# Logging

- [介紹](#introduction)
- [配置](#configuration)
    - [可用通道驅動](#available-channel-driver)
    - [通道先決條件](#available-channel-driver)
    - [記錄棄用警告](#logging-deprecation-warnings)
- [構建日志堆棧](#building-log-stacks)
- [寫日志消息](#writing-log-messages)
    - [上下文信息](#contextual-information)
    - [寫入到指定通道](#writing-to-specific-channels)
- [Monolog 通道自定義](#monolog-channel-customization)
    - [為通道自定義 Monolog](#customizing-monolog-for-channels)
    - [創建 Monolog 處理器通道](#creating-monolog-handler-channels)
    - [創建 Monolog 處理器通道](#creating-custom-channels-via-factories)

<a name="introduction"></a>
## 介紹

為了幫助您更多地了解應用程序中發生的事情，Laravel 提供了強大的日志記錄服務，允許您將日志記錄到文件、系統錯誤日志，甚至記錄到 Slack 以通知您的整個團隊。

Laravel 日志基於「 通道 」。 每個通道代表一種寫入日志信息的特定方式。 例如，`single` 通道是將日志寫入到單個日志文件中。而 `slack` 通道是將日志發送到 Slack 上。 基於它們的重要程度，日志可以被寫入到多個通道中去。

在底層，Laravel 利用 [Monolog](https://github.com/Seldaek/monolog) 庫，它為各種強大的日志處理程序提供了支持。 Laravel 使配置這些處理程序變得輕而易舉，允許您混合和匹配它們，以自定義應用程序的方式完成日志處理。
<a name="configuration"></a>
## 配置

所有應用程序的日志行為配置選項都位於 `config/logging.php` 配置文件中。 該文件允許您配置應用程序的日志通道，因此請務必查看每個可用通道及其選項。 我們將在下面回顧一些常見的選項。



默認情況下，Laravel 在記錄日志消息時使用 `stack` 頻道。`stack` 頻道用於將多個日志頻道聚合到一個頻道中。有關構建堆棧的更多信息，請查看下面的[文檔](https://chat.openai.com/chat#building-log-stacks)。

<a name="configuring-the-channel-name"></a>
#### 配置頻道名稱

默認情況下，Monolog 使用與當前環境相匹配的“頻道名稱”（例如 `production` 或 `local`）進行實例化。要更改此值，請向頻道的配置中添加一個 `name` 選項：

    'stack' => [
        'driver' => 'stack',
        'name' => 'channel-name',
        'channels' => ['single', 'slack'],
    ],

<a name="available-channel-drivers"></a>
### 可用頻道驅動程序

每個日志頻道都由一個“驅動程序”驅動。驅動程序確定實際記錄日志消息的方式和位置。以下日志頻道驅動程序在每個 Laravel 應用程序中都可用。大多數這些驅動程序的條目已經在應用程序的 `config/logging.php` 配置文件中存在，因此請務必查看此文件以熟悉其內容：

<div class="overflow-auto" markdown="1">

| 名稱 | 描述 |
| --- | --- |
| `custom` | 調用指定工廠創建頻道的驅動程序 |
| `daily` | 基於 `RotatingFileHandler` 的 Monolog 驅動程序，每天輪換一次日志文件 |
| `errorlog` | 基於 `ErrorLogHandler` 的 Monolog 驅動程序 |
| `monolog` | 可使用任何支持的 Monolog 處理程序的 Monolog 工廠驅動程序 |
| `null` | 丟棄所有日志消息的驅動程序 |
| `papertrail` | 基於 `SyslogUdpHandler` 的 Monolog 驅動程序 |
| `single` | 單個文件或路徑為基礎的記錄器頻道（`StreamHandler`） |
| `slack` | 基於 `SlackWebhookHandler` 的 Monolog 驅動程序 |
| `stack` | 包裝器，用於方便地創建“多通道”頻道 |
| `syslog` | 基於 `SyslogHandler` 的 Monolog 驅動程序 |

</div>

> **注意**
> 查看 [高級頻道自定義](/chat#monolog-channel-customization) 文檔，了解有關 `monolog` 和 `custom` 驅動程序的更多信息。


### 頻道前提條件

#### 配置單一和日志頻道

在處理消息時，`single`和 `daily` 頻道有三個可選配置選項：`bubble`，`permission` 和`locking`。

<div class="overflow-auto" markdown="1">

| 名稱 | 描述 | 默認值 |
| --- | --- | --- |
| `bubble` | 表示是否在處理後將消息傳遞到其他頻道 | `true` |
| `locking` | 在寫入日志文件之前嘗試鎖定日志文件 | `false` |
| `permission` | 日志文件的權限 | `0644` |</div>

另外，可以通過 `days` 選項配置 `daily` 頻道的保留策略：

<div class="overflow-auto" markdown="1">

| 名稱 | 描述 | 默認值 |
| --- | --- | --- |
| `days` | 保留每日日志文件的天數 | `7` |</div>

#### 配置 Papertrail 頻道

`papertrail` 頻道需要 `host` 和 `port` 配置選項。您可以從[Papertrail](https://help.papertrailapp.com/kb/configuration/configuring-centralized-logging-from-php-apps/#send-events-from-php-app)獲取這些值。

#### 配置Slack頻道

`slack` 頻道需要一個 `url` 配置選項。此URL應該與您為Slack團隊配置的[incoming webhook](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks)的URL匹配。

默認情況下，Slack僅會接收 `critical` 級別及以上的日志；但是，您可以通過修改 `config/logging.php` 配置文件中您的Slack日志頻道配置數組中的 `level` 配置選項來調整此設置。

### 記錄棄用警告

PHP、Laravel和其他庫通常會通知其用戶，一些功能已被棄用，將在未來版本中刪除。如果您想記錄這些棄用警告，可以在應用程序的 `config/logging.php` 配置文件中指定您首選的 `deprecations` 日志頻道：

    'deprecations' => env('LOG_DEPRECATIONS_CHANNEL', 'null'),

    'channels' => [
        ...
    ]



或者，您可以定義一個名為 `deprecations` 的日志通道。如果存在此名稱的日志通道，則始終將其用於記錄棄用：

    'channels' => [
        'deprecations' => [
            'driver' => 'single',
            'path' => storage_path('logs/php-deprecation-warnings.log'),
        ],
    ],

<a name="building-log-stacks"></a>
## 構建日志堆棧

如前所述，`stack` 驅動程序允許您將多個通道組合成一個方便的日志通道。為了說明如何使用日志堆棧，讓我們看一個您可能在生產應用程序中看到的示例配置：

    'channels' => [
        'stack' => [
            'driver' => 'stack',
            'channels' => ['syslog', 'slack'],
        ],

        'syslog' => [
            'driver' => 'syslog',
            'level' => 'debug',
        ],

        'slack' => [
            'driver' => 'slack',
            'url' => env('LOG_SLACK_WEBHOOK_URL'),
            'username' => 'Laravel Log',
            'emoji' => ':boom:',
            'level' => 'critical',
        ],
    ],

讓我們分解一下這個配置。首先，請注意我們的 `stack` 通道通過其 `channels` 選項聚合了兩個其他通道：`syslog` 和 `slack`。因此，在記錄消息時，這兩個通道都有機會記錄消息。但是，正如我們將在下面看到的那樣，這些通道是否實際記錄消息可能取決於消息的嚴重程度/"級別"。

<a name="log-levels"></a>
#### 日志級別

請注意上面示例中 `syslog` 和 `slack` 通道配置中存在的 `level` 配置選項。此選項確定必須記錄消息的最小“級別”。Laravel的日志服務采用Monolog，提供[RFC 5424規範](https://tools.ietf.org/html/rfc5424)中定義的所有日志級別。按嚴重程度遞減的順序，這些日志級別是：**emergency**，**alert**，**critical**，**error**，**warning**，**notice**，**info**和**debug**。



在我們的配置中，如果我們使用 `debug` 方法記錄消息：

    Log::debug('An informational message.');

根據我們的配置，`syslog` 渠道將把消息寫入系統日志；但由於錯誤消息不是 `critical` 或以上級別，它不會被發送到 Slack。然而，如果我們記錄一個 `emergency` 級別的消息，則會發送到系統日志和 Slack，因為 `emergency` 級別高於我們兩個渠道的最小級別閾值：

    Log::emergency('The system is down!');

<a name="writing-log-messages"></a>
## 寫入日志消息

您可以使用 `Log`  [facade](/docs/laravel/10.x/facades) 向日志寫入信息。正如之前提到的，日志記錄器提供了 [RFC 5424 規範](https://tools.ietf.org/html/rfc5424) 中定義的八個日志級別：**emergency**、**alert**、**critical**、**error**、**warning**、**notice**、**info** 和 **debug**：

    use Illuminate\Support\Facades\Log;

    Log::emergency($message);
    Log::alert($message);
    Log::critical($message);
    Log::error($message);
    Log::warning($message);
    Log::notice($message);
    Log::info($message);
    Log::debug($message);

您可以調用其中任何一個方法來記錄相應級別的消息。默認情況下，該消息將根據您的 `logging` 配置文件配置的默認日志渠道進行寫入：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\User;
    use Illuminate\Support\Facades\Log;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Show the profile for the given user.
         */
        public function show(string $id): View
        {
            Log::info('Showing the user profile for user: '.$id);

            return view('user.profile', [
                'user' => User::findOrFail($id)
            ]);
        }
    }



<a name="contextual-information"></a>
### 上下文信息

可以向日志方法傳遞一組上下文數據。這些上下文數據將與日志消息一起格式化和顯示：

    use Illuminate\Support\Facades\Log;

    Log::info('User failed to login.', ['id' => $user->id]);

偶爾，您可能希望指定一些上下文信息，這些信息應包含在特定頻道中所有隨後的日志條目中。例如，您可能希望記錄與應用程序的每個傳入請求相關聯的請求ID。為了實現這一目的，您可以調用 `Log` 門面的 `withContext` 方法：

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Log;
    use Illuminate\Support\Str;
    use Symfony\Component\HttpFoundation\Response;

    class AssignRequestId
    {
        /**
         * Handle an incoming request.
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            $requestId = (string) Str::uuid();

            Log::withContext([
                'request-id' => $requestId
            ]);

            return $next($request)->header('Request-Id', $requestId);
        }
    }

如果要在_所有_日志頻道之間共享上下文信息，則可以調用 `Log::shareContext()` 方法。此方法將向所有已創建的頻道提供上下文信息，以及隨後創建的任何頻道。通常，`shareContext` 方法應從應用程序服務提供程序的 `boot` 方法中調用：

    use Illuminate\Support\Facades\Log;
    use Illuminate\Support\Str;

    class AppServiceProvider
    {
        /**
         * 啟動任何應用程序服務。
         */
        public function boot(): void
        {
            Log::shareContext([
                'invocation-id' => (string) Str::uuid(),
            ]);
        }
    }

<a name="writing-to-specific-channels"></a>
### 寫入特定頻道

有時，您可能希望將消息記錄到應用程序默認頻道以外的頻道。您可以使用 `Log` 門面上的 `channel` 方法來檢索並記錄配置文件中定義的任何頻道：

    use Illuminate\Support\Facades\Log;

    Log::channel('slack')->info('Something happened!');



如果你想創建一個由多個通道組成的按需記錄堆棧，可以使用 `stack` 方法：

    Log::stack(['single', 'slack'])->info('Something happened!');

<a name="on-demand-channels"></a>
#### 按需通道

還可以創建一個按需通道，方法是在運行時提供配置而無需將該配置包含在應用程序的 `logging` 配置文件中。為此，可以將配置數組傳遞給 `Log` 門面的 `build` 方法：

    use Illuminate\Support\Facades\Log;

    Log::build([
      'driver' => 'single',
      'path' => storage_path('logs/custom.log'),
    ])->info('Something happened!');

您可能還希望在按需記錄堆棧中包含一個按需通道。可以通過將按需通道實例包含在傳遞給 `stack` 方法的數組中來實現：

    use Illuminate\Support\Facades\Log;

    $channel = Log::build([
      'driver' => 'single',
      'path' => storage_path('logs/custom.log'),
    ]);

    Log::stack(['slack', $channel])->info('Something happened!');

<a name="monolog-channel-customization"></a>
## Monolog 通道定制

<a name="customizing-monolog-for-channels"></a>
### 為通道定制 Monolog

有時，您可能需要完全控制 Monolog 如何配置現有通道。例如，您可能希望為 Laravel 內置的 `single` 通道配置自定義的 Monolog `FormatterInterface` 實現。

要開始，請在通道配置中定義 `tap` 數組。`tap` 數組應包含一系列類，這些類在創建 Monolog 實例後應有機會自定義（或“tap”）它。沒有這些類應放置在何處的慣例位置，因此您可以在應用程序中創建一個目錄以包含這些類：

    'single' => [
        'driver' => 'single',
        'tap' => [App\Logging\CustomizeFormatter::class],
        'path' => storage_path('logs/laravel.log'),
        'level' => 'debug',
    ],



一旦你在通道上配置了 `tap` 選項，你就可以定義一個類來自定義你的 Monolog 實例。這個類只需要一個方法：`__invoke`，它接收一個 `Illuminate\Log\Logger` 實例。`Illuminate\Log\Logger` 實例代理所有方法調用到底層的 Monolog 實例：


    <?php

    namespace App\Logging;

    use Illuminate\Log\Logger;
    use Monolog\Formatter\LineFormatter;

    class CustomizeFormatter
    {
        /**
         * 自定義給定的日志記錄器實例。
         */
        public function __invoke(Logger $logger): void
        {
            foreach ($logger->getHandlers() as $handler) {
                $handler->setFormatter(new LineFormatter(
                    '[%datetime%] %channel%.%level_name%: %message% %context% %extra%'
                ));
            }
        }
    }

> **注意**
> 所有的 “tap” 類都由 [服務容器](/docs/laravel/10.x/container) 解析，因此它們所需的任何構造函數依賴關系都將自動注入。

<a name="creating-monolog-handler-channels"></a>

### 創建 Monolog 處理程序通道

Monolog 有多種 [可用的處理程序](https://github.com/Seldaek/monolog/tree/main/src/Monolog/Handler)，而 Laravel 並沒有為每個處理程序內置通道。在某些情況下，你可能希望創建一個自定義通道，它僅是一個特定的 Monolog 處理程序實例，該處理程序沒有相應的 Laravel 日志驅動程序。這些通道可以使用 `monolog` 驅動程序輕松創建。

使用 `monolog` 驅動程序時，`handler` 配置選項用於指定將實例化哪個處理程序。可選地，可以使用 `with` 配置選項指定處理程序需要的任何構造函數參數：

    'logentries' => [
        'driver'  => 'monolog',
        'handler' => Monolog\Handler\SyslogUdpHandler::class,
        'with' => [
            'host' => 'my.logentries.internal.datahubhost.company.com',
            'port' => '10000',
        ],
    ],

<a name="monolog-formatters"></a>

#### Monolog 格式化程序

使用 `monolog` 驅動程序時，Monolog `LineFormatter` 將用作默認格式化程序。但是，你可以使用 `formatter` 和 `formatter_with` 配置選項自定義傳遞給處理程序的格式化程序類型：

    'browser' => [
        'driver' => 'monolog',
        'handler' => Monolog\Handler\BrowserConsoleHandler::class,
        'formatter' => Monolog\Formatter\HtmlFormatter::class,
        'formatter_with' => [
            'dateFormat' => 'Y-m-d',
        ],
    ],

如果你使用的是能夠提供自己的格式化程序的 Monolog 處理程序，你可以將 `formatter` 配置選項的值設置為 `default`：

    'newrelic' => [
        'driver' => 'monolog',
        'handler' => Monolog\Handler\NewRelicHandler::class,
        'formatter' => 'default',
    ],


 <a name="monolog-processors"></a>
#### Monolog 處理器

Monolog 也可以在記錄消息之前對其進行處理。你可以創建你自己的處理器或使用 [Monolog提供的現有處理器](https://github.com/Seldaek/monolog/tree/main/src/Monolog/Processor)。

 如果你想為 `monolog` 驅動定制處理器，請在通道的配置中加入`processors` 配置值。

     'memory' => [
         'driver' => 'monolog',
         'handler' => Monolog\Handler\StreamHandler::class,
         'with' => [
             'stream' => 'php://stderr',
         ],
         'processors' => [
             // Simple syntax...
             Monolog\Processor\MemoryUsageProcessor::class,

             // With options...
             [
                'processor' => Monolog\Processor\PsrLogMessageProcessor::class,
                'with' => ['removeUsedContextFields' => true],
            ],
         ],
     ],


<a name="creating-custom-channels-via-factories"></a>
### 通過工廠創建通道

如果你想定義一個完全自定義的通道，你可以在其中完全控制 Monolog 的實例化和配置，你可以在 `config/logging.php` 配置文件中指定`custom` 驅動程序類型。你的配置應該包括一個 `via` 選項，其中包含將被調用以創建 Monolog 實例的工廠類的名稱：

    'channels' => [
        'example-custom-channel' => [
            'driver' => 'custom',
            'via' => App\Logging\CreateCustomLogger::class,
        ],
    ],

一旦你配置了 `custom` 驅動程序通道，你就可以定義將創建你的 Monolog 實例的類。這個類只需要一個 __invoke 方法，它應該返回 Monolog 記錄器實例。 該方法將接收通道配置數組作為其唯一參數：

    <?php

    namespace App\Logging;

    use Monolog\Logger;

    class CreateCustomLogger
    {
        /**
         * 創建一個自定義 Monolog 實例。
         */
        public function __invoke(array $config): Logger
        {
            return new Logger(/* ... */);
        }
    }
