# Facades

- [簡介](#introduction)
- [何時使用 Facades](#when-to-use-facades)
    - [Facades Vs 依賴注入](#facades-vs-dependency-injection)
    - [Facades Vs 助手函數](#facades-vs-helper-functions)
- [Facades 工作原理](#how-facades-work)
- [實時 Facades](#real-time-facades)
- [Facade 參考類](#facade-class-reference)

<a name="introduction"></a>
## 簡介

在整個 Laravel 文檔中，你將看到通過 Facades 與 Laravel 特性交互的代碼示例。Facades 為應用程序的[服務容器](/docs/laravel/10.x/container)中可用的類提供了「靜態代理」。在 Laravel 這艘船上有許多 Facades，提供了幾乎所有 Laravel 的特征。

Laravel Facades 充當服務容器中底層類的「靜態代理」，提供簡潔、富有表現力的好處，同時保持比傳統靜態方法更多的可測試性和靈活性。如果你不完全理解引擎蓋下的 Facades 是如何工作的，那也沒問題，跟著流程走，繼續學習 Laravel。

Laravel 的所有 Facades 都在`Illuminate\Support\Facades`命名空間中定義。因此，我們可以很容易地訪問這樣一個 Facades ：

    use Illuminate\Support\Facades\Cache;
    use Illuminate\Support\Facades\Route;

    Route::get('/cache', function () {
        return Cache::get('key');
    });

在整個 Laravel 文檔中，許多示例將使用 Facades 來演示框架的各種特性。

<a name="helper-functions"></a>
#### 輔助函數

為了補充 Facades，Laravel 提供了各種全局 「助手函數」，使它更容易與常見的 Laravel 功能進行交互。可以與之交互的一些常用助手函數有`view`, `response`, `url`, `config`等。Laravel 提供的每個助手函數都有相應的特性；但是，在專用的[輔助函數文檔](/docs/laravel/10.x/helpers)中有一個完整的列表。



例如，我們可以使用 `response` 函數而不是 `Illuminate\Support\Facades\Response` Facade 生成 JSON 響應。由於「助手函數」是全局可用的，因此無需導入任何類即可使用它們：

```php
use Illuminate\Support\Facades\Response;

Route::get('/users', function () {
    return Response::json([
        // ...
    ]);
});

Route::get('/users', function () {
    return response()->json([
        // ...
    ]);
});
```

<a name="when-to-use-facades"></a>

## 何時使用 Facades

Facades 有很多好處。它們提供了簡潔、易記的語法，讓你可以使用 Laravel 的功能而不必記住必須手動注入或配置的長類名。此外，由於它們獨特地使用了 PHP 的動態方法，因此它們易於測試。

然而，在使用 Facades 時必須小心。Facades 的主要危險是類的「作用域泄漏」。由於 Facades 如此易於使用並且不需要注入，因此讓你的類繼續增長並在單個類中使用許多 Facades 可能很容易。使用依賴注入，這種潛在問題通過構造函數變得明顯，告訴你的類過於龐大。因此，在使用 Facades 時，需要特別關注類的大小，以便它的責任範圍保持狹窄。如果你的類變得太大，請考慮將它拆分成多個較小的類。

<a name="facades-vs-dependency-injection"></a>

### Facades 與 依賴注入

依賴注入的主要好處之一是能夠替換注入類的實現。這在測試期間很有用，因為你可以注入一個模擬或存根並斷言各種方法是否在存根上調用了。

通常，真正的靜態方法是不可能 mock 或 stub 的。無論如何，由於 Facades 使用動態方法對服務容器中解析出來的對象方法的調用進行了代理， 我們也可以像測試注入類實例一樣測試 Facades。比如，像下面的路由：

    use Illuminate\Support\Facades\Cache;

    Route::get('/cache', function () {
        return Cache::get('key');
    });

使用 Laravel 的 Facade 測試方法，我們可以編寫以下測試用例來驗證是否 Cache::get 使用我們期望的參數調用了該方法：

    use Illuminate\Support\Facades\Cache;

    /**
     *  一個基礎功能的測試用例
     */
    public function test_basic_example(): void
    {
        Cache::shouldReceive('get')
             ->with('key')
             ->andReturn('value');

        $response = $this->get('/cache');

        $response->assertSee('value');
    }

<a name="facades-vs-helper-functions"></a>
### Facades Vs 助手函數

除了 Facades，Laravel 還包含各種「輔助函數」來實現這些常用功能，比如生成視圖、觸發事件、任務調度或者發送 HTTP 響應。許多輔助函數都有與之對應的 Facade。例如，下面這個 Facades 和輔助函數的作用是一樣的：

    return Illuminate\Support\Facades\View::make('profile');

    return view('profile');

Facades 和輔助函數之間沒有實際的區別。 當你使用輔助函數時，你可以像測試相應的 Facade 那樣進行測試。例如，下面的路由：

    Route::get('/cache', function () {
        return cache('key');
    });

在底層實現，輔助函數 cache 實際是調用 Cache 這個 Facade 的 get 方法。因此，盡管我們使用的是輔助函數，我們依然可以帶上我們期望的參數編寫下面的測試代碼來驗證該方法：

    use Illuminate\Support\Facades\Cache;

    /**
     * 一個基礎功能的測試用例
     */
    public function test_basic_example(): void
    {
        Cache::shouldReceive('get')
             ->with('key')
             ->andReturn('value');

        $response = $this->get('/cache');

        $response->assertSee('value');
    }



<a name="how-facades-work"></a>
## Facades 工作原理

在 Laravel 應用程序中，Facades 是一個提供從容器訪問對象的類。完成這項工作的部分屬於 `Facade` 類。Laravel 的 Facade、以及你創建的任何自定義 Facade，都繼承自 `Illuminate\Support\Facades\Facade` 類。

`Facade` 基類使用 `__callStatic()` 魔術方法將來自 Facade 的調用推遲到從容器解析出對象後。在下面的示例中，調用了 Laravel 緩存系統。看一眼這段代碼，人們可能會假設靜態的 `get` 方法正在 `Cache` 類上被調用：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Support\Facades\Cache;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Show the profile for the given user.
         */
        public function showProfile(string $id): View
        {
            $user = Cache::get('user:'.$id);

            return view('profile', ['user' => $user]);
        }
    }

請注意，在文件頂部附近，我們正在「導入」`Cache` Facade。這個 Facade 作為訪問 `Illuminate\Contracts\Cache\Factory` 接口底層實現的代理。我們使用 Facade 進行的任何調用都將傳遞給 Laravel 緩存服務的底層實例。

如果我們查看 `Illuminate\Support\Facades\Cache` 類，你會發現沒有靜態方法 `get`：

    class Cache extends Facade
    {
        /**
         * Get the registered name of the component.
         */
        protected static function getFacadeAccessor(): string
        {
            return 'cache';
        }
    }

相反，`Cache` Facade 繼承了 `Facade` 基類並定義了 `getFacadeAccessor()` 方法。此方法的工作是返回服務容器綁定的名稱。當用戶引用 `Cache` Facade 上的任何靜態方法時，Laravel 會從 [服務容器](/docs/laravel/10.x/container) 中解析 `cache` 綁定並運行該對象請求的方法（在這個例子中就是 `get` 方法）



<a name="real-time-facades"></a>
## 實時 Facades

使用實時 Facade, 你可以將應用程序中的任何類視為 Facade。為了說明這是如何使用的， 讓我們首先看一下一些不使用實時 Facade 的代碼。例如，假設我們的 `Podcast` 模型有一個 `publish 方法`。 但是，為了發布 `Podcast`，我們需要注入一個 `Publisher` 實例：

    <?php

    namespace App\Models;

    use App\Contracts\Publisher;
    use Illuminate\Database\Eloquent\Model;

    class Podcast extends Model
    {
        /**
         * Publish the podcast.
         */
        public function publish(Publisher $publisher): void
        {
            $this->update(['publishing' => now()]);

            $publisher->publish($this);
        }
    }

將 publisher 的實現注入到該方法中，我們可以輕松地測試這種方法，因為我們可以模擬注入的 publisher 。但是，它要求我們每次調用 `publish` 方法時始終傳遞一個 publisher 實例。 使用實時的 Facades, 我們可以保持同樣的可測試性，而不需要顯式地通過 `Publisher` 實例。要生成實時 Facade，請在導入類的名稱空間中加上 `Facades`：

    <?php

    namespace App\Models;

    use Facades\App\Contracts\Publisher;
    use Illuminate\Database\Eloquent\Model;

    class Podcast extends Model
    {
        /**
         * Publish the podcast.
         */
        public function publish(): void
        {
            $this->update(['publishing' => now()]);

            Publisher::publish($this);
        }
    }

當使用實時 Facade 時， publisher 實現將通過使用 `Facades` 前綴後出現的接口或類名的部分來解決服務容器的問題。在測試時，我們可以使用 Laravel 的內置 Facade 測試輔助函數來模擬這種方法調用：

    <?php

    namespace Tests\Feature;

    use App\Models\Podcast;
    use Facades\App\Contracts\Publisher;
    use Illuminate\Foundation\Testing\RefreshDatabase;
    use Tests\TestCase;

    class PodcastTest extends TestCase
    {
        use RefreshDatabase;

        /**
         * A test example.
         */
        public function test_podcast_can_be_published(): void
        {
            $podcast = Podcast::factory()->create();

            Publisher::shouldReceive('publish')->once()->with($podcast);

            $podcast->publish();
        }
    }



<a name="facade-class-reference"></a>
## Facade 類參考

在下面你可以找到每個 facade 類及其對應的底層類。這是一個快速查找給定 facade 類的 API 文檔的工具。[服務容器綁定](/docs/laravel/10.x/container) 的關鍵信息也包含在內。

<div class="overflow-auto" markdown="1">

Facade  |  Class  |  Service Container Binding|
------------- | ------------- | -------------|
App  |  [Illuminate\Foundation\Application](https://laravel.com/api/10.x/Illuminate/Foundation/Application.html)  |  `app`|
Artisan  |  [Illuminate\Contracts\Console\Kernel](https://laravel.com/api/10.x/Illuminate/Contracts/Console/Kernel.html)  |  `artisan`|
Auth  |  [Illuminate\Auth\AuthManager](https://laravel.com/api/10.x/Illuminate/Auth/AuthManager.html)  |  `auth`|
Auth (Instance)  |  [Illuminate\Contracts\Auth\Guard](https://laravel.com/api/10.x/Illuminate/Contracts/Auth/Guard.html)  |  `auth.driver`|
Blade  |  [Illuminate\View\Compilers\BladeCompiler](https://laravel.com/api/10.x/Illuminate/View/Compilers/BladeCompiler.html)  |  `blade.compiler`|
Broadcast  |  [Illuminate\Contracts\Broadcasting\Factory](https://laravel.com/api/10.x/Illuminate/Contracts/Broadcasting/Factory.html)  |  &nbsp;|
Broadcast (Instance)  |  [Illuminate\Contracts\Broadcasting\Broadcaster](https://laravel.com/api/10.x/Illuminate/Contracts/Broadcasting/Broadcaster.html)  |  &nbsp;|
Bus  |  [Illuminate\Contracts\Bus\Dispatcher](https://laravel.com/api/10.x/Illuminate/Contracts/Bus/Dispatcher.html)  |  &nbsp;|
Cache  |  [Illuminate\Cache\CacheManager](https://laravel.com/api/10.x/Illuminate/Cache/CacheManager.html)  |  `cache`|
Cache (Instance)  |  [Illuminate\Cache\Repository](https://laravel.com/api/10.x/Illuminate/Cache/Repository.html)  |  `cache.store`|
Config  |  [Illuminate\Config\Repository](https://laravel.com/api/10.x/Illuminate/Config/Repository.html)  |  `config`|
Cookie  |  [Illuminate\Cookie\CookieJar](https://laravel.com/api/10.x/Illuminate/Cookie/CookieJar.html)  |  `cookie`|
Crypt  |  [Illuminate\Encryption\Encrypter](https://laravel.com/api/10.x/Illuminate/Encryption/Encrypter.html)  |  `encrypter`|
Date  |  [Illuminate\Support\DateFactory](https://laravel.com/api/10.x/Illuminate/Support/DateFactory.html)  |  `date`|
DB  |  [Illuminate\Database\DatabaseManager](https://laravel.com/api/10.x/Illuminate/Database/DatabaseManager.html)  |  `db`|
DB (Instance)  |  [Illuminate\Database\Connection](https://laravel.com/api/10.x/Illuminate/Database/Connection.html)  |  `db.connection`|
Event  |  [Illuminate\Events\Dispatcher](https://laravel.com/api/10.x/Illuminate/Events/Dispatcher.html)  |  `events`|
File  |  [Illuminate\Filesystem\Filesystem](https://laravel.com/api/10.x/Illuminate/Filesystem/Filesystem.html)  |  `files`|
Gate  |  [Illuminate\Contracts\Auth\Access\Gate](https://laravel.com/api/10.x/Illuminate/Contracts/Auth/Access/Gate.html)  |  &nbsp;|
Hash  |  [Illuminate\Contracts\Hashing\Hasher](https://laravel.com/api/10.x/Illuminate/Contracts/Hashing/Hasher.html)  |  `hash`|
Http  |  [Illuminate\Http\Client\Factory](https://laravel.com/api/10.x/Illuminate/Http/Client/Factory.html)  |  &nbsp;|
Lang  |  [Illuminate\Translation\Translator](https://laravel.com/api/10.x/Illuminate/Translation/Translator.html)  |  `translator`|
Log  |  [Illuminate\Log\LogManager](https://laravel.com/api/10.x/Illuminate/Log/LogManager.html)  |  `log`|
Mail  |  [Illuminate\Mail\Mailer](https://laravel.com/api/10.x/Illuminate/Mail/Mailer.html)  |  `mailer`|
Notification  |  [Illuminate\Notifications\ChannelManager](https://laravel.com/api/10.x/Illuminate/Notifications/ChannelManager.html)  |  &nbsp;|
Password  |  [Illuminate\Auth\Passwords\PasswordBrokerManager](https://laravel.com/api/10.x/Illuminate/Auth/Passwords/PasswordBrokerManager.html)  |  `auth.password`|
Password (Instance)  |  [Illuminate\Auth\Passwords\PasswordBroker](https://laravel.com/api/10.x/Illuminate/Auth/Passwords/PasswordBroker.html)  |  `auth.password.broker`|
Pipeline (Instance)  |  [Illuminate\Pipeline\Pipeline](https://laravel.com/api/10.x/Illuminate/Pipeline/Pipeline.html)  |  &nbsp;|
Queue  |  [Illuminate\Queue\QueueManager](https://laravel.com/api/10.x/Illuminate/Queue/QueueManager.html)  |  `queue`|
Queue (Instance)  |  [Illuminate\Contracts\Queue\Queue](https://laravel.com/api/10.x/Illuminate/Contracts/Queue/Queue.html)  |  `queue.connection`|
Queue (Base Class)  |  [Illuminate\Queue\Queue](https://laravel.com/api/10.x/Illuminate/Queue/Queue.html)  |  &nbsp;|
Redirect  |  [Illuminate\Routing\Redirector](https://laravel.com/api/10.x/Illuminate/Routing/Redirector.html)  |  `redirect`|
Redis  |  [Illuminate\Redis\RedisManager](https://laravel.com/api/10.x/Illuminate/Redis/RedisManager.html)  |  `redis`|
Redis (Instance)  |  [Illuminate\Redis\Connections\Connection](https://laravel.com/api/10.x/Illuminate/Redis/Connections/Connection.html)  |  `redis.connection`|
Request  |  [Illuminate\Http\Request](https://laravel.com/api/10.x/Illuminate/Http/Request.html)  |  `request`|
Response  |  [Illuminate\Contracts\Routing\ResponseFactory](https://laravel.com/api/10.x/Illuminate/Contracts/Routing/ResponseFactory.html)  |  &nbsp;|
Response (Instance)  |  [Illuminate\Http\Response](https://laravel.com/api/10.x/Illuminate/Http/Response.html)  |  &nbsp;|
Route  |  [Illuminate\Routing\Router](https://laravel.com/api/10.x/Illuminate/Routing/Router.html)  |  `router`|
Schema  |  [Illuminate\Database\Schema\Builder](https://laravel.com/api/10.x/Illuminate/Database/Schema/Builder.html)  |  &nbsp;|
Session  |  [Illuminate\Session\SessionManager](https://laravel.com/api/10.x/Illuminate/Session/SessionManager.html)  |  `session`|
Session (Instance)  |  [Illuminate\Session\Store](https://laravel.com/api/10.x/Illuminate/Session/Store.html)  |  `session.store`|
Storage  |  [Illuminate\Filesystem\FilesystemManager](https://laravel.com/api/10.x/Illuminate/Filesystem/FilesystemManager.html)  |  `filesystem`|
Storage (Instance)  |  [Illuminate\Contracts\Filesystem\Filesystem](https://laravel.com/api/10.x/Illuminate/Contracts/Filesystem/Filesystem.html)  |  `filesystem.disk`|
URL  |  [Illuminate\Routing\UrlGenerator](https://laravel.com/api/10.x/Illuminate/Routing/UrlGenerator.html)  |  `url`|
Validator  |  [Illuminate\Validation\Factory](https://laravel.com/api/10.x/Illuminate/Validation/Factory.html)  |  `validator`|
Validator (Instance)  |  [Illuminate\Validation\Validator](https://laravel.com/api/10.x/Illuminate/Validation/Validator.html)  |  &nbsp;|
View  |  [Illuminate\View\Factory](https://laravel.com/api/10.x/Illuminate/View/Factory.html)  |  `view`|
View (Instance)  |  [Illuminate\View\View](https://laravel.com/api/10.x/Illuminate/View/View.html)  |  &nbsp;|
Vite  |  [Illuminate\Foundation\Vite](https://laravel.com/api/10.x/Illuminate/Foundation/Vite.html)  |  &nbsp;|

</div>
