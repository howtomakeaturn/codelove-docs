
# HTTP 會話機制

- [簡介](#introduction)
    - [配置](#configuration)
    - [驅動程序先決條件](#driver-prerequisites)
- [使用 Session](#interacting-with-the-session)
    - [獲取數據](#retrieving-data)
    - [存儲數據](#storing-data)
    - [閃存數據](#flash-data)
    - [刪除數據](#deleting-data)
    - [重新生成 Session ID](#regenerating-the-session-id)
- [Session Blocking](#session-blocking)
- [添加自定義 Session 驅動](#adding-custom-session-drivers)
    - [實現驅動](#implementing-the-driver)
    - [注冊驅動](#registering-the-driver)

<a name="introduction"></a>
## 簡介

由於 HTTP 驅動的應用程序是無狀態的，Session 提供了一種在多個請求之間存儲有關用戶信息的方法，這類信息一般都存儲在後續請求可以訪問的持久存儲 / 後端中。

Laravel 通過同一個可讀性強的 API 處理各種自帶的後台驅動程序。支持諸如比較熱門的[Memcached](https://memcached.org)、 [Redis](https://redis.io)和數據庫。

<a name="configuration"></a>
### 配置

Session 的配置文件存儲在`config/session.php`文件中。請務必查看此文件中對於你而言可用的選項。默認情況下，Laravel 為絕大多數應用程序配置的 Session 驅動為`file` 驅動，它適用於大多數程序。如果你的應用程序需要在多個 Web 服務器之間進行負載平衡，你應該選擇一個所有服務器都可以訪問的集中式存儲，例如 Redis 或數據庫。

Session`driver`的配置預設了每個請求存儲 Session 數據的位置。Laravel 自帶了幾個不錯而且開箱即用的驅動：

<div class="content-list" markdown="1">

- `file` - Sessions 存儲在`storage/framework/sessions`。
- `cookie` - Sessions 被存儲在安全加密的 cookie 中。
- `database` - Sessions 被存儲在關系型數據庫中。
- `memcached` / `redis` - Sessions 被存儲在基於高速緩存的存儲系統中。
- `dynamodb` - Sessions 被存儲在 AWS DynamoDB 中。
- `array` - Sessions 存儲在 PHP 數組中，但不會被持久化。

</div>

> **技巧**
> 數組驅動一般用於[測試](/docs/laravel/10.x/testing)並且防止存儲在 Session 中的數據被持久化。



<a name="driver-prerequisites"></a>
### 驅動先決條件

<a name="database"></a>
#### 數據庫

使用`database`Session 驅動時，你需要創建一個記錄 Session 的表。下面是`Schema`的聲明示例：

    use Illuminate\Database\Schema\Blueprint;
    use Illuminate\Support\Facades\Schema;

    Schema::create('sessions', function (Blueprint $table) {
        $table->string('id')->primary();
        $table->foreignId('user_id')->nullable()->index();
        $table->string('ip_address', 45)->nullable();
        $table->text('user_agent')->nullable();
        $table->text('payload');
        $table->integer('last_activity')->index();
    });

你可以使用 Artisan 命令`session:table`生成這個遷移。了解更多數據庫遷移，請查看完整的文檔[遷移文檔](/docs/laravel/10.x/migrations):

```shell
php artisan session:table

php artisan migrate
```

<a name="redis"></a>
#### Redis

在 Laravel 使用 Redis Session 驅動前，你需要安裝 PhpRedis PHP 擴展，可以通過 PECL 或者 通過 Composer 安裝這個`predis/predis`包 (~1.0)。更多關於 Redis 配置信息，查詢 Laravel 的 [Redis 文檔](/docs/laravel/10.x/redis#configuration).

> **技巧**
> 在`session`配置文件里，`connection`選項可以用來設置 Session 使用 Redis 連接方式。

<a name="interacting-with-the-session"></a>
## 使用 Session

<a name="retrieving-data"></a>
### 獲取數據

在 Laravel 中有兩種基本的 Session 使用方式：全局`session`助手函數和通過`Request`實例。首先看下通過`Request`實例訪問 Session , 它可以隱式綁定路由閉包或者控制器方法。記住，Laravel 會自動注入控制器方法的依賴。[服務容器](/docs/laravel/10.x/container)：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Http\Request;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * 顯示指定用戶個人資料。
         */
        public function show(Request $request, string $id): View
        {
            $value = $request->session()->get('key');

            // ...

            $user = $this->users->find($id);

            return view('user.profile', ['user' => $user]);
        }
    }



當你從 Session 獲取數據時，你也可以在`get`方法第二個參數里傳遞一個 default 默認值，如果 Session 里不存在鍵值對 key 的數據結果，這個默認值就會返回。如果你傳遞給`get`方法一個閉包作為默認值，這個閉包會被執行並且返回結果：

    $value = $request->session()->get('key', 'default');

    $value = $request->session()->get('key', function () {
        return 'default';
    });

<a name="the-global-session-helper"></a>
#### 全局 Session 助手函數

你也可以在 Session 里使用 PHP 全局`session`函數獲取和儲存數據。當這個`session`函數以一個單獨的字符串形式被調用時，它將會返回這個 Session 鍵值對的結果。當函數以 key / value 數組形式被調用時，這些值會被存儲在 Session 里：

    Route::get('/home', function () {
        // 從 Session 獲取數據 ...
        $value = session('key');

        // 設置默認值...
        $value = session('key', 'default');

        // 在Session 里存儲一段數據 ...
        session(['key' => 'value']);
    });

> **技巧**
> 通過 HTTP 請求實例與通過`session`助手函數方式使用 Session 之間沒有實際區別。兩種方式都是[可的測試](/docs/laravel/10.x/testing)，你所有的測試用例中都可以通過 `assertSessionHas`方法進行斷言。

<a name="retrieving-all-session-data"></a>
#### 獲取所有 Session 數據

如果你想要從 Session 里獲取所有數據，你可以使用`all`方法：

    $data = $request->session()->all();



<a name="determining-if-an-item-exists-in-the-session"></a>
#### 判斷 Session 里是否存在條目

判斷 Session 里是否存在一個條目，你可以使用`has`方法。如果條目存在`has`，方法返回`true`不存在則返回`null`：

    if ($request->session()->has('users')) {
        // ...
    }

判斷 Session 里是否存在一個即使結果值為`null`的條目，你可以使用`exists`方法：

    if ($request->session()->exists('users')) {
        // ...
    }

要確定某個條目是否在會話中不存在，你可以使用 `missing`方法。如果條目不存在，`missing`方法返回`true`：

    if ($request->session()->missing('users')) {
        // ...
    }

<a name="storing-data"></a>
### 存儲數據

Session 里存儲數據，你通常將使用 Request 實例中的`put`方法或者`session`助手函數：

    // 通過 Request 實例存儲 ...
    $request->session()->put('key', 'value');

    // 通過全局 Session 助手函數存儲 ...
    session(['key' => 'value']);

<a name="pushing-to-array-session-values"></a>
#### Session 存儲數組

`push`方法可以把一個新值推入到以數組形式存儲的 session 值里。例如：如果`user.teams`鍵值對有一個關於團隊名字的數組，你可以推入一個新值到這個數組里：

    $request->session()->push('user.teams', 'developers');

<a name="retrieving-deleting-an-item"></a>
#### 獲取 & 刪除條目

`pull`方法會從 Session 里獲取並且刪除一個條目，只需要一步如下：

    $value = $request->session()->pull('key', 'default');

<a name="#incrementing-and-decrementing-session-values"></a>
#### 遞增 / 遞減會話值



如果你的 Session 數據里有整形你希望進行加減操作，可以使用`increment`和`decrement`方法：

    $request->session()->increment('count');

    $request->session()->increment('count', $incrementBy = 2);

    $request->session()->decrement('count');

    $request->session()->decrement('count', $decrementBy = 2);

<a name="flash-data"></a>
### 閃存數據

有時你可能想在 Session 里為下次請求存儲一些條目。你可以使用`flash`方法。使用這個方法，存儲在 Session 的數據將立即可用並且會保留到下一個 HTTP 請求期間，之後會被刪除。閃存數據主要用於短期的狀態消息：

    $request->session()->flash('status', 'Task was successful!');

如果你需要為多次請求持久化閃存數據，可以使用`reflash`方法，它會為一個額外的請求保持住所有的閃存數據，如果你僅需要保持特定的閃存數據，可以使用`keep`方法：

    $request->session()->reflash();

    $request->session()->keep(['username', 'email']);

如果你僅為了當前的請求持久化閃存數據，可以使用`now` 方法：

    $request->session()->now('status', 'Task was successful!');

<a name="deleting-data"></a>
### 刪除數據

`forget`方法會從 Session 刪除一些數據。如果你想刪除所有 Session 數據，可以使用`flush`方法：

    // 刪除一個單獨的鍵值對 ...
    $request->session()->forget('name');

    // 刪除多個 鍵值對 ...
    $request->session()->forget(['name', 'status']);

    $request->session()->flush();



<a name="regenerating-the-session-id"></a>
### 重新生成 Session ID

重新生成 Session ID 經常被用來阻止惡意用戶使用 [session fixation](https://owasp.org/www-community/attacks/Session_fixation) 攻擊你的應用。

如果你正在使用[入門套件](/docs/laravel/10.x/starter-kits)或 [Laravel Fortify](/docs/laravel/10.x/fortify)中的任意一種， Laravel 會在認證階段自動生成 Session ID；然而如果你需要手動重新生成 Session ID ，可以使用`regenerate`方法：

    $request->session()->regenerate();

如果你需要重新生成 Session ID 並同時刪除所有 Session 里的數據，可以使用`invalidate`方法：

    $request->session()->invalidate();

<a name="session-blocking"></a>
## Session 阻塞

> **注意**
> 應用 Session 阻塞功能，你的應用必須使用一個支持[原子鎖 ](/docs/laravel/10.x/cache#atomic-locks)的緩存驅動。目前，可用的緩存驅動有`memcached`、 `dynamodb`、 `redis`和`database`等。另外，你可能不會使用`cookie` Session 驅動。

默認情況下，Laravel 允許使用同一 Session 的請求並發地執行，舉例來說，如果你使用一個 JavaScript HTTP 庫向你的應用執行兩次 HTTP 請求，它們將同時執行。對多數應用這不是問題，然而 在一小部分應用中可能出現 Session 數據丟失，這些應用會向兩個不同的應用端並發請求，並同時寫入數據到 Session。

為了解決這個問題，Laravel 允許你限制指定 Session 的並發請求。首先，你可以在路由定義時使用`block`鏈式方法。在這個示例中，一個到`/profile`的路由請求會拿到一把 Session 鎖。當它處在鎖定狀態時，任何使用相同 Session ID 的到`/profile`或`/order`的路由請求都必須等待，直到第一個請求處理完成後再繼續執行：

    Route::post('/profile', function () {
        // ...
    })->block($lockSeconds = 10, $waitSeconds = 10)

    Route::post('/order', function () {
        // ...
    })->block($lockSeconds = 10, $waitSeconds = 10)



`block`方法接受兩個可選參數。`block`方法接受的第一個參數是 Session 鎖釋放前應該持有的最大秒數。當然，如果請求在此時間之前完成執行，鎖將提前釋放。

`block`方法接受的第二個參數是請求在試圖獲得 Session 鎖時應該等待的秒數。如果請求在給定的秒數內無法獲得會話鎖，將拋出`Illuminate\Contracts\Cache\LockTimeoutException`異常。

如果不傳參，那麽 Session 鎖默認鎖定最大時間是 10 秒，請求鎖最大的等待時間也是 10 秒：

    Route::post('/profile', function () {
        // ...
    })->block()

<a name="adding-custom-session-drivers"></a>
## 添加自定義 Session 驅動

<a name="implementing-the-driver"></a>
#### 實現驅動

如果現存的 Session 驅動不能滿足你的需求，Laravel 允許你自定義 Session Handler。你的自定義驅動應實現 PHP 內置的`SessionHandlerInterface`。這個接口僅包含幾個方法。以下是 MongoDB 驅動實現的代碼片段：

    <?php

    namespace App\Extensions;

    class MongoSessionHandler implements \SessionHandlerInterface
    {
        public function open($savePath, $sessionName) {}
        public function close() {}
        public function read($sessionId) {}
        public function write($sessionId, $data) {}
        public function destroy($sessionId) {}
        public function gc($lifetime) {}
    }

> **技巧**
> Laravel 沒有內置存放擴展的目錄，你可以放置在任意目錄下，這個示例里，我們創建了一個`Extensions`目錄存放`MongoSessionHandler`。



由於這些方法的含義並非通俗易懂，因此我們快速瀏覽下每個方法：

<div class="content-list" markdown="1">

- `open`方法通常用於基於文件的 Session 存儲系統。因為 Laravel 附帶了一個`file`  Session 驅動。你無須在里面寫任何代碼。可以簡單地忽略掉。
- `close`方法跟`open`方法很像，通常也可以忽略掉。對大多數驅動來說，它不是必須的。
- `read` 方法應返回與給定的`$sessionId`關聯的 Session 數據的字符串格式。在你的驅動中獲取或存儲 Session 數據時，無須作任何序列化和編碼的操作，Laravel 會自動為你執行序列化。
- `write`方法將與`$sessionId`關聯的給定的`$data`字符串寫入到一些持久化存儲系統，如 MongoDB 或者其他你選擇的存儲系統。再次，你無須進行任何序列化操作，Laravel 會自動為你處理。
- `destroy`方法應可以從持久化存儲中刪除與`$sessionId`相關聯的數據。
- `gc`方法應可以銷毀給定的`$lifetime`（UNIX 時間戳格式 ）之前的所有 Session 數據。對於像 Memcached 和 Redis 這類擁有過期機制的系統來說，本方法可以置空。

</div>

<a name="registering-the-driver"></a>
#### 注冊驅動

一旦你的驅動實現了，需要注冊到 Laravel 。在 Laravel 中添加額外的驅動到 Session 後端 ，你可以使用`Session` [Facade](/docs/laravel/10.x/facades) 提供的`extend`方法。你應該在[服務提供者](/docs/laravel/10.x/providers)中的`boot`方法中調用`extend`方法。可以通過已有的`App\Providers\AppServiceProvider`或創建一個全新的服務提供者執行此操作：

    <?php

    namespace App\Providers;

    use App\Extensions\MongoSessionHandler;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\Facades\Session;
    use Illuminate\Support\ServiceProvider;

    class SessionServiceProvider extends ServiceProvider
    {
        /**
         * 注冊任意應用服務。
         */
        public function register(): void
        {
            // ...
        }

        /**
         * 啟動任意應用服務。
         */
        public function boot(): void
        {
            Session::extend('mongo', function (Application $app) {
                // 返回一個 SessionHandlerInterface 接口的實現 ...
                return new MongoSessionHandler;
            });
        }
    }



一旦 Session 驅動注冊完成，就可以在`config/session.php`配置文件選擇使用`mongo` 驅動。
