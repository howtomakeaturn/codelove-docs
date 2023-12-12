
# 響應

- [創建響應](#creating-responses)
    - [添加響應頭](#attaching-headers-to-responses)
    - [添加響應 Cookies](#attaching-cookies-to-responses)
    - [Cookies & 加密](#cookies-and-encryption)
- [重定向](#redirects)
    - [重定向到命名路由](#redirecting-named-routes)
    - [重定向到控制器方法](#redirecting-controller-actions)
    - [重定向到外部域名](#redirecting-external-domains)
    - [重定向並使用閃存的 Session 數據](#redirecting-with-flashed-session-data)
- [其它響應類型](#other-response-types)
    - [視圖響應](#view-responses)
    - [JSON 響應](#json-responses)
    - [文件下載](#file-downloads)
    - [文件響應](#file-responses)
- [響應宏](#response-macros)

<a name="creating-responses"></a>
## 創建響應

<a name="strings-arrays"></a>
#### 字符串 & 數組

所有路由和控制器處理完業務邏輯之後都會返回響應到用戶的瀏覽器，Laravel 提供了多種不同的響應方式，其中最基本就是從路由或控制器返回一個簡單的字符串，框架會自動將這個字符串轉化為一個完整的 HTTP 響應：

    Route::get('/', function () {
        return 'Hello World';
    });

除了從路由和控制器返回字符串之外，你還可以返回數組。 框架會自動將數組轉換為 JSON 響應：

    Route::get('/', function () {
        return [1, 2, 3];
    });

> **技巧**
> 你知道從路由或控制器還可以返回 [Eloquent 集合](/docs/laravel/10.x/eloquent-collections)嗎？他們也會自動轉化為 JSON 響應！

<a name="response-objects"></a>
#### Response 對象

通常情況下會只返回簡單的字符串或數組，大多數時候，需要返回一個完整的`Illuminate\Http\Response`實例或是[視圖](/docs/laravel/10.x/views).

返回一個完整的`Response` 實例允許你自定義返回的 HTTP 狀態碼和返回頭信息。`Response`實例繼承自`Symfony\Component\HttpFoundation\Response`類，該類提供了各種構建 HTTP 響應的方法：

    Route::get('/home', function () {
        return response('Hello World', 200)
                      ->header('Content-Type', 'text/plain');
    });



<a name="eloquent-models-and-collections"></a>
#### Eloquent 模型 和 集合

你也可以直接從你的路由和控制器返回 [Eloquent ORM](/docs/laravel/10.x/eloquent) 模型和集合。當你這樣做時，Laravel 將自動將模型和集合轉換為 JSON 響應，同時遵循模型的 [隱藏屬性](/docs/laravel/10.x/eloquent-serialization#hiding-attributes-from-json):

    use App\Models\User;

    Route::get('/user/{user}', function (User $user) {
        return $user;
    });

<a name="attaching-headers-to-responses"></a>
### 在響應中附加 Header 信息

請記住，大多數響應方法都是可以鏈式調用的，它允許你流暢地構建響應實例。例如，在將響應發送回用戶之前，可以使用 `header` 方法將一系列頭添加到響應中：

    return response($content)
                ->header('Content-Type', $type)
                ->header('X-Header-One', 'Header Value')
                ->header('X-Header-Two', 'Header Value');

或者，你可以使用 `withHeaders` 方法指定要添加到響應的標頭數組：

    return response($content)
                ->withHeaders([
                    'Content-Type' => $type,
                    'X-Header-One' => 'Header Value',
                    'X-Header-Two' => 'Header Value',
                ]);

<a name="cache-control-middleware"></a>
#### 緩存控制中間件

Laravel 包含一個 `cache.headers` 中間件，可用於快速設置一組路由的 `Cache-Control` 標頭。指令應使用相應緩存控制指令的 蛇形命名法 等效項提供，並應以分號分隔。如果在指令列表中指定了 `etag` ，則響應內容的 MD5 哈希將自動設置為 ETag 標識符：

    Route::middleware('cache.headers:public;max_age=2628000;etag')->group(function () {
        Route::get('/privacy', function () {
            // ...
        });

        Route::get('/terms', function () {
            // ...
        });
    });



<a name="attaching-cookies-to-responses"></a>
### 在響應中附加 Cookie 信息

可以使用 `cookie` 方法將 cookie 附加到傳出的 `illumize\Http\Response` 實例。你應將 cookie 的名稱、值和有效分鐘數傳遞給此方法：

    return response('Hello World')->cookie(
        'name', 'value', $minutes
    );

`cookie` 方法還接受一些使用頻率較低的參數。通常，這些參數的目的和意義與 PHP 的原生 [setcookie](https://secure.php.net/manual/en/function.setcookie.php) 的參數相同

    return response('Hello World')->cookie(
        'name', 'value', $minutes, $path, $domain, $secure, $httpOnly
    );

如果你希望確保 cookie 與傳出響應一起發送，但你還沒有該響應的實例，則可以使用 `Cookie` facade 將 cookie 加入隊列，以便在發送響應時附加到響應中。`queue` 方法接受創建 cookie 實例所需的參數。在發送到瀏覽器之前，這些 cookies 將附加到傳出的響應中：

    use Illuminate\Support\Facades\Cookie;

    Cookie::queue('name', 'value', $minutes);

<a name="generating-cookie-instances"></a>
#### 生成 Cookie 實例

如果要生成一個 `Symfony\Component\HttpFoundation\Cookie` 實例，打算稍後附加到響應實例中，你可以使用全局 `cookie` 助手函數。此 cookie 將不會發送回客戶端，除非它被附加到響應實例中：

    $cookie = cookie('name', 'value', $minutes);

    return response('Hello World')->cookie($cookie);



<a name="expiring-cookies-early"></a>
#### 提前過期 Cookies

你可以通過響應中的`withoutCookie`方法使 cookie 過期，用於刪除 cookie ：

    return response('Hello World')->withoutCookie('name');

如果尚未有創建響應的實例，則可以使用`Cookie` facade 中的`expire` 方法使 Cookie 過期：

    Cookie::expire('name');

<a name="cookies-and-encryption"></a>
### Cookies 和 加密

默認情況下，由 Laravel 生成的所有 cookie 都經過了加密和簽名，因此客戶端無法篡改或讀取它們。如果要對應用程序生成的部分 cookie 禁用加密，可以使用`App\Http\Middleware\EncryptCookies`中間件的`$except`屬性，該屬性位於`app/Http/Middleware`目錄中：

    /**
     * 這個名字的 Cookie 將不會加密。
     *
     * @var array
     */
    protected $except = [
        'cookie_name',
    ];

<a name="redirects"></a>
## 重定向

重定向響應是`Illuminate\Http\RedirectResponse` 類的實例，包含將用戶重定向到另一個 URL 所需的適當 HTTP 頭。Laravel 有幾種方法可以生成`RedirectResponse`實例。最簡單的方法是使用全局`redirect`助手函數：

    Route::get('/dashboard', function () {
        return redirect('home/dashboard');
    });

有時你可能希望將用戶重定向到以前的位置，例如當提交的表單無效時。你可以使用全局 back 助手函數來執行此操作。由於此功能使用 [session](/docs/laravel/10.x/session)，請確保調用`back` 函數的路由使用的是`web`中間件組：

    Route::post('/user/profile', function () {
        // 驗證請求參數

        return back()->withInput();
    });



<a name="redirecting-named-routes"></a>
### 重定向到指定名稱的路由

當你在沒有傳遞參數的情況下調用 `redirect` 助手函數時，將返回 `Illuminate\Routing\Redirector` 的實例，允許你調用 `Redirector` 實例上的任何方法。例如，要對命名路由生成 `RedirectResponse` ，可以使用 `route` 方法：

    return redirect()->route('login');

如果路由中有參數，可以將其作為第二個參數傳遞給 `route` 方法：

    // 對於具有以下URI的路由: /profile/{id}

    return redirect()->route('profile', ['id' => 1]);

<a name="populating-parameters-via-eloquent-models"></a>
#### 通過 Eloquent 模型填充參數

如果你要重定向到使用從 Eloquent 模型填充 「ID」 參數的路由，可以直接傳遞模型本身。ID 將會被自動提取：

    // 對於具有以下URI的路由: /profile/{id}

    return redirect()->route('profile', [$user]);

如果你想要自定義路由參數，你可以指定路由參數 (`/profile/{id:slug}`) 或者重寫 Eloquent 模型上的 `getRouteKey` 方法：

    /**
     * 獲取模型的路由鍵值。
     */
    public function getRouteKey(): mixed
    {
        return $this->slug;
    }

<a name="redirecting-controller-actions"></a>
### 重定向到控制器行為

也可以生成重定向到 [controller actions](/docs/laravel/10.x/controllers)。只要把控制器和 action 的名稱傳遞給 `action` 方法：

    use App\Http\Controllers\UserController;

    return redirect()->action([UserController::class, 'index']);

如果控制器路由有參數，可以將其作為第二個參數傳遞給 `action` 方法：

    return redirect()->action(
        [UserController::class, 'profile'], ['id' => 1]
    );



<a name="redirecting-external-domains"></a>
### 重定向到外部域名

有時候你需要重定向到應用外的域名。可以通過調用`away`方法，它會創建一個不帶有任何額外的 URL 編碼、有效性校驗和檢查`RedirectResponse`實例：

    return redirect()->away('https://www.google.com');

<a name="redirecting-with-flashed-session-data"></a>
### 重定向並使用閃存的 Session 數據

重定向到新的 URL 的同時[傳送數據給 seesion](/docs/laravel/10.x/session#flash-data) 是很常見的。 通常這是在你將消息發送到 session 後成功執行操作後完成的。為了方便，你可以創建一個`RedirectResponse`實例並在鏈式方法調用中將數據傳送給 session：

    Route::post('/user/profile', function () {
        // ...

        return redirect('dashboard')->with('status', 'Profile updated!');
    });

在用戶重定向後，你可以顯示 [session](/docs/laravel/10.x/session)。例如，你可以使用[ Blade 模板語法](/docs/laravel/10.x/blade)：

    @if (session('status'))
        <div class="alert alert-success">
            {{ session('status') }}
        </div>
    @endif

<a name="redirecting-with-input"></a>
#### 使用輸入重定向

你可以使用`RedirectResponse`實例提供的`withInput`方法將當前請求輸入的數據發送到 session ，然後再將用戶重定向到新位置。當用戶遇到驗證錯誤時，通常會執行此操作。每當輸入數據被發送到 session , 你可以很簡單的在下一次重新提交的表單請求中[取回它](/docs/laravel/10.x/requests#retrieving-old-input)：

    return back()->withInput();

<a name="other-response-types"></a>


## 其他響應類型

`response` 助手可用於生成其他類型的響應實例。當不帶參數調用 `response` 助手時，會返回 `Illuminate\Contracts\Routing\ResponseFactory` [contract](/docs/laravel/10.x/contracts) 的實現。 該契約提供了幾種有用的方法來生成響應。

<a name="view-responses"></a>
### 響應視圖

如果你需要控制響應的狀態和標頭，但還需要返回 [view](/docs/laravel/10.x/views) 作為響應的內容，你應該使用 `view` 方法：

    return response()
                ->view('hello', $data, 200)
                ->header('Content-Type', $type);

當然，如果你不需要傳遞自定義 HTTP 狀態代碼或自定義標頭，則可以使用全局 `view` 輔助函數。

<a name="json-responses"></a>
### JSON Responses

`json` 方法會自動將 `Content-Type` 標頭設置為 `application/json`，並使用 `json_encode` PHP 函數將給定的數組轉換為 JSON：

    return response()->json([
        'name' => 'Abigail',
        'state' => 'CA',
    ]);

如果你想創建一個 JSONP 響應，你可以結合使用 `json` 方法和 `withCallback` 方法：

    return response()
                ->json(['name' => 'Abigail', 'state' => 'CA'])
                ->withCallback($request->input('callback'));

<a name="file-downloads"></a>
### 文件下載

`download` 方法可用於生成強制用戶瀏覽器在給定路徑下載文件的響應。`download` 方法接受文件名作為該方法的第二個參數，這將確定下載文件的用戶看到的文件名。 最後，你可以將一組 HTTP 標頭作為該方法的第三個參數傳遞：

    return response()->download($pathToFile);

    return response()->download($pathToFile, $name, $headers);

> 注意：管理文件下載的 Symfony HttpFoundation 要求正在下載的文件具有 ASCII 文件名。


<a name="streamed-downloads"></a>
#### 流式下載

有時你可能希望將給定操作的字符串響應轉換為可下載的響應，而不必將操作的內容寫入磁盤。在這種情況下，你可以使用`streamDownload`方法。此方法接受回調、文件名和可選的標頭數組作為其參數：

    use App\Services\GitHub;

    return response()->streamDownload(function () {
        echo GitHub::api('repo')
                    ->contents()
                    ->readme('laravel', 'laravel')['contents'];
    }, 'laravel-readme.md');

<a name="file-responses"></a>
### 文件響應

`file`方法可用於直接在用戶的瀏覽器中顯示文件，例如圖像或 PDF，而不是啟動下載。這個方法接受文件的路徑作為它的第一個參數和一個頭數組作為它的第二個參數：

    return response()->file($pathToFile);

    return response()->file($pathToFile, $headers);

<a name="response-macros"></a>
## 響應宏

如果你想定義一個可以在各種路由和控制器中重覆使用的自定義響應，你可以使用`Response` facade 上的`macro`方法。通常，你應該從應用程序的[服務提供者](/docs/laravel/10.x/providers)，如`App\Providers\AppServiceProvider`服務提供程序的`boot`方法調用此方法：

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Response;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * 啟動一個應用的服務
         */
        public function boot(): void
        {
            Response::macro('caps', function (string $value) {
                return Response::make(strtoupper($value));
            });
        }
    }

`macro`函數接受名稱作為其第一個參數，並接受閉包作為其第二個參數。當從`ResponseFactory`實現或`response`助手函數調用宏名稱時，將執行宏的閉包：

    return response()->caps('foo');
