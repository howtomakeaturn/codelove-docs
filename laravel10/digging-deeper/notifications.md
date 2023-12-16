# 消息通知
-   [介紹](#introduction)
-   [生成通知](#generating-notifications)
-   [發送通知](#sending-notifications)
    -   [使用可通知特征](#using-the-notifiable-trait)
    -   [使用通知門面](#using-the-notification-facade)
    -   [指定傳送渠道](#specifying-delivery-channels)
    -   [通知排隊](#queueing-notifications)
    -   [按需通知](#on-demand-notifications)
-   [郵件通知](#mail-notifications)
    -   [格式化郵件消息](#formatting-mail-messages)
    -   [自定義發件人](#customizing-the-sender)
    -   [自定義收件人](#customizing-the-recipient)
    -   [自定義主題](#customizing-the-subject)
    -   [自定義郵件程序](#customizing-the-mailer)
    -   [自定義模板](#customizing-the-templates)
    -   [附件](#mail-attachments)
    -   [添加標簽和元數據](#adding-tags-metadata)
    -   [自定義 Symfony 消息](#customizing-the-symfony-message)
    -   [使用 Mailables](#using-mailables)
    -   [預覽郵件通知](#previewing-mail-notifications)
-   [Markdown 郵件通知](#markdown-mail-notifications)
    -   [生成消息](#generating-the-message)
    -   [撰寫消息](#writing-the-message)
    -   [自定義組件](#customizing-the-components)
-   [數據庫通知](#database-notifications)
    -   [先決條件](#database-prerequisites)
    -   [格式化數據庫通知](#formatting-database-notifications)
    -   [訪問通知](#accessing-the-notifications)
    -   [將通知標記為已讀](#marking-notifications-as-read)
-   [廣播通知](#broadcast-notifications)
    -   [先決條件](#broadcast-prerequisites)
    -   [格式化廣播通知](#formatting-broadcast-notifications)
    -   [監聽通知](#listening-for-notifications)
-   [短信通知](#sms-notifications)
    -   [先決條件](#sms-prerequisites)
    -   [格式化短信通知](#formatting-sms-notifications)
    -   [格式化短代碼通知](#formatting-shortcode-notifications)
    -   [自定義「來源」號碼](#customizing-the-from-number)
    -   [添加客戶參考](#adding-a-client-reference)
    -   [路由短信通知](#routing-sms-notifications)
-   [Slack 通知](#slack-notifications)
    -   [先決條件](#slack-prerequisites)
    -   [格式化 Slack 通知](#formatting-slack-notifications)
    -   [Slack 附件](#slack-attachments)
    -   [路由 Slack 通知](#routing-slack-notifications)
-   [本地化通知](#localizing-notifications)
-   [測試](#testing)
-   [通知事件](#notification-events)
-   [自定義渠道](#custom-channels)

<a name="introduction"></a>
## 介紹

除了支持 [發送電子郵件](/docs/laravel/10.x/mail) 之外，Laravel還提供了支持通過多種傳遞渠道發送通知的功能，包括電子郵件、短信（通過 [Vonage](https://www.vonage.com/communications-apis/)，前身為Nexmo）和 [Slack](https://slack.com/)。此外，已經創建了多種 [社區構建的通知渠道](https://laravel-notification-channels.com/about/#suggesting-a-new-channel)，用於通過數十個不同的渠道發送通知！通知也可以存儲在數據庫中，以便在你的Web界面中顯示。

通常，通知應該是簡短的信息性消息，用於通知用戶應用中發生的事情。例如，如果你正在編寫一個賬單應用，則可以通過郵件和短信頻道向用戶發送一個「支付憑證」通知。

<a name="generating-notifications"></a>
## 創建通知

Laravel 中，通常每個通知都由一個存儲在 `app/Notifications` 目錄下的一個類表示。如果在你的應用中沒有看到這個目錄，不要擔心，當運行 `make:notification` 命令時它將為你創建：

```shell
php artisan make:notification InvoicePaid
```

這個命令會在 `app/Notifications` 目錄下生成一個新的通知類。每個通知類都包含一個 `via` 方法以及一個或多個消息構建的方法比如 `toMail` 或 `toDatabase`，它們會針對特定的渠道把通知轉換為對應的消息。

<a name="sending-notifications"></a>
## 發送通知

<a name="using-the-notifiable-trait"></a>
### 使用 Notifiable Trait

通知可以通過兩種方式發送： 使用 `Notifiable` 特性的 `notify` 方法或使用 `Notification` [facade](/docs/laravel/10.x/facades)。 該 `Notifiable` 特性默認包含在應用程序的 `App\Models\User` 模型中：

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;
    }

此 `notify` 方法需要接收一個通知實例參數：

    use App\Notifications\InvoicePaid;

    $user->notify(new InvoicePaid($invoice));

> **技巧**
> 請記住，你可以在任何模型中使用 `Notifiable` trait。而不僅僅是在 `User` 模型中。

<a name="using-the-notification-facade"></a>
### 使用 Notification Facade

另外，你可以通過 `Notification` [facade](/docs/laravel/10.x/facades) 來發送通知。它主要用在當你需要給多個可接收通知的實體發送的時候，比如給用戶集合發送通知。使用 Facade 發送通知的話，要把可接收通知實例和通知實例傳遞給 `send` 方法：

    use Illuminate\Support\Facades\Notification;

    Notification::send($users, new InvoicePaid($invoice));

你也可以使用 `sendNow` 方法立即發送通知。即使通知實現了 `ShouldQueue` 接口，該方法也會立即發送通知：

    Notification::sendNow($developers, new DeploymentCompleted($deployment));

<a name="specifying-delivery-channels"></a>
### 發送指定頻道

每個通知類都有一個 `via` 方法，用於確定將在哪些通道上傳遞通知。通知可以在 `mail`、`database`、`broadcast`、`vonage` 和 `slack` 頻道上發送。

> **提示**
> 如果你想使用其他的頻道，比如 Telegram 或者 Pusher，你可以去看下社區驅動的 [Laravel 通知頻道網站](http://laravel-notification-channels.com).

`via` 方法接收一個 `$notifiable` 實例，這個實例將是通知實際發送到的類的實例。你可以用 `$notifiable` 來決定這個通知用哪些頻道來發送：

    /**
     * 獲取通知發送頻道。
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return $notifiable->prefers_sms ? ['vonage'] : ['mail', 'database'];
    }

<a name="queueing-notifications"></a>
### 通知隊列化

> **注意**
> 使用通知隊列前需要配置隊列並 [開啟一個隊列任務](/docs/laravel/10.x/queues)。

發送通知可能是耗時的，尤其是通道需要調用額外的 API 來傳輸通知。為了加速應用的響應時間，可以將通知推送到隊列中異步發送，而要實現推送通知到隊列，可以讓對應通知類實現 `ShouldQueue` 接口並使用 `Queueable` trait。如果通知類是通過 make:notification 命令生成的，那麽該接口和 trait 已經默認導入，你可以快速將它們添加到通知類：

    <?php

    namespace App\Notifications;

    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Notifications\Notification;

    class InvoicePaid extends Notification implements ShouldQueue
    {
        use Queueable;

        // ...
    }

一旦將 `ShouldQueue` 接口添加到你的通知中，你就可以發送通知。 Laravel 將檢測類上的 `ShouldQueue` 接口並自動排隊發送通知：

    $user->notify(new InvoicePaid($invoice));

排隊通知時，將為每個收件人和頻道組合創建一個排隊的作業。比如，如果你的通知有三個收件人和兩個頻道，則六個作業將被分配到隊列中。

<a name="delaying-notifications"></a>
#### 延遲通知

如果你需要延遲發送消息通知, 你可以在你的消息通知實例上添加 `delay` 方法:

    $delay = now()->addMinutes(10);

    $user->notify((new InvoicePaid($invoice))->delay($delay));

<a name="delaying-notifications-per-channel"></a>
#### 多個通道的延遲通知

將一個數組傳遞給 `delay` 方法來指定特定通道的延遲時間:

    $user->notify((new InvoicePaid($invoice))->delay([
        'mail' => now()->addMinutes(5),
        'sms' => now()->addMinutes(10),
    ]));

或者，你可以在通知類本身上定義一個 `withDelay` 方法。 `withDelay` 方法會返回包含通道名稱和延遲值的數組:

    /**
     * 確定通知的傳遞延遲.
     *
     * @return array<string, \Illuminate\Support\Carbon>
     */
    public function withDelay(object $notifiable): array
    {
        return [
            'mail' => now()->addMinutes(5),
            'sms' => now()->addMinutes(10),
        ];
    }

<a name="customizing-the-notification-queue-connection"></a>
#### 自定義消息通知隊列連接

默認情況下，排隊的消息通知將使用應用程序的默認隊列連接進行排隊。如果你想指定一個不同的連接用於特定的通知，你可以在通知類上定義一個 `$connection` 屬性:

    /**
     * 排隊通知時要使用的隊列連接的名稱.
     *
     * @var string
     */
    public $connection = 'redis';

或者，如果你想為每個通知通道都指定一個特定的隊列連接，你可以在你的通知上定義一個 `viaConnections` 方法。這個方法應該返回一個通道名稱 / 隊列連接名稱的數組。

    /**
     * 定義每個通知通道應該使用哪個連接。
     *
     * @return array<string, string>
     */
    public function viaConnections(): array
    {
        return [
            'mail' => 'redis',
            'database' => 'sync',
        ];
    }

<a name="customizing-notification-channel-queues"></a>
#### 自定義通知通道隊列

如果你想為每個通知通道指定一個特定的隊列，你可以在你的通知上定義一個 `viaQueues` 。 此方法應返回通道名稱 / 隊列名稱對的數組：

    /**
     * 定義每個通知通道應使用哪條隊列。
     *
     * @return array<string, string>
     */
    public function viaQueues(): array
    {
        return [
            'mail' => 'mail-queue',
            'slack' => 'slack-queue',
        ];
    }

<a name="queued-notifications-and-database-transactions"></a>
#### 隊列通知 & 數據庫事務

當隊列通知在數據庫事務中被分發時，它們可能在數據庫事務提交之前被隊列處理。發生這種情況時，你在數據庫事務期間對模型或數據庫記錄所做的任何更新可能尚未反映在數據庫中。甚至，在事務中創建的任何模型或數據庫記錄可能不存在於數據庫中。如果你的通知依賴於這些模型，那麽在處理發送隊列通知時可能會發生意外錯誤。

如果你的隊列連接的 `after_commit` 配置選項設置為 `false`，你仍然可以通過在發送通知時調用 `afterCommit` 方法來指示應在提交所有打開的數據庫事務後發送特定的排隊通知：

    use App\Notifications\InvoicePaid;

    $user->notify((new InvoicePaid($invoice))->afterCommit());

或者，你可以從通知的構造函數調用 `afterCommit` 方法：

```
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class InvoicePaid extends Notification implements ShouldQueue
{
    use Queueable;

    /**
     * 創建一個新的通知通知實例。
     */
    public function __construct()
    {
        $this->afterCommit();
    }
}
```

> **注意**
> 要了解更多解決這些問題的方法，請查閱有關隊列作業和 [數據庫事務](/docs/laravel/10.x/queuesmd#jobs-and-database-transactions) 的文檔。

<a name="determining-if-the-queued-notification-should-be-sent"></a>
#### 確定是否發送排隊的通知

在將排隊的通知分派到後台處理的隊列之後，它通常會被隊列工作進程接受並發送給其目標收件人。

然而，如果你想要在隊列工作進程處理後最終確定是否發送排隊的通知，你可以在通知類上定義一個 `shouldSend` 方法。如果此方法返回 `false`，則通知不會被發送：

    /**
     * 定義通知是否應該被發送。
     */
    public function shouldSend(object $notifiable, string $channel): bool
    {
        return $this->invoice->isPaid();
    }

<a name="on-demand-notifications"></a>
### 按需通知

有時你需要向一些不屬於你應用程序的「用戶」發送通知。使用 `Notification` 門面的 `route` 方法，你可以在發送通知之前指定即時的通知路由信息：

    use Illuminate\Broadcasting\Channel;
    use Illuminate\Support\Facades\Notification;

    Notification::route('mail', 'taylor@example.com')
                ->route('vonage', '5555555555')
                ->route('slack', 'https://hooks.slack.com/services/...')
                ->route('broadcast', [new Channel('channel-name')])
                ->notify(new InvoicePaid($invoice));

如果你想在向 `mail` 路由發送通知時指定收件人，你可以提供一個數組
電子郵件地址作為鍵，名字作為值。

    Notification::route('mail', [
        'barrett@example.com' => 'Barrett Blair',
    ])->notify(new InvoicePaid($invoice));

<a name="mail-notifications"></a>
## 郵件通知

<a name="formatting-mail-messages"></a>
### 格式化郵件

如果一個通知支持以電子郵件的形式發送，你應該在通知類中定義一個 `toMail` 方法。這個方法將接收一個 `$notifiable` 實體，並應該返回一個`Illuminate\Notifications\Messages\MailMessage` 實例。

`MailMessage` 類包含一些簡單的方法來幫助你建立事務性的電子郵件信息。郵件信息可能包含幾行文字以及一個「操作」。讓我們來看看一個 `toMail` 方法的例子。

    /**
     * 獲取通知的郵件表示形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        $url = url('/invoice/'.$this->invoice->id);

        return (new MailMessage)
                    ->greeting('你好!')
                    ->line('你的一張發票已經付款了！')
                    ->lineIf($this->amount > 0, "支出金額: {$this->amount}")
                    ->action('查看發票', $url)
                    ->line('感謝你使用我們的應用程序！');
    }

> **注意**
> 注意我們在 `toMail` 方法中使用 `$this->invoice->id`。你可以在通知的構造函數中傳遞任何你的通知需要生成的信息數據。

在這個例子中，我們注冊了一個問候語、一行文字、一個操作，然後是另一行文字。`MailMessage` 對象所提供的這些方法使得郵件的格式化變得簡單而快速。然後，郵件通道將把信息組件轉換封裝成一個漂亮的、響應式的HTML電子郵件模板，並有一個純文本對應。
下面是一個由 `mail` 通道生成的電子郵件的例子。

<img src="https://laravel.com/img/docs/notification-example-2.png">

> **注意**
> 當發送郵件通知時，請確保在你的 `config/app.php` 配置文件中設置 `name` 配置選項。
這個值將在你的郵件通知信息的標題和頁腳中使用。

<a name="error-messages"></a>
#### 錯誤消息

一些通知會通知用戶錯誤，比如支付失敗的發票。你可以通過在構建消息時調用 `error` 方法來指示郵件消息是關於錯誤的。當在郵件消息上使用 `error` 方法時，操作按鈕將會是紅色而不是黑色：

    /**
     * 獲取通知的郵件表示形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->error()
                    ->subject('發票支付失敗')
                    ->line('...');
    }

<a name="other-mail-notification-formatting-options"></a>
#### 其他郵件通知格式選項
你可以使用 `view` 方法來指定應用於呈現通知電子郵件的自定義模板，而不是在通知類中定義文本「行」：

    /**
     * 獲取通知的郵件表現形式
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)->view(
            'emails.name', ['invoice' => $this->invoice]
        );
    }

你可以通過將視圖名稱作為數組的第二個元素傳遞給 `view` 方法來指定郵件消息的純文本視圖：

    /**
     * 獲取通知的郵件表現形式
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)->view(
            ['emails.name.html', 'emails.name.plain'],
            ['invoice' => $this->invoice]
        );
    }

<a name="customizing-the-sender"></a>
### 自定義發件人

默認情況下，電子郵件的發件人/寄件人地址在 `config/mail.php` 配置文件中定義。但是，你可以使用 `from` 方法為特定的通知指定發件人地址：

    /**
     * 獲取通知的郵件表現形式
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->from('barrett@example.com', 'Barrett Blair')
                    ->line('...');
    }

<a name="customizing-the-recipient"></a>
### 自定義收件人

當通過 `mail` 通道發送通知時，通知系統將自動查找可通知實體的 `email` 屬性。你可以通過在可通知實體上定義 `routeNotificationForMail` 方法來自定義用於傳遞通知的電子郵件地址：

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Notifications\Notification;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * 路由郵件通道的通知。
         *
         * @return  array<string, string>|string
         */
        public function routeNotificationForMail(Notification $notification): array|string
        {
            // 只返回電子郵件地址...
            return $this->email_address;

            // 返回電子郵件地址和姓名...
            return [$this->email_address => $this->name];
        }
    }

<a name="customizing-the-subject"></a>
### 自定義主題

默認情況下，郵件的主題是通知類的類名格式化為「標題案例」（Title Case）。因此，如果你的通知類命名為 `InvoicePaid`，則郵件的主題將是 `Invoice Paid`。如果你想為消息指定不同的主題，可以在構建消息時調用 `subject` 方法：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->subject('通知標題')
                    ->line('...');
    }

<a name="customizing-the-mailer"></a>
### 自定義郵件程序

默認情況下，郵件通知將使用 `config/mail.php` 配置文件中定義的默認郵件程序進行發送。但是，你可以在運行時通過在構建消息時調用 `mailer` 方法來指定不同的郵件程序：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->mailer('postmark')
                    ->line('...');
    }

<a name="customizing-the-templates"></a>
### 自定義模板

你可以通過發布通知包的資源來修改郵件通知使用的 HTML 和純文本模板。運行此命令後，郵件通知模板將位於 `resources/views/vendor/notifications` 目錄中：

```shell
php artisan vendor:publish --tag=laravel-notifications
```

<a name="mail-attachments"></a>
### 附件

要在電子郵件通知中添加附件，可以在構建消息時使用 `attach` 方法。`attach` 方法接受文件的絕對路徑作為其第一個參數：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('你好!')
                    ->attach('/path/to/file');
    }

> **注意**
> 通知郵件消息提供的 `attach` 方法還接受 [可附加對象](/docs/laravel/10.x/mailmd#attachable-objects)。請查閱全面的 [可附加對象](/docs/laravel/10.x/mailmd#attachable-objects) 文檔以了解更多信息。

當附加文件到消息時，你還可以通過將 `array` 作為 `attach` 方法的第二個參數來指定顯示名稱和/或 MIME 類型：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('你好!')
                    ->attach('/path/to/file', [
                        'as' => 'name.pdf',
                        'mime' => 'application/pdf',
                    ]);
    }

與在可郵寄對象中附加文件不同，你不能使用 `attachFromStorage` 直接從存儲磁盤附加文件。相反，你應該使用 `attach` 方法，並提供存儲磁盤上文件的絕對路徑。或者，你可以從 `toMail` 方法中返回一個 [可郵寄對象](/docs/laravel/10.x/mailmd#generating-mailables)：

    use App\Mail\InvoicePaid as InvoicePaidMailable;

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): Mailable
    {
        return (new InvoicePaidMailable($this->invoice))
                    ->to($notifiable->email)
                    ->attachFromStorage('/path/to/file');
    }



必要時，可以使用 `attachMany` 方法將多個文件附加到消息中：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('你好!')
                    ->attachMany([
                        '/path/to/forge.svg',
                        '/path/to/vapor.svg' => [
                            'as' => 'Logo.svg',
                            'mime' => 'image/svg+xml',
                        ],
                    ]);
    }

<a name="raw-data-attachments"></a>
#### 原始數據附件

`attachData` 方法可以用於將原始字節數組附加為附件。在調用 `attachData` 方法時，應提供應分配給附件的文件名：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('你好!')
                    ->attachData($this->pdf, 'name.pdf', [
                        'mime' => 'application/pdf',
                    ]);
    }

<a name="adding-tags-metadata"></a>
### 添加標簽和元數據

一些第三方電子郵件提供商（如 Mailgun 和 Postmark）支持消息「標簽」和「元數據」，可用於分組和跟蹤應用程序發送的電子郵件。可以通過 `tag` 和 `metadata` 方法將標簽和元數據添加到電子郵件消息中：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->greeting('評論點讚！')
                    ->tag('點讚')
                    ->metadata('comment_id', $this->comment->id);
    }

如果你的應用程序使用 Mailgun 驅動程序，則可以查閱 Mailgun 的文檔以獲取有關 [標簽](https://documentation.mailgun.com/en/latest/user_manual.html#tagging-1) 和 [元數據](https://documentation.mailgun.com/en/latest/user_manual.html#attaching-data-to-messages) 的更多信息。同樣，也可以參考 Postmark 文檔了解他們對 [標簽](https://postmarkapp.com/blog/tags-support-for-smtp) 和 [元數據](https://postmarkapp.com/support/article/1125-custom-metadata-faq) 的支持。


如果你的應用程序使用 Amazon SES 發送電子郵件，則應使用 `metadata` 方法將 [SES 「標簽」](https://docs.aws.amazon.com/ses/latest/APIReference/API_MessageTag.html)附加到消息。
<a name="customizing-the-symfony-message"></a>
### 自定義 Symfony 消息

`MailMessage`類的`withSymfonyMessage`方法允許你注冊一個閉包，在發送消息之前將調用Symfony Message實例。這給你在傳遞消息之前有深度自定義消息的機會：

    use Symfony\Component\Mime\Email;

    /**
     * 獲取通知的郵件表示形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->withSymfonyMessage(function (Email $message) {
                        $message->getHeaders()->addTextHeader(
                            'Custom-Header', 'Header Value'
                        );
                    });
    }

<a name="using-mailables"></a>
### 使用可郵寄對象

如果需要，你可以從通知的 `toMail` 方法返回完整的 [mailable 對象](/docs/laravel/10.x/mail)。當返回 `Mailable` 而不是 `MailMessage` 時，你需要使用可郵寄對象的 `to` 方法指定消息接收者：

    use App\Mail\InvoicePaid as InvoicePaidMailable;
    use Illuminate\Mail\Mailable;

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): Mailable
    {
        return (new InvoicePaidMailable($this->invoice))
                    ->to($notifiable->email);
    }

<a name="mailables-and-on-demand-notifications"></a>
#### 可郵寄對象和按需通知

如果你正在發送[按需通知](#on-demand-notifications)，則提供給`toMail`方法的`$notifiable`實例將是`Illuminate\Notifications\AnonymousNotifiable`的一個實例，它提供了一個`routeNotificationFor`方法，該方法可用於檢索應將按需通知發送到的電子郵件地址：

    use App\Mail\InvoicePaid as InvoicePaidMailable;
    use Illuminate\Notifications\AnonymousNotifiable;
    use Illuminate\Mail\Mailable;

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): Mailable
    {
        $address = $notifiable instanceof AnonymousNotifiable
                ? $notifiable->routeNotificationFor('mail')
                : $notifiable->email;

        return (new InvoicePaidMailable($this->invoice))
                    ->to($address);
    }

<a name="previewing-mail-notifications"></a>
### 預覽郵件通知

設計郵件通知模板時，可以像典型的 Blade 模板一樣在瀏覽器中快速預覽呈現的郵件消息。出於這個原因，Laravel 允許你直接從路由閉包或控制器返回由郵件通知生成的任何郵件消息。當返回一個 `MailMessage` 時，它將在瀏覽器中呈現和顯示，讓你可以快速預覽其設計，無需將其發送到實際的電子郵件地址：

    use App\Models\Invoice;
    use App\Notifications\InvoicePaid;

    Route::get('/notification', function () {
        $invoice = Invoice::find(1);

        return (new InvoicePaid($invoice))
                    ->toMail($invoice->user);
    });

<a name="markdown-mail-notifications"></a>
## Markdown 郵件通知

Markdown 郵件通知允許你利用郵件通知的預構建模板，同時為你提供編寫更長、定制化消息的自由。由於這些消息是用 Markdown 寫的，因此 Laravel 能夠為消息呈現漂亮、響應式的 HTML 模板，同時還會自動生成一個純文本的副本。

<a name="generating-the-message"></a>
### 生成消息

要生成具有相應 Markdown 模板的通知，可以使用 `make:notification` Artisan 命令的 `--markdown` 選項：

```shell
php artisan make:notification InvoicePaid --markdown=mail.invoice.paid
```

與所有其他郵件通知一樣，使用 Markdown 模板的通知應該在其通知類上定義一個 `toMail` 方法。但是，不要使用 `line` 和 `action` 方法構建通知，而是使用 `markdown` 方法指定應該使用的 Markdown 模板的名稱。你希望提供給模板的數據數組可以作為該方法的第二個參數傳遞：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        $url = url('/invoice/'.$this->invoice->id);

        return (new MailMessage)
                    ->subject('發票支付')
                    ->markdown('mail.invoice.paid', ['url' => $url]);
    }

<a name="writing-the-message"></a>
### 編寫消息

Markdown 郵件通知使用 Blade 組件和 Markdown 語法的組合，可以讓你在利用 Laravel 的預構建通知組件的同時，輕松構建通知：

```blade
<x-mail::message>
# 發票支付

你的發票已支付!

<x-mail::button :url="$url">
查看發票
</x-mail::button>

謝謝，<br>
{{ config('app.name') }}
</x-mail::message>
```

<a name="button-component"></a>
#### Button 組件

Button 組件會呈現一個居中的按鈕鏈接。該組件接受兩個參數，`url` 和一個可選的 `color`。支持的顏色有 `primary`、`green` 和 `red`。你可以在通知中添加任意數量的 Button 組件：

```blade
<x-mail::button :url="$url" color="green">
查看發票
</x-mail::button>
```

<a name="panel-component"></a>
#### Panel 組件
Panel 組件會在通知中呈現給定的文本塊，並在面板中以稍微不同的背景顏色呈現。這讓你可以引起讀者對特定文本塊的注意：

```blade
<x-mail::panel>
這是面板內容。
</x-mail::panel>
```

<a name="table-component"></a>
#### Table 組件
Table 組件允許你將 Markdown 表格轉換為 HTML 表格。該組件接受 Markdown 表格作為其內容。可以使用默認的 Markdown 表格對齊語法來支持表格列對齊：

```blade
<x-mail::table>
| Laravel       | Table         | Example  |
| ------------- |:-------------:| --------:|
| Col 2 is      | Centered      | $10      |
| Col 3 is      | Right-Aligned | $20      |
</x-mail::table>
```

<a name="customizing-the-components"></a>
### 定制組件
你可以將所有的 Markdown 通知組件導出到自己的應用程序進行定制。要導出組件，請使用 `vendor:publish` Artisan 命令來發布 `laravel-mail` 資源標記：


這個命令會將 Markdown 郵件組件發布到 `resources/views/vendor/mail` 目錄下。`mail` 目錄將包含一個 `html` 和一個 `text` 目錄，每個目錄都包含其可用組件的各自表示形式。你可以自由地按照自己的喜好定制這些組件。

<a name="customizing-the-css"></a>
#### 定制 CSS 樣式

在導出組件之後，`resources/views/vendor/mail/html/themes` 目錄將包含一個 `default.css` 文件。你可以在此文件中自定義 CSS 樣式，你的樣式將自動被內聯到 Markdown 通知的 HTML 表示中。

如果你想為 Laravel 的 Markdown 組件構建一個全新的主題，可以在 `html/themes` 目錄中放置一個 CSS 文件。命名並保存 CSS 文件後，更新 `mail` 配置文件的 `theme` 選項以匹配你的新主題的名稱。

要為單個通知自定義主題，可以在構建通知的郵件消息時調用 `theme` 方法。`theme` 方法接受應該在發送通知時使用的主題名稱：

    /**
     * 獲取通知的郵件表現形式。
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->theme('發票')
                    ->subject('發票支付')
                    ->markdown('mail.invoice.paid', ['url' => $url]);
    }

<a name="database-notifications"></a>
## 數據庫通知

<a name="database-prerequisites"></a>
### 前提條件

`database` 通知渠道將通知信息存儲在一個數據庫表中。該表將包含通知類型以及描述通知的 JSON 數據結構等信息。


你可以查詢該表，在你的應用程序用戶界面中顯示通知。但是，在此之前，你需要創建一個數據庫表來保存你的通知。你可以使用 `notifications:table` 命令生成一個適當的表模式的 [遷移](/docs/laravel/10.x/migrations)：

```shell
php artisan notifications:table

php artisan migrate
```

<a name="formatting-database-notifications"></a>
### 格式化數據庫通知

如果一個通知支持被存儲在一個數據庫表中，你應該在通知類上定義一個 `toDatabase` 或 `toArray` 方法。這個方法將接收一個 `$notifiable` 實體，並應該返回一個普通的 PHP 數組。返回的數組將被編碼為 JSON，並存儲在你的 `notifications` 表的 `data` 列中。讓我們看一個 `toArray` 方法的例子：

    /**
     * 獲取通知的數組表示形式。
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'invoice_id' => $this->invoice->id,
            'amount' => $this->invoice->amount,
        ];
    }

<a name="todatabase-vs-toarray"></a>
#### `toDatabase` Vs. `toArray`

`toArray` 方法也被 `broadcast` 頻道用來確定要廣播到你的 JavaScript 前端的數據。如果你想為 `database` 和 `broadcast` 頻道定義兩個不同的數組表示形式，你應該定義一個 `toDatabase` 方法，而不是一個 `toArray` 方法。

<a name="accessing-the-notifications"></a>
### 訪問通知

一旦通知被存儲在數據庫中，你需要一個方便的方式從你的可通知實體中訪問它們。`Illuminate\Notifications\Notifiable` trait 包含在 Laravel 的默認 `App\Models\User` 模型中，它包括一個 `notifications` [Eloquent 關聯](/docs/laravel/10.x/eloquent-relationships)，返回實體的通知。要獲取通知，你可以像訪問任何其他 Eloquent 關系一樣訪問此方法。默認情況下，通知將按照 `created_at` 時間戳排序，最新的通知位於集合的開頭：

    $user = App\Models\User::find(1);

    foreach ($user->notifications as $notification) {
        echo $notification->type;
    }

如果你想要只檢索「未讀」的通知，你可以使用 `unreadNotifications` 關系。同樣，這些通知將按照 `created_at` 時間戳排序，最新的通知位於集合的開頭：

    $user = App\Models\User::find(1);

    foreach ($user->unreadNotifications as $notification) {
        echo $notification->type;
    }

> **注意**
> 要從你的 JavaScript 客戶端訪問你的通知，你應該為你的應用程序定義一個通知控制器，該控制器返回一個可通知實體的通知，如當前用戶。然後，你可以從你的 JavaScript 客戶端向該控制器的 URL 發送 HTTP 請求。

<a name="marking-notifications-as-read"></a>
### 將通知標記為已讀

通常，當用戶查看通知時，你希望將通知標記為「已讀」。`Illuminate\Notifications\Notifiable` trait 提供了一個 `markAsRead` 方法，該方法將更新通知的數據庫記錄上的 `read_at` 列：

    $user = App\Models\User::find(1);

    foreach ($user->unreadNotifications as $notification) {
        $notification->markAsRead();
    }

然而，你可以直接在通知集合上使用 `markAsRead` 方法，而不是遍歷每個通知：

    $user->unreadNotifications->markAsRead();

你也可以使用批量更新查詢將所有通知標記為已讀而不必從數據庫中檢索它們：

    $user = App\Models\User::find(1);

    $user->unreadNotifications()->update(['read_at' => now()]);

你可以使用 `delete` 方法將通知刪除並從表中完全移除：

    $user->notifications()->delete();

<a name="broadcast-notifications"></a>
## 廣播通知

<a name="broadcast-prerequisites"></a>
### 前提條件

在廣播通知之前，你應該配置並熟悉 Laravel 的 [事件廣播](/docs/laravel/10.x/broadcasting) 服務。事件廣播提供了一種從你的 JavaScript 前端響應服務器端 Laravel 事件的方法。

<a name="formatting-broadcast-notifications"></a>
### 格式化廣播通知

`broadcast` 頻道使用 Laravel 的 [事件廣播](/docs/laravel/10.x/broadcasting) 服務來廣播通知，允許你的 JavaScript 前端實時捕獲通知。如果通知支持廣播，你可以在通知類上定義一個 `toBroadcast` 方法。該方法將接收一個 `$notifiable` 實體，並應該返回一個 `BroadcastMessage` 實例。如果 `toBroadcast` 方法不存在，則將使用 `toArray` 方法來收集應該廣播的數據。返回的數據將被編碼為 JSON 並廣播到你的 JavaScript 前端。讓我們看一個 `toBroadcast` 方法的示例：

    use Illuminate\Notifications\Messages\BroadcastMessage;

    /**
     * 獲取通知的可廣播表示形式。
     */
    public function toBroadcast(object $notifiable): BroadcastMessage
    {
        return new BroadcastMessage([
            'invoice_id' => $this->invoice->id,
            'amount' => $this->invoice->amount,
        ]);
    }

<a name="broadcast-queue-configuration"></a>
#### 廣播隊列配置

所有廣播通知都會被排隊等待廣播。如果你想配置用於排隊廣播操作的隊列連接或隊列名稱，你可以使用 `BroadcastMessage` 的 `onConnection` 和 `onQueue` 方法：

    return (new BroadcastMessage($data))
                    ->onConnection('sqs')
                    ->onQueue('broadcasts');

<a name="customizing-the-notification-type"></a>
#### 自定義通知類型

除了你指定的數據之外，所有廣播通知還包含一個 `type` 字段，其中包含通知的完整類名。如果你想要自定義通知的 `type`，可以在通知類上定義一個 `broadcastType` 方法：

    /**
     * 獲取正在廣播的通知類型。
     */
    public function broadcastType(): string
    {
        return 'broadcast.message';
    }

<a name="listening-for-notifications"></a>
### 監聽通知

通知會以 `{notifiable}.{id}` 的格式在一個私有頻道上廣播。因此，如果你向一個 ID 為 `1` 的 `App\Models\User` 實例發送通知，通知將在 `App.Models.User.1` 私有頻道上廣播。當使用 [Laravel Echo](/docs/laravel/10.x/broadcastingmd#client-side-installation) 時，你可以使用 `notification` 方法輕松地在頻道上監聽通知：

    Echo.private('App.Models.User.' + userId)
        .notification((notification) => {
            console.log(notification.type);
        });

<a name="customizing-the-notification-channel"></a>
#### 自定義通知頻道

如果你想自定義實體的廣播通知在哪個頻道上廣播，可以在可通知實體上定義一個 `receivesBroadcastNotificationsOn` 方法：

    <?php

    namespace App\Models;

    use Illuminate\Broadcasting\PrivateChannel;
    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * 用戶接收通知廣播的頻道。
         */
        public function receivesBroadcastNotificationsOn(): string
        {
            return 'users.'.$this->id;
        }
    }

<a name="sms-notifications"></a>
## 短信通知

<a name="sms-prerequisites"></a>
### 先決條件

Laravel 中發送短信通知是由 [Vonage](https://www.vonage.com/)（之前稱為 Nexmo）驅動的。在通過 Vonage 發送通知之前，你需要安裝 `laravel/vonage-notification-channel` 和 `guzzlehttp/guzzle` 包：

    composer require laravel/vonage-notification-channel guzzlehttp/guzzle

該包包括一個 [配置文件](https://github.com/laravel/vonage-notification-channel/blob/3.x/config/vonage.php)。但是，你不需要將此配置文件導出到自己的應用程序。你可以簡單地使用 `VONAGE_KEY` 和 `VONAGE_SECRET` 環境變量來定義 Vonage 的公共和私有密鑰。

定義好密鑰後，你可以設置一個 `VONAGE_SMS_FROM` 環境變量，該變量定義了你發送 SMS 消息的默認電話號碼。你可以在 Vonage 控制面板中生成此電話號碼：

    VONAGE_SMS_FROM=15556666666

<a name="formatting-sms-notifications"></a>
### 格式化短信通知

如果通知支持作為 SMS 發送，你應該在通知類上定義一個 `toVonage` 方法。此方法將接收一個 `$notifiable` 實體並應返回一個 `Illuminate\Notifications\Messages\VonageMessage` 實例：

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * 獲取通知的 Vonage / SMS 表達式。
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->content('你的短信內容');
    }

<a name="unicode-content"></a>
#### Unicode 內容

如果你的 SMS 消息將包含 unicode 字符，你應該在構造 `VonageMessage` 實例時調用 `unicode` 方法：

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * 獲取通知的 Vonage / SMS 表達式。
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->content('你的統一碼消息')
                    ->unicode();
    }

<a name="customizing-the-from-number"></a>
### 自定義「來源」號碼

如果你想從一個不同於 `VONAGE_SMS_FROM` 環境變量所指定的電話號碼發送通知，你可以在 `VonageMessage` 實例上調用 `from` 方法：

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * 獲取通知的 Vonage / SMS 表達式。
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->content('您的短信內容')
                    ->from('15554443333');
    }

<a name="adding-a-client-reference"></a>
### 添加客戶關聯

如果你想跟蹤每個用戶、團隊或客戶的消費，你可以在通知中添加「客戶關聯」。Vonage 將允許你使用這個客戶關聯生成報告，以便你能更好地了解特定客戶的短信使用情況。客戶關聯可以是任何字符串，最多 40 個字符。

    use Illuminate\Notifications\Messages\VonageMessage;

    /**
     * 獲取通知的 Vonage / SMS 表達式。
     */
    public function toVonage(object $notifiable): VonageMessage
    {
        return (new VonageMessage)
                    ->clientReference((string) $notifiable->id)
                    ->content('你的短信內容');
    }

<a name="routing-sms-notifications"></a>
### 路由短信通知

要將 Vonage 通知路由到正確的電話號碼，請在你的通知實體上定義 `routeNotificationForVonage` 方法：

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Notifications\Notification;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * Vonage 通道的路由通知。
         */
        public function routeNotificationForVonage(Notification $notification): string
        {
            return $this->phone_number;
        }
    }

<a name="slack-notifications"></a>
## Slack 通知

<a name="slack-prerequisites"></a>
### 先決條件

在你可以通過 Slack 發送通知之前，你必須通過 Composer 安裝 Slack 通知通道：

```shell
composer require laravel/slack-notification-channel
```

你還需要為你的團隊創建一個 [Slack 應用](https://api.slack.com/apps?new_app=1)。創建應用後，你應該為工作區配置一個「傳入 Webhook」。 然後，Slack 將為你提供一個 webhook URL，你可以在 [路由 Slack 通知](#routing-slack-notifications) 時使用該 URL。

<a name="formatting-slack-notifications"></a>
### 格式化 Slack 通知

如果通知支持作為 Slack 消息發送，你應在通知類上定義 `toSlack` 方法。此方法將接收一個 `$notifiable` 實體並應返回一個 `Illuminate\Notifications\Messages\SlackMessage` 實例。Slack 消息可能包含文本內容以及格式化附加文本或字段數組的「附件」。  讓我們看一個基本的 `toSlack` 示例：

    use Illuminate\Notifications\Messages\SlackMessage;

    /**
     * 獲取通知的 Slack 表達式。
     */
    public function toSlack(object $notifiable): SlackMessage
    {
        return (new SlackMessage)
                    ->content('你的一張發票已經付款了！');
    }

<a name="slack-attachments"></a>
### Slack 附件

你還可以向 Slack 消息添加「附件」。附件提供比簡單文本消息更豐富的格式選項。在這個例子中，我們將發送一個關於應用程序中發生的異常的錯誤通知，包括一個鏈接，以查看有關異常的更多詳細信息：

    use Illuminate\Notifications\Messages\SlackAttachment;
    use Illuminate\Notifications\Messages\SlackMessage;

    /**
     * 獲取通知的 Slack 表示形式。
     */
    public function toSlack(object $notifiable): SlackMessage
    {
        $url = url('/exceptions/'.$this->exception->id);

        return (new SlackMessage)
                    ->error()
                    ->content('哎呀！出了問題。')
                    ->attachment(function (SlackAttachment $attachment) use ($url) {
                        $attachment->title('例外：文件未找到', $url)
                                   ->content('文件 [background.jpg] 未找到。');
                    });
    }

附件還允許你指定應呈現給用戶的數據數組。 給定的數據將以表格形式呈現，以便於閱讀：

    use Illuminate\Notifications\Messages\SlackAttachment;
    use Illuminate\Notifications\Messages\SlackMessage;

    /**
     * 獲取通知的 Slack 表示形式。
     */
    public function toSlack(object $notifiable): SlackMessage
    {
        $url = url('/invoices/'.$this->invoice->id);

        return (new SlackMessage)
                    ->success()
                    ->content('你的一張發票已經付款了！')
                    ->attachment(function (SlackAttachment $attachment) use ($url) {
                        $attachment->title('Invoice 1322', $url)
                                   ->fields([
                                        'Title' => 'Server Expenses',
                                        'Amount' => '$1,234',
                                        'Via' => 'American Express',
                                        'Was Overdue' => ':-1:',
                                    ]);
                    });
    }

<a name="markdown-attachment-content"></a>
#### Markdown 附件內容

如果你的附件字段中包含 Markdown，則可以使用 `markdown` 方法指示 Slack 解析和顯示給定的附件字段為 Markdown 格式的文本。此方法接受的值是：`pretext`、`text`和/或`fields`。有關 Slack 附件格式的更多信息，請查看 [Slack API 文檔](https://api.slack.com/docs/message-formatting#message_formatting)：

    use Illuminate\Notifications\Messages\SlackAttachment;
    use Illuminate\Notifications\Messages\SlackMessage;

    /**
     * 獲取通知的 Slack 表示形式。
     */
    public function toSlack(object $notifiable): SlackMessage
    {
        $url = url('/exceptions/'.$this->exception->id);

        return (new SlackMessage)
                    ->error()
                    ->content('Whoops! Something went wrong.')
                    ->attachment(function (SlackAttachment $attachment) use ($url) {
                        $attachment->title('Exception: File Not Found', $url)
                                   ->content('File [background.jpg] was *not found*.')
                                   ->markdown(['text']);
                    });
    }

<a name="routing-slack-notifications"></a>
### 路由 Slack 通知

為了將 Slack 通知路由到正確的 Slack 團隊和頻道，請在你的通知實體上定義一個 `routeNotificationForSlack` 方法。它應該返回要傳送通知的 Webhook URL。Webhook URL 可以通過向你的 Slack 團隊添加「傳入 Webhook」服務來生成：

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Notifications\Notification;

    class User extends Authenticatable
    {
        use Notifiable;

        /**
         * 路由 Slack 頻道的通知。
         */
        public function routeNotificationForSlack(Notification $notification): string
        {
            return 'https://hooks.slack.com/services/...';
        }
    }

<a name="localizing-notifications"></a>
## 本地化通知

Laravel 允許你在除了當前請求語言環境之外的其他語言環境中發送通知，甚至在通知被隊列化的情況下也能記住此語言環境。

為了實現這一功能，`Illuminate\Notifications\Notification` 類提供了 `locale` 方法來設置所需的語言環境。在通知被評估時，應用程序將切換到此語言環境，然後在評估完成後恢覆到以前的語言環境：

    $user->notify((new InvoicePaid($invoice))->locale('es'));

通過 `Notification` 門面，也可以實現多個通知實體的本地化：

    Notification::locale('es')->send(
        $users, new InvoicePaid($invoice)
    );

<a name="user-preferred-locales"></a>
### 用戶首選語言環境

有時，應用程序會存儲每個用戶的首選區域設置。通過在你的可通知模型上實現 `HasLocalePreference` 合同，你可以指示 Laravel 在發送通知時使用此存儲的區域設置：

    use Illuminate\Contracts\Translation\HasLocalePreference;

    class User extends Model implements HasLocalePreference
    {
        /**
         * 獲取用戶的首選語言環境。
         */
        public function preferredLocale(): string
        {
            return $this->locale;
        }
    }

翻譯：一旦你實現了這個接口，當發送通知和郵件到該模型時，Laravel 會自動使用首選語言環境。因此，在使用此接口時不需要調用`locale`方法：

    $user->notify(new InvoicePaid($invoice));

<a name="testing"></a>
## 測試

你可以使用 `Notification` 門面的 `fake` 方法來阻止通知被發送。通常情況下，發送通知與你實際測試的代碼無關。很可能，只需要斷言 Laravel 被指示發送了給定的通知即可。

在調用 `Notification` 門面的 `fake` 方法後，你可以斷言已經被告知將通知發送給用戶，甚至檢查通知接收到的數據：

    <?php

    namespace Tests\Feature;

    use App\Notifications\OrderShipped;
    use Illuminate\Support\Facades\Notification;
    use Tests\TestCase;

    class ExampleTest extends TestCase
    {
        public function test_orders_can_be_shipped(): void
        {
            Notification::fake();

            // 執行訂單發貨...

            // 斷言沒有發送通知...
            Notification::assertNothingSent();

            // 斷言通知已發送給給定用戶...
            Notification::assertSentTo(
                [$user], OrderShipped::class
            );

            // 斷言未發送通知...
            Notification::assertNotSentTo(
                [$user], AnotherNotification::class
            );

            // 斷言已發送給定數量的通知...
            Notification::assertCount(3);
        }
    }

你可以通過向 `assertSentTo` 或 `assertNotSentTo` 方法傳遞一個閉包來斷言發送了符合給定「真實性測試」的通知。如果發送了至少一個符合給定真實性測試的通知，則斷言將成功：

    Notification::assertSentTo(
        $user,
        function (OrderShipped $notification, array $channels) use ($order) {
            return $notification->order->id === $order->id;
        }
    );

<a name="on-demand-notifications"></a>
#### 按需通知

如果你正在測試的代碼發送 [即時通知](https://chat.openai.com/chat#on-demand-notifications)，你可以使用 `assertSentOnDemand` 方法測試是否發送了即時通知：

    Notification::assertSentOnDemand(OrderShipped::class);

通過將閉包作為 `assertSentOnDemand` 方法的第二個參數傳遞，你可以確定是否將即時通知發送到了正確的 「route」 地址：

    Notification::assertSentOnDemand(
        OrderShipped::class,
        function (OrderShipped $notification, array $channels, object $notifiable) use ($user) {
            return $notifiable->routes['mail'] === $user->email;
        }
    );

<a name="notification-events"></a>
## 通知事件

<a name="notification-sending-event"></a>
#### 通知發送事件

發送通知時，通知系統會調度 `Illuminate\Notifications\Events\NotificationSending` [事件](/docs/laravel/10.x/events)。 這包含「可通知」實體和通知實例本身。 你可以在應用程序的 `EventServiceProvider` 中為該事件注冊監聽器：

    use App\Listeners\CheckNotificationStatus;
    use Illuminate\Notifications\Events\NotificationSending;

    /**
     * 應用程序的事件偵聽器映射。
     *
     * @var array
     */
    protected $listen = [
        NotificationSending::class => [
            CheckNotificationStatus::class,
        ],
    ];

如果 `NotificationSending` 事件的監聽器從它的 `handle` 方法返回 `false`，通知將不會被發送：

    use Illuminate\Notifications\Events\NotificationSending;

    /**
     * 處理事件。
     */
    public function handle(NotificationSending $event): void
    {
        return false;
    }

在事件監聽器中，你可以訪問事件的 `notifiable`、`notification` 和 `channel` 屬性，以了解有關通知接收者或通知本身的更多信息。

    /**
     * 處理事件。
     */
    public function handle(NotificationSending $event): void
    {
        // $event->channel
        // $event->notifiable
        // $event->notification
    }

<a name="notification-sent-event"></a>
#### 通知發送事件

當通知被發送時，通知系統會觸發 `Illuminate\Notifications\Events\NotificationSent` [事件](/docs/laravel/10.x/events)，其中包含 「notifiable」 實體和通知實例本身。你可以在 `EventServiceProvider` 中注冊此事件的監聽器：

    use App\Listeners\LogNotification;
    use Illuminate\Notifications\Events\NotificationSent;

    /**
     * 應用程序的事件偵聽器映射。
     *
     * @var array
     */
    protected $listen = [
        NotificationSent::class => [
            LogNotification::class,
        ],
    ];

> **注意**
> 在 `EventServiceProvider` 中注冊了監聽器之後，可以使用 event:generate Artisan 命令快速生成監聽器類。

在事件監聽器中，你可以訪問事件上的 `notifiable`、`notification`、`channel` 和 `response` 屬性，以了解更多有關通知收件人或通知本身的信息：

    /**
     * 處理事件。
     */
    public function handle(NotificationSent $event): void
    {
        // $event->channel
        // $event->notifiable
        // $event->notification
        // $event->response
    }

<a name="custom-channels"></a>
## 自定義頻道
Laravel 提供了一些通知頻道，但你可能想編寫自己的驅動程序，以通過其他頻道傳遞通知。Laravel 讓這變得簡單。要開始，定義一個包含 `send` 方法的類。該方法應接收兩個參數：`$notifiable` 和 `$notification`。

在 `send` 方法中，你可以調用通知上的方法來檢索一個由你的頻道理解的消息對象，然後按照你希望的方式將通知發送給 `$notifiable` 實例：

    <?php

    namespace App\Notifications;

    use Illuminate\Notifications\Notification;

    class VoiceChannel
    {
        /**
         * 發送給定的通知
         */
        public function send(object $notifiable, Notification $notification): void
        {
            $message = $notification->toVoice($notifiable);

            // 將通知發送給 $notifiable 實例...
        }
    }

一旦你定義了你的通知頻道類，你可以從你的任何通知的 `via` 方法返回該類的名稱。在這個例子中，你的通知的 `toVoice` 方法可以返回你選擇來表示語音消息的任何對象。例如，你可以定義自己的 `VoiceMessage` 類來表示這些消息：

    <?php

    namespace App\Notifications;

    use App\Notifications\Messages\VoiceMessage;
    use App\Notifications\VoiceChannel;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Notifications\Notification;

    class InvoicePaid extends Notification
    {
        use Queueable;

        /**
         * 獲取通知頻道
         */
        public function via(object $notifiable): string
        {
            return VoiceChannel::class;
        }

        /**
         * 獲取通知的語音表示形式
         */
        public function toVoice(object $notifiable): VoiceMessage
        {
            // ...
        }
    }
