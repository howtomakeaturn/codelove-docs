
# 服務提供者

- [簡介](#introduction)
- [編寫服務提供者](#writing-service-providers)
    - [注冊方法](#the-register-method)
    - [引導方法](#the-boot-method)
- [注冊提供者](#registering-providers)
- [延遲加載提供者](#deferred-providers)

<a name="introduction"></a>
## 簡介

服務提供者是所有 Laravel 應用程序的引導中心。你的應用程序，以及通過服務器引導的 Laravel 核心服務都是通過服務提供器引導。

但是，「引導」是什麽意思呢？通常，我們可以理解為**注冊**，比如注冊服務容器綁定，事件監聽器，中間件，甚至是路由。服務提供者是配置應用程序的中心。

當你打開 Laravel 的`config/app.php`  文件時，你會看到 `providers`數組。數組中的內容是應用程序要加載的所有服務提供者的類。當然，其中有很多「延遲」提供者，他們並不會在每次請求的時候都加載，只有他們的服務實際被需要時才會加載。

本篇你將會學到如何編寫自己的服務提供者，並將其注冊到你的 Laravel 應用程序中。

> **技巧 **
> 如果你想了解有關 Laravel 如何處理請求並在內部工作的更多信息，請查看有關 Laravel 的文檔 [請求生命周期](/docs/laravel/10.x/lifecycle)。

<a name="writing-service-providers"></a>
## 編寫服務提供者

所有的服務提供者都會繼承`Illuminate\Support\ServiceProvider`類。大多服務提供者都包含一個 register 和一個`boot`方法。在`register`方法中，你只需要將服務綁定到 `register` 方法中， 你只需要 **將服務綁定到 [服務容器](/docs/laravel/10.x/container)**。而不要嘗試在`register`方法中注冊任何監聽器，路由，或者其他任何功能。



使用 Artisan 命令行工具，通過 `make:provider` 命令可以生成一個新的提供者：

```shell
php artisan make:provider RiakServiceProvider
```

<a name="the-register-method"></a>
### 注冊方法

如上所述，在 `register` 方法中，你只需要將服務綁定到 [服務容器](/docs/laravel/9.x/container) 中。而不要嘗試在 `register` 方法中注冊任何監聽器，路由，或者其他任何功能。否則，你可能會意外地使用到尚未加載的服務提供者提供的服務。

讓我們來看一個基礎的服務提供者。在任何服務提供者方法中，你總是通過 $app 屬性來訪問服務容器：

    <?php

    namespace App\Providers;

    use App\Services\Riak\Connection;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\ServiceProvider;

    class RiakServiceProvider extends ServiceProvider
    {
        /**
         * 注冊應用服務
         */
        public function register(): void
        {
            $this->app->singleton(Connection::class, function (Application $app) {
                return new Connection(config('riak'));
            });
        }
    }

這個服務提供者只是定義了一個 `register` 方法，並且使用這個方法在服務容器中定義了一個 `Riak\Connection` 接口。如果你不理解服務容器的工作原理，請查看其 [文檔](/docs/laravel/10.x/container).

<a name="bindings 和 singletons 的特性"></a>
#### bindings 和 singletons 的特性

如果你的服務提供器注冊了許多簡單的綁定，你可能想用 `bindings` 和 `singletons` 屬性替代手動注冊每個容器綁定。當服務提供器被框架加載時，將自動檢查這些屬性並注冊相應的綁定：

    <?php

    namespace App\Providers;

    use App\Contracts\DowntimeNotifier;
    use App\Contracts\ServerProvider;
    use App\Services\DigitalOceanServerProvider;
    use App\Services\PingdomDowntimeNotifier;
    use App\Services\ServerToolsProvider;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         *  所有需要注冊的容器綁定
         *
         * @var array
         */
        public $bindings = [
            ServerProvider::class => DigitalOceanServerProvider::class,
        ];

        /**
         * 所有需要注冊的容器單例
         *
         * @var array
         */
        public $singletons = [
            DowntimeNotifier::class => PingdomDowntimeNotifier::class,
            ServerProvider::class => ServerToolsProvider::class,
        ];
    }



<a name="引導方法"></a>
### 引導方法

如果我們要在服務提供者中注冊一個 [視圖合成器](/docs/laravel/10.x/views#view-composers) 該怎麽做？這就需要用到 `boot` 方法了。**該方法在所有服務提供者被注冊以後才會被調用**，這就是說我們可以在其中訪問框架已注冊的所有其它服務：

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\View;
    use Illuminate\Support\ServiceProvider;

    class ComposerServiceProvider extends ServiceProvider
    {
        /**
         * 啟動所有的應用服務
         */
        public function boot(): void
        {
            View::composer('view', function () {
                // ...
            });
        }
    }

<a name="啟動方法的依賴注入"></a>
#### 啟動方法的依賴注入

你可以為服務提供者的 `boot` 方法設置類型提示。[服務容器](/docs/laravel/10.x/container) 會自動注入你所需要的依賴：

    use Illuminate\Contracts\Routing\ResponseFactory;

    /**
     * 引導所有的應用服務
     */
    public function boot(ResponseFactory $response): void
    {
        $response->macro('serialized', function (mixed $value) {
            // ...
        });
    }

<a name="注冊服務提供者"></a>
## 注冊服務提供者

所有服務提供者都是通過配置文件 `config/app.php` 進行注冊。該文件包含了一個列出所有服務提供者名字的 `providers` 數組，默認情況下，其中列出了所有核心服務提供者，這些服務提供者啟動 Laravel 核心組件，比如郵件、隊列、緩存等等。

要注冊提供器，只需要將其添加到數組：

    'providers' => [
        // 其他服務提供者

        App\Providers\ComposerServiceProvider::class,
    ],

<a name="延遲加載提供者"></a>
## 延遲加載提供者

如果你的服務提供者 **只** 在 [服務容器](/docs/laravel/10.x/container)中注冊，可以選擇延遲加載該綁定直到注冊綁定的服務真的需要時再加載，延遲加載這樣的一個提供者將會提升應用的性能，因為它不會在每次請求時都從文件系統加載。



Laravel 編譯並保存延遲服務提供者提供的所有服務的列表，以及其服務提供者類的名稱。因此，只有當你在嘗試解析其中一項服務時，Laravel 才會加載服務提供者。

要延遲加載提供者，需要實現 `\Illuminate\Contracts\Support\DeferrableProvider` 接口並置一個 `provides` 方法。這個 `provides` 方法返回該提供者注冊的服務容器綁定：

    <?php

    namespace App\Providers;

    use App\Services\Riak\Connection;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Contracts\Support\DeferrableProvider;
    use Illuminate\Support\ServiceProvider;

    class RiakServiceProvider extends ServiceProvider implements DeferrableProvider
    {
        /**
         * 注冊所有的應用服務
         */
        public function register(): void
        {
            $this->app->singleton(Connection::class, function (Application $app) {
                return new Connection($app['config']['riak']);
            });
        }

        /**
         * 獲取服務提供者的服務
         *
         * @return array<int, string>
         */
        public function provides(): array
        {
            return [Connection::class];
        }
    }
