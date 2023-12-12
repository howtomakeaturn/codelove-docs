# 服務容器

- [簡介](#introduction)
    - [零配置解決方案](#zero-configuration-resolution)
    - [何時使用容器](#when-to-use-the-container)
- [綁定](#binding)
    - [綁定基礎](#binding-basics)
    - [接口到實現的綁定](#binding-interfaces-to-implementations)
    - [上下文綁定](#contextual-binding)
    - [綁定原語](#binding-primitives)
    - [綁定變長參數類型](#binding-typed-variadics)
    - [標簽](#tagging)
    - [繼承綁定](#extending-bindings)
- [解析](#resolving)
    - [Make 方法](#the-make-method)
    - [自動注入](#automatic-injection)
- [方法調用 & 注入](#method-invocation-and-injection)
- [容器事件](#container-events)
- [PSR-11](#psr-11)

<a name="introduction"></a>
## 簡介

Laravel 服務容器是一個用於管理類依賴以及實現依賴注入的強有力工具。依賴注入這個名詞表面看起來花哨，實質上是指：通過構造函數，或者某些情況下通過「setter」方法將類依賴「注入」到類中。

我們來看一個簡單的例子：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Repositories\UserRepository;
    use App\Models\User;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * 創建一個新的控制器實例
         */
        public function __construct(
            protected UserRepository $users,
        ) {}

        /**
         * 展示給定用戶的信息
         */
        public function show(string $id): View
        {
            $user = $this->users->find($id);

            return view('user.profile', ['user' => $user]);
        }
    }

在此示例中，`UserController` 需要從數據源中檢索用戶。 因此，我們將 **注入** 一個能夠檢索用戶的服務。 在這種情況下，我們的 `UserRepository` 很可能使用 [Eloquent](/docs/laravel/10.x/eloquent) 從數據庫中檢索用戶信息。 然而，由於存儲庫是注入的，我們可以很容易地用另一個實現替換它。 這種方式的便利之處也體現在：當需要為應用編寫測試的時候，我們也可以很輕松地 「模擬」 或者創建一個 `UserRepository` 的偽實現來操作。



深入理解服務容器，對於構建一個強大的、大型的應用，以及對 Laravel 核心本身的貢獻都是至關重要的。

<a name="zero-configuration-resolution"></a>
### 零配置解決方案

如果一個類沒有依賴項或只依賴於其他具體類（而不是接口），則不需要指定容器如何解析該類。例如，你可以將以下代碼放在 `routes/web.php` 文件中：

    <?php

    class Service
    {
        // ...
    }

    Route::get('/', function (Service $service) {
        die(get_class($service));
    });

在這個例子中，點擊應用程序的 `/` 路由將自動解析 `Service` 類並將其注入到路由的處理程序中。 這是一個有趣的改變。 這意味著你可以開發應用程序並利用依賴注入，而不必擔心臃腫的配置文件。

很榮幸的通知你，在構建 Laravel 應用程序時，你將要編寫的許多類都可以通過容器自動接收它們的依賴關系，包括 [控制器](/docs/laravel/10.x/controllers)、 [事件監聽器](/docs/laravel/10.x/events)、 [中間件](/docs/laravel/10.x/middleware) 等等。 此外，你可以在 [隊列系統](/docs/laravel/10.x/queues) 的 `handle` 方法中鍵入提示依賴項。 一旦你嘗到了自動和零配置依賴注入的力量，你就會覺得沒有它是不可以開發的。

<a name="when-to-use-the-container"></a>
### 何時使用容器

得益於零配置解決方案，通常情況下，你只需要在路由、控制器、事件偵聽器和其他地方鍵入提示依賴項，而不必手動與容器打交道。例如，可以在路由定義中鍵入 `Illuminate\Http\Request` 對象，以便輕松訪問當前請求的 Request 類。盡管我們不必與容器交互來編寫此代碼，但它在幕後管理著這些依賴項的注入：

    use Illuminate\Http\Request;

    Route::get('/', function (Request $request) {
        // ...
    });

在許多情況下，由於自動依賴注入和 [facades](/docs/laravel/10.x/facades) ，你在構建 Laravel 應用程序，而無需手動綁定或解析容器中的任何內容。 **那麽，你什麽時候會手動與容器打交道呢？** 讓我們來看看下面兩種情況。

首先，如果你編寫了一個實現接口的類，並希望在路由或類的構造函數上鍵入該接口的提示，則必須 [告訴容器如何解析該接口](#binding-interfaces-to-implementations)。第二，如果你正在 [編寫一個 Laravel 包](/docs/laravel/10.x/packages) 計劃與其他 Laravel 開發人員共享，那麽你可能需要將包的服務綁定到容器中。

<a name="binding"></a>
## 綁定

<a name="binding-basics"></a>
### 基礎綁定

<a name="simple-bindings"></a>
#### 簡單綁定

幾乎所有的服務容器綁定都會在 [服務提供者](/docs/laravel/10.x/providers) 中注冊，下面示例中的大多數將演示如何在該上下文（服務提供者）中使用容器。

在服務提供者中，你總是可以通過 `$this->app` 屬性訪問容器。我們可以使用 `bind` 方法注冊一個綁定，將我們希望注冊的類或接口名稱與返回類實例的閉包一起傳遞:

    use App\Services\Transistor;
    use App\Services\PodcastParser;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->bind(Transistor::class, function (Application $app) {
        return new Transistor($app->make(PodcastParser::class));
    });

注意，我們接受容器本身作為解析器的參數。然後，我們可以使用容器來解析正在構建的對象的子依賴。



如前所述，你通常會在服務提供者內部與容器進行交互；但是，如果你希望在服務提供者外部與容器進行交互，則可以通過 `App` [facade](/docs/laravel/10.x/facades) 進行:

    use App\Services\Transistor;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\Facades\App;

    App::bind(Transistor::class, function (Application $app) {
        // ...
    });

> **技巧**
> 如果類不依賴於任何接口，則不需要將它們綁定到容器中。不需要指示容器如何構建這些對象，因為它可以使用反射自動解析這些對象。

<a name="binding-a-singleton"></a>
#### 單例的綁定

`singleton` 方法將類或接口綁定到只應解析一次的容器中。解析單例綁定後，後續調用容器時將返回相同的對象實例：

    use App\Services\Transistor;
    use App\Services\PodcastParser;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->singleton(Transistor::class, function (Application $app) {
        return new Transistor($app->make(PodcastParser::class));
    });

<a name="binding-scoped"></a>
#### 綁定作用域單例

`scoped` 方法將一個類或接口綁定到容器中，該容器只應在給定的 Laravel 請求 / 作業生命周期內解析一次。雖然該方法與 `singleton` 方法類似，但是當 Laravel 應用程序開始一個新的「生命周期」時， 使用 `scoped` 方法注冊的實例 將被刷新，例如當 [Laravel Octane](/docs/laravel/10.x/octane) 工作者處理新請求或 Laravel [隊列系統](/docs/laravel/10.x/queues)處理新作業時：

    use App\Services\Transistor;
    use App\Services\PodcastParser;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->scoped(Transistor::class, function (Application $app) {
        return new Transistor($app->make(PodcastParser::class));
    });



<a name="binding-instances"></a>
#### 綁定實例

你也可以使 `instance` 方法將一個現有的對象實例綁定到容器中。給定的實例總會在後續對容器的調用中返回:

    use App\Services\Transistor;
    use App\Services\PodcastParser;

    $service = new Transistor(new PodcastParser);

    $this->app->instance(Transistor::class, $service);

<a name="binding-interfaces-to-implementations"></a>
### 將接口綁定實例

服務容器的一個非常強大的特性是它能夠將接口綁定到給定的實例。例如，我們假設有一個 `EventPusher` 接口和一個 `RedisEventPusher` 實例。一旦我們編寫了這個接口的 `RedisEventPusher` 實例，我們就可以像這樣把它注冊到服務容器中:

    use App\Contracts\EventPusher;
    use App\Services\RedisEventPusher;

    $this->app->bind(EventPusher::class, RedisEventPusher::class);

這條語句告訴容器，當類需要 `EventPusher` 的實例時，它應該注入 `RedisEventPusher`。現在我們可以在由容器解析的類的構造函數中輸入 `EventPusher` 接口。記住，控制器、事件監聽器、中間件和Laravel應用程序中的各種其他類型的類總是使用容器進行解析的:

    use App\Contracts\EventPusher;

    /**
     * Create a new class instance.
     */
    public function __construct(
        protected EventPusher $pusher
    ) {}

<a name="contextual-binding"></a>
### 上下文綁定
> 譯者注：所謂「上下文綁定」就是根據上下文進行動態的綁定，指依賴的上下文關系。

有時你可能有兩個類使用相同的接口，但是你希望將不同的實現分別注入到各自的類中。例如，兩個控制器可能依賴於 `Illuminate\Contracts\Filesystem\Filesystem` [契約](/docs/laravel/10.x/contracts) 的不同實現。Laravel 提供了一個簡單流暢的方式來定義這種行為：

    use App\Http\Controllers\PhotoController;
    use App\Http\Controllers\UploadController;
    use App\Http\Controllers\VideoController;
    use Illuminate\Contracts\Filesystem\Filesystem;
    use Illuminate\Support\Facades\Storage;

    $this->app->when(PhotoController::class)
              ->needs(Filesystem::class)
              ->give(function () {
                  return Storage::disk('local');
              });

    $this->app->when([VideoController::class, UploadController::class])
              ->needs(Filesystem::class)
              ->give(function () {
                  return Storage::disk('s3');
              });



<a name="binding-primitives"></a>
### 綁定原語

有時，你可能有一個接收一些注入類的類，但也需要一個注入的原語值，如整數。你可以很容易地使用上下文綁定來，注入類可能需要的任何值:

    use App\Http\Controllers\UserController;

    $this->app->when(UserController::class)
              ->needs('$variableName')
              ->give($value);

有時，類可能依賴於 [標簽](#tagging) 實例的數組。使用 `giveTagged` 方法，你可以很容易地注入所有帶有該標簽的容器綁定:

    $this->app->when(ReportAggregator::class)
        ->needs('$reports')
        ->giveTagged('reports');

如果你需要從應用程序的某個配置文件中注入一個值，你可以使用 `giveConfig` 方法:

    $this->app->when(ReportAggregator::class)
        ->needs('$timezone')
        ->giveConfig('app.timezone');

<a name="binding-typed-variadics"></a>
### 綁定變長參數類型

有時，你可能有一個使用可變構造函數參數接收類型對象數組的類：

    <?php

    use App\Models\Filter;
    use App\Services\Logger;

    class Firewall
    {
        /**
         * 過濾器實例組
         *
         * @var array
         */
        protected $filters;

        /**
         * 創建一個類實例
         */
        public function __construct(
            protected Logger $logger,
            Filter ...$filters,
        ) {
            $this->filters = $filters;
        }
    }

使用上下文綁定，你可以通過提供 `give` 方法一個閉包來解決這個依賴，該閉包返回一個已解析的 `Filter`實例數組：

    $this->app->when(Firewall::class)
              ->needs(Filter::class)
              ->give(function (Application $app) {
                    return [
                        $app->make(NullFilter::class),
                        $app->make(ProfanityFilter::class),
                        $app->make(TooLongFilter::class),
                    ];
              });

為方便起見，你也可以只提供一個類名數組，以便在 `Firewall` 需要 `Filter` 實例時由容器解析:

    $this->app->when(Firewall::class)
              ->needs(Filter::class)
              ->give([
                  NullFilter::class,
                  ProfanityFilter::class,
                  TooLongFilter::class,
              ]);



<a name="variadic-tag-dependencies"></a>
#### 變長參數的關聯標簽

有時，一個類可能具有類型提示為給定類的可變依賴項（`Report ...$reports`)）。使用 `needs` 和 `giveTagged` 方法，你可以輕松地為給定依賴項注入所有帶有該 [標簽](#tagging) 的所有容器綁定：

    $this->app->when(ReportAggregator::class)
        ->needs(Report::class)
        ->giveTagged('reports');

<a name="tagging"></a>
### 標簽

有時，你可能需要解決所有特定「類別」的綁定。例如，也許你正在構建一個報告分析器，它接收許多不同的 `Report` 接口實現的數組。注冊 `Report` 實現後，你可以使用 `tag` 方法為它們分配標簽：

    $this->app->bind(CpuReport::class, function () {
        // ...
    });

    $this->app->bind(MemoryReport::class, function () {
        // ...
    });

    $this->app->tag([CpuReport::class, MemoryReport::class], 'reports');

一旦服務被打上標簽，你就可以通過容器的 `tagged` 方法輕松地解析它們：

    $this->app->bind(ReportAnalyzer::class, function (Application $app) {
        return new ReportAnalyzer($app->tagged('reports'));
    });

<a name="extending-bindings"></a>
### 繼承綁定

`extend` 方法允許修改已解析的服務。例如，解析服務時，可以運行其他代碼來修飾或配置服務。`extend` 方法接受閉包，該閉包應返回修改後的服務作為其唯一參數。閉包接收正在解析的服務和容器實例：

    $this->app->extend(Service::class, function (Service $service, Application $app) {
        return new DecoratedService($service);
    });

<a name="resolving"></a>
## 解析

<a name="the-make-method"></a>
### `make` 方法



你可以使用 `make` 方法從容器中解析出一個類實例。`make` 方法接受你要解析的類或接口的名稱：

```php
use App\Services\Transistor;

$transistor = $this->app->make(Transistor::class);
```

如果你的某些類依賴關系無法通過容器解析，請通過將它們作為關聯數組傳遞到 `makeWith` 方法中來注入它們。例如，我們可以手動傳遞 `Transistor` 服務所需的 `$id` 構造函數參數：

```php
use App\Services\Transistor;

$transistor = $this->app->makeWith(Transistor::class, ['id' => 1]);
```

如果你不在服務提供程序外部的代碼位置中，並且沒有訪問 `$app` 變量的權限，你可以使用 `App` [facade](/docs/laravel/10.x/facades) 或 `app` [helper](/docs/laravel/10.x/helpersmd#method-app) 來從容器中解析出一個類實例：


```php
use App\Services\Transistor;
use Illuminate\Support\Facades\App;

$transistor = App::make(Transistor::class);

$transistor = app(Transistor::class);
```

如果你想將 Laravel 容器實例本身注入到由容器解析的類中，你可以在你的類的構造函數上進行類型提示，指定 `Illuminate\Container\Container` 類型：


```php
use Illuminate\Container\Container;

/**
 * 創建一個新的類實例。
 */
public function __construct( protected Container $container ) {}
```

### 自動注入

或者，你可以在由容器解析的類的構造函數中類型提示依賴項，包括 [控制器](/docs/laravel/10.x/controllers)、[事件監聽器](/docs/laravel/10.x/events)、[中間件](/docs/laravel/10.x/middleware) 等。此外，你可以在 [隊列作業](/docs/laravel/10.x/queues) 的 `handle` 方法中類型提示依賴項。在實踐中，這是大多數對象應該由容器解析的方式。

例如，你可以在控制器的構造函數中添加一個 repository 的類型提示，然後這個 repository 將會被自動解析並注入類中：

    <?php

    namespace App\Http\Controllers;

    use App\Repositories\UserRepository;
    use App\Models\User;

    class UserController extends Controller
    {
        /**
         * 創建一個控制器實例
         */
        public function __construct(
            protected UserRepository $users,
        ) {}

        /**
         * 使用給定的 ID 顯示 user
         */
        public function show(string $id): User
        {
            $user = $this->users->findOrFail($id);

            return $user;
        }
    }

<a name="method-invocation-and-injection"></a>
## 方法調用和注入

有時你可能希望調用對象實例上的方法，同時允許容器自動注入該方法的依賴項。例如，給定以下類：

    <?php

    namespace App;

    use App\Repositories\UserRepository;

    class UserReport
    {
        /**
         * 生成新的用戶報告
         */
        public function generate(UserRepository $repository): array
        {
            return [
                // ...
            ];
        }
    }

你可以通過容器調用 `generate` 方法，如下所示：

    use App\UserReport;
    use Illuminate\Support\Facades\App;

    $report = App::call([new UserReport, 'generate']);

`call` 方法接受任何可調用的 PHP 方法。容器的 `call` 方法甚至可以用於調用閉包，同時自動注入其依賴項：

    use App\Repositories\UserRepository;
    use Illuminate\Support\Facades\App;

    $result = App::call(function (UserRepository $repository) {
        // ...
    });

<a name="container-events"></a>
## 容器事件

服務容器每次解析對象時都會觸發一個事件。你可以使用 `resolving` 方法監聽此事件：

    use App\Services\Transistor;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->resolving(Transistor::class, function (Transistor $transistor, Application $app) {
        // 當容器解析「Transistor」類型的對象時調用...
    });

    $this->app->resolving(function (mixed $object, Application $app) {
        // 當容器解析任何類型的對象時調用...
    });



如你所見，正在解析的對象將被傳遞給回調，從而允許你在對象提供給其使用者之前設置對象的任何其他屬性。

<a name="psr-11"></a>
## PSR-11

Laravel 的服務容器實現了 [PSR-11](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-11-container.md) 接口。因此，你可以添加 PSR-11 容器接口的類型提示來獲取 Laravel 容器的實例：

    use App\Services\Transistor;
    use Psr\Container\ContainerInterface;

    Route::get('/', function (ContainerInterface $container) {
        $service = $container->get(Transistor::class);

        // ...
    });

如果無法解析給定的標識符，將引發異常。如果標識符從未綁定，則異常將是`Psr\Container\NotFoundExceptionInterface` 的實例。如果標識符已綁定但無法解析，則將拋出`Psr\Container\ContainerExceptionInterface` 的實例。
