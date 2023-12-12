# 控制器

- [介紹](#introduction)
- [編寫控制器](#writing-controllers)
    - [基本控制器](#basic-controllers)
    - [單動作控制器](#single-action-controllers)
- [控制器中間件](#controller-middleware)
- [資源控制器](#resource-controllers)
    - [部分資源路由](#restful-partial-resource-routes)
    - [嵌套資源](#restful-nested-resources)
    - [命名資源路由](#restful-naming-resource-routes)
    - [命名資源路由參數](#restful-naming-resource-route-parameters)
    - [範圍資源路由](#restful-scoping-resource-routes)
    - [本地化資源 URI](#restful-localizing-resource-uris)
    - [補充資源控制器](#restful-supplementing-resource-controllers)
    - [單例資源控制器](#singleton-resource-controllers)
- [依賴注入和控制器](#dependency-injection-and-controllers)

<a name="introduction"></a>
## 介紹

你可能希望使用「controller」類來組織此行為，而不是將所有請求處理邏輯定義為路由文件中的閉包。控制器可以將相關的請求處理邏輯分組到一個類中。 例如，一個 `UserController` 類可能會處理所有與用戶相關的傳入請求，包括顯示、創建、更新和刪除用戶。 默認情況下，控制器存儲在 `app/Http/Controllers` 目錄中。

<a name="writing-controllers"></a>
## 編寫控制器

<a name="basic-controllers"></a>
### 基本控制器

如果要快速生成新控制器，可以使用 `make:controller` Artisan 命令。默認情況下，應用程序的所有控制器都存儲在`app/Http/Controllers` 目錄中：

```shell
php artisan make:controller UserController
```

讓我們來看一個基本控制器的示例。控制器可以有任意數量的公共方法來響應傳入的HTTP請求：

    <?php

    namespace App\Http\Controllers;

    use App\Models\User;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * 顯示給定用戶的配置文件。
         */
        public function show(string $id): View
        {
            return view('user.profile', [
                'user' => User::findOrFail($id)
            ]);
        }
    }



編寫控制器類和方法後，可以定義到控制器方法的路由，如下所示：

    use App\Http\Controllers\UserController;

    Route::get('/user/{id}', [UserController::class, 'show']);

當傳入的請求與指定的路由 URI 匹配時，將調用 `App\Http\Controllers\UserController` 類的 `show` 方法，並將路由參數傳遞給該方法。

>技巧：控制器並不是 **必需** 繼承基礎類。如果控制器沒有繼承基礎類，你將無法使用一些便捷的功能，比如 `middleware` 和 `authorize` 方法。

<a name="single-action-controllers"></a>
### 單動作控制器

如果控制器動作特別覆雜，你可能會發現將整個控制器類專用於該單個動作很方便。為此，您可以在控制器中定義一個 `__invoke` 方法：

    <?php

    namespace App\Http\Controllers;

    use App\Models\User;
    use Illuminate\Http\Response;

    class ProvisionServer extends Controller
    {
        /**
         * 設置新的web服務器。
         */
        public function __invoke()
        {
            // ...
        }
    }

為單動作控制器注冊路由時，不需要指定控制器方法。相反，你可以簡單地將控制器的名稱傳遞給路由器：

    use App\Http\Controllers\ProvisionServer;

    Route::post('/server', ProvisionServer::class);

你可以使用 `make:controller` Artisan 命令的 `--invokable` 選項生成可調用控制器：

```shell
php artisan make:controller ProvisionServer --invokable
```

>技巧：可以使用 [stub 定制](/docs/laravel/10.x/artisan#stub-customization) 自定義控制器模板。

<a name="controller-middleware"></a>
## 控制器中間件

[中間件](/docs/laravel/10.x/middleware) 可以在你的路由文件中分配給控制器的路由：

    Route::get('profile', [UserController::class, 'show'])->middleware('auth');



或者，你可能會發現在控制器的構造函數中指定中間件很方便。使用控制器構造函數中的 `middleware` 方法，你可以將中間件分配給控制器的操作：

    class UserController extends Controller
    {
        /**
         * Instantiate a new controller instance.
         */
        public function __construct()
        {
            $this->middleware('auth');
            $this->middleware('log')->only('index');
            $this->middleware('subscribed')->except('store');
        }
    }

控制器還允許你使用閉包注冊中間件。這提供了一種方便的方法來為單個控制器定義內聯中間件，而無需定義整個中間件類：

    use Closure;
    use Illuminate\Http\Request;

    $this->middleware(function (Request $request, Closure $next) {
        return $next($request);
    });

<a name="resource-controllers"></a>
## 資源型控制器

如果你將應用程序中的每個 Eloquent 模型都視為資源，那麽通常對應用程序中的每個資源都執行相同的操作。例如，假設你的應用程序中包含一個 `Photo` 模型和一個 `Movie` 模型。用戶可能可以創建，讀取，更新或者刪除這些資源。

Laravel 的資源路由通過單行代碼即可將典型的增刪改查（“CURD”）路由分配給控制器。首先，我們可以使用 Artisan 命令 `make:controller` 的 `--resource` 選項來快速創建一個控制器:

```shell
php artisan make:controller PhotoController --resource
```

這個命令將會生成一個控制器 `app/Http/Controllers/PhotoController.php`。其中包括每個可用資源操作的方法。接下來，你可以給控制器注冊一個資源路由：

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class);



這個單一的路由聲明創建了多個路由來處理資源上的各種行為。生成的控制器為每個行為保留了方法，而且你可以通過運行 Artisan 命令 `route:list` 來快速了解你的應用程序。

你可以通過將數組傳參到 `resources` 方法中的方式來一次性的創建多個資源控制器：

    Route::resources([
        'photos' => PhotoController::class,
        'posts' => PostController::class,
    ]);

<a name="actions-handled-by-resource-controller"></a>
#### 資源控制器操作處理

|請求方式      | 請求URI                    | 行為       | 路由名稱
----------|------------------------|--------------|---------------------
GET       | `/photos`              | index        | photos.index
GET       | `/photos/create`       | create       | photos.create
POST      | `/photos`              | store        | photos.store
GET       | `/photos/{photo}`      | show         | photos.show
GET       | `/photos/{photo}/edit` | edit         | photos.edit
PUT/PATCH | `/photos/{photo}`      | update       | photos.update
DELETE    | `/photos/{photo}`      | destroy      | photos.destroy

<a name="customizing-missing-model-behavior"></a>
#### 自定義缺失模型行為

通常，如果未找到隱式綁定的資源模型，則會生成狀態碼為 404 的 HTTP 響應。 但是，你可以通過在定義資源路由時調用 `missing` 的方法來自定義該行為。`missing` 方法接受一個閉包，如果對於任何資源的路由都找不到隱式綁定模型，則將調用該閉包：

    use App\Http\Controllers\PhotoController;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Redirect;

    Route::resource('photos', PhotoController::class)
            ->missing(function (Request $request) {
                return Redirect::route('photos.index');
            });

<a name="soft-deleted-models"></a>
#### 軟刪除模型

通常情況下，隱式模型綁定將不會檢索已經進行了 [軟刪除](/docs/laravel/10.x/eloquent#soft-deleting) 的模型，並且會返回一個 404 HTTP 響應。但是，你可以在定義資源路由時調用 `withTrashed` 方法來告訴框架允許軟刪除的模型：

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class)->withTrashed();



當不傳遞參數調用 `withTrashed` 時，將在 `show`、`edit` 和 `update` 資源路由中允許軟刪除的模型。你可以通過一個數組指定這些路由的子集傳遞給 `withTrashed` 方法：

    Route::resource('photos', PhotoController::class)->withTrashed(['show']);

<a name="specifying-the-resource-model"></a>
#### 指定資源模型

如果你使用了路由模型的綁定 [路由模型綁定](/docs/laravel/10.x/routing#route-model-binding) 並且想在資源控制器的方法中使用類型提示，你可以在生成控制器的時候使用 `--model` 選項：

```shell
php artisan make:controller PhotoController --model=Photo --resource
```

<a name="generating-form-requests"></a>
#### 生成表單請求

你可以在生成資源控制器時提供 `--requests`  選項來讓 Artisan 為控制器的 storage 和 update 方法生成 [表單請求類](/docs/laravel/10.x/validation#form-request-validation)：

```shell
php artisan make:controller PhotoController --model=Photo --resource --requests
```

<a name="restful-partial-resource-routes"></a>
### 部分資源路由

當聲明資源路由時，你可以指定控制器處理的部分行為，而不是所有默認的行為：

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class)->only([
        'index', 'show'
    ]);

    Route::resource('photos', PhotoController::class)->except([
        'create', 'store', 'update', 'destroy'
    ]);

<a name="api-resource-routes"></a>
#### API 資源路由

當聲明用於 API 的資源路由時，通常需要排除顯示 HTML 模板的路由，例如 `create` 和 `edit`。為了方便，你可以使用 `apiResource` 方法來排除這兩個路由：

    use App\Http\Controllers\PhotoController;

    Route::apiResource('photos', PhotoController::class);



你也可以傳遞一個數組給 `apiResources` 方法來同時注冊多個 API 資源控制器：

    use App\Http\Controllers\PhotoController;
    use App\Http\Controllers\PostController;

    Route::apiResources([
        'photos' => PhotoController::class,
        'posts' => PostController::class,
    ]);

要快速生成不包含 `create` 或 `edit` 方法的 API 資源控制器，你可以在執行 `make:controller` 命令時使用 `--api` 參數：

```shell
php artisan make:controller PhotoController --api
```

<a name="restful-nested-resources"></a>
### 嵌套資源

有時可能需要定義一個嵌套的資源型路由。例如，照片資源可能被添加了多個評論。那麽可以在路由中使用 `.` 符號來聲明資源型控制器：

    use App\Http\Controllers\PhotoCommentController;

    Route::resource('photos.comments', PhotoCommentController::class);

該路由會注冊一個嵌套資源，可以使用如下 URI 訪問：

    /photos/{photo}/comments/{comment}

<a name="scoping-nested-resources"></a>
#### 限定嵌套資源的範圍

Laravel 的 [隱式模型綁定](/docs/laravel/10.x/routing#implicit-model-binding-scoping) 特性可以自動限定嵌套綁定的範圍，以便確認已解析的子模型會自動屬於父模型。定義嵌套路由時，使用 scoped 方法，可以開啟自動範圍限定，也可以指定 Laravel 應該按照哪個字段檢索子模型資源，有關如何完成此操作的更多信息，請參見有關 [範圍資源路由](#restful-scoping-resource-routes) 的文檔。

<a name="shallow-nesting"></a>
#### 淺層嵌套

通常，並不是在所有情況下都需要在 URI 中同時擁有父 ID 和子 ID，因為子 ID 已經是唯一的標識符。當使用唯一標識符（如自動遞增的主鍵）來標識 URL 中的模型時，可以選擇使用「淺嵌套」的方式定義路由：

    use App\Http\Controllers\CommentController;

    Route::resource('photos.comments', CommentController::class)->shallow();



上面的路由定義方式會定義以下路由：

|請求方式       | 請求URI                               | 行為       | 路由名稱
----------|-----------------------------------|--------------|---------------------
GET       | `/photos/{photo}/comments`        | index        | photos.comments.index
GET       | `/photos/{photo}/comments/create` | create       | photos.comments.create
POST      | `/photos/{photo}/comments`        | store        | photos.comments.store
GET       | `/comments/{comment}`             | show         | comments.show
GET       | `/comments/{comment}/edit`        | edit         | comments.edit
PUT/PATCH | `/comments/{comment}`             | update       | comments.update
DELETE    | `/comments/{comment}`             | destroy      | comments.destroy

<a name="restful-naming-resource-routes"></a>
### 命名資源路由

默認情況下，所有的資源控制器行為都有一個路由名稱。你可以傳入 `names` 數組來覆蓋這些名稱：

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class)->names([
        'create' => 'photos.build'
    ]);

<a name="restful-naming-resource-route-parameters"></a>
### 命名資源路由參數

默認情況下，`Route::resource` 會根據資源名稱的「單數」形式創建資源路由的路由參數。你可以使用 `parameters` 方法來輕松地覆蓋資源路由名稱。傳入 `parameters` 方法應該是資源名稱和參數名稱的關聯數組：

    use App\Http\Controllers\AdminUserController;

    Route::resource('users', AdminUserController::class)->parameters([
        'users' => 'admin_user'
    ]);

上面的示例將會為資源的 `show` 路由生成以下的 URL：

    /users/{admin_user}

<a name="restful-scoping-resource-routes"></a>
### 限定範圍的資源路由

Laravel 的 [作用域隱式模型綁定](/docs/laravel/10.x/routing#implicit-model-binding-scoping) 功能可以自動確定嵌套綁定的範圍，以便確認已解析的子模型屬於父模型。通過在定義嵌套資源時使用 `scoped` 方法，你可以啟用自動範圍界定，並指示 Laravel 應該通過以下方式來檢索子資源的哪個字段：

    use App\Http\Controllers\PhotoCommentController;

    Route::resource('photos.comments', PhotoCommentController::class)->scoped([
        'comment' => 'slug',
    ]);



此路由將注冊一個有範圍的嵌套資源，該資源可以通過以下 URI 進行訪問：

    /photos/{photo}/comments/{comment:slug}

當使用一個自定義鍵的隱式綁定作為嵌套路由參數時，Laravel 會自動限定查詢範圍，按照約定的命名方式去父類中查找關聯方法，然後檢索到對應的嵌套模型。在這種情況下，將假定 `Photo` 模型有一個叫 `comments` （路由參數名的覆數）的關聯方法，通過這個方法可以檢索到 `Comment` 模型。

<a name="restful-localizing-resource-uris"></a>
### 本地化資源 URIs

默認情況下，`Route::resource` 將會用英文動詞創建資源 URIs。如果需要自定義 `create` 和 `edit` 行為的動名詞，你可以在 `App\Providers\RouteServiceProvider` 的 `boot` 方法中使用 `Route::resourceVerbs` 方法實現：

    /**
     * 定義你的路由模型綁定，模式過濾器等
     */
    public function boot(): void
    {
        Route::resourceVerbs([
            'create' => 'crear',
            'edit' => 'editar',
        ]);

        // ...
    }

Laravel 的覆數器支持[配置幾種不同的語言](/docs/laravel/10.x/localization#pluralization-language)。自定義動詞和覆數語言後，諸如 `Route::resource('publicacion', PublicacionController::class)` 之類的資源路由注冊將生成以下URI：

    /publicacion/crear

    /publicacion/{publicaciones}/editar

<a name="restful-supplementing-resource-controllers"></a>
### 補充資源控制器

如果你需要向資源控制器添加超出默認資源路由集的其他路由，則應在調用 `Route::resource` 方法之前定義這些路由；否則，由 `resource` 方法定義的路由可能會無意中優先於您的補充路由：
單例資源
    use App\Http\Controller\PhotoController;

    Route::get('/photos/popular', [PhotoController::class, 'popular']);
    Route::resource('photos', PhotoController::class);

> 技巧：請記住讓你的控制器保持集中。如果你發現自己經常需要典型資源操作集之外的方法，請考慮將控制器拆分為兩個更小的控制器。



<a name="singleton-resource-controllers"></a>
### 單例資源控制器

有時候，應用中的資源可能只有一個實例。比如，用戶「個人資料」可被編輯或更新，但是一個用戶只會有一份「個人資料」。同樣，一張圖片也只有一個「縮略圖」。這些資源就是所謂「單例資源」，這意味著該資源有且只能有一個實例存在。這種情況下，你可以注冊成單例(signleton)資源控制器:

```php
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::singleton('profile', ProfileController::class);
```

上例中定義的單例資源會注冊如下所示的路由。如你所見，單例資源中「新建」路由沒有被注冊；並且注冊的路由不接收路由參數，因為該資源中只有一個實例存在：

|請求方式      | 請求 URI                               | 行為       | 路由名稱
----------|-----------------------------------|--------------|---------------------
GET       | `/profile`                        | show         | profile.show
GET       | `/profile/edit`                   | edit         | profile.edit
PUT/PATCH | `/profile`                        | update       | profile.update

單例資源也可以在標準資源內嵌套使用：

```php
Route::singleton('photos.thumbnail', ThumbnailController::class);
```

上例中， `photo` 資源將接收所有的[標準資源路由](#actions-handled-by-resource-controller)；不過，`thumbnail` 資源將會是個單例資源，它的路由如下所示：

| 請求方式      | 請求 URI                              | 行為  | 路由名稱               |
|-----------|----------------------------------|---------|--------------------------|
| GET       | `/photos/{photo}/thumbnail`      | show    | photos.thumbnail.show    |
| GET       | `/photos/{photo}/thumbnail/edit` | edit    | photos.thumbnail.edit    |
| PUT/PATCH | `/photos/{photo}/thumbnail`      | update  | photos.thumbnail.update  |

<a name="creatable-singleton-resources"></a>
#### Creatable 單例資源

有時，你可能需要為單例資源定義 create 和 storage 路由。要實現這一功能，你可以在注冊單例資源路由時，調用 `creatable` 方法：

```php
Route::singleton('photos.thumbnail', ThumbnailController::class)->creatable();
```



如下所示，將注冊以下路由。還為可創建的單例資源注冊 `DELETE` 路由：

| Verb      | URI                                | Action  | Route Name               |
|-----------|------------------------------------|---------|--------------------------|
| GET       | `/photos/{photo}/thumbnail/create` | create  | photos.thumbnail.create  |
| POST      | `/photos/{photo}/thumbnail`        | store   | photos.thumbnail.store   |
| GET       | `/photos/{photo}/thumbnail`        | show    | photos.thumbnail.show    |
| GET       | `/photos/{photo}/thumbnail/edit`   | edit    | photos.thumbnail.edit    |
| PUT/PATCH | `/photos/{photo}/thumbnail`        | update  | photos.thumbnail.update  |
| DELETE    | `/photos/{photo}/thumbnail`        | destroy | photos.thumbnail.destroy |

如果希望 Laravel 為單個資源注冊 `DELETE` 路由，但不注冊創建或存儲路由，則可以使用 `destroyable` 方法：

```php
Route::singleton(...)->destroyable();
```

<a name="api-singleton-resources"></a>
#### API 單例資源

`apiSingleton` 方法可用於注冊將通過API操作的單例資源，從而不需要 `create` 和 `edit`  路由：

```php
Route::apiSingleton('profile', ProfileController::class);
```

當然， API 單例資源也可以是 `可創建的` ，它將注冊 `store` 和 `destroy` 資源路由：

```php
Route::apiSingleton('photos.thumbnail', ProfileController::class)->creatable();
```

<a name="dependency-injection-and-controllers"></a>
## 依賴注入和控制器

<a name="constructor-injection"></a>
#### 構造函數注入

Laravel [服務容器](/docs/laravel/10.x/container) 用於解析所有 Laravel 控制器。因此，可以在其構造函數中對控制器可能需要的任何依賴項進行類型提示。聲明的依賴項將自動解析並注入到控制器實例中：

    <?php

    namespace App\Http\Controllers;

    use App\Repositories\UserRepository;

    class UserController extends Controller
    {
        /**
         * 創建新控制器實例。
         */
        public function __construct(
            protected UserRepository $users,
        ) {}
    }



<a name="method-injection"></a>
#### 方法注入

除了構造函數注入，還可以在控制器的方法上鍵入提示依賴項。方法注入的一個常見用例是將 `Illuminate\Http\Request` 實例注入到控制器方法中：

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class UserController extends Controller
    {
        /**
         * 存儲新用戶。
         */
        public function store(Request $request): RedirectResponse
        {
            $name = $request->name;

            // 存儲用戶。。。

            return redirect('/users');
        }
    }

如果控制器方法也需要路由參數，那就在其他依賴項之後列出路由參數。例如，路由是這樣定義的：

    use App\Http\Controllers\UserController;

    Route::put('/user/{id}', [UserController::class, 'update']);

如下所示，你依然可以類型提示 `Illuminate\Http\Request` 並通過定義您的控制器方法訪問 `id` 參數：

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class UserController extends Controller
    {
        /**
         * 更新給定用戶。
         */
        public function update(Request $request, string $id): RedirectResponse
        {
            // 更新用戶。。。

            return redirect('/users');
        }
    }
