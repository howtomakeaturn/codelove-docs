# 郵件

- [介紹](#introduction)
    - [配置](#configuration)
    - [驅動前提](#driver-prerequisites)
    - [故障轉移配置](#failover-configuration)
- [生成 Mailables](#generating-mailables)
- [編寫 Mailables](#writing-mailables)
    - [配置發送者](#configuring-the-sender)
    - [配置視圖](#configuring-the-view)
    - [視圖數據](#view-data)
    - [附件](#attachments)
    - [內部附件](#inline-attachments)
    - [可附著對象](#attachable-objects)
    - [標頭](#headers)
    - [標記和元數據](#tags-and-metadata)
    - [自定義 Symfony 消息](#customizing-the-symfony-message)
- [Markdown 格式郵件](#markdown-mailables)
    - [生成 Markdown 格式郵件](#generating-markdown-mailables)
    - [生成 Markdown 格式郵件](#writing-markdown-messages)
    - [自定義組件](#customizing-the-components)
- [發送郵件](#sending-mail)
    - [郵件隊列](#queueing-mail)
- [渲染郵件](#rendering-mailables)
    - [瀏覽器中預覽郵件](#previewing-mailables-in-the-browser)
- [郵件本土化](#localizing-mailables)
- [測試郵件](#testing-mailables)
    - [測試郵件內容](#testing-mailable-content)
    - [測試郵件發送](#testing-mailable-sending)
- [郵件和本地開發](#mail-and-local-development)
- [事件](#events)
- [自定義傳輸方式](#custom-transports)
    - [附 - Symfony 傳輸方式](#additional-symfony-transports)

<a name="introduction"></a>
## 介紹

發送郵件並不覆雜。Laravel 基於 [Symfony Mailer](https://symfony.com/doc/6.0/mailer.html) 組件提供了一個簡潔、簡單的郵件 API。Laravel 和 Symfony 為 Mailer SMTP 、Mailgun 、Postmark 、 Amazon SES 、 及 sendmail （發送郵件的方式）提供驅動，允許你通過本地或者雲服務來快速發送郵件。

<a name="configuration"></a>
### 配置

Laravel 的郵件服務可以通過 `config/mail.php` 配置文件進行配置。郵件中的每一項都在配置文件中有單獨的配置項，甚至是獨有的「傳輸方式」，允許你的應用使用不同的郵件服務發送郵件。例如，你的應用程序在使用 Amazon SES 發送批量郵件時，也可以使用 Postmark 發送事務性郵件。

在你的 `mail` 配置文件中，你將找到 `mailers` 配置數組。該數組包含 Laravel 支持的每個郵件 驅動程序 / 傳輸方式 配置，而 `default` 配置值確定當你的應用程序需要發送電子郵件時，默認情況下將使用哪個郵件驅動。

<a name="driver-prerequisites"></a>
### 驅動 / 傳輸的前提

基於 API 的驅動，如 Mailgun 和 Postmark ，通常比 SMTP 服務器更簡單快速。如果可以的話， 我們建議你使用下面這些驅動。

<a name="mailgun-driver"></a>
#### Mailgun 驅動

要使用 Mailgun 驅動，可以先通過 `composer` 來安裝 `Mailgun` 函數庫 ：

```shell
composer require symfony/mailgun-mailer symfony/http-client
```

接著，在應用的 `config/mail.php` 配置文件中，將默認項設置成 `mailgun`。配置好之後，確認 `config/services.php` 配置文件中包含以下選項：

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
    ],

如果不使用 US [Mailgun region](https://documentation.mailgun.com/en/latest/api-intro.html#mailgun-regions) 區域終端 ，你需要在 `service` 文件中配置區域終端：

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.eu.mailgun.net'),
    ],

<a name="postmark-driver"></a>
#### Postmark 驅動

要使用 `Postmark` 驅動，先通過 `composer` 來安裝 `Postmark` 函數庫：

```shell
composer require symfony/postmark-mailer symfony/http-client
```

接著，在應用的 `config/mail.php` 配置文件中，將默認項設置成 `postmark`。配置好之後，確認 `config/services.php` 配置文件中包含如下選項：

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

如果你要給指定郵件程序使用的 Postmark message stream，可以在配置數組中添加 `message_stream_id` 配置選項。這個配置數組在應用程序的 config/mail.php 配置文件中：

    'postmark' => [
        'transport' => 'postmark',
        'message_stream_id' => env('POSTMARK_MESSAGE_STREAM_ID'),
    ],

這樣，你還可以使用不同的 `message stream` 來設置多個 `Postmark 郵件驅動`。

<a name="ses-driver"></a>
#### SES 驅動

要使用 `Amazon SES` 驅動，你必須先安裝 `PHP` 的 `Amazon AWS SDK` 。你可以可以通過 Composer 軟件包管理器安裝此庫：

```shell
composer require aws/aws-sdk-php
```

然後，將 `config/mail.php` 配置文件的 `default` 選項設置成 `ses` 並確認你的 `config/services.php` 配置文件包含以下選項：

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

為了通過 session token 來使用 AWS [temporary credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html) ，你需要向應用的 SES 配置中添加一個 `token` 鍵：

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
        'token' => env('AWS_SESSION_TOKEN'),
    ],

發送郵件，如果你想傳遞一些 [額外的選項](https://docs.aws.amazon.com/aws-sdk-php/v3/api/api-sesv2-2019-09-27.html#sendemail) 給 AWS SDK 的 `SendEmail` 方法，你可以在 `ses` 配置中定義一個 `options` 數組：

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
        'options' => [
            'ConfigurationSetName' => 'MyConfigurationSet',
            'EmailTags' => [
                ['Name' => 'foo', 'Value' => 'bar'],
            ],
        ],
    ],

<a name="failover-configuration"></a>
### 備用配置

有時，已經配置好用於發送應用程序郵件的外部服務可能已關閉。在這種情況下，定義一個或多個備份郵件傳遞配置非常有用，這些配置將在主傳遞驅動程序關閉時使用。
為此，應該在應用程序的 `mail` 配置文件中定義一個使用 `failover` 傳輸的郵件程序。應用程序的 `failover` 郵件程序的配置數組應包含一個 `mailers` 數組，該數組引用選擇郵件驅動程序進行傳遞的順序：

    'mailers' => [
        'failover' => [
            'transport' => 'failover',
            'mailers' => [
                'postmark',
                'mailgun',
                'sendmail',
            ],
        ],

        // ...
    ],

定義故障轉移郵件程序後，應將此郵件程序設置為應用程序使用的`默認`郵件程序，方法是將其名稱指定為應用程序 `mail` 配置文件中 `default` 配置密鑰的值：

    'default' => env('MAIL_MAILER', 'failover'),

<a name="generating-mailables"></a>
## 生成 Mailables

在構建 Laravel 應用程序時，應用程序發送的每種類型的電子郵件都表示為一個 `mailable` 類。這些類存儲在 app/Mail 目錄中。 如果你在應用程序中看不到此目錄，請不要擔心，因為它會在你使用 make:mail Artisan 命令創建第一個郵件類時自然生成：

```shell
php artisan make:mail OrderShipped
```

<a name="writing-mailables"></a>
## 編寫 Mailables

一旦生成了一個郵件類，就打開它，這樣我們就可以探索它的內容。郵件類的配置可以通過幾種方法完成，包括 `envelope`、`content` 和 `attachments` 方法。

 `envelope` 方法返回 `Illuminate\Mail\Mailables\Envelope` 對象，該對象定義郵件的主題，有時還定義郵件的收件人。`content` 方法返回 `Illuminate\Mail\Mailables\Content` 對象，該對象定義將用於生成消息內容的[Blade模板](/docs/laravel/10.x/blade)。

<a name="configuring-the-sender"></a>
### 配置發件人

<a name="using-the-envelope"></a>
#### 使用 Envelope

首先，讓我們來看下如何配置電子郵件的發件人。電子郵件的「發件人」。有兩種方法可以配置發送者。首先，你可以在郵件信封上指定「發件人」地址：

    use Illuminate\Mail\Mailables\Address;
    use Illuminate\Mail\Mailables\Envelope;

    /**
     * 獲取郵件信封。
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            from: new Address('jeffrey@example.com', 'Jeffrey Way'),
            subject: '訂單發貨',
        );
    }

除此之外，還可以指定 `replyTo` 地址：

    return new Envelope(
        from: new Address('jeffrey@example.com', 'Jeffrey Way'),
        replyTo: [
            new Address('taylor@example.com', 'Taylor Otwell'),
        ],
        subject: '訂單發貨',
    );

<a name="using-a-global-from-address"></a>
#### 使用全局 `from` 地址

當然，如果你的應用在任何郵件中使用的「發件人」地址都一致的話，在你生成的每一個 mailable 類中調用 `from` 方法可能會很麻煩。因此，你可以在 `config/mail.php` 文件中指定一個全局的「發件人」地址。當某個 mailable 類沒有指定「發件人」時，它將使用該全局「發件人」：

    'from' => ['address' => 'example@example.com', 'name' => 'App Name'],

此外，你可以在 `config/mail.php` 配置文件中定義全局 「reply_to」 地址：

    'reply_to' => ['address' => 'example@example.com', 'name' => 'App Name'],

<a name="configuring-the-view"></a>
### 配置視圖

在郵件類下的 `content` 方法中使用 `view` 方法來指定在渲染郵件內容時要使用的模板。由於每封電子郵件通常使用一個 [Blade 模板](/docs/laravel/10.x/blade) 來渲染其內容。因此在構建電子郵件的 HTML 時，可以充分利用 Blade 模板引擎的功能和便利性：

    /**
     * 獲取消息內容定義。
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.orders.shipped',
        );
    }

> **技巧**
> 你可以創建一個 `resources/views/emails` 目錄來存放所有的郵件模板；當然，也可以將其置於 `resources/views` 目錄下的任何位置。

<a name="plain-text-emails"></a>
#### 純文本郵件

如果要定義電子郵件的純文本版本，可以在創建郵件的 `Content` 定義時指定純文本模板。與 `view` 參數一樣， `text` 參數是用於呈現電子郵件內容的模板名稱。這樣你就可以自由定義郵件的 Html 和純文本版本：

    /**
     * 獲取消息內容定義。
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.orders.shipped',
            text: 'emails.orders.shipped-text'
        );
    }

為了清晰，`html` 參數可以用作 `view` 參數的別名：

    return new Content(
        html: 'emails.orders.shipped',
        text: 'emails.orders.shipped-text'
    );

<a name="view-data"></a>
### 視圖數

<a name="via-public-properties"></a>
#### 通過 Public 屬性

通常，你需要將一些數據傳遞給視圖，以便在呈現電子郵件的 HTML 時使用。有兩種方法可以使數據對視圖可用。首先，在 mailable 類上定義的任何公共屬性都將自動對視圖可用。例如，可以將數據傳遞到可郵寄類的構造函數中，並將該數據設置為類上定義的公共方法：

    <?php

    namespace App\Mail;

    use App\Models\Order;
    use Illuminate\Bus\Queueable;
    use Illuminate\Mail\Mailable;
    use Illuminate\Mail\Mailables\Content;
    use Illuminate\Queue\SerializesModels;

    class OrderShipped extends Mailable
    {
        use Queueable, SerializesModels;

        /**
         * 創建新的消息實例。
         */
        public function __construct(
            public Order $order,
        ) {}

        /**
         * 獲取消息內容定義。
         */
        public function content(): Content
        {
            return new Content(
                view: 'emails.orders.shipped',
            );
        }
    }

一旦數據設置為公共屬性，它將自動在視圖中可用，因此可以像訪問 Blade 模板中的任何其他數據一樣訪問它：

    <div>
        Price: {{ $order->price }}
    </div>

<a name="via-the-with-parameter"></a>
#### 通過 `with` 參數：

如果你想要在郵件數據發送到模板前自定義它們的格式，你可以使用 `with` 方法來手動傳遞數據到視圖中。一般情況下，你還是需要通過 mailable 類的構造函數來傳遞數據；不過，你應該將它們定義為 `protected` 或 `private` 以防止它們被自動傳遞到視圖中。然後，在調用 `with` 方法的時候，可以以數組的形式傳遞你想要傳遞給模板的數據：

    <?php

    namespace App\Mail;

    use App\Models\Order;
    use Illuminate\Bus\Queueable;
    use Illuminate\Mail\Mailable;
    use Illuminate\Mail\Mailables\Content;
    use Illuminate\Queue\SerializesModels;

    class OrderShipped extends Mailable
    {
        use Queueable, SerializesModels;

        /**
         * 創建新的消息實例。
         */
        public function __construct(
            protected Order $order,
        ) {}

        /**
         * 獲取消息內容定義。
         */
        public function content(): Content
        {
            return new Content(
                view: 'emails.orders.shipped',
                with: [
                    'orderName' => $this->order->name,
                    'orderPrice' => $this->order->price,
                ],
            );
        }
    }

一旦數據被傳遞到 `with` 方法，同樣的它將自動在視圖中可用，因此可以像訪問 Blade 模板中的任何其他數據一樣訪問它：

    <div>
        Price: {{ $orderPrice }}
    </div>

<a name="attachments"></a>
### 附件

要向電子郵件添加附件，你將向郵件的 `attachments` 方法返回的數組添加附件。首先，可以通過向 `Attachment` 類提供的 `fromPath` 方法提供文件路徑來添加附件：

    use Illuminate\Mail\Mailables\Attachment;

    /**
     * 獲取郵件的附件。
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromPath('/path/to/file'),
        ];
    }

將文件附加到郵件時，還可以使用 `as` 和 `withMime` 方法來指定附件的顯示名稱 / 或 MIME 類型：

    /**
     * 獲取郵件的附件。
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromPath('/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf'),
        ];
    }

<a name="attaching-files-from-disk"></a>
#### 從磁盤中添加附件

如果你已經在 [文件存儲](/docs/laravel/10.x/filesystem) 上存儲了一個文件，則可以使用 `attachFromStorage` 方法將其附加到郵件中：

    /**
     * 獲取郵件的附件。
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromStorage('/path/to/file'),
        ];
    }

當然，也可以指定附件的名稱和 MIME 類型：

    /**
     * 獲取郵件的附件。
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromStorage('/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf'),
        ];
    }

如果需要指定默認磁盤以外的存儲磁盤，可以使用 `attachFromStorageDisk` 方法：

    /**
     * 獲取郵件的附件。
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromStorageDisk('s3', '/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf'),
        ];
    }

<a name="raw-data-attachments"></a>
#### 原始數據附件

`fromData` 附件方法可用於附加原始字節字符串作為附件。例如，如果你在內存中生成了PDF，並且希望將其附加到電子郵件而不將其寫入磁盤，可以使用到此方法。 `fromData` 方法接受一個閉包，該閉包解析原始數據字節以及應分配給附件的名稱：

    /**
     * 獲取郵件的附件。
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromData(fn () => $this->pdf, 'Report.pdf')
                    ->withMime('application/pdf'),
        ];
    }

<a name="inline-attachments"></a>
### 內聯附件

在郵件中嵌入內聯圖片通常很麻煩；不過，Laravel 提供了一種將圖像附加到郵件的便捷方法。可以使用郵件模板中 $message 變量的 embed 方法來嵌入內聯圖片。Laravel 自動使 $message 變量在全部郵件模板中可用，不需要擔心手動傳遞它：

```blade
<body>
    這是一張圖片：

    <img src="{{ $message->embed($pathToImage) }}">
</body>
```

> **注意**
> 該 `$message` 在文本消息中不可用，因為文本消息不能使用內聯附件。

<a name="embedding-raw-data-attachments"></a>
#### 嵌入原始數據附件

如果你已經有了可以嵌入郵件模板的原始圖像數據字符串，可以使用 `$message` 變量的 `embedData` 方法，當調用 `embedData` 方法時，需要傳遞一個文件名：

```blade
<body>
    以下是原始數據的圖像：

    <img src="{{ $message->embedData($data, 'example-image.jpg') }}">
</body>
```

<a name="attachable-objects"></a>
### 可附著對象

雖然通過簡單的字符串路徑將文件附加到消息通常就足夠了，但在多數情況下，應用程序中的可附加實體由類表示。例如，如果你的應用程序正在將照片附加到消息中，那麽在應用中可能還具有表示該照片的 `Photo` 模型。在這種情況下，簡單地將 `Photo` 模型傳遞給 `attach` 方法會很方便。

開始時，在可附加到郵件的對象上實現 `Illuminate\Contracts\Mail\Attachable` 接口。此接口要求類定義一個 `toMailAttachment` 方法，該方法返回一個 `Illuminate\Mail\Attachment` 實例：

    <?php

    namespace App\Models;

    use Illuminate\Contracts\Mail\Attachable;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Mail\Attachment;

    class Photo extends Model implements Attachable
    {
        /**
         * 獲取模型的可附加表示。
         */
        public function toMailAttachment(): Attachment
        {
            return Attachment::fromPath('/path/to/file');
        }
    }

一旦定義了可附加對象，就可以在生成電子郵件時從 `attachments` 方法返回該對象的實例：

    /**
     * 獲取郵件的附件。
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [$this->photo];
    }

當然，附件數據可以存儲在遠程文件存儲服務（例如 Amazon S3）上。因此，Laravel 還允許你從存儲在應用程序 [文件系統磁盤](/docs/laravel/10.x/filesystem) 上的數據生成附件實例：

    // 從默認磁盤上的文件創建附件。。。
    return Attachment::fromStorage($this->path);

    // 從特定磁盤上的文件創建附件。。。
    return Attachment::fromStorageDisk('backblaze', $this->path);

此外，還可以通過內存中的數據創建附件實例。為此還提供了 `fromData` 方法的閉包。但閉包應返回表示附件的原始數據：

    return Attachment::fromData(fn () => $this->content, 'Photo Name');

Laravel 還提供了其他方法，你可以使用這些方法自定義附件。例如，可以使用 `as` 和 `withMime` 方法自定義文件名和 MIME 類型：

    return Attachment::fromPath('/path/to/file')
            ->as('Photo Name')
            ->withMime('image/jpeg');

<a name="headers"></a>
### 標頭

有時，你可能需要在傳出消息中附加附加的標頭。例如，你可能需要設置自定義 `Message-Id` 或其他任意文本標題。

如果要實現這一點，請在郵件中定義 `headers` 方法。 `headers` 方法應返回 `Illuminate\Mail\Mailables\Headers` 實例。此類接受 `messageId` 、 `references` 和 `text` 參數。當然，你可以只提供特定消息所需的參數：

    use Illuminate\Mail\Mailables\Headers;

    /**
     * 獲取郵件標題。
     */
    public function headers(): Headers
    {
        return new Headers(
            messageId: 'custom-message-id@example.com',
            references: ['previous-message@example.com'],
            text: [
                'X-Custom-Header' => 'Custom Value',
            ],
        );
    }

<a name="tags-and-metadata"></a>
### 標記 和 元數據

一些第三方電子郵件提供商（如 Mailgun 和 Postmark ）支持消息「標簽」和 「元數據」，可用於對應用程序發送的電子郵件進行分組和跟蹤。你可以通過 `Envelope` 來定義向電子郵件添加標簽和元數據：

    use Illuminate\Mail\Mailables\Envelope;

    /**
     * 獲取郵件信封。
     *
     * @return \Illuminate\Mail\Mailables\Envelope
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: '訂單發貨',
            tags: ['shipment'],
            metadata: [
                'order_id' => $this->order->id,
            ],
        );
    }

如果你的應用程序正在使用 Mailgun 驅動程序，你可以查閱 Mailgun 的文檔以獲取有關 [標簽](https://documentation.mailgun.com/en/latest/user_manual.html#tagging-1) 和 [元數據](https://documentation.mailgun.com/en/latest/user_manual.html#attaching-data-to-messages) 的更多信息。同樣，還可以查閱郵戳文檔，了解其對 [標簽](https://postmarkapp.com/blog/tags-support-for-smtp) 和 [元數據](https://postmarkapp.com/support/article/1125-custom-metadata-faq) 支持的更多信息

如果你的應用程序使用 Amazon SES 發送電子郵件，則應使用 `metadata` 方法將 [SES 「標簽」](https://docs.aws.amazon.com/ses/latest/APIReference/API_MessageTag.html)附加到郵件中。

<a name="customizing-the-symfony-message"></a>
### 自定義 Symfony 消息

Laravel 的郵件功能是由 Symfony Mailer 提供的。Laravel 在你發送消息之前是由 Symfony Message 注冊然後再去調用自定義實例。這讓你有機會在發送郵件之前對其進行深度定制。為此，請在 `Envelope` 定義上定義 `using` 參數：


    use Illuminate\Mail\Mailables\Envelope;
    use Symfony\Component\Mime\Email;

    /**
     * 獲取郵件信封。
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: '訂單發貨',
            using: [
                function (Email $message) {
                    // ...
                },
            ]
        );
    }

<a name="markdown-mailables"></a>
## Markdown 格式郵件

Markdown 格式郵件允許你可以使用 mailable 中的預構建模板和 [郵件通知](/docs/laravel/10.x/notificationsmd#mail-notifications) 組件。由於消息是用 Markdown 編寫，Laravel 能夠渲染出美觀的、響應式的 HTML 模板消息，同時還能自動生成純文本副本。

<a name="generating-markdown-mailables"></a>
### 生成 Markdown 郵件

你可以在執行 `make:mail` 的 Artisan 命令時使用 `--markdown` 選項來生成一個 Markdown 格式模板的 mailable 類：

```shell
php artisan make:mail OrderShipped --markdown=emails.orders.shipped
```

然後，在 `Content` 方法中配置郵寄的 `content` 定義時，使用 `markdown` 參數而不是 `view` 參數：

    use Illuminate\Mail\Mailables\Content;

    /**
     * 獲取消息內容定義。
     */
    public function content(): Content
    {
        return new Content(
            markdown: 'emails.orders.shipped',
            with: [
                'url' => $this->orderUrl,
            ],
        );
    }

<a name="writing-markdown-messages"></a>
### 編寫 Markdown 郵件

Markdown mailable 類整合了 Markdown 語法和 Blade 組件，讓你能夠非常方便的使用 Laravel 預置的 UI 組件來構建郵件消息：

```blade
<x-mail::message>
# 訂單發貨

你的訂單已發貨！

<x-mail::button :url="$url">
查看訂單
</x-mail::button>

謝謝,<br>
{{ config('app.name') }}
</x-mail::message>
```

> **技巧**
> 在編寫 Markdown 郵件的時候，請勿使用額外的縮進。Markdown 解析器會把縮進渲染成代碼塊。

<a name="button-component"></a>
#### 按鈕組件

按鈕組件用於渲染居中的按鈕鏈接。該組件接收兩個參數，一個是 `url` 一個是可選的 `color`。 支持的顏色包括 `primary` ，`success` 和 `error`。你可以在郵件中添加任意數量的按鈕組件：

```blade
<x-mail::button :url="$url" color="success">
查看訂單
</x-mail::button>
```

<a name="panel-component"></a>
#### 面板組件

面板組件在面板內渲染指定的文本塊，面板與其他消息的背景色略有不同。它允許你繪制一個警示文本塊：

```blade
<x-mail::panel>
這是面板內容
</x-mail::panel>
```

<a name="table-component"></a>
#### 表格組件

表格組件允許你將 Markdown 表格轉換成 HTML 表格。該組件接受 Markdown 表格作為其內容。列對齊支持默認的 Markdown 表格對齊語法：

```blade
<x-mail::table>
| Laravel       | Table         | Example  |
| ------------- |:-------------:| --------:|
| Col 2 is      | Centered      | $10      |
| Col 3 is      | Right-Aligned | $20      |
</x-mail::table>
```

<a name="customizing-the-components"></a>
### 自定義組件

你可以將所有 Markdown 郵件組件導出到自己的應用，用作自定義組件的模板。若要導出組件，使用 `laravel-mail` 資產標簽的 `vendor:publish` Artisan 命令：

```shell
php artisan vendor:publish --tag=laravel-mail
```

此命令會將 Markdown 郵件組件導出到 `resources/views/vendor/mail` 目錄。 該 `mail` 目錄包含 `html` 和 `text` 子目錄，分別包含各自對應的可用組件描述。你可以按照自己的意願自定義這些組件。

<a name="customizing-the-css"></a>
#### 自定義 CSS

組件導出後，`resources/views/vendor/mail/html/themes` 目錄有一個 `default.css` 文件。可以在此文件中自定義 CSS，這些樣式將自動內聯到 Markdown 郵件消息的 HTML 表示中。

如果想為 Laravel 的 Markdown 組件構建一個全新的主題，你可以在 `html/themes` 目錄中新建一個 CSS 文件。命名並保存 CSS 文件後，並更新應用程序 `config/mail.php` 配置文件的 `theme` 選項以匹配新主題的名稱。

要想自定義單個郵件主題，可以將 mailable 類的 `$theme` 屬性設置為發送 mailable 時應使用的主題名稱。

<a name="sending-mail"></a>
## 發送郵件

若要發送郵件，使用 `Mail` [facade](/docs/laravel/10.x/facades) 的方法。該 `to` 方法接受 郵件地址、用戶實例或用戶集合。如果傳遞一個對象或者對象集合，mailer 在設置收件人時將自動使用它們的 `email` 和 `name` 屬性，因此請確保對象的這些屬性可用。一旦指定了收件人，就可以將 mailable 類實例傳遞給 `send` 方法：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Mail\OrderShipped;
    use App\Models\Order;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Mail;

    class OrderShipmentController extends Controller
    {
        /**
         * 發送給定的訂單信息。
         */
        public function store(Request $request): RedirectResponse
        {
            $order = Order::findOrFail($request->order_id);

            // 發貨訂單。。。

            Mail::to($request->user())->send(new OrderShipped($order));

            return redirect('/orders');
        }
    }

在發送消息時不止可以指定收件人。還可以通過鏈式調用「to」、「cc」、「bcc」一次性指定抄送和密送收件人：

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->send(new OrderShipped($order));

<a name="looping-over-recipients"></a>
#### 遍歷收件人列表

有時，你需要通過遍歷一個收件人 / 郵件地址數組的方式，給一系列收件人發送郵件。但是，由於 `to` 方法會給 mailable 列表中的收件人追加郵件地址，因此，你應該為每個收件人重建 mailable 實例。

    foreach (['taylor@example.com', 'dries@example.com'] as $recipient) {
        Mail::to($recipient)->send(new OrderShipped($order));
    }

<a name="sending-mail-via-a-specific-mailer"></a>
#### 通過特定的 Mailer 發送郵件

默認情況下，Laravel 將使用 `mail` 你的配置文件中配置為 `default` 郵件程序。 但是，你可以使用 `mailer` 方法通過特定的郵件程序配置發送：

    Mail::mailer('postmark')
            ->to($request->user())
            ->send(new OrderShipped($order));

<a name="queueing-mail"></a>
### 郵件隊列

<a name="queueing-a-mail-message"></a>
#### 將郵件消息加入隊列

由於發送郵件消息可能大幅度延長應用的響應時間，許多開發者選擇將郵件消息加入隊列放在後台發送。Laravel 使用內置的 [統一隊列 API](/docs/laravel/10.x/queues) 簡化了這一工作。若要將郵件消息加入隊列，可以在指定消息的接收者後，使用 `Mail` 門面的 `queue` 方法：

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->queue(new OrderShipped($order));

此方法自動將作業推送到隊列中以便消息在後台發送。使用此特性之前，需要 [配置隊列](/docs/laravel/10.x/queues) 。

<a name="delayed-message-queueing"></a>
#### 延遲消息隊列

想要延遲發送隊列化的郵件消息，可以使用 `later` 方法。該 `later` 方法的第一個參數的第一個參數是標示消息何時發送的 `DateTime` 實例：

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->later(now()->addMinutes(10), new OrderShipped($order));

<a name="pushing-to-specific-queues"></a>
#### 推送到指定隊列

由於所有使用 `make:mail` 命令生成的 mailable 類都是用了 `Illuminate\Bus\Queueable` trait，因此你可以在任何 mailable 類實例上調用 `onQueue` 和 `onConnection` 方法來指定消息的連接和隊列名：

    $message = (new OrderShipped($order))
                    ->onConnection('sqs')
                    ->onQueue('emails');

    Mail::to($request->user())
        ->cc($moreUsers)
        ->bcc($evenMoreUsers)
        ->queue($message);

<a name="queueing-by-default"></a>
#### 默認隊列

如果你希望你的郵件類始終使用隊列，你可以給郵件類實現 `ShouldQueue` 契約，現在即使你調用了 `send` 方法，郵件依舊使用隊列的方式發送

    use Illuminate\Contracts\Queue\ShouldQueue;

    class OrderShipped extends Mailable implements ShouldQueue
    {
        // ...
    }

<a name="queued-mailables-and-database-transactions"></a>
#### 隊列的郵件和數據庫事務

當在數據庫事務中分發郵件隊列時，隊列可能在數據庫事務提交之前處理郵件。 發生這種情況時，在數據庫事務期間對模型或數據庫記錄所做的任何更新可能都不會反映在數據庫中。另外，在事務中創建的任何模型或數據庫記錄都可能不存在於數據庫中。如果你的郵件基於以上這些模型數據，則在處理郵件發送時，可能會發生意外錯誤。

如果隊列連接的 `after_commit` 配置選項設置為 `false`，那麽仍然可以通過在 mailable 類上定義 `afterCommit` 屬性來設置提交所有打開的數據庫事務之後再調度特定的郵件隊列：

    Mail::to($request->user())->send(
        (new OrderShipped($order))->afterCommit()
    );

或者，你可以 `afterCommit` 從 mailable 的構造函數中調用該方法：

    <?php

    namespace App\Mail;

    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Mail\Mailable;
    use Illuminate\Queue\SerializesModels;

    class OrderShipped extends Mailable implements ShouldQueue
    {
        use Queueable, SerializesModels;

        /**
         * 創建新的消息實例。
         */
        public function __construct()
        {
            $this->afterCommit();
        }
    }

> **技巧**
> 要了解有關解決這些問題的更多信息，請查看 [隊列和數據庫事物](/docs/laravel/10.x/queuesmd#jobs-and-database-transactions)。

<a name="rendering-mailables"></a>
## 渲染郵件

有時你可能希望捕獲郵件的 HTML 內容而不發送它。為此，可以調用郵件類的 `render` 方法。此方法將以字符串形式返回郵件類的渲染內容:

    use App\Mail\InvoicePaid;
    use App\Models\Invoice;

    $invoice = Invoice::find(1);

    return (new InvoicePaid($invoice))->render();

<a name="previewing-mailables-in-the-browser"></a>
### 在瀏覽器中預覽郵件

設計郵件模板時，可以方便地在瀏覽器中預覽郵件，就像典型的 Blade 模板一樣。因此， Laravel 允許你直接從路由閉包或控制器返回任何郵件類。當郵件返回時，它將渲染並顯示在瀏覽器中，允許你快速預覽其設計，而無需將其發送到實際的電子郵件地址：

    Route::get('/mailable', function () {
        $invoice = App\Models\Invoice::find(1);

        return new App\Mail\InvoicePaid($invoice);
    });

> **注意**
> 在瀏覽器中預覽郵件時，不會呈現 [內聯附件](#inline-attachments) 要預覽這些郵件，你應該將它們發送到電子郵件測試應用程序，例如 [Mailpit](https://github.com/axllent/mailpit) 或 [HELO](https://usehelo.com)。

<a name="localizing-mailables"></a>
## 本地化郵件

Laravel 允許你在請求的當前語言環境之外的語言環境中發送郵件，如果郵件在排隊，它甚至會記住這個語言環境。

為此， `Mail` 門面提供了一個 `locale` 方法來設置所需的語言。評估可郵寄的模板時，應用程序將更改為此語言環境，然後在評估完成後恢覆為先前的語言環境：

    Mail::to($request->user())->locale('es')->send(
        new OrderShipped($order)
    );

<a name="user-preferred-locales"></a>
### 用戶首選語言環境

有時，應用程序存儲每個用戶的首選語言環境。 通過在一個或多個模型上實現 `HasLocalePreference` 契約，你可以指示 Laravel 在發送郵件時使用這個存儲的語言環境：

    use Illuminate\Contracts\Translation\HasLocalePreference;

    class User extends Model implements HasLocalePreference
    {
        /**
         * 獲取用戶的區域設置。
         */
        public function preferredLocale(): string
        {
            return $this->locale;
        }
    }

一旦你實現了接口，Laravel 將在向模型發送郵件和通知時自動使用首選語言環境。 因此，使用該接口時無需調用 `locale` 方法：

    Mail::to($request->user())->send(new OrderShipped($order));

<a name="testing-mailables"></a>
## 測試郵件

<a name="testing-mailable-content"></a>
### 測試郵件內容

Laravel 提供了幾種方便的方法來測試你的郵件是否包含你期望的內容。 這些方法是：`assertSeeInHtml`、`assertDontSeeInHtml`、`assertSeeInOrderInHtml`、`assertSeeInText`、`assertDontSeeInText` 和 `assertSeeInOrderInText`。

和你想的一樣，「HTML」判斷你的郵件的 HTML 版本中是否包含給定字符串，而「Text」是判斷你的可郵寄郵件的純文本版本是否包含給定字符串：

    use App\Mail\InvoicePaid;
    use App\Models\User;

    public function test_mailable_content(): void
    {
        $user = User::factory()->create();

        $mailable = new InvoicePaid($user);

        $mailable->assertFrom('jeffrey@example.com');
        $mailable->assertTo('taylor@example.com');
        $mailable->assertHasCc('abigail@example.com');
        $mailable->assertHasBcc('victoria@example.com');
        $mailable->assertHasReplyTo('tyler@example.com');
        $mailable->assertHasSubject('Invoice Paid');
        $mailable->assertHasTag('example-tag');
        $mailable->assertHasMetadata('key', 'value');

        $mailable->assertSeeInHtml($user->email);
        $mailable->assertSeeInHtml('Invoice Paid');
        $mailable->assertSeeInOrderInHtml(['Invoice Paid', 'Thanks']);

        $mailable->assertSeeInText($user->email);
        $mailable->assertSeeInOrderInText(['Invoice Paid', 'Thanks']);

        $mailable->assertHasAttachment('/path/to/file');
        $mailable->assertHasAttachment(Attachment::fromPath('/path/to/file'));
        $mailable->assertHasAttachedData($pdfData, 'name.pdf', ['mime' => 'application/pdf']);
        $mailable->assertHasAttachmentFromStorage('/path/to/file', 'name.pdf', ['mime' => 'application/pdf']);
        $mailable->assertHasAttachmentFromStorageDisk('s3', '/path/to/file', 'name.pdf', ['mime' => 'application/pdf']);
    }

<a name="testing-mailable-sending"></a>
### 測試郵件的發送

我們建議將郵件內容和判斷指定的郵件「發送」給特定用戶的測試分開進行測試。通常來講，郵件的內容與你正在測試的代碼無關，只要能簡單地判斷 Laravel 能夠發送指定的郵件就足夠了。

你可以使用 `Mail`方法的 `fake` 方法來阻止郵件的發送。調用了 `Mail` 方法的 `fake`方法後，你可以判斷郵件是否已被發送給指定的用戶，甚至可以檢查郵件收到的數據：

    <?php

    namespace Tests\Feature;

    use App\Mail\OrderShipped;
    use Illuminate\Support\Facades\Mail;
    use Tests\TestCase;

    class ExampleTest extends TestCase
    {
        public function test_orders_can_be_shipped(): void
        {
            Mail::fake();

            // 執行郵件發送。。。

            // 判斷沒有發送的郵件。。。
            Mail::assertNothingSent();

            // 判斷已發送郵件。。。
            Mail::assertSent(OrderShipped::class);

            // 判斷已發送兩次的郵件。。。
            Mail::assertSent(OrderShipped::class, 2);

            // 判斷郵件是否未發送。。。
            Mail::assertNotSent(AnotherMailable::class);
        }
    }

如果你在後台排隊等待郵件的傳遞，則應該使用 `assertQueued` 方法而不是 `assertSent` 方法。

    Mail::assertQueued(OrderShipped::class);

    Mail::assertNotQueued(OrderShipped::class);

    Mail::assertNothingQueued();

你可以向 `assertSent`、`assertNotSent`、 `assertQueued` 或者 `assertNotQueued` 方法來傳遞閉包，來判斷發送的郵件是否通過給定的 「真值檢驗」。如果至少發送了一個可以通過的郵件，就可以判斷為成功。

    Mail::assertSent(function (OrderShipped $mail) use ($order) {
        return $mail->order->id === $order->id;
    });

當調用 `Mail` 外觀的判斷方法時，提供的閉包所接受的郵件實例會公開檢查郵件的可用方法：

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) use ($user) {
        return $mail->hasTo($user->email) &&
               $mail->hasCc('...') &&
               $mail->hasBcc('...') &&
               $mail->hasReplyTo('...') &&
               $mail->hasFrom('...') &&
               $mail->hasSubject('...');
    });

mailable 實例還包括檢查 mailable 上的附件的幾種可用方法：

    use Illuminate\Mail\Mailables\Attachment;

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) {
        return $mail->hasAttachment(
            Attachment::fromPath('/path/to/file')
                    ->as('name.pdf')
                    ->withMime('application/pdf')
        );
    });

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) {
        return $mail->hasAttachment(
            Attachment::fromStorageDisk('s3', '/path/to/file')
        );
    });

    Mail::assertSent(OrderShipped::class, function (OrderShipped $mail) use ($pdfData) {
        return $mail->hasAttachment(
            Attachment::fromData(fn () => $pdfData, 'name.pdf')
        );
    });

你可能已經注意到，有 2 種方法可以判斷郵件是否發送, 即：`assertNotSent` 和 `assertNotQueued` 。有時你可能希望判斷郵件沒有被發送**或**排隊。如果要實現這一點，你可以使用 `assertNothingOutgoing` 和 `assertNotOutgoing` 方法。

    Mail::assertNothingOutgoing();

    Mail::assertNotOutgoing(function (OrderShipped $mail) use ($order) {
        return $mail->order->id === $order->id;
    });

<a name="mail-and-local-development"></a>
## 郵件和本地開發

在開發發送電子郵件的應用程序時，你可能不希望實際將電子郵件發送到實際的電子郵件地址。 Laravel 提供了幾種在本地開發期間「禁用」發送電子郵件的方法。

<a name="log-driver"></a>
#### 日志驅動

`log` 郵件驅動程序不會發送你的電子郵件，而是將所有電子郵件信息寫入你的日志文件以供檢查。 通常，此驅動程序僅在本地開發期間使用。有關按環境配置應用程序的更多信息，請查看 [配置文檔](/docs/laravel/10.x/configuration/14836#environment-configuration)。

<a name="mailtrap"></a>
#### HELO / Mailtrap / Mailpit

或者，你可以使用 [HELO](https://usehelo.com/) 或 [Mailtrap](https://mailtrap.io/) 之類的服務和 `smtp` 驅動程序將你的電子郵件信息發送到「虛擬」郵箱。你可以通過在真正的電子郵件客戶端中查看它們。這種方法的好處是允許你在 Mailtrap 的消息查看實際並檢查的最終電子郵件。

如果你使用 [Laravel Sail](/docs/laravel/10.x/sail)，你可以使用 [Mailpit](https://github.com/axllent/mailpit) 預覽你的消息。當 Sail 運行時，你可以訪問 Mailpit 界面：`http://localhost:8025`。

<a name="using-a-global-to-address"></a>
#### 使用全局 `to` 地址

最後，你可以通過調用 `Mail` 門面提供的 `alwaysTo` 方法來指定一個全局的「收件人」地址。 通常，應該從應用程序的服務提供者之一的 `boot` 方法調用此方法：

    use Illuminate\Support\Facades\Mail;

    /**
     * 啟動應用程序服務
     */
    public function boot(): void
    {
        if ($this->app->environment('local')) {
            Mail::alwaysTo('taylor@example.com');
        }
    }

<a name="events"></a>
## 事件

Laravel 在發送郵件消息的過程中會觸發 2 個事件。`MessageSending` 事件在消息發送之前觸發，而 `MessageSent` 事件在消息發送後觸發。請記住，這些事件是在郵件**發送**時觸發的，而不是在排隊時觸發的。你可以在你的 `App\Providers\EventServiceProvider` 服務中為這個事件注冊事件監聽器：

    use App\Listeners\LogSendingMessage;
    use App\Listeners\LogSentMessage;
    use Illuminate\Mail\Events\MessageSending;
    use Illuminate\Mail\Events\MessageSent;

    /**
     * 應用程序的事件偵聽器映射。
     *
     * @var array
     */
    protected $listen = [
        MessageSending::class => [
            LogSendingMessage::class,
        ],

        MessageSent::class => [
            LogSentMessage::class,
        ],
    ];

<a name="custom-transports"></a>
## 自定義傳輸

Laravel 包含多種郵件傳輸；但是，你可能希望編寫自己的傳輸程序，通過 Laravel 來發送電子郵件。首先，定義一個擴展 `Symfony\Component\Mailer\Transport\AbstractTransport` 類。然後，在傳輸上實現 `doSend` 和 `__toString()` 方法：

    use MailchimpTransactional\ApiClient;
    use Symfony\Component\Mailer\SentMessage;
    use Symfony\Component\Mailer\Transport\AbstractTransport;
    use Symfony\Component\Mime\Address;
    use Symfony\Component\Mime\MessageConverter;

    class MailchimpTransport extends AbstractTransport
    {
        /**
         * 創建一個新的 Mailchimp 傳輸實例。
         */
        public function __construct(
            protected ApiClient $client,
        ) {
            parent::__construct();
        }

        /**
         * {@inheritDoc}
         */
        protected function doSend(SentMessage $message): void
        {
            $email = MessageConverter::toEmail($message->getOriginalMessage());

            $this->client->messages->send(['message' => [
                'from_email' => $email->getFrom(),
                'to' => collect($email->getTo())->map(function (Address $email) {
                    return ['email' => $email->getAddress(), 'type' => 'to'];
                })->all(),
                'subject' => $email->getSubject(),
                'text' => $email->getTextBody(),
            ]]);
        }

        /**
         * 獲取傳輸字符串的表示形式。
         */
        public function __toString(): string
        {
            return 'mailchimp';
        }
    }

你一旦定義了自定義傳輸，就可以通過 `Mail` 外觀提供的 `boot` 方法來注冊它。通常情況下，這應該在應用程序的 `AppServiceProvider` 服務種提供的 `boot` 方法中完成。`$config` 參數將提供給 `extend` 方法的閉包。該參數將包含在應用程序中的 `config/mail.php` 來配置文件中為 mailer 定義的配置數組。

    use App\Mail\MailchimpTransport;
    use Illuminate\Support\Facades\Mail;

    /**
     * 啟動應用程序服務
     */
    public function boot(): void
    {
        Mail::extend('mailchimp', function (array $config = []) {
            return new MailchimpTransport(/* ... */);
        });
    }

定義並注冊自定義傳輸後，你可以在應用程序中的 `config/mail.php` 配置文件中新建一個利用自定義傳輸的郵件定義：

    'mailchimp' => [
        'transport' => 'mailchimp',
        // ...
    ],

<a name="additional-symfony-transports"></a>
### 額外的 Symfony 傳輸

Laravel 同樣支持一些現有的 Symfony 維護的郵件傳輸，如 Mailgun 和 Postmark 。但是，你可能希望通過擴展 Laravel，來支持 Symfony 維護的其他傳輸。你可以通過 Composer 請求必要的 Symfony 郵件並向 Laravel 注冊運輸。例如，你可以安裝並注冊 Symfony 的「Sendinblue」 郵件：

```none
composer require symfony/sendinblue-mailer symfony/http-client
```

安裝 Sendinblue 郵件包後，你可以將 Sendinblue API 憑據的條目添加到應用程序的「服務」配置文件中：

    'sendinblue' => [
        'key' => 'your-api-key',
    ],

最後，你可以使用 `Mail` 門面的 `extend` 方法向 Laravel 注冊傳輸。通常，這應該在服務提供者的 `boot` 方法中完成：

    use Illuminate\Support\Facades\Mail;
    use Symfony\Component\Mailer\Bridge\Sendinblue\Transport\SendinblueTransportFactory;
    use Symfony\Component\Mailer\Transport\Dsn;

    /**
     * 啟動應用程序服務。
     */
    public function boot(): void
    {
        Mail::extend('sendinblue', function () {
            return (new SendinblueTransportFactory)->create(
                new Dsn(
                    'sendinblue+api',
                    'default',
                    config('services.sendinblue.key')
                )
            );
        });
    }

你一旦注冊了傳輸，就可以在應用程序的 `config/mail.php` 配置文件中創建一個用於新傳輸的 mailer 定義：

    'sendinblue' => [
        'transport' => 'sendinblue',
        // ...
    ],
