# 目錄結構

-   [介紹](#introduction)
-   [根目錄](#the-root-directory)
    -   [`app` 目錄](#the-root-app-directory)
    -   [`bootstrap` 目錄](#the-bootstrap-directory)
    -   [`config` 目錄](#the-config-directory)
    -   [`database` 目錄](#the-database-directory)
    -   [`public` 目錄](#the-public-directory)
    -   [`resources` 目錄](#the-resources-directory)
    -   [`routes` 目錄](#the-routes-directory)
    -   [`storage` 目錄](#the-storage-directory)
    -   [`tests` 目錄](#the-tests-directory)
    -   [`vendor` 目錄](#the-vendor-directory)
-   [應用程序目錄](#the-app-directory)
    -   [`Broadcasting` 目錄](#the-broadcasting-directory)
    -   [`Console` 目錄](#the-console-directory)
    -   [`Events` 目錄](#the-events-directory)
    -   [`Exceptions` 目錄](#the-exceptions-directory)
    -   [`Http` 目錄](#the-http-directory)
    -   [`Jobs` 目錄](#the-jobs-directory)
    -   [`Listeners` 目錄](#the-listeners-directory)
    -   [`Mail` 目錄](#the-mail-directory)
    -   [`Models` 目錄](#the-models-directory)
    -   [`Notifications` 目錄](#the-notifications-directory)
    -   [`Policies` 目錄](#the-policies-directory)
    -   [`Providers` 目錄](#the-providers-directory)
    -   [`Rules` 目錄](#the-rules-directory)

<a name="introduction"></a>
## 介紹

默認的 Laravel 應用程序結構旨在為大型和小型應用程序提供一個良好的起點。但是你可以自由地組織你的應用程序。Laravel 幾乎不會限制任何給定類的位置——只要 Composer 可以自動加載類即可。

> **注意**
> 初次使用 Laravel？請查看 [Laravel Bootcamp](https://bootcamp.laravel.com) 以獲得該框架的實戰指南，同時我們將幫助你構建你的第一個 Laravel 應用。

<a name="the-root-directory"></a>
## 根目錄

<a name="the-root-app-directory"></a>
#### App 目錄

`app` 目錄包含應用程序的核心代碼。我們很快將詳細探討這個目錄；但是，你的應用程序中幾乎所有的類都將在此目錄中。

<a name="the-bootstrap-directory"></a>
#### Bootstrap 目錄

`bootstrap` 目錄包含 `app.php` 文件，該文件引導框架。此目錄還包含一個 `cache` 目錄，其中包含框架生成的文件，用於性能優化，例如路由和服務緩存文件。你通常不需要修改此目錄中的任何文件。

<a name="the-config-directory"></a>
#### Config 目錄

`config` 目錄，顧名思義，包含所有應用程序的配置文件。建議你閱讀所有這些文件並熟悉所有可用選項。

<a name="the-database-directory"></a>
#### Database 目錄

`database` 目錄包含數據庫遷移、模型工廠和種子。如果需要，你還可以使用此目錄來保存 SQLite 數據庫。

<a name="the-public-directory"></a>
#### Public 目錄

`public` 目錄包含 `index.php` 文件，該文件是所有進入應用程序的請求的入口點並配置自動加載。此目錄還包含你的資源文件，例如圖片、JavaScript 和 CSS。

<a name="the-resources-directory"></a>
#### Resources 目錄

`resources` 目錄包含你的 [視圖](/docs/laravel/10.x/views)，以及原始的、未編譯的資源文件，例如 CSS 或 JavaScript。

<a name="the-routes-directory"></a>
#### Routes 目錄

`routes` 目錄包含應用程序的所有路由定義。默認情況下，Laravel 包括幾個路由文件：`web.php`、`api.php`、`console.php` 和 `channels.php`。

`web.php` 文件包含 `RouteServiceProvider` 將放置在 `web` 中間件組中的路由，該組提供會話狀態、CSRF 保護和 cookie 加密。如果你的應用程序不提供無狀態的 RESTful API，則所有路由都很可能在 `web.php` 文件中定義。

`api.php` 文件包含 `RouteServiceProvider` 將放置在 `api` 中間件組中的路由。這些路由旨在是無狀態的，因此通過這些路由進入應用程序的請求旨在通過令牌進行身份驗證，並且不會訪問會話狀態。

`console.php` 文件是你可以在其中定義基於閉包的控制台命令的位置。每個閉包都綁定到一個命令實例，允許一種簡單的方法與每個命令的 IO 方法進行交互。即使此文件不定義 HTTP 路由，它也定義了基於控制台的入口點（路由）進入你的應用程序。

`channels.php` 文件是你可以在其中注冊所有應用程序支持的 [事件廣播](/docs/laravel/10.x/broadcasting) 頻道的位置。

<a name="the-storage-directory"></a>
#### Storage 目錄

`storage` 目錄包含日志、編譯後的 Blade 模板、基於文件的會話、文件緩存和框架生成的其他文件。該目錄分為 `app`、`framework` 和 `logs` 目錄。`app` 目錄可用於存儲應用程序生成的任何文件。`framework` 目錄用於存儲框架生成的文件和緩存。最後，`logs` 目錄包含應用程序的日志文件。

`storage/app/public` 目錄可用於存儲用戶生成的文件，例如個人資料頭像，應該是公開可訪問的。你應該在 `public/storage` 創建一個符號鏈接，該符號鏈接指向此目錄。你可以使用 `php artisan storage:link` Artisan 命令創建鏈接。

<a name="the-tests-directory"></a>
#### Tests 目錄

`tests` 目錄包含你的自動化測試。 開箱即用的示例 [PHPUnit](https://phpunit.de/) 單元測試和功能測試。 每個測試類都應以單詞「Test」作為後綴。 你可以使用 `phpunit` 或 `php vendor/bin/phpunit` 命令運行測試。 或者，如果你想要更詳細和更漂亮的測試結果表示，你可以使用 `php artisan test` Artisan 命令運行測試

<a name="the-vendor-directory"></a>
#### Vendor 目錄

`vendor` 目錄包含你的 [Composer](https://getcomposer.org/) 依賴項。

<a name="the-app-directory"></a>
## App 目錄

你的大部分應用程序都位於 `app` 目錄中。默認情況下，此目錄在 `App` 下命名，並由 Composer 使用 [PSR-4 自動加載標準] ([www.php-fig.org/psr/psr-4/](https://www.php-fig.org/psr/psr-4/)) 自動加載。

`app` 目錄包含各種附加目錄，例如 `Console`、`Http` 和 `Providers`。將 `Console` 和 `Http` 目錄視為為應用程序核心提供 API。 HTTP 協議和 CLI 都是與應用程序交互的機制，但實際上並不包含應用程序邏輯。換句話說，它們是向你的應用程序發出命令的兩種方式。 `Console` 目錄包含你的所有 Artisan 命令，而 `Http` 目錄包含你的控制器、中間件和請求。

當你使用 `make` Artisan 命令生成類時，會在 `app` 目錄中生成各種其他目錄。因此，例如，在你執行 `make:job` Artisan 命令生成作業類之前，`app/Jobs` 目錄將不存在。

> **技巧**
> `app` 目錄中的許多類可以由 Artisan 通過命令生成。 要查看可用命令，請在終端中運行 `php artisan list make` 命令。

<a name="the-broadcasting-directory"></a>
#### Broadcasting 目錄

`Broadcasting` 目錄包含應用程序的所有廣播頻道類。 這些類是使用 `make:channel` 命令生成的。 此目錄默認不存在，但會在你創建第一個頻道時為你創建。 要了解有關頻道的更多信息，請查看有關 [事件廣播](/docs/laravel/10.x/broadcasting) 的文檔。

<a name="the-console-directory"></a>
#### Console 目錄

`Console` 目錄包含應用程序的所有自定義 Artisan 命令。 這些命令可以使用 `make:command` 命令生成。 該目錄還包含你的控制台內核，這是你注冊自定義 Artisan 命令和定義 [計劃任務](/docs/laravel/10.x/scheduling) 的地方。

<a name="the-events-directory"></a>
#### Events 目錄

此目錄默認不存在，但會由 `event:generate` 和 `make:event` Artisan 命令為你創建。 `Events` 目錄包含 [事件類](/docs/laravel/10.x/events)。 事件可用於提醒應用程序的其他部分發生了給定的操作，從而提供了極大的靈活性和解耦性。

<a name="the-exceptions-directory"></a>
#### Exceptions 目錄

`Exceptions` 目錄包含應用程序的異常處理程序，也是放置應用程序拋出的任何異常的好地方。 如果你想自定義記錄或呈現異常的方式，你應該修改此目錄中的 `Handler` 類。

<a name="the-http-directory"></a>
#### Http 目錄

`Http` 目錄包含你的控制器、中間件和表單請求。 幾乎所有處理進入應用程序的請求的邏輯都將放在這個目錄中。

<a name="the-jobs-directory"></a>
#### Jobs 目錄

該目錄默認不存在，但如果你執行 `make:job` Artisan 命令，則會為你創建。 `Jobs` 目錄包含你的應用程序的 [隊列作業](/docs/laravel/10.x/queues)。 作業可能由你的應用程序排隊或在當前請求生命周期內同步運行。 在當前請求期間同步運行的作業有時被稱為「命令」，因為它們是 [命令模式](https://en.wikipedia.org/wiki/Command_pattern) 的實現。

<a name="the-listeners-directory"></a>
#### Listeners 目錄

此目錄默認不存在，但如果你執行 `event:generate` 或 `make:listener` Artisan 命令，則會為你創建。 `Listeners` 目錄包含處理你的 [events](/docs/laravel/10.x/events) 的類。 事件偵聽器接收事件實例並執行邏輯以響應被觸發的事件。 例如，`UserRegistered` 事件可能由 `SendWelcomeEmail` 監聽器處理。

<a name="the-mail-directory"></a>
#### Mail 目錄

該目錄默認不存在，但如果你執行 `make:mail` Artisan 命令，則會為你創建。 `Mail` 目錄包含你的應用程序發送的所有 [代表電子郵件的類](/docs/laravel/10.x/mail)。 Mail 對象允許你將構建電子郵件的所有邏輯封裝在一個簡單的類中，該類可以使用 `Mail::send` 方法發送。

<a name="the-models-directory"></a>
#### Models 目錄

`Models` 目錄包含所有 [Eloquent 模型類](/docs/laravel/10.x/eloquent)。 Laravel 中包含的 Eloquent ORM 提供了一個漂亮、簡單的 ActiveRecord 實現來處理你的數據庫。 每個數據庫表都有一個相應的「模型」，用於與該表進行交互。 模型允許你查詢表中的數據，以及將新記錄插入表中

<a name="the-notifications-directory"></a>
#### Notifications 目錄

默認情況下，此目錄不存在，但如果你執行 `make:notification` Artisan 命令時會自動生成。 `Notifications` 目錄包含所有你發送給應用程序的「事務性」 [消息通知](/docs/laravel/10.x/notifications) 。例如關於應用程序內發生的事件的簡單通知。Laravel 的通知功能抽象了通過各種驅動程序發送的通知，如電子郵件通知、Slack 信息、SMS 短信通知或數據庫存儲。

<a name="the-policies-directory"></a>
#### Policies 目錄

默認情況下，此目錄不存在，但如果你執行 `make:policy` Artisan 命令會生成。 `Policies` 目錄包含應用程序的 [授權策略類](/docs/laravel/10.x/authorization)。這些類用於確定用戶是否可以對資源執行給定的操作。

<a name="the-providers-directory"></a>
#### Providers 目錄

`Providers` 目錄包含程序中所有的 [服務提供者](/docs/laravel/10.x/providers)。服務提供者通過在服務容器中綁定服務、注冊事件或執行任何其他任務來引導應用程序以應對傳入請求。

在一個新的 Laravel 應用程序中，這個目錄已經包含了幾個提供者。你可以根據需要將自己的提供程序添加到此目錄。

<a name="the-rules-directory"></a>
#### Rules 目錄

默認情況下，此目錄不存在，但如果你執行 `make:rule` Artisan 命令後會生成。 `Rules` 目錄包含應用程序用戶自定義的驗證規則。這些驗證規則用於將覆雜的驗證邏輯封裝在一個簡單的對象中。有關更多信息，請查看 [表單驗證](/docs/laravel/10.x/validation)。
