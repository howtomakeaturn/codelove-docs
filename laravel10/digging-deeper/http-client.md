# HTTP Client

- [簡介](#introduction)
- [創建請求](#making-requests)
    - [請求數據](#request-data)
    - [請求頭](#headers)
    - [認證](#authentication)
    - [超時](#timeout)
    - [重試](#retries)
    - [錯誤處理](#error-handling)
    - [Guzzle 中間件](#guzzle-middleware)
    - [Guzzle 選項](#guzzle-options)
- [並發請求](#concurrent-requests)
- [宏](#macros)
- [測試](#testing)
    - [模擬響應](#faking-responses)
    - [注入請求](#inspecting-requests)
    - [防止意外請求](#preventing-stray-requests)
- [事件](#events)

<a name="introduction"></a>
## 簡介

Laravel 為 [Guzzle HTTP 客戶端](http://docs.guzzlephp.org/en/stable/) 提供了一套語義化且輕量的 API，讓你可用快速地使用 HTTP 請求與其他 Web 應用進行通信。該 API 專注於其在常見用例中的快速實現以及良好的開發者體驗。

在開始之前，你需要確保你的項目已經安裝了 Guzzle 包作為依賴項。默認情況下，Laravel 已經包含了 Guzzle 包。但如果你此前手動移除了它，你也可以通過 Composer 重新安裝它：

```shell
composer require guzzlehttp/guzzle
```

<a name="making-requests"></a>
## 創建請求

你可以使用 `Http` Facade 提供的 `head`, `get`, `post`, `put`, `patch`，以及 `delete` 方法來創建請求。首先，讓我們先看一下如何發出一個基礎的 GET 請求：

    use Illuminate\Support\Facades\Http;

    $response = Http::get('http://example.com');

`get` 方法返回一個 `Illuminate\Http\Client\Response` 的實例，該實例提供了大量的方法來檢查請求的響應：

    $response->body() : string;
    $response->json($key = null, $default = null) : array|mixed;
    $response->object() : object;
    $response->collect($key = null) : Illuminate\Support\Collection;
    $response->status() : int;
    $response->successful() : bool;
    $response->redirect(): bool;
    $response->failed() : bool;
    $response->clientError() : bool;
    $response->header($header) : string;
    $response->headers() : array;

`Illuminate\Http\Client\Response` 對象同樣實現了 PHP 的 `ArrayAccess` 接口，這代表著你可以直接訪問響應的 JSON 數據：

    return Http::get('http://example.com/users/1')['name'];

除了上面列出的響應方法之外，還可以使用以下方法來確定響應是否具有相應的狀態碼：

    $response->ok() : bool;                  // 200 OK
    $response->created() : bool;             // 201 Created
    $response->accepted() : bool;            // 202 Accepted
    $response->noContent() : bool;           // 204 No Content
    $response->movedPermanently() : bool;    // 301 Moved Permanently
    $response->found() : bool;               // 302 Found
    $response->badRequest() : bool;          // 400 Bad Request
    $response->unauthorized() : bool;        // 401 Unauthorized
    $response->paymentRequired() : bool;     // 402 Payment Required
    $response->forbidden() : bool;           // 403 Forbidden
    $response->notFound() : bool;            // 404 Not Found
    $response->requestTimeout() : bool;      // 408 Request Timeout
    $response->conflict() : bool;            // 409 Conflict
    $response->unprocessableEntity() : bool; // 422 Unprocessable Entity
    $response->tooManyRequests() : bool;     // 429 Too Many Requests
    $response->serverError() : bool;         // 500 Internal Server Error

<a name="uri-templates"></a>
#### URI 模版

HTTP客戶端還允許你使用 [URI 模板規範](https://www.rfc-editor.org/rfc/rfc6570) 構造請求URL. 要定義URI查詢參數，你可以使用 `withUrlParameters` 方法：

    Http::withUrlParameters([
        'endpoint' => 'https://laravel.com',
        'page' => 'docs',
        'version' => '9.x',
        'topic' => 'validation',
    ])->get('{+endpoint}/{page}/{version}/{topic}');

<a name="dumping-requests"></a>
#### 打印請求信息

如果要在發送請求之前打印輸出請求信息並且結束腳本運行，你應該在創建請求前調用 `dd` 方法：

    return Http::dd()->get('http://example.com');

<a name="request-data"></a>
### 請求數據

大多數情況下，`POST`、 `PUT` 和 `PATCH` 攜帶著額外的請求數據是相當常見的。所以，這些方法的第二個參數接受一個包含著請求數據的數組。默認情況下，這些數據會使用 `application/json` 類型隨請求發送：

    use Illuminate\Support\Facades\Http;

    $response = Http::post('http://example.com/users', [
        'name' => 'Steve',
        'role' => 'Network Administrator',
    ]);

<a name="get-request-query-parameters"></a>
#### GET 請求查詢參數

在創建 `GET` 請求時，你可以通過直接向 URL 添加查詢字符串或是將鍵值對作為第二個參數傳遞給 `get` 方法：

    $response = Http::get('http://example.com/users', [
        'name' => 'Taylor',
        'page' => 1,
    ]);

<a name="sending-form-url-encoded-requests"></a>
#### 發送 URL 編碼請求

如果你希望使用 `application/x-www-form-urlencoded` 作為請求的數據類型，你應該在創建請求前調用 `asForm` 方法：

    $response = Http::asForm()->post('http://example.com/users', [
        'name' => 'Sara',
        'role' => 'Privacy Consultant',
    ]);

<a name="sending-a-raw-request-body"></a>
#### 發送原始數據（Raw）請求

如果你想使用一個原始請求體發送請求，你可以在創建請求前調用 `withBody` 方法。你還可以將數據類型作為第二個參數傳遞給 `withBody` 方法：

    $response = Http::withBody(
        base64_encode($photo), 'image/jpeg'
    )->post('http://example.com/photo');

<a name="multi-part-requests"></a>
#### Multi-Part 請求

如果你希望將文件作為 Multipart 請求發送，你應該在創建請求前調用 `attach` 方法。該方法接受文件的名字（相當於 HTML Input 的 name 屬性）以及它對應的內容。你也可以在第三個參數傳入自定義的文件名稱，這不是必須的。如果有需要，你也可以通過第三個參數來指定文件的文件名：

    $response = Http::attach(
        'attachment', file_get_contents('photo.jpg'), 'photo.jpg'
    )->post('http://example.com/attachments');

除了傳遞文件的原始內容，你也可以傳遞 Stream 流數據：

    $photo = fopen('photo.jpg', 'r');

    $response = Http::attach(
        'attachment', $photo, 'photo.jpg'
    )->post('http://example.com/attachments');

<a name="headers"></a>
### 請求頭

你可以通過 `withHeaders` 方法添加請求頭。該 `withHeaders` 方法接受一個數組格式的鍵 / 值對：

    $response = Http::withHeaders([
        'X-First' => 'foo',
        'X-Second' => 'bar'
    ])->post('http://example.com/users', [
        'name' => 'Taylor',
    ]);

你可以使用 `accept` 方法指定應用程序響應你的請求所需的內容類型：

    $response = Http::accept('application/json')->get('http://example.com/users');

為方便起見，你可以使用 `acceptJson` 方法快速指定應用程序需要 `application/json` 內容類型來響應你的請求：

    $response = Http::acceptJson()->get('http://example.com/users');

<a name="authentication"></a>
### 認證

你可以使用 `withBasicAuth` 和 `withDigestAuth` 方法來分別指定使用 Basic 或是 Digest 認證方式：

    // Basic 認證方式...
    $response = Http::withBasicAuth('taylor@laravel.com', 'secret')->post(/* ... */);

    // Digest 認證方式...
    $response = Http::withDigestAuth('taylor@laravel.com', 'secret')->post(/* ... */);

<a name="bearer-tokens"></a>
#### Bearer 令牌

如果你想要為你的請求快速添加 `Authorization` Token 令牌請求頭，你可以使用 `withToken` 方法：

    $response = Http::withToken('token')->post(/* ... */);

<a name="timeout"></a>
### 超時

該 `timeout` 方法用於指定響應的最大等待秒數：

    $response = Http::timeout(3)->get(/* ... */);

如果響應時間超過了指定的超時時間，將會拋出 `Illuminate\Http\Client\ConnectionException` 異常。

你可以嘗試使用 `connectTimeout` 方法指定連接到服務器時等待的最大秒數：

    $response = Http::connectTimeout(3)->get(/* ... */);

<a name="retries"></a>
### 重試

如果你希望 HTTP 客戶端在發生客戶端或服務端錯誤時自動進行重試，你可以使用 retry 方法。該 retry 方法接受兩個參數：重新嘗試次數以及重試間隔（毫秒）：

    $response = Http::retry(3, 100)->post(/* ... */);

如果需要，你可以將第三個參數傳遞給該 `retry` 方法。第三個參數應該是一個可調用的，用於確定是否應該實際嘗試重試。例如，你可能希望僅在初始請求遇到以下情況時重試請求 `ConnectionException`：

    use Exception;
    use Illuminate\Http\Client\PendingRequest;

    $response = Http::retry(3, 100, function (Exception $exception, PendingRequest $request) {
        return $exception instanceof ConnectionException;
    })->post(/* ... */);

如果請求失敗，你可以在新請求之前更改請求。你可以通過修改 `retry` 方法的第三個請求參數來實現這一點。例如，當請求返回身份驗證錯誤，則可以使用新的授權令牌重試請求：

    use Exception;
    use Illuminate\Http\Client\PendingRequest;

    $response = Http::withToken($this->getToken())->retry(2, 0, function (Exception $exception, PendingRequest $request) {
        if (! $exception instanceof RequestException || $exception->response->status() !== 401) {
            return false;
        }

        $request->withToken($this->getNewToken());

        return true;
    })->post(/* ... */);

所有請求都失敗時，將會拋出一個`Illuminate\Http\Client\RequestException`實例。如果不想拋出錯誤，你需要設置請求方法的`throw`參數為`false`。禁止後，當所有的請求都嘗試完成後，最後一個響應將會return回來：

    $response = Http::retry(3, 100, throw: false)->post(/* ... */);

> **注意**
> 如果所有的請求都因為連接問題失敗， 即使 `throw`屬性設置為`false`，`Illuminate\Http\Client\ConnectionException`錯誤依舊會被拋出。

<a name="error-handling"></a>
### 錯誤處理

與 Guzzle 的默認處理方式不同，Laravel 的 HTTP 客戶端在客戶端或者服務端出現4xx或者5xx錯誤時並不會拋出錯誤。你應該通過`successful`、 `clientError`或 `serverError`方法來校驗返回的響應是否有錯誤信息:

    // 判斷狀態碼是否是 2xx
    $response->successful();

    // 判斷錯誤碼是否是 4xx或5xx
    $response->failed();

    // 判斷錯誤碼是4xx
    $response->clientError();

    // 判斷錯誤碼是5xx
    $response->serverError();

    // 如果出現客戶端或服務器錯誤，則執行給定的回調
    $response->onError(callable $callback);

<a name="throwing-exceptions"></a>
#### 主動拋出錯誤

如果你想在收到的響應是客戶端或者服務端錯誤時拋出一個`Illuminate\Http\Client\RequestException`實例，你可以使用`throw` 或 `throwIf` 方法：

    use Illuminate\Http\Client\Response;

    $response = Http::post(/* ... */);

    // 當收到服務端或客戶端錯誤時拋出
    $response->throw();

    // 當滿足condition條件是拋出錯誤
    $response->throwIf($condition);

    // 當給定的閉包執行結果是true時拋出錯誤
    $response->throwIf(fn (Response $response) => true);

    // 當給定條件是false是拋出錯誤
    $response->throwUnless($condition);

    // 當給定的閉包執行結果是false時拋出錯誤
    $response->throwUnless(fn (Response $response) => false);

    // 當收到的狀態碼是403時拋出錯誤
    $response->throwIfStatus(403);

    // 當收到的狀態碼不是200時拋出錯誤
    $response->throwUnlessStatus(200);

    return $response['user']['id'];

`Illuminate\Http\Client\RequestException` 實例擁有一個  `$response` 公共屬性，該屬性允許你檢查返回的響應。

如果沒有發生錯誤，`throw` 方法返回響應實例，你可以將其他操作鏈接到 `throw` 方法：

    return Http::post(/* ... */)->throw()->json();

如果你希望在拋出異常前進行一些操作，你可以向 `throw` 方法傳遞一個閉包。異常將會在閉包執行完成後自動拋出，你不必在閉包內手動拋出異常：

    use Illuminate\Http\Client\Response;
    use Illuminate\Http\Client\RequestException;

    return Http::post(/* ... */)->throw(function (Response $response, RequestException $e) {
        // ...
    })->json();

<a name="guzzle-middleware"></a>
### Guzzle 中間件

由於 Laravel 的 HTTP 客戶端是由 Guzzle 提供支持的, 你可以利用 [Guzzle 中間件](https://docs.guzzlephp.org/en/stable/handlers-and-middleware.html) 來操作發出的請求或檢查傳入的響應。要操作發出的請求，需要通過 `withMiddleware` 方法和 Guzzle 的 `mapRequest` 中間件工廠注冊一個 Guzzle 中間件：

    use GuzzleHttp\Middleware;
    use Illuminate\Support\Facades\Http;
    use Psr\Http\Message\RequestInterface;

    $response = Http::withMiddleware(
        Middleware::mapRequest(function (RequestInterface $request) {
            $request = $request->withHeader('X-Example', 'Value');

            return $request;
        })
    )->get('http://example.com');

同樣地，你可以通過 `withMiddleware` 方法結合 Guzzle 的 `mapResponse` 中間件工廠注冊一個中間件來檢查傳入的 HTTP 響應：

    use GuzzleHttp\Middleware;
    use Illuminate\Support\Facades\Http;
    use Psr\Http\Message\ResponseInterface;

    $response = Http::withMiddleware(
        Middleware::mapResponse(function (ResponseInterface $response) {
            $header = $response->getHeader('X-Example');

            // ...

            return $response;
        })
    )->get('http://example.com');

<a name="guzzle-options"></a>
### Guzzle 選項

你可以使用 `withOptions` 方法來指定額外的 [Guzzle 請求配置](http://docs.guzzlephp.org/en/stable/request-options.html)。`withOptions` 方法接受數組形式的鍵 / 值對：

    $response = Http::withOptions([
        'debug' => true,
    ])->get('http://example.com/users');

<a name="concurrent-requests"></a>
## 並發請求

有時，你可能希望同時發出多個 HTTP 請求。換句話說，你希望同時分派多個請求，而不是按順序發出請求。當與慢速 HTTP API 交互時，這可以顯著提高性能。

值得慶幸的是，你可以使用該 `pool` 方法完成此操作。`pool` 方法接受一個接收 `Illuminate\Http\Client\Pool` 實例的閉包，能讓你輕松地將請求添加到請求池以進行調度：

    use Illuminate\Http\Client\Pool;
    use Illuminate\Support\Facades\Http;

    $responses = Http::pool(fn (Pool $pool) => [
        $pool->get('http://localhost/first'),
        $pool->get('http://localhost/second'),
        $pool->get('http://localhost/third'),
    ]);

    return $responses[0]->ok() &&
           $responses[1]->ok() &&
           $responses[2]->ok();

如你所見，每個響應實例可以按照添加到池中的順序來訪問。你可以使用 `as` 方法命名請求，該方法能讓你按名稱訪問相應的響應：

    use Illuminate\Http\Client\Pool;
    use Illuminate\Support\Facades\Http;

    $responses = Http::pool(fn (Pool $pool) => [
        $pool->as('first')->get('http://localhost/first'),
        $pool->as('second')->get('http://localhost/second'),
        $pool->as('third')->get('http://localhost/third'),
    ]);

    return $responses['first']->ok();

<a name="macros"></a>
## 宏

Laravel HTTP客戶端允許你定義「宏」（macros），這可以作為一種流暢、表達力強的機制，在與應用程序中的服務交互時配置常見的請求路徑和標頭。要開始使用，你可以在應用程序的 `App\Providers\AppServiceProvider` 類的 `boot` 方法中定義宏：

    use Illuminate\Support\Facades\Http;

    /**
     * 引導應用程序服務。
     */
    public function boot(): void
    {
        Http::macro('github', function () {
            return Http::withHeaders([
                'X-Example' => 'example',
            ])->baseUrl('https://github.com');
        });
    }

一旦你配置了宏，你可以在應用程序的任何地方調用它，以使用指定的配置創建一個掛起的請求：

    $response = Http::github()->get('/');

<a name="testing"></a>
## 測試

許多 Laravel 服務提供功能來幫助你輕松、表達性地編寫測試，而 Laravel 的 HTTP 客戶端也不例外。`Http` 門面的 `fake` 方法允許你指示 HTTP 客戶端在發出請求時返回存根/虛擬響應。

<a name="faking-responses"></a>
### 偽造響應

例如，要指示 HTTP 客戶端在每個請求中返回空的 `200` 狀態碼響應，你可以調用 `fake` 方法而不傳遞參數：

    use Illuminate\Support\Facades\Http;

    Http::fake();

    $response = Http::post(/* ... */);

<a name="faking-specific-urls"></a>
#### 偽造特定的URL

另外，你可以向 `fake` 方法傳遞一個數組。該數組的鍵應該代表你想要偽造的 URL 模式及其關聯的響應。`*` 字符可以用作通配符。任何請求到未偽造的 URL 的請求將會被實際執行。你可以使用 `Http` 門面的 `response` 方法來構建這些端點的存根/虛擬響應：

    Http::fake([
        // 為 GitHub 端點存根一個 JSON 響應...
        'github.com/*' => Http::response(['foo' => 'bar'], 200, $headers),

        // 為 Google 端點存根一個字符串響應...
        'google.com/*' => Http::response('Hello World', 200, $headers),
    ]);

如果你想指定一個後備 URL 模式來存根所有不匹配的 URL，你可以使用單個 `*` 字符：

    Http::fake([
        // 為 GitHub 端點存根 JSON 響應……
        'github.com/*' => Http::response(['foo' => 'bar'], 200, ['Headers']),

        // 為其他所有端點存根字符串響應……
        '*' => Http::response('Hello World', 200, ['Headers']),
    ]);

<a name="faking-response-sequences"></a>
#### 偽造響應序列

有時候，你可能需要為單個 URL 指定其一系列的偽造響應的返回順序。你可以使用 `Http::sequence` 方法來構建響應，以實現這個功能：

    Http::fake([
        // 存根 GitHub端點的一系列響應……
        'github.com/*' => Http::sequence()
                                ->push('Hello World', 200)
                                ->push(['foo' => 'bar'], 200)
                                ->pushStatus(404),
    ]);

當響應序列中的所有響應都被消費完後，後續的任何請求都將導致相應序列拋出一個異常。如果你想要在響應序列為空時指定一個默認的響應，則可以使用 `whenEmpty` 方法：

    Http::fake([
        // 為 GitHub 端點存根一系列響應
        'github.com/*' => Http::sequence()
                                ->push('Hello World', 200)
                                ->push(['foo' => 'bar'], 200)
                                ->whenEmpty(Http::response()),
    ]);

如果你想要偽造一個響應序列，但你又期望在偽造的時候無需指定一個特定的 URL 匹配模式，那麽你可以使用 `Http::fakeSequence` 方法：

    Http::fakeSequence()
            ->push('Hello World', 200)
            ->whenEmpty(Http::response());

<a name="fake-callback"></a>
#### Fake 回調

如果你需要更為覆雜的邏輯來確定某些端點返回什麽響應，你需要傳遞一個閉包給 `fake` 方法。這個閉包應該接受一個 `Illuminate\Http\Client\Request` 實例且返回一個響應實例。在閉包中你可以執行任何必要的邏輯來確定要返回的響應類型：

    use Illuminate\Http\Client\Request;

    Http::fake(function (Request $request) {
        return Http::response('Hello World', 200);
    });

<a name="preventing-stray-requests"></a>
### 避免「流浪的」請求（確保請求總是偽造的）

如果你想確保通過 HTTP 客戶端發送的所有請求在整個單獨的測試或完整的測試套件中都是偽造的，那麽你可以調用 `preventStrayRequests` 方法。在調用該方法後，如果一個請求沒有與之相匹配的偽造的響應，則將會拋出一個異常而不是發起一個真實的請求：

    use Illuminate\Support\Facades\Http;

    Http::preventStrayRequests();

    Http::fake([
        'github.com/*' => Http::response('ok'),
    ]);

    // 將會返回 OK 響應……
    Http::get('https://github.com/laravel/framework');

    // 拋出一個異常……
    Http::get('https://laravel.com');

<a name="inspecting-requests"></a>
### 檢查請求

在偽造響應時，你可能希望檢查客戶端收到的請求，以確保你的應用程序發出了正確的數據和標頭。你可以在調用 `Http::fake` 方法後調用 `Http::assertSent` 方法來實現這個功能。

`assertSent` 方法接受一個閉包，該閉包應當接收一個 `Illuminate\Http\Client\Request` 實例且返回一個布爾值，該布爾值指示請求是否符合預期。為了使得測試通過，必須至少發出一個符合給定預期的請求：

    use Illuminate\Http\Client\Request;
    use Illuminate\Support\Facades\Http;

    Http::fake();

    Http::withHeaders([
        'X-First' => 'foo',
    ])->post('http://example.com/users', [
        'name' => 'Taylor',
        'role' => 'Developer',
    ]);

    Http::assertSent(function (Request $request) {
        return $request->hasHeader('X-First', 'foo') &&
               $request->url() == 'http://example.com/users' &&
               $request['name'] == 'Taylor' &&
               $request['role'] == 'Developer';
    });

如果有需要，你可以使用 `assertNotSent` 方法來斷言未發出指定的請求：

    use Illuminate\Http\Client\Request;
    use Illuminate\Support\Facades\Http;

    Http::fake();

    Http::post('http://example.com/users', [
        'name' => 'Taylor',
        'role' => 'Developer',
    ]);

    Http::assertNotSent(function (Request $request) {
        return $request->url() === 'http://example.com/posts';
    });

你可以使用 `assertSentCount` 方法來斷言在測試過程中發出的請求數量：

    Http::fake();

    Http::assertSentCount(5);

或者，你也可以使用 `assertNothingSent` 方法來斷言在測試過程中沒有發出任何請求：

    Http::fake();

    Http::assertNothingSent();

<a name="recording-requests-and-responses"></a>
#### 記錄請求和響應

你可以使用 `recorded` 方法來收集所有的請求及其對應的響應。`recorded` 方法返回一個數組集合，其中包含了 `Illuminate\Http\Client\Request` 實例和 `Illuminate\Http\Client\Response` 實例：

    Http::fake([
        'https://laravel.com' => Http::response(status: 500),
        'https://nova.laravel.com/' => Http::response(),
    ]);

    Http::get('https://laravel.com');
    Http::get('https://nova.laravel.com/');

    $recorded = Http::recorded();

    [$request, $response] = $recorded[0];

此外，`recorded` 函數也接受一個閉包，該閉包接受一個 `Illuminate\Http\Client\Request` 和 `Illuminate\Http\Client\Response` 實例，該閉包可以用來按照你的期望來過濾請求和響應：

    use Illuminate\Http\Client\Request;
    use Illuminate\Http\Client\Response;

    Http::fake([
        'https://laravel.com' => Http::response(status: 500),
        'https://nova.laravel.com/' => Http::response(),
    ]);

    Http::get('https://laravel.com');
    Http::get('https://nova.laravel.com/');

    $recorded = Http::recorded(function (Request $request, Response $response) {
        return $request->url() !== 'https://laravel.com' &&
               $response->successful();
    });

<a name="events"></a>
## 事件

Laravel 在發出 HTTP 請求的過程中將會觸發三個事件。在發送請求前將會觸發 `RequestSending` 事件，在接收到了指定請求對應的響應時將會觸發 `ResponseReceived` 事件。如果沒有收到指定請求對應的響應則會觸發 `ConnectionFailed` 事件。

`RequestSending` 和 `ConnectionFailed` 事件都包含一個公共的 `$request` 屬性，你可以使用它來檢查 `Illuminate\Http\Client\Request` 實例。 同樣，`ResponseReceived` 事件包含一個 `$request` 屬性以及一個 `$response` 屬性，可用於檢查 `Illuminate\Http\Client\Response` 實例。 你可以在你的 `App\Providers\EventServiceProvider` 服務提供者中為這個事件注冊事件監聽器：

    /**
     * 應用程序的事件偵聽器映射。
     *
     * @var array
     */
    protected $listen = [
        'Illuminate\Http\Client\Events\RequestSending' => [
            'App\Listeners\LogRequestSending',
        ],
        'Illuminate\Http\Client\Events\ResponseReceived' => [
            'App\Listeners\LogResponseReceived',
        ],
        'Illuminate\Http\Client\Events\ConnectionFailed' => [
            'App\Listeners\LogConnectionFailed',
        ],
    ];
