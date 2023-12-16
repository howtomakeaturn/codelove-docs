# 緩存系統

- [簡介](#introduction)
- [配置](#configuration)
    - [驅動的前提條件](#driver-prerequisites)
- [緩存使用](#cache-usage)
    - [獲取緩存實例](#obtaining-a-cache-instance)
    - [從緩存獲取數據](#retrieving-items-from-the-cache)
    - [向緩存存儲數據](#storing-items-in-the-cache)
    - [從緩存刪除數據](#removing-items-from-the-cache)
    - [Cache 輔助函數](#the-cache-helper)
- [緩存標記](#cache-tags)
    - [存儲被標記的緩存數據](#storing-tagged-cache-items)
    - [訪問被標記的緩存數據](#accessing-tagged-cache-items)
    - [刪除被標記的緩存數據](#removing-tagged-cache-items)
    - [清理過期的緩存標記](#pruning-stale-cache-tags)
- [原子鎖](#atomic-locks)
    - [驅動的前提條件](#lock-driver-prerequisites)
    - [管理鎖](#managing-locks)
    - [跨進程管理鎖](#managing-locks-across-processes)
- [添加自定義緩存驅動](#adding-custom-cache-drivers)
    - [編寫驅動](#writing-the-driver)
    - [注冊驅動](#registering-the-driver)
- [事件](#events)

<a name="introduction"></a>
## 簡介

在某些應用中，一些查詢數據或處理任務的操作會在某段時間里短時間內大量進行，或是一個操作花費好幾秒鐘。當出現這種情況時，通常會將檢索到的數據緩存起來，從而為後面請求同一數據的請求迅速返回結果。這些緩存數據通常會儲存在極快的存儲系統中，例如 [Memcached](https://memcached.org) 和 [Redis](https://redis.io)。

Laravel 為各種緩存後端提供了富有表現力且統一的 API，以便你利用它們極快的查詢數據來加快你的應用。

<a name="configuration"></a>
## 配置

緩存配置文件位於 `config/cache.php`。在這個文件中，你可以指定應用默認使用哪個緩存驅動。Laravel 支持的緩存後端包括 [Memcached](https://memcached.org)、[Redis](https://redis.io)、[DynamoDB](https://aws.amazon.com/dynamodb)，以及現成的關系型數據庫。此外，還支持基於文件的緩存驅動，以及方便自動化測試的緩存驅動 `array` 和 `null` 。

緩存配置文件還包含文件中記錄的各種其他選項，因此請務必閱讀這些選項。 默認情況下，Laravel 配置為使用 `file` 緩存驅動，它將序列化的緩存對象存儲在服務器的文件系統中。 對於較大的應用程序，建議你使用更強大的驅動，例如 Memcached 或 Redis。 你甚至可以為同一個驅動配置多個緩存配置。

<a name="driver-prerequisites"></a>
### 驅動先決條件

<a name="prerequisites-database"></a>
#### Database

使用 `database` 緩存驅動時，你需要設置一個表來包含緩存項。你將在下表中找到 `Schema` 聲明的示例：

    Schema::create('cache', function (Blueprint $table) {
        $table->string('key')->unique();
        $table->text('value');
        $table->integer('expiration');
    });

> **注意**
> 你還可以使用 `php artisan cache:table` Artisan 命令生成具有適當模式的遷移。

<a name="memcached"></a>
#### Memcached

使用 Memcached 驅動程序需要安裝 [Memcached PECL 包](https://pecl.php.net/package/memcached)。你可以在  `config/cache.php` 配置文件中列出所有的 Memcached 服務器。該文件已經包含一個 `memcached.servers` 來幫助你入門：

    'memcached' => [
        'servers' => [
            [
                'host' => env('MEMCACHED_HOST', '127.0.0.1'),
                'port' => env('MEMCACHED_PORT', 11211),
                'weight' => 100,
            ],
        ],
    ],

如果需要，你可以將 `host` 選項設置為 UNIX socket 的路徑。 如果這樣做， `port` 選項應設置為 `0`：

    'memcached' => [
        [
            'host' => '/var/run/memcached/memcached.sock',
            'port' => 0,
            'weight' => 100
        ],
    ],

<a name="redis"></a>
#### Redis

在將 Redis 緩存與 Laravel 一起使用之前，您需要通過 PECL 安裝 PhpRedis PHP 擴展或通過 Composer 安裝 `predis/predis` 包（~1.0）。[Laravel Sail](/docs/laravel/10.x/sail) 已經包含了這個擴展。另外，Laravel 官方部署平台如 [Laravel Forge](https://forge.laravel.com) 和 [Laravel Vapor](https://vapor.laravel.com) 也默認安裝了 PhpRedis 擴展。

有關配置 Redis 的更多信息，請參閱其 [Laravel documentation page](/docs/laravel/10.x/redis#configuration).

<a name="dynamodb"></a>
#### DynamoDB

在使用 [DynamoDB](https://aws.amazon.com/dynamodb)  緩存驅動程序之前，您必須創建一個 DynamoDB 表來存儲所有緩存的數據。通常，此表應命名為`cache`。但是，您應該根據應用程序的緩存配置文件中的 `stores.dynamodb.table` 配置值來命名表。

該表還應該有一個字符串分區鍵，其名稱對應於應用程序的緩存配置文件中的 `stores.dynamodb.attributes.key` 配置項的值。 默認情況下，分區鍵應命名為 `key`。

<a name="cache-usage"></a>
## 緩存用法

<a name="obtaining-a-cache-instance"></a>
### 獲取緩存實例

要獲取緩存存儲實例，您可以使用 `Cache` 門面類，我們將在本文檔中使用它。`Cache` 門面類提供了對 Laravel 緩存底層實現的方便、簡單的訪問：

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Support\Facades\Cache;

    class UserController extends Controller
    {
        /**
         * 顯示應用程序所有用戶的列表。
         */
        public function index(): array
        {
            $value = Cache::get('key');

            return [
                // ...
            ];
        }
    }

<a name="accessing-multiple-cache-stores"></a>
#### 訪問多個緩存存儲

使用 `Cache` 門面類, 您可以通過 `store` 方法訪問各種緩存存儲。傳遞給 `store` 方法的鍵應該對應於 `cache` 配置文件中的 `stores` 配置數組中列出的存儲之一：

    $value = Cache::store('file')->get('foo');

    Cache::store('redis')->put('bar', 'baz', 600); // 10 分鐘

<a name="retrieving-items-from-the-cache"></a>
### 從緩存中檢索項目

`Cache` 門面的 `get` 方法用於從緩存中檢索項目。如果緩存中不存在該項目，則將返回 `null`。如果您願意，您可以將第二個參數傳遞給 `get` 方法，指定您希望在項目不存在時返回的默認值：

    $value = Cache::get('key');

    $value = Cache::get('key', 'default');

您甚至可以將閉包作為默認值傳遞。如果指定的項在緩存中不存在，則返回閉包的結果。傳遞閉包允許您推遲從數據庫或其他外部服務中檢索默認值：

    $value = Cache::get('key', function () {
        return DB::table(/* ... */)->get();
    });

<a name="checking-for-item-existence"></a>
#### 檢查項目是否存在

`has` 方法可用於確定緩存中是否存在項目。如果項目存在但其值為 `null`，此方法也將返回 `false`：

    if (Cache::has('key')) {
        // ...
    }

<a name="incrementing-decrementing-values"></a>
#### 遞增 / 遞減值

`increment` 和 `decrement` 方法可用於調整緩存中整數項的值。這兩種方法都接受一個可選的第二個參數，指示增加或減少項目值的數量：

    Cache::increment('key');
    Cache::increment('key', $amount);
    Cache::decrement('key');
    Cache::decrement('key', $amount);

<a name="retrieve-store"></a>
#### 檢索和存儲

有時你可能希望從緩存中檢索一個項目，但如果請求的項目不存在，則存儲一個默認值。 例如， 你可能希望從緩存中檢索所有用戶，如果用戶不存在，則從數據庫中檢索並將它們添加到緩存中。 你可以使用 `Cache::remember` 方法執行此操作：

    $value = Cache::remember('users', $seconds, function () {
        return DB::table('users')->get();
    });

如果該項不存在於緩存中，將執行傳遞給 `remember` 方法的閉包，並將其結果放入緩存中。

你可以使用 `rememberForever` 方法從緩存中檢索一個項目，如果它不存在則永久存儲它：

    $value = Cache::rememberForever('users', function () {
        return DB::table('users')->get();
    });

<a name="retrieve-delete"></a>
#### 檢索和刪除

如果你需要從緩存中檢索一項後並刪除該項，你可以使用 `pull` 方法。 與 `get` 方法一樣，如果該項不存在於緩存中，將返回 `null`：

    $value = Cache::pull('key');

<a name="storing-items-in-the-cache"></a>
### 在緩存中存儲項目

你可以使用 `Cache` Facade上的 `put` 方法將項目存儲在緩存中：

    Cache::put('key', 'value', $seconds = 10);

如果存儲時間沒有傳遞給 `put` 方法，則該項目將無限期存儲：

    Cache::put('key', 'value');

除了將秒數作為整數傳遞之外，你還可以傳遞一個代表緩存項所需過期時間的 `DateTime` 實例：

    Cache::put('key', 'value', now()->addMinutes(10));

<a name="store-if-not-present"></a>
#### 如果不存在則存儲

`add` 方法只會將緩存存儲中不存在的項目添加到緩存中。如果項目實際添加到緩存中，該方法將返回 `true`。 否則，該方法將返回 `false`。 `add` 方法是一個原子操作：

    Cache::add('key', 'value', $seconds);

<a name="storing-items-forever"></a>
#### 永久存儲

`forever` 方法可用於將項目永久存儲在緩存中。由於這些項目不會過期，因此必須使用 `forget` 方法手動將它們從緩存中刪除：

    Cache::forever('key', 'value');

> **注意**
> 如果您使用的是 Memcached 驅動程序，則當緩存達到其大小限制時，可能會刪除「永久」存儲的項目。

<a name="removing-items-from-the-cache"></a>
### 從緩存中刪除項目

您可以使用 `forget` 方法從緩存中刪除項目：

    Cache::forget('key');

您還可以通過提供零或負數的過期秒數來刪除項目：

    Cache::put('key', 'value', 0);

    Cache::put('key', 'value', -5);

您可以使用 `flush` 方法清除整個緩存：

    Cache::flush();

> **注意**
> 刷新緩存不會考慮您配置的緩存「前綴，並且會從緩存中刪除所有條目。在清除由其他應用程序共享的緩存時，請考慮到這一點。

<a name="the-cache-helper"></a>
### 緩存助手函數

除了使用 `Cache` 門面之外，您還可以使用全局 `cache` 函數通過緩存檢索和存儲數據。當使用單個字符串參數調用 `cache` 函數時，它將返回給定鍵的值：

    $value = cache('key');

如果您向函數提供鍵 / 值對數組和過期時間，它將在指定的持續時間內將值存儲在緩存中：

    cache(['key' => 'value'], $seconds);

    cache(['key' => 'value'], now()->addMinutes(10));

當不帶任何參數調用 cache 函數時，它會返回 Illuminate\Contracts\Cache\Factory 實現的實例，允許您調用其他緩存方法：

    cache()->remember('users', $seconds, function () {
        return DB::table('users')->get();
    });

> **技巧**
> 在測試對全局 `cache` 函數的調用時，您可以使用 `Cache::shouldReceive` 方法，就像 [testing the facade](/docs/laravel/10.x/mocking#mocking-facades).
<a name="cache-tags"></a>

## 緩存標簽

> **注意**
> 使用 `file`, `dynamodb` 或 `database` 存驅動程序時不支持緩存標記。 此外，當使用帶有「永久」存儲的緩存的多個標簽時，使用諸如「memcached」之類的驅動程序會獲得最佳性能，它會自動清除陳舊的記錄。
<a name="storing-tagged-cache-items"></a>

### 存儲緩存標簽

緩存標簽允許您在緩存中標記相關項目，然後刷新所有已分配給定標簽的緩存值。您可以通過傳入標記名稱的有序數組來訪問標記緩存。例如，讓我們訪問一個標記的緩存並將一個值`put`緩存中：

    Cache::tags(['people', 'artists'])->put('John', $john, $seconds);

    Cache::tags(['people', 'authors'])->put('Anne', $anne, $seconds);

<a name="accessing-tagged-cache-items"></a>

### 訪問緩存標簽

要檢索標記的緩存項，請將相同的有序標簽列表傳遞給 tags 方法，然後使用您要檢索的鍵調用 `get` 方法：

    $john = Cache::tags(['people', 'artists'])->get('John');

    $anne = Cache::tags(['people', 'authors'])->get('Anne');

<a name="removing-tagged-cache-items"></a>
### 刪除被標記的緩存數據

你可以刷新所有分配了標簽或標簽列表的項目。 例如，此語句將刪除所有標記有 `people`, `authors`或兩者的緩存。因此，`Anne` 和 `John` 都將從緩存中刪除：

    Cache::tags(['people', 'authors'])->flush();

相反，此語句將僅刪除帶有 `authors` 標記的緩存，因此將刪除 `Anne`，但不會刪除 `John`：

    Cache::tags('authors')->flush();

<a name="pruning-stale-cache-tags"></a>
### 清理過期的緩存標記

> **注意**
> 僅在使用 Redis 作為應用程序的緩存驅動程序時，才需要清理過期的緩存標記。

為了在使用 Redis 緩存驅動程序時正確清理過期的緩存標記，Laravel 的 Artisan 命令 `cache:prune-stale-tags` 應該被添加到 [任務調度](/docs/laravel/10.x/scheduling) 中，在應用程序的 `App\Console\Kernel` 類里：

    $schedule->command('cache:prune-stale-tags')->hourly();

<a name="atomic-locks"></a>
## 原子鎖

> **注意**
> 要使用此功能，您的應用程序必須使用`memcached`、`redis`、`dynamicodb`、`database`、`file`或`array`緩存驅動程序作為應用程序的默認緩存驅動程序。
此外，所有服務器都必須與同一中央緩存服務器通信。

<a name="lock-driver-prerequisites"></a>
### 驅動程序先決條件

<a name="atomic-locks-prerequisites-database"></a>
#### 數據庫

使用“數據庫”緩存驅動程序時，您需要設置一個表來包含應用程序的緩存鎖。您將在下表中找到一個示例 `Schema` 聲明：

    Schema::create('cache_locks', function (Blueprint $table) {
        $table->string('key')->primary();
        $table->string('owner');
        $table->integer('expiration');
    });

<a name="managing-locks"></a>
### 管理鎖

原子鎖允許操作分布式鎖而不用擔心競爭條件。例如，[Laravel Forge](https://forge.laravel.com) 使用原子鎖來確保服務器上一次只執行一個遠程任務。您可以使用 `Cache::lock` 方法創建和管理鎖：

    use Illuminate\Support\Facades\Cache;

    $lock = Cache::lock('foo', 10);

    if ($lock->get()) {
        // 鎖定 10 秒…

        $lock->release();
    }

`get` 方法也接受一個閉包。閉包執行後，Laravel 會自動釋放鎖：

    Cache::lock('foo', 10)->get(function () {
        // 鎖定 10 秒並自動釋放...
    });

如果在您請求時鎖不可用，您可以指示 Laravel 等待指定的秒數。如果在指定的時間限制內無法獲取鎖，則會拋出 Illuminate\Contracts\Cache\LockTimeoutException：

    use Illuminate\Contracts\Cache\LockTimeoutException;

    $lock = Cache::lock('foo', 10);

    try {
        $lock->block(5);

        // 等待最多 5 秒後獲得的鎖...
    } catch (LockTimeoutException $e) {
        // 無法獲取鎖…
    } finally {
        $lock?->release();
    }

上面的例子可以通過將閉包傳遞給 `block` 方法來簡化。當一個閉包被傳遞給這個方法時，Laravel 將嘗試在指定的秒數內獲取鎖，並在閉包執行後自動釋放鎖：

    Cache::lock('foo', 10)->block(5, function () {
        // 等待最多 5 秒後獲得的鎖...
    });

<a name="managing-locks-across-processes"></a>
### 跨進程管理鎖

有時，您可能希望在一個進程中獲取鎖並在另一個進程中釋放它。例如，您可能在 Web 請求期間獲取鎖，並希望在由該請求觸發的排隊作業結束時釋放鎖。在這種情況下，您應該將鎖的作用域`owner token`傳遞給排隊的作業，以便作業可以使用給定的令牌重新實例化鎖。

在下面的示例中，如果成功獲取鎖，我們將調度一個排隊的作業。 此外，我們將通過鎖的`owner`方法將鎖的所有者令牌傳遞給排隊的作業：

    $podcast = Podcast::find($id);

    $lock = Cache::lock('processing', 120);

    if ($lock->get()) {
        ProcessPodcast::dispatch($podcast, $lock->owner());
    }

在我們應用程序的`ProcessPodcast`作業中，我們可以使用所有者令牌恢覆和釋放鎖：

    Cache::restoreLock('processing', $this->owner)->release();

如果你想釋放一個鎖而不考慮它的當前所有者，你可以使用`forceRelease`方法：

    Cache::lock('processing')->forceRelease();

<a name="adding-custom-cache-drivers"></a>
## 添加自定義緩存驅動

<a name="writing-the-driver"></a>
### 編寫驅動

要創建我們的自定義緩存驅動程序，我們首先需要實現`Illuminate\Contracts\Cache\Store` [contract](/docs/laravel/10.x/contracts)。 因此，MongoDB 緩存實現可能如下所示：

    <?php

    namespace App\Extensions;

    use Illuminate\Contracts\Cache\Store;

    class MongoStore implements Store
    {
        public function get($key) {}
        public function many(array $keys) {}
        public function put($key, $value, $seconds) {}
        public function putMany(array $values, $seconds) {}
        public function increment($key, $value = 1) {}
        public function decrement($key, $value = 1) {}
        public function forever($key, $value) {}
        public function forget($key) {}
        public function flush() {}
        public function getPrefix() {}
    }

我們只需要使用 MongoDB 連接來實現這些方法中的每一個。有關如何實現這些方法的示例，請查看 [Laravel 框架源代碼](https://github.com/laravel/framework)中的`Illuminate\Cache\MemcachedStore`。 一旦我們的實現完成，我們可以通過調用`Cache` 門面的`extend`方法來完成我們的自定義驅動程序注冊：

    Cache::extend('mongo', function (Application $app) {
        return Cache::repository(new MongoStore);
    });

> **技巧**
> 如果你想知道將自定義緩存驅動程序代碼放在哪里，可以在你的`app`目錄中創建一個`Extensions`命名空間。 但是請記住，Laravel 沒有嚴格的應用程序結構，你可以根據自己的喜好自由組織應用程序。

<a name="registering-the-driver"></a>
### 注冊驅動

要向 Laravel 注冊自定義緩存驅動程序，我們將使用`Cache`門面的`extend`方法。 由於其他服務提供者可能會嘗試在他們的`boot`方法中讀取緩存值，我們將在`booting`回調中注冊我們的自定義驅動程序。 通過使用`booting`回調，我們可以確保在應用程序的服務提供者調用`boot`方法之前但在所有服務提供者調用`register`方法之後注冊自定義驅動程序。 我們將在應用程序的`App\Providers\AppServiceProvider`類的`register`方法中注冊我們的`booting`回調：

    <?php

    namespace App\Providers;

    use App\Extensions\MongoStore;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\Facades\Cache;
    use Illuminate\Support\ServiceProvider;

    class CacheServiceProvider extends ServiceProvider
    {
        /**
         * 注冊任何應用程序服務。
         */
        public function register(): void
        {
            $this->app->booting(function () {
                 Cache::extend('mongo', function (Application $app) {
                     return Cache::repository(new MongoStore);
                 });
             });
        }

        /**
         * 引導任何應用程序服務。
         */
        public function boot(): void
        {
            // ...
        }
    }

傳遞給`extend`方法的第一個參數是驅動程序的名稱。這將對應於`config/cache.php`配置文件中的 `driver`選項。 第二個參數是一個閉包，它應該返回一個`Illuminate\Cache\Repository`實例。閉包將傳遞一個`$app`實例，它是[服務容器](/docs/laravel/10.x/container)的一個實例。

注冊擴展程序後，將`config/cache.php`配置文件的`driver`選項更新為擴展程序的名稱。

<a name="events"></a>
## 事件

要在每個緩存操作上執行代碼，你可以偵聽緩存觸發的 [events](/docs/laravel/10.x/events) 。 通常，你應該將這些事件偵聽器放在應用程序的`App\Providers\EventServiceProvider`類中：

    use App\Listeners\LogCacheHit;
    use App\Listeners\LogCacheMissed;
    use App\Listeners\LogKeyForgotten;
    use App\Listeners\LogKeyWritten;
    use Illuminate\Cache\Events\CacheHit;
    use Illuminate\Cache\Events\CacheMissed;
    use Illuminate\Cache\Events\KeyForgotten;
    use Illuminate\Cache\Events\KeyWritten;

    /**
     * 應用程序的事件偵聽器映射。
     *
     * @var array
     */
    protected $listen = [
        CacheHit::class => [
            LogCacheHit::class,
        ],

        CacheMissed::class => [
            LogCacheMissed::class,
        ],

        KeyForgotten::class => [
            LogKeyForgotten::class,
        ],

        KeyWritten::class => [
            LogKeyWritten::class,
        ],
    ];
