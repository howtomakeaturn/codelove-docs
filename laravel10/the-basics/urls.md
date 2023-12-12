
# 生成 URL

- [簡介](#introduction)
- [基礎](#the-basics)
    - [生成基礎 URLs](#generating-urls)
    - [訪問當前 URL](#accessing-the-current-url)
- [命名路由的 URLs](#urls-for-named-routes)
    - [簽名 URLs](#signed-urls)
- [控制器行為的 URLs](#urls-for-controller-actions)
- [默認值](#default-values)

<a name="introduction"></a>
## 簡介

Laravel 提供了幾個輔助函數來為應用程序生成 URL。主要用於在模板和 API 響應中構建 URL 或者在應用程序的其它部分生成重定向響應。

<a name="the-basics"></a>
## 基礎

<a name="generating-urls"></a>
### 生成基礎 URLs

輔助函數 `url` 可以用於應用的任何一個 URL。生成的 URL 將自動使用當前請求中的方案 (HTTP 或 HTTPS) 和主機：

    $post = App\Models\Post::find(1);

    echo url("/posts/{$post->id}");

    // http://example.com/posts/1

<a name="accessing-the-current-url"></a>
### 訪問當前 URL

如果沒有給輔助函數 `url` 提供路徑，則會返回一個 `Illuminate\Routing\UrlGenerator` 實例，來允許你訪問有關當前 URL 的信息：

    // 獲取當前 URL 沒有 query string...
    echo url()->current();

    // 獲取當前 URL 包括 query string...
    echo url()->full();

    // 獲取上個請求 URL
    echo url()->previous();

上面的這些方法都可以通過 `URL` [facade](/docs/laravel/10.x/facades) 訪問:

    use Illuminate\Support\Facades\URL;

    echo URL::current();

<a name="urls-for-named-routes"></a>
## 命名路由的 URLs

輔助函數 `route` 可以用於生成指定 [命名路由](/docs/laravel/10.x/routing#named-routes) 的URLs。 命名路由生成的 URLs 不與路由上定義的 URL 相耦合。因此，就算路由的 URL 有任何改變，都不需要對 `route` 函數調用進行任何更改。例如，假設你的應用程序包含以下路由：

    Route::get('/post/{post}', function (Post $post) {
        // ...
    })->name('post.show');



要生成此路由的 URL ，可以像這樣使用輔助函數 `route` ：

    echo route('post.show', ['post' => 1]);

    // http://example.com/post/1

當然，輔助函數 `route` 也可以用於為具有多個參數的路由生成 URL：

    Route::get('/post/{post}/comment/{comment}', function (Post $post, Comment $comment) {
        // ...
    })->name('comment.show');

    echo route('comment.show', ['post' => 1, 'comment' => 3]);

    // http://example.com/post/1/comment/3

任何與路由定義參數對應不上的附加數組元素都將添加到 URL 的查詢字符串中：

    echo route('post.show', ['post' => 1, 'search' => 'rocket']);

    // http://example.com/post/1?search=rocket

<a name="eloquent-models"></a>
#### Eloquent Models

你通常使用 [Eloquent 模型](/docs/laravel/10.x/eloquent) 的主鍵生成 URL。因此，您可以將 Eloquent 模型作為參數值傳遞。 `route` 輔助函數將自動提取模型的主鍵：

    echo route('post.show', ['post' => $post]);

<a name="signed-urls"></a>
### 簽名 URLs

Laravel 允許你輕松地為命名路徑創建「簽名」 URLs，這些 URLs 在查詢字符串後附加了「簽名」哈希，允許 Laravel 驗證 URL 自創建以來未被修改過。 簽名 URLs 對於可公開訪問但需要一層防止 URL 操作的路由特別有用。

例如，你可以使用簽名 URLs 來實現通過電子郵件發送給客戶的公共「取消訂閱」鏈接。要創建指向路徑的簽名 URL ，請使用  `URL` facade 的 `signedRoute` 方法：

    use Illuminate\Support\Facades\URL;

    return URL::signedRoute('unsubscribe', ['user' => 1]);



如果要生成具有有效期的臨時簽名路由 URL，可以使用以下 `temporarySignedRoute` 方法，當 Laravel 驗證一個臨時的簽名路由 URL 時，它會確保編碼到簽名 URL 中的過期時間戳沒有過期：

    use Illuminate\Support\Facades\URL;

    return URL::temporarySignedRoute(
        'unsubscribe', now()->addMinutes(30), ['user' => 1]
    );

<a name="validating-signed-route-requests"></a>
#### 驗證簽名路由請求

要驗證傳入請求是否具有有效簽名，你應該對傳入的 `Illuminate\Http\Request` 實例中調用 `hasValidSignature` 方法：

    use Illuminate\Http\Request;

    Route::get('/unsubscribe/{user}', function (Request $request) {
        if (! $request->hasValidSignature()) {
            abort(401);
        }

        // ...
    })->name('unsubscribe');

有時，你可能需要允許你的應用程序前端將數據附加到簽名 URL，例如在執行客戶端分頁時。因此，你可以指定在使用 `hasValidSignatureWhileIgnoring` 方法驗證簽名 URL 時應忽略的請求查詢參數。請記住，忽略參數將允許任何人根據請求修改這些參數：

    if (! $request->hasValidSignatureWhileIgnoring(['page', 'order'])) {
        abort(401);
    }

或者，你可以將 `Illuminate\Routing\Middleware\ValidateSignature` [中間件](/docs/laravel/10.x/middleware) 分配給路由。如果它不存在，則應該在 HTTP 內核的 `$middlewareAliases` 數組中為此中間件分配一個鍵：

    /**
     * The application's middleware aliases.
     *
     * Aliases may be used to conveniently assign middleware to routes and groups.
     *
     * @var array<string, class-string|string>
     */
    protected $middlewareAliases = [
        'signed' => \Illuminate\Routing\Middleware\ValidateSignature::class,
    ];

一旦在內核中注冊了中間件，就可以將其附加到路由。如果傳入的請求沒有有效的簽名，中間件將自動返回 `403` HTTP 響應：

    Route::post('/unsubscribe/{user}', function (Request $request) {
        // ...
    })->name('unsubscribe')->middleware('signed');



<a name="responding-to-invalid-signed-routes"></a>
#### 響應無效的簽名路由

當有人訪問已過期的簽名 URL 時，他們將收到一個通用的錯誤頁面，顯示 `403` HTTP 狀態代碼。然而，你可以通過在異常處理程序中為 `InvalidSignatureException` 異常定義自定義 “可渲染” 閉包來自定義此行為。這個閉包應該返回一個 HTTP 響應：

    use Illuminate\Routing\Exceptions\InvalidSignatureException;

    /**
     * 為應用程序注冊異常處理回調
     */
    public function register(): void
    {
        $this->renderable(function (InvalidSignatureException $e) {
            return response()->view('error.link-expired', [], 403);
        });
    }

<a name="urls-for-controller-actions"></a>
## 控制器行為的 URL

`action` 功能可以為給定的控制器行為生成 URL。

    use App\Http\Controllers\HomeController;

    $url = action([HomeController::class, 'index']);

如果控制器方法接收路由參數，你可以通過第二個參數傳遞：

    $url = action([UserController::class, 'profile'], ['id' => 1]);

<a name="default-values"></a>
## 默認值

對於某些應用程序，你可能希望為某些 URL 參數的請求範圍指定默認值。例如，假設有些路由定義了 `{locale}` 參數：

    Route::get('/{locale}/posts', function () {
        // ...
    })->name('post.index');

每次都通過 `locale` 來調用輔助函數 `route` 也是一件很麻煩的事情。因此，使用 `URL::defaults` 方法定義這個參數的默認值，可以讓該參數始終存在當前請求中。然後就能從 [路由中間件](/docs/laravel/10.x/middleware#assigning-middleware-to-routes) 調用此方法來訪問當前請求：

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\URL;
    use Symfony\Component\HttpFoundation\Response;

    class SetDefaultLocaleForUrls
    {
        /**
         * 處理傳入的請求
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            URL::defaults(['locale' => $request->user()->locale]);

            return $next($request);
        }
    }



一旦設置了 `locale` 參數的默認值，你就不再需要通過輔助函數 `route` 生成 URL 時傳遞它的值。

<a name="url-defaults-middleware-priority"></a>
#### 默認 URL & 中間件優先級

設置 URL 的默認值會影響 Laravel 對隱式模型綁定的處理。因此，你應該通過[設置中間件優先級](/docs/laravel/10.x/middleware#sorting-middleware)來確保在 Laravel 自己的 `SubstituteBindings` 中間件執行之前設置 URL 的默認值。你可以通過在你的應用的 HTTP kernel 文件中的 `$middlewarePriority` 屬性里把你的中間件放在 `SubstituteBindings` 中間件之前。

`$middlewarePriority` 這個屬性在 `Illuminate\Foundation\Http\Kernel` 這個基類里。你可以覆制一份到你的應用程序的 HTTP kernel 文件中以便做修改:

    /**
     * 根據優先級排序的中間件列表
     *
     * 這將保證非全局中間件按照既定順序排序
     *
     * @var array
     */
    protected $middlewarePriority = [
        // ...
         \App\Http\Middleware\SetDefaultLocaleForUrls::class,
         \Illuminate\Routing\Middleware\SubstituteBindings::class,
         // ...
    ];
