# 事件系統
- [介紹](#introduction)
- [注冊事件和監聽器](#registering-events-and-listeners)
    - [生成事件和監聽器](#generating-events-and-listeners)
    - [手動注冊事件](#manually-registering-events)
    - [事件發現](#event-discovery)
- [定義事件](#defining-events)
- [定義監聽器](#defining-listeners)
- [隊列事件監聽器](#queued-event-listeners)
    - [手動與隊列交互](#manually-interacting-with-the-queue)
    - [隊列事件監聽器和數據庫事務](#queued-event-listeners-and-database-transactions)
    - [處理失敗的隊列](#handling-failed-jobs)
- [調度事件](#dispatching-events)
- [事件訂閱者](#event-subscribers)
    - [編寫事件訂閱者](#writing-event-subscribers)
    - [注冊事件訂閱者](#registering-event-subscribers)
- [測試](#testing)
    - [模擬一部分事件](#faking-a-subset-of-events)
    - [作用域事件模擬](#scoped-event-fakes)

<a name="introduction"></a>
## 介紹

Laravel 的事件系統提供了一個簡單的觀察者模式的實現，允許你能夠訂閱和監聽在你的應用中的發生的各種事件。事件類一般來說存儲在 `app/Events` 目錄，監聽者的類存儲在 `app/Listeners` 目錄。不要擔心在你的應用中沒有看到這兩個目錄，因為通過 Artisan 命令行來創建事件和監聽者的時候目錄會同時被創建。

事件系統可以作為一個非常棒的方式來解耦你的系統的方方面面，因為一個事件可以有多個完全不相關的監聽者。例如，你希望每當有訂單發出的時候都給你發送一個 Slack 通知。你大可不必將你的處理訂單的代碼和發送 slack 消息的代碼放在一起，你只需要觸發一個 App\Events\OrderShipped 事件，然後事件監聽者可以收到這個事件然後發送 slack 通知

<a name="registering-events-and-listeners"></a>
## 注冊事件和監聽器

在系統的服務提供者 `App\Providers\EventServiceProvider` 中提供了一個簡單的方式來注冊你所有的事件監聽者。屬性 `listen` 包含所有的事件 (作為鍵) 和對應的監聽器 (值)。你可以添加任意多系統需要的監聽器在這個數組中，讓我們添加一個 `OrderShipped` 事件：

    use App\Events\OrderShipped;
    use App\Listeners\SendShipmentNotification;

    /**
     * 系統中的事件和監聽器的對應關系。
     *
     * @var array
     */
    protected $listen = [
        OrderShipped::class => [
            SendShipmentNotification::class,
        ],
    ];

> **注意**
> 可以使用 `event:list` 命令顯示應用程序


<a name="generating-events-and-listeners"></a>
### 生成事件和監聽器

當然，為每個事件和監聽器手動創建文件是很麻煩的。相反，將監聽器和事件添加到 `EventServiceProvider` 並使用 `event:generate` Artisan 命令。此命令將生成 `EventServiceProvider` 中列出的、尚不存在的任何事件或偵聽器：

```shell
php artisan event:generate
```

或者，你可以使用 `make:event` 以及 `make:listener` 用於生成單個事件和監聽器的 Artisan 命令：

```shell
php artisan make:event PodcastProcessed

php artisan make:listener SendPodcastNotification --event=PodcastProcessed
```

<a name="manually-registering-events"></a>
### 手動注冊事件

通常，事件應該通過 `EventServiceProvider` `$listen` 數組注冊；但是，你也可以在 `EventServiceProvider` 的 `boot` 方法中手動注冊基於類或閉包的事件監聽器：

    use App\Events\PodcastProcessed;
    use App\Listeners\SendPodcastNotification;
    use Illuminate\Support\Facades\Event;

    /**
     * 注冊任意的其他事件和監聽器。
     */
    public function boot(): void
    {
        Event::listen(
            PodcastProcessed::class,
            [SendPodcastNotification::class, 'handle']
        );

        Event::listen(function (PodcastProcessed $event) {
            // ...
        });
    }

<a name="queuable-anonymous-event-listeners"></a>
#### 可排隊匿名事件監聽器

手動注冊基於閉包的事件監聽器時，可以將監聽器閉包包裝在 `Illuminate\Events\queueable` 函數中，以指示 Laravel 使用 [隊列](/docs/laravel/10.x/queues) 執行偵聽器：

    use App\Events\PodcastProcessed;
    use function Illuminate\Events\queueable;
    use Illuminate\Support\Facades\Event;

    /**
     * 注冊任意的其他事件和監聽器。
     */
    public function boot(): void
    {
        Event::listen(queueable(function (PodcastProcessed $event) {
            // ...
        }));
    }

與隊列任務一樣，可以使用 `onConnection`、`onQueue` 和 `delay` 方法自定義隊列監聽器的執行：

    Event::listen(queueable(function (PodcastProcessed $event) {
        // ...
    })->onConnection('redis')->onQueue('podcasts')->delay(now()->addSeconds(10)));



如果你想處理匿名隊列監聽器失敗，你可以在定義 `queueable` 監聽器時為 `catch` 方法提供一個閉包。這個閉包將接收導致監聽器失敗的事件實例和 `Throwable` 實例：

    use App\Events\PodcastProcessed;
    use function Illuminate\Events\queueable;
    use Illuminate\Support\Facades\Event;
    use Throwable;

    Event::listen(queueable(function (PodcastProcessed $event) {
        // ...
    })->catch(function (PodcastProcessed $event, Throwable $e) {
        // 隊列監聽器失敗了
    }));

<a name="wildcard-event-listeners"></a>
#### 通配符事件監聽器

你甚至可以使用 `*` 作為通配符參數注冊監聽器，這允許你在同一個監聽器上捕獲多個事件。通配符監聽器接收事件名作為其第一個參數，整個事件數據數組作為其第二個參數：

    Event::listen('event.*', function (string $eventName, array $data) {
        // ...
    });

<a name="event-discovery"></a>
### 事件的發現

你可以啟用自動事件發現，而不是在 `EventServiceProvider` 的 `$listen` 數組中手動注冊事件和偵聽器。當事件發現啟用，Laravel 將通過掃描你的應用程序的 `Listeners` 目錄自動發現和注冊你的事件和監聽器。此外，在 `EventServiceProvider` 中列出的任何顯式定義的事件仍將被注冊。

Laravel 通過使用 PHP 的反射服務掃描監聽器類來查找事件監聽器。當 Laravel 發現任何以 `handle` 或 `__invoke` 開頭的監聽器類方法時，Laravel 會將這些方法注冊為該方法簽名中類型暗示的事件的事件監聽器：

    use App\Events\PodcastProcessed;

    class SendPodcastNotification
    {
        /**
         * 處理給定的事件
         */
        public function handle(PodcastProcessed $event): void
        {
            // ...
        }
    }



事件發現在默認情況下是禁用的，但你可以通過重寫應用程序的 `EventServiceProvider` 的 `shouldDiscoverEvents` 方法來啟用它：

    /**
     * 確定是否應用自動發現事件和監聽器。
     */
    public function shouldDiscoverEvents(): bool
    {
        return true;
    }

默認情況下，應用程序 `app/listeners` 目錄中的所有監聽器都將被掃描。如果你想要定義更多的目錄來掃描，你可以重寫 `EventServiceProvider` 中的 `discoverEventsWithin` 方法：

    /**
     * 獲取應用於發現事件的監聽器目錄。
     *
     * @return array<int, string>
     */
    protected function discoverEventsWithin(): array
    {
        return [
            $this->app->path('Listeners'),
        ];
    }

<a name="event-discovery-in-production"></a>
#### 生產中的事件發現

在生產環境中，框架在每個請求上掃描所有監聽器的效率並不高。因此，在你的部署過程中，你應該運行 `event:cache` Artisan 命令來緩存你的應用程序的所有事件和監聽器清單。框架將使用該清單來加速事件注冊過程。`event:clear` 命令可以用來銷毀緩存。

<a name="defining-events"></a>
## 定義事件

事件類本質上是一個數據容器，它保存與事件相關的信息。例如，讓我們假設一個 `App\Events\OrderShipped` 事件接收到一個 [Eloquent ORM](/docs/laravel/10.x/eloquent) 對象：

    <?php

    namespace App\Events;

    use App\Models\Order;
    use Illuminate\Broadcasting\InteractsWithSockets;
    use Illuminate\Foundation\Events\Dispatchable;
    use Illuminate\Queue\SerializesModels;

    class OrderShipped
    {
        use Dispatchable, InteractsWithSockets, SerializesModels;

        /**
         * 創建一個新的事件實例。
         */
        public function __construct(
            public Order $order,
        ) {}
    }

如你所見，這個事件類不包含邏輯。它是一個被購買的 `App\Models\Order` 實例容器。 如果事件對象是使用 PHP 的 `SerializesModels` 函數序列化的，事件使用的 `SerializesModels` trait 將會優雅地序列化任何 Eloquent 模型，比如在使用 [隊列偵聽器](#queued-event-listeners)。


<a name="defining-listeners"></a>
## 定義監聽器

接下來，讓我們看一下示例事件的監聽器。事件監聽器在其 `handle` 方法中接收事件實例。Artisan 命令 `event:generate` 和 `make:listener` 會自動導入正確的事件類，並在 `handle` 方法上對事件進行類型提示。在 `handle` 方法中，你可以執行任何必要的操作來響應事件：

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;

    class SendShipmentNotification
    {
        /**
         * 創建事件監聽器
         */
        public function __construct()
        {
            // ...
        }

        /**
         * 處理事件
         */
        public function handle(OrderShipped $event): void
        {
            // 使用 $event->order 來訪問訂單 ...
        }
    }

> **技巧**
> 事件監聽器還可以在構造函數中加入任何依賴關系的類型提示。所有的事件監聽器都是通過 Laravel 的 [服務容器](/docs/laravel/10.x/container) 解析的，因此所有的依賴都將會被自動注入。

<a name="stopping-the-propagation-of-an-event"></a>
#### 停止事件傳播

有時，你可能希望停止將事件傳播到其他監聽器。你可以通過從監聽器的 `handle` 方法中返回 `false` 來做到這一點。

<a name="queued-event-listeners"></a>
## 隊列事件監聽器

如果你的監聽器要執行一個緩慢的任務，如發送電子郵件或進行 HTTP 請求，那麽隊列化監聽器就很有用了。在使用隊列監聽器之前，請確保 [配置你的隊列](/docs/laravel/10.x/queues) 並在你的服務器或本地開發環境中啟動一個隊列 worker。

要指定監聽器啟動隊列，請將 `ShouldQueue` 接口添加到監聽器類。 由 Artisan 命令 `event:generate` 和 `make:listener` 生成的監聽器已經將此接口導入當前命名空間，因此你可以直接使用：

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        // ...
    }



就是這樣！ 現在，當此監聽器處理的事件被調度時，監聽器將使用 Laravel 的 [隊列系統](/docs/laravel/10.x/queues) 自動由事件調度器排隊。 如果監聽器被隊列執行時沒有拋出異常，隊列中的任務處理完成後會自動刪除。

<a name="customizing-the-queue-connection-queue-name"></a>
#### 自定義隊列連接和隊列名稱

如果你想自定義事件監聽器的隊列連接、隊列名稱或隊列延遲時間，可以在監聽器類上定義 `$connection`、`$queue` 或 `$delay` 屬性：

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        /**
         * 任務發送到的連接的名稱。
         *
         * @var string|null
         */
        public $connection = 'sqs';

        /**
         * 任務發送到的隊列的名稱。
         *
         * @var string|null
         */
        public $queue = 'listeners';

        /**
         * 處理作業前的時間（秒）。
         *
         * @var int
         */
        public $delay = 60;
    }

如果你想在運行時定義監聽器的隊列連接或隊列名稱，可以在監聽器上定義 `viaConnection` 或 `viaQueue` 方法：

    /**
     * 獲取偵聽器的隊列連接的名稱。
     */
    public function viaConnection(): string
    {
        return 'sqs';
    }

    /**
     * 獲取偵聽器隊列的名稱。
     */
    public function viaQueue(): string
    {
        return 'listeners';
    }

<a name="conditionally-queueing-listeners"></a>
#### 有條件地隊列監聽器

有時，你可能需要根據一些僅在運行時可用的數據來確定是否應將偵聽器排隊。 為此，可以將「shouldQueue」方法添加到偵聽器以確定是否應將偵聽器排隊。 如果 `shouldQueue` 方法返回 `false`，監聽器將不會被執行：

    <?php

    namespace App\Listeners;

    use App\Events\OrderCreated;
    use Illuminate\Contracts\Queue\ShouldQueue;

    class RewardGiftCard implements ShouldQueue
    {
        /**
         * 獎勵客戶一張禮品卡。
         */
        public function handle(OrderCreated $event): void
        {
            // ...
        }

        /**
         * 確定偵聽器是否應排隊。
         */
        public function shouldQueue(OrderCreated $event): bool
        {
            return $event->order->subtotal >= 5000;
        }
    }



<a name="manually-interacting-with-the-queue"></a>
### 手動與隊列交互

如果你需要手動訪問偵聽器的底層隊列作業的 delete 和 release 方法，可以使用 `Illuminate\Queue\InteractsWithQueue` 特性來實現。 這個 trait 默認導入生成的偵聽器並提供對這些方法的訪問：

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        use InteractsWithQueue;

        /**
         * Handle the event.
         */
        public function handle(OrderShipped $event): void
        {
            if (true) {
                $this->release(30);
            }
        }
    }

<a name="queued-event-listeners-and-database-transactions"></a>
### 隊列事件監聽器和數據庫事務

當排隊的偵聽器在數據庫事務中被分派時，它們可能在數據庫事務提交之前由隊列處理。 發生這種情況時，在數據庫事務期間對模型或數據庫記錄所做的任何更新可能尚未反映在數據庫中。 此外，在事務中創建的任何模型或數據庫記錄可能不存在於數據庫中。 如果你的偵聽器依賴於這些模型，則在處理調度排隊偵聽器的作業時可能會發生意外錯誤。

如果你的隊列連接的 `after_commit` 配置選項設置為 `false`，你仍然可以通過在偵聽器類上定義 `$afterCommit` 屬性來指示在提交所有打開的數據庫事務後應該調度特定的排隊偵聽器：

    <?php

    namespace App\Listeners;

    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        use InteractsWithQueue;

        public $afterCommit = true;
    }

> **注意**
> 要了解有關解決這些問題的更多信息，請查看有關[隊列作業和數據庫事務](/docs/laravel/10.x/queuesmd#jobs-and-database-transactions) 的文檔。



<a name="handling-failed-jobs"></a>
### 處理失敗的隊列

有時隊列的事件監聽器可能會失敗。如果排隊的監聽器超過了隊列工作者定義的最大嘗試次數，則將對監聽器調用 `failed` 方法。`failed` 方法接收導致失敗的事件實例和 `Throwable`：

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;
    use Throwable;

    class SendShipmentNotification implements ShouldQueue
    {
        use InteractsWithQueue;

        /**
         * 事件處理。
         */
        public function handle(OrderShipped $event): void
        {
            // ...
        }

        /**
         * 處理失敗任務。
         */
        public function failed(OrderShipped $event, Throwable $exception): void
        {
            // ...
        }
    }

<a name="specifying-queued-listener-maximum-attempts"></a>
#### 指定隊列監聽器的最大嘗試次數

如果隊列中的某個監聽器遇到錯誤，你可能不希望它無限期地重試。因此，Laravel 提供了各種方法來指定監聽器的嘗試次數或嘗試時間。

你可以在監聽器類上定義 `$tries` 屬性，以指定監聽器在被認為失敗之前可能嘗試了多少次：

    <?php

    namespace App\Listeners;

    use App\Events\OrderShipped;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;

    class SendShipmentNotification implements ShouldQueue
    {
        use InteractsWithQueue;

        /**
         * 嘗試隊列監聽器的次數。
         *
         * @var int
         */
        public $tries = 5;
    }

作為定義偵聽器在失敗之前可以嘗試多少次的替代方法，你可以定義不再嘗試偵聽器的時間。這允許在給定的時間範圍內嘗試多次監聽。若要定義不再嘗試監聽器的時間，請在你的監聽器類中添加 `retryUntil` 方法。此方法應返回一個 `DateTime` 實例：

    use DateTime;

    /**
     * 確定監聽器應該超時的時間。
     */
    public function retryUntil(): DateTime
    {
        return now()->addMinutes(5);
    }



<a name="dispatching-events"></a>
## 調度事件

要分派一個事件，你可以在事件上調用靜態的 `dispatch` 方法。這個方法是通過 `Illuminate\Foundation\Events\Dispatchable` 特性提供給事件的。 傳遞給 `dispatch` 方法的任何參數都將被傳遞給事件的構造函數：

    <?php

    namespace App\Http\Controllers;

    use App\Events\OrderShipped;
    use App\Http\Controllers\Controller;
    use App\Models\Order;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class OrderShipmentController extends Controller
    {
        /**
         * 運送給定的訂單。
         */
        public function store(Request $request): RedirectResponse
        {
            $order = Order::findOrFail($request->order_id);

            // 訂單出貨邏輯...

            OrderShipped::dispatch($order);

            return redirect('/orders');
        }
    }

你可以使用 `dispatchIf` 和 `dispatchUnless` 方法根據條件分派事件：

    OrderShipped::dispatchIf($condition, $order);

    OrderShipped::dispatchUnless($condition, $order);

> **提示**
> 在測試時，斷言某些事件是在沒有實際觸發其偵聽器的情況下被分派的，這可能會有所幫助。 Laravel 的 [內置助手](#testing) 讓它變得很簡單。

<a name="event-subscribers"></a>
## 事件訂閱者

<a name="writing-event-subscribers"></a>
### 構建事件訂閱者

事件訂閱者是可以從訂閱者類本身中訂閱多個事件的類，允許你在單個類中定義多個事件處理程序。訂閱者應該定義一個 `subscribe` 方法，它將被傳遞一個事件分派器實例。你可以在給定的分派器上調用 `listen` 方法來注冊事件監聽器：

    <?php

    namespace App\Listeners;

    use Illuminate\Auth\Events\Login;
    use Illuminate\Auth\Events\Logout;
    use Illuminate\Events\Dispatcher;

    class UserEventSubscriber
    {
        /**
         * 處理用戶登錄事件。
         */
        public function handleUserLogin(Login $event): void {}

        /**
         * 處理用戶退出事件。
         */
        public function handleUserLogout(Logout $event): void {}

        /**
         * 為訂閱者注冊偵聽器。
         */
        public function subscribe(Dispatcher $events): void
        {
            $events->listen(
                Login::class,
                [UserEventSubscriber::class, 'handleUserLogin']
            );

            $events->listen(
                Logout::class,
                [UserEventSubscriber::class, 'handleUserLogout']
            );
        }
    }



如果你的事件偵聽器方法是在訂閱者本身中定義的，你可能會發現從訂閱者的「訂閱」方法返回一組事件和方法名稱會更方便。 Laravel 會在注冊事件監聽器時自動判斷訂閱者的類名：

    <?php

    namespace App\Listeners;

    use Illuminate\Auth\Events\Login;
    use Illuminate\Auth\Events\Logout;
    use Illuminate\Events\Dispatcher;

    class UserEventSubscriber
    {
        /**
         * 處理用戶登錄事件。
         */
        public function handleUserLogin(Login $event): void {}

        /**
         * 處理用戶注銷事件。
         */
        public function handleUserLogout(Logout $event): void {}

        /**
         * 為訂閱者注冊監聽器。
         *
         * @return array<string, string>
         */
        public function subscribe(Dispatcher $events): array
        {
            return [
                Login::class => 'handleUserLogin',
                Logout::class => 'handleUserLogout',
            ];
        }
    }

<a name="registering-event-subscribers"></a>
### 注冊事件訂閱者

編寫訂閱者後，你就可以將其注冊到事件調度程序。 可以使用 `EventServiceProvider` 上的 `$subscribe` 屬性注冊訂閱者。 例如，讓我們將 `UserEventSubscriber` 添加到列表中：

    <?php

    namespace App\Providers;

    use App\Listeners\UserEventSubscriber;
    use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

    class EventServiceProvider extends ServiceProvider
    {
        /**
         * The event listener mappings for the application.
         *
         * @var array
         */
        protected $listen = [
            // ...
        ];

        /**
         * The subscriber classes to register.
         *
         * @var array
         */
        protected $subscribe = [
            UserEventSubscriber::class,
        ];
    }

<a name="testing"></a>
## 測試

當測試分發事件的代碼時，你可能希望指示 Laravel 不要實際執行事件的監聽器，因為監聽器的代碼可以直接和分發相應事件的代碼分開測試。 當然，要測試監聽器本身，你可以實例化一個監聽器實例並直接在測試中調用 handle 方法。



使用 `Event` 門面的 `fake` 方法，你可以阻止偵聽器執行，執行測試代碼，然後使用 `assertDispatched`、`assertNotDispatched` 和 `assertNothingDispatched` 方法斷言你的應用程序分派了哪些事件：

    <?php

    namespace Tests\Feature;

    use App\Events\OrderFailedToShip;
    use App\Events\OrderShipped;
    use Illuminate\Support\Facades\Event;
    use Tests\TestCase;

    class ExampleTest extends TestCase
    {
        /**
         * 測試訂單發貨。
         */
        public function test_orders_can_be_shipped(): void
        {
            Event::fake();

            // 執行訂單發貨...

            // 斷言事件已發送...
            Event::assertDispatched(OrderShipped::class);

            // 斷言一個事件被發送了兩次......
            Event::assertDispatched(OrderShipped::class, 2);

            // 斷言事件未被發送...
            Event::assertNotDispatched(OrderFailedToShip::class);

            // 斷言沒有事件被發送...
            Event::assertNothingDispatched();
        }
    }

你可以將閉包傳遞給 `assertDispatched` 或 `assertNotDispatched` 方法，以斷言已派發的事件通過了給定的「真實性測試」。 如果至少發送了一個通過給定真值測試的事件，則斷言將成功：

    Event::assertDispatched(function (OrderShipped $event) use ($order) {
        return $event->order->id === $order->id;
    });

如果你只想斷言事件偵聽器正在偵聽給定事件，可以使用 `assertListening` 方法：

    Event::assertListening(
        OrderShipped::class,
        SendShipmentNotification::class
    );

> **警告**
> 調用 `Event::fake()` 後，不會執行任何事件偵聽器。 因此，如果你的測試使用依賴於事件的模型工廠，例如在模型的「創建」事件期間創建 UUID，則您應該在使用您的工廠**之後**調用“Event::fake()”。

<a name="faking-a-subset-of-events"></a>
### 偽造一部分事件

如果你只想為一組特定的事件偽造事件監聽器，你可以將它們傳遞給 `fake` 或 `fakeFor` 方法：

    /**
     * 測試訂單流程。
     */
    public function test_orders_can_be_processed(): void
    {
        Event::fake([
            OrderCreated::class,
        ]);

        $order = Order::factory()->create();

        Event::assertDispatched(OrderCreated::class);

        // 其他事件正常發送...
        $order->update([...]);
    }



你可以使用 `except` 方法排除指定事件：

    Event::fake()->except([
        OrderCreated::class,
    ]);

<a name="scoped-event-fakes"></a>
### Fakes 作用域事件

如果你只想為測試的一部分創建事件偵聽器，你可以使用 `fakeFor` 方法：

    <?php

    namespace Tests\Feature;

    use App\Events\OrderCreated;
    use App\Models\Order;
    use Illuminate\Support\Facades\Event;
    use Tests\TestCase;

    class ExampleTest extends TestCase
    {
        /**
         * 測試訂單程序
         */
        public function test_orders_can_be_processed(): void
        {
            $order = Event::fakeFor(function () {
                $order = Order::factory()->create();

                Event::assertDispatched(OrderCreated::class);

                return $order;
            });

            // 事件按正常方式調度，觀察者將會運行...
            $order->update([...]);
        }
    }
