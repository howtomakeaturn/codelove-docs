# 路由

- [基本路由](#basic-routing)
    - [路由重定向](#redirect-routes)
    - [路由視圖](#view-routes)
    - [route:list 命令](#the-route-list)
- [路由參數](#route-parameters)
    - [必選參數](#required-parameters)
    - [可選參數](#parameters-optional-parameters)
    - [正則約束](#parameters-regular-expression-constraints)
- [路由命名](#named-routes)
- [路由分組](#route-groups)
    - [中間件](#route-group-middleware)
    - [Controllers](#route-group-controllers)
    - [子域名路由](#route-group-subdomain-routing)
    - [路由前綴](#route-group-prefixes)
    - [路由前綴命名](#route-group-name-prefixes)
- [路由模型綁定](#route-model-binding)
    - [隱式綁定](#implicit-binding)
    - [隱式枚舉綁定](#implicit-enum-binding)
    - [顯式綁定](#explicit-binding)
- [回退路由](#fallback-routes)
- [限流](#rate-limiting)
    - [定義限流器](#defining-rate-limiters)
    - [獨立訪客和認證用戶的限流](#attaching-rate-limiters-to-routes)
- [偽造表單方法](#form-method-spoofing)
- [訪問當前路由](#accessing-the-current-route)
- [跨源資源共享 (CORS)](#cors)
- [路由緩存](#route-caching)

<a name="basic-routing"></a>
## 基本路由

最基本的 Laravel 路由接受一個 URI 和一個閉包，提供了一個簡單優雅的方法來定義路由和行為，而不需要覆雜的路由配置文件：

    use Illuminate\Support\Facades\Route;

    Route::get('/greeting', function () {
        return 'Hello World';
    });

<a name="the-default-route-files"></a>
#### 默認路由文件

所有 Laravel 路由都定義在你的路由文件中，它位於 `routes` 目錄。這些文件會被你的應用程序中的 `App\Providers\RouteServiceProvider` 自動加載。`routes/web.php` 文件用於定義 web 界面的路由。這些路由被分配給 `web` 中間件組，它提供了 會話狀態和 CSRF 保護等功能。定義在 `routes/api.php` 中的路由都是無狀態的，並且被分配了 `api` 中間件組。

對於大多數應用程序，都是以在 `routes/web.php` 文件定義路由開始的。可以通過在瀏覽器中輸入定義的路由 URL 來訪問 `routes/web.php` 中定義的路由。例如，你可以在瀏覽器中輸入 `http://example.com/user` 來訪問以下路由：

    use App\Http\Controllers\UserController;

    Route::get('/user', [UserController::class, 'index']);



定義在 `routes/api.php` 文件中的路由是被 `RouteServiceProvider` 嵌套在一個路由組內。 在這個路由組內，將自動應用 `/api` URI 前綴，所以你無需手動將其應用於文件中的每個路由。你可以通過修改 `RouteServiceProvider` 類來修改前綴和其他路由組選項。

<a name="available-router-methods"></a>
#### 可用的路由方法

路由器允許你注冊能響應任何 HTTP 請求的路由

    Route::get($uri, $callback);
    Route::post($uri, $callback);
    Route::put($uri, $callback);
    Route::patch($uri, $callback);
    Route::delete($uri, $callback);
    Route::options($uri, $callback);

有的時候你可能需要注冊一個可響應多個 HTTP 請求的路由，這時你可以使用 `match` 方法，也可以使用 `any` 方法注冊一個實現響應所有 HTTP 請求的路由：

    Route::match(['get', 'post'], '/', function () {
        // ...
    });

    Route::any('/', function () {
        // ...
    });

> **技巧**
> 當定義多個相同路由時，使用 `get`， `post`， `put`， `patch`， `delete`， 和 `options` 方法的路由應該在使用 `any`， `match`， 和 `redirect` 方法的路由之前定義，這樣可以確保請求與正確的路由匹配。

<a name="dependency-injection"></a>
#### 依賴注入

你可以在路由的回調方法中，以形參的方式聲明路由所需要的任何依賴項。這些依賴會被 Laravel 的 [容器](/docs/laravel/10.x/container) 自動解析並注入。 例如，你可以在閉包中聲明 `Illuminate\Http\Request` 類， 讓當前的 HTTP 請求自動注入依賴到你的路由回調中：

    use Illuminate\Http\Request;

    Route::get('/users', function (Request $request) {
        // ...
    });



<a name="csrf-protection"></a>
#### CSRF 保護

請記住，任何指向`POST`、`PUT`、`PATCH` 或 `DELETE` 路由(在 `web` 路由文件中定義)的 HTML 表單都應該包含 CSRF 令牌字，否則請求會被拒絕。更多 CSRF 保護的相關信息請閱讀[CSRF 文檔](/docs/laravel/10.x/csrf)：

    <form method="POST" action="/profile">
        @csrf
        ...
    </form>

<a name="redirect-routes"></a>
### 重定向路由

如果要定義一個重定向到另一個 URI 的路由，可以使用 `Route::redirect` 方法。這個方法可以快速的實現重定向，而不再需要去定義完整的路由或者控制器：

    Route::redirect('/here', '/there');

默認情況下，`Route::redirect` 返回 `302` 狀態碼。你可以使用可選的第三個參數自定義狀態碼：

    Route::redirect('/here', '/there', 301);

或者，你也可以使用 `Route::permanentRedirect` 方法返回 `301`狀態碼：

    Route::permanentRedirect('/here', '/there');

> **警告**
> 在重定向路由中使用路由參數時，以下參數由 Laravel 保留，不能使用：`destination` 和 `status`。

<a name="view-routes"></a>
### 視圖路由

如果你的路由只需返回一個[視圖](/docs/laravel/10.x/views)，你可以使用 `Route::view` 方法。就像 `redirect` 方法，該方法提供了一個讓你不必定義完整路由或控制器的便捷操作。這個`view`方法的第一個參數是URI，第二個參數為視圖名稱。此外，你也可以在可選的第三個參數中傳入數組，將數組的數據傳遞給視圖：

    Route::view('/welcome', 'welcome');

    Route::view('/welcome', 'welcome', ['name' => 'Taylor']);

> **警告**
> 在視圖路由中使用參數時，下列參數由 Laravel 保留，不能使用：`view`、`data`, `status` 及 `headers`。


<a name="the-route-list"></a>
### route:list 命令

使用 `route:list` Artisan命令可以輕松提供應用程序定義的所有路線的概述：

```shell
php artisan route:list
```

正常情況下，`route:list`不會顯示分配給路由的中間件信息；但是你可以通過在命令中添加 `-v` 選項 來顯示路由中的中間件信息：

```shell
php artisan route:list -v
```

你也可以通過 `--path` 來顯示指定的 URL 開頭的路由：

```shell
php artisan route:list --path=api
```

此外，在執行 `route:list` 命令時，可以通過提供 `--except-vendor` 選項來隱藏由第三方包定義的任何路由：

```shell
php artisan route:list --except-vendor
```

同理，也可以通過在執行 `route:list` 命令時提供 `--only-vendor` 選項來顯示由第三方包定義的路由：

```shell
php artisan route:list --only-vendor
```

<a name="route-parameters"></a>
## 路由參數

<a name="required-parameters"></a>
### 必需參數

有時你將需要捕獲路由內的 URI 段。例如，你可能需要從 URL 中捕獲用戶的 ID。你可以通過定義路由參數來做到這一點：

    Route::get('/user/{id}', function (string $id) {
        return 'User '.$id;
    });

也可以根據你的需要在路由中定義多個參數：

    Route::get('/posts/{post}/comments/{comment}', function (string $postId, string $commentId) {
        // ...
    });

路由的參數通常都會被放在 `{}` ，並且參數名只能為字母。下劃線 (`_`) 也可以用於路由參數名中。路由參數會按路由定義的順序依次注入到路由回調或者控制器中，而不受回調或者控制器的參數名稱的影響。



<a name="parameters-and-dependency-injection"></a>
#### 必填參數

如果你的路由具有依賴關系，而你希望 Laravel 服務容器自動注入到路由的回調中，則應在依賴關系之後列出路由參數：

    use Illuminate\Http\Request;

    Route::get('/user/{id}', function (Request $request, string $id) {
        return 'User '.$id;
    });

<a name="parameters-optional-parameters"></a>
### 可選參數

有時，你可能需要指定一個路由參數，但你希望這個參數是可選的。你可以在參數後面加上 `?` 標記來實現，但前提是要確保路由的相應變量有默認值：

    Route::get('/user/{name?}', function (string $name = null) {
        return $name;
    });

    Route::get('/user/{name?}', function (string $name = 'John') {
        return $name;
    });

<a name="parameters-regular-expression-constraints"></a>
### 正則表達式約束

你可以使用路由實例上的 `where` 方法來限制路由參數的格式。 `where` 方法接受參數的名稱和定義如何約束參數的正則表達式：

    Route::get('/user/{name}', function (string $name) {
        // ...
    })->where('name', '[A-Za-z]+');

    Route::get('/user/{id}', function (string $id) {
        // ...
    })->where('id', '[0-9]+');

    Route::get('/user/{id}/{name}', function (string $id, string $name) {
        // ...
    })->where(['id' => '[0-9]+', 'name' => '[a-z]+']);

為方便起見，一些常用的正則表達式模式具有幫助方法，可讓你快速將模式約束添加到路由：

    Route::get('/user/{id}/{name}', function (string $id, string $name) {
        // ...
    })->whereNumber('id')->whereAlpha('name');

    Route::get('/user/{name}', function (string $name) {
        // ...
    })->whereAlphaNumeric('name');

    Route::get('/user/{id}', function (string $id) {
        // ...
    })->whereUuid('id');

    Route::get('/user/{id}', function (string $id) {
        //
    })->whereUlid('id');

    Route::get('/category/{category}', function (string $category) {
        // ...
    })->whereIn('category', ['movie', 'song', 'painting']);



如果傳入請求與路由模式約束不匹配，將返回 404 HTTP 響應。

<a name="parameters-global-constraints"></a>
#### 全局約束

如果你希望路由參數始終受給定正則表達式的約束，你可以使用 `pattern` 方法。 你應該在 `App\Providers\RouteServiceProvider` 類的 `boot` 方法中定義這些模式：

    /**
     * 定義路由模型綁定、模式篩選器等。
     */
    public function boot(): void
    {
        Route::pattern('id', '[0-9]+');
    }

一旦定義了模式，它就會自動應用到使用該參數名稱的所有路由：

    Route::get('/user/{id}', function (string $id) {
        // 僅當 {id} 是數字時執行。。。
    });

<a name="parameters-encoded-forward-slashes"></a>
#### 編碼正斜杠

Laravel 路由組件允許除 `/` 之外的所有字符出現在路由參數值中。 你必須使用 `where` 條件正則表達式明確允許 `/` 成為占位符的一部分：

    Route::get('/search/{search}', function (string $search) {
        return $search;
    })->where('search', '.*');

> 注意：僅在最後一個路由段中支持編碼的正斜杠。

<a name="named-routes"></a>
## 命名路由

命名路由允許為特定路由方便地生成 URL 或重定向。通過將 `name` 方法鏈接到路由定義上，可以指定路由的名稱：

    Route::get('/user/profile', function () {
        // ...
    })->name('profile');

你還可以為控制器操作指定路由名稱：

    Route::get(
        '/user/profile',
        [UserProfileController::class, 'show']
    )->name('profile');

> 注意：路由名稱應始終是唯一的。

<a name="generating-urls-to-named-routes"></a>


#### 生成命名路由的 URL

一旦你為給定的路由分配了一個名字，你可以在通過 Laravel 的 `route` 和 `redirect` 輔助函數生成 URL 或重定向時使用該路由的名稱：

    // 生成URL。。。
    $url = route('profile');

    // 生成重定向。。。
    return redirect()->route('profile');

    return to_route('profile');

如果命名路由定義了參數，你可以將參數作為第二個參數傳遞給 `route` 函數。 給定的參數將自動插入到生成的 URL 的正確位置：

    Route::get('/user/{id}/profile', function (string $id) {
        // ...
    })->name('profile');

    $url = route('profile', ['id' => 1]);

如果你在數組中傳遞其他參數，這些鍵 / 值對將自動添加到生成的 URL 的查詢字符串中：

    Route::get('/user/{id}/profile', function (string $id) {
        // ...
    })->name('profile');

    $url = route('profile', ['id' => 1, 'photos' => 'yes']);

    // /user/1/profile?photos=yes

> 技巧：有時，你可能希望為 URL 參數指定請求範圍的默認值，例如當前語言環境。 為此，你可以使用 [`URL::defaults` 方法](/docs/laravel/10.x/urlsmd/14854#default-values).

<a name="inspecting-the-current-route"></a>
#### 檢查當前路由

如果你想確定當前請求是否路由到給定的命名路由，你可以在 Route 實例上使用 `named` 方法。 例如，你可以從路由中間件檢查當前路由名稱：


    /**
     * 處理傳入請求。
      * @param  \Illuminate\Http\Request  $request
      * @param  \Closure  $next
      * @return mixed
	 */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->route()->named('profile')) {
            // ...
        }

        return $next($request);
    }



<a name="route-groups"></a>
## 路由組

路由組允許你共享路由屬性，例如中間件，而無需在每個單獨的路由上定義這些屬性。

嵌套組嘗試智能地將屬性與其父組 "合並"。中間件和 `where` 條件合並，同時附加名稱和前綴。 URI 前綴中的命名空間分隔符和斜杠會在適當的地方自動添加。

<a name="route-group-middleware"></a>
### 路由中間件

要將 [中間件](/docs/laravel/10.x/middleware) 分配給組內的所有路由，你可以在定義組之前使用 `middleware` 方法。 中間件按照它們在數組中列出的順序執行：

    Route::middleware(['first', 'second'])->group(function () {
        Route::get('/', function () {
            // 使用第一個和第二個中間件。。。
        });

        Route::get('/user/profile', function () {
            // 使用第一個和第二個中間件。。。
        });
    });

<a name="route-group-controllers"></a>
### 控制器

如果一組路由都使用相同的 [控制器](/docs/laravel/10.x/controllers), 你可以使用 `controller` 方法為組內的所有路由定義公共控制器。然後，在定義路由時，你只需要提供它們調用的控制器方法：

    use App\Http\Controllers\OrderController;

    Route::controller(OrderController::class)->group(function () {
        Route::get('/orders/{id}', 'show');
        Route::post('/orders', 'store');
    });

<a name="route-group-subdomain-routing"></a>
### 子域路由

路由組也可以用來處理子域路由。子域可以像路由 uri 一樣被分配路由參數，允許你捕獲子域的一部分以便在路由或控制器中使用。子域可以在定義組之前調用 `domain` 方法來指定:

    Route::domain('{account}.example.com')->group(function () {
        Route::get('user/{id}', function (string $account, string $id) {
            // ...
        });
    });

> 注意：為了確保子域路由是可以訪問的，你應該在注冊根域路由之前注冊子域路由。這將防止根域路由覆蓋具有相同 URI 路徑的子域路由。



<a name="route-group-prefixes"></a>
### 路由前綴

`prefix` 方法可以用給定的 URI 為組中的每個路由做前綴。例如，你可能想要在組內的所有路由 uri 前面加上 `admin` 前綴：

    Route::prefix('admin')->group(function () {
        Route::get('/users', function () {
            // 對應 "/admin/users" 的 URL
        });
    });

<a name="route-group-name-prefixes"></a>
### 路由名稱前綴

`name` 方法可以用給定字符串作為組中的每個路由名的前綴。例如，你可能想要用 `admin` 作為所有分組路由的前綴。因為給定字符串的前綴與指定的路由名完全一致，所以我們一定要提供末尾 `.` 字符在前綴中：

    Route::name('admin.')->group(function () {
        Route::get('/users', function () {
            // 被分配的路由名為："admin.users"
        })->name('users');
    });

<a name="route-model-binding"></a>
## 路由模型綁定

將模型 ID 注入到路由或控制器操作時，你通常會查詢數據庫以檢索與該 ID 對應的模型。Laravel 路由模型綁定提供了一種方便的方法來自動將模型實例直接注入到你的路由中。例如，你可以注入與給定 ID 匹配的整個 `User` 模型實例，而不是注入用戶的 ID。

<a name="implicit-binding"></a>
### 隱式綁定

Laravel 自動解析定義在路由或控制器操作中的 Eloquent 模型，其類型提示的變量名稱與路由段名稱匹配。例如：

    use App\Models\User;

    Route::get('/users/{user}', function (User $user) {
        return $user->email;
    });



由於 `$user` 變量被類型提示為 `App\Models\User` Eloquent 模型，並且變量名稱與 `{user}` URI 段匹配，Laravel 將自動注入 ID 匹配相應的模型實例 來自請求 URI 的值。如果在數據庫中沒有找到匹配的模型實例，將自動生成 404 HTTP 響應。

當然，使用控制器方法時也可以使用隱式綁定。同樣，請注意 `{user}` URI 段與控制器中的 `$user` 變量匹配，該變量包含 `App\Models\User` 類型提示：

    use App\Http\Controllers\UserController;
    use App\Models\User;

    // 路由定義。。。
    Route::get('/users/{user}', [UserController::class, 'show']);

    // 定義控制器方法。。。
    public function show(User $user)
    {
        return view('user.profile', ['user' => $user]);
    }

<a name="implicit-soft-deleted-models"></a>
#### 軟刪除模型

通常，隱式模型綁定不會檢索已 [軟刪除](/docs/laravel/10.x/eloquent#soft-deleting) 的模型。但是，你可以通過將 `withTrashed` 方法鏈接到你的路由定義來指示隱式綁定來檢索這些模型：

    use App\Models\User;

    Route::get('/users/{user}', function (User $user) {
        return $user->email;
    })->withTrashed();

<a name="customizing-the-key"></a>
<a name="customizing-the-default-key-name"></a>
#### 自定義密鑰

有時你可能希望使用 `id` 外的列來解析 Eloquent 模型。為此，你可以在路由參數定義中指定列：

    use App\Models\Post;

    Route::get('/posts/{post:slug}', function (Post $post) {
        return $post;
    });

如果你希望模型綁定在檢索給定模型類時始終使用 `id` 以外的數據庫列，則可以覆蓋 Eloquent 模型上的 `getRouteKeyName` 方法：

    /**
     * 獲取模型的路線密鑰。
     */
    public function getRouteKeyName(): string
    {
        return 'slug';
    }

<a name="implicit-model-binding-scoping"></a>
#### 自定義鍵和範圍

當在單個路由定義中隱式綁定多個 Eloquent 模型時，你可能希望限定第二個 Eloquent 模型的範圍，使其必須是前一個 Eloquent 模型的子模型。例如，考慮這個通過 slug 為特定用戶檢索博客文章的路由定義：

    use App\Models\Post;
    use App\Models\User;

    Route::get('/users/{user}/posts/{post:slug}', function (User $user, Post $post) {
        return $post;
    });

當使用自定義鍵控隱式綁定作為嵌套路由參數時，Laravel 將自動限定查詢範圍以通過其父級檢索嵌套模型，使用約定來猜測父級上的關系名稱。 在這種情況下，假設 `User` 模型有一個名為 `posts` 的關系（路由參數名稱的覆數形式），可用於檢索 `Post` 模型。

如果你願意，即使未提供自定義鍵，你也可以指示 Laravel 限定「子」綁定的範圍。為此，你可以在定義路由時調用 `scopeBindings` 方法：

    use App\Models\Post;
    use App\Models\User;

    Route::get('/users/{user}/posts/{post}', function (User $user, Post $post) {
        return $post;
    })->scopeBindings();

或者，你可以指示整個路由定義組使用範圍綁定：

    Route::scopeBindings()->group(function () {
        Route::get('/users/{user}/posts/{post}', function (User $user, Post $post) {
            return $post;
        });
    });

類似地，你可以通過調用 `withoutScopedBindings` 方法來明確的指示 Laravel 不做作用域綁定：

    Route::get('/users/{user}/posts/{post:slug}', function (User $user, Post $post) {
        return $post;
    })->withoutScopedBindings();

<a name="customizing-missing-model-behavior"></a>
#### 自定義缺失模型行為

通常，如果未找到隱式綁定模型，則會生成 404 HTTP 響應。但是，你可以通過在定義路由時調用 `missing` 方法來自定義此行為。`missing` 方法接受一個閉包，如果找不到隱式綁定模型，則將調用該閉包：

    use App\Http\Controllers\LocationsController;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Redirect;

    Route::get('/locations/{location:slug}', [LocationsController::class, 'show'])
            ->name('locations.view')
            ->missing(function (Request $request) {
                return Redirect::route('locations.index');
            });

<a name="implicit-enum-binding"></a>
### 隱式枚舉綁定

PHP 8.1 引入了對 [Enums](https://www.php.net/manual/en/language.enumerations.backed.php). 的支持。為了補充這個特性，Laravel 允許你在你的路由定義中鍵入一個 [Enums](https://www.php.net/manual/en/language.enumerations.backed.php) 並且 Laravel 只會在該路由段對應於一個有效的 Enum 值時調用該路由。否則，將自動返回 404 HTTP 響應。例如，給定以下枚舉：

```php
<?php

namespace App\Enums;

enum Category: string
{
    case Fruits = 'fruits';
    case People = 'people';
}
```

你可以定義一個只有在 `{category}` 路由段是 `fruits` 或 `people` 時才會被調用的路由。 否則，Laravel 將返回 404 HTTP 響應：

```php
use App\Enums\Category;
use Illuminate\Support\Facades\Route;

Route::get('/categories/{category}', function (Category $category) {
    return $category->value;
});
```

<a name="explicit-binding"></a>
### 顯式綁定

不需要使用 Laravel 隱式的、基於約定的模型解析來使用模型綁定。你還可以顯式定義路由參數與模型的對應方式。要注冊顯式綁定，請使用路由器的 `model` 方法為給定參數指定類。在 `RouteServiceProvider` 類的 `boot` 方法的開頭定義顯式模型綁定：

    use App\Models\User;
    use Illuminate\Support\Facades\Route;

    /**
     * 定義路由模型綁定、模式篩選器等。
     */
    public function boot(): void
    {
        Route::model('user', User::class);

        // ...
    }

接下來，定義一個包含 `{user}` 參數的路由：

    use App\Models\User;

    Route::get('/users/{user}', function (User $user) {
        // ...
    });

由於我們已將所有 `{user}` 參數綁定到 `App\Models\User` 模型，該類的一個實例將被注入到路由中。因此，例如，對 `users/1` 的請求將從 ID 為 `1` 的數據庫中注入 `User` 實例。

如果在數據庫中沒有找到匹配的模型實例，則會自動生成 404 HTTP 響應。

<a name="customizing-the-resolution-logic"></a>
#### 自定義解析邏輯

如果你想定義你自己的模型綁定解析邏輯，你可以使用 `Route::bind` 方法。傳遞給 `bind` 方法的閉包將接收 URI 段的值，並應返回應注入路由的類的實例。同樣，這種定制應該在應用程序的 `RouteServiceProvider` 的 `boot` 方法中進行：

    use App\Models\User;
    use Illuminate\Support\Facades\Route;

    /**
     * 定義路由模型綁定、模式篩選器等。
     */
    public function boot(): void
    {
        Route::bind('user', function (string $value) {
            return User::where('name', $value)->firstOrFail();
        });

        // ...
    }

或者，你可以覆蓋 Eloquent 模型上的 `resolveRouteBinding` 方法。此方法將接收 URI 段的值，並應返回應注入路由的類的實例：

    /**
     * 檢索綁定值的模型。
     *
     * @param  mixed  $value
     * @param  string|null  $field
     * @return \Illuminate\Database\Eloquent\Model|null
     */
    public function resolveRouteBinding($value, $field = null)
    {
        return $this->where('name', $value)->firstOrFail();
    }

如果路由正在使用 [implicit binding scoping](#implicit-model-binding-scoping), 則 `resolveChildRouteBinding` 方法將用於解析父模型的子綁定：

    /**
     * 檢索綁定值的子模型。
     *
     * @param  string  $childType
     * @param  mixed  $value
     * @param  string|null  $field
     * @return \Illuminate\Database\Eloquent\Model|null
     */
    public function resolveChildRouteBinding($childType, $value, $field)
    {
        return parent::resolveChildRouteBinding($childType, $value, $field);
    }

<a name="fallback-routes"></a>
## Fallback 路由

使用 `Route::fallback` 方法，你可以定義一個在沒有其他路由匹配傳入請求時將執行的路由。通常，未處理的請求將通過應用程序的異常處理程序自動呈現「404」頁面。但是，由於你通常會在 `routes/web.php` 文件中定義 fallback 路由，因此 web 中間件組中的所有中間件都將應用於該路由。你可以根據需要隨意向此路由添加額外的中間件：

    Route::fallback(function () {
        // ...
    });

> 注意：Fallback 路由應該始終是你的應用程序注冊的最後一個路由。

<a name="rate-limiting"></a>
## 速率限制

<a name="defining-rate-limiters"></a>
### 定義速率限制器

Laravel 包括功能強大且可定制的限速服務，你可以利用這些服務來限制給定路線或一組路線的流量。首先，你應該定義滿足應用程序需求的速率限制器配置。通常，這應該在應用程序的 `App\Providers\RouteServiceProvider` 類的 `configureRateLimiting` 方法中完成，該類已經包含了一個速率限制器定義，該定義應用於應用程序 `routes/api.php` 文件中的路由：

```php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

/**
 * 為應用程序配置速率限制器。
 */
protected function boot(): void
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
    });

    // ...
}
```

速率限制器是使用 `RateLimiter` 外觀的 `for` 方法定義的。for 方法接受一個速率限制器名稱和一個閉包，該閉包返回應該應用於分配給速率限制器的路由的限制配置。限制配置是 `Illuminate\Cache\RateLimiting\Limit` 類的實例。此類包含有用的「構建器」方法，以便你可以快速定義限制。速率限制器名稱可以是你希望的任何字符串：

```php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

/**
 * 為應用程序配置速率限制器。
 */
protected function boot(): void
{
    RateLimiter::for('global', function (Request $request) {
        return Limit::perMinute(1000);
    });

    // ...
}
```

如果傳入的請求超過指定的速率限制，Laravel 將自動返回一個帶有 429 HTTP 狀態碼的響應。如果你想定義自己的響應，應該由速率限制返回，你可以使用 `response` 方法：

    RateLimiter::for('global', function (Request $request) {
        return Limit::perMinute(1000)->response(function (Request $request, array $headers) {
            return response('Custom response...', 429, $headers);
        });
    });

由於速率限制器回調接收傳入的 HTTP 請求實例，你可以根據傳入的請求或經過身份驗證的用戶動態構建適當的速率限制：

    RateLimiter::for('uploads', function (Request $request) {
        return $request->user()->vipCustomer()
                    ? Limit::none()
                    : Limit::perMinute(100);
    });

<a name="segmenting-rate-limits"></a>
#### 分段速率限制

有時你可能希望按某個任意值對速率限制進行分段。例如，你可能希望每個 IP 地址每分鐘允許用戶訪問給定路由 100 次。為此，你可以在構建速率限制時使用 `by` 方法：

    RateLimiter::for('uploads', function (Request $request) {
        return $request->user()->vipCustomer()
                    ? Limit::none()
                    : Limit::perMinute(100)->by($request->ip());
    });

為了使用另一個示例來說明此功能，我們可以將每個經過身份驗證的用戶 ID 的路由訪問限制為每分鐘 100 次，或者對於訪客來說，每個 IP 地址每分鐘訪問 10 次：

    RateLimiter::for('uploads', function (Request $request) {
        return $request->user()
                    ? Limit::perMinute(100)->by($request->user()->id)
                    : Limit::perMinute(10)->by($request->ip());
    });

<a name="multiple-rate-limits"></a>
#### 多個速率限制

如果需要，你可以返回給定速率限制器配置的速率限制數組。將根據路由在數組中的放置順序評估每個速率限制：

    RateLimiter::for('login', function (Request $request) {
        return [
            Limit::perMinute(500),
            Limit::perMinute(3)->by($request->input('email')),
        ];
    });

<a name="attaching-rate-limiters-to-routes"></a>
### 將速率限制器附加到路由

可以使用 `throttle` [middleware](/docs/laravel/10.x/middleware)。 將速率限制器附加到路由或路由組。路由中間件接受你希望分配給路由的速率限制器的名稱：

    Route::middleware(['throttle:uploads'])->group(function () {
        Route::post('/audio', function () {
            // ...
        });

        Route::post('/video', function () {
            // ...
        });
    });

<a name="throttling-with-redis"></a>
#### 使用 Redis 節流

通常，`throttle` 中間件映射到 `Illuminate\Routing\Middleware\ThrottleRequests` 類。此映射在應用程序的 HTTP 內核 (App\Http\Kernel) 中定義。但是，如果你使用 Redis 作為應用程序的緩存驅動程序，你可能希望更改此映射以使用 `Illuminate\Routing\Middleware\ThrottleRequestsWithRedis` 類。這個類在使用 Redis 管理速率限制方面更有效：

    'throttle' => \Illuminate\Routing\Middleware\ThrottleRequestsWithRedis::class,

<a name="form-method-spoofing"></a>
## 偽造表單方法

HTML 表單不支持 `PUT` ， `PATCH` 或 `DELETE` 請求。所以，當定義 `PUT` ， `PATCH` 或 `DELETE` 路由用在 HTML 表單時，你將需要一個隱藏的加 `_method` 字段在表單中。該 `_method` 字段的值將會與 HTTP 請求一起發送。

    <form action="/example" method="POST">
        <input type="hidden" name="_method" value="PUT">
        <input type="hidden" name="_token" value="{{ csrf_token() }}">
    </form>

為方便起見，你可以使用 `@method` [Blade 指令](/docs/laravel/10.x/blade) 生成 `_method` 輸入字段：

    <form action="/example" method="POST">
        @method('PUT')
        @csrf
    </form>

<a name="accessing-the-current-route"></a>
## 訪問當前路由

你可以使用 `Route Facade` 的 `current`、`currentRouteName` 和 `currentRouteAction` 方法來訪問有關處理傳入請求的路由的信息：

    use Illuminate\Support\Facades\Route;

    $route = Route::current(); // Illuminate\Routing\Route
    $name = Route::currentRouteName(); // string
    $action = Route::currentRouteAction(); // string

你可以參考 [Route facade 的底層類](https://laravel.com/api/laravel/10.x/Illuminate/Routing/Router.html) 和 [Route 實例](https://laravel.com/api/laravel/10.x/Illuminate/Routing/Route.html) 的 API 文檔查看路由器和路由類上可用的所有方法。

<a name="cors"></a>
## 跨域資源共享 (CORS)

Laravel 可以使用你配置的值自動響應 CORS `OPTIONS` HTTP 請求。所有 CORS 設置都可以在應用程序的 `config/cors.php` 配置文件中進行配置。OPTIONS 請求將由默認包含在全局中間件堆棧中的 HandleCors [middleware](/docs/laravel/10.x/middleware) 自動處理。你的全局中間件堆棧位於應用程序的 HTTP 內核 (`App\Http\Kernel`) 中。

> 技巧：有關 CORS 和 CORS 標頭的更多信息，請參閱 [MDN 關於 CORS 的 Web 文檔](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#The_HTTP_response_headers)。

<a name="route-caching"></a>
## 路由緩存

在將應用程序部署到生產環境時，你應該利用 Laravel 的路由緩存。使用路由緩存將大大減少注冊所有應用程序路由所需的時間。要生成路由緩存，請執行 `route:cache` Artisan 命令：

```shell
php artisan route:cache
```

運行此命令後，你的緩存路由文件將在每個請求上加載。請記住，如果你添加任何新路線，你將需要生成新的路線緩存。因此，你應該只在項目部署期間運行 `route:cache` 命令。

你可以使用 `route:clear` 命令清除路由緩存：

```shell
php artisan route:clear
```


<a name="自定義秘鑰"></a>
<a name="自定義鍵和範圍"></a>
