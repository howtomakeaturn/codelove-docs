# 錯誤處理

- [簡介](#introduction)
- [配置](#configuration)
- [異常處理](#the-exception-handler)
    - [報告異常](#reporting-exceptions)
    - [異常日志級別](#exception-log-levels)
    - [忽略指定類型異常](#ignoring-exceptions-by-type)
    - [渲染異常](#rendering-exceptions)
    - [Reportable & Renderable 異常](#renderable-exceptions)
- [HTTP 異常](#http-exceptions)
    - [自定義 HTTP 錯誤頁面](#custom-http-error-pages)

<a name="introduction"></a>
## 簡介

Laravel 默認已經為我們配置好了錯誤和異常處理，我們在 App\Exceptions\Handler 類中觸發異常並將響應返回給用戶。在本文檔中我們將深入探討這個類。

<a name="configuration"></a>
## 配置

配置文件 config/app.php 中的 debug 配置項控制瀏覽器顯示的錯誤信息數量。默認情況下，該配置項通過 .env 文件中的環境變量 APP_DEBUG 進行設置。

對本地開發而言，你應該設置環境變量 APP_DEBUG 值為 true。在生產環境，該值應該被設置為 false。如果在生產環境被設置為 true，就有可能將一些敏感的配置值暴露給終端用戶。

<a name="the-exception-handler"></a>
## 異常處理器

<a name="reporting-exceptions"></a>
### 報告異常

所有異常都由 App\Exceptions\Handler 類處理。這個類包含了一個 register 方法用於注冊自定義的異常報告器和渲染器回調，接下來我們會詳細介紹這些概念。我們可以通過異常報告記錄異常或者將它們發送給外部服務，比如 Flare、Bugsnag 以及 Sentry。默認情況下，會基於日志配置記錄異常，不過，你也可以按照自己期望的方式進行自定義。

例如，如果你需要以不同方式報告不同類型的異常，可以使用 reportable 方法注冊一個閉包，該閉包會在給定類型異常需要被報告時執行。Laravel 會通過檢查閉包的參數類型提示推斷該閉包報告的異常類型：



# 錯誤處理

- [介紹](#introduction)
- [配置](#configuration)
- [異常處理](#the-exception-handler)
    - [異常報告](#reporting-exceptions)
    - [異常日志級別](#exception-log-levels)
    - [忽略指定類型異常](#ignoring-exceptions-by-type)
    - [渲染異常](#rendering-exceptions)
    - [Reportable & Renderable 異常](#renderable-exceptions)
- [HTTP 異常](#http-exceptions)
    - [自定義 HTTP 錯誤頁面](#custom-http-error-pages)

<a name="introduction"></a>
## 介紹

當你開始一個新的 Laravel 項目時，它已經為你配置了錯誤和異常處理。`App\Exceptions\Handler`類用於記錄應用程序觸發的所有異常，然後將其呈現回用戶。我們將在本文中深入討論這個類。

<a name="configuration"></a>
## 配置

你的`config/app.php`配置文件中的`debug`選項決定了對於一個錯誤實際上將顯示多少信息給用戶。默認情況下，該選項的設置將遵照存儲在`.env`文件中的`APP_DEBUG`環境變量的值。

對於本地開發，你應該將`APP_DEBUG`環境變量的值設置為`true`。 **在生產環境中，該值應始終為`false`。如果在生產中將該值設置為`true`，則可能會將敏感配置值暴露給應用程序的終端用戶。**

<a name="the-exception-handler"></a>
## 異常處理

<a name="reporting-exceptions"></a>
### 異常報告

所有異常都是由`App\Exceptions\Handler`類處理。此類包含一個`register`方法，可以在其中注冊自定義異常報告程序和渲染器回調。我們將詳細研究每個概念。異常報告用於記錄異常或將其發送到如  [Flare](https://flareapp.io)、 [Bugsnag](https://bugsnag.com) 或 [Sentry](https://github.com/getsentry/sentry-laravel) 等外部服務。默認情況下，將根據你的[日志](/docs/laravel/10.x/logging)配置來記錄異常。不過，你可以用任何自己喜歡的方式來記錄異常。



例如，如果您需要以不同的方式報告不同類型的異常，您可以使用 <code>reportable</code> 方法注冊一個閉包，當需要報告給定的異常的時候便會執行它。 Laravel 將通過檢查閉包的類型提示來判斷閉包報告的異常類型：

    use App\Exceptions\InvalidOrderException;

    /**
     * 為應用程序注冊異常處理回調
     */
    public function register(): void
    {
        $this->reportable(function (InvalidOrderException $e) {
            // ...
        });
    }

當您使用 <code>reportable</code> 方法注冊一個自定義異常報告回調時， Laravel 依然會使用默認的日志配置記錄下應用異常。 如果您想要在默認的日志堆棧中停止這個行為，您可以在定義報告回調時使用 stop 方法或者從回調函數中返回 <code>false</code>：


    $this->reportable(function (InvalidOrderException $e) {
        // ...
    })->stop();

    $this->reportable(function (InvalidOrderException $e) {
        return false;
    });

> **技巧**
> 要為給定的異常自定義異常報告，您可以使用 [可報告異常](/docs/laravel/10.x/errors#renderable-exceptions).

<a name="global-log-context"></a>
#### 全局日志上下文

在可用的情況下， Laravel 會自動將當前用戶的編號作為數據添加到每一條異常日志信息中。您可以通過重寫 <code>App\Exceptions\Handler</code> 類中的 <code>context</code> 方法來定義您自己的全局上下文數據（環境變量）。此後，每一條異常日志信息都將包含這個信息：

    /**
     * 獲取默認日志的上下文變量。
     *
     * @return array<string, mixed>
     */
    protected function context(): array
    {
        return array_merge(parent::context(), [
            'foo' => 'bar',
        ]);
    }

<a name="exception-log-context"></a>


#### 異常日志上下文

盡管將上下文添加到每個日志消息中可能很有用，但有時特定的異常可能具有您想要包含在日志中的唯一上下文。通過在應用程序的自定義異常中定義`context`方法，您可以指定與該異常相關的任何數據，應將其添加到異常的日志條目中：

    <?php

    namespace App\Exceptions;

    use Exception;

    class InvalidOrderException extends Exception
    {
        // ...

        /**
         * 獲取異常上下文信息
         *
         * @return array<string, mixed>
         */
        public function context(): array
        {
            return ['order_id' => $this->orderId];
        }
    }

<a name="the-report-helper"></a>
#### `report` 助手

有時，您可能需要報告異常，但繼續處理當前請求。`report`助手函數允許您通過異常處理程序快速報告異常，而無需向用戶呈現錯誤頁面：

    public function isValid(string $value): bool
    {
        try {
            // Validate the value...
        } catch (Throwable $e) {
            report($e);

            return false;
        }
    }

<a name="exception-log-levels"></a>
### 異常日志級別

當消息被寫入應用程序的[日志](/docs/laravel/10.x/logging)時，消息將以指定的[日志級別](/docs/laravel/10.x/logging#log-levels)寫入，該級別指示正在記錄的消息的嚴重性或重要性。

如上所述，即使使用`reportable`方法注冊自定義異常報告回調，Laravel仍將使用應用程序的默認日志記錄配置記錄異常；但是，由於日志級別有時會影響消息記錄的通道，因此您可能希望配置某些異常記錄的日志級別。



為了實現這個目標，您可以在應用程序的異常處理程序的`$levels`屬性中定義一個異常類型數組以及它們關聯的日志級別：

    use PDOException;
    use Psr\Log\LogLevel;

    /**
     * 包含其對應自定義日志級別的異常類型列表。
     *
     * @var array<class-string<\Throwable>, \Psr\Log\LogLevel::*>
     */
    protected $levels = [
        PDOException::class => LogLevel::CRITICAL,
    ];

<a name="ignoring-exceptions-by-type"></a>
### 按類型忽略異常

在構建應用程序時，您可能希望忽略某些類型的異常並永遠不報告它們。應用程序的異常處理程序包含一個	`$dontReport` 屬性，該屬性初始化為空數組。您添加到此屬性的任何類都將不會被報告；但是它們仍然可能具有自定義渲染邏輯：

    use App\Exceptions\InvalidOrderException;

    /**
     * 不會被報告的異常類型列表。
     *
     * @var array<int, class-string<\Throwable>>
     */
    protected $dontReport = [
        InvalidOrderException::class,
    ];

在內部，Laravel已經為您忽略了一些類型的錯誤，例如由404 HTTP錯誤或由無效CSRF令牌生成的419 HTTP響應引起的異常。如果您想指示Laravel停止忽略給定類型的異常，您可以在異常處理程序的`register`方法中調用`stopIgnoring`方法：

    use Symfony\Component\HttpKernel\Exception\HttpException;

    /**
     * 為應用程序注冊異常處理回調函數。
     */
    public function register(): void
    {
        $this->stopIgnoring(HttpException::class);

        // ...
    }

<a name="rendering-exceptions"></a>
### 渲染異常

默認情況下，Laravel 異常處理程序會將異常轉換為 HTTP 響應。但是，您可以自由地為給定類型的異常注冊自定義渲染閉包。您可以通過在異常處理程序中調用`renderable`方法來實現這一點。



傳遞給 `renderable` 方法的閉包應該返回一個 `Illuminate\Http\Response` 實例，該實例可以通過 `response` 助手生成。 Laravel 將通過檢查閉包的類型提示來推斷閉包呈現的異常類型：

    use App\Exceptions\InvalidOrderException;
    use Illuminate\Http\Request;

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->renderable(function (InvalidOrderException $e, Request $request) {
            return response()->view('errors.invalid-order', [], 500);
        });
    }

您還可以使用 `renderable` 方法來覆蓋內置的Laravel或Symfony異常的呈現行為，例如 `NotFoundHttpException`。如果傳遞給 `renderable` 方法的閉包沒有返回值，則將使用Laravel的默認異常呈現：

    use Illuminate\Http\Request;
    use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->renderable(function (NotFoundHttpException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json([
                    'message' => 'Record not found.'
                ], 404);
            }
        });
    }

<a name="renderable-exceptions"></a>
### Reportable & Renderable 異常

您可以直接在自定義異常類中定義 `report` 和 `render` 方法，而不是在異常處理程序的 `register` 方法中定義自定義報告和呈現行為。當存在這些方法時，框架將自動調用它們：

    <?php

    namespace App\Exceptions;

    use Exception;
    use Illuminate\Http\Request;
    use Illuminate\Http\Response;

    class InvalidOrderException extends Exception
    {
        /**
         * Report the exception.
         */
        public function report(): void
        {
            // ...
        }

        /**
         * Render the exception into an HTTP response.
         */
        public function render(Request $request): Response
        {
            return response(/* ... */);
        }
    }

如果您的異常擴展了已經可呈現的異常，例如內置的Laravel或Symfony異常，則可以從異常的 `render` 方法中返回`false`，以呈現異常的默認HTTP響應：

    /**
     * Render the exception into an HTTP response.
     */
    public function render(Request $request): Response|bool
    {
        if (/** Determine if the exception needs custom rendering */) {

            return response(/* ... */);
        }

        return false;
    }



如果你的異常包含了只在特定條件下才需要使用的自定義報告邏輯，那麽你可能需要指示 Laravel 有時使用默認的異常處理配置來報告異常。為了實現這一點，你可以從異常的 `report` 方法中返回 `false`：

    /**
     * Report the exception.
     */
    public function report(): bool
    {
        if (/** 確定異常是否需要自定義報告 */) {

            // ...

            return true;
        }

        return false;
    }

> **注意**
> 你可以在 `report` 方法中類型提示任何所需的依賴項，它們將自動被 Laravel 的[服務容器](/docs/laravel/10.x/container)注入該方法中。

<a name="http-exceptions"></a>
## HTTP 異常

有些異常描述了服務器返回的 HTTP 錯誤代碼。例如，這可能是一個 "頁面未找到" 錯誤（404），一個 "未經授權錯誤"（401）或甚至是一個由開發者生成的 500 錯誤。為了從應用程序的任何地方生成這樣的響應，你可以使用 `abort` 幫助函數：

    abort(404);

<a name="custom-http-error-pages"></a>
### 自定義 HTTP 錯誤頁面

Laravel 使得為各種 HTTP 狀態碼顯示自定義錯誤頁面變得很容易。例如，如果你想自定義 404 HTTP 狀態碼的錯誤頁面，請創建一個 `resources/views/errors/404.blade.php` 視圖模板。這個視圖將會被渲染在應用程序生成的所有 404 錯誤上。這個目錄中的視圖應該被命名為它們對應的 HTTP 狀態碼。`abort` 函數引發的 `Symfony\Component\HttpKernel\Exception\HttpException` 實例將會以 `$exception` 變量的形式傳遞給視圖：

    <h2>{{ $exception->getMessage() }}</h2>

你可以使用 `vendor:publish` Artisan 命令發布 Laravel 的默認錯誤頁面模板。一旦模板被發布，你可以根據自己的喜好進行自定義：

```shell
php artisan vendor:publish --tag=laravel-errors
```

<a name="fallback-http-error-pages"></a>
#### 回退 HTTP 錯誤頁面

你也可以為給定系列的 HTTP 狀態碼定義一個“回退”錯誤頁面。如果沒有針對發生的具體 HTTP 狀態碼相應的頁面，就會呈現此頁面。為了實現這一點，在你應用程序的 `resources/views/errors` 目錄中定義一個 `4xx.blade.php` 模板和一個 `5xx.blade.php` 模板。
