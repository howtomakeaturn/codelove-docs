# 廣播

-   [介紹](#introduction)
-   [服務器端安裝](#server-side-installation)
    -   [配置](#configuration)
    -   [Pusher Channels](#pusher-channels)
    -   [Ably](#ably)
    -   [開源替代品](#open-source-alternatives)
-   [客戶端安裝](#client-side-installation)
    -   [Pusher Channels](#client-pusher-channels)
    -   [Ably](#client-ably)
-   [概念概述](#concept-overview)
    -   [使用示例應用程序](#using-example-application)
-   [定義廣播事件](#defining-broadcast-events)
    -   [廣播名稱](#broadcast-name)
    -   [廣播數據](#broadcast-data)
    -   [廣播隊列](#broadcast-queue)
    -   [廣播條件](#broadcast-conditions)
    -   [廣播和數據庫事務](#broadcasting-and-database-transactions)
-   [授權頻道](#authorizing-channels)
    -   [定義授權路由](#defining-authorization-routes)
    -   [定義授權回調](#defining-authorization-callbacks)
    -   [定義頻道類](#defining-channel-classes)
-   [廣播事件](#broadcasting-events)
    -   [僅發送給其他人](#only-to-others)
    -   [自定義連接](#customizing-the-connection)
-   [接收廣播](#receiving-broadcasts)
    -   [監聽事件](#listening-for-events)
    -   [離開頻道](#leaving-a-channel)
    -   [命名空間](#namespaces)
-   [在場頻道](#presence-channels)
    -   [授權在場頻道](#authorizing-presence-channels)
    -   [加入在場頻道](#joining-presence-channels)
    -   [廣播到在場頻道](#broadcasting-to-presence-channels)
-   [模型廣播](#model-broadcasting)
    -   [模型廣播約定](#model-broadcasting-conventions)
    -   [監聽模型廣播](#listening-for-model-broadcasts)
-   [客戶端事件](#client-events)
-   [通知](#notifications)

<a name="introduction"></a>
## 介紹

在許多現代 Web 應用程序中，WebSockets 用於實現實時的、實時更新的用戶界面。當服務器上的某些數據更新時，通常會發送一條消息到 WebSocket 連接，以由客戶端處理。WebSockets 提供了一種更有效的替代方法，可以連續輪詢應用程序服務器以反映 UI 中應該反映的數據更改。

舉個例子，假設你的應用程序能夠將用戶的數據導出為 CSV 文件並通過電子郵件發送給他們。但是，創建這個 CSV 文件需要幾分鐘的時間，因此你選擇在[隊列任務](/docs/laravel/10.x/queues)中創建和發送 CSV。當 CSV 文件已經創建並發送給用戶後，我們可以使用事件廣播來分發 `App\Events\UserDataExported` 事件，該事件由我們應用程序的 JavaScript 接收。一旦接收到事件，我們可以向用戶顯示消息，告訴他們他們的 CSV 已通過電子郵件發送給他們，而無需刷新頁面。



為了幫助你構建此類特性，Laravel使得在WebSocket連接上“廣播”你的服務端[Laravel事件](/docs/laravel/10.x/events)變得簡單。廣播你的Laravel事件允許你在你的服務端Laravel應用和客戶端JavaScript應用之間共享相同的事件名稱和數據。

廣播背後的核心概念很簡單：客戶端在前端連接到命名通道，而你的Laravel應用在後端向這些通道廣播事件。這些事件可以包含任何你想要向前端提供的其他數據。

<a name="supported-drivers"></a>
#### 支持的驅動程序

默認情況下，Laravel為你提供了兩個服務端廣播驅動程序可供選擇：[Pusher Channels](https://pusher.com/channels) 和 [Ably](https://ably.com/)。但是，社區驅動的包，如 [laravel-websockets](https://beyondco.de/docs/laravel-websockets/getting-started/introduction) 和 [soketi](https://docs.soketi.app/) 提供了不需要商業廣播提供者的其他廣播驅動程序。

> **注意**
> 在深入了解事件廣播之前，請確保已閱讀Laravel的[事件和偵聽器](/docs/laravel/10.x/events)文檔。

<a name="server-side-installation"></a>
## 服務端安裝

為了開始使用Laravel的事件廣播，我們需要在Laravel應用程序中進行一些配置，並安裝一些包。

事件廣播是通過服務端廣播驅動程序實現的，該驅動程序廣播你的Laravel事件，以便Laravel Echo（一個JavaScript庫）可以在瀏覽器客戶端中接收它們。不用擔心 - 我們將逐步介紹安裝過程的每個部分。

<a name="configuration"></a>
### 配置

所有應用程序的事件廣播配置都存儲在`config/broadcasting.php`配置文件中。Laravel支持多個廣播驅動程序：[Pusher Channels](https://pusher.com/channels)、[Redis](/docs/laravel/10.x/redis)和用於本地開發和調試的`log`驅動程序。此外，還包括一個`null`驅動程序，它允許你在測試期間完全禁用廣播。`config/broadcasting.php`配置文件中包含每個驅動程序的配置示例。



<a name="broadcast-service-provider"></a>
#### 廣播服務提供商

在廣播任何事件之前，您首先需要注冊 `App\Providers\BroadcastServiceProvider`。在新的 Laravel 應用程序中，您只需要在 `config/app.php` 配置文件的 `providers` 數組中取消注釋此提供程序即可。這個 `BroadcastServiceProvider` 包含了注冊廣播授權路由和回調所需的代碼。

<a name="queue-configuration"></a>
#### 隊列配置

您還需要配置和運行一個[隊列工作者](/docs/laravel/10.x/queues)。所有事件廣播都是通過排隊的作業完成的，以確保您的應用程序的響應時間不會受到廣播事件的影響。

<a name="pusher-channels"></a>
### Pusher Channels

如果您計劃使用[Pusher Channels](https://pusher.com/channels)廣播您的事件，您應該使用 Composer 包管理器安裝 Pusher Channels PHP SDK：

```shell
composer require pusher/pusher-php-server
```

接下來，您應該在 `config/broadcasting.php` 配置文件中配置 Pusher Channels 憑據。此文件中已經包含了一個示例 Pusher Channels 配置，讓您可以快速指定您的密鑰、密鑰、應用程序 ID。通常，這些值應該通過 `PUSHER_APP_KEY`、`PUSHER_APP_SECRET` 和 `PUSHER_APP_ID`  [環境變量](/docs/laravel/10.x/configuration#environment-configuration) 設置：

```ini
PUSHER_APP_ID=your-pusher-app-id
PUSHER_APP_KEY=your-pusher-key
PUSHER_APP_SECRET=your-pusher-secret
PUSHER_APP_CLUSTER=mt1
```

`config/broadcasting.php` 文件的 `pusher` 配置還允許您指定 Channels 支持的其他 `options`，例如集群。

接下來，您需要在您的 `.env` 文件中將廣播驅動程序更改為 `pusher`：

```ini
BROADCAST_DRIVER=pusher
```



最後，您已經準備好安裝和配置[Laravel Echo](#client-side-installation)，它將在客戶端接收廣播事件。

<a name="pusher-compatible-open-source-alternatives"></a>
#### 開源的Pusher替代品

[laravel-websockets](https://github.com/beyondcode/laravel-websockets)和[soketi](https://docs.soketi.app/)軟件包提供了適用於Laravel的Pusher兼容的WebSocket服務器。這些軟件包允許您利用Laravel廣播的全部功能，而無需商業WebSocket提供程序。有關安裝和使用這些軟件包的更多信息，請參閱我們的[開源替代品文檔](#open-source-alternatives)。

<a name="ably"></a>
### Ably

>**注意** 下面的文檔介紹了如何在“Pusher兼容”模式下使用Ably。然而，Ably團隊推薦並維護一個廣播器和Echo客戶端，能夠利用Ably提供的獨特功能。有關使用Ably維護的驅動程序的更多信息，請[參閱Ably的Laravel廣播器文檔](https://github.com/ably/laravel-broadcaster)。

如果您計劃使用[Ably](https://ably.com/)廣播您的事件，則應使用Composer軟件包管理器安裝Ably PHP SDK：

```shell
composer require ably/ably-php
```

接下來，您應該在`config/broadcasting.php`配置文件中配置您的Ably憑據。該文件已經包含了一個示例Ably配置，允許您快速指定您的密鑰。通常，此值應通過`ABLY_KEY`[環境變量](/docs/laravel/10.x/configuration#environment-configuration)進行設置：

```ini
ABLY_KEY=your-ably-key
```

Next, you will need to change your broadcast driver to `ably` in your `.env` file:

```ini
BROADCAST_DRIVER=ably
```

接下來，您需要在`.env`文件中將廣播驅動程序更改為`ably`：



<a name="open-source-alternatives"></a>
### 開源替代方案

<a name="open-source-alternatives-php"></a>
#### PHP

[laravel-websockets](https://github.com/beyondcode/laravel-websockets) 是一個純 PHP 的，與 Pusher 兼容的 Laravel WebSocket 包。該包允許您充分利用 Laravel 廣播的功能，而無需商業 WebSocket 提供商。有關安裝和使用此包的更多信息，請參閱其[官方文檔](https://beyondco.de/docs/laravel-websockets)。

<a name="open-source-alternatives-node"></a>
#### Node

[Soketi](https://github.com/soketi/soketi) 是一個基於 Node 的，與 Pusher 兼容的 Laravel WebSocket 服務器。在幕後，Soketi 利用 µWebSockets.js 來實現極端的可擴展性和速度。該包允許您充分利用 Laravel 廣播的功能，而無需商業 WebSocket 提供商。有關安裝和使用此包的更多信息，請參閱其[官方文檔](https://docs.soketi.app/)。

<a name="client-side-installation"></a>
## 客戶端安裝

<a name="client-pusher-channels"></a>
### Pusher Channels

[Laravel Echo](https://github.com/laravel/echo) 是一個 JavaScript 庫，可以輕松訂閱通道並監聽由服務器端廣播驅動程序廣播的事件。您可以通過 NPM 包管理器安裝 Echo。在此示例中，我們還將安裝 `pusher-js` 包，因為我們將使用 Pusher Channels 廣播器：

```shell
npm install --save-dev laravel-echo pusher-js
```

安裝 Echo 後，您可以在應用程序的 JavaScript 中創建一個新的 Echo 實例。一個很好的地方是在 Laravel 框架附帶的 `resources/js/bootstrap.js` 文件的底部創建它。默認情況下，該文件中已包含一個示例 Echo 配置 - 您只需取消注釋即可：

```js
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: import.meta.env.VITE_PUSHER_APP_KEY,
    cluster: import.meta.env.VITE_PUSHER_APP_CLUSTER,
    forceTLS: true
});
```



一旦您根據自己的需求取消注釋並調整了 Echo 配置，就可以編譯應用程序的資產：

```shell
npm run dev
```

> **注意**
> 要了解有關編譯應用程序的 JavaScript 資產的更多信息，請參閱 [Vite](/docs/laravel/10.x/vite) 上的文檔。

<a name="using-an-existing-client-instance"></a>
#### 使用現有的客戶端實例

如果您已經有一個預配置的 Pusher Channels 客戶端實例，並希望 Echo 利用它，您可以通過 `client` 配置選項將其傳遞給 Echo：

```js
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

const options = {
    broadcaster: 'pusher',
    key: 'your-pusher-channels-key'
}

window.Echo = new Echo({
    ...options,
    client: new Pusher(options.key, options)
});
```

<a name="client-ably"></a>
### Ably

> **注意**
> 下面的文檔討論如何在“Pusher 兼容性”模式下使用 Ably。但是，Ably 團隊推薦和維護了一個廣播器和 Echo 客戶端，可以利用 Ably 提供的獨特功能。有關使用由 Ably 維護的驅動程序的更多信息，請[查看 Ably 的 Laravel 廣播器文檔](https://github.com/ably/laravel-broadcaster)。

[Laravel Echo](https://github.com/laravel/echo) 是一個 JavaScript 庫，可以輕松訂閱通道並偵聽服務器端廣播驅動程序廣播的事件。您可以通過 NPM 包管理器安裝 Echo。在本示例中，我們還將安裝 `pusher-js` 包。

您可能會想為什麽我們要安裝 `pusher-js` JavaScript 庫，即使我們使用 Ably 來廣播事件。幸運的是，Ably 包括 Pusher 兼容性模式，讓我們可以在客戶端應用程序中使用 Pusher 協議來偵聽事件：

```shell
npm install --save-dev laravel-echo pusher-js
```



**在繼續之前，你應該在你的 Ably 應用設置中啟用 Pusher 協議支持。你可以在你的 Ably 應用設置儀表板的“協議適配器設置”部分中啟用此功能。**

安裝 Echo 後，你可以在應用的 JavaScript 中創建一個新的 Echo 實例。一個很好的地方是在 Laravel 框架附帶的 `resources/js/bootstrap.js` 文件底部。默認情況下，此文件中已包含一個示例 Echo 配置；但是，`bootstrap.js` 文件中的默認配置是為 Pusher 設計的。你可以覆制以下配置來將配置轉換為 Ably：

```js
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: import.meta.env.VITE_ABLY_PUBLIC_KEY,
    wsHost: 'realtime-pusher.ably.io',
    wsPort: 443,
    disableStats: true,
    encrypted: true,
});
```

請注意，我們的 Ably Echo 配置引用了一個 `VITE_ABLY_PUBLIC_KEY` 環境變量。該變量的值應該是你的 Ably 公鑰。你的公鑰是出現在 Ably 密鑰的 `:` 字符之前的部分。

一旦你根據需要取消注釋並調整 Echo 配置，你可以編譯應用的資產：

```shell
npm run dev
```
> **注意**
> 要了解有關編譯應用程序的 JavaScript 資產的更多信息，請參閱 [Vite](/docs/laravel/10.x/vite) 的文檔。

<a name="concept-overview"></a>
## 概念概述

Laravel 的事件廣播允許你使用基於驅動程序的 WebSocket 方法，將服務器端 Laravel 事件廣播到客戶端的 JavaScript 應用程序。目前，Laravel 附帶了 [Pusher Channels](https://pusher.com/channels) 和 [Ably](https://ably.com/) 驅動程序。可以使用 [Laravel Echo](#client-side-installation) JavaScript 包輕松地在客戶端消耗這些事件。



事件通過“通道”廣播，可以指定為公共或私有。任何訪問您的應用程序的用戶都可以訂閱公共頻道，無需進行身份驗證或授權；但是，要訂閱私有頻道，用戶必須經過身份驗證和授權以便監聽該頻道。


> **注意**
> 如果您想探索 Pusher 的開源替代品，請查看[開源替代品](#open-source-alternatives)。

<a name="using-example-application"></a>
### 使用示例應用程序

在深入了解事件廣播的每個組件之前，讓我們使用電子商務店鋪作為示例進行高級概述。

在我們的應用程序中，假設我們有一個頁面，允許用戶查看其訂單的發貨狀態。假設在應用程序處理發貨狀態更新時，將觸發一個 `OrderShipmentStatusUpdated` 事件：

    use App\Events\OrderShipmentStatusUpdated;

    OrderShipmentStatusUpdated::dispatch($order);

<a name="the-shouldbroadcast-interface"></a>
#### ShouldBroadcast 接口

當用戶查看其訂單之一時，我們不希望他們必須刷新頁面才能查看狀態更新。相反，我們希望在創建更新時將更新廣播到應用程序。因此，我們需要使用 `ShouldBroadcast` 接口標記 `OrderShipmentStatusUpdated` 事件。這將指示 Laravel 在觸發事件時廣播該事件：

    <?php

    namespace App\Events;

    use App\Models\Order;
    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\InteractsWithSockets;
    use Illuminate\Broadcasting\PresenceChannel;
    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Queue\SerializesModels;

    class OrderShipmentStatusUpdated implements ShouldBroadcast
    {
        /**
         * The order instance.
         *
         * @var \App\Order
         */
        public $order;
    }



`ShouldBroadcast`接口要求我們的事件定義一個`broadcastOn`方法。該方法負責返回事件應廣播到的頻道。在生成的事件類中已經定義了這個方法的空樁，所以我們只需要填寫它的細節即可。我們只希望訂單的創建者能夠查看狀態更新，因此我們將事件廣播到與訂單相關的私有頻道上：

    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\PrivateChannel;

    /**
     * 獲取事件應該廣播到的頻道。
     */
    public function broadcastOn(): Channel
    {
        return new PrivateChannel('orders.'.$this->order->id);
    }

如果你希望事件廣播到多個頻道，可以返回一個`array`：

    use Illuminate\Broadcasting\PrivateChannel;

    /**
     * 獲取事件應該廣播到的頻道。
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('orders.'.$this->order->id),
            // ...
        ];
    }

<a name="example-application-authorizing-channels"></a>
#### 授權頻道

記住，用戶必須被授權才能監聽私有頻道。我們可以在應用程序的`routes/channels.php`文件中定義頻道授權規則。在這個例子中，我們需要驗證任何試圖監聽私有`orders.1`頻道的用戶是否實際上是訂單的創建者：

    use App\Models\Order;
    use App\Models\User;

    Broadcast::channel('orders.{orderId}', function (User $user, int $orderId) {
        return $user->id === Order::findOrNew($orderId)->user_id;
    });

`channel`方法接受兩個參數：頻道名稱和一個回調函數，該函數返回`true`或`false`，表示用戶是否被授權監聽該頻道。



所有授權回調函數的第一個參數是當前認證的用戶，其余的通配符參數是它們的後續參數。在此示例中，我們使用`{orderId}`占位符來指示頻道名稱的“ID”部分是通配符。

<a name="listening-for-event-broadcasts"></a>
#### 監聽事件廣播

接下來，我們只需要在JavaScript應用程序中監聽事件即可。我們可以使用[Laravel Echo](#client-side-installation)來完成這個過程。首先，我們使用`private`方法訂閱私有頻道。然後，我們可以使用`listen`方法來監聽`OrderShipmentStatusUpdated`事件。默認情況下，廣播事件的所有公共屬性將被包括在廣播事件中：

```js
Echo.private(`orders.${orderId}`)
    .listen('OrderShipmentStatusUpdated', (e) => {
        console.log(e.order);
    });
```

<a name="defining-broadcast-events"></a>
## 定義廣播事件

要通知 Laravel 給定事件應該被廣播，您必須在事件類上實現`Illuminate\Contracts\Broadcasting\ShouldBroadcast`接口。該接口已經被框架生成的所有事件類導入，因此您可以輕松地將其添加到任何事件中。

`ShouldBroadcast`接口要求您實現一個單獨的方法:`broadcastOn`。`broadcastOn`方法應該返回一個頻道或頻道數組，事件應該在這些頻道上廣播。這些頻道應該是`Channel`、`PrivateChannel`或`PresenceChannel`的實例。`Channel`的實例表示任何用戶都可以訂閱的公共頻道，而`PrivateChannel`和`PresenceChannel`表示需要[頻道授權](#authorizing-channels)的私有頻道：

    <?php

    namespace App\Events;

    use App\Models\User;
    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\InteractsWithSockets;
    use Illuminate\Broadcasting\PresenceChannel;
    use Illuminate\Broadcasting\PrivateChannel;
    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Queue\SerializesModels;

    class ServerCreated implements ShouldBroadcast
    {
        use SerializesModels;

        /**
         * 創建一個新的事件實例。
         */
        public function __construct(
            public User $user,
        ) {}

        /**
         * 獲取事件應該廣播到哪些頻道。
         *
         * @return array<int, \Illuminate\Broadcasting\Channel>
         */
        public function broadcastOn(): array
        {
            return [
                new PrivateChannel('user.'.$this->user->id),
            ];
        }
    }



實現 `ShouldBroadcast` 接口後，您只需要像平常一樣[觸發事件](/docs/laravel/10.x/events)。一旦事件被觸發，一個[隊列任務](/docs/laravel/10.x/queues)將自動使用指定的廣播驅動程序廣播該事件。

<a name="broadcast-name"></a>
### 廣播名稱

默認情況下，Laravel將使用事件類名廣播事件。但是，您可以通過在事件上定義 `broadcastAs` 方法來自定義廣播名稱：

    /**
     * 活動的廣播名稱
     */
    public function broadcastAs(): string
    {
        return 'server.created';
    }

如果您使用 `broadcastAs` 方法自定義廣播名稱，則應確保使用前導“.”字符注冊您的偵聽器。這將指示 Echo 不將應用程序的命名空間添加到事件中：

    .listen('.server.created', function (e) {
        ....
    });

<a name="broadcast-data"></a>
### 廣播數據

當廣播事件時，所有 `public` 屬性都將自動序列化並廣播為事件負載，使您能夠從 JavaScript 應用程序中訪問其任何公共數據。例如，如果您的事件具有單個公共 `$user` 屬性，其中包含 Eloquent 模型，則事件的廣播負載將是：

```json
{
    "user": {
        "id": 1,
        "name": "Patrick Stewart"
        ...
    }
}
```

但是，如果您希望更精細地控制廣播負載，則可以向事件中添加 `broadcastWith` 方法。該方法應該返回您希望作為事件負載廣播的數據數組：

    /**
     * 獲取要廣播的數據。
     *
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return ['id' => $this->user->id];
    }

<a name="broadcast-queue"></a>


### 廣播隊列

默認情況下，每個廣播事件都會被放置在您在 `queue.php` 配置文件中指定的默認隊列連接的默認隊列上。您可以通過在事件類上定義 `connection` 和 `queue` 屬性來自定義廣播器使用的隊列連接和名稱：

    /**
     * 廣播事件時要使用的隊列連接的名稱。
     *
     * @var string
     */
    public $connection = 'redis';

    /**
     * 廣播作業要放置在哪個隊列上的名稱。
     *
     * @var string
     */
    public $queue = 'default';

或者，您可以通過在事件上定義一個 `broadcastQueue` 方法來自定義隊列名稱：

    /**
     * 廣播作業放置在其上的隊列的名稱。
     */
    public function broadcastQueue(): string
    {
        return 'default';
    }

如果您想要使用 `sync` 隊列而不是默認的隊列驅動程序來廣播事件，您可以實現 `ShouldBroadcastNow` 接口而不是 `ShouldBroadcast` 接口：

    <?php

    use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;

    class OrderShipmentStatusUpdated implements ShouldBroadcastNow
    {
        // ...
    }

<a name="broadcast-conditions"></a>
### 廣播條件

有時候您只想在給定條件為真時才廣播事件。您可以通過在事件類中添加一個 `broadcastWhen` 方法來定義這些條件：

    /**
     * 確定此事件是否應該廣播。
     */
    public function broadcastWhen(): bool
    {
        return $this->order->value > 100;
    }

<a name="broadcasting-and-database-transactions"></a>
#### 廣播和數據庫事務

當在數據庫事務中分派廣播事件時，它們可能會在數據庫事務提交之前被隊列處理。當這種情況發生時，在數據庫中對模型或數據庫記錄所做的任何更新可能尚未反映在數據庫中。此外，在事務中創建的任何模型或數據庫記錄可能不存在於數據庫中。如果您的事件依賴於這些模型，則在處理廣播事件的作業時可能會出現意外錯誤。



如果您的隊列連接的`after_commit`配置選項設置為`false`，您仍然可以通過在事件類上定義`$afterCommit`屬性來指示特定的廣播事件在所有打開的數據庫事務提交後被調度：

    <?php

    namespace App\Events;

    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Queue\SerializesModels;

    class ServerCreated implements ShouldBroadcast
    {
        use SerializesModels;

        public $afterCommit = true;
    }

> **注意**
> 要了解更多有關解決這些問題的信息，請查閱有關[隊列作業和數據庫事務](https://chat.openai.com/docs/laravel/10.x/queues#jobs-and-database-transactions)的文檔。

<a name="authorizing-channels"></a>
## 授權頻道

私有頻道需要您授權當前已驗證的用戶是否實際上可以監聽該頻道。這可以通過向您的 Laravel 應用程序發送帶有頻道名稱的 HTTP 請求來完成，並允許您的應用程序確定用戶是否可以在該頻道上監聽。當使用[Laravel Echo](#client-side-installation)時，將自動進行授權訂閱私有頻道的 HTTP 請求；但是，您需要定義正確的路由來響應這些請求。

<a name="defining-authorization-routes"></a>
### 定義授權路由

幸運的是，Laravel 可以輕松定義用於響應頻道授權請求的路由。在您的 Laravel 應用程序中包含的`App\Providers\BroadcastServiceProvider`中，您將看到對`Broadcast::routes`方法的調用。此方法將注冊`/broadcasting/auth`路由以處理授權請求：

    Broadcast::routes();

`Broadcast::routes`方法將自動將其路由放置在`web`中間件組中；但是，如果您想自定義分配的屬性，則可以將路由屬性數組傳遞給該方法：

    Broadcast::routes($attributes);



<a name="customizing-the-authorization-endpoint"></a>
#### 自定義授權終點

默認情況下，Echo 將使用 `/broadcasting/auth` 終點來授權頻道訪問。但是，您可以通過將 `authEndpoint` 配置選項傳遞給 Echo 實例來指定自己的授權終點：

```js
window.Echo = new Echo({
    broadcaster: 'pusher',
    // ...
    authEndpoint: '/custom/endpoint/auth'
});
```

<a name="customizing-the-authorization-request"></a>
#### 自定義授權請求

您可以在初始化 Echo 時提供自定義授權器來自定義 Laravel Echo 如何執行授權請求：

```js
window.Echo = new Echo({
    // ...
    authorizer: (channel, options) => {
        return {
            authorize: (socketId, callback) => {
                axios.post('/api/broadcasting/auth', {
                    socket_id: socketId,
                    channel_name: channel.name
                })
                .then(response => {
                    callback(null, response.data);
                })
                .catch(error => {
                    callback(error);
                });
            }
        };
    },
})
```

<a name="defining-authorization-callbacks"></a>
### 定義授權回調函數

接下來，我們需要定義實際確定當前認證用戶是否可以收聽給定頻道的邏輯。這是在您的應用程序中包含的 `routes/channels.php` 文件中完成的。在該文件中，您可以使用 `Broadcast::channel` 方法來注冊頻道授權回調函數：

    use App\Models\User;

    Broadcast::channel('orders.{orderId}', function (User $user, int $orderId) {
        return $user->id === Order::findOrNew($orderId)->user_id;
    });

`channel` 方法接受兩個參數：頻道名稱和一個回調函數，該回調函數返回 `true` 或 `false`，指示用戶是否有權限在頻道上收聽。

所有授權回調函數都接收當前認證用戶作為其第一個參數，任何其他通配符參數作為其後續參數。在此示例中，我們使用 `{orderId}` 占位符來指示頻道名稱的 "ID" 部分是通配符。



您可以使用`channel:list` Artisan命令查看應用程序的廣播授權回調列表：

```shell
php artisan channel:list
```

<a name="authorization-callback-model-binding"></a>
#### 授權回調模型綁定

與HTTP路由一樣，頻道路由也可以利用隱式和顯式的[路由模型綁定](/docs/laravel/10.x/routing#route-model-binding)。例如，您可以請求一個實際的 `Order` 模型實例，而不是接收一個字符串或數字訂單ID：

    use App\Models\Order;
    use App\Models\User;

    Broadcast::channel('orders.{order}', function (User $user, Order $order) {
        return $user->id === $order->user_id;
    });

> **警告**
> 與HTTP路由模型綁定不同，頻道模型綁定不支持自動[隱式模型綁定範圍](/docs/laravel/10.x/routing#implicit-model-binding-scoping)。但是，這很少是問題，因為大多數頻道可以基於單個模型的唯一主鍵進行範圍限制。

<a name="authorization-callback-authentication"></a>
#### 授權回調身份驗證

私有和存在廣播頻道會通過您的應用程序的默認身份驗證保護當前用戶。如果用戶未經過身份驗證，則頻道授權將自動被拒絕，並且不會執行授權回調。但是，您可以分配多個自定義守衛，以根據需要對傳入請求進行身份驗證：

    Broadcast::channel('channel', function () {
        // ...
    }, ['guards' => ['web', 'admin']]);

<a name="defining-channel-classes"></a>
### 定義頻道類

如果您的應用程序正在消耗許多不同的頻道，則您的 `routes/channels.php` 文件可能會變得臃腫。因此，您可以使用頻道類而不是使用閉包來授權頻道。要生成一個頻道類，請使用 `make:channel` Artisan命令。該命令將在 `App/Broadcasting` 目錄中放置一個新的頻道類。

```shell
php artisan make:channel OrderChannel
```



接下來，在您的 `routes/channels.php` 文件中注冊您的頻道：

    use App\Broadcasting\OrderChannel;

    Broadcast::channel('orders.{order}', OrderChannel::class);

最後，您可以將頻道授權邏輯放在頻道類的 `join` 方法中。這個 `join` 方法將包含您通常放置在頻道授權閉包中的相同邏輯。您還可以利用頻道模型綁定：

    <?php

    namespace App\Broadcasting;

    use App\Models\Order;
    use App\Models\User;

    class OrderChannel
    {
        /**
         * 創建一個新的頻道實例。
         */
        public function __construct()
        {
            // ...
        }

        /**
         * 驗證用戶對頻道的訪問權限。
         */
        public function join(User $user, Order $order): array|bool
        {
            return $user->id === $order->user_id;
        }
    }

> **注意**
> 像 Laravel 中的許多其他類一樣，頻道類將自動由[服務容器](/docs/laravel/10.x/container)解析。因此，您可以在其構造函數中聲明頻道所需的任何依賴關系。

<a name="broadcasting-events"></a>
## 廣播事件

一旦您定義了一個事件並使用 `ShouldBroadcast` 接口標記了它，您只需要使用事件的 `dispatch` 方法來觸發事件。事件調度程序會注意到該事件已標記為 `ShouldBroadcast` 接口，並將該事件排隊進行廣播：

    use App\Events\OrderShipmentStatusUpdated;

    OrderShipmentStatusUpdated::dispatch($order);

<a name="only-to-others"></a>
### 只發給其他人

在構建使用事件廣播的應用程序時，您可能需要將事件廣播給給定頻道的所有訂閱者，除了當前用戶。您可以使用 `broadcast` 幫助器和 `toOthers` 方法來實現：

    use App\Events\OrderShipmentStatusUpdated;

    broadcast(new OrderShipmentStatusUpdated($update))->toOthers();



為了更好地理解何時需要使用`toOthers`方法，讓我們想象一個任務列表應用程序，用戶可以通過輸入任務名稱來創建新任務。為了創建任務，您的應用程序可能會向`/task` URL發出請求，該請求廣播任務的創建並返回新任務的JSON表示。當JavaScript應用程序從端點接收到響應時，它可能會直接將新任務插入到其任務列表中，如下所示：

```js
axios.post('/task', task)
    .then((response) => {
        this.tasks.push(response.data);
    });
```

然而，請記住，我們也會廣播任務的創建。如果JavaScript應用程序也在監聽此事件以便將任務添加到任務列表中，那麽您的列表中將有重覆的任務：一個來自端點，一個來自廣播。您可以使用`toOthers`方法來解決這個問題，指示廣播器不要向當前用戶廣播事件。

> **警告**
> 您的事件必須使用`Illuminate\Broadcasting\InteractsWithSockets`特性才能調用`toOthers`方法。

<a name="only-to-others-configuration"></a>
#### 配置

當您初始化一個Laravel Echo實例時，將為連接分配一個套接字ID。如果您正在使用全局的[Axios](https://github.com/mzabriskie/axios)實例從JavaScript應用程序發出HTTP請求，則套接字ID將自動附加到每個傳出請求作為`X-Socket-ID`頭。然後，當您調用`toOthers`方法時，Laravel將從標頭中提取套接字ID，並指示廣播器不向具有該套接字ID的任何連接廣播。



如果您沒有使用全局的 Axios 實例，您需要手動配置 JavaScript 應用程序，以在所有傳出請求中發送 `X-Socket-ID` 標頭。您可以使用 `Echo.socketId` 方法檢索 socket ID：

```js
var socketId = Echo.socketId();
```

<a name="customizing-the-connection"></a>
### 定制連接

如果您的應用程序與多個廣播連接交互，並且您想使用除默認之外的廣播器廣播事件，則可以使用 `via` 方法指定要將事件推送到哪個連接：

    use App\Events\OrderShipmentStatusUpdated;

    broadcast(new OrderShipmentStatusUpdated($update))->via('pusher');

或者，您可以在事件的構造函數中調用 `broadcastVia` 方法指定事件的廣播連接。不過，在這樣做之前，您應該確保事件類使用了 `InteractsWithBroadcasting` trait：

    <?php

    namespace App\Events;

    use Illuminate\Broadcasting\Channel;
    use Illuminate\Broadcasting\InteractsWithBroadcasting;
    use Illuminate\Broadcasting\InteractsWithSockets;
    use Illuminate\Broadcasting\PresenceChannel;
    use Illuminate\Broadcasting\PrivateChannel;
    use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
    use Illuminate\Queue\SerializesModels;

    class OrderShipmentStatusUpdated implements ShouldBroadcast
    {
        use InteractsWithBroadcasting;

        /**
         * 創建一個新的事件實例。
         */
        public function __construct()
        {
            $this->broadcastVia('pusher');
        }
    }

<a name="receiving-broadcasts"></a>
## 接收廣播

<a name="listening-for-events"></a>
### 監聽事件

一旦您 [安裝並實例化了 Laravel Echo](#client-side-installation)，您就可以開始監聽從 Laravel 應用程序廣播的事件。首先使用 `channel` 方法檢索通道實例，然後調用 `listen` 方法來監聽指定的事件：

```js
Echo.channel(`orders.${this.order.id}`)
    .listen('OrderShipmentStatusUpdated', (e) => {
        console.log(e.order.name);
    });
```



如需在私有頻道上監聽事件，請改用`private`方法。您可以繼續鏈式調用`listen`方法以偵聽單個頻道上的多個事件：

```js
Echo.private(`orders.${this.order.id}`)
    .listen(/* ... */)
    .listen(/* ... */)
    .listen(/* ... */);
```

<a name="stop-listening-for-events"></a>
#### 停止監聽事件

如果您想停止偵聽給定事件而不離開頻道，可以使用`stopListening`方法：

```js
Echo.private(`orders.${this.order.id}`)
    .stopListening('OrderShipmentStatusUpdated')
```

<a name="leaving-a-channel"></a>
### 離開頻道

要離開頻道，請在Echo實例上調用`leaveChannel`方法：

```js
Echo.leaveChannel(`orders.${this.order.id}`);
```

如果您想離開頻道以及其關聯的私有和預​​sence頻道，則可以調用`leave`方法：

```js
Echo.leave(`orders.${this.order.id}`);
```
<a name="namespaces"></a>
### 命名空間

您可能已經注意到在上面的示例中，我們沒有指定事件類的完整`App\Events`命名空間。這是因為Echo將自動假定事件位於`App\Events`命名空間中。但是，您可以在實例化Echo時通過傳遞`namespace`配置選項來配置根命名空間：

```js
window.Echo = new Echo({
    broadcaster: 'pusher',
    // ...
    namespace: 'App.Other.Namespace'
});
```

或者，您可以在使用Echo訂閱時使用`。`前綴為事件類添加前綴。這將允許您始終指定完全限定的類名：
```js
Echo.channel('orders')
    .listen('.Namespace\\Event\\Class', (e) => {
        // ...
    });
```

<a name="presence-channels"></a>


## 存在頻道

存在頻道基於私有頻道的安全性，並公開了訂閱頻道用戶的附加功能。這使得構建強大的協作應用程序功能變得容易，例如在另一個用戶正在查看同一頁面時通知用戶，或者列出聊天室的用戶。

<a name="authorizing-presence-channels"></a>
### 授權存在頻道

所有存在頻道也都是私有頻道，因此用戶必須獲得[訪問權限](#authorizing-channels)。但是，在為存在頻道定義授權回調時，如果用戶被授權加入該頻道，您將不會返回`true`。相反，您應該返回有關用戶的數據數組。

授權回調返回的數據將在JavaScript應用程序中的存在頻道事件偵聽器中可用。如果用戶沒有被授權加入存在頻道，則應返回`false`或`null`：

    use App\Models\User;

    Broadcast::channel('chat.{roomId}', function (User $user, int $roomId) {
        if ($user->canJoinRoom($roomId)) {
            return ['id' => $user->id, 'name' => $user->name];
        }
    });

<a name="joining-presence-channels"></a>
### 加入存在頻道

要加入存在頻道，您可以使用Echo的`join`方法。`join`方法將返回一個`PresenceChannel`實現，除了公開`listen`方法外，還允許您訂閱`here`，`joining`和`leaving`事件。

```js
Echo.join(`chat.${roomId}`)
    .here((users) => {
        // ...
    })
    .joining((user) => {
        console.log(user.name);
    })
    .leaving((user) => {
        console.log(user.name);
    })
    .error((error) => {
        console.error(error);
    });
```

成功加入頻道後，`here`回調將立即執行，並接收一個包含所有當前訂閱頻道用戶信息的數組。`joining`方法將在新用戶加入頻道時執行，而`leaving`方法將在用戶離開頻道時執行。當認證端點返回HTTP狀態碼200以外的代碼或存在解析返回的JSON時，將執行`error`方法。



<a name="broadcasting-to-presence-channels"></a>
### 向 Presence 頻道廣播

Presence 頻道可以像公共頻道或私有頻道一樣接收事件。以聊天室為例，我們可能希望將 `NewMessage` 事件廣播到聊天室的 Presence 頻道中。為此，我們將從事件的 `broadcastOn` 方法返回一個 `PresenceChannel` 實例：

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PresenceChannel('room.'.$this->message->room_id),
        ];
    }

與其他事件一樣，您可以使用 `broadcast` 助手和 `toOthers` 方法來排除當前用戶接收廣播：

    broadcast(new NewMessage($message));

    broadcast(new NewMessage($message))->toOthers();

與其他類型的事件一樣，您可以使用 Echo 的 `listen` 方法來監聽發送到 Presence 頻道的事件：

```js
Echo.join(`chat.${roomId}`)
    .here(/* ... */)
    .joining(/* ... */)
    .leaving(/* ... */)
    .listen('NewMessage', (e) => {
        // ...
    });
```

<a name="model-broadcasting"></a>
## 模型廣播

> **警告**
> 在閱讀有關模型廣播的以下文檔之前，我們建議您熟悉 Laravel 模型廣播服務的一般概念以及如何手動創建和監聽廣播事件。

當創建、更新或刪除應用程序的[Eloquent 模型](/docs/laravel/10.x/eloquent)時，通常會廣播事件。當然，這可以通過手動[定義用於 Eloquent 模型狀態更改的自定義事件](/docs/laravel/10.x/eloquent#events)並將這些事件標記為 `ShouldBroadcast` 接口來輕松完成。

但是，如果您沒有在應用程序中使用這些事件進行任何其他用途，則為僅廣播它們的目的創建事件類可能會很麻煩。為解決這個問題，Laravel 允許您指示一個 Eloquent 模型應自動廣播其狀態更改。



開始之前，你的Eloquent模型應該使用`Illuminate\Database\Eloquent\BroadcastsEvents` trait。此外，模型應該定義一個`broadcastOn`方法，該方法將返回一個數組，該數組包含模型事件應該廣播到的頻道：

```php
<?php

namespace App\Models;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Database\Eloquent\BroadcastsEvents;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Post extends Model
{
    use BroadcastsEvents, HasFactory;

    /**
     * 獲取發帖用戶
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * 獲取模型事件應該廣播到的頻道
     *
     * @return array<int, \Illuminate\Broadcasting\Channel|\Illuminate\Database\Eloquent\Model>
     */
    public function broadcastOn(string $event): array
    {
        return [$this, $this->user];
    }
}
```

一旦你的模型包含了這個trait並定義了它的廣播頻道，當模型實例被創建、更新、刪除、移到回收站或還原時，它將自動開始廣播事件。

另外，你可能已經注意到`broadcastOn`方法接收一個字符串`$event`參數。這個參數包含了在模型上發生的事件類型，將具有`created`、`updated`、`deleted`、`trashed`或`restored`的值。通過檢查這個變量的值，你可以確定模型在特定事件上應該廣播到哪些頻道（如果有）：

```php
/**
 * 獲取模型事件應該廣播到的頻道
 *
 * @return array<string, array<int, \Illuminate\Broadcasting\Channel|\Illuminate\Database\Eloquent\Model>>
 */
public function broadcastOn(string $event): array
{
    return match ($event) {
        'deleted' => [],
        default => [$this, $this->user],
    };
}
```



<a name="customizing-model-broadcasting-event-creation"></a>
#### 自定義模型廣播事件創建

有時候，您可能希望自定義 Laravel 創建底層模型廣播事件的方式。您可以通過在您的 Eloquent 模型上定義一個 `newBroadcastableEvent` 方法來實現。這個方法應該返回一個 `Illuminate\Database\Eloquent\BroadcastableModelEventOccurred` 實例：

```php
use Illuminate\Database\Eloquent\BroadcastableModelEventOccurred;

/**
 * 為模型創建一個新的可廣播模型事件。
 */
protected function newBroadcastableEvent(string $event): BroadcastableModelEventOccurred
{
    return (new BroadcastableModelEventOccurred(
        $this, $event
    ))->dontBroadcastToCurrentUser();
}
```

<a name="model-broadcasting-conventions"></a>
### 模型廣播約定

<a name="model-broadcasting-channel-conventions"></a>
#### 頻道約定

您可能已經注意到，在上面的模型示例中，`broadcastOn` 方法沒有返回 `Channel` 實例。相反，它直接返回了 Eloquent 模型。如果您的模型的 `broadcastOn` 方法返回了 Eloquent 模型實例（或者包含在方法返回的數組中），Laravel 將自動使用模型的類名和主鍵標識符作為頻道名稱為模型實例實例化一個私有頻道實例。

因此，`App\Models\User` 模型的 `id` 為 `1` 將被轉換為一個名稱為 `App.Models.User.1` 的 `Illuminate\Broadcasting\PrivateChannel` 實例。當然，除了從模型的 `broadcastOn` 方法返回 Eloquent 模型實例之外，您還可以返回完整的 `Channel` 實例，以完全控制模型的頻道名稱：

```php
use Illuminate\Broadcasting\PrivateChannel;

/**
 * 獲取模型事件應該廣播到的頻道。
 *
 * @return array<int, \Illuminate\Broadcasting\Channel>
 */
public function broadcastOn(string $event): array
{
    return [
        new PrivateChannel('user.'.$this->id)
    ];
}
```

如果您打算從模型的 `broadcastOn` 方法中明確返回一個頻道實例，您可以將一個 Eloquent 模型實例傳遞給頻道的構造函數。這樣做時，Laravel 將使用上面討論的模型頻道約定將 Eloquent 模型轉換為頻道名稱字符串：

```php
return [new Channel($this->user)];
```



如果您需要確定模型的頻道名稱，可以在任何模型實例上調用`broadcastChannel`方法。例如，對於一個 `App\Models\User` 模型，它的 `id` 為 `1`，這個方法將返回字符串 `App.Models.User.1`：

```php
$user->broadcastChannel()
```

<a name="model-broadcasting-event-conventions"></a>
#### 事件約定

由於模型廣播事件與應用程序的 `App\Events` 目錄中的“實際”事件沒有關聯，它們會根據約定分配名稱和負載。 Laravel 的約定是使用模型的類名（不包括命名空間）和觸發廣播的模型事件的名稱來廣播事件。

例如，對 `App\Models\Post` 模型進行更新會將事件廣播到您的客戶端應用程序中，名稱為 `PostUpdated`，負載如下：

```json
{
    "model": {
        "id": 1,
        "title": "My first post"
        ...
    },
    ...
    "socket": "someSocketId",
}
```

刪除 `App\Models\User` 模型將廣播名為 `UserDeleted` 的事件。

如果需要，您可以通過在模型中添加 `broadcastAs` 和 `broadcastWith` 方法來定義自定義廣播名稱和負載。這些方法接收正在發生的模型事件/操作的名稱，允許您為每個模型操作自定義事件的名稱和負載。如果從 `broadcastAs` 方法返回 `null`，則 Laravel 將在廣播事件時使用上述討論的模型廣播事件名稱約定：

```php
/**
 * 模型事件的廣播名稱。
 */
public function broadcastAs(string $event): string|null
{
    return match ($event) {
        'created' => 'post.created',
        default => null,
    };
}

/**
 * 獲取要廣播到模型的數據。
 *
 * @return array<string, mixed>
 */
public function broadcastWith(string $event): array
{
    return match ($event) {
        'created' => ['title' => $this->title],
        default => ['model' => $this],
    };
}
```



<a name="listening-for-model-broadcasts"></a>
### 監聽模型廣播

一旦您將`BroadcastsEvents` trait添加到您的模型中並定義了模型的`broadcastOn`方法，您就可以開始在客戶端應用程序中監聽廣播的模型事件。在開始之前，您可能希望查閱完整的[事件監聽文檔](#listening-for-events)。

首先，使用`private`方法獲取一個通道實例，然後調用`listen`方法來監聽指定的事件。通常，傳遞給`private`方法的通道名稱應該對應於Laravel的[模型廣播規則](#model-broadcasting-conventions)。

獲取通道實例後，您可以使用`listen`方法來監聽特定事件。由於模型廣播事件與應用程序的`App\Events`目錄中的"實際"事件不相關聯，因此必須在事件名稱前加上`.`以表示它不屬於特定的命名空間。每個模型廣播事件都有一個`model`屬性，其中包含模型的所有可廣播屬性：

```js
Echo.private(`App.Models.User.${this.user.id}`)
    .listen('.PostUpdated', (e) => {
        console.log(e.model);
    });
```

<a name="client-events"></a>
## 客戶端事件

> **注意**
> 當使用[Pusher Channels](https://pusher.com/channels)時，您必須在[應用程序儀表板](https://dashboard.pusher.com/)的"應用程序設置"部分中啟用"客戶端事件"選項，以便發送客戶端事件。

有時您可能希望將事件廣播給其他連接的客戶端，而根本不會觸發您的Laravel應用程序。這對於諸如"正在輸入"通知非常有用，其中您希望向應用程序的用戶通知另一個用戶正在給定屏幕上輸入消息。



要廣播客戶端事件，你可以使用 Echo 的 `whisper` 方法：

```js
Echo.private(`chat.${roomId}`)
    .whisper('typing', {
        name: this.user.name
    });
```

要監聽客戶端事件，你可以使用 `listenForWhisper` 方法：

```js
Echo.private(`chat.${roomId}`)
    .listenForWhisper('typing', (e) => {
        console.log(e.name);
    });
```

<a name="notifications"></a>
## 通知

通過將事件廣播與 [notifications](/docs/laravel/10.x/notifications) 配對，你的 JavaScript 應用程序可以在新通知發生時接收它們，而無需刷新頁面。在開始之前，請務必閱讀有關使用 [廣播通知頻道](/docs/laravel/10.x/notifications#broadcast-notifications) 的文檔。

一旦你配置了一個使用廣播頻道的通知，你就可以使用 Echo 的 `notification` 方法來監聽廣播事件。請記住，通道名稱應與接收通知的實體的類名稱匹配：

```js
Echo.private(`App.Models.User.${userId}`)
    .notification((notification) => {
        console.log(notification.type);
    });
```

在這個例子中，所有通過 `broadcast` 通道發送到 `App\Models\User` 實例的通知都會被回調接收。 `App.Models.User.{id}` 頻道的頻道授權回調包含在 Laravel 框架附帶的默認` BroadcastServiceProvider` 中。
