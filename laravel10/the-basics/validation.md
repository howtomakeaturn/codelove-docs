# 表單驗證

- [簡介](#introduction)
- [快速開始](#validation-quickstart)
    - [定義路由](#quick-defining-the-routes)
    - [創建控制器](#quick-creating-the-controller)
    - [編寫驗證邏輯](#quick-writing-the-validation-logic)
    - [顯示驗證錯誤信息](#quick-displaying-the-validation-errors)
    - [回填表單](#repopulating-forms)
    - [可選字段的注意事項](#a-note-on-optional-fields)
    - [驗證錯誤響應的格式化](#validation-error-response-format)
- [表單請求驗證](#form-request-validation)
    - [創建表單請求類](#creating-form-requests)
    - [表單請求授權驗證](#authorizing-form-requests)
    - [自定義錯誤消息](#customizing-the-error-messages)
    - [表單輸入預處理](#preparing-input-for-validation)
- [手動創建驗證器](#manually-creating-validators)
    - [自動重定向](#automatic-redirection)
    - [命名錯誤包](#named-error-bags)
    - [自定義錯誤消息](#manual-customizing-the-error-messages)
    - [驗證後的鉤子](#after-validation-hook)
- [使用驗證後的表單輸入](#working-with-validated-input)
- [使用驗證錯誤信息](#working-with-error-messages)
    - [在本地化文件中指定自定義消息](#specifying-custom-messages-in-language-files)
    - [在本地化文件中指定屬性](#specifying-attribute-in-language-files)
    - [在本地化文件中指定值](#specifying-values-in-language-files)
- [可用的驗證規則](#available-validation-rules)
- [按條件添加驗證規則](#conditionally-adding-rules)
- [驗證數組](#validating-arrays)
    - [驗證多維數組](#validating-nested-array-input)
    - [錯誤消息的索引和定位](#error-message-indexes-and-positions)
- [驗證文件](#validating-files)
- [驗證密碼](#validating-passwords)
- [自定義驗證規則](#custom-validation-rules)
    - [使用 Rule 對象](#using-rule-objects)
    - [使用閉包函數](#using-closures)
    - [隱式規則](#implicit-rules)

<a name="introduction"></a>
## 簡介

Laravel 提供了幾種不同的方法來驗證傳入應用程序的數據。最常見的做法是在所有傳入的 HTTP 請求中使用 `validate` 方法。同時，我們還將討論其他驗證方法。

Laravel 包含了各種方便的驗證規則，你可以將它們應用於數據，甚至可以驗證給定數據庫表中的值是否唯一。我們將詳細介紹每個驗證規則，以便你熟悉 Laravel 的所有驗證功能。

<a name="validation-quickstart"></a>
## 快速開始

為了了解 Laravel 強大的驗證功能，我們來看一個表單驗證並將錯誤消息展示給用戶的完整示例。通過閱讀概述，這將會對你如何使用 Laravel 驗證傳入的請求數據有一個很好的理解：

<a name="quick-defining-the-routes"></a>
### 定義路由

首先，假設我們在 `routes/web.php` 路由文件中定義了下面這些路由：

```
use App\Http\Controllers\PostController;
Route::get('/post/create', [PostController::class, 'create']);
Route::post('/post', [PostController::class, 'store']);
```

`GET` 路由會顯示一個供用戶創建新博客文章的表單，而 `POST` 路由會將新的博客文章存儲到數據庫中。

<a name="quick-creating-the-controller"></a>
### 創建控制器
接下來，讓我們一起來看看處理這些路由的簡單控制器。我們暫時留空了 store 方法：

```
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PostController extends Controller
{
    /**
     * 博客的表單視圖
     */
    public function create(): View
    {
        return view('post.create');
    }

    /**
     * 存儲博客的 Action
     */
    public function store(Request $request): RedirectResponse
    {
        // 驗證並且執行存儲邏輯

        $post = /** ... */

        return to_route('post.show', ['post' => $post->id]);
    }
}
```

<a name="quick-writing-the-validation-logic"></a>
### 編寫驗證邏輯

現在我們開始在 `store` 方法中編寫用來驗證新的博客文章的邏輯代碼。為此，我們將使用 `Illuminate\Http\Request` 類提供的 `validate` 方法。如果驗證通過，你的代碼會繼續正常運行。如果驗證失敗，則會拋出 `Illuminate\Validation\ValidationException` 異常，並自動將對應的錯誤響應返回給用戶。

如果在傳統 HTTP 請求期間驗證失敗，則會生成對先前 URL 的重定向響應。如果傳入的請求是 XHR，將將返回包含驗證錯誤信息的 JSON 響應。

為了深入理解 `validate`  方法，讓我們接著回到 `store` 方法中：

    /**
     * 存儲一篇新的博客文章。
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|unique:posts|max:255',
            'body' => 'required',
        ]);

        // 博客文章驗證通過...

        return redirect('/posts');
    }

如你所見，驗證規則被傳遞到 `validate` 方法中。不用擔心——所有可用的驗證規則均已 [存檔](#available-validation-rules)。 另外再提醒一次，如果驗證失敗，會自動生成一個對應的響應。如果驗證通過，那我們的控制器會繼續正常運行。

另外，驗證規則可以使用數組，而不是單個 `|` 分隔的字符串：

    $validatedData = $request->validate([
        'title' => ['required', 'unique:posts', 'max:255'],
        'body' => ['required'],
    ]);

此外，你可以使用 `validateWithBag` 方法來驗證請求，並將所有錯誤信息儲存在一個 [命名錯誤信息包](#named-error-bags)：

    $validatedData = $request->validateWithBag('post', [
        'title' => ['required', 'unique:posts', 'max:255'],
        'body' => ['required'],
    ]);

<a name="stopping-on-first-validation-failure"></a>
#### 在首次驗證失敗時停止運行

有時候我們希望某個字段在第一次驗證失敗後就停止運行驗證規則，只需要將 `bail` 添加到規則中：

    $request->validate([
        'title' => 'bail|required|unique:posts|max:255',
        'body' => 'required',
    ]);

在這個例子中，如果 `title` 字段沒有通過 `unique` 規則，那麽不會繼續驗證 `max` 規則。規則會按照分配時的順序來驗證。



<a name="a-note-on-nested-attributes"></a>
#### 嵌套字段的說明

如果傳入的 HTTP 請求包含「嵌套」參數，你可以在驗證規則中使用`.`語法來指定這些參數：

```
$request->validate([
	'title' => 'required|unique:posts|max:255',
	'author.name' => 'required',
	'author.description' => 'required',
]);
```

另外，如果你的字段名稱包含點，則可以通過使用反斜杠將點轉義，以防止將其解釋為`.`語法：

```
$request->validate([
	'title' => 'required|unique:posts|max:255',
	'v1\.0' => 'required',
]);
```

<a name="quick-displaying-the-validation-errors"></a>
### 顯示驗證錯誤信息

那麽，如果傳入的請求字段沒有通過驗證規則呢？如前所述，Laravel 會自動將用戶重定向到之前的位置。此外，所有的驗證錯誤和[請求輸入](/docs/laravel/10.x/requests#retrieving-old-input)都會自動存入到[閃存 session](/docs/laravel/10.x/session#flash-data) 中。

`Illuminate\View\Middleware\ShareErrorsFromSession`中間件與應用程序的所有視圖共享一個`$errors`變量，該變量由`web`中間件組提供。當應用該中間件時，`$errors` 變量始終在視圖中可用，`$errors` 變量是 `Illuminate\Support\MessageBag` 的實例。更多有關使用該對象的信息，[查看文檔](#working-with-error-messages)

因此，在實例中，當驗證失敗時，用戶將重定向到控制器`create`方法，從而在視圖中顯示錯誤消息：

```blade
<!-- /resources/views/post/create.blade.php -->

<h1>Create Post</h1>

@if ($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<!-- Create Post Form -->
```



<a name="quick-customizing-the-error-messages"></a>
#### 在語言文件中指定自定義消息

Laravel 的內置驗證規則每個都對應一個錯誤消息，位於應用程序的`lang/en/validation.php`文件中。在此文件中，你將找到每個驗證規則的翻譯條目。你可以根據應用程序的需求隨意更改或修改這些消息。

此外，你可以將此文件覆制到另一個翻譯語言目錄中，以翻譯應用程序語言的消息。要了解有關 Laravel 本地化的更多信息，請查看完整的[本地化文檔](/docs/laravel/10.x/localization).

> **注意**
> 默認，Laravel 應用程序框架不包括`lang`目錄。如果你想自定義 Laravel 的語言文件，你可以通過`lang:publish` Artisan 命令發布它們。

<a name="quick-xhr-requests-and-validation"></a>
#### XHR 請求 & 驗證

在如下示例中，我們使用傳統形式將數據發送到應用程序。但是，許多應用程序從 JavaScript 驅動的前端接收 XHR 請求。在 XHR 請求期間使用`validate`方法時，Laravel 將不會生成重定向響應。相反，Laravel生成一個[包含所有驗證錯誤的 JSON 響應](#validation-error-response-format)。該 JSON 響應將以 422 HTTP 狀態碼發送。

<a name="the-at-error-directive"></a>
#### `@error`指令

你亦可使用 `@error` [Blade](/docs/laravel/10.x/blade) 指令方便地檢查給定的屬性是否存在驗證錯誤信息。在`@error`指令中，你可以輸出`$message`變量以顯示錯誤信息：

```blade
<!-- /resources/views/post/create.blade.php -->

<label for="title">Post Title</label>

<input id="title"
    type="text"
    name="title"
    class="@error('title') is-invalid @enderror">

@error('title')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror
```



如果你使用[命名錯誤包](#named-error-bags)，你可以將錯誤包的名稱作為第二個參數傳遞給`@error`指令：

```blade
<input ... class="@error('title', 'post') is-invalid @enderror">
```

<a name="repopulating-forms"></a>
### 回填表單

當 Laravel 由於驗證錯誤而生成重定向響應時，框架將自動[將所有請求的輸入閃存到 session 中](/docs/laravel/10.x/session#flash-data)。這樣做是為了方便你在下一個請求期間訪問輸入，並重新填充用戶嘗試提交的表單。

要從先前的請求中檢索閃存的輸入，請在 `Illuminate\Http\Request`的實例上調用`old`方法。 `old`方法將從 [session](/docs/laravel/10.x/session) 中提取先前閃存的輸入數據：

    $title = $request->old('title');

Laravel 還提供了一個全局性的`old`。如果要在 [Blade 模板](/docs/laravel/10.x/blade), 中顯示舊輸入，則使用`old`來重新填充表單會更加方便。如果給定字段不存在舊輸入，則將返回`null`：

```blade
<input type="text" name="title" value="{{ old('title') }}">
```

<a name="a-note-on-optional-fields"></a>
### 關於可選字段的注意事項

默認情況下， 在你的 Laravel 應用的全局中間件堆棧`App\Http\Kernel`類中包含了`TrimStrings`和`ConvertEmptyStringsToNull`中間件。因此，如果你不想讓`null`被驗證器標識為非法的話，你需要將「可選」字段標志為`nullable`。例如：

    $request->validate([
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
        'publish_at' => 'nullable|date',
    ]);



在此示例中，我們指定 `publish_at` 字段可以為 `null` 或有效的日期表示。如果沒有將 `nullable` 修飾符添加到規則定義中，則驗證器會將 `null` 視為無效日期。

<a name="validation-error-response-format"></a>
### 驗證錯誤響應格式

當您的應用程序拋出 `Illuminate\Validation\ValidationException` 異常，並且傳入的 HTTP 請求希望返回 JSON 響應時，Laravel 將自動為您格式化錯誤消息，並返回 `422 Unprocessable Entity` HTTP 響應。

下面是驗證錯誤的 JSON 響應格式示例。請注意，嵌套的錯誤鍵會被轉換為“點”符號格式：

```json
{
    "message": "The team name must be a string. (and 4 more errors)",
    "errors": {
        "team_name": [
            "The team name must be a string.",
            "The team name must be at least 1 characters."
        ],
        "authorization.role": [
            "The selected authorization.role is invalid."
        ],
        "users.0.email": [
            "The users.0.email field is required."
        ],
        "users.2.email": [
            "The users.2.email must be a valid email address."
        ]
    }
}
```

<a name="form-request-validation"></a>
## 表單請求驗證

<a name="creating-form-requests"></a>
### 創建表單請求

對於更覆雜的驗證場景，您可能希望創建一個“表單請求”。表單請求是自定義請求類，封裝了自己的驗證和授權邏輯。要創建一個表單請求類，您可以使用 `make:request` Artisan CLI 命令：

```shell
php artisan make:request StorePostRequest
```

生成的表單請求類將被放置在 `app/Http/Requests` 目錄中。如果此目錄不存在，則在運行 `make:request` 命令時將創建該目錄。Laravel 生成的每個表單請求都有兩個方法：`authorize` 和 `rules`。



你可能已經猜到了，`authorize` 方法負責確定當前已認證用戶是否可以執行請求所代表的操作，而 `rules` 方法返回應用於請求數據的驗證規則：

    /**
     * 獲取應用於請求的驗證規則。
     *
     * @return array<string, \Illuminate\Contracts\Validation\Rule|array|string>
     */
    public function rules(): array
    {
        return [
            'title' => 'required|unique:posts|max:255',
            'body' => 'required',
        ];
    }

> **注意**
> 你可以在 `rules` 方法的簽名中指定任何你需要的依賴項類型提示。它們將通過 Laravel 的 [服務容器](/docs/laravel/10.x/container) 自動解析。

那麽，驗證規則是如何被評估的呢？你只需要在控制器方法中對請求進行類型提示。在調用控制器方法之前，傳入的表單請求將被驗證，這意味著你不需要在控制器中添加任何驗證邏輯：

    /**
     * 存儲新博客文章。
     */
    public function store(StorePostRequest $request): RedirectResponse
    {
        // 傳入的請求有效...

        // 檢索已驗證的輸入數據...
        $validated = $request->validated();

        // Retrieve a portion of the validated input data...
        $validated = $request->safe()->only(['name', 'email']);
        $validated = $request->safe()->except(['name', 'email']);

        // 存儲博客文章...

        return redirect('/posts');
    }

如果驗證失敗，將生成重定向響應以將用戶發送回其先前的位置。錯誤也將被閃存到會話中，以便進行顯示。如果請求是 XHR 請求，則會向用戶返回帶有 422 狀態代碼的 HTTP 響應，其中包含[JSON 格式的驗證錯誤表示](#validation-error-response-format)。


<a name="adding-after-hooks-to-form-requests"></a>
#### 在表單請求後添加鉤子

如果您想在表單請求「之後」添加驗證鉤子，可以使用 `withValidator` 方法。這個方法接收一個完整的驗證構造器，允許你在驗證結果返回之前調用任何方法：

    use Illuminate\Validation\Validator;

    /**
     * 配置驗證實例。
     */
    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            if ($this->somethingElseIsInvalid()) {
                $validator->errors()->add('field', 'Something is wrong with this field!');
            }
        });
    }


<a name="request-stopping-on-first-validation-rule-failure"></a>
#### 單個驗證規則失敗後停止

通過向您的請求類添加 `stopOnFirstFailure` 屬性，您可以通知驗證器一旦發生單個驗證失敗後，停止驗證所有規則。

    /**
     * 表示驗證器是否應在第一個規則失敗時停止。
     *
     * @var bool
     */
    protected $stopOnFirstFailure = true;

<a name="customizing-the-redirect-location"></a>
#### 自定義重定向

如前所述，當表單請求驗證失敗時，將會生成一個讓用戶返回到先前位置的重定向響應。當然，您也可以自由定義此行為。如果您要這樣做，可以在表單請求中定義一個 `$redirect` 屬性：

    /**
     * 如果驗證失敗，用戶應重定向到的 URI。
     *
     * @var string
     */
    protected $redirect = '/dashboard';

或者，如果你想將用戶重定向到一個命名路由，你可以定義一個 `$redirectRoute` 屬性來代替：

    /**
     * 如果驗證失敗，用戶應該重定向到的路由。
     *
     * @var string
     */
    protected $redirectRoute = 'dashboard';

<a name="authorizing-form-requests"></a>
### 表單請求授權驗證

表單請求類內也包含了 `authorize` 方法。在這個方法中，您可以檢查經過身份驗證的用戶確定其是否具有更新給定資源的權限。例如，您可以判斷用戶是否擁有更新文章評論的權限。最有可能的是，您將通過以下方法與你的 [授權與策略](/docs/laravel/10.x/authorization) 進行交互：

    use App\Models\Comment;

    /**
     * 確定用戶是否有請求權限。
     */
    public function authorize(): bool
    {
        $comment = Comment::find($this->route('comment'));

        return $comment && $this->user()->can('update', $comment);
    }



由於所有的表單請求都是繼承了 Laravel 中的請求基類，所以我們可以使用 `user` 方法去獲取當前認證登錄的用戶。同時請注意上述例子中對 `route` 方法的調用。這個方法允許你在被調用的路由上獲取其定義的 URI 參數，譬如下面例子中的 `{comment}` 參數：

    Route::post('/comment/{comment}');

因此，如果您的應用程序正在使用 [路由模型綁定](/docs/laravel/10.x/routing#route-model-binding)，則可以通過將解析的模型作為請求從而讓您的代碼更加簡潔：

    return $this->user()->can('update', $this->comment);

如果 `authorize` 方法返回 `false`，則會自動返回一個包含 403 狀態碼的 HTTP 響應，也不會運行控制器的方法。

如果您打算在應用程序的其它部分處理請求的授權邏輯，只需從 `authorize` 方法返回 `true`：

    /**
     * 判斷用戶是否有請求權限。
     */
    public function authorize(): bool
    {
        return true;
    }

> **注意**
> 你可以向 `authorize` 方法傳入所需的任何依賴項。它們會自動被 Laravel 提供的 [服務容器](/docs/laravel/10.x/container) 自動解析。

<a name="customizing-the-error-messages"></a>
### 自定義錯誤消息

你可以通過重寫表單請求的 `messages` 方法來自定義錯誤消息。此方法應返回屬性 / 規則對及其對應錯誤消息的數組：

    /**
     * 獲取已定義驗證規則的錯誤消息。
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'title.required' => 'A title is required',
            'body.required' => 'A message is required',
        ];
    }



<a name="customizing-the-validation-attributes"></a>
#### 自定義驗證屬性

Laravel 的許多內置驗證規則錯誤消息都包含 `:attribute` 占位符。如果您希望將驗證消息的 `:attribute` 部分替換為自定義屬性名稱，則可以重寫 `attributes` 方法來指定自定義名稱。此方法應返回屬性 / 名稱對的數組：

    /**
     * 獲取驗證錯誤的自定義屬性
     *
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'email' => 'email address',
        ];
    }

<a name="preparing-input-for-validation"></a>
### 準備驗證輸入

如果您需要在應用驗證規則之前修改或清理請求中的任何數據，您可以使用 `prepareForValidation` 方法：

    use Illuminate\Support\Str;

    /**
     * 準備驗證數據。
     */
    protected function prepareForValidation(): void
    {
        $this->merge([
            'slug' => Str::slug($this->slug),
        ]);
    }

同樣地，如果您需要在驗證完成後對任何請求數據進行規範化，您可以使用 `passedValidation` 方法：

    use Illuminate\Support\Str;

    /**
     * Handle a passed validation attempt.
     */
    protected function passedValidation(): void
    {
        $this->replace(['name' => 'Taylor']);
    }

<a name="manually-creating-validators"></a>
## 手動創建驗證器

如果您不想在請求上使用 `validate` 方法，可以使用 `Validator`  [門面](/laravel/10.x/facades) 手動創建一個驗證器實例。門面上的 `make` 方法會生成一個新的驗證器實例：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Validator;

    class PostController extends Controller
    {
        /**
         * 存儲新的博客文章。
         */
        public function store(Request $request): RedirectResponse
        {
            $validator = Validator::make($request->all(), [
                'title' => 'required|unique:posts|max:255',
                'body' => 'required',
            ]);

            if ($validator->fails()) {
                return redirect('post/create')
                            ->withErrors($validator)
                            ->withInput();
            }

            // 獲取驗證後的輸入...
            $validated = $validator->validated();

            // 獲取驗證後輸入的一部分...
            $validated = $validator->safe()->only(['name', 'email']);
            $validated = $validator->safe()->except(['name', 'email']);

            // 存儲博客文章...

            return redirect('/posts');
        }
    }



第一個參數傳遞給`make`方法的是要驗證的數據。第二個參數是一個應用於數據的驗證規則的數組。

在確定請求驗證是否失敗之後，您可以使用`withErrors`方法將錯誤消息閃存到會話中。使用此方法後，`$errors`變量將自動在重定向後與您的視圖共享，從而可以輕松地將其顯示回用戶。`withErrors`方法接受驗證器、`MessageBag`或PHP數組。

#### 單個驗證規則失敗後停止

通過向您的請求類添加 `stopOnFirstFailure` 屬性，您可以通知驗證器一旦發生單個驗證失敗後，停止驗證所有規則。

    if ($validator->stopOnFirstFailure()->fails()) {
        // ...
    }

<a name="automatic-redirection"></a>
### 自動重定向

如果您想手動創建驗證器實例，但仍要利用HTTP請求的`validate`方法提供的自動重定向，可以在現有驗證器實例上調用`validate`方法。如果驗證失敗，則會自動重定向用戶，或者在XHR請求的情況下，將返回一個[JSON響應](#validation-error-response-format)

    Validator::make($request->all(), [
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
    ])->validate();

如果驗證失敗，您可以使用`validateWithBag`方法將錯誤消息存儲在[命名錯誤包](#named-error-bags)中：

    Validator::make($request->all(), [
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
    ])->validateWithBag('post');

<a name="named-error-bags"></a>
### 命名的錯誤包

如果您在同一頁上有多個表單，您可能希望為包含驗證錯誤的`MessageBag`命名，以便檢索特定表單的錯誤消息。為此，將名稱作為第二個參數傳遞給`withErrors`：

    return redirect('register')->withErrors($validator, 'login');



你可以通過 `$errors` 變量訪問命名後的 `MessageBag` 實例：

```blade
{{ $errors->login->first('email') }}
```

<a name="manual-customizing-the-error-messages"></a>
### 自定義錯誤消息

如果需要，你可以提供驗證程序實例使用的自定義錯誤消息，而不是 Laravel 提供的默認錯誤消息。有幾種指定自定義消息的方法。首先，您可以將自定義消息作為第三個參數傳遞給 `Validator::make` 方法：

    $validator = Validator::make($input, $rules, $messages = [
        'required' => 'The :attribute field is required.',
    ]);

在此示例中，`:attribute` 占位符將被驗證中的字段的實際名稱替換。您也可以在驗證消息中使用其它占位符。例如：

    $messages = [
        'same' => 'The :attribute and :other must match.',
        'size' => 'The :attribute must be exactly :size.',
        'between' => 'The :attribute value :input is not between :min - :max.',
        'in' => 'The :attribute must be one of the following types: :values',
    ];

<a name="specifying-a-custom-message-for-a-given-attribute"></a>
#### 為給定屬性指定自定義消息

有時你可能希望只為特定屬性指定自定義錯誤消息。你可以使用 `.` 表示法。首先指定屬性名稱，然後指定規則：

    $messages = [
        'email.required' => 'We need to know your email address!',
    ];

<a name="specifying-custom-attribute-values"></a>
#### 指定自定義屬性值

Laravel 的許多內置錯誤消息都包含一個 `:attribute` 占位符，該占位符已被驗證中的字段或屬性的名稱替換。為了自定義用於替換特定字段的這些占位符的值，你可以將自定義屬性的數組作為第四個參數傳遞給 `Validator::make` 方法：

    $validator = Validator::make($input, $rules, $messages, [
        'email' => 'email address',
    ]);



<a name="after-validation-hook"></a>
### 驗證後鉤子

驗證器允許你在完成驗證操作後執行附加的回調。以便你處理下一步的驗證，甚至是往信息集合中添加更多的錯誤信息。你可以在驗證器實例上使用 `after` 方法實現：

    use Illuminate\Support\Facades;
    use Illuminate\Validation\Validator;

    $validator = Facades\Validator::make(/* ... */);

    $validator->after(function (Validator $validator) {
        if ($this->somethingElseIsInvalid()) {
            $validator->errors()->add(
                'field', 'Something is wrong with this field!'
            );
        }
    });

    if ($validator->fails()) {
        // ...
    }

<a name="working-with-validated-input"></a>
## 處理驗證字段

在使用表單請求或手動創建的驗證器實例驗證傳入請求數據後，你可能希望檢索經過驗證的請求數據。 這可以通過多種方式實現。 首先，你可以在表單請求或驗證器實例上調用 `validated` 方法。 此方法返回已驗證的數據數組：

    $validated = $request->validated();

    $validated = $validator->validated();

或者，你可以在表單請求或驗證器實例上調用 `safe` 方法。 此方法返回一個 `Illuminate\Support\ValidatedInput`的實例。 該實例對象包含 `only`、`except` 和 `all` 方法來檢索已驗證數據的子集或整個已驗證數據數組：

    $validated = $request->safe()->only(['name', 'email']);

    $validated = $request->safe()->except(['name', 'email']);

    $validated = $request->safe()->all();

此外， `Illuminate\Support\ValidatedInput` 實例可以像數組一樣被叠代和訪問：

    // 叠代驗證數據...
    foreach ($request->safe() as $key => $value) {
        // ...
    }

    // 訪問驗證數據數組...
    $validated = $request->safe();

    $email = $validated['email'];



`merge` 方法可以給驗證過的數據添加額外的字段：

    $validated = $request->safe()->merge(['name' => 'Taylor Otwell']);

`collect` 方法以 [collection](/docs/laravel/10.x/collections) 實例的形式來檢索驗證的數據：

    $collection = $request->safe()->collect();

<a name="working-with-error-messages"></a>
## 使用錯誤消息

在調用 `Validator` 實例的 `errors` 方法後，會收到一個 `Illuminate\Support\MessageBag` 實例，用於處理錯誤信息。自動提供給所有視圖的 `$errors` 變量也是 `MessageBag` 類的一個實例。

<a name="retrieving-the-first-error-message-for-a-field"></a>
#### 檢索字段的第一條錯誤消息

`first` 方法返回給定字段的第一條錯誤信息：

    $errors = $validator->errors();

    echo $errors->first('email');

<a name="retrieving-all-error-messages-for-a-field"></a>
#### 檢索一個字段的所有錯誤信息

`get` 方法用於檢索一個給定字段的所有錯誤信息，返回值類型為數組：

    foreach ($errors->get('email') as $message) {
        // ...
    }

對於數組表單字段，可以使用 `*` 來檢索每個數組元素的所有錯誤信息：

    foreach ($errors->get('attachments.*') as $message) {
        // ...
    }

<a name="retrieving-all-error-messages-for-all-fields"></a>
#### 檢索所有字段的所有錯誤信息

`all` 方法用於檢索所有字段的所有錯誤信息，返回值類型為數組：

    foreach ($errors->all() as $message) {
        // ...
    }

<a name="determining-if-messages-exist-for-a-field"></a>
#### 判斷字段是否存在錯誤信息

`has` 方法可用於確定一個給定字段是否存在任何錯誤信息：

    if ($errors->has('email')) {
        // ...
    }



<a name="specifying-custom-messages-in-language-files"></a>
### 在語言文件中指定自定義消息

Laravel 內置的驗證規則都有一個錯誤信息，位於應用程序的 `lang/en/validation.php` 文件中。在這個文件中, 你會發現每個驗證規則都有一個翻譯條目。可以根據你的應用程序的需要，自由地改變或修改這些信息。

此外, 你可以把這個文件覆制到另一個語言目錄，為你的應用程序的語言翻譯信息。要了解更多關於Laravel本地化的信息, 請查看完整的 [本地化](/docs/laravel/10.x/localization)。

> **Warning**
> 默認情況下, Laravel 應用程序的骨架不包括 `lang` 目錄. 如果你想定制 Laravel 的語言文件, 可以通過 `lang:publish` Artisan 命令發布它們。

<a name="custom-messages-for-specific-attributes"></a>
#### 針對特定屬性的自定義信息

可以在應用程序的驗證語言文件中自定義用於指定屬性和規則組合的錯誤信息。將自定義信息添加到應用程序的 `lang/xx/validation.php` 語言文件的  `custom` 數組中：

    'custom' => [
        'email' => [
            'required' => 'We need to know your email address!',
            'max' => 'Your email address is too long!'
        ],
    ],

<a name="specifying-attribute-in-language-files"></a>
### 在語言文件中指定屬性

Laravel 內置的錯誤信息包括一個 `:attribute` 占位符，它被替換為驗證中的字段或屬性的名稱。如果你希望你的驗證信息中的 `:attribute` 部分被替換成一個自定義的值, 可以在 `lang/xx/validation.php` 文件的 `attributes` 數組中指定自定義屬性名稱:

    'attributes' => [
        'email' => 'email address',
    ],

> **Warning**
> 默認情況下, Laravel 應用程序的骨架不包括 `lang` 目錄. 如果你想定制 Laravel 的語言文件, 可以通過 `lang:publish` Artisan 命令發布它們。



<a name="specifying-values-in-language-files"></a>
### 指定語言文件中的值

Laravel 內置的驗證規則錯誤信息包含一個 `:value` 占位符，它被替換成請求屬性的當前值。然而, 你可能偶爾需要在驗證信息的 `:value` 部分替換成自定義的值。 例如，如果 `payment_type` 的值為 `cc` 則需要驗證信用卡號碼:

    Validator::make($request->all(), [
        'credit_card_number' => 'required_if:payment_type,cc'
    ]);

如果這個驗證規則失敗了，它將產生以下錯誤信息:

```none
The credit card number field is required when payment type is cc.
```

你可以在 `lang/xx/validation.php` 語言文件中通過定義一個 `values` 數組來指定一個更友好的提示，而不是顯示 `cc` 作為支付類型值：

    'values' => [
        'payment_type' => [
            'cc' => 'credit card'
        ],
    ],

> **Warning**
> 默認情況下, Laravel 應用程序的骨架不包括 `lang` 目錄. 如果你想定制 Laravel 的語言文件, 你可以通過 `lang:publish` Artisan 命令發布它們。

定義這個值後，驗證規則將產生以下錯誤信息：

```none
The credit card number field is required when payment type is credit card.
```
<a name="available-validation-rules"></a>
## 可用的驗證規則

下面是所有可用的驗證規則及其功能的列表:

<style>
    .collection-method-list > p {
        columns: 10.8em 3; -moz-columns: 10.8em 3; -webkit-columns: 10.8em 3;
    }

    .collection-method-list a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
</style>

<div class="collection-method-list" markdown="1">

[Accepted](#rule-accepted)
[Accepted If](#rule-accepted-if)
[Active URL](#rule-active-url)
[After (Date)](#rule-after)
[After Or Equal (Date)](#rule-after-or-equal)
[Alpha](#rule-alpha)
[Alpha Dash](#rule-alpha-dash)
[Alpha Numeric](#rule-alpha-num)
[Array](#rule-array)
[Ascii](#rule-ascii)
[Bail](#rule-bail)
[Before (Date)](#rule-before)
[Before Or Equal (Date)](#rule-before-or-equal)
[Between](#rule-between)
[Boolean](#rule-boolean)
[Confirmed](#rule-confirmed)
[Current Password](#rule-current-password)
[Date](#rule-date)
[Date Equals](#rule-date-equals)
[Date Format](#rule-date-format)
[Decimal](#rule-decimal)
[Declined](#rule-declined)
[Declined If](#rule-declined-if)
[Different](#rule-different)
[Digits](#rule-digits)
[Digits Between](#rule-digits-between)
[Dimensions (Image Files)](#rule-dimensions)
[Distinct](#rule-distinct)
[Doesnt Start With](#rule-doesnt-start-with)
[Doesnt End With](#rule-doesnt-end-with)
[Email](#rule-email)
[Ends With](#rule-ends-with)
[Enum](#rule-enum)
[Exclude](#rule-exclude)
[Exclude If](#rule-exclude-if)
[Exclude Unless](#rule-exclude-unless)
[Exclude With](#rule-exclude-with)
[Exclude Without](#rule-exclude-without)
[Exists (Database)](#rule-exists)
[File](#rule-file)
[Filled](#rule-filled)
[Greater Than](#rule-gt)
[Greater Than Or Equal](#rule-gte)
[Image (File)](#rule-image)
[In](#rule-in)
[In Array](#rule-in-array)
[Integer](#rule-integer)
[IP Address](#rule-ip)
[JSON](#rule-json)
[Less Than](#rule-lt)
[Less Than Or Equal](#rule-lte)
[Lowercase](#rule-lowercase)
[MAC Address](#rule-mac)
[Max](#rule-max)
[Max Digits](#rule-max-digits)
[MIME Types](#rule-mimetypes)
[MIME Type By File Extension](#rule-mimes)
[Min](#rule-min)
[Min Digits](#rule-min-digits)
[Missing](#rule-missing)
[Missing If](#rule-missing-if)
[Missing Unless](#rule-missing-unless)
[Missing With](#rule-missing-with)
[Missing With All](#rule-missing-with-all)
[Multiple Of](#rule-multiple-of)
[Not In](#rule-not-in)
[Not Regex](#rule-not-regex)
[Nullable](#rule-nullable)
[Numeric](#rule-numeric)
[Password](#rule-password)
[Present](#rule-present)
[Prohibited](#rule-prohibited)
[Prohibited If](#rule-prohibited-if)
[Prohibited Unless](#rule-prohibited-unless)
[Prohibits](#rule-prohibits)
[Regular Expression](#rule-regex)
[Required](#rule-required)
[Required If](#rule-required-if)
[Required Unless](#rule-required-unless)
[Required With](#rule-required-with)
[Required With All](#rule-required-with-all)
[Required Without](#rule-required-without)
[Required Without All](#rule-required-without-all)
[Required Array Keys](#rule-required-array-keys)
[Same](#rule-same)
[Size](#rule-size)
[Sometimes](#validating-when-present)
[Starts With](#rule-starts-with)
[String](#rule-string)
[Timezone](#rule-timezone)
[Unique (Database)](#rule-unique)
[Uppercase](#rule-uppercase)
[URL](#rule-url)
[ULID](#rule-ulid)
[UUID](#rule-uuid)

</div>



<a name="rule-accepted"></a>
#### accepted

待驗證字段必須是 `「yes」` ，`「on」` ，`1` 或 `true`。這對於驗證「服務條款」的接受或類似字段時很有用。

<a name="rule-accepted-if"></a>
#### accepted_if:anotherfield,value,...

如果另一個正在驗證的字段等於指定的值，則驗證中的字段必須為 `「yes」` ，`「on」` ，`1` 或 `true`。 這對於驗證「服務條款」接受或類似字段很有用。

<a name="rule-active-url"></a>
#### active_url

根據 `dns_get_record` PHP 函數，驗證中的字段必須具有有效的 A 或 AAAA 記錄。 提供的 URL 的主機名使用 `parse_url` PHP 函數提取，然後傳遞給 `dns_get_record`。

<a name="rule-after"></a>
#### after:_date_

驗證中的字段必須是給定日期之後的值。日期將被傳遞給 `strtotime` PHP 函數中，以便轉換為有效的 `DateTime` 實例：

    'start_date' => 'required|date|after:tomorrow'

你也可以指定另一個要與日期比較的字段，而不是傳遞要由 `strtotime` 處理的日期字符串：

    'finish_date' => 'required|date|after:start_date'

<a name="rule-after-or-equal"></a>
#### after\_or\_equal:_date_

待驗證字段的值對應的日期必須在給定日期之後或與給定的日期相同。可參閱 [after](#rule-after) 規則獲取更多信息。

<a name="rule-alpha"></a>
#### alpha

待驗證字段必須是包含在 [`\p{L}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AL%3A%5D&g=&i=) 和 [`\p{M}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AM%3A%5D&g=&i=) 中的Unicode字母字符。



為了將此驗證規則限制在 ASCII 範圍內的字符（`a-z` 和`A-Z`），你可以為驗證規則提供 `ascii` 選項：

```php
'username' => 'alpha:ascii',
```

<a name="rule-alpha-dash"></a>
#### alpha_dash

被驗證的字段必須完全是 Unicode 字母數字字符中的 [`\p{L}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AL%3A%5D&g=&i=)、[`\p{M}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AM%3A%5D&g=&i=)、[`\p{N}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AN%3A%5D&g=&i=)，以及 ASCII 破折號（`-`）和 ASCII 下劃線（`_`）。

為了將此驗證規則限制在 ASCII 範圍內的字符（`a-z` 和`A-Z`），你可以為驗證規則提供 `ascii` 選項：

```php
'username' => 'alpha_dash:ascii',
```

<a name="rule-alpha-num"></a>
#### alpha_num

被驗證的字段必須完全是 Unicode 字母數字字符中的 [`\p{L}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AL%3A%5D&g=&i=), [`\p{M}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AM%3A%5D&g=&i=) 和 [`\p{N}`](https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AN%3A%5D&g=&i=)。

為了將此驗證規則限制在 ASCII 範圍內的字符（`a-z` 和`A-Z`），你可以為驗證規則提供 `ascii` 選項：

```php
'username' => 'alpha_num:ascii',
```

<a name="rule-array"></a>
#### array

待驗證字段必須是有效的 PHP `數組`。

當向 `array`  規則提供附加值時，輸入數組中的每個鍵都必須出現在提供給規則的值列表中。在以下示例中，輸入數組中的 `admin` 鍵無效，因為它不包含在提供給  `array` 規則的值列表中：

    use Illuminate\Support\Facades\Validator;

    $input = [
        'user' => [
            'name' => 'Taylor Otwell',
            'username' => 'taylorotwell',
            'admin' => true,
        ],
    ];

    Validator::make($input, [
        'user' => 'array:name,username',
    ]);



通常，你應該始終指定允許出現在數組中的數組鍵。

#### ascii

正在驗證的字段必須完全是 7 位的 ASCII 字符。

#### bail

在首次驗證失敗後立即終止驗證。

雖然 `bail` 規則只會在遇到驗證失敗時停止驗證特定字段，但 `stopOnFirstFailure` 方法會通知驗證器，一旦發生單個驗證失敗，它應該停止驗證所有屬性:

    if ($validator->stopOnFirstFailure()->fails()) {
        // ...
    }

#### before:_date_

待驗證字段的值對應的日期必須在給定的日期之前。這個日期將被傳遞給 PHP 函數 `strtotime` 以便轉化為有效的 `DateTime` 實例。此外，與 [`after`](#rule-after) 規則一致，可以將另外一個待驗證的字段作為 `date` 的值。

#### before\_or\_equal:_date_

待驗證字段的值必須是給定日期之前或等於給定日期的值。這個日期將被傳遞給 PHP 函數 `strtotime` 以便轉化為有效的 `DateTime` 實例。此外，與 [`after`](#rule-after) 規則一致， 可以將另外一個待驗證的字段作為 `date` 的值。

#### between:_min_,_max_

待驗證字段值的大小必須介於給定的最小值和最大值（含）之間。字符串、數字、數組和文件的計算方式都使用 [`size`](#rule-size) 方法。



<a name="rule-boolean"></a>
#### boolean

驗證的字段必須可以轉換為 Boolean 類型。 可接受的輸入為 `true`, `false`, `1`, `0`, `「1」`, 和 `「0」`。

<a name="rule-confirmed"></a>
#### confirmed

驗證字段必須與 `{field}_confirmation` 字段匹配。例如，如果驗證字段是 `password`，則輸入中必須存在相應的 `password_confirmation` 字段。

<a name="rule-current-password"></a>
#### current_password

驗證字段必須與已認證用戶的密碼匹配。 您可以使用規則的第一個參數指定 [authentication guard](/docs/laravel/10.x/authentication):

    'password' => 'current_password:api'

<a name="rule-date"></a>
#### date

驗證字段必須是 `strtotime` PHP 函數可識別的有效日期。

<a name="rule-date-equals"></a>
#### date_equals:_date_

驗證字段必須等於給定日期。日期將傳遞到 PHP `strtotime` 函數中，以轉換為有效的 `DateTime` 實例。

<a name="rule-date-format"></a>
#### date_format:_format_,...

驗證字段必須匹配給定的 *format* 。在驗證字段時，您應該只使用 `date` 或 `date_format` 中的**其中一個**，而不是同時使用。該驗證規則支持 PHP 的 [DateTime](https://www.php.net/manual/en/class.datetime.php) 類支持的所有格式。

<a name="rule-decimal"></a>
#### decimal:_min_,_max_

驗證字段必須是數值類型，並且必須包含指定的小數位數：

    // 必須正好有兩位小數（例如 9.99）...
    'price' => 'decimal:2'

    // 必須有 2 到 4 位小數...
    'price' => 'decimal:2,4'

<a name="rule-declined"></a>


#### declined

正在驗證的字段必須是 `「no」`，`「off」`，`0` 或者 `false`。

<a name="rule-declined-if"></a>
#### declined_if:anotherfield,value,...

如果另一個驗證字段的值等於指定值，則驗證字段的值必須為`「no」`、`「off」`、`0`或`false`。

<a name="rule-different"></a>
#### different:_field_

驗證的字段值必須與字段 _field_ 的值不同。

<a name="rule-digits"></a>
#### digits:_value_

驗證的整數必須具有確切長度 _value_ 。

<a name="rule-digits-between"></a>
#### digits_between:_min_,_max_

驗證的整數長度必須在給定的 _min_ 和 _max_ 之間。

<a name="rule-dimensions"></a>
#### dimensions

驗證的文件必須是符合規則參數指定尺寸限制的圖像：

    'avatar' => 'dimensions:min_width=100,min_height=200'

可用的限制條件有: _min\_width_ , _max\_width_ , _min\_height_ , _max\_height_ , _width_ , _height_ , _ratio_ .

_ratio_ 約束應該表示為寬度除以高度。 這可以通過像 `3/2` 這樣的語句或像 `1.5` 這樣的浮點數來指定：

    'avatar' => 'dimensions:ratio=3/2'

由於此規則需要多個參數，因此你可以 `Rule::dimensions` 方法來構造可讀性高的規則：

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'avatar' => [
            'required',
            Rule::dimensions()->maxWidth(1000)->maxHeight(500)->ratio(3 / 2),
        ],
    ]);

<a name="rule-distinct"></a>
#### distinct

驗證數組時，正在驗證的字段不能有任何重覆值：

    'foo.*.id' => 'distinct'

默認情況下，Distinct 使用松散的變量比較。要使用嚴格比較，您可以在驗證規則定義中添加 `strict` 參數：

    'foo.*.id' => 'distinct:strict'



你可以在驗證規則的參數中添加 `ignore_case` ，以使規則忽略大小寫差異：

    'foo.*.id' => 'distinct:ignore_case'

<a name="rule-doesnt-start-with"></a>
#### doesnt_start_with:_foo_,_bar_,...

驗證的字段不能以給定值之一開頭。

<a name="rule-doesnt-end-with"></a>
#### doesnt_end_with:_foo_,_bar_,...

驗證的字段不能以給定值之一結尾。

<a name="rule-email"></a>
#### email

驗證的字段必須符合 `e-mail` 地址格式。當前版本，此種驗證規則由 [`egulias/email-validator`](https://github.com/egulias/EmailValidator) 提供支持。默認情況下，使用 `RFCValidation` 驗證樣式，但你也可以應用其他驗證樣式：

    'email' => 'email:rfc,dns'

上面的示例將應用 `RFCValidation` 和 `DNSCheckValidation` 驗證。以下是你可以應用的驗證樣式的完整列表：

<div class="content-list" markdown="1">

- `rfc`: `RFCValidation`
- `strict`: `NoRFCWarningsValidation`
- `dns`: `DNSCheckValidation`
- `spoof`: `SpoofCheckValidation`
- `filter`: `FilterEmailValidation`
- `filter_unicode`: `FilterEmailValidation::unicode()`

</div>

`filter` 驗證器是 Laravel 內置的一個驗證器，它使用 PHP 的 `filter_var` 函數實現。在 Laravel 5.8 版本之前，它是 Laravel 默認的電子郵件驗證行為。

> **注意**
> `dns` 和 `spoof` 驗證器需要 PHP 的 `intl` 擴展。

<a name="rule-ends-with"></a>
#### ends_with:_foo_,_bar_,...

被驗證的字段必須以給定值之一結尾。

<a name="rule-enum"></a>
#### enum

`Enum` 規則是一種基於類的規則，用於驗證被驗證字段是否包含有效的枚舉值。 `Enum` 規則的構造函數只接受枚舉的名稱作為參數：

    use App\Enums\ServerStatus;
    use Illuminate\Validation\Rules\Enum;

    $request->validate([
        'status' => [new Enum(ServerStatus::class)],
    ]);



<a name="rule-exclude"></a>
#### exclude

 `validate` 和 `validated` 方法中會排除掉當前驗證的字段。

<a name="rule-exclude-if"></a>
#### exclude_if:_anotherfield_,_value_

如果 _anotherfield_ 等於 _value_ ，`validate` 和 `validated` 方法中會排除掉當前驗證的字段。

在一些覆雜的場景，也可以使用 `Rule::excludeIf` 方法，這個方法需要返回一個布爾值或者一個匿名函數。如果返回的是匿名函數，那麽這個函數應該返回 `true` 或 `false`去決定被驗證的字段是否應該被排除掉：

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($request->all(), [
        'role_id' => Rule::excludeIf($request->user()->is_admin),
    ]);

    Validator::make($request->all(), [
        'role_id' => Rule::excludeIf(fn () => $request->user()->is_admin),
    ]);

<a name="rule-exclude-unless"></a>
#### exclude_unless:_anotherfield_,_value_

除非 *anotherfield* 等於 *value* ，否則 `validate` 和 `validated` 方法中會排除掉當前的字段。如果 *value* 為 `null` （`exclude_unless:name,null`），那麽成立的條件就是被比較的字段為 `null` 或者表單中沒有該字段。

<a name="rule-exclude-with"></a>
#### exclude_with:_anotherfield_

如果表單數據中有 _anotherfield_ ，`validate` 和 `validated` 方法中會排除掉當前的字段。

<a name="rule-exclude-without"></a>
#### exclude_without:_anotherfield_

如果表單數據中沒有 _anotherfield_ ，`validate` 和 `validated` 方法中會排除掉當前的字段。



<a name="rule-exists"></a>
#### exists:_table_,_column_

驗證的字段值必須存在於指定的表中。

<a name="basic-usage-of-exists-rule"></a>
#### Exists 規則的基本用法

    'state' => 'exists:states'

如果未指定 `column` 選項，則將使用字段名稱。因此，在這種情況下，該規則將驗證 `states` 數據庫表是否包含一條記錄，該記錄的 `state` 列的值與請求的 `state` 屬性值匹配。

<a name="specifying-a-custom-column-name"></a>
#### 指定自定義列名

你可以將驗證規則使用的數據庫列名稱指定在數據庫表名稱之後：

    'state' => 'exists:states,abbreviation'

有時候，你或許需要去明確指定一個具體的數據庫連接，用於 `exists` 查詢。你可以通過在表名前面添加一個連接名稱來實現這個效果。

    'email' => 'exists:connection.staff,email'

你可以明確指定 Eloquent 模型，而不是直接指定表名：

    'user_id' => 'exists:App\Models\User,id'

如果你想要自定義一個執行查詢的驗證規則，你可以使用 `Rule` 類去流暢地定義規則。在這個例子中，我們也將指定驗證規則為一個數組，而不再是使用 `|` 分割他們：

    use Illuminate\Database\Query\Builder;
    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'email' => [
            'required',
            Rule::exists('staff')->where(function (Builder $query) {
                return $query->where('account_id', 1);
            }),
        ],
    ]);

您可以通過將列名作為 `exists` 方法的第二個參數來明確指定 `Rule::exists` 方法生成的 `exists` 規則應該使用的數據庫列名：

    'state' => Rule::exists('states', 'abbreviation'),



<a name="rule-file"></a>
#### file

要驗證的字段必須是一個成功的已經上傳的文件。

<a name="rule-filled"></a>
#### filled

當字段存在時，要驗證的字段必須是一個非空的。

<a name="rule-gt"></a>
#### gt:_field_

要驗證的字段必須要大於給定的字段。這兩個字段必須是同一個類型。字符串、數字、數組和文件都使用 [`size`](#rule-size) 進行相同的評估。

<a name="rule-gte"></a>
#### gte:_field_

要驗證的字段必須要大於或等於給定的字段。這兩個字段必須是同一個類型。字符串、數字、數組和文件都使用 [`size`](#rule-size) 進行相同的評估。

<a name="rule-image"></a>
#### image

正在驗證的文件必須是圖像（jpg、jpeg、png、bmp、gif、svg 或 webp）。

<a name="rule-in"></a>
#### in:_foo_,_bar_,...

驗證字段必須包含在給定的值列表中。由於此規則通常要求你 `implode` 數組，因此可以使用 `Rule::in` 方法來流暢地構造規則:

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'zones' => [
            'required',
            Rule::in(['first-zone', 'second-zone']),
        ],
    ]);

當 `in` 規則與 `array` 規則組合使用時，輸入數組中的每個值都必須出現在提供給 `in` 規則的值列表中。 在以下示例中，輸入數組中的`LAS` 機場代碼無效，因為它不包含在提供給 `in` 規則的機場列表中：

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    $input = [
        'airports' => ['NYC', 'LAS'],
    ];

    Validator::make($input, [
        'airports' => [
            'required',
            'array',
        ],
        'airports.*' => Rule::in(['NYC', 'LIT']),
    ]);



<a name="rule-in-array"></a>
#### in_array:_anotherfield_.*

驗證的字段必須存在於_anotherfield_的值中。

<a name="rule-integer"></a>
#### integer

驗證的字段必須是一個整數。

**警告**
這個驗證規則並不會驗證輸入是否為"integer"變量類型，它只會驗證輸入是否為 PHP 的 `FILTER_VALIDATE_INT` 規則接受的類型。如果你需要驗證輸入是否為數字，請結合 [numeric](#rule-numeric) 驗證規則使用。

<a name="rule-ip"></a>
#### ip

驗證的字段必須是一個 IP 地址。

<a name="ipv4"></a>
#### ipv4

驗證的字段必須是一個 IPv4 地址。

<a name="ipv6"></a>
#### ipv6

驗證的字段必須是一個 IPv6 地址。

<a name="rule-json"></a>
#### json

驗證的字段必須是一個有效的 JSON 字符串。

<a name="rule-lt"></a>
#### lt:_field_

驗證的字段必須小於給定的 *field* 字段。兩個字段必須是相同的類型。字符串、數字、數組和文件的處理方式與 [`size`](#rule-size) 規則相同。

<a name="rule-lte"></a>
#### lte:_field_

驗證的字段必須小於或等於給定的 *field* 字段。兩個字段必須是相同的類型。字符串、數字、數組和文件的處理方式與 [`size`](#rule-size) 規則相同。

<a name="rule-lowercase"></a>
#### lowercase

驗證的字段必須是小寫的。

<a name="rule-mac"></a>
#### mac_address

驗證的字段必須是一個 MAC 地址。



<a name="rule-max"></a>
#### max:_value_

驗證的字段的值必須小於或等於最大值 *value*。字符串、數字、數組和文件的處理方式與 [`size`](#rule-size) 規則相同。

<a name="rule-max-digits"></a>
#### max_digits:_value_

驗證的整數必須具有最大長度 value。

<a name="rule-mimetypes"></a>
#### mimetypes:_text/plain_,...

驗證的文件必須匹配給定的 MIME 類型之一：

    'video' => 'mimetypes:video/avi,video/mpeg,video/quicktime'

為了確定上傳文件的 MIME 類型，將讀取文件內容並嘗試猜測 MIME 類型，這可能與客戶端提供的 MIME 類型不同。

<a name="rule-mimes"></a>
#### mimes:_foo_,_bar_,...

驗證的文件必須具有與列出的擴展名之一對應的 MIME 類型。

<a name="basic-usage-of-mime-rule"></a>
#### MIME 規則的基本用法

    'photo' => 'mimes:jpg,bmp,png'

盡管您只需要指定擴展名，但該規則實際上通過讀取文件內容並猜測其 MIME 類型來驗證文件的 MIME 類型。可以在以下位置找到 MIME 類型及其相應擴展名的完整列表：

[https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types](https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types)

<a name="rule-min"></a>
#### min:_value_

驗證的字段的值必須大於或等於最小值 *value*。字符串、數字、數組和文件的處理方式與 [`size`](#rule-size) 規則相同。



<a name="rule-min-digits"></a>
#### min_digits:_value_

 驗證的整數必須具有至少_value_位數。

<a name="rule-multiple-of"></a>
#### multiple_of:_value_

 驗證的字段必須是_value_的倍數。

<a name="rule-missing"></a>
#### missing

 驗證的字段在輸入數據中必須不存在。

 <a name="rule-missing-if"></a>
 #### missing_if:_anotherfield_,_value_,...

 如果_anotherfield_字段等於任何_value_，則驗證的字段必須不存在。

 <a name="rule-missing-unless"></a>
 #### missing_unless:_anotherfield_,_value_

 驗證的字段必須不存在，除非_anotherfield_字段等於任何_value_。

 <a name="rule-missing-with"></a>
 #### missing_with:_foo_,_bar_,...

 如果任何其他指定的字段存在，則驗證的字段必須不存在。

 <a name="rule-missing-with-all"></a>
 #### missing_with_all:_foo_,_bar_,...

 如果所有其他指定的字段都存在，則驗證的字段必須不存在。

<a name="rule-not-in"></a>
#### not_in:_foo_,_bar_,...

驗證的字段不能包含在給定值列表中。可以使用`Rule::notIn`方法流暢地構建規則：

    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'toppings' => [
            'required',
            Rule::notIn(['sprinkles', 'cherries']),
        ],
    ]);

<a name="rule-not-regex"></a>
#### not_regex:_pattern_

驗證的字段必須不匹配給定的正則表達式。

在內部，此規則使用PHP的`preg_match`函數。指定的模式應遵守`preg_match`所需的相同格式要求，因此也應包括有效的分隔符。例如：`'email' => 'not_regex:/^.+$/i'`。

**警告** 使用`regex` / `not_regex`模式時，可能需要使用數組指定驗證規則，而不是使用`|`分隔符，特別是如果正則表達式包含`|`字符。



<a name="rule-nullable"></a>
#### nullable

需要驗證的字段可以為 null。

<a name="rule-numeric"></a>
#### numeric

需要驗證的字段必須是[數字類型](https://www.php.net/manual/en/function.is-numeric.php)。

<a name="rule-password"></a>
#### password

需要驗證的字段必須與已認證用戶的密碼相匹配。

>**警告**
> 這個規則在 Laravel 9 中被重命名為 `current_password` 並計劃刪除，請改用 [Current Password](#rule-current-password) 規則。

<a name="rule-present"></a>
#### present

需要驗證的字段必須存在於輸入數據中。

<a name="rule-prohibited"></a>
#### prohibited

需要驗證的字段必須不存在或為空。如果符合以下條件之一，字段將被認為是“空”：

<div class="content-list" markdown="1">

-   值為 `null`。
-   值為空字符串。
-   值為空數組或空的可計數對象。
-   值為上傳文件，但文件路徑為空。

</div>

<a name="rule-prohibited-if"></a>
#### prohibited_if:_anotherfield_,_value_,...

如果 anotherfield 字段等於任何 value，則需要驗證的字段必須不存在或為空。如果符合以下條件之一，字段將被認為是“空”：

<div class="content-list" markdown="1">

-   值為 `null`。
-   值為空字符串。
-   值為空數組或空的可計數對象。
-   值為上傳文件，但文件路徑為空。

</div>

如果需要覆雜的條件禁止邏輯，則可以使用 `Rule::prohibitedIf` 方法。該方法接受一個布爾值或一個閉包。當給定一個閉包時，閉包應返回 `true` 或 `false`，以指示是否應禁止驗證字段：

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($request->all(), [
        'role_id' => Rule::prohibitedIf($request->user()->is_admin),
    ]);

    Validator::make($request->all(), [
        'role_id' => Rule::prohibitedIf(fn () => $request->user()->is_admin),
    ]);



<a name="rule-prohibited-unless"></a>
#### prohibited_unless:_anotherfield_,_value_,...

在 anotherfield 字段等於任何 value 時，驗證的字段必須為空或缺失。如果一個字段符合以下任一標準，則它被認為是“空”的：

<div class="content-list" markdown="1">

-   值為 `null`。
-   值為空字符串。
-   值為一個空數組或一個空的 `Countable` 對象。
-   值為上傳文件且路徑為空。

</div>

<a name="rule-prohibits"></a>
#### prohibits:_anotherfield_,...

如果驗證的字段不為空或缺失，則 anotherfield 中的所有字段都必須為空或缺失。如果一個字段符合以下任一標準，則它被認為是“空”的：

<div class="content-list" markdown="1">

-   值為 `null`。
-   值為空字符串。
-   值為一個空數組或一個空的 `Countable` 對象。
-   值為上傳文件且路徑為空。

</div>

<a name="rule-regex"></a>
#### regex:_pattern_

驗證的字段必須匹配給定的正則表達式。

在內部，此規則使用 PHP 的 `preg_match` 函數。指定的模式應遵循 `preg_match` 所需的相同格式，並且也包括有效的分隔符。例如：`'email' => 'regex:/^.+@.+$/i'`。

> **警告**
> 當使用 `regex` / `not_regex` 模式時，可能需要使用數組指定規則而不是使用 `|` 分隔符，特別是如果正則表達式包含 `|` 字符。

<a name="rule-required"></a>
#### required

驗證的字段必須出現在輸入數據中且不為空。如果一個字段符合以下任一標準，則它被認為是“空”的：

<div class="content-list" markdown="1">

-   值為 `null`。
-   值為空字符串。
-   值為一個空數組或一個空的 `Countable` 對象。
-   值為上傳文件且路徑為空。

</div>



<a name="rule-required-if"></a>
#### required_if:_anotherfield_,_value_,...

如果 anotherfield 字段的值等於任何 value 值，則驗證的字段必須存在且不為空。

如果您想要構建更覆雜的 `required_if` 規則條件，可以使用 `Rule::requiredIf` 方法。該方法接受一個布爾值或閉包。當傳遞一個閉包時，閉包應返回 `true` 或 `false` 來指示是否需要驗證的字段：

    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($request->all(), [
        'role_id' => Rule::requiredIf($request->user()->is_admin),
    ]);

    Validator::make($request->all(), [
        'role_id' => Rule::requiredIf(fn () => $request->user()->is_admin),
    ]);

<a name="rule-required-unless"></a>
#### required_unless:_anotherfield_,_value_,...

如果 *anotherfield* 字段的值不等於任何 *value* 值，則驗證的字段必須存在且不為空。這也意味著，除非 *anotherfield* 字段等於任何 *value* 值，否則必須在請求數據中包含 *anotherfield* 字段。如果 *value* 的值為 `null` （`required_unless:name,null`），則必須驗證該字段，除非比較字段是 `null` 或比較字段不存在於請求數據中。

<a name="rule-required-with"></a>
#### required_with:_foo_,_bar_,...

僅當任何其他指定字段存在且不為空時，才需要驗證字段存在且不為空。

<a name="rule-required-with-all"></a>
#### required_with_all:_foo_,_bar_,...

僅當所有其他指定字段存在且不為空時，才需要驗證字段存在且不為空。

<a name="rule-required-without"></a>


#### required_without:_foo_,_bar_,...

驗證的字段僅在任一其他指定字段為空或不存在時，必須存在且不為空。

<a name="rule-required-without-all"></a>
#### required_without_all:_foo_,_bar_,...

驗證的字段僅在所有其他指定字段為空或不存在時，必須存在且不為空。

<a name="rule-required-array-keys"></a>
#### required_array_keys:_foo_,_bar_,...

驗證的字段必須是一個數組，並且必須至少包含指定的鍵。

<a name="rule-same"></a>
#### same:_field_

給定的字段必須與驗證的字段匹配。

<a name="rule-size"></a>
#### size:_value_

驗證的字段必須具有與給定的_value相匹配的大小。對於字符串數據，value 對應於字符數。對於數字數據，value 對應於給定的整數值（該屬性還必須具有 numeric 或 integer 規則）。對於數組，size 對應於數組的 count。對於文件，size 對應於文件大小（以千字節為單位）。讓我們看一些例子：

    // Validate that a string is exactly 12 characters long...
    'title' => 'size:12';

    // Validate that a provided integer equals 10...
    'seats' => 'integer|size:10';

    // Validate that an array has exactly 5 elements...
    'tags' => 'array|size:5';

    // Validate that an uploaded file is exactly 512 kilobytes...
    'image' => 'file|size:512';

<a name="rule-starts-with"></a>
#### starts_with:_foo_,_bar_,...

驗證的字段必須以給定值之一開頭。

<a name="rule-string"></a>
#### string

驗證的字段必須是一個字符串。如果您希望允許字段也可以為 `null`，則應將 `nullable` 規則分配給該字段。



<a name="rule-timezone"></a>
#### 時區

驗證字段必須是一個有效的時區標識符，符合 `timezone_identifiers_list` PHP 函數的要求。

<a name="rule-unique"></a>
#### unique:_table_,_column_

驗證字段在給定的數據庫表中必須不存在。

**指定自定義表/列名:**

可以指定應使用哪個 Eloquent 模型來確定表名，而不是直接指定表名：

    'email' => 'unique:App\Models\User,email_address'

`column` 選項可用於指定字段對應的數據庫列。如果未指定 `column` 選項，則使用驗證字段的名稱。

    'email' => 'unique:users,email_address'

**指定自定義數據庫連接**

有時，您可能需要為 Validator 執行的數據庫查詢設置自定義連接。為此，可以在表名之前添加連接名稱：

    'email' => 'unique:connection.users,email_address'

**強制唯一規則忽略給定的 ID:**

有時，您可能希望在唯一驗證期間忽略給定的 ID。例如，考慮一個“更新個人資料”屏幕，其中包括用戶的姓名、電子郵件地址和位置。您可能希望驗證電子郵件地址是否唯一。但是，如果用戶僅更改了名稱字段而未更改電子郵件字段，則不希望因為用戶已經擁有相關電子郵件地址而拋出驗證錯誤。

要指示驗證器忽略用戶的 ID，我們將使用 `Rule` 類來流暢地定義規則。在此示例中，我們還將指定驗證規則作為數組，而不是使用 `|` 字符來分隔規則：

    use Illuminate\Database\Eloquent\Builder;
    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    Validator::make($data, [
        'email' => [
            'required',
            Rule::unique('users')->ignore($user->id),
        ],
    ]);

> **警告**
> 您不應將任何用戶控制的請求輸入傳遞到 `ignore` 方法中。相反，您應僅傳遞系統生成的唯一 ID，例如 Eloquent 模型實例的自增 ID 或 UUID。否則，您的應用程序將容易受到 SQL 注入攻擊。



不需要將模型鍵的值傳遞給 `ignore` 方法，您也可以傳遞整個模型實例。Laravel 將自動從模型中提取鍵：

    Rule::unique('users')->ignore($user)

如果您的表使用的是除 `id` 以外的主鍵列名，可以在調用 `ignore` 方法時指定列的名稱：

    Rule::unique('users')->ignore($user->id, 'user_id')

默認情況下，`unique` 規則將檢查與正在驗證的屬性名稱匹配的列的唯一性。但是，您可以將不同的列名稱作為第二個參數傳遞給 `unique` 方法：

    Rule::unique('users', 'email_address')->ignore($user->id)

**添加額外的查詢條件：**

您可以通過自定義查詢並使用 `where` 方法來指定其他查詢條件。例如，讓我們添加一個查詢條件，將查詢範圍限定為僅搜索具有 `account_id` 列值為 `1` 的記錄：

    'email' => Rule::unique('users')->where(fn (Builder $query) => $query->where('account_id', 1))

<a name="rule-uppercase"></a>
#### uppercase

驗證字段必須為大寫。

<a name="rule-url"></a>
#### url

驗證字段必須為有效的 URL。

<a name="rule-ulid"></a>
#### ulid

驗證字段必須為有效的[通用唯一詞典排序標識符](https://github.com/ulid/spec)（ULID）。

<a name="rule-uuid"></a>
#### uuid

驗證字段必須為有效的 RFC 4122（版本1、3、4或5）通用唯一標識符（UUID）。

<a name="conditionally-adding-rules"></a>
## 有條件添加規則

<a name="skipping-validation-when-fields-have-certain-values"></a>
#### 當字段具有特定值時跳過驗證



有時，您可能希望在給定字段具有特定值時不驗證另一個字段。您可以使用`exclude_if`驗證規則來實現這一點。在下面的示例中，如果`has_appointment`字段的值為`false`，則不會驗證`appointment_date`和`doctor_name`字段：

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($data, [
        'has_appointment' => 'required|boolean',
        'appointment_date' => 'exclude_if:has_appointment,false|required|date',
        'doctor_name' => 'exclude_if:has_appointment,false|required|string',
    ]);

或者，您可以使用`exclude_unless`規則，除非另一個字段具有給定值，否則不驗證給定字段：

    $validator = Validator::make($data, [
        'has_appointment' => 'required|boolean',
        'appointment_date' => 'exclude_unless:has_appointment,true|required|date',
        'doctor_name' => 'exclude_unless:has_appointment,true|required|string',
    ]);

<a name="validating-when-present"></a>
#### 僅在字段存在時驗證

在某些情況下，您可能希望僅在驗證數據中存在該字段時才對該字段運行驗證檢查。要快速實現此操作，請將`sometimes`規則添加到您的規則列表中：

    $v = Validator::make($data, [
        'email' => 'sometimes|required|email',
    ]);

在上面的示例中，如果`$data`數組中存在`email`字段，則僅對其進行驗證。

> **注意**
> 如果您嘗試驗證始終應存在但可能為空的字段，請查看[有關可選字段的說明](#a-note-on-optional-fields)。

<a name="complex-conditional-validation"></a>
#### 覆雜條件驗證

有時，您可能希望根據更覆雜的條件邏輯添加驗證規則。例如，您可能只希望在另一個字段的值大於100時要求給定字段。或者，只有在存在另一個字段時，兩個字段才需要具有給定值。添加這些驗證規則不必是痛苦的。首先，使用永不改變的靜態規則創建一個`Validator`實例：

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'games' => 'required|numeric',
    ]);



假設我們的 Web 應用是給遊戲收藏家使用的。如果一個遊戲收藏家在我們的應用上注冊，並且他們擁有超過 100 個遊戲，我們想要讓他們解釋為什麽擁有這麽多遊戲。例如，也許他們經營著一家遊戲轉售店，或者他們只是喜歡收集遊戲。為了有條件地添加這個要求，我們可以在 `Validator` 實例上使用 `sometimes` 方法。

    use Illuminate\Support\Fluent;

    $validator->sometimes('reason', 'required|max:500', function (Fluent $input) {
        return $input->games >= 100;
    });

傳遞給 `sometimes` 方法的第一個參數是我們有條件驗證的字段的名稱。第二個參數是我們想要添加的規則列表。如果傳遞作為第三個參數的閉包返回 `true`，這些規則將被添加。使用此方法可以輕松構建覆雜的條件驗證。您甚至可以同時為多個字段添加條件驗證：

    $validator->sometimes(['reason', 'cost'], 'required', function (Fluent $input) {
        return $input->games >= 100;
    });

> **注意**
> 傳遞給您的閉包的 `$input` 參數將是 `Illuminate\Support\Fluent` 的一個實例，可用於訪問您正在驗證的輸入和文件。

<a name="complex-conditional-array-validation"></a>
#### 覆雜條件數組驗證

有時，您可能想要基於同一嵌套數組中的另一個字段驗證一個字段，而您不知道其索引。在這種情況下，您可以允許您的閉包接收第二個參數，該參數將是正在驗證的當前個體數組項：

    $input = [
        'channels' => [
            [
                'type' => 'email',
                'address' => 'abigail@example.com',
            ],
            [
                'type' => 'url',
                'address' => 'https://example.com',
            ],
        ],
    ];

    $validator->sometimes('channels.*.address', 'email', function (Fluent $input, Fluent $item) {
        return $item->type === 'email';
    });

    $validator->sometimes('channels.*.address', 'url', function (Fluent $input, Fluent $item) {
        return $item->type !== 'email';
    });



像傳遞給閉包的 `$input` 參數一樣，當屬性數據是數組時，`$item` 參數是 `Illuminate\Support\Fluent` 的實例；否則，它是一個字符串。

<a name="validating-arrays"></a>
## 驗證數組

正如在 [`array` 驗證規則文檔](#rule-array) 中討論的那樣，`array` 規則接受允許的數組鍵列表。如果數組中存在任何額外的鍵，則驗證將失敗：

    use Illuminate\Support\Facades\Validator;

    $input = [
        'user' => [
            'name' => 'Taylor Otwell',
            'username' => 'taylorotwell',
            'admin' => true,
        ],
    ];

    Validator::make($input, [
        'user' => 'array:username,locale',
    ]);

通常情況下，您應該始終指定允許出現在數組中的鍵。否則，驗證器的 `validate` 和 `validated` 方法將返回所有經過驗證的數據，包括數組及其所有鍵，即使這些鍵沒有通過其他嵌套數組驗證規則進行驗證。

<a name="validating-nested-array-input"></a>
### 驗證嵌套數組輸入

驗證基於嵌套數組的表單輸入字段並不需要很痛苦。您可以使用 "點符號" 來驗證數組中的屬性。例如，如果傳入的 HTTP 請求包含一個 `photos[profile]` 字段，您可以像這樣驗證它：

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($request->all(), [
        'photos.profile' => 'required|image',
    ]);

您還可以驗證數組中的每個元素。例如，要驗證給定數組輸入字段中的每個電子郵件是否唯一，可以執行以下操作：

    $validator = Validator::make($request->all(), [
        'person.*.email' => 'email|unique:users',
        'person.*.first_name' => 'required_with:person.*.last_name',
    ]);



同樣，您可以在語言文件中指定[自定義驗證消息](#custom-messages-for-specific-attributes)時使用 `*` 字符，使得針對基於數組的字段使用單個驗證消息變得非常簡單：

    'custom' => [
        'person.*.email' => [
            'unique' => 'Each person must have a unique email address',
        ]
    ],

<a name="accessing-nested-array-data"></a>
#### 訪問嵌套數組數據

有時，當為屬性分配驗證規則時，您可能需要訪問給定嵌套數組元素的值。您可以使用 `Rule::forEach` 方法來實現此目的。`forEach` 方法接受一個閉包，在驗證數組屬性的每次叠代中調用該閉包，並接收屬性的值和顯式的完全展開的屬性名稱。閉包應該返回要分配給數組元素的規則數組：

    use App\Rules\HasPermission;
    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rule;

    $validator = Validator::make($request->all(), [
        'companies.*.id' => Rule::forEach(function (string|null $value, string $attribute) {
            return [
                Rule::exists(Company::class, 'id'),
                new HasPermission('manage-company', $value),
            ];
        }),
    ]);

<a name="error-message-indexes-and-positions"></a>
### 錯誤消息索引和位置

在驗證數組時，您可能希望在應用程序顯示的錯誤消息中引用失敗驗證的特定項的索引或位置。為了實現這一點，您可以在[自定義驗證消息](#manual-customizing-the-error-messages)中包含 `:index`（從 `0` 開始）和 `:position`（從 `1` 開始）占位符：

    use Illuminate\Support\Facades\Validator;

    $input = [
        'photos' => [
            [
                'name' => 'BeachVacation.jpg',
                'description' => '我的海灘假期照片！',
            ],
            [
                'name' => 'GrandCanyon.jpg',
                'description' => '',
            ],
        ],
    ];

    Validator::validate($input, [
        'photos.*.description' => 'required',
    ], [
        'photos.*.description.required' => '請描述第 :position 張照片。',
    ]);



上述示例將驗證失敗，並且用戶會看到以下錯誤：“請描述第 2 張照片。”

<a name="validating-files"></a>
## 驗證文件

Laravel提供了多種上傳文件的驗證規則，如`mimes`、`image`、`min`和`max`。雖然你可以在驗證文件時單獨指定這些規則，但Laravel還是提供了一個流暢的文件驗證規則生成器，你可能會覺得更方便：

```
    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rules\File;

    Validator::validate($input, [
        'attachment' => [
            'required',
            File::types(['mp3', 'wav'])
                ->min(1024)
                ->max(12 * 1024),
        ],
    ]);
```

如果你的程序允許用戶上傳圖片，那麽可以使用`File` 規則的 `image` 構造方法來指定上傳的文件應該是圖片。另外， `dimensions` 規則可用於限制圖片的尺寸：

```
    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rules\File;

    Validator::validate($input, [
        'photo' => [
            'required',
            File::image()
                ->min(1024)
                ->max(12 * 1024)
                ->dimensions(Rule::dimensions()->maxWidth(1000)->maxHeight(500)),
        ],
    ]);
```

> **技巧**
> 更多驗證圖片尺寸的信息，請參見[尺寸規則文檔](#rule-dimensions)。

<a name="validating-files-file-types"></a>
#### 文件類型

盡管在調用 `types` 方法時只需要指定擴展名，但該方法實際上是通過讀取文件的內容並猜測其MIME類型來驗證文件的MIME類型的。MIME類型及其相應擴展的完整列表可以在以下鏈接中找到：

[https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types](https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types)



<a name="validating-passwords"></a>
## 驗證密碼

為確保密碼具有足夠的覆雜性，你可以使用 Laravel 的 `password` 規則對象：

```
    use Illuminate\Support\Facades\Validator;
    use Illuminate\Validation\Rules\Password;

    $validator = Validator::make($request->all(), [
        'password' => ['required', 'confirmed', Password::min(8)],
    ]);
```

`Password` 規則對象允許你輕松自定義應用程序的密碼覆雜性要求，例如指定密碼至少需要一個字母、數字、符號或混合大小寫的字符：

```
    // 至少需要 8 個字符...
    Password::min(8)

    // 至少需要一個字母...
    Password::min(8)->letters()

    // 至少需要一個大寫字母和一個小寫字母...
    Password::min(8)->mixedCase()

    // 至少需要一個數字...
    Password::min(8)->numbers()

    // 至少需要一個符號...
    Password::min(8)->symbols()
```

此外，你可以使用 `uncompromised` 方法確保密碼沒有在公共密碼數據泄露事件中被泄露：

```
    Password::min(8)->uncompromised()
```

在內部，`Password` 規則對象使用 [k-Anonymity](https://en.wikipedia.org/wiki/K-anonymity) 模型來確定密碼是否已通過 [haveibeenpwned.com](https://haveibeenpwned.com)  服務而不犧牲用戶的隱私或安全。

默認情況下，如果密碼在數據泄露中至少出現一次，則會被視為已泄露。你可以使用 `uncompromised` 方法的第一個參數自定義此閾值

```
    // Ensure the password appears less than 3 times in the same data leak...
    Password::min(8)->uncompromised(3);
```

當然，你可以將上面示例中的所有方法鏈接起來：

```
    Password::min(8)
        ->letters()
        ->mixedCase()
        ->numbers()
        ->symbols()
        ->uncompromised()
```


<a name="defining-default-password-rules"></a>
#### 定義默認密碼規則

你可能會發現在應用程序的單個位置指定密碼的默認驗證規則很方便。你可以使用接受閉包的 `Password::defaults` 方法輕松完成此操作。給 `defaults` 方法的閉包應該返回密碼規則的默認配置。通常，應該在應用程序服務提供者之一的 `boot` 方法中調用 `defaults` 規則：

```php
use Illuminate\Validation\Rules\Password;

/**
 * 引導任何應用程序服務
 */
public function boot(): void
{
    Password::defaults(function () {
        $rule = Password::min(8);

        return $this->app->isProduction()
                    ? $rule->mixedCase()->uncompromised()
                    : $rule;
    });
}
```

然後，當你想將默認規則應用於正在驗證的特定密碼時，你可以調用不帶參數的 `defaults` 方法：

    'password' => ['required', Password::defaults()],

有時，你可能希望將其他驗證規則附加到默認密碼驗證規則。 你可以使用 `rules` 方法來完成此操作：

    use App\Rules\ZxcvbnRule;

    Password::defaults(function () {
        $rule = Password::min(8)->rules([new ZxcvbnRule]);

        // ...
    });

<a name="custom-validation-rules"></a>
## 自定義驗證規則

<a name="using-rule-objects"></a>
### 使用規則對象

Laravel 提供了各種有用的驗證規則；但是，你可能希望指定一些你自己的。 注冊自定義驗證規則的一種方法是使用規則對象。 要生成新的規則對象，你可以使用 `make:rule` Artisan 命令。 讓我們使用這個命令生成一個規則來驗證字符串是否為大寫。 Laravel 會將新規則放在 `app/Rules` 目錄中。 如果這個目錄不存在，Laravel 會在你執行 Artisan 命令創建規則時創建它：

```shell
php artisan make:rule Uppercase
```



一旦規則被創建，我們就可以定義其行為。一個規則對象包含一個單一的方法：`validate`。該方法接收屬性名、其值和一個回調函數，如果驗證失敗應該調用該回調函數並傳入驗證錯誤消息：

    <?php

    namespace App\Rules;

    use Closure;
    use Illuminate\Contracts\Validation\ValidationRule;

    class Uppercase implements ValidationRule
    {
        /**
         * Run the validation rule.
         */
        public function validate(string $attribute, mixed $value, Closure $fail): void
        {
            if (strtoupper($value) !== $value) {
                $fail('The :attribute must be uppercase.');
            }
        }
    }

一旦定義了規則，您可以通過將規則對象的實例與其他驗證規則一起傳遞來將其附加到驗證器：

    use App\Rules\Uppercase;

    $request->validate([
        'name' => ['required', 'string', new Uppercase],
    ]);

#### 驗證消息

您可以不提供 `$fail` 閉包的字面錯誤消息，而是提供一個[翻譯字符串鍵](https://chat.openai.com/docs/laravel/10.x/localization)，並指示 Laravel 翻譯錯誤消息：

    if (strtoupper($value) !== $value) {
        $fail('validation.uppercase')->translate();
    }

如有必要，您可以通過第一個和第二個參數分別提供占位符替換和首選語言來調用 `translate` 方法：

    $fail('validation.location')->translate([
        'value' => $this->value,
    ], 'fr')

#### 訪問額外數據

如果您的自定義驗證規則類需要訪問正在驗證的所有其他數據，則規則類可以實現 `Illuminate\Contracts\Validation\DataAwareRule` 接口。此接口要求您的類定義一個 `setData` 方法。Laravel 會自動調用此方法（在驗證繼續之前）並傳入所有正在驗證的數據：

    <?php

    namespace App\Rules;

    use Illuminate\Contracts\Validation\DataAwareRule;
    use Illuminate\Contracts\Validation\ValidationRule;

    class Uppercase implements DataAwareRule, ValidationRule
    {
        /**
         * 正在驗證的所有數據。
         *
         * @var array<string, mixed>
         */
        protected $data = [];

        // ...

        /**
         * 設置正在驗證的數據。
         *
         * @param  array<string, mixed>  $data
         */
        public function setData(array $data): static
        {
            $this->data = $data;

            return $this;
        }
    }



或者，如果您的驗證規則需要訪問執行驗證的驗證器實例，則可以實現`ValidatorAwareRule`接口：

    <?php

    namespace App\Rules;

    use Illuminate\Contracts\Validation\ValidationRule;
    use Illuminate\Contracts\Validation\ValidatorAwareRule;
    use Illuminate\Validation\Validator;

    class Uppercase implements ValidationRule, ValidatorAwareRule
    {
        /**
         * 驗證器實例.
         *
         * @var \Illuminate\Validation\Validator
         */
        protected $validator;

        // ...

        /**
         * 設置當前驗證器.
         */
        public function setValidator(Validator $validator): static
        {
            $this->validator = $validator;

            return $this;
        }
    }

<a name="using-closures"></a>
### 使用閉包函數

如果您只需要在應用程序中一次使用自定義規則的功能，可以使用閉包函數而不是規則對象。閉包函數接收屬性名稱、屬性值和 $fail 回調函數，如果驗證失敗，應該調用該函數：

    use Illuminate\Support\Facades\Validator;

    $validator = Validator::make($request->all(), [
        'title' => [
            'required',
            'max:255',
            function (string $attribute, mixed $value, Closure $fail) {
                if ($value === 'foo') {
                    $fail("The {$attribute} is invalid.");
                }
            },
        ],
    ]);

<a name="implicit-rules"></a>
### 隱式規則

默認情況下，當要驗證的屬性不存在或包含空字符串時，正常的驗證規則，包括自定義規則，都不會執行。例如，[`unique`](#rule-unique) 規則不會針對空字符串運行：

    use Illuminate\Support\Facades\Validator;

    $rules = ['name' => 'unique:users,name'];

    $input = ['name' => ''];

    Validator::make($input, $rules)->passes(); // true

為了使自定義規則在屬性為空時也運行，規則必須暗示該屬性是必需的。您可以使用 make:rule Artisan 命令的 --implicit 選項快速生成新的隱式規則對象：

```shell
php artisan make:rule Uppercase --implicit
```

> **警告 **
> 隱式規則僅 暗示 該屬性是必需的。實際上，缺少或空屬性是否無效取決於您。
