# 包開發

- [介紹](#introduction)
    - [關於 Facades](#a-note-on-facades)
- [包發現](#package-discovery)
- [服務提供者](#service-providers)
- [資源](#resources)
    - [配置](#configuration)
    - [遷移](#migrations)
    - [路由](#routes)
    - [語言文件](#language-files)
    - [視圖](#views)
    - [視圖組件](#view-components)
    - ["About" Artisan 命令](#about-artisan-command)
- [命令](#commands)
- [公共資源](#public-assets)
- [發布文件組](#publishing-file-groups)

<a name="introduction"></a>
## 介紹

包是向 Laravel 添加功能的主要方式。包可能是處理日期的好方法，例如 [Carbon](https://github.com/briannesbitt/Carbon)，也可能是允許您將文件與 Eloquent 模型相關聯的包，例如 Spatie 的 [Laravel 媒體庫](https://github.com/spatie/laravel-medialibrary)。

包有不同類型。有些包是獨立的，這意味著它們可以與任何 PHP 框架一起使用。 Carbon 和 PHPUnit 是獨立包的示例。這種包可以通過 `composer.json` 文件引入，在 Laravel 中使用。

此外，還有一些包是專門用在 Laravel 中。這些包可能包含路由、控制器、視圖和配置，專門用於增強 Laravel 應用。本教程主要涵蓋的就是這些專用於 Laravel 的包的開發。

<a name="a-note-on-facades"></a>
### 關於 Facades

編寫 Laravel 應用時，通常使用契約（Contracts）還是門面（Facades）並不重要，因為兩者都提供了基本相同的可測試性級別。但是，在編寫包時，包通常是無法使用 Laravel 的所有測試輔助函數。如果您希望能夠像將包安裝在典型的 Laravel 應用程序中一樣編寫包測試，您可以使用 [Orchestral Testbench](https://github.com/orchestral/testbench) 包。


<a name="package-discovery"></a>
## 包發現

在 Laravel 應用程序的 `config/app.php` 配置文件中，providers 選項定義了 Laravel 應該加載的服務提供者列表。當有人安裝您的軟件包時，您通常希望您的服務提供者也包含在此列表中。 您可以在包的 `composer.json` 文件的 `extra` 部分中定義提供者，而不是要求用戶手動將您的服務提供者添加到列表中。除了服務提供者外，您還可以列出您想注冊的任何 [facades](/docs/laravel/10.x/facades)：

```json
"extra": {
    "laravel": {
        "providers": [
            "Barryvdh\\Debugbar\\ServiceProvider"
        ],
        "aliases": {
            "Debugbar": "Barryvdh\\Debugbar\\Facade"
        }
    }
},
```

當你的包配置了包發現後，Laravel 會在安裝該包時自動注冊服務提供者及 Facades，這樣就為你的包用戶創造一個便利的安裝體驗。

<a name="opting-out-of-package-discovery"></a>
### 退出包發現

如果你是包消費者，要禁用包發現功能，你可以在應用的 `composer.json` 文件的 `extra` 區域列出包名：

```json
"extra": {
    "laravel": {
        "dont-discover": [
            "barryvdh/laravel-debugbar"
        ]
    }
},
```

你可以在應用的 `dont-discover` 指令中使用 `*` 字符，禁用所有包的包發現功能：

```json
"extra": {
    "laravel": {
        "dont-discover": [
            "*"
        ]
    }
},
```

<a name="service-providers"></a>
## 服務提供者

[服務提供者](/docs/laravel/10.x/providers)是你的包和 Laravel 之間的連接點。服務提供者負責將事物綁定到 Laravel 的[服務容器](/docs/laravel/10.x/container)並告知 Laravel 到哪里去加載包資源，比如視圖、配置及語言文件。



服務提供者擴展了 `Illuminate/Support/ServiceProvider` 類，包含兩個方法： `register` 和 `boot`。基本的 `ServiceProvider` 類位於 `illuminate/support` Composer 包中，你應該把它添加到你自己包的依賴項中。要了解更多關於服務提供者的結構和目的，請查看 [服務提供者](/docs/laravel/10.x/providers).

<a name="resources"></a>
## 資源

<a name="configuration"></a>
### 配置

通常情況下，你需要將你的包的配置文件發布到應用程序的 `config` 目錄下。這將允許在使用包時覆蓋擴展包中的默認配置選項。發布配置文件，需要在服務提供者的 `boot` 方法中調用 `publishes` 方法:

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->publishes([
            __DIR__.'/../config/courier.php' => config_path('courier.php'),
        ]);
    }

使用擴展包的時候執行 Laravel 的 `vendor:publish` 命令, 你的文件將被覆制到指定的發布位置。 一旦你的配置被發布, 它的值可以像其他的配置文件一樣被訪問:

    $value = config('courier.option');

> **Warning**
> 你不應該在你的配置文件中定義閉包。當用戶執行 `config:cache` Artisan 命令時，它們不能被正確序列化。

<a name="default-package-configuration"></a>
#### 默認的包配置

你也可以將你自己的包的配置文件與應用程序的發布副本合並。這將允許你的用戶在配置文件的發布副本中只定義他們真正想要覆蓋的選項。要合並配置文件的值，請使用你的服務提供者的 `register` 方法中的 `mergeConfigFrom` 方法。



`mergeConfigFrom` 方法的第一個參數為你的包的配置文件的路徑，第二個參數為應用程序的配置文件副本的名稱：

    /**
     * 注冊應用程序服務
     */
    public function register(): void
    {
        $this->mergeConfigFrom(
            __DIR__.'/../config/courier.php', 'courier'
        );
    }

> **Warning**
> 這個方法只合並了配置數組的第一層。如果你的用戶部分地定義了一個多維的配置陣列，缺少的選項將不會被合並。

<a name="routes"></a>
### 路由

如果你的軟件包包含路由，你可以使用 `loadRoutesFrom` 方法加載它們。這個方法會自動判斷應用程序的路由是否被緩存，如果路由已經被緩存，則不會加載你的路由文件：

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__.'/../routes/web.php');
    }

<a name="migrations"></a>
### 遷移

如果你的軟件包包含了 [數據庫遷移](/docs/laravel/10.x/migrations) , 你可以使用 `loadMigrationsFrom` 方法來加載它們。`loadMigrationsFrom` 方法的參數為軟件包遷移文件的路徑。

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->loadMigrationsFrom(__DIR__.'/../database/migrations');
    }

一旦你的軟件包的遷移被注冊，當 `php artisan migrate` 命令被執行時，它們將自動被運行。你不需要把它們導出到應用程序的 `database/migrations` 目錄中。

<a name="language-files"></a>
### 語言文件

如果你的軟件包包含 [語言文件](/docs/laravel/10.x/localization) , 你可以使用 `loadTranslationsFrom` 方法來加載它們。 例如, 如果你的包被命名為 `courier` , 你應該在你的服務提供者的 `boot` 方法中加入以下內容:

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->loadTranslationsFrom(__DIR__.'/../lang', 'courier');
    }



包的翻譯行是使用 `package::file.line` 的語法慣例來引用的。因此，你可以這樣從 `messages` 文件中加載 `courier` 包的 `welcome` 行：

    echo trans('courier::messages.welcome');

<a name="publishing-language-files"></a>
#### 發布語言文件

如果你想把包的語言文件發布到應用程序的 `lang/vendor` 目錄，可以使用服務提供者的 `publishes` 方法。`publishes` 方法接受一個軟件包路徑和它們所需的發布位置的數組。例如，要發布 `courier` 包的語言文件，你可以做以下工作：

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->loadTranslationsFrom(__DIR__.'/../lang', 'courier');

        $this->publishes([
            __DIR__.'/../lang' => $this->app->langPath('vendor/courier'),
        ]);
    }

當你的軟件包的用戶執行Laravel的 `vendor:publish` Artisan 命令時, 你的軟件包的語言文件會被發布到指定的發布位置。

<a name="views"></a>
### 視圖

要在 Laravel 注冊你的包的 [視圖](/docs/laravel/10.x/views) , 你需要告訴 Laravel 這些視圖的位置. 你可以使用服務提供者的 `loadViewsFrom` 方法來完成。`loadViewsFrom` 方法接受兩個參數: 視圖模板的路徑和包的名稱。 例如，如果你的包的名字是 `courier`，你可以在服務提供者的 `boot` 方法中加入以下內容：

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->loadViewsFrom(__DIR__.'/../resources/views', 'courier');
    }

包的視圖是使用 `package::view` 的語法慣例來引用的。因此，一旦你的視圖路徑在服務提供者中注冊，你可以像這樣從 `courier` 包中加載 `dashboard` 視圖。

    Route::get('/dashboard', function () {
        return view('courier::dashboard');
    });



<a name="overriding-package-views"></a>
#### 覆蓋包的視圖

當你使用 `loadViewsFrom` 方法時, Laravel 實際上為你的視圖注冊了兩個位置: 應用程序的 `resources/views/vendor` 目錄和你指定的目錄。 所以, 以 `courier` 包為例, Laravel 首先會檢查視圖的自定義版本是否已經被開發者放在 `resources/views/vendor/courier` 目錄中。 然後, 如果視圖沒有被定制, Laravel 會搜索你在調用 `loadViewsFrom` 時指定的包的視圖目錄. 這使得包的用戶可以很容易地定制/覆蓋你的包的視圖。

<a name="publishing-views"></a>
#### 發布視圖

如果你想讓你的視圖可以發布到應用程序的 `resources/views/vendor` 目錄下，你可以使用服務提供者的 `publishes` 方法。`publishes` 方法接受一個數組的包視圖路徑和它們所需的發布位置：

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->loadViewsFrom(__DIR__.'/../resources/views', 'courier');

        $this->publishes([
            __DIR__.'/../resources/views' => resource_path('views/vendor/courier'),
        ]);
    }

當你的包的用戶執行 Laravel 的 `vendor:publish` Artisan 命令時, 你的包的視圖將被覆制到指定的發布位置。

<a name="view-components"></a>
### 視圖組件

如果你正在建立一個用 Blade 組件的包，或者將組件放在非傳統的目錄中，你將需要手動注冊你的組件類和它的 HTML 標簽別名，以便 Laravel 知道在哪里可以找到這個組件。你通常應該在你的包的服務提供者的 `boot` 方法中注冊你的組件:

    use Illuminate\Support\Facades\Blade;
    use VendorPackage\View\Components\AlertComponent;

    /**
     * 引導你的包的服務
     */
    public function boot(): void
    {
        Blade::component('package-alert', AlertComponent::class);
    }



當組件注冊成功後，你就可以使用標簽別名對其進行渲染：

```blade
<x-package-alert/>
```

<a name="autoloading-package-components"></a>
#### 自動加載包組件

此外，你可以使用 `compoentNamespace` 方法依照規範自動加載組件類。比如，`Nightshade` 包中可能有 `Calendar` 和 `ColorPicker` 組件，存在於 `Nightshade\Views\Components` 命名空間中：

    use Illuminate\Support\Facades\Blade;

    /**
     * 啟動包服務
     */
    public function boot(): void
    {
        Blade::componentNamespace('Nightshade\\Views\\Components', 'nightshade');
    }

我們可以使用 `package-name::` 語法，通過包提供商的命名空間調用包組件：

```blade
<x-nightshade::calendar />
<x-nightshade::color-picker />
```

Blade 會通過組件名自動檢測鏈接到該組件的類。子目錄也支持使用'點'語法。

<a name="anonymous-components"></a>
#### 匿名組件

如果包中有匿名組件，則必須將它們放在包的視圖目錄(由[`loadViewsFrom` 方法](#views)指定)的 `components` 文件夾下。然後，你就可以通過在組件名的前面加上包視圖的命名空間來對其進行渲染了：

```blade
<x-courier::alert />
```

<a name="about-artisan-command"></a>
### "About" Artisan 命令

Laravel 內建的 `about` Artisan 命令提供了應用環境和配置的摘要信息。包可以通過 `AboutCommand` 類為該命令輸出添加附加信息。一般而言，這些信息可以在包服務提供者的 `boot` 方法中添加：

    use Illuminate\Foundation\Console\AboutCommand;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        AboutCommand::add('My Package', fn () => ['Version' => '1.0.0']);
    }

<a name="commands"></a>
## 命令

要在 Laravel 中注冊你的包的 Artisan 命令，你可以使用 `commands` 方法。 此方法需要一個命令類名稱數組。 注冊命令後，您可以使用 [Artisan CLI](https://learnku.com/docs/laravel/9.x/artisan) 執行它們：

    use Courier\Console\Commands\InstallCommand;
    use Courier\Console\Commands\NetworkCommand;

    /**
     * Bootstrap any package services.
     */
    public function boot(): void
    {
        if ($this->app->runningInConsole()) {
            $this->commands([
                InstallCommand::class,
                NetworkCommand::class,
            ]);
        }
    }



<a name="public-assets"></a>
## 公共資源

你的包可能有諸如 JavaScript 、CSS 和圖片等資源。要發布這些資源到應用程序的 `public` 目錄，請使用服務提供者的 `publishes` 方法。在下面例子中，我們還將添加一個 `public` 資源組標簽，它可以用來輕松發布相關資源組：

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->publishes([
            __DIR__.'/../public' => public_path('vendor/courier'),
        ], 'public');
    }

當你的軟件包的用戶執行 `vendor:publish` 命令時，你的資源將被覆制到指定的發布位置。通常用戶需要在每次更新包的時候都要覆蓋資源，你可以使用 `--force` 標志。

```shell
php artisan vendor:publish --tag=public --force
```

<a name="publishing-file-groups"></a>
## 發布文件組

你可能想單獨發布軟件包的資源和資源組。例如，你可能想讓你的用戶發布你的包的配置文件，而不被強迫發布你的包的資源。你可以通過在調用包的服務提供者的 `publishes` 方法時對它們進行 `tagging` 來做到這一點。例如，讓我們使用標簽在軟件包服務提供者的 `boot` 方法中為 `courier` 軟件包定義兩個發布組（ `courier-config` 和 `courier-migrations` ）。

    /**
     * 引導包服務
     */
    public function boot(): void
    {
        $this->publishes([
            __DIR__.'/../config/package.php' => config_path('package.php')
        ], 'courier-config');

        $this->publishes([
            __DIR__.'/../database/migrations/' => database_path('migrations')
        ], 'courier-migrations');
    }

現在你的用戶可以在執行 `vendor:publish` 命令時引用他們的標簽來單獨發布這些組。

```shell
php artisan vendor:publish --tag=courier-config
```
