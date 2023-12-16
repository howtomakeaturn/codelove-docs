# 隊列

- [簡介](#introduction)
    - [連接 Vs. 驅動](#connections-vs-queues)
    - [驅動程序說明 & 先決條件](#driver-prerequisites)
- [創建任務](#creating-jobs)
    - [生成任務類](#generating-job-classes)
    - [任務類結構](#class-structure)
    - [唯一任務](#unique-jobs)
- [任務中間件](#job-middleware)
    - [訪問限制](#rate-limiting)
    - [防止任務重覆](#preventing-job-overlaps)
    - [限制異常](#throttling-exceptions)
- [任務調度](#dispatching-jobs)
    - [延遲調度](#delayed-dispatching)
    - [同步調度](#synchronous-dispatching)
    - [任務 & 數據庫事務](#jobs-and-database-transactions)
    - [任務鏈](#job-chaining)
    - [自定義隊列 & 連接](#customizing-the-queue-and-connection)
    - [指定任務最大嘗試次數 / 超時值](#max-job-attempts-and-timeout)
    - [錯誤處理](#error-handling)
- [任務批處理](#job-batching)
    - [定義可批處理任務](#defining-batchable-jobs)
    - [分派批處理](#dispatching-batches)
    - [將任務添加到批處理](#adding-jobs-to-batches)
    - [校驗批處理](#inspecting-batches)
    - [取消批處理](#cancelling-batches)
    - [批處理失敗](#batch-failures)
    - [批量清理](#pruning-batches)
- [隊列閉包](#queueing-closures)
- [運行隊列處理器](#running-the-queue-worker)
    - [`queue:work` 命令](#the-queue-work-command)
    - [隊列優先級](#queue-priorities)
    - [隊列處理器 & 部署](#queue-workers-and-deployment)
    - [任務過期 & 超時](#job-expirations-and-timeouts)
- [Supervisor 配置](#supervisor-configuration)
- [處理失敗任務](#dealing-with-failed-jobs)
    - [清理失敗任務](#cleaning-up-after-failed-jobs)
    - [重試失敗任務](#retrying-failed-jobs)
    - [忽略缺失的模型](#ignoring-missing-models)
    - [清理失敗的任務](#pruning-failed-jobs)
    - [在 DynamoDB 中存儲失敗的任務](#storing-failed-jobs-in-dynamodb)
    - [禁用失敗的任務存儲](#disabling-failed-job-storage)
    - [任務失敗事件](#failed-job-events)
- [清理隊列任務](#clearing-jobs-from-queues)
- [監控你的隊列](#monitoring-your-queues)
- [測試](#testing)
    - [偽造任務的一個子集](#faking-a-subset-of-jobs)
    - [測試任務鏈](#testing-job-chains)
    - [測試任務批處理](#testing-job-batches)
- [任務事件](#job-events)

<a name="introduction"></a>
## 簡介

在構建 Web 應用程序時，你可能需要執行一些任務，例如解析和存儲上傳的 CSV 文件，這些任務在典型的 Web 請求期間需要很長時間才能執行。 值得慶幸的是，Laravel 允許你輕松創建可以在後台處理的隊列任務。 通過將時間密集型任務移至隊列，你的應用程序可以以極快的速度響應 Web 請求，並為你的客戶提供更好的用戶體驗。

Laravel 隊列為各種不同的隊列驅動提供統一的隊列 API，例如 [Amazon SQS](https://aws.amazon.com/sqs/)，[Redis](https://redis.io)，甚至關系數據庫。

Laravel 隊列的配置選項存儲在 `config/queue.php` 文件中。 在這個文件中，你可以找到框架中包含的每個隊列驅動的連接配置，包括數據庫， [Amazon SQS](https://aws.amazon.com/sqs/), [Redis](https://redis.io)， 和 [Beanstalkd](https://beanstalkd.github.io/) 驅動，以及一個會立即執行作業的同步驅動（用於本地開發）。還包括一個用於丟棄排隊任務的 `null` 隊列驅動。

> **技巧**
> Laravel 提供了 Horizon ，適用於 Redis 驅動隊列。 Horizon 是一個擁有漂亮儀表盤的配置系統。如需了解更多信息請查看完整的 [Horizon 文檔](/docs/laravel/10.x/horizon)。

<a name="connections-vs-queues"></a>
### 連接 Vs. 驅動

在開始使用 Laravel 隊列之前，理解「連接」和「隊列」之間的區別非常重要。 在 `config/queue.php` 配置文件中，有一個 `connections` 連接選項。 此選項定義連接某個驅動（如 Amazon SQS、Beanstalk 或 Redis）。然而，任何給定的隊列連接都可能有多個「隊列」，這些「隊列」可能被認為是不同的堆棧或成堆的排隊任務。

請注意， `queue` 配置文件中的每個連接配置示例都包含一個 `queue` 屬性。

這是將任務發送到給定連接時將被分配到的默認隊列。換句話說，如果你沒有顯式地定義任務應該被發送到哪個隊列，那麽該任務將被放置在連接配置的 `queue` 屬性中定義的隊列上：

    use App\Jobs\ProcessPodcast;

    // 這個任務將被推送到默認隊列...

    ProcessPodcast::dispatch();

	// 這個任務將被推送到「emails」隊列...

    ProcessPodcast::dispatch()->onQueue('emails');

有些應用程序可能不需要將任務推到多個隊列中，而是傾向於使用一個簡單的隊列。然而，如果希望對任務的處理方式進行優先級排序或分段時，將任務推送到多個隊列就顯得特別有用，因為 Laravel 隊列工作程序允許你指定哪些隊列應該按優先級處理。例如，如果你將任務推送到一個 `high` 隊列，你可能會運行一個賦予它們更高處理優先級的 worker：

```shell
php artisan queue:work --queue=high,default
```

<a name="driver-prerequisites"></a>

### 驅動程序說明和先決條件

<a name="database"></a>

#### 數據庫

要使用 `database` 隊列驅動程序，你需要一個數據庫表來保存任務。要生成創建此表的遷移，請運行 `queue:table` Artisan 命令。一旦遷移已經創建，你可以使用 `migrate` 命令遷移你的數據庫：

```shell
php artisan queue:table

php artisan migrate
```

最後，請不要忘記通過修改`.env` 文件中的 `QUEUE_CONNECTION` 變量從而將 `database` 作為你的應用隊列驅動程序:

```shell
 QUEUE_CONNECTION=database
```

<a name="redis"></a>

#### Redis

要使用 `redis` 隊列驅動程序，需要在 `config/database.php` 配置文件中配置一個 redis 數據庫連接。

**Redis 集群**

如果你的 Redis 隊列當中使用了 Redis 集群，那麽你的隊列名稱就必須包含一個 [key hash tag](https://redis.io/topics/cluster-spec#keys-hash-tags)。這是為了確保一個給定隊列的所有 Redis 鍵都被放在同一個哈希插槽：

    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => '{default}',
        'retry_after' => 90,
    ],

**阻塞**

在使用 Redis 隊列時，你可以使用 block_for 配置選項來指定在遍歷 worker 循環和重新輪詢 Redis 數據庫之前，驅動程序需要等待多長時間才能使任務變得可用。

根據你的隊列負載調整此值要比連續輪詢 Redis 數據庫中的新任務更加有效。例如，你可以將值設置為 5 以指示驅動程序在等待任務變得可用時應該阻塞 5 秒：

    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => 'default',
        'retry_after' => 90,
        'block_for' => 5,
    ],

> **注意**
> 將 block_for 設置為 0 將導致隊列 workers 一直阻塞，直到某一個任務變得可用。這還能防止在下一個任務被處理之前處理諸如 SIGTERM 之類的信號。

<a name="other-driver-prerequisites"></a>

#### 其他驅動的先決條件

列出的隊列驅動需要如下的依賴，這些依賴可通過 Composer 包管理器進行安裝：

<div class="content-list" markdown="1">

- Amazon SQS: `aws/aws-sdk-php ~3.0`
- Beanstalkd: `pda/pheanstalk ~4.0`
- Redis: `predis/predis ~1.0` or phpredis PHP extension

</div>

<a name="creating-jobs"></a>
## 創建任務

<a name="generating-job-classes"></a>
### 生成任務類

默認情況下，應用程序的所有的可排隊任務都被存儲在了 app/Jobs 目錄中。如果 app/Jobs 目錄不存在，當你運行 make:job Artisan 命令時，將會自動創建該目錄：

```shell
php artisan make:job ProcessPodcast
```

生成的類將會實現 Illuminate\Contracts\Queue\ShouldQueue 接口， 告訴 Laravel ，該任務應該推入隊列以異步的方式運行。

> **技巧**
> 你可以使用 [stub publishing](/docs/laravel/10.x/artisanmd#stub-customization) 來自定義任務 stub 。

<a name="class-structure"></a>
### 任務類結構

任務類非常簡單，通常只包含一個 `handle` 方法，在隊列處理任務時將會調用它。讓我們看一個任務類的示例。在這個例子中，我們假設我們管理一個 podcast 服務，並且需要在上傳的 podcast 文件發布之前對其進行處理：

    <?php

    namespace App\Jobs;

    use App\Models\Podcast;
    use App\Services\AudioProcessor;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Foundation\Bus\Dispatchable;
    use Illuminate\Queue\InteractsWithQueue;
    use Illuminate\Queue\SerializesModels;

    class ProcessPodcast implements ShouldQueue
    {
        use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * 創建一個新的任務實例
         */
        public function __construct(
            public Podcast $podcast,
        ) {}

        /**
         * 運行任務
         */
        public function handle(AudioProcessor $processor): void
        {
            // 處理上傳的 podcast...
        }
    }

在本示例中，請注意，我們能夠將一個 [Eloquent model](/docs/laravel/10.x/eloquent)  直接傳遞到已排隊任務的構造函數中。由於任務所使用的 `SerializesModels` ，在任務處理時，Eloquent 模型及其加載的關系將被優雅地序列化和反序列化。

如果你的隊列任務在其構造函數中接受一個 Eloquent 模型，那麽只有模型的標識符才會被序列化到隊列中。當實際處理任務時，隊列系統將自動重新從數據庫中獲取完整的模型實例及其加載的關系。這種用於模型序列化的方式允許將更小的作業有效負載發送給你的隊列驅動程序。

<a name="handle-method-dependency-injection"></a>
#### `handle` 方法依賴注入

當任務由隊列處理時，將調用 `handle` 方法。注意，我們可以對任務的 `handle` 方法進行類型提示依賴。Laravel [服務容器](/docs/laravel/10.x/container) 會自動注入這些依賴項。

如果你想完全控制容器如何將依賴注入  `handle` 方法，你可以使用容器的 `bindMethod`  方法。 `bindMethod` 方法接受一個可接收任務和容器的回調。在回調中，你可以在任何你想用的地方隨意調用 `handle` 方法。 通常， 你應該從你的 `App\Providers\AppServiceProvider` [服務提供者](/docs/laravel/10.x/providers)  中來調用該方法:

    use App\Jobs\ProcessPodcast;
    use App\Services\AudioProcessor;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->bindMethod([ProcessPodcast::class, 'handle'], function (ProcessPodcast $job, Application $app) {
        return $job->handle($app->make(AudioProcessor::class));
    });

> **注意**
> 二進制數據，例如原始圖像內容，應該在傳遞到隊列任務之前通過 `base64_encode` 函數傳遞。否則，在將任務放入隊列時，可能無法正確地序列化為 JSON。

<a name="handling-relationships"></a>
#### 隊列關系

因為加載的關系也會被序列化，所以處理序列化任務的字符串有時會變得相當大。為了防止該關系被序列化，可以在設置屬性值時對模型調用 `withoutRelations` 方法。此方法將返回沒有加載關系的模型實例：

    /**
     * 創建新的任務實例
     */
    public function __construct(Podcast $podcast)
    {
        $this->podcast = $podcast->withoutRelations();
    }

此外，當反序列化任務並從數據庫中重新檢索模型關系時，它們將被完整檢索。反序列化任務時，將不會應用在任務排隊過程中序列化模型之前應用的任何先前關系約束。因此，如果你希望使用給定關系的子集，則應在排隊任務中重新限制該關系。

<a name="unique-jobs"></a>
### 唯一任務

> 注意：唯一任務需要支持 [locks](/docs/laravel/10.x/cachemd#atomic-locks) 的緩存驅動程序。 目前，`memcached`、`redis`、`dynamodb`、`database`、`file`和`array`緩存驅動支持原子鎖。 此外，獨特的任務約束不適用於批次內的任務。

有時，你可能希望確保在任何時間點隊列中只有一個特定任務的實例。你可以通過在你的工作類上實現 `ShouldBeUnique` 接口來做到這一點。這個接口不需要你在你的類上定義任何額外的方法：

    <?php

    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Contracts\Queue\ShouldBeUnique;

    class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
    {
        ...
    }

以上示例中，`UpdateSearchIndex` 任務是唯一的。因此，如果任務的另一個實例已經在隊列中並且尚未完成處理，則不會分派該任務。

在某些情況下，你可能想要定義一個使任務唯一的特定「鍵」，或者你可能想要指定一個超時時間，超過該時間任務不再保持唯一。為此，你可以在任務類上定義 `uniqueId` 和 `uniqueFor` 屬性或方法：

    <?php

    use App\Product;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Contracts\Queue\ShouldBeUnique;

    class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
    {
        /**
         * 產品實例
         *
         * @var \App\Product
         */
        public $product;

        /**
         * 任務的唯一鎖將被釋放的秒數
         *
         * @var int
         */
        public $uniqueFor = 3600;

        /**
         * 任務的唯一 ID
         */
        public function uniqueId(): string
        {
            return $this->product->id;
        }
    }

以上示例中， `UpdateSearchIndex` 任務中的 product ID 是唯一的。因此，在現有任務完成處理之前，任何具有相同 product ID 的任務都將被忽略。此外，如果現有任務在一小時內沒有得到處理，則釋放唯一鎖，並將具有相同唯一鍵的另一個任務分派到該隊列。

> **注意**
> 如果你的應用程序從多個 web 服務器或容器分派任務，你應該確保你的所有服務器都與同一個中央緩存服務器通信，以便Laravel能夠準確確定任務是否唯一。

<a name="keeping-jobs-unique-until-processing-begins"></a>
#### 在任務處理開始前保證唯一

默認情況下，在任務完成處理或所有重試嘗試均失敗後，唯一任務將被「解鎖」。但是，在某些情況下，你可能希望任務在處理之前立即解鎖。為此，你的任務類可以實現  `ShouldBeUniqueUntilProcessing`  接口，而不是實現 `ShouldBeUnique` 接口：

    <?php

    use App\Product;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Contracts\Queue\ShouldBeUniqueUntilProcessing;

    class UpdateSearchIndex implements ShouldQueue, ShouldBeUniqueUntilProcessing
    {
        // ...
    }

<a name="unique-job-locks"></a>
#### 唯一任務鎖

在底層實現中，當分發 `ShouldBeUnique` 任務時，Laravel 嘗試使用`uniqueId` 鍵獲取一個   [鎖](/docs/laravel/10.x/cachemd#atomic-locks) 。如果未獲取到鎖，則不會分派任務。當任務完成處理或所有重試嘗試失敗時，將釋放此鎖。默認情況下，Laravel 將使用默認的緩存驅動程序來獲取此鎖。但是，如果你希望使用其他驅動程序來獲取鎖，則可以定義一個 `uniqueVia` 方法，該方法返回一個緩存驅動對象：

    use Illuminate\Contracts\Cache\Repository;
    use Illuminate\Support\Facades\Cache;

    class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
    {
        ...

        /**
         * 獲取唯一任務鎖的緩存驅動程序
         */
        public function uniqueVia(): Repository
        {
            return Cache::driver('redis');
        }
    }

> 技巧：如果只需要限制任務的並發處理，請改用 [`WithoutOverlapping`](/docs/laravel/10.x/queuesmd#preventing-job-overlaps) 任務中間件。

<a name="job-middleware"></a>
## 任務中間件

任務中間件允許你圍繞排隊任務的執行封裝自定義邏輯，從而減少了任務本身的樣板代碼。例如，看下面的  `handle` 方法，它利用了 Laravel 的 Redis 速率限制特性，允許每 5 秒只處理一個任務：

    use Illuminate\Support\Facades\Redis;

    /**
     * 執行任務
     */
    public function handle(): void
    {
        Redis::throttle('key')->block(0)->allow(1)->every(5)->then(function () {
            info('取得了鎖...');

            // 處理任務...
        }, function () {
            // 無法獲取鎖...

            return $this->release(5);
        });
    }

雖然這段代碼是有效的， 但是 `handle` 方法的結構卻變得雜亂，因為它摻雜了 Redis 速率限制邏輯。此外，其他任務需要使用速率限制的時候，只能將限制邏輯覆制一次。

我們可以定義一個處理速率限制的任務中間件，而不是在 handle 方法中定義速率限制。Laravel 沒有任務中間件的默認位置，所以你可以將任務中間件放置在你喜歡的任何位置。在本例中，我們將把中間件放在  `app/Jobs/Middleware`  目錄：

    <?php

    namespace App\Jobs\Middleware;

    use Closure;
    use Illuminate\Support\Facades\Redis;

    class RateLimited
    {
        /**
         * 處理隊列任務
         *
         * @param  \Closure(object): void  $next
         */
        public function handle(object $job, Closure $next): void
        {
            Redis::throttle('key')
                    ->block(0)->allow(1)->every(5)
                    ->then(function () use (object $job, Closure $next) {
                        // 已獲得鎖...

                        $next($job);
                    }, function () use ($job) {
                        // 沒有獲取到鎖...

                        $job->release(5);
                    });
        }
    }

正如你看到的，類似於 [路由中間件](/docs/laravel/10.x/middleware)，任務中間件接收正在處理隊列任務以及一個回調來繼續處理隊列任務。

在任務中間件被創建以後，他們可能被關聯到通過從任務的 `middleware`方法返回的任務。這個方法並不存在於 `make:job`  Artisan 命令搭建的任務中，所以你需要將它添加到你自己的任務類的定義中：

    use App\Jobs\Middleware\RateLimited;

    /**
     * 獲取一個可以被傳遞通過的中間件任務
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [new RateLimited];
    }

> **技巧**
> 任務中間件也可以分配其他可隊列處理的監聽事件當中，比如郵件，通知等。

<a name="rate-limiting"></a>
### 訪問限制

盡管我們剛剛演示了如何編寫自己的訪問限制的任務中間件，但 Laravel 實際上內置了一個訪問限制中間件，你可以利用它來限制任務。與 [路由限流器](/docs/laravel/10.x/routingmd/14845#defining-rate-limiters) 一樣，任務訪問限制器是使用 `RateLimiter` facade 的 `for` 方法定義的。

例如，你可能希望允許用戶每小時備份一次數據，但不對高級客戶施加此類限制。為此，可以在 `RateLimiter` 的 `boot` 方法中定義 `AppServiceProvider`：

    use Illuminate\Cache\RateLimiting\Limit;
    use Illuminate\Support\Facades\RateLimiter;

    /**
     * 注冊應用程序服務
     */
    public function boot(): void
    {
        RateLimiter::for('backups', function (object $job) {
            return $job->user->vipCustomer()
                        ? Limit::none()
                        : Limit::perHour(1)->by($job->user->id);
        });
    }

在上面的例子中，我們定義了一個小時訪問限制；但是，你可以使用 `perMinute` 方法輕松定義基於分鐘的訪問限制。此外，你可以將任何值傳遞給訪問限制的 `by` 方法，但是，這個值通常用於按客戶來區分不同的訪問限制：

    return Limit::perMinute(50)->by($job->user->id);

定義速率限制後，你可以使用 `Illuminate\Queue\Middleware\RateLimited` 中間件將速率限制器附加到備份任務。 每次任務超過速率限制時，此中間件都會根據速率限制持續時間以適當的延遲將任務釋放回隊列。

    use Illuminate\Queue\Middleware\RateLimited;

    /**
     * 獲取任務時，應該通過的中間件
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [new RateLimited('backups')];
    }

將速率受限的任務釋放回隊列仍然會增加任務的 「嘗試」總數。你可能希望相應地調整你的任務類上的 `tries` 和 `maxExceptions` 屬性。或者，你可能希望使用 `retryUntil` [方法](#time-based-attempts) 來定義不再嘗試任務之前的時間量。

如果你不想在速率限制時重試任務，你可以使用 `dontRelease` 方法：

    /**
     * 獲取任務時，應該通過的中間件
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [(new RateLimited('backups'))->dontRelease()];
    }

> **技巧**
> 如果你使用 Redis，你可以使用 Illuminate\Queue\Middleware\RateLimitedWithRedis 中間件，它針對 Redis 進行了微調，比基本的限速中間件更高效。

<a name="preventing-job-overlaps"></a>
### 防止任務重疊

Laravel 包含一個 `Illuminate\Queue\Middleware\WithoutOverlapping` 中間件，允許你根據任意鍵防止任務重疊。當排隊的任務正在修改一次只能由一個任務修改的資源時，這會很有幫助。

例如，假設你有一個更新用戶信用評分的排隊任務，並且你希望防止同一用戶 ID 的信用評分更新任務重疊。為此，你可以從任務的 `middleware` 方法返回 `WithoutOverlapping` 中間件：

    use Illuminate\Queue\Middleware\WithoutOverlapping;

    /**
     * 獲取任務時，應該通過的中間件
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [new WithoutOverlapping($this->user->id)];
    }

任何重疊的任務都將被釋放回隊列。你還可以指定再次嘗試釋放的任務之前必須經過的秒數：

    /**
     * 獲取任務時，應該通過的中間件
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [(new WithoutOverlapping($this->order->id))->releaseAfter(60)];
    }

如果你想立即刪除任何重疊的任務，你可以使用 `dontRelease` 方法，這樣它們就不會被重試：

    /**
     * 獲取任務時，應該通過的中間件。
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [(new WithoutOverlapping($this->order->id))->dontRelease()];
    }

`WithoutOverlapping` 中間件由 Laravel 的原子鎖特性提供支持。有時，你的任務可能會以未釋放鎖的方式意外失敗或超時。因此，你可以使用 expireAfter 方法顯式定義鎖定過期時間。例如，下面的示例將指示 Laravel 在任務開始處理三分鐘後釋放 WithoutOverlapping 鎖：

    /**
     * 獲取任務時，應該通過的中間件。
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [(new WithoutOverlapping($this->order->id))->expireAfter(180)];
    }

> **注意**
> `WithoutOverlapping` 中間件需要支持 [locks](/docs/laravel/10.x/cachemd#atomic-locks) 的緩存驅動程序。目前，`memcached`、`redis`、`dynamodb`、`database`、`file` 和 `array` 緩存驅動支持原子鎖。

<a name="sharing-lock-keys"></a>
#### 跨任務類別共享鎖

默認情況下，`WithoutOverlapping` 中間件只會阻止同一類的重疊任務。 因此，盡管兩個不同的任務類可能使用相同的鎖，但不會阻止它們重疊。 但是，你可以使用 `shared` 方法指示 Laravel 跨任務類應用鎖：

```php
use Illuminate\Queue\Middleware\WithoutOverlapping;

class ProviderIsDown
{
    // ...


    public function middleware(): array
    {
        return [
            (new WithoutOverlapping("status:{$this->provider}"))->shared(),
        ];
    }
}

class ProviderIsUp
{
    // ...


    public function middleware(): array
    {
        return [
            (new WithoutOverlapping("status:{$this->provider}"))->shared(),
        ];
    }
}
```

<a name="throttling-exceptions"></a>
### 節流限制異常

Laravel 包含一個 `Illuminate\Queue\Middleware\ThrottlesExceptions` 中間件，允許你限制異常。一旦任務拋出給定數量的異常，所有進一步執行該任務的嘗試都會延遲，直到經過指定的時間間隔。該中間件對於與不穩定的第三方服務交互的任務特別有用。

例如，讓我們想象一個隊列任務與開始拋出異常的第三方 API 交互。要限制異常，你可以從任務的 `middleware` 方法返回 `ThrottlesExceptions` 中間件。通常，此中間件應與實現 [基於時間的嘗試](#time-based-attempts) 的任務配對：

    use DateTime;
    use Illuminate\Queue\Middleware\ThrottlesExceptions;

    /**
     * 獲取任務時，應該通過的中間件。
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [new ThrottlesExceptions(10, 5)];
    }

    /**
     * 確定任務應該超時的時間。
     */
    public function retryUntil(): DateTime
    {
        return now()->addMinutes(5);
    }

中間件接受的第一個構造函數參數是任務在被限制之前可以拋出的異常數，而第二個構造函數參數是在任務被限制後再次嘗試之前應該經過的分鐘數。在上面的代碼示例中，如果任務在 5 分鐘內拋出 10 個異常，我們將等待 5 分鐘，然後再次嘗試該任務。

當任務拋出異常但尚未達到異常閾值時，通常會立即重試該任務。但是，你可以通過在將中間件附加到任務時調用 `backoff` 方法來指定此類任務應延遲的分鐘數：

    use Illuminate\Queue\Middleware\ThrottlesExceptions;

    /**
     * 獲取任務時，應該通過的中間件。
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [(new ThrottlesExceptions(10, 5))->backoff(5)];
    }

在內部，這個中間件使用 Laravel 的緩存系統來實現速率限制，並利用任務的類名作為緩存 「鍵」。 在將中間件附加到任務時，你可以通過調用 `by` 方法來覆蓋此鍵。 如果你有多個任務與同一個第三方服務交互並且你希望它們共享一個共同的節流 「桶」，這可能會很有用：

    use Illuminate\Queue\Middleware\ThrottlesExceptions;

    /**
     * 獲取任務時，應該通過的中間件。
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [(new ThrottlesExceptions(10, 10))->by('key')];
    }

> **技巧**
> 如果你使用 Redis，你可以使用 `Illuminate\Queue\Middleware\ThrottlesExceptionsWithRedis` 中間件，它針對 Redis 進行了微調，比基本的異常節流中間件更高效。

<a name="dispatching-jobs"></a>
## 調度任務

一旦你寫好了你的任務類，你可以使用任務本身的 `dispatch` 方法來調度它。傳遞給 `dispatch` 方法的參數將被提供給任務的構造函數：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * 存儲一個新的播客。
         */
        public function store(Request $request): RedirectResponse
        {
            $podcast = Podcast::create(/* ... */);

            // ...

            ProcessPodcast::dispatch($podcast);

            return redirect('/podcasts');
        }
    }

如果你想有條件地分派任務，你可以使用 `dispatchIf` 和 `dispatchUnless` 方法：

    ProcessPodcast::dispatchIf($accountActive, $podcast);

    ProcessPodcast::dispatchUnless($accountSuspended, $podcast);

在新的 Laravel 應用程序中，`sync` 是默認的隊列驅動程序。 該驅動程序會在當前請求的前台同步執行任務，這在本地開發時通常會很方便。 如果你想在後台處理排隊任務，你可以在應用程序的 `config/queue.php` 配置文件中指定一個不同的隊列驅動程序。


<a name="delayed-dispatching"></a>
### 延遲調度

如果你想指定任務不應立即可供隊列工作人員處理，你可以在調度任務時使用 `delay` 方法。例如，讓我們指定一個任務在分派後 10 分鐘內不能用於處理

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * 儲存一個新的播客
         */
        public function store(Request $request): RedirectResponse
        {
            $podcast = Podcast::create(/* ... */);

            // ...

            ProcessPodcast::dispatch($podcast)
                        ->delay(now()->addMinutes(10));

            return redirect('/podcasts');
        }
    }

> **注意**
> Amazon SQS 隊列服務的最大延遲時間為 15 分鐘。

<a name="dispatching-after-the-response-is-sent-to-browser"></a>
#### 響應發送到瀏覽器後調度

或者，`dispatchAfterResponse` 方法延遲調度任務，直到 HTTP 響應發送到用戶的瀏覽器之後。 即使排隊的任務仍在執行，這仍將允許用戶開始使用應用程序。這通常應該只用於需要大約一秒鐘的工作，例如發送電子郵件。由於它們是在當前 HTTP 請求中處理的，因此以這種方式分派的任務不需要運行隊列工作者來處理它們：

    use App\Jobs\SendNotification;

    SendNotification::dispatchAfterResponse();

你也可以 `dispatch` 一個閉包並將 `afterResponse` 方法鏈接到 `dispatch` 幫助器以在 HTTP 響應發送到瀏覽器後執行一個閉包

    use App\Mail\WelcomeMessage;
    use Illuminate\Support\Facades\Mail;

    dispatch(function () {
        Mail::to('taylor@example.com')->send(new WelcomeMessage);
    })->afterResponse();

<a name="synchronous-dispatching"></a>
### 同步調度

如果你想立即（同步）調度任務，你可以使用 `dispatchSync` 方法。使用此方法時，任務不會排隊，會在當前進程內立即執行：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * 儲存一個新的播客。
         */
        public function store(Request $request): RedirectResponse
        {
            $podcast = Podcast::create(/* ... */);

            // 創建播客

            ProcessPodcast::dispatchSync($podcast);

            return redirect('/podcasts');
        }
    }

<a name="jobs-and-database-transactions"></a>
### 任務 & 數據庫事務

雖然在數據庫事務中分派任務非常好，但你應該特別注意確保你的任務實際上能夠成功執行。在事務中調度任務時，任務可能會在父事務提交之前由工作人員處理。發生這種情況時，你在數據庫事務期間對模型或數據庫記錄所做的任何更新可能尚未反映在數據庫中。此外，在事務中創建的任何模型或數據庫記錄可能不存在於數據庫中。

值得慶幸的是，Laravel 提供了幾種解決這個問題的方法。首先，你可以在隊列連接的配置數組中設置 `after_commit` 連接選項：

    'redis' => [
        'driver' => 'redis',
        // ...
        'after_commit' => true,
    ],

當 `after_commit` 選項為 true 時，你可以在數據庫事務中分發任務；Laravel 會等到所有打開的數據庫事務都已提交，然後才會開始分發任務。當然，如果當前沒有打開的數據庫事務，任務將被立即調度。

如果事務因事務期間發生異常而回滾，則在該事務期間分發的已分發任務將被丟棄。

> **技巧**
> 將 `after_commit` 配置選項設置為 `true` 還會導致所有排隊的事件監聽器、郵件、通知和廣播事件在所有打開的數據庫事務提交後才被調度。

<a name="specifying-commit-dispatch-behavior-inline"></a>
#### 內聯指定提交調度

如果你沒有將 `after_commit` 隊列連接配置選項設置為 `true`，你可能需要在所有打開的數據庫事務提交後才調度特定的任務。為此，你可以將 `afterCommit` 方法放到你的調度操作上：

    use App\Jobs\ProcessPodcast;

    ProcessPodcast::dispatch($podcast)->afterCommit();

同樣，如果 `after_commit` 配置選項設置為 `true`，則可以指示應立即調度特定作業，而無需等待任何打開的數據庫事務提交：

    ProcessPodcast::dispatch($podcast)->beforeCommit();

<a name="job-chaining"></a>
### 任務鏈

任務鏈允許你指定一組應在主任務成功執行後按順序運行的排隊任務。如果序列中的一個任務失敗，其余的任務將不會運行。要執行一個排隊的任務鏈，你可以使用 `Bus` facade 提供的 `chain` 方法：

    use App\Jobs\OptimizePodcast;
    use App\Jobs\ProcessPodcast;
    use App\Jobs\ReleasePodcast;
    use Illuminate\Support\Facades\Bus;

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        new ReleasePodcast,
    ])->dispatch();

除了鏈接任務類實例之外，你還可以鏈接閉包：

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        function () {
            Podcast::update(/* ... */);
        },
    ])->dispatch();

> **注意**
> 在任務中使用 `$this->delete()` 方法刪除任務不會阻止鏈式任務的處理。只有當鏈中的任務失敗時，鏈才會停止執行。

<a name="chain-connection-queue"></a>
#### 鏈式連接 & 隊列

如果要指定鏈接任務應使用的連接和隊列，可以使用 `onConnection` 和 `onQueue` 方法。這些方法指定應使用的隊列連接和隊列名稱，除非為排隊任務顯式分配了不同的連接 / 隊列：

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        new ReleasePodcast,
    ])->onConnection('redis')->onQueue('podcasts')->dispatch();

<a name="chain-failures"></a>
#### 鏈故障

鏈接任務時，你可以使用 `catch` 方法指定一個閉包，如果鏈中的任務失敗，則應調用該閉包。給定的回調將接收導致任務失敗的 `Throwable` 實例：

    use Illuminate\Support\Facades\Bus;
    use Throwable;

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        new ReleasePodcast,
    ])->catch(function (Throwable $e) {
        // 鏈中的任務失敗了...
    })->dispatch();

> **注意**
> 由於鏈式回調由 Laravel 隊列稍後序列化並執行，因此你不應在鏈式回調中使用 `$this` 變量。

<a name="customizing-the-queue-and-connection"></a>
### 自定義隊列 & 連接

<a name="dispatching-to-a-particular-queue"></a>
#### 分派到特定隊列

通過將任務推送到不同的隊列，你可以對排隊的任務進行「分類」，甚至可以優先考慮分配給各個隊列的工作人員數量。請記住，這不會將任務推送到隊列配置文件定義的不同隊列「連接」，而只會推送到單個連接中的特定隊列。要指定隊列，請在調度任務時使用 `onQueue` 方法：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * 存儲一個播客。
         */
        public function store(Request $request): RedirectResponse
        {
            $podcast = Podcast::create(/* ... */);

            // 創建播客...

            ProcessPodcast::dispatch($podcast)->onQueue('processing');

            return redirect('/podcasts');
        }
    }

或者，你可以通過在任務的構造函數中調用 `onQueue` 方法來指定任務的隊列：

    <?php

    namespace App\Jobs;

     use Illuminate\Bus\Queueable;
     use Illuminate\Contracts\Queue\ShouldQueue;
     use Illuminate\Foundation\Bus\Dispatchable;
     use Illuminate\Queue\InteractsWithQueue;
     use Illuminate\Queue\SerializesModels;

    class ProcessPodcast implements ShouldQueue
    {
        use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * 創建一個新的任務實例
         */
        public function __construct()
        {
            $this->onQueue('processing');
        }
    }

<a name="dispatching-to-a-particular-connection"></a>
#### 調度到特定連接

如果你的應用程序與多個隊列連接交互，你可以使用 `onConnection` 方法指定將任務推送到哪個連接：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * 儲存新的播客
         */
        public function store(Request $request): RedirectResponse
        {
            $podcast = Podcast::create(/* ... */);

            // 創建播客...

            ProcessPodcast::dispatch($podcast)->onConnection('sqs');

            return redirect('/podcasts');
        }
    }

你可以將 `onConnection` 和 `onQueue` 方法鏈接在一起，以指定任務的連接和隊列：

    ProcessPodcast::dispatch($podcast)
                  ->onConnection('sqs')
                  ->onQueue('processing');

或者，你可以通過在任務的構造函數中調用 `onConnection` 方法來指定任務的連接

    <?php

    namespace App\Jobs;

     use Illuminate\Bus\Queueable;
     use Illuminate\Contracts\Queue\ShouldQueue;
     use Illuminate\Foundation\Bus\Dispatchable;
     use Illuminate\Queue\InteractsWithQueue;
     use Illuminate\Queue\SerializesModels;

    class ProcessPodcast implements ShouldQueue
    {
        use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * 創建一個新的任務實例。
         */
        public function __construct()
        {
            $this->onConnection('sqs');
        }
    }

<a name="max-job-attempts-and-timeout"></a>
### 指定最大任務嘗試 / 超時值

<a name="max-attempts"></a>
#### 最大嘗試次數

如果你的一個隊列任務遇到了錯誤，你可能不希望無限制的重試。因此 Laravel 提供了各種方法來指定一個任務可以嘗試多少次或多長時間。

指定任務可嘗試的最大次數的其中一個方法是，通過 Artisan 命令行上的 `--tries` 開關。這將適用於調度作業的所有任務，除非正在處理的任務指定了最大嘗試次數。

```shell
php artisan queue:work --tries=3
```

如果一個任務超過其最大嘗試次數，將被視為「失敗」的任務。有關處理失敗任務的更多信息，可以參考 [處理失敗隊列](/docs/laravel/10.x/queuesmd/14873#dealing-with-failed-jobs)。如果將 `--tries=0` 提供給 `queue:work` 命令，任務將無限期地重試。

你可以采取更細化的方法來定義任務類本身的最大嘗試次數。如果在任務上指定了最大嘗試次數，它將優先於命令行上提供的 `--tries` 開關設定的值：

    <?php

    namespace App\Jobs;

    class ProcessPodcast implements ShouldQueue
    {
        /**
         * 任務可嘗試的次數。
         *
         * @var int
         */
        public $tries = 5;
    }

<a name="time-based-attempts"></a>
#### 基於時間的嘗試

除了定義任務失敗前嘗試的次數之外，還可以定義任務應該超時的時間。這允許在給定的時間範圍內嘗試任意次數的任務。要定義任務超時的時間，請在任務類中添加 `retryUntil` 方法。這個方法應返回一個 `DateTime` 實例：

    use DateTime;

    /**
     * 確定任務應該超時的時間。
     */
    public function retryUntil(): DateTime
    {
        return now()->addMinutes(10);
    }

> **技巧**
> 你也可以在 [隊列事件監聽器](/docs/laravel/10.x/eventsmd#queued-event-listeners) 上定義一個 `tries` 屬性或 `retryUntil` 方法。

<a name="max-exceptions"></a>
#### 最大嘗試

有時你可能希望指定一個任務可能會嘗試多次，但如果重試由給定數量的未處理異常觸發（而不是直接由 `release` 方法釋放），則應該失敗。為此，你可以在任務類上定義一個 `maxExceptions` 屬性：

    <?php

    namespace App\Jobs;

    use Illuminate\Support\Facades\Redis;

    class ProcessPodcast implements ShouldQueue
    {
        /**
         * 可以嘗試任務的次數
         *
         * @var int
         */
        public $tries = 25;

        /**
         * 失敗前允許的最大未處理異常數
         *
         * @var int
         */
        public $maxExceptions = 3;

        /**
         * 執行
         */
        public function handle(): void
        {
            Redis::throttle('key')->allow(10)->every(60)->then(function () {
                // 獲得鎖，處理播客...
            }, function () {
                // 無法獲取鎖...
                return $this->release(10);
            });
        }
    }

在此示例中，如果應用程序無法獲得 Redis 鎖，則該任務將在 10 秒後被釋放，並將繼續重試最多 25 次。但是，如果任務拋出三個未處理的異常，則任務將失敗。

<a name="timeout"></a>
#### 超時

> **注意**
> 必須安裝 `pcntl` PHP 擴展以指定任務超時。

通常，你大致知道你預計排隊的任務需要多長時間。出於這個原因，Laravel 允許你指定一個「超時」值。 如果任務的處理時間超過超時值指定的秒數，則處理該任務的任務進程將退出並出現錯誤。 通常，任務程序將由在你的[服務器上配置的進程管理器](#supervisor-configuration)自動重新啟動。

同樣，任務可以運行的最大秒數可以使用 Artisan 命令行上的 `--timeout` 開關來指定：

```shell
php artisan queue:work --timeout=30
```

如果任務因不斷超時而超過其最大嘗試次數，則它將被標記為失敗。

你也可以定義允許任務在任務類本身上運行的最大秒數。如果在任務上指定了超時，它將優先於在命令行上指定的任何超時:

    <?php

    namespace App\Jobs;

    class ProcessPodcast implements ShouldQueue
    {
        /**
         * 在超時之前任務可以運行的秒數.
         *
         * @var int
         */
        public $timeout = 120;
    }

有些時候，諸如 socket 或在 HTTP 連接之類的 IO 阻止進程可能不會遵守你指定的超時。因此，在使用這些功能時，也應始終嘗試使用其 API 指定超時。例如，在使用 Guzzle 時，應始終指定連接並請求的超時時間。

<a name="failing-on-timeout"></a>
#### 超時失敗

如果你希望在超時時將任務標記為 [failed](#dealing-with-failed-jobs)，可以在任務類上定義 `$failOnTimeout` 屬性：

```php
/**
 * 標示是否應在超時時標記為失敗.
 *
 * @var bool
 */
public $failOnTimeout = true;
```

<a name="error-handling"></a>
### 錯誤處理

如果在處理任務時拋出異常，任務將自動釋放回隊列，以便再次嘗試。 任務將繼續發布，直到嘗試達到你的應用程序允許的最大次數為止。最大嘗試次數由 `queue:work` Artisan 命令中使用的 `--tries` 開關定義。或者，可以在任務類本身上定義最大嘗試次數。有關運行隊列處理器的更多信息 [可以在下面找到](#running-the-queue-worker)。

<a name="manually-releasing-a-job"></a>
#### 手動發布

有時你可能希望手動將任務發布回隊列，以便稍後再次嘗試。你可以通過調用 `release` 方法來完成此操作：

    /**
     * 執行任務。
     */
    public function handle(): void
    {
        // ...

        $this->release();
    }

默認情況下，`release` 方法會將任務發布回隊列以供立即處理。但是，通過向 `release` 方法傳遞一個整數，你可以指示隊列在給定的秒數過去之前不使任務可用於處理：

    $this->release(10);

<a name="manually-failing-a-job"></a>
#### 手動使任務失敗

有時，你可能需要手動將任務標記為 「failed」。為此，你可以調用 `fail` 方法：

    /**
     * 執行任務。
     */
    public function handle(): void
    {
        // ...

        $this->fail();
    }

如果你捕獲了一個異常，你想直接將你的任務標記為失敗，你可以將異常傳遞給 `fail` 方法。 或者，為方便起見，你可以傳遞一個字符串來表示錯誤異常信息：

    $this->fail($exception);

    $this->fail('Something went wrong.');

> **技巧**
> 有關失敗任務的更多信息，請查看 [處理任務失敗的文檔](#dealing-with-failed-jobs).

<a name="job-batching"></a>
## 任務批處理

Laravel 的任務批處理功能允許你輕松地執行一批任務，然後在這批任務執行完畢後執行一些操作。 在開始之前，你應該創建一個數據庫遷移以構建一個表來包含有關你的任務批次的元信息，例如它們的完成百分比。 可以使用 `queue:batches-table` Artisan 命令來生成此遷移：

```shell
php artisan queue:batches-table

php artisan migrate
```

<a name="defining-batchable-jobs"></a>
### 定義可批處理任務

要定義可批處理的任務，你應該像往常一樣[創建可排隊的任務](#creating-jobs)； 但是，你應該將 `Illuminate\Bus\Batchable` 特性添加到任務類中。 此 `trait` 提供對 `batch` 方法的訪問，該方法可用於檢索任務正在執行的當前批次：

    <?php

    namespace App\Jobs;

    use Illuminate\Bus\Batchable;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Foundation\Bus\Dispatchable;
    use Illuminate\Queue\InteractsWithQueue;
    use Illuminate\Queue\SerializesModels;

    class ImportCsv implements ShouldQueue
    {
        use Batchable, Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * 執行任務。
         */
        public function handle(): void
        {
            if ($this->batch()->cancelled()) {
                // 確定批次是否已被取消...

                return;
            }

            // 導入 CSV 文件的一部分...
        }
    }

<a name="dispatching-batches"></a>
### 調度批次

要調度一批任務，你應該使用 `Bus` 門面的 `batch` 方法。 當然，批處理主要在與完成回調結合使用時有用。 因此，你可以使用 `then`、`catch` 和 `finally` 方法來定義批處理的完成回調。 這些回調中的每一個在被調用時都會收到一個 `Illuminate\Bus\Batch` 實例。 在這個例子中，我們假設我們正在排隊一批任務，每個任務處理 CSV 文件中給定數量的行：

    use App\Jobs\ImportCsv;
    use Illuminate\Bus\Batch;
    use Illuminate\Support\Facades\Bus;
    use Throwable;

    $batch = Bus::batch([
        new ImportCsv(1, 100),
        new ImportCsv(101, 200),
        new ImportCsv(201, 300),
        new ImportCsv(301, 400),
        new ImportCsv(401, 500),
    ])->then(function (Batch $batch) {
        // 所有任務均已成功完成...
    })->catch(function (Batch $batch, Throwable $e) {
        // 檢測到第一批任務失敗...
    })->finally(function (Batch $batch) {
        // 批處理已完成執行...
    })->dispatch();

    return $batch->id;

批次的 ID 可以通過 `$batch->id` 屬性訪問，可用於 [查詢 Laravel 命令總線](#inspecting-batches) 以獲取有關批次分派後的信息。

> **注意**
> 由於批處理回調是由 Laravel 隊列序列化並在稍後執行的，因此你不應在回調中使用 `$this` 變量。

<a name="naming-batches"></a>
#### 命名批次

Laravel Horizon 和 Laravel Telescope 等工具如果命名了批次，可能會為批次提供更用戶友好的調試信息。要為批處理分配任意名稱，你可以在定義批處理時調用 `name` 方法：

    $batch = Bus::batch([
        // ...
    ])->then(function (Batch $batch) {
        // 所有任務均已成功完成...
    })->name('Import CSV')->dispatch();

<a name="batch-connection-queue"></a>
#### 批處理連接 & 隊列

如果你想指定應用於批處理任務的連接和隊列，你可以使用 `onConnection` 和 `onQueue` 方法。 所有批處理任務必須在相同的連接和隊列中執行：

    $batch = Bus::batch([
        // ...
    ])->then(function (Batch $batch) {
        // 所有任務均已成功完成...
    })->onConnection('redis')->onQueue('imports')->dispatch();

<a name="chains-within-batches"></a>
#### 批量內鏈

你可以通過將鏈接的任務放在數組中來在批處理中定義一組 [鏈接的任務](#job-chaining)。 例如，我們可以並行執行兩個任務鏈，並在兩個任務鏈都完成處理後執行回調：

    use App\Jobs\ReleasePodcast;
    use App\Jobs\SendPodcastReleaseNotification;
    use Illuminate\Bus\Batch;
    use Illuminate\Support\Facades\Bus;

    Bus::batch([
        [
            new ReleasePodcast(1),
            new SendPodcastReleaseNotification(1),
        ],
        [
            new ReleasePodcast(2),
            new SendPodcastReleaseNotification(2),
        ],
    ])->then(function (Batch $batch) {
        // ...
    })->dispatch();

<a name="adding-jobs-to-batches"></a>
### 批量添加任務

有些時候，批量向批處理中添加任務可能很有用。當你需要批量處理數千個任務時，這種模式非常好用，而這些任務在 Web 請求期間可能需要很長時間才能調度。因此，你可能希望調度初始批次的「加載器」任務，這些任務與更多任務相結合：

    $batch = Bus::batch([
        new LoadImportBatch,
        new LoadImportBatch,
        new LoadImportBatch,
    ])->then(function (Batch $batch) {
        // 所有任務都成功完成...
    })->name('Import Contacts')->dispatch();

在這個例子中，我們將使用 `LoadImportBatch` 實例為批處理添加其他任務。為了實現這個功能，我們可以對批處理實例使用 `add` 方法，該方法可以通過 `batch` 實例訪問：

    use App\Jobs\ImportContacts;
    use Illuminate\Support\Collection;

    /**
     * 執行任務。
     */
    public function handle(): void
    {
        if ($this->batch()->cancelled()) {
            return;
        }

        $this->batch()->add(Collection::times(1000, function () {
            return new ImportContacts;
        }));
    }

> **注意**
> 你只能將任務添加到當前任務所屬的批處理中。

<a name="inspecting-batches"></a>
### 校驗批處理

為批處理完成後提供回調的 `Illuminate\Bus\Batch` 實例中具有多種屬性和方法，可以幫助你與指定的批處理業務進行交互和檢查：

    // 批處理的UUID...
    $batch->id;

    // 批處理的名稱（如果已經設置的話）...
    $batch->name;

    // 分配給批處理的任務數量...
    $batch->totalJobs;

    // 隊列還沒處理的任務數量...
    $batch->pendingJobs;

    // 失敗的任務數量...
    $batch->failedJobs;

    // 到目前為止已經處理的任務數量...
    $batch->processedJobs();

    // 批處理已經完成的百分比（0-100）...
    $batch->progress();

    // 批處理是否已經完成執行...
    $batch->finished();

    // 取消批處理的運行...
    $batch->cancel();

    // 批處理是否已經取消...
    $batch->cancelled();

<a name="returning-batches-from-routes"></a>
#### 從路由返回批次

所有 `Illuminate\Bus\Batch` 實例都是 JSON 可序列化的，這意味著你可以直接從應用程序的一個路由返回它們，以檢索包含有關批處理的信息的 JSON 有效負載，包括其完成進度。這樣可以方便地在應用程序的 UI 中顯示有關批處理完成進度的信息。

要通過 ID 檢索批次，你可以使用 `Bus` 外觀的 `findBatch` 方法：

    use Illuminate\Support\Facades\Bus;
    use Illuminate\Support\Facades\Route;

    Route::get('/batch/{batchId}', function (string $batchId) {
        return Bus::findBatch($batchId);
    });

<a name="cancelling-batches"></a>
### 取消批次

有時你可能需要取消給定批處理的執行。這可以通過調用 `Illuminate\Bus\Batch` 實例的 `cancel` 方法來完成：

    /**
     * 執行任務。
     */
    public function handle(): void
    {
        if ($this->user->exceedsImportLimit()) {
            return $this->batch()->cancel();
        }

        if ($this->batch()->cancelled()) {
            return;
        }
    }

正如你在前面的示例中可能已經注意到的那樣，批處理任務通常應在繼續執行之前確定其相應的批處理是否已被取消。 但是，為了方便起見，你可以將 `SkipIfBatchCancelled` [中間件](#job-middleware) 分配給作業。 顧名思義，如果相應的批次已被取消，此中間件將指示 Laravel 不處理該作業：

    use Illuminate\Queue\Middleware\SkipIfBatchCancelled;

    /**
     * 獲取任務應通過的中間件。
     */
    public function middleware(): array
    {
        return [new SkipIfBatchCancelled];
    }

<a name="batch-failures"></a>
### 批處理失敗

當批處理任務失敗時，將調用 `catch` 回調（如果已分配）。此回調僅針對批處理中失敗的第一個任務調用。

<a name="allowing-failures"></a>
#### 允許失敗

當批處理中的某個任務失敗時，Laravel 會自動將該批處理標記為「已取消」。如果你願意，你可以禁用此行為，以便任務失敗不會自動將批處理標記為已取消。這可以通過在調度批處理時調用 `allowFailures` 方法來完成：

    $batch = Bus::batch([
        // ...
    ])->then(function (Batch $batch) {
        // 所有任務均已成功完成...
    })->allowFailures()->dispatch();

<a name="retrying-failed-batch-jobs"></a>
#### 重試失敗的批處理任務

為方便起見，Laravel 提供了一個 `queue:retry-batch` Artisan 命令，允許你輕松重試給定批次的所有失敗任務。 `queue:retry-batch` 命令接受應該重試失敗任務的批處理的 UUID：

```shell
php artisan queue:retry-batch 32dbc76c-4f82-4749-b610-a639fe0099b5
```

<a name="pruning-batches"></a>
### 修剪批次

如果不進行修剪，`job_batches` 表可以非常快速地積累記錄。為了緩解這種情況，你應該 [schedule](/docs/laravel/10.x/scheduling) `queue:prune-batches` Artisan 命令每天運行：

    $schedule->command('queue:prune-batches')->daily();

默認情況下，將修剪所有超過 24 小時的已完成批次。你可以在調用命令時使用 `hours` 選項來確定保留批處理數據的時間。例如，以下命令將刪除 48 小時前完成的所有批次：

    $schedule->command('queue:prune-batches --hours=48')->daily();

有時，你的 `jobs_batches` 表可能會累積從未成功完成的批次的批次記錄，例如任務失敗且該任務從未成功重試的批次。 你可以使用 `unfinished` 選項指示 `queue:prune-batches` 命令修剪這些未完成的批處理記錄：

    $schedule->command('queue:prune-batches --hours=48 --unfinished=72')->daily();

同樣，你的 `jobs_batches` 表也可能會累積已取消批次的批次記錄。 你可以使用 `cancelled` 選項指示 `queue:prune-batches` 命令修剪這些已取消的批記錄：

    $schedule->command('queue:prune-batches --hours=48 --cancelled=72')->daily();

<a name="queueing-closures"></a>
## 隊列閉包

除了將任務類分派到隊列之外，你還可以分派一個閉包。這對於需要在當前請求周期之外執行的快速、簡單的任務非常有用。當向隊列分派閉包時，閉包的代碼內容是加密簽名的，因此它不能在傳輸過程中被修改：

    $podcast = App\Podcast::find(1);

    dispatch(function () use ($podcast) {
        $podcast->publish();
    });

使用 `catch` 方法，你可以提供一個閉包，如果排隊的閉包在耗盡所有隊列的[配置的重試次數](#max-job-attempts-and-timeout) 後未能成功完成，則應執行該閉包：

    use Throwable;

    dispatch(function () use ($podcast) {
        $podcast->publish();
    })->catch(function (Throwable $e) {
        // 這個任務失敗了...
    });

> **注意**
> 由於 `catch` 回調由 Laravel 隊列稍後序列化並執行，因此你不應在 `catch` 回調中使用 `$this` 變量。

<a name="running-the-queue-worker"></a>
## 運行隊列工作者

<a name="the-queue-work-command"></a>
### `queue:work` 命令

Laravel 包含一個 Artisan 命令，該命令將啟動隊列進程並在新任務被推送到隊列時處理它們。 你可以使用 `queue:work` Artisan 命令運行任務進程。請注意，一旦 `queue:work` 命令啟動，它將繼續運行，直到手動停止或關閉終端：

```shell
php artisan queue:work
```

> **技巧**
> 要保持 `queue:work` 進程在後台永久運行，你應該使用 [Supervisor](#supervisor-configuration) 等進程監視器來確保隊列工作進程不會停止運行。



如果你希望處理的任務 ID 包含在命令的輸出中，則可以在調用 `queue:work` 命令時包含 -v 標志：

```shell
php artisan queue:work -v
```

請記住，隊列任務工作者是長期存在的進程，並將啟動的應用程序狀態存儲在內存中。 因此，他們在啟動後不會注意到你的代碼庫中的更改。 因此，在你的部署過程中，請務必[重新啟動你的任務隊列進程](#queue-workers-and-deployment)。 此外，請記住，你的應用程序創建或修改的任何靜態狀態都不會在任務啟動之間自動重置。

或者，你可以運行 `queue:listen` 命令。 使用 `queue:listen` 命令時，當你想要重新加載更新後的代碼或重置應用程序狀態時，無需手動重啟 worker； 但是，此命令的效率明顯低於 `queue:work` 命令：

```shell
php artisan queue:listen
```

<a name="running-multiple-queue-workers"></a>
#### 運行多個隊列進程

要將多個 worker 分配到一個隊列並同時處理任務，你應該簡單地啟動多個 `queue:work` 進程。 這可以通過終端中的多個選項卡在本地完成，也可以使用流程管理器的配置設置在生產環境中完成。 [使用 Supervisor 時](#supervisor-configuration)，你可以使用 `numprocs` 配置值。

<a name="specifying-the-connection-queue"></a>
#### 指定連接 & 隊列

你還可以指定工作人員應使用哪個隊列連接。 傳遞給 `work` 命令的連接名稱應對應於 `config/queue.php` 配置文件中定義的連接之一：

```shell
php artisan queue:work redis
```

默認情況下，`queue:work` 命令只處理給定連接上默認隊列的任務。 但是，你可以通過僅處理給定連接的特定隊列來進一步自定義你的隊列工作者。 例如，如果你的所有電子郵件都在你的 `redis` 隊列連接上的 `emails` 隊列中處理，你可以發出以下命令來啟動只處理該隊列的工作程序：

```shell
php artisan queue:work redis --queue=emails
```

<a name="processing-a-specified-number-of-jobs"></a>
#### Processing A Specified Number Of Jobs

`--once` 選項可用於指定進程僅處理隊列中的單個任務

```shell
php artisan queue:work --once
```

`--max-jobs` 選項可用於指示 worker 處理給定數量的任務然後退出。 此選項在與 [Supervisor](#supervisor-configuration) 結合使用時可能很有用，這樣你的工作人員在處理給定數量的任務後會自動重新啟動，釋放他們可能積累的任何內存：

```shell
php artisan queue:work --max-jobs=1000
```

<a name="processing-all-queued-jobs-then-exiting"></a>
#### 處理所有排隊的任務然後退出

`--stop-when-empty` 選項可用於指定進程處理所有作業，然後正常退出。如果你希望在隊列為空後關閉容器，則此選項在處理 Docker 容器中的 Laravel 隊列時很有用

```shell
php artisan queue:work --stop-when-empty
```

<a name="processing-jobs-for-a-given-number-of-seconds"></a>
#### 在給定的秒數內處理任務

`--max-time` 選項可用於指示進程給定的秒數內處理作業，然後退出。 當與 [Supervisor](#supervisor-configuration) 結合使用時，此選項可能很有用，這樣你的工作人員在處理作業給定時間後會自動重新啟動，釋放他們可能積累的任何內存：

```shell
# 處理進程一小時，然後退出...
php artisan queue:work --max-time=3600
```

<a name="worker-sleep-duration"></a>
#### 進程睡眠時間

當隊列中有任務可用時，進程將繼續處理作業，而不會在它們之間產生延遲。但是，`sleep` 選項決定了如果沒有可用的新任務，進程將 `sleep` 多少秒。 睡眠時，進程不會處理任何新的作業 - 任務將在進程再次喚醒後處理。

```shell
php artisan queue:work --sleep=3
```

<a name="resource-considerations"></a>
#### 資源注意事項

守護進程隊列在處理每個任務之前不會 `reboot` 框架。因此，你應該在每個任務完成後釋放所有繁重的資源。例如，如果你正在使用 GD 庫進行圖像處理，你應該在處理完圖像後使用 `imagedestroy` 釋放內存。

<a name="queue-priorities"></a>
### 隊列優先級

有時你可能希望優先處理隊列的處理方式。例如，在 `config/queue.php` 配置文件中，你可以將 `redis` 連接的默認 `queue` 設置為 `low`。 但是，有時你可能希望將作業推送到 `high` 優先級隊列，如下所示：

    dispatch((new Job)->onQueue('high'));

要啟動一個進程，在繼續處理 `low` 隊列上的任何任務之前驗證所有 `high` 隊列任務是否已處理，請將隊列名稱的逗號分隔列表傳遞給 `work` 命令：

```shell
php artisan queue:work --queue=high,low
```

<a name="queue-workers-and-deployment"></a>
### 隊列進程 & 部署

由於隊列任務是長期存在的進程，如果不重新啟動，他們不會注意到代碼的更改。因此，使用隊列任務部署應用程序的最簡單方法是在部署過程中重新啟動任務。你可以通過發出 `queue:restart` 命令優雅地重新啟動所有進程：

```shell
php artisan queue:restart
```

此命令將指示所有隊列進程在處理完當前任務後正常退出，以免丟失現有任務。由於隊列任務將在執行 `queue:restart` 命令時退出，你應該運行諸如 [Supervisor](#supervisor-configuration) 之類的進程管理器來自動重新啟動隊列任務。

>**注意**
>隊列使用 [cache](/docs/laravel/10.x/cache)  來存儲重啟信號，因此你應該在使用此功能之前驗證是否為你的應用程序正確配置了緩存驅動程序。

<a name="job-expirations-and-timeouts"></a>
### 任務到期 & 超時

<a name="job-expiration"></a>
#### 任務到期

在`config/queue.php`配置文件中，每個隊列連接都定義了一個`retry_after`選項。該選項指定隊列連接在重試正在處理的作業之前應該等待多少秒。例如，如果`retry_after`的值設置為`90`，如果作業已經處理了90秒而沒有被釋放或刪除，則該作業將被釋放回隊列。通常，你應該將`retry_after`值設置為作業完成處理所需的最大秒數。

>**警告**
>唯一不包含 `retry_after` 值的隊列連接是Amazon SQS。SQS將根據AWS控制台內管理的 [默認可見性超時](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/AboutVT.html) 重試作業。

<a name="worker-timeouts"></a>
#### 進程超時

`queue:work` Artisan命令公開了一個`--timeout`選項。默認情況下，`--timeout`值為60秒。如果任務的處理時間超過超時值指定的秒數，則處理該任務的進程將退出並出現錯誤。通常，工作程序將由 [你的服務器上配置的進程管理器](#supervisor-configuration) 自動重新啟動：

```shell
php artisan queue:work --timeout=60
```

`retry_after` 配置選項和 `--timeout` CLI 選項是不同的，但它們協同工作以確保任務不會丟失並且任務僅成功處理一次。
> **警告**
> `--timeout` 值應始終比 `retry_after` 配置值至少短幾秒鐘。 這將確保處理凍結任務的進程始終在重試任務之前終止。 如果你的 `--timeout` 選項比你的 `retry_after` 配置值長，你的任務可能會被處理兩次。

<a name="supervisor-configuration"></a>
## Supervisor 配置

在生產中，你需要一種方法來保持 `queue:work` 進程運行。 `queue:work` 進程可能會因多種原因停止運行，例如超過 worker 超時或執行 `queue:restart` 命令。
出於這個原因，你需要配置一個進程監視器，它可以檢測你的 `queue:work` 進程何時退出並自動重新啟動它們。此外，進程監視器可以讓你指定要同時運行多少個 `queue:work` 進程。Supervisor 是 Linux 環境中常用的進程監視器，我們將在下面的文檔中討論如何配置它。

<a name="installing-supervisor"></a>
#### 安裝 Supervisor

Supervisor 是 Linux 操作系統的進程監視器，如果它們失敗，它將自動重新啟動你的 `queue:work` 進程。要在 Ubuntu 上安裝 Supervisor，你可以使用以下命令：

```shell
sudo apt-get install supervisor
```
>**注意**
>如果你自己配置和管理 Supervisor 聽起來很費力，請考慮使用 [Laravel Forge](https://forge.laravel.com)，它會自動為你的生產 Laravel 項目安裝和配置 Supervisor。

<a name="configuring-supervisor"></a>
#### 配置 Supervisor

Supervisor 配置文件通常存儲在 `/etc/supervisor/conf.d` 目錄中。在這個目錄中，你可以創建任意數量的配置文件來指示 Supervisor 應該如何監控你的進程。例如，讓我們創建一個啟動和監控 `queue:work` 進程的 `laravel-worker.conf` 文件：

```ini
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /home/forge/app.com/artisan queue:work sqs --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=forge
numprocs=8
redirect_stderr=true
stdout_logfile=/home/forge/app.com/worker.log
stopwaitsecs=3600
```

在這個例子中，`numprocs` 指令將指示 Supervisor 運行 8 個 `queue:work` 進程並監控所有進程，如果它們失敗則自動重新啟動它們。你應該更改配置的「命令」指令以反映你所需的隊列連接和任務選項。

> **警告**
> 你應該確保 `stopwaitsecs` 的值大於運行時間最長的作業所消耗的秒數。否則，Supervisor 可能會在作業完成處理之前將其終止。

<a name="starting-supervisor"></a>
#### 開始 Supervisor

創建配置文件後，你可以使用以下命令更新 Supervisor 配置並啟動進程：

```shell
sudo supervisorctl reread

sudo supervisorctl update

sudo supervisorctl start laravel-worker:*
```

有關 Supervisor 的更多信息，請參閱 [Supervisor 文檔](http://supervisord.org/index.html)。

<a name="dealing-with-failed-jobs"></a>
## 處理失敗的任務

有時，你隊列的任務會失敗。別擔心，事情並不總是按計劃進行！ Laravel 提供了一種方便的方法來 [指一個任務應該嘗試的最大次數](#max-job-attempts-and-timeout)。在異步任務超過此嘗試次數後，它將被插入到 `failed_jobs` 數據庫表中。 失敗的 [同步調度的任務](/docs/laravel/10.x/queuesmd#synchronous-dispatching) 不存儲在此表中，它們的異常由應用程序立即處理。


創建 `failed_jobs` 表的遷移通常已經存在於新的 Laravel 應用程序中。但是，如果你的應用程序不包含此表的遷移，你可以使用 `queue:failed-table` 命令來創建遷移：

```shell
php artisan queue:failed-table

php artisan migrate
```

運行 [queue worker](#running-the-queue-worker) 進程時，你可以使用 `queue:work` 命令上的 `--tries` 開關指定任務應嘗試的最大次數。如果你沒有為 `--tries` 選項指定值，則作業將僅嘗試一次或與任務類的 `$tries` 屬性指定的次數相同：

```shell
php artisan queue:work redis --tries=3
```

使用 `--backoff` 選項，你可以指定 Laravel 在重試遇到異常的任務之前應該等待多少秒。默認情況下，任務會立即釋放回隊列，以便可以再次嘗試：

```shell
php artisan queue:work redis --tries=3 --backoff=3
```

如果你想配置 Laravel 在重試每個任務遇到異常的任務之前應該等待多少秒，你可以通過在你的任務類上定義一個 `backoff` 屬性來實現：

    /**
     * 重試任務前等待的秒數
     *
     * @var int
     */
    public $backoff = 3;

如果你需要更覆雜的邏輯來確定任務的退避時間，你可以在你的任務類上定義一個 `backoff` 方法：

    /**
    * 計算重試任務之前要等待的秒數
    */
    public function backoff(): int
    {
        return 3;
    }

你可以通過從 `backoff` 方法返回一組退避值來輕松配置 “exponential” 退避。在此示例中，第一次重試的重試延遲為 1 秒，第二次重試為 5 秒，第三次重試為 10 秒：

    /**
    * 計算重試任務之前要等待的秒數
    *
    * @return array<int, int>
    */
    public function backoff(): array
    {
        return [1, 5, 10];
    }

<a name="cleaning-up-after-failed-jobs"></a>
### 任務失敗後清理

當特定任務失敗時，你可能希望向用戶發送警報或恢覆該任務部分完成的任何操作。為此，你可以在任務類上定義一個 `failed` 方法。導致作業失敗的 `Throwable` 實例將被傳遞給 `failed` 方法：

    <?php

    namespace App\Jobs;

    use App\Models\Podcast;
    use App\Services\AudioProcessor;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;
    use Illuminate\Queue\SerializesModels;
    use Throwable;

    class ProcessPodcast implements ShouldQueue
    {
        use InteractsWithQueue, Queueable, SerializesModels;

        /**
         * 創建新任務實例
         */
        public function __construct(
            public Podcast $podcast,
        ) {}

        /**
         * 執行任務
         */
        public function handle(AudioProcessor $processor): void
        {
            // 處理上傳的播客...
        }

        /**
         * 處理失敗作業
         */
        public function failed(Throwable $exception): void
        {
            // 向用戶發送失敗通知等...
        }
    }

> **注意**
> 在調用 `failed` 方法之前實例化任務的新實例；因此，在 `handle` 方法中可能發生的任何類屬性修改都將丟失。

<a name="retrying-failed-jobs"></a>
### 重試失敗的任務

要查看已插入到你的 `failed_jobs` 數據庫表中的所有失敗任務，你可以使用 `queue:failed` Artisan 命令：

```shell
php artisan queue:failed
```

`queue:failed` 命令將列出任務 ID、連接、隊列、失敗時間和有關任務的其他信息。任務 ID 可用於重試失敗的任務。例如，要重試 ID 為 `ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece` 的失敗任務，請發出以下命令：

```shell
php artisan queue:retry ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece
```

如有必要，可以向命令傳遞多個 ID:

```shell
php artisan queue:retry ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece 91401d2c-0784-4f43-824c-34f94a33c24d
```

還可以重試指定隊列的所有失敗任務：

```shell
php artisan queue:retry --queue=name
```

重試所有失敗任務，可以執行 `queue:retry` 命令，並將 `all` 作為 ID 傳遞：

```shell
php artisan queue:retry all
```

如果要刪除指定的失敗任務，可以使用 `queue:forget` 命令：

```shell
php artisan queue:forget 91401d2c-0784-4f43-824c-34f94a33c24d
```

> **技巧**
> 使用 [Horizon](/docs/laravel/10.x/horizon) 時，應該使用 `Horizon:forget` 命令來刪除失敗任務，而不是 `queue:forget` 命令。

刪除 `failed_jobs` 表中所有失敗任務，可以使用 `queue:flush` 命令:

```shell
php artisan queue:flush
```

<a name="ignoring-missing-models"></a>
### 忽略缺失的模型

向任務中注入 `Eloquent` 模型時，模型會在注入隊列之前自動序列化，並在處理任務時從數據庫中重新檢索。但是，如果在任務等待消費時刪除了模型，則任務可能會失敗，拋出 `ModelNotFoundException` 異常。

為方便起見，可以把將任務的 `deleteWhenMissingModels` 屬性設置為 `true`，這樣會自動刪除缺少模型的任務。當此屬性設置為 `true` 時，Laravel 會放棄該任務，並且不會引發異常：

    /**
     * 如果任務的模型不存在，則刪除該任務
     *
     * @var bool
     */
    public $deleteWhenMissingModels = true;

<a name="pruning-failed-jobs"></a>
### 刪除失敗的任務

你可以通過調用 `queue:prune-failed` Artisan 命令刪除應用程序的 `failed_jobs` 表中的所有記錄：

```shell
php artisan queue:prune-failed
```

默認情況下，將刪除所有超過 24 小時的失敗任務記錄，如果為命令提供 `--hours` 選項，則僅保留在過去 N 小時內插入的失敗任務記錄。例如，以下命令將刪除超過 48 小時前插入的所有失敗任務記錄：

```shell
php artisan queue:prune-failed --hours=48
```

<a name="storing-failed-jobs-in-dynamodb"></a>
### 在 DynamoDB 中存儲失敗的任務

Laravel 還支持將失敗的任務記錄存儲在 [DynamoDB](https://aws.amazon.com/dynamodb) 而不是關系數據庫表中。但是，你必須創建一個 DynamoDB 表來存儲所有失敗的任務記錄。通常，此表應命名為 `failed_jobs`，但你應根據應用程序的 `queue` 配置文件中的 `queue.failed.table` 配置值命名該表。

`failed_jobs` 表應該有一個名為 `application` 的字符串主分區鍵和一個名為 uuid 的字符串主排序鍵。鍵的 `application` 部分將包含應用程序的名稱，該名稱由應用程序的 `app` 配置文件中的 `name` 配置值定義。由於應用程序名稱是 DynamoDB 表鍵的一部分，因此你可以使用同一個表來存儲多個 Laravel 應用程序的失敗任務。

此外，請確保你安裝了 AWS 開發工具包，以便你的 Laravel 應用程序可以與 Amazon DynamoDB 通信：

```shell
composer require aws/aws-sdk-php
```

接下來，`queue.failed.driver` 配置選項的值設置為 `dynamodb`。此外，你應該在失敗的作業配置數組中定義 `key`、`secret` 和 `region` 配置選項。 這些選項將用於向 AWS 進行身份驗證。 當使用 `dynamodb` 驅動程序時，`queue.failed.database` 配置選項不是必須的：

```php
'failed' => [
    'driver' => env('QUEUE_FAILED_DRIVER', 'dynamodb'),
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    'table' => 'failed_jobs',
],
```

<a name="disabling-failed-job-storage"></a>
### 禁用失敗的任務存儲

你可以通過將 `queue.failed.driver` 配置選項的值設置為 `null` 來指示 Laravel 丟棄失敗的任務而不存儲它們。通過 `QUEUE_FAILED_DRIVER` 環境變量來完成：

```ini
QUEUE_FAILED_DRIVER=null
```

<a name="failed-job-events"></a>
### 失敗的任務事件

如果你想注冊一個在作業失敗時調用的事件監聽器，你可以使用 `Queue` facade的 failing 方法。例如，我們可以從 Laravel 中包含的 `AppServiceProvider` 的 `boot` 方法為這個事件附加一個閉包：

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Queue;
    use Illuminate\Support\ServiceProvider;
    use Illuminate\Queue\Events\JobFailed;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * 注冊任何應用程序服務
         */
        public function register(): void
        {
            // ...
        }

        /**
         * 引導任何應用程序服務
         */
        public function boot(): void
        {
            Queue::failing(function (JobFailed $event) {
                // $event->connectionName
                // $event->job
                // $event->exception
            });
        }
    }

<a name="clearing-jobs-from-queues"></a>
## 從隊列中清除任務

> **技巧**
> 使用 [Horizon](/docs/laravel/10.x/horizon) 時，應使用 `horizon:clear` 命令從隊列中清除作業，而不是使用 `queue:clear` 命令。

如果你想從默認連接的默認隊列中刪除所有任務，你可以使用 `queue:clear` Artisan 命令來執行此操作：

```shell
php artisan queue:clear
```

你還可以提供 `connection` 參數和 `queue` 選項以從特定連接和隊列中刪除任務：

```shell
php artisan queue:clear redis --queue=emails
```

> **注意**
> 從隊列中清除任務僅適用於 SQS、Redis 和數據庫隊列驅動程序。 此外，SQS 消息刪除過程最多需要 60 秒，因此在你清除隊列後 60 秒內發送到 SQS 隊列的任務也可能會被刪除。

<a name="monitoring-your-queues"></a>
## 監控你的隊列

如果你的隊列突然湧入了大量的任務，它會導致隊列任務繁重，從而增加了任務的完成時間，想你所想， Laravel 可以在隊列執行超過設定的閾值時候提醒你。

在開始之前， 你需要通過 `queue:monitor` 命令配置它 [每分鐘執行一次](/docs/laravel/10.x/scheduling)。這個命令可以設定任務的名稱，以及你想要設定的任務閾值：

```shell
php artisan queue:monitor redis:default,redis:deployments --max=100
```

當你的任務超過設定閾值時候，僅通過這個方法還不足以觸發通知，此時會觸發一個 `Illuminate\Queue\Events\QueueBusy` 事件。你可以在你的應用 `EventServiceProvider` 來監聽這個事件，從而將監聽結果通知給你的開發團隊：

```php
use App\Notifications\QueueHasLongWaitTime;
use Illuminate\Queue\Events\QueueBusy;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Notification;

/**
 * 為你的應用程序注冊其他更多事件
 */
public function boot(): void
{
    Event::listen(function (QueueBusy $event) {
        Notification::route('mail', 'dev@example.com')
                ->notify(new QueueHasLongWaitTime(
                    $event->connection,
                    $event->queue,
                    $event->size
                ));
    });
}
```

<a name="testing"></a>
## 測試

當測試調度任務的代碼時，你可能希望指示 Laravel 不要實際執行任務本身，因為任務的代碼可以直接和獨立於調度它的代碼進行測試。 當然，要測試任務本身，你可以實例化一個任務實例並在測試中直接調用 `handle` 方法。

你可以使用 `Queue` facade 的 `fake` 方法來防止排隊的任務實際被推送到隊列中。 在調用 `Queue` facade 的 `fake` 方法後，你可以斷言應用程序試圖將任務推送到隊列中：

    <?php

    namespace Tests\Feature;

    use App\Jobs\AnotherJob;
    use App\Jobs\FinalJob;
    use App\Jobs\ShipOrder;
    use Illuminate\Support\Facades\Queue;
    use Tests\TestCase;

    class ExampleTest extends TestCase
    {
        public function test_orders_can_be_shipped(): void
        {
            Queue::fake();

            // 執行訂單發貨...

            // 斷言沒有任務被推送......
            Queue::assertNothingPushed();

            // 斷言一個任務被推送到一個給定的隊列...
            Queue::assertPushedOn('queue-name', ShipOrder::class);

            // 斷言任務被推了兩次...
            Queue::assertPushed(ShipOrder::class, 2);

            // 斷言任務沒有被推送...
            Queue::assertNotPushed(AnotherJob::class);

            // 斷言閉包被推送到隊列中...
            Queue::assertClosurePushed();
        }
    }

你可以將閉包傳遞給 `assertPushed` 或 `assertNotPushed` 方法，以斷言已推送通過給定「真實性測試」的任務。 如果至少有一項任務被推送並通過了給定的真值測試，則斷言將成功：

    Queue::assertPushed(function (ShipOrder $job) use ($order) {
        return $job->order->id === $order->id;
    });

<a name="faking-a-subset-of-jobs"></a>
### 偽造任務的一個子集

如果你只需要偽造特定的任務，同時允許你的其他任務正常執行，你可以將應該偽造的任務的類名傳遞給 fake 方法：

    public function test_orders_can_be_shipped(): void
    {
        Queue::fake([
            ShipOrder::class,
        ]);

        // 執行訂單發貨...

        // 斷言任務被推了兩次......
        Queue::assertPushed(ShipOrder::class, 2);
    }

你可以使用 `except` 方法偽造除一組指定任務之外的所有任務：

    Queue::fake()->except([
        ShipOrder::class,
    ]);

<a name="testing-job-chains"></a>
### 測試任務鏈

要測試任務鏈，你需要利用 `Bus` 外觀的偽造功能。 `Bus` 門面的 `assertChained` 方法可用於斷言 [任務鏈](/docs/laravel/10.x/queues#job-chaining) 已被分派。 `assertChained` 方法接受一個鏈式任務數組作為它的第一個參數：

    use App\Jobs\RecordShipment;
    use App\Jobs\ShipOrder;
    use App\Jobs\UpdateInventory;
    use Illuminate\Support\Facades\Bus;

    Bus::fake();

    // ...

    Bus::assertChained([
        ShipOrder::class,
        RecordShipment::class,
        UpdateInventory::class
    ]);

正如你在上面的示例中看到的，鏈式任務數組可能是任務類名稱的數組。 但是，你也可以提供一組實際的任務實例。 這樣做時，Laravel 將確保任務實例屬於同一類，並且與你的應用程序調度的鏈式任務具有相同的屬性值：

    Bus::assertChained([
        new ShipOrder,
        new RecordShipment,
        new UpdateInventory,
    ]);

你可以使用 `assertDispatchedWithoutChain` 方法來斷言一個任務是在沒有任務鏈的情況下被推送的：

    Bus::assertDispatchedWithoutChain(ShipOrder::class);

<a name="testing-job-batches"></a>
### 測試任務批處理

`Bus` 門面的 `assertBatched` 方法可用於斷言 [批處理任務](/docs/laravel/10.x/queuesmd#job-batching) 已分派。 給 `assertBatched` 方法的閉包接收一個 `Illuminate\Bus\PendingBatch` 的實例，它可用於檢查批處理中的任務：

    use Illuminate\Bus\PendingBatch;
    use Illuminate\Support\Facades\Bus;

    Bus::fake();

    // ...

    Bus::assertBatched(function (PendingBatch $batch) {
        return $batch->name == 'import-csv' &&
               $batch->jobs->count() === 10;
    });

<a name="testing-job-batch-interaction"></a>
#### 測試任務 / 批處理交互

此外，你可能偶爾需要測試單個任務與其基礎批處理的交互。 例如，你可能需要測試任務是否取消了對其批次的進一步處理。 為此，你需要通過 `withFakeBatch` 方法為任務分配一個假批次。 `withFakeBatch` 方法返回一個包含任務實例和假批次的元組：

    [$job, $batch] = (new ShipOrder)->withFakeBatch();

    $job->handle();

    $this->assertTrue($batch->cancelled());
    $this->assertEmpty($batch->added);

<a name="job-events"></a>
## 任務事件

使用 `Queue` [facade](/docs/laravel/10.x/facades) 上的 `before` 和 `after` 方法，你可以指定要在處理排隊任務之前或之後執行的回調。 這些回調是為儀表板執行額外日志記錄或增量統計的絕佳機會。 通常，你應該從 [服務提供者](/docs/laravel/10.x/providers) 的 `boot` 方法中調用這些方法。 例如，我們可以使用 Laravel 自帶的 `AppServiceProvider`：

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Queue;
    use Illuminate\Support\ServiceProvider;
    use Illuminate\Queue\Events\JobProcessed;
    use Illuminate\Queue\Events\JobProcessing;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * 注冊任何應用程序服務。
         */
        public function register(): void
        {
            // ...
        }

        /**
         * 引導任何應用程序服務。
         */
        public function boot(): void
        {
            Queue::before(function (JobProcessing $event) {
                // $event->connectionName
                // $event->job
                // $event->job->payload()
            });

            Queue::after(function (JobProcessed $event) {
                // $event->connectionName
                // $event->job
                // $event->job->payload()
            });
        }
    }

通過使用 `Queue` [facade](/docs/laravel/10.x/facades) 的 `looping` 方法 ，你可以在 worker 嘗試從隊列獲取任務之前執行指定的回調。例如，你可以注冊一個閉包，用以回滾之前失敗任務打開的任何事務：

    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\Facades\Queue;

    Queue::looping(function () {
        while (DB::transactionLevel() > 0) {
            DB::rollBack();
        }
    });
