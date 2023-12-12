# 中間件

- [介紹](#introduction)
- [定義中間件](#defining-middleware)
- [注冊中間件](#registering-middleware)
    - [全局中間件](#global-middleware)
    - [將中間件分配給路由](#assigning-middleware-to-routes)
    - [中間件組](#middleware-groups)
    - [排序中間件](#sorting-middleware)
- [中間件參數](#middleware-parameters)
- [可終止的中間件](#terminable-middleware)

<a name="introduction"></a>
## 介紹

中間件提供了一種方便的機制來檢查和過濾進入應用程序的 HTTP 請求。例如，Laravel 包含一個中間件，用於驗證應用程序的用戶是否經過身份驗證。如果用戶未通過身份驗證，中間件會將用戶重定向到應用程序的登錄屏幕。 但是，如果用戶通過了身份驗證，中間件將允許請求進一步進入應用程序。

除了身份驗證之外，還可以編寫其他中間件來執行各種任務。例如，日志中間件可能會將所有傳入請求記錄到你的應用程序。Laravel 框架中包含了幾個中間件，包括用於身份驗證和 CSRF 保護的中間件。所有這些中間件都位於 `app/Http/Middleware` 目錄中。

<a name="defining-middleware"></a>
## 定義中間件

要創建新的中間件，請使用 `make:middleware` Artisan 命令：

```shell
php artisan make:middleware EnsureTokenIsValid
```

此命令將在你的 `app/Http/Middleware` 目錄中放置一個新的 `EnsureTokenIsValid` 類。在這個中間件中，如果提供的 `token` 輸入匹配指定的值，我們將只允許訪問路由。否則，我們會將用戶重定向回 `home` URI：

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class EnsureTokenIsValid
    {
        /**
         * 處理傳入請求。
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            if ($request->input('token') !== 'my-secret-token') {
                return redirect('home');
            }

            return $next($request);
        }
    }



如你所見，如果給定的 `token` 與我們的秘密令牌不匹配，中間件將向客戶端返回 HTTP 重定向； 否則，請求將被進一步傳遞到應用程序中。要將請求更深入地傳遞到應用程序中（允許中間件「通過」），你應該使用 `$request` 調用 `$next` 回調。

最好將中間件設想為一系列「層」HTTP 請求在到達你的應用程序之前必須通過。每一層都可以檢查請求，甚至完全拒絕它。

>技巧：所有中間件都通過 [服務容器](/docs/laravel/10.x/container) 解析，因此你可以在中間件的構造函數中鍵入提示你需要的任何依賴項。

<a name="before-after-middleware"></a>
<a name="middleware-and-responses"></a>
#### 中間件和響應

當然，中間件可以在將請求更深入地傳遞到應用程序之前或之後執行任務。例如，以下中間件將在應用程序處理__請求之前__執行一些任務：

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class BeforeMiddleware
    {
        public function handle(Request $request, Closure $next): Response
        {
            // 執行操作

            return $next($request);
        }
    }

但是，此中間件將在應用程序處理__請求之後__執行其任務：

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class AfterMiddleware
    {
        public function handle(Request $request, Closure $next): Response
        {
            $response = $next($request);

            // 執行操作

            return $response;
        }
    }

<a name="registering-middleware"></a>
## 注冊中間件

<a name="global-middleware"></a>
### 全局中間件

如果你希望在對應用程序的每個 HTTP 請求期間運行中間件，請在 `app/Http/Kernel.php` 類的 `$middleware` 屬性中列出中間件類。

<a name="assigning-middleware-to-routes"></a>
### 將中間件分配給路由

如果要將中間件分配給特定路由，可以在定義路由時調用 `middleware` 方法：


    use App\Http\Middleware\Authenticate;

    Route::get('/profile', function () {
        // ...
    })->middleware(Authenticate::class);

通過向 `middleware` 方法傳遞一組中間件名稱，可以為路由分配多個中間件：

    Route::get('/', function () {
        // ...
    })->middleware([First::class, Second::class]);

為了方便起見，可以在應用程序的`app/Http/Kernel.php`文件中為中間件分配別名。默認情況下，此類的 `$middlewareAliases` 屬性包含Laravel中包含的中間件的條目。你可以將自己的中間件添加到此列表中，並為其分配選擇的別名：

    // 在App\Http\Kernel類中。。。

    protected $middlewareAliases = [
        'auth' => \App\Http\Middleware\Authenticate::class,
        'auth.basic' => \Illuminate\Auth\Middleware\AuthenticateWithBasicAuth::class,
        'bindings' => \Illuminate\Routing\Middleware\SubstituteBindings::class,
        'cache.headers' => \Illuminate\Http\Middleware\SetCacheHeaders::class,
        'can' => \Illuminate\Auth\Middleware\Authorize::class,
        'guest' => \App\Http\Middleware\RedirectIfAuthenticated::class,
        'signed' => \Illuminate\Routing\Middleware\ValidateSignature::class,
        'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,
        'verified' => \Illuminate\Auth\Middleware\EnsureEmailIsVerified::class,
    ];

一旦在HTTP內核中定義了中間件別名，就可以在將中間件分配給路由時使用該別名：

    Route::get('/profile', function () {
        // ...
    })->middleware('auth');

<a name="excluding-middleware"></a>
#### 排除中間件

當將中間件分配給一組路由時，可能偶爾需要防止中間件應用於組內的單個路由。可以使用 `withoutMiddleware` 方法完成此操作：

    use App\Http\Middleware\EnsureTokenIsValid;

    Route::middleware([EnsureTokenIsValid::class])->group(function () {
        Route::get('/', function () {
            // ...
        });

        Route::get('/profile', function () {
            // ...
        })->withoutMiddleware([EnsureTokenIsValid::class]);
    });

還可以從整個 [組](/docs/laravel/10.x/routing#route-groups) 路由定義中排除一組給定的中間件：

    use App\Http\Middleware\EnsureTokenIsValid;

    Route::withoutMiddleware([EnsureTokenIsValid::class])->group(function () {
        Route::get('/profile', function () {
            // ...
        });
    });

「withoutMiddleware」方法只能刪除路由中間件，不適用於 [全局中間件](#global-middleware)。

<a name="middleware-groups"></a>
### 中間件組

有時，你可能希望將多個中間件組合在一個鍵下，以使它們更容易分配給路由。你可以使用 HTTP 內核的 `$middlewareGroups` 屬性來完成此操作。

Laravel 包括預定義 帶有 `web` 和 `api` 中間件組，其中包含你可能希望應用於 Web 和 API 路由的常見中間件。請記住，這些中間件組會由應用程序的 `App\Providers\RouteServiceProvider` 服務提供者自動應用於相應的 `web` 和 `api` 路由文件中的路由：

    /**
     * 應用程序的路由中間件組。
     *
     * @var array
     */
    protected $middlewareGroups = [
        'web' => [
            \App\Http\Middleware\EncryptCookies::class,
            \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \Illuminate\View\Middleware\ShareErrorsFromSession::class,
            \App\Http\Middleware\VerifyCsrfToken::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],

        'api' => [
            \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
    ];

中間件組可以使用與單個中間件相同的語法分配給路由和控制器動作。同理，中間件組使一次將多個中間件分配給一個路由更加方便：

    Route::get('/', function () {
        // ...
    })->middleware('web');

    Route::middleware(['web'])->group(function () {
        // ...
    });

>技巧：開箱即用，`web` 和 `api` 中間件組會通過  `App\Providers\RouteServiceProvider` 自動應用於應用程序對應的 `routes/web.php` 和 `routes/api.php` 文件。

<a name="sorting-middleware"></a>
### 排序中間件

在特定情況下，可能需要中間件以特定的順序執行，但當它們被分配到路由時，是無法控制它們的順序的。在這種情況下，可以使用到 `app/Http/Kernel.php` 文件的 `$middlewarePriority` 屬性指定中間件優先級。默認情況下，HTTP內核中可能不存在此屬性。如果它不存在，你可以覆制下面的默認定義：

    /**
     * 中間件的優先級排序列表。
     *
     * 這迫使非全局中間件始終處於給定的順序。
     *
     * @var string[]
     */
    protected $middlewarePriority = [
        \Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests::class,
        \Illuminate\Cookie\Middleware\EncryptCookies::class,
        \Illuminate\Session\Middleware\StartSession::class,
        \Illuminate\View\Middleware\ShareErrorsFromSession::class,
        \Illuminate\Contracts\Auth\Middleware\AuthenticatesRequests::class,
        \Illuminate\Routing\Middleware\ThrottleRequests::class,
        \Illuminate\Routing\Middleware\ThrottleRequestsWithRedis::class,
        \Illuminate\Contracts\Session\Middleware\AuthenticatesSessions::class,
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
        \Illuminate\Auth\Middleware\Authorize::class,
    ];

<a name="middleware-parameters"></a>
## 中間件參數

中間件也可以接收額外的參數。例如，如果你的應用程序需要在執行給定操作之前驗證經過身份驗證的用戶是否具有給定的「角色」，你可以創建一個 `EnsureUserHasRole` 中間件，該中間件接收角色名稱作為附加參數。

額外的中間件參數將在 `$next` 參數之後傳遞給中間件：

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class EnsureUserHasRole
    {
        /**
         * 處理傳入請求。
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next, string $role): Response
        {
            if (! $request->user()->hasRole($role)) {
                // 重定向。。。
            }

            return $next($request);
        }

    }

在定義路由時，可以指定中間件參數，方法是使用 `:` 分隔中間件名稱和參數。多個參數應以逗號分隔：

    Route::put('/post/{id}', function (string $id) {
        // ...
    })->middleware('role:editor');

<a name="terminable-middleware"></a>
## 可終止的中間件

部分情況下，在將 HTTP 響應發送到瀏覽器之後，中間件可能需要做一些工作。如果你在中間件上定義了一個 `terminate` 方法，並且你的 Web 服務器使用 FastCGI，則在將響應發送到瀏覽器後會自動調用 `terminate` 方法：

    <?php

    namespace Illuminate\Session\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    class TerminatingMiddleware
    {
        /**
         * 處理傳入的請求。
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            return $next($request);
        }

        /**
         * 在響應發送到瀏覽器後處理任務。
         */
        public function terminate(Request $request, Response $response): void
        {
            // ...
        }
    }

`terminate` 方法應該同時接收請求和響應。一旦你定義了一個可終止的中間件，你應該將它添加到 `app/Http/Kernel.php` 文件中的路由或全局中間件列表中。

當在中間件上調用 `terminate` 方法時，Laravel 會從 [服務容器](/docs/laravel/10.x/container) 解析一個新的中間件實例。如果你想在調用 `handle` 和 `terminate` 方法時使用相同的中間件實例，請使用容器的 `singleton` 方法向容器注冊中間件。 通常這應該在你的 `AppServiceProvider` 的 `register` 方法中完成：

    use App\Http\Middleware\TerminatingMiddleware;

    /**
     * 注冊任何應用程序服務。
     */
    public function register(): void
    {
        $this->app->singleton(TerminatingMiddleware::class);
    }


<a name="前後中間件"></a>
<a name="中間件和響應"></a>
