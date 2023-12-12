
# HTTP 請求

-   [介紹](#introduction)
-   [與請求交互](#interacting-with-the-request)
    -   [訪問請求](#accessing-the-request)
    -   [請求路徑、主機和方法](#request-path-and-method)
    -   [請求頭](#request-headers)
    -   [請求 IP址](#request-ip-address)
    -   [內容協商](#content-negotiation)
    -   [PSR-7 請求](#psr7-requests)
-   [輸入](#input)
    -   [檢索輸入](#retrieving-input)
    -   [確定輸入是否存在](#determining-if-input-is-present)
    -   [合並額外的輸入](#merging-additional-input)
    -   [舊輸入](#old-input)
    -   [Cookies](#cookies)
    -   [輸入修剪和規範化](#input-trimming-and-normalization)
-   [文件](#files)
    -   [檢索上傳的文件](#retrieving-uploaded-files)
    -   [存儲上傳的文件](#storing-uploaded-files)
-   [配置可信代理](#configuring-trusted-proxies)
-   [配置可信主機](#configuring-trusted-hosts)

<a name="introduction"></a>

## 介紹

Laravel 的 `Illuminate\Http\Request` 類提供了一種面向對象的方式來與當前由應用程序處理的 HTTP 請求進行交互，並檢索提交請求的輸入內容、Cookie 和文件。

<a name="interacting-with-the-request"></a>

## 與請求交互

<a name="accessing-the-request"></a>

### 訪問請求

要通過依賴注入獲取當前的 HTTP 請求實例，您應該在路由閉包或控制器方法中導入 `Illuminate\Http\Request` 類。傳入的請求實例將由 Laravel  [服務容器](/docs/laravel/10.x/container) 自動注入：

```
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
        $name = $request->input('name');

        // 存儲用戶……

        return redirect('/users');
    }
}

```

如上所述，您也可以在路由閉包上導入 `Illuminate\Http\Request` 類。服務容器將在執行時自動將傳入請求注入閉包中：

```
use Illuminate\Http\Request;

Route::get('/', function (Request $request) {
    // ...
});
```

<a name="dependency-injection-route-parameters"></a>

#### 依賴注入和路由參數

如果您的控制器方法還需要從路由參數中獲取輸入，則應該在其他依賴項之後列出路由參數。例如，如果您的路由定義如下：

```
use App\Http\Controllers\UserController;

Route::put('/user/{id}', [UserController::class, 'update']);

```

您仍然可以在控制器方法中使用類型提示的 `Illuminate\Http\Request` 並通過以下方式訪問您的 `id` 路由參數來定義您的控制器方法：

```
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Update the specified user.
     */
    public function update(Request $request, string $id): RedirectResponse
    {
        // 更新用戶...

        return redirect('/users');
    }
}

```

<a name="request-path-and-method"></a>

### 請求路徑、主機和方法

`Illuminate\Http\Request` 實例提供各種方法來檢查傳入的 HTTP 請求，並擴展了 `Symfony\Component\HttpFoundation\Request` 類。下面我們將討論一些最重要的方法。

<a name="retrieving-the-request-path"></a>

#### 獲取請求路徑

`path` 方法返回請求的路徑信息。因此，如果傳入的請求針對 `http://example.com/foo/bar`，則 `path` 方法將返回 `foo/bar`：

```
$uri = $request->path();

```

<a name="inspecting-the-request-path"></a>

#### 檢查請求路徑/路由信息

`is` 方法允許您驗證傳入請求路徑是否與給定的模式匹配。當使用此方法時，您可以使用 `*` 字符作為通配符：

```
if ($request->is('admin/*')) {
    // ...
}

```

使用 `routeIs` 方法，您可以確定傳入的請求是否與 [命名路由](/docs/laravel/10.x/routing#named-routes) 匹配：

```
if ($request->routeIs('admin.*')) {
    // ...
}
```

<a name="retrieving-the-request-url"></a>

#### 獲取請求 URL

要獲取傳入請求的完整 URL，您可以使用 `url` 或 `fullUrl` 方法。`url` 方法將返回不帶查詢字符串的 URL，而`fullUrl` 方法將包括查詢字符串：

```
$url = $request->url();

$urlWithQueryString = $request->fullUrl();

```

如果您想將查詢字符串數據附加到當前 URL，請調用 `fullUrlWithQuery` 方法。此方法將給定的查詢字符串變量數組與當前查詢字符串合並：

```
$request->fullUrlWithQuery(['type' => 'phone']);

```

<a name="retrieving-the-request-host"></a>

#### 獲取請求 Host

您可以通過 `host`、`httpHost` 和 `schemeAndHttpHost` 方法獲取傳入請求的 「host」：

```
$request->host();
$request->httpHost();
$request->schemeAndHttpHost();

```

<a name="retrieving-the-request-method"></a>

#### 獲取請求方法

`method` 方法將返回請求的 HTTP 動詞。您可以使用 `isMethod` 方法來驗證 HTTP 動詞是否與給定的字符串匹配：

```
$method = $request->method();

if ($request->isMethod('post')) {
    // ...
}

```

<a name="request-headers"></a>

### 請求頭

您可以使用`header` 方法從 `Illuminate\Http\Request` 實例中檢索請求標頭。如果請求中沒有該標頭，則返回 `null`。但是，`header` 方法接受兩個可選參數，如果該標頭在請求中不存在，則返回第二個參數：

```
$value = $request->header('X-Header-Name');

$value = $request->header('X-Header-Name', 'default');

```

`hasHeader` 方法可用於確定請求是否包含給定的標頭：

```
if ($request->hasHeader('X-Header-Name')) {
    // ...
}

```

為了方便起見，`bearerToken` 方法可用於從 `Authorization` 標頭檢索授權標記。如果不存在此類標頭，將返回一個空字符串：

```
$token = $request->bearerToken();
```

<a name="request-ip-address"></a>

### 請求 IP 地址

`ip` 方法可用於檢索向您的應用程序發出請求的客戶端的 IP 地址：

```
$ipAddress = $request->ip();

```

<a name="content-negotiation"></a>

### 內容協商

Laravel 提供了幾種方法，通過 `Accept` 標頭檢查傳入請求的請求內容類型。首先，`getAcceptableContentTypes` 方法將返回包含請求接受的所有內容類型的數組：

```
$contentTypes = $request->getAcceptableContentTypes();

```

`accepts` 方法接受一個內容類型數組，並在請求接受任何內容類型時返回 `true`。否則，將返回 `false`：

```
if ($request->accepts(['text/html', 'application/json'])) {
    // ...
}

```

您可以使用 `prefers` 方法確定給定內容類型數組中的哪種內容類型由請求最具優勢。如果請求未接受任何提供的內容類型，則返回 `null`：

```
$preferred = $request->prefers(['text/html', 'application/json']);

```

由於許多應用程序僅提供 HTML 或 JSON，因此您可以使用 `expectsJson` 方法快速確定傳入請求是否期望獲得 JSON 響應：

```
if ($request->expectsJson()) {
    // ...
}

```

<a name="psr7-requests"></a>

### PSR-7 請求

[PSR-7 標準](https://www.php-fig.org/psr/psr-7/) 指定了 HTTP 消息的接口，包括請求和響應。如果您想要獲取 PSR-7 請求的實例而不是 Laravel 請求，您首先需要安裝一些庫。Laravel 使用 *Symfony HTTP Message Bridge* 組件將典型的 Laravel 請求和響應轉換為 PSR-7 兼容的實現：

```shell
composer require symfony/psr-http-message-bridge
composer require nyholm/psr7
```

安裝這些庫之後，您可以通過在路由閉包或控制器方法上的請求接口進行類型提示來獲取 PSR-7 請求：

```
use Psr\Http\Message\ServerRequestInterface;

Route::get('/', function (ServerRequestInterface $request) {
    // ...
});

```

> **注意**
> 如果您從路由或控制器返回 PSR-7 響應實例，它將自動轉換回 Laravel 響應實例，並由框架顯示。

<a name="input"></a>

## 輸入

<a name="retrieving-input"></a>

### 檢索輸入

<a name="retrieving-all-input-data"></a>

#### 檢索所有輸入數據

您可以使用 `all` 方法將所有傳入請求的輸入數據作為 `array` 檢索。無論傳入請求是否來自 HTML 表單或 XHR 請求，都可以使用此方法：

```
$input = $request->all();

```

使用 `collect` 方法，您可以將所有傳入請求的輸入數據作為 [集合](/docs/laravel/10.x/collections) 檢索：

```
$input = $request->collect();

```

`collect` 方法還允許您將傳入請求的子集作為集合檢索：

```
$request->collect('users')->each(function (string $user) {
    // ...
});

```

<a name="retrieving-an-input-value"></a>

#### 檢索輸入值

使用幾個簡單的方法，無論請求使用了哪種 HTTP 動詞，都可以從您的 `Illuminate\Http\Request` 實例訪問所有用戶輸入。`input` 方法可用於檢索用戶輸入：

```
$name = $request->input('name');

```

您可以將默認值作為第二個參數傳遞給 `input` 方法。如果請求中不存在所請求的輸入值，則返回此值：

```
$name = $request->input('name', 'Sally');
```

處理包含數組輸入的表單時，請使用「.」符號訪問數組：

```
$name = $request->input('products.0.name');

$names = $request->input('products.*.name');

```

您可以調用不帶任何參數的 `input` 方法，以將所有輸入值作為關聯數組檢索出來：

```
$input = $request->input();

```

<a name="retrieving-input-from-the-query-string"></a>

#### 從查詢字符串檢索輸入

雖然 `input` 方法從整個請求消息載荷（包括查詢字符串）檢索值，但 `query` 方法僅從查詢字符串檢索值：

```
$name = $request->query('name');

```

如果請求的查詢字符串值數據不存在，則將返回此方法的第二個參數：

```
$name = $request->query('name', 'Helen');

```

您可以調用不帶任何參數的 `query` 方法，以將所有查詢字符串值作為關聯數組檢索出來：

```
$query = $request->query();

```

<a name="retrieving-json-input-values"></a>

#### 檢索 JSON 輸入值

當向您的應用程序發送 JSON 請求時，只要請求的 `Content-Type` 標頭正確設置為 `application/json`，您就可以通過 `input` 方法訪問 JSON 數據。您甚至可以使用「.」語法來檢索嵌套在 JSON 數組/對象中的值：

```
$name = $request->input('user.name');

```

<a name="retrieving-stringable-input-values"></a>

#### 檢索可字符串化的輸入值

您可以使用 `string` 方法將請求的輸入數據檢索為 [`Illuminate\Support\Stringable`](/docs/laravel/10.x/helpers#fluent-strings) 的實例，而不是將其作為基本 `string` 檢索：

```
$name = $request->string('name')->trim();

```

<a name="retrieving-boolean-input-values"></a>

#### 檢索布爾值輸入

處理類似覆選框的 HTML 元素時，您的應用程序可能會接收到實際上是字符串的「true」。例如，「true」或「on」。為了方便起見，您可以使用 `boolean` 方法將這些值作為布爾值檢索。`boolean` 方法對於 1，「1」，true，「true」，「on」和「yes」，返回 `true`。所有其他值將返回 `false`：

```
$archived = $request->boolean('archived');

```

<a name="retrieving-date-input-values"></a>

#### 檢索日期輸入值

為了方便起見，包含日期 / 時間的輸入值可以使用 `date` 方法檢索為 Carbon 實例。如果請求中不包含給定名稱的輸入值，則返回 `null`：

```
$birthday = $request->date('birthday');

```

`date` 方法可接受的第二個和第三個參數可用於分別指定日期的格式和時區：

```
$elapsed = $request->date('elapsed', '!H:i', 'Europe/Madrid');

```

如果輸入值存在但格式無效，則會拋出一個 `InvalidArgumentException` 異常；因此，在調用 `date` 方法之前建議對輸入進行驗證。

<a name="retrieving-enum-input-values"></a>

#### 檢索枚舉輸入值

還可以從請求中檢索對應於 [PHP 枚舉](https://www.php.net/manual/en/language.types.enumerations.php) 的輸入值。如果請求中不包含給定名稱的輸入值或枚舉沒有與輸入值匹配的備份值，則返回 `null`。`enum` 方法接受輸入值的名稱和枚舉類作為其第一個和第二個參數：

```
use App\Enums\Status;

$status = $request->enum('status', Status::class);
```

<a name="retrieving-input-via-dynamic-properties"></a>

#### 通過動態屬性檢索輸入

您也可以使用 `Illuminate\Http\Request` 實例上的動態屬性訪問用戶輸入。例如，如果您的應用程序的表單之一包含一個 `name` 字段，則可以像這樣訪問該字段的值：

```php
$name = $request->name;

```

使用動態屬性時，Laravel 首先會在請求負載中查找參數的值，如果不存在，則會在匹配路由的參數中搜索該字段。

<a name="retrieving-a-portion-of-the-input-data"></a>

#### 檢索輸入數據的一部分

如果您需要檢索輸入數據的子集，則可以使用 `only` 和 `except` 方法。這兩個方法都接受一個單一的 `array` 或動態參數列表：

```php
$input = $request->only(['username', 'password']);

$input = $request->only('username', 'password');

$input = $request->except(['credit_card']);

$input = $request->except('credit_card');

```

> **警告**
> `only` 方法返回您請求的所有鍵 / 值對；但是，它不會返回請求中不存在的鍵 / 值對。

<a name="determining-if-input-is-present"></a>

### 判斷輸入是否存在

您可以使用 `has` 方法來確定請求中是否存在某個值。如果請求中存在該值則 `has` 方法返回 `true`：

```
if ($request->has('name')) {
    // ...
}

```

當給定一個數組時，`has` 方法將確定所有指定的值是否都存在：

```
if ($request->has(['name', 'email'])) {
    // ...
}

```

`whenHas` 方法將在請求中存在一個值時執行給定的閉包：

```
$request->whenHas('name', function (string $input) {
    // ...
});
```

可以通過向 `whenHas` 方法傳遞第二個閉包來執行，在請求中沒有指定值的情況下：

```
$request->whenHas('name', function (string $input) {
    // "name" 值存在...
}, function () {
    // "name" 值不存在...
});

```

`hasAny` 方法返回 `true`，如果任一指定的值存在，則它返回 `true`：

```
if ($request->hasAny(['name', 'email'])) {
    // ...
}

```

如果您想要確定請求中是否存在一個值且不是一個空字符串，則可以使用 `filled` 方法：

```
if ($request->filled('name')) {
    // ...
}

```

`whenFilled` 方法將在請求中存在一個值且不是空字符串時執行給定的閉包：

```
$request->whenFilled('name', function (string $input) {
    // ...
});

```

可以通過向 `whenFilled` 方法傳遞第二個閉包來執行，在請求中沒有指定值的情況下：

```
$request->whenFilled('name', function (string $input) {
    // "name" 值已填寫...
}, function () {
    // "name" 值未填寫...
});

```

要確定給定的鍵是否不存在於請求中，可以使用 `missing` 和 `whenMissing` 方法：

```
if ($request->missing('name')) {
    // ...
}

$request->whenMissing('name', function (array $input) {
    // "name" 值缺失...
}, function () {
    // "name" 值存在...
});

```

<a name="merging-additional-input"></a>

### 合並其他輸入

有時，您可能需要手動將其他輸入合並到請求的現有輸入數據中。為此，可以使用 `merge` 方法。如果給定的輸入鍵已經存在於請求中，它將被提供給 `merge` 方法的數據所覆蓋：

```
$request->merge(['votes' => 0]);
```

如果請求的輸入數據中不存在相應的鍵，則可以使用 `mergeIfMissing` 方法將輸入合並到請求中：

```
$request->mergeIfMissing(['votes' => 0]);

```

<a name="old-input"></a>

### 舊輸入

Laravel 允許你在兩次請求之間保留數據。這個特性在檢測到驗證錯誤後重新填充表單時特別有用。但是，如果您使用 Laravel 的包含的 [表單驗證](/docs/laravel/10.x/validation)，不需要自己手動調用這些方法，因為 Laravel 的一些內置驗證功能將自動調用它們。

<a name="flashing-input-to-the-session"></a>

#### 閃存輸入到 Session

在 `Illuminate\Http\Request` 類上的 `flash` 方法將當前輸入閃存到 [session](/docs/laravel/10.x/session)，以便在下一次用戶請求應用程序時使用：

```
$request->flash();

```

您還可以使用 `flashOnly` 和 `flashExcept` 方法閃存一部分請求數據到  Session。這些方法對於將敏感信息（如密碼）排除在 Session 外的情況下非常有用：

```
$request->flashOnly(['username', 'email']);

$request->flashExcept('password');

```

<a name="flashing-input-then-redirecting"></a>

#### 閃存輸入後重定向

由於您通常希望閃存輸入到 Session，然後重定向到以前的頁面，因此您可以使用 `withInput` 方法輕松地將輸入閃存到重定向中：

```
return redirect('form')->withInput();

return redirect()->route('user.create')->withInput();

return redirect('form')->withInput(
    $request->except('password')
);

```

<a name="retrieving-old-input"></a>

#### 檢索舊輸入值

若要獲取上一次請求所保存的舊輸入數據，可以在 `Illuminate\Http\Request` 的實例上調用 `old` 方法。`old` 方法會從 [session](/docs/laravel/10.x/session) 中檢索先前閃存的輸入數據：

```
$username = $request->old('username');

```

此外，Laravel 還提供了一個全局輔助函數 `old`。如果您在 [Blade 模板](/docs/laravel/10.x/blade) 中顯示舊的輸入，則更方便使用 `old` 輔助函數重新填充表單。如果給定字段沒有舊輸入，則會返回 `null`：

```
<input type="text" name="username" value="{{ old('username') }}">

```

<a name="cookies"></a>

### Cookies

<a name="retrieving-cookies-from-requests"></a>

#### 檢索請求中的 Cookies

Laravel 框架創建的所有 cookies 都經過加密並簽名，這意味著如果客戶端更改了 cookie 值，則這些 cookie 將被視為無效。要從請求中檢索 cookie 值，請在 `Illuminate\Http\Request` 實例上使用 `cookie` 方法：

```
$value = $request->cookie('name');

```

<a name="input-trimming-and-normalization"></a>

## 輸入過濾和規範化

默認情況下，Laravel 在應用程序的全局中間件棧中包含 `App\Http\Middleware\TrimStrings` 和 `Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull` 中間件。這些中間件在 `App\Http\Kernel` 類的全局中間件棧中列出。這些中間件將自動修剪請求中的所有字符串字段，並將任何空字符串字段轉換為 `null`。這使您不必在路由和控制器中擔心這些規範化問題。

#### 禁用輸入規範化

如果要禁用所有請求的該行為，可以從 `App\Http\Kernel` 類的 `$middleware` 屬性中刪除這兩個中間件，從而將它們從應用程序的中間件棧中刪除。

如果您想要禁用應用程序的一部分請求的字符串修剪和空字符串轉換，可以使用中間件提供的 `skipWhen` 方法。該方法接受一個閉包，該閉包應返回 `true` 或 `false`，以指示是否應跳過輸入規範化。通常情況下，需要在應用程序的 `AppServiceProvider` 的 `boot` 方法中調用 `skipWhen` 方法。

```php
use App\Http\Middleware\TrimStrings;
use Illuminate\Http\Request;
use Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    TrimStrings::skipWhen(function (Request $request) {
        return $request->is('admin/*');
    });

    ConvertEmptyStringsToNull::skipWhen(function (Request $request) {
        // ...
    });
}
```

<a name="files"></a>

## 文件

<a name="retrieving-uploaded-files"></a>

### 檢索上傳的文件

您可以使用 `file` 方法或動態屬性從 `Illuminate\Http\Request` 實例中檢索已上傳的文件。`file` 方法返回 `Illuminate\Http\UploadedFile` 類的實例，該類擴展了 PHP 的 `SplFileInfo` 類，並提供了各種用於與文件交互的方法：

```php
$file = $request->file('photo');

$file = $request->photo;

```

您可以使用 `hasFile` 方法檢查請求中是否存在文件：

```php
if ($request->hasFile('photo')) {
    // ...
}

```

<a name="validating-successful-uploads"></a>

#### 驗證成功上傳的文件

除了檢查文件是否存在之外，您還可以通過 `isValid` 方法驗證上傳文件時是否存在問題：

```php
if ($request->file('photo')->isValid()) {
    // ...
}

```

<a name="file-paths-extensions"></a>

#### 文件路徑和擴展名

`UploadedFile` 類還包含訪問文件的完全限定路徑及其擴展名的方法。`extension` 方法將嘗試基於其內容猜測文件的擴展名。此擴展名可能與客戶端提供的擴展名不同：

```php
$path = $request->photo->path();

$extension = $request->photo->extension();
```

<a name="other-file-methods"></a>

#### 其他文件方法

`UploadedFile` 實例有許多其他可用的方法。有關這些方法的更多信息，請查看該類的 [API文檔](https://github.com/symfony/symfony/blob/6.0/src/Symfony/Component/HttpFoundation/File/UploadedFile.php) 。

<a name="storing-uploaded-files"></a>

### 存儲上傳的文件

要存儲已上傳的文件，通常會使用您配置的一個[文件系統](/docs/laravel/10.x/filesystem) 。`UploadedFile` 類具有一個 `store` 方法，該方法將上傳的文件移動到您的磁盤中的一個位置，該位置可以是本地文件系統上的位置，也可以是像 Amazon S3 這樣的雲存儲位置。

`store` 方法接受存儲文件的路徑，該路徑相對於文件系統的配置根目錄。此路徑不應包含文件名，因為將自動生成唯一的 ID 作為文件名。

`store` 方法還接受一個可選的第二個參數，用於指定應用於存儲文件的磁盤的名稱。該方法將返回相對於磁盤根目錄的文件路徑：

```php
$path = $request->photo->store('images');

$path = $request->photo->store('images', 's3');

```

如果您不希望自動生成文件名，則可以使用 `storeAs` 方法，該方法接受路徑、文件名和磁盤名稱作為其參數：

```php
$path = $request->photo->storeAs('images', 'filename.jpg');

$path = $request->photo->storeAs('images', 'filename.jpg', 's3');

```

> **注意**
> 有關在 Laravel 中存儲文件的更多信息，請查看完整的 [文件存儲文檔](/docs/laravel/10.x/filesystem) 。

<a name="configuring-trusted-proxies"></a>

## 配置受信任的代理

在終止 TLS / SSL 證書的負載平衡器後面運行應用程序時，您可能會注意到，使用 `url` 幫助程序時，應用程序有時不會生成 HTTPS 鏈接。通常，這是因為正在從端口 `80` 上的負載平衡器轉發應用程序的流量，並且不知道它應該生成安全鏈接。

為了解決這個問題，您可以使用 `App\Http\Middleware\TrustProxies` 中間件，這個中間件已經包含在 Laravel 應用程序中，它允許您快速定制應用程序應信任的負載均衡器或代理。您信任的代理應該被列在此中間件的 `$proxies` 屬性上的數組中。除了配置受信任的代理之外，您還可以配置應該信任的代理 `$headers`：

```php
<?php

namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Illuminate\Http\Request;

class TrustProxies extends Middleware
{
    /**
     * 此應用程序的受信任代理。
     *
     * @var string|array
     */
    protected $proxies = [
        '192.168.1.1',
        '192.168.1.2',
    ];

    /**
     * 應用於檢測代理的標頭。
     *
     * @var int
     */
    protected $headers = Request::HEADER_X_FORWARDED_FOR | Request::HEADER_X_FORWARDED_HOST | Request::HEADER_X_FORWARDED_PORT | Request::HEADER_X_FORWARDED_PROTO;
}

```

> **注意**
> 如果您正在使用 AWS 彈性負載平衡，請將 `$headers` 值設置為 `Request::HEADER_X_FORWARDED_AWS_ELB`。有關可在 `$headers` 屬性中使用的常量的更多信息，請查看 Symfony 關於 [信任代理](https://symfony.com/doc/current/deployment/proxies.html) 的文檔。

<a name="trusting-all-proxies"></a>

#### 信任所有代理

如果您使用的是 Amazon AWS 或其他「雲」負載均衡器提供商，則可能不知道實際負載均衡器的 IP 地址。在這種情況下，您可以使用 `*` 來信任所有代理：

```
/**
 * 應用所信任的代理。
 *
 * @var string|array
 */
protected $proxies = '*';

```

<a name="configuring-trusted-hosts"></a>

## 配置可信任的 Host

默認情況下，Laravel 將響應它接收到的所有請求，而不管 HTTP 請求的 `Host` 標頭的內容是什麽。此外，在 web 請求期間生成應用程序的絕對 URL 時，將使用 `Host` 頭的值。

通常情況下，您應該配置您的 Web 服務器（如 Nginx 或 Apache）僅向匹配給定主機名的應用程序發送請求。然而，如果您沒有直接自定義您的 Web 服務器的能力，需要指示 Laravel 僅響應特定主機名的請求，您可以為您的應用程序啟用 `App\Http\Middleware\TrustHosts` 中間件。

`TrustHosts` 中間件已經包含在應用程序的 `$middleware` 堆棧中；但是，您應該將其取消注釋以使其生效。在此中間件的 `hosts` 方法中，您可以指定您的應用程序應該響應的主機名。具有其他 `Host` 值標頭的傳入請求將被拒絕：

```
/**
 * 獲取應被信任的主機模式。
 *
 * @return array<int, string>
 */
public function hosts(): array
{
    return [
        'laravel.test',
        $this->allSubdomainsOfApplicationUrl(),
    ];
}

```

`allSubdomainsOfApplicationUrl` 幫助程序方法將返回與您的應用程序 `app.url` 配置值的所有子域相匹配的正則表達式。在構建利用通配符子域的應用程序時，這個幫助程序提供了一種方便的方法來允許所有應用程序的子域。
