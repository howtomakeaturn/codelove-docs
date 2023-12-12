# 視圖

- [介紹](#introduction)
    - [在 React / Vue 中編寫視圖](#writing-views-in-react-or-vue)
- [創建和渲染視圖](#creating-and-rendering-views)
    - [嵌套視圖目錄](#nested-view-directories)
    - [創建第一個可用視圖](#creating-the-first-available-view)
    - [確定視圖是否存在](#determining-if-a-view-exists)
- [向視圖傳遞數據](#passing-data-to-views)
    - [與所有視圖分享數據](#sharing-data-with-all-views)
- [視圖組件](#view-composers)
    - [視圖構造器](#view-creators)
- [視圖構造器](#optimizing-views)

<a name="introduction"></a>
## 介紹

當然，直接從路由和控制器返回整個 HTML 文檔字符串是不切實際的。值得慶幸的是，視圖提供了一種方便的方式來將我們所有的 HTML 放在單獨的文件中。

視圖將你的控制器 / 應用程序邏輯與你的表示邏輯分開並存儲在 `resources/views` 目錄中。一個簡單的視圖可能看起來像這樣：使用 Laravel 時，視圖模板通常使用[Blade模板語言](/docs/laravel/10.x/blade) 編寫。一個簡單的視圖如下所示：

```blade
<!-- 視圖存儲在 `resources/views/greeting.blade.php` -->

<html>
    <body>
        <h1>Hello, {{ $name }}</h1>
    </body>
</html>
```

將上述代碼存儲到 `resources/views/greeting.blade.php` 後，我們可以使用全局輔助函數 `view` 將其返回，例如：

    Route::get('/', function () {
        return view('greeting', ['name' => 'James']);
    });

> 技巧：如果你想了解更多關於如何編寫 Blade 模板的更多信息？查看完整的 [Blade 文檔](/docs/laravel/10.x/blade) 將是最好的開始。

<a name="writing-views-in-react-or-vue"></a>
### 在 React / Vue 中編寫視圖

許多開發人員已經開始傾向於使用 React 或 Vue 編寫模板，而不是通過 Blade 在 PHP 中編寫前端模板。Laravel 讓這件事不痛不癢，這要歸功於 [慣性](https://inertiajs.com/)，這是一個庫，可以輕松地將 React / Vue 前端連接到 Laravel 後端，而無需構建 SPA 的典型覆雜性。


我們的 Breeze 和 Jetstream [starter kits](https://laravel.com/docs/10.x/starter-kits) 為你提供了一個很好的起點，用 Inertia 驅動你的下一個 Laravel 應用程序。此外，[Laravel Bootcamp](https://bootcamp.laravel.com/) 提供了一個完整的演示，展示如何構建一個由 Inertia 驅動的 Laravel 應用程序，包括 Vue 和 React 的示例。

<a name="creating-and-rendering-views"></a>

## 創建和渲染視圖

你可以通過在應用程序 `resources/views` 目錄中放置具有 `.blade.php` 擴展名的文件來創建視圖。該 `.blade.php` 擴展通知框架該文件包含一個 [Blade 模板](/docs/laravel/10.x/blade)。Blade 模板包含 HTML 和 Blade 指令，允許你輕松地回顯值、創建「if」語句、叠代數據等。

創建視圖後，可以使用全局 `view` 從應用程序的某個路由或控制器返回視圖：

    Route::get('/', function () {
        return view('greeting', ['name' => 'James']);
    });

也可以使用 `View` 視圖門面（Facade）：

    use Illuminate\Support\Facades\View;

    return View::make('greeting', ['name' => 'James']);

如上所示，傳遞給 `view` 的第一個參數對應於 `resources/views` 目錄中視圖文件的名稱。第二個參數是應該對視圖可用的數據數組。在這種情況下，我們傳遞 name 變量，它使用 [Blade 語法](/docs/laravel/10.x/blade)顯示在視圖中。

<a name="nested-view-directories"></a>
### 嵌套視圖目錄

視圖也可以嵌套在目錄 `resources/views` 的子目錄中。「.」符號可用於引用嵌套視圖。例如，如果視圖存儲在  `resources/views/admin/profile.blade.php` ，你可以從應用程序的路由或控制器中返回它，如下所示：

    return view('admin.profile', $data);

> 注意：查看目錄名稱不應包含該 . 字符。



<a name="creating-the-first-available-view"></a>
### 創建第一個可用視圖

使用 `View` 門面的 `first` 方法，你可以創建給定數組視圖中第一個存在的視圖。如果你的應用程序或開發的第三方包允許定制或覆蓋視圖，這會非常有用：

    use Illuminate\Support\Facades\View;

    return View::first(['custom.admin', 'admin'], $data);

<a name="determining-if-a-view-exists"></a>
### 判斷視圖文件是否存在

如果需要判斷視圖文件是否存在，可以使用 `View` 門面。如果視圖存在， `exists` 方法會返回 `true`：

    use Illuminate\Support\Facades\View;

    if (View::exists('emails.customer')) {
        // ...
    }

<a name="passing-data-to-views"></a>
## 向視圖傳遞數據

正如您在前面的示例中看到的，您可以將數據數組傳遞給視圖，以使該數據可用於視圖：

    return view('greetings', ['name' => 'Victoria']);

以這種方式傳遞信息時，數據應該是帶有鍵 / 值對的數組。向視圖提供數據後，您可以使用數據的鍵訪問視圖中的每個值，例如 `<?php echo $name; ?>`。

作為將完整的數據數組傳遞給 `view` 輔助函數的替代方法，你可以使用該 `with` 方法將單個數據添加到視圖中。該 `with` 方法返回視圖對象的實例，以便你可以在返回視圖之前繼續鏈接方法：

    return view('greeting')
                ->with('name', 'Victoria')
                ->with('occupation', 'Astronaut');

<a name="sharing-data-with-all-views"></a>
### 與所有視圖共享數據

有時，你可能需要與應用程序呈現的所有視圖共享數據，可以使用 `View` 門面的 `share` 。你可以在服務提供器的 `boot` 方法中調用視圖門面（Facade）的 share 。例如，可以將它們添加到 `App\Providers\AppServiceProvider` 或者為它們生成一個單獨的服務提供器：

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\View;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * 注冊應用服務.
         */
        public function register(): void
        {
            // ...
        }

        /**
         * 引導任何應用程序服務。
         */
        public function boot(): void
        {
            View::share('key', 'value');
        }
    }



<a name="view-composers"></a>
## 查看合成器

視圖合成器是在呈現視圖時調用的回調或類方法。如果每次渲染視圖時都希望將數據綁定到視圖，則視圖合成器可以幫助你將邏輯組織到單個位置。如果同一視圖由應用程序中的多個路由或控制器返回，並且始終需要特定的數據，視圖合成器或許會特別有用。

通常，視圖合成器將在應用程序的一個 [服務提供者](/docs/laravel/10.x/providers) 中注冊。在本例中，我們假設我們已經創建了一個新的 `App\Providers\ViewServiceProvider` 來容納此邏輯。

我們將使用 `View` 門面的 `composer` 方法來注冊視圖合成器。 Laravel 不包含基於類的視圖合成器的默認目錄，因此你可以隨意組織它們。例如，可以創建一個 `app/View/Composers` 目錄來存放應用程序的所有視圖合成器：

    <?php

    namespace App\Providers;

    use App\View\Composers\ProfileComposer;
    use Illuminate\Support\Facades;
    use Illuminate\Support\ServiceProvider;
    use Illuminate\View\View;

    class ViewServiceProvider extends ServiceProvider
    {
        /**
         * 注冊任何應用程序服務。
         */
        public function register(): void
        {
            // ...
        }

        /**
         * 引導任何應用程序服務。
         */
        public function boot(): void
        {
            // 使用基於類的合成器。。。
            Facades\View::composer('profile', ProfileComposer::class);

            // 使用基於閉包的合成器。。。
            Facades\View::composer('welcome', function (View $view) {
                // ...
            });

            Facades\View::composer('dashboard', function (View $view) {
                // ...
            });
        }
    }

> 注意：請記住，如果創建一個新的服務提供程序來包含視圖合成器注冊，則需要將服務提供程序添加到 `config/app.php` 配置文件中的 `providers` 數組中。



現在我們注冊了視圖合成器，每次渲染 `profile` 視圖時都會執行 `App\View\Composers\ProfileComposer` 類的 `compose` 方法。接下來看一個視圖合成器類的例子：

    <?php

    namespace App\View\Composers;

    use App\Repositories\UserRepository;
    use Illuminate\View\View;

    class ProfileComposer
    {
        /**
         * 創建新的配置文件合成器。
         */
        public function __construct(
            protected UserRepository $users,
        ) {}

        /**
         * 將數據綁定到視圖。
         */
        public function compose(View $view): void
        {
            $view->with('count', $this->users->count());
        }
    }

如上所示，所有的視圖合成器都會通過 [服務容器](/docs/laravel/10.x/container)進行解析，所以你可以在視圖合成器的構造函數中類型提示需要注入的依賴項。

<a name="attaching-a-composer-to-multiple-views"></a>
#### 將視圖合成器添加到多個視圖

你可以通過將視圖數組作為第一個參數傳遞給 `composer` 方法，可以一次添加多個視圖到視圖合成器中：

    use App\Views\Composers\MultiComposer;
    use Illuminate\Support\Facades\View;

    View::composer(
        ['profile', 'dashboard'],
        MultiComposer::class
    );

該 `composer` 方法同時也接受通配符 `*` ，表示將所有視圖添加到視圖合成器中：

    use Illuminate\Support\Facades;
    use Illuminate\View\View;

    Facades\View::composer('*', function (View $view) {
        // ...
    });

<a name="view-creators"></a>
### 視圖構造器

視圖構造器「creators」和視圖合成器非常相似。唯一不同之處在於視圖構造器在視圖實例化之後執行，而視圖合成器在視圖即將渲染時執行。使用 `creator` 方法注冊視圖構造器：

    use App\View\Creators\ProfileCreator;
    use Illuminate\Support\Facades\View;

    View::creator('profile', ProfileCreator::class);



<a name="optimizing-views"></a>
## 優化視圖

默認情況下，Blade 模板視圖是按需編譯的。當執行渲染視圖的請求時，Laravel 將確定視圖的編譯版本是否存在。如果文件存在，Laravel 將比較未編譯的視圖和已編譯的視圖是否有修改。如果編譯後的視圖不存在，或者未編譯的視圖已被修改，Laravel 將重新編譯該視圖。

在請求期間編譯視圖可能會對性能產生小的負面影響，因此 Laravel 提供了 `view:cache` Artisan 命令來預編譯應用程序使用的所有視圖。為了提高性能，你可能希望在部署過程中運行此命令：

```shell
php artisan view:cache
```

你可以使用 `view:clear` 命令清除視圖緩存：

```shell
php artisan view:clear
```
