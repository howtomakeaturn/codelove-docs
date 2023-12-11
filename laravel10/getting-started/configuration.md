# 配置信息

- [介紹](#introduction)
- [環境配置](#environment-configuration)
    - [環境變量類型](#environment-variable-types)
    - [檢索環境配置](#retrieving-environment-configuration)
    - [確定當前環境](#determining-the-current-environment)
    - [環境文件加密](#encrypting-environment-files)
- [訪問配置值](#accessing-configuration-values)
- [緩存配置](#configuration-caching)
- [調試模式](#debug-mode)
- [維護模式](#maintenance-mode)

## 介紹 {#introduction}

Laravel 框架的所有配置文件都存儲在`config`目錄中。每個選項都有文檔記錄，因此請隨意查看文件並熟悉可用的選項。

這些配置文件允許你配置諸如數據庫連接信息、郵件服務器信息以及各種其他核心配置值（例如應用程序時區和加密密鑰）之類的事項。

#### 應用概述 {#application-overview}

為了方便你可以通過`about`Artisan 命令快速了解應用程序的配置、驅動程序和環境：

```shell
php artisan about
```

如果只對應用程序概述輸出的特定部分感興趣，則可以使用`--only`選項過濾該部分：

```shell
php artisan about --only=environment
```
或者，如果你想詳細了解特定配置文件的值，你可以使用`config:show` Artisan命令：
```shell
php artisan config:show database
```

## 環境配置 {#environment-configuration}

根據應用程序運行的環境，有不同的配置值通常是有幫助的。例如，你可能希望在本地使用不同的緩存驅動程序，而在生產服務器上則使用另一個。

為了使這個過程變得簡單，Laravel 利用了 [DotEnv](https://github.com/vlucas/phpdotenv) PHP 庫。在新安裝的 Laravel 應用程序中，你的應用程序的根目錄將包含一個定義許多常見環境變量的`.env.example`文件。在 Laravel 安裝過程中，這個文件將自動被覆制到`.env`。

Laravel 的默認`.env`文件包含一些常見的配置值，這些值可能會根據你的應用程序是在本地運行還是在生產Web服務器上運行而有所不同。然後，這些值將使用 Laravel 的`env`函數從`config`目錄中的各種 Laravel 配置文件中檢索出來。

如果你正在與團隊一起開發，你可能希望繼續在你的應用程序中包含一個`.env.example`文件。通過在示例配置文件中放置占位符值，你的團隊中的其他開發人員可以清楚地看到運行你的應用程序需要哪些環境變量。

> **技巧**
> `.env`文件中的任何變量都可以被外部環境變量覆蓋，例如服務器級或系統級環境變量。

#### 環境文件安全 {#environment-file-security}

你的`.env`文件不應該提交到版本管理器中，首先，使用應用程序的每個開發人員 / 服務器可能需要不同的環境配置。其次，如果入侵者獲得了對版本管理器的訪問權限，這將成為一個安全風險，他將能看到配置文件中的敏感數據。

但是，可以使用 Laravel 的內置 [加密環境](#encrypting-environment-files)。加密環境文件可以安全地放置在源代碼管理中。

#### 附加環境文件 {#additional-environment-files}

在加載應用程序的環境變量之前，Laravel 會確定是否已經從外部提供了`APP_ENV`環境變量，或者是否指定了`--env`CLI 參數。如果是這樣，Laravel 將嘗試加載一個`.env.[APP_ENV]`文件（如果它存在）。 如果它不存在，將加載默認的`.env`文件。

### 環境變量類型 {#environment-variable-types}

`.env`文件中的所有變量通常都被解析為字符串，因此創建了一些保留值以允許你從`env()`函數返回更廣泛的類型：

| `.env` Value | `env()` Value |
|--------------|---------------|
| true         | (bool) true   |
| (true)       | (bool) true   |
| false        | (bool) false  |
| (false)      | (bool) false  |
| empty        | (string) ''   |
| (empty)      | (string) ''   |
| null         | (null) null   |
| (null)       | (null) null   |

如果你需要使用包含空格的值定義環境變量，可以通過將值括在雙引號中來實現：

```ini
APP_NAME="My Application"
```

### 獲取環境配置 {#retrieving-environment-configuration}

當應用程序收到請求時`.env`文件中列出的所有變量將被加載到 PHP 的超級全局變量`$_ENV`中。你可以使用`env`函數檢索這些變量的值。實際上，如果你看過 Laravel 的配置文件，就能注意到有數個選項已經使用了這個函數：

    'debug' => env('APP_DEBUG', false),

`env`函數的第二個參數是「默認值」。 當沒有找到對應環境變量時將返回 「默認值」。

### 獲取當前環境配置 {#determining-the-current-environment}

當前應用的環境配置是從你的`.env`文件中的`APP_ENV`變量配置的。你可以通過`App` [facade](/docs/laravel/10.x/facades) 的`environment`函數獲取：

    use Illuminate\Support\Facades\App;

    $environment = App::environment();

你還可以將參數傳遞給`environment`函數，以確定當前環境是否匹配給定的值。當環境匹配給參數它將返回`true`

    if (App::environment('local')) {
        // 當前環境是 local
    }

    if (App::environment(['local', 'staging'])) {
        // 當前環境是 local 或 staging ...
    }

> **技巧**
> 當前應用程序的環境檢測，可以通過定義服務器級`APP_ENV`環境變量來覆蓋。

### 環境文件加密 {#encrypting-environment-files}

未加密的環境文件不應該被存儲在源碼控制中. 然而, Laravel允許你加密你的環境文件, 這樣他們就可以安全地與你的應用程序的其他部分一起被添加到源碼控制中.

#### 加密 {#encryption}

為了加密環境文件，你可以使用`env:encrypt`命令。

```shell
php artisan env:encrypt
```

運行`env:encrypt`命令將加密你的`.env`文件，並將加密的內容放在`.env.encrypted`文件中。解密密鑰將出現在命令的輸出中，並應存儲在一個安全的密碼管理器中。如果你想提供你自己的加密密鑰，你可以在調用該命令時使用`--key`選項:

```shell
php artisan env:encrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF
```

> **注意**
> 所提供的密鑰的長度應該與所使用的加密密碼所要求的密鑰長度相匹配. 默認情況下, Laravel會使用`AES-256-CBC`密碼, 需要一個32個字符的密鑰. 你可以自由地使用Laravel的 [encrypter](/docs/laravel/10.x/encryption) 所支持的任何密碼，只要在調用該命令時傳遞`--cipher`選項即可。

如果你的應用程序有多個環境文件，如`.env`和`.env.staging`，你可以通過`--env`選項提供環境名稱來指定應該被加密的環境文件:

```shell
php artisan env:encrypt --env=staging
```

#### 解密 {#decryption}

要解密一個環境文件, 你可以使用`env:decrypt`命令. 這個命令需要一個解密密鑰, Laravel會從`LARAVEL_ENV_ENCRYPTION_KEY`環境變量中獲取.:

```shell
php artisan env:decrypt
```

或者，密鑰也可以通過 --key 選項直接提供給命令：

```shell
php artisan env:decrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF
```

當執行 `env:decrypt` 命令時，Laravel 將解密 	`.env.encrypted` 文件的內容，並將解密後的內容放置在 `.env` 文件中。

可以通過 `--cipher` 選項提供自定義加密算法的名稱給 `env:decrypt` 命令：

```shell
php artisan env:decrypt --key=qUWuNRdfuImXcKxZ --cipher=AES-128-CBC
```

如果你的應用程序有多個環境文件，例如 `.env` 和 	`.env.staging`，可以通過 `--env` 選項提供環境名稱來指定應該解密的環境文件：

```shell
php artisan env:decrypt --env=staging
```

為了覆蓋現有的環境文件，可以在 `env:decrypt` 命令中提供 `--force` 選項：

```shell
php artisan env:decrypt --force
```

## 訪問配置值 {#accessing-configuration-values}

你可以在應用程序的任何地方使用全局 `config` 函數輕松訪問你的配置值。可以使用 "點" 語法來訪問配置值，其中包括你希望訪問的文件和選項的名稱。如果配置選項不存在，則可以指定默認值，如果不存在則返回默認值：

    $value = config('app.timezone');

    // 如果配置值不存在，則檢索默認值...
    $value = config('app.timezone', 'Asia/Seoul');

要在運行時設置配置值，請將數組傳遞給 `config` 函數：

    config(['app.timezone' => 'America/Chicago']);

## 配置緩存 {#configuration-caching}

為了提高應用程序的速度，你應該使用`config:cache`Artisan 命令將所有配置文件緩存到一個文件中。 這會將應用程序的所有配置選項組合到一個文件中，框架可以快速加載該文件。

你通常應該在生產部署過程中運行`php artisan config:cache` 命令。 該命令不應在本地開發期間運行，因為在應用程序開發過程中經常需要更改配置選項。

一旦配置被緩存，應用程序的。`.env`文件將不會在請求或 Artisan 命令期間被框架加載；因此， `env`函數將只返回外部的系統級環境變量。

因此，應確保僅從應用程序的配置`config`文件中調用`env`函數。通過檢查 Laravel 的默認配置文件，你可以看到許多示例。可以使用`config`函數從應用程序中的任何位置訪問配置值 [如上所述](#accessing-configuration-values)。

> **注意**
> 如果你在部署過程中執行`config:cache`命令，則應確保僅從配置文件中調用`env`函數。一旦配置被緩存，`.env`文件將不會被加載；因此，`env`函數只會返回外部的系統級環境變量。

## 調試模式 {#debug-mode}

`config/app.php`配置文件中的`debug`選項決定了實際向用戶顯示的錯誤信息量。 默認情況下，此選項設置為尊重`APP_DEBUG`環境變量的值，該變量存儲在你的`.env`文件中。

對於本地開發，你應該將`APP_DEBUG`環境變量設置為`true`。 **在你的生產環境中，此值應始終為`false`。 如果在生產環境中將該變量設置為`true`，你可能會將敏感的配置值暴露給應用程序的最終用戶。**

## 維護模式 {#maintenance-mode}

當你的應用程序處於維護模式時，將為你的應用程序的所有請求顯示一個自定義視圖。 這使得在更新或執行維護時可以輕松「禁用」你的應用程序。 維護模式檢查包含在應用程序的默認中間件堆棧中。 如果應用程序處於維護模式，則會拋出一個`Symfony\Component\HttpKernel\Exception\HttpException`實例，狀態碼為 503。

要啟用維護模式，請執行`down`Artisan 命令：

```shell
php artisan down
```

如果你希望`Refresh` HTTP 標頭與所有維護模式響應一起發送，你可以在調用`down`命令時提供`refresh`選項。`Refresh` 標頭將指示瀏覽器在指定秒數後自動刷新頁面：

```shell
php artisan down --refresh=15
```

你還可以為`down`命令提供`retry` 選項，該選項將設置為`Retry-After` HTTP 標頭的值，盡管瀏覽器通常會忽略此標頭：

```shell
php artisan down --retry=60
```

#### 繞過維護模式 {#bypassing-maintenance-mode}

即使在維護模式下，你也可以使用`secret`選項來指定維護模式繞過令牌：

```shell
php artisan down --secret="1630542a-246b-4b66-afa1-dd72a4c43515"
```

將應用程序置於維護模式後，你可以訪問與該令牌匹配的應用程序 URL，Laravel 將為你的瀏覽器頒發一個維護模式繞過 cookie：
```shell
https://example.com/1630542a-246b-4b66-afa1-dd72a4c43515
```
當訪問此隱藏路由時，你將被重定向到應用程序的`/`路徑。一旦 cookie 被頒發到你的瀏覽器，你就可以像維護模式不存在一樣正常瀏覽應用程序。

> **技巧**
> 你的維護模式 secret 通常應由字母數字字符和可選的破折號組成。應避免使用 URL 中具有特殊含義的字符，例如 `?`。

#### 預渲染維護模式視圖 {#pre-rendering-the-maintenance-mode-view}

如果在部署期間中使用 `php artisan down` 命令，當你的 Composer 依賴或其基礎組件更新的時候，你的用戶也可能遇到偶然性的錯誤。這是因為 Laravel 框架的重要部分必須啟動才能確定應用程序處於維護模式，並使用模板引擎呈現維護模式視圖。

因此，Laravel 允許你預渲染一個維護模式視圖，該視圖將在請求周期的最開始返回。此視圖在加載應用程序的任何依賴項之前呈現。可以使用 `down` 命令的 `render` 選項預渲染所選模板：

```shell
php artisan down --render="errors::503"
```

#### 重定向維護模式請求 {#redirecting-maintenance-mode-requests}

在維護模式下，Laravel 將顯示用戶試圖訪問的所有應用程序 url 的維護模式視圖。如果你願意，你可以指示 Laravel 重定向所有請求到一個特定的 URL。這可以使用 `redirect` 選項來實現。例如，你可能希望將所有請求重定向到 `/` URI：

```shell
php artisan down --redirect=/
```

#### 禁用維護模式 {#disabling-maintenance-mode}

要禁用維護模式，請使用 `up` 命令：

```shell
php artisan up
```

> **技巧**
> 你可以通過在`resources/views/errors/503.blade.php`中定義自己的維護模式模板。

#### 維護模式 & 隊列 {#maintenance-mode-queues}

當應用程序處於維護模式時，將不會處理任何 [隊列任務](/docs/laravel/10.x/queues)。一旦應用程序退出維護模式，像往常一樣繼續處理。

#### 維護模式的替代方法 {#alternatives-to-maintenance-mode}

由於維護模式要求你的應用程序有幾秒鐘的停機時間，因此你可以考慮使用 [Laravel Vapor](https://vapor.laravel.com) 和 [Envoyer](https://envoyer.io) 等替代方案來實現 Laravel 零停機部署。
