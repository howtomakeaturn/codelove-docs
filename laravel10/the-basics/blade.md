# Blade 模板

- [簡介](#introduction)
    - [用 Livewire 為 Blade 賦能](#supercharging-blade-with-livewire)
- [數據顯示](#displaying-data)
    - [HTML 實體編碼](#html-entity-encoding)
    - [Blade 與 JavaScript 框架](#blade-and-javascript-frameworks)
- [Blade 指令](#blade-directives)
    - [If 語句](#if-statements)
    - [Switch 語句](#switch-statements)
    - [循環](#loops)
    - [循環變量](#the-loop-variable)
    - [條件類](#conditional-classes)
    - [附加屬性](#additional-attributes)
    - [包括子視圖](#including-subviews)
    - [`@once` 指令](#the-once-directive)
    - [原始 PHP 語法](#raw-php)
    - [注釋](#comments)
- [組件](#components)
    - [渲染組件](#rendering-components)
    - [組件傳參](#passing-data-to-components)
    - [組件屬性](#component-attributes)
    - [保留關鍵字](#reserved-keywords)
    - [插槽](#slots)
    - [內聯組件視圖](#inline-component-views)
    - [動態組件](#dynamic-components)
    - [手動注冊組件](#manually-registering-components)
- [匿名組件](#anonymous-components)
    - [匿名索引組件](#anonymous-index-components)
    - [數據特性/屬性](#data-properties-attributes)
    - [訪問父級數據](#accessing-parent-data)
    - [匿名組件路徑](#anonymous-component-paths)
- [創建布局](#building-layouts)
    - [使用組件的布局](#layouts-using-components)
    - [使用模板繼承的布局](#layouts-using-template-inheritance)
- [表單](#forms)
    - [CSRF 字段](#csrf-field)
    - [Method 字段](#method-field)
    - [驗證錯誤](#validation-errors)
- [堆棧](#stacks)
- [服務注入](#service-injection)
- [渲染 Blade 模板](#rendering-blade-templates)
- [Blade 擴展](#extending-blade)
    - [自定義 Echo 處理](#custom-echo-handlers)
    - [自定義 if 語句](#custom-if-statements)

<a name="introduction"></a>
## 簡介

Blade 是 Laravel 提供的一個簡單而又強大的模板引擎。 和其他流行的 PHP 模板引擎不同，Blade 並不限制你在視圖中使用原生 PHP 代碼。實際上，所有 Blade 視圖文件都將被編譯成原生的 PHP 代碼並緩存起來，除非它被修改，否則不會重新編譯，這就意味著 Blade 基本上不會給你的應用增加任何負擔。Blade 模板文件使用 `.blade.php` 作為文件擴展名，被存放在 `resources/views` 目錄。



Blade 視圖可以使用全局 `view` 函數從 Route 或控制器返回。當然，正如有關 [views](/docs/laravel/10.x/views) 的文檔中所描述的，可以使用 `view` 函數的第二個參數將數據傳遞到 Blade 視圖：

    Route::get('/', function () {
        return view('greeting', ['name' => 'Finn']);
    });

<a name="supercharging-blade-with-livewire"></a>
### 用 Livewire 為 Blade 賦能

想讓你的 Blade 模板更上一層樓，輕松構建動態界面嗎？看看[Laravel Livewire](https://laravel-livewire.com)。Livewire 允許你編寫 Blade 組件，這些組件具有動態功能，通常只能通過 React 或 Vue 等前端框架來實現，這提供了一個很好的方法來構建現代，沒有覆雜前端映射，基於客戶端渲染，無須很多的構建步驟的  JavaScript 框架。


<a name="displaying-data"></a>
## 顯示數據

你可以把變量置於花括號中以在視圖中顯示數據。例如，給定下方的路由：

    Route::get('/', function () {
        return view('welcome', ['name' => 'Samantha']);
    });

你可以像如下這樣顯示 `name` 變量的內容：

```blade
Hello, {{ $name }}.
```

> **技巧**：Blade 的 `{{ }}` 語句將被 PHP 的 `htmlspecialchars` 函數自動轉義以防範 XSS 攻擊。

你不僅限於顯示傳遞給視圖的變量的內容。你也可以回顯任何 PHP 函數的結果。實際上，你可以將所需的任何 PHP 代碼放入 Blade echo 語句中：

```blade
The current UNIX timestamp is {{ time() }}.
```

<a name="html-entity-encoding"></a>
### HTML 實體編碼



默認情況下，Blade（和 Laravel `e` 助手）將對 HTML 實體進行雙重編碼。如果你想禁用雙重編碼，請從 `AppServiceProvider` 的 `boot` 方法調用 `Blade::withoutDoubleEncoding` 方法：

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Blade;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Bootstrap any application services.
         */
        public function boot(): void
        {
            Blade::withoutDoubleEncoding();
        }
    }

<a name="displaying-unescaped-data"></a>
#### 展示非轉義數據

默認情況下， Blade `{{ }}` 語句將被 PHP 的 `htmlspecialchars` 函數自動轉義以防範 XSS 攻擊。如果不想你的數據被轉義，那麽你可使用如下的語法：

```blade
Hello, {!! $name !!}.
```

> **注意：**在應用中顯示用戶提供的數據時請格外小心，請盡可能的使用轉義和雙引號語法來防範 XSS 攻擊。

<a name="blade-and-javascript-frameworks"></a>
### Blade & JavaScript 框架

由於許多 JavaScript 框架也使用「花括號」來標識將顯示在瀏覽器中的表達式，因此，你可以使用 `@` 符號來表示 Blade 渲染引擎應當保持不變。例如：

```blade
<h1>Laravel</h1>

Hello, @{{ name }}.
```

在這個例子中， `@` 符號將被 Blade 移除；當然，Blade 將不會修改 `{{ name }}` 表達式，取而代之的是 JavaScript 模板來對其進行渲染。

`@` 符號也用於轉義 Blade 指令：

```blade
{{-- Blade template --}}
@@if()

<!-- HTML output -->
@if()
```

<a name="rendering-json"></a>
#### 渲染 JSON

有時，你可能會將數組傳遞給視圖，以將其呈現為 JSON，以便初始化 JavaScript 變量。 例如：

```blade
<script>
    var app = <?php echo json_encode($array); ?>;
</script>
```



或者，你可以使用 `Illuminate\Support\Js::from` 方法指令，而不是手動調用 `json_encode`。 `from` 方法接受與 PHP 的 `json_encode` 函數相同的參數；但是，它將確保正確轉義生成的 JSON 以包含在 HTML 引號中。 `from` 方法將返回一個字符串 `JSON.parse` JavaScript 語句，它將給定對象或數組轉換為有效的 JavaScript 對象：

```blade
<script>
    var app = {{ Illuminate\Support\Js::from($array) }};
</script>
```

Laravel 框架的最新版本包括一個 `Js` 門面，它提供了在 Blade 模板中方便地訪問此功能：

```blade
<script>
    var app = {{ Js::from($array) }};
</script>
```

> **注意：**你應該只使用 `Js::from` 渲染已經存在的變量為 JSON。 Blade 模板基於正則表達式，如果嘗試將覆雜表達式傳遞給 `Js::from` 可能會導致無法預測的錯誤。

<a name="the-at-verbatim-directive"></a>
#### `@verbatim` 指令

如果你在模板中顯示很大一部分 JavaScript 變量，你可以將 HTML 嵌入到 `@verbatim` 指令中，這樣，你就不需要在每一個 Blade 回顯語句前添加 `@` 符號：

```blade
@verbatim
    <div class="container">
        Hello, {{ name }}.
    </div>
@endverbatim
```

<a name="blade-directives"></a>
## Blade 指令

除了模板繼承和顯示數據以外， Blade 還為常見的 PHP 控制結構提供了便捷的快捷方式，例如條件語句和循環。這些快捷方式為 PHP 控制結構提供了一個非常清晰、簡潔的書寫方式，同時，還與 PHP 中的控制結構保持了相似的語法特性。



<a name="if-statements"></a>
### If 語句

你可以使用 `@if` ， `@elseif` ， `@else` 和 `@endif` 指令構造 `if` 語句。這些指令功能與它們所對應的 PHP 語句完全一致：

```blade
@if (count($records) === 1)
    有一條記錄
@elseif (count($records) > 1)
    有多條記錄
@else
    沒有記錄
@endif
```

為了方便， Blade 還提供了一個 `@unless` 指令：

```blade
@unless (Auth::check())
    你還沒有登錄
@endunless
```

> 譯注：相當於 `@if (! Auth::check()) @endif`

除了上面所說條件指令外， `@isset` 和 `@empty` 指令亦可作為它們所對應的 PHP 函數的快捷方式：

```blade
@isset($records)
    // $records 已經被定義且不為 null ……
@endisset

@empty($records)
    // $records 為「空」……
@endempty
```

<a name="authentication-directives"></a>
#### 授權指令

`@auth` 和 `@guest` 指令可用於快速判斷當前用戶是否已經獲得 [授權](/docs/laravel/10.x/authentication) 或是遊客：

```blade
@auth
    // 用戶已經通過認證……
@endauth

@guest
    // 用戶沒有通過認證……
@endguest
```

如有需要，你亦可在使用 `@auth` 和 `@guest` 指令時指定 [認證守衛](https://learnku.com/docs/laravel/10.x/authentication "認證守衛")：

```blade
@auth('admin')
    // 用戶已經通過認證...
@endauth

@guest('admin')
    // 用戶沒有通過認證...
@endguest
```

<a name="environment-directives"></a>
#### 環境指令

你可以使用 `@production` 指令來判斷應用是否處於生產環境：

```blade
@production
    // 生產環境特定內容...
@endproduction
```

或者，你可以使用 `@env` 指令來判斷應用是否運行於指定的環境：

```blade
@env('staging')
    //  應用運行於「staging」環境...
@endenv

@env(['staging', 'production'])
    // 應用運行於 「staging」或 [生產] 環境...
@endenv
```



<a name="section-directives"></a>
#### 區塊指令

你可以使用 `@hasSection` 指令來判斷區塊是否有內容：

```blade
@hasSection('navigation')
    <div class="pull-right">
        @yield('navigation')
    </div>

    <div class="clearfix"></div>
@endif
```

你可以使用 `sectionMissing` 指令來判斷區塊是否沒有內容：

```blade
@sectionMissing('navigation')
    <div class="pull-right">
        @include('default-navigation')
    </div>
@endif
```

<a name="switch-statements"></a>
### Switch 語句

你可使用 `@switch` ， `@case` ， `@break` ， `@default` 和 `@endswitch` 語句來構造 Switch 語句：

```blade
@switch($i)
    @case(1)
        First case...
        @break

    @case(2)
        Second case...
        @break

    @default
        Default case...
@endswitch
```

<a name="loops"></a>
### 循環

除了條件語句， Blade 還提供了與 PHP 循環結構功能相同的指令。同樣，這些語句的功能和它們所對應的 PHP 語法一致：

```blade
@for ($i = 0; $i < 10; $i++)
    The current value is {{ $i }}
@endfor

@foreach ($users as $user)
    <p>This is user {{ $user->id }}</p>
@endforeach

@forelse ($users as $user)
    <li>{{ $user->name }}</li>
@empty
    <p>No users</p>
@endforelse

@while (true)
    <p>I'm looping forever.</p>
@endwhile
```

> **技巧：**在遍歷 `foreach` 循環時，你可以使用 [循環變量](#the-loop-variable) 去獲取有關循環的有價值的信息，例如，你處於循環的第一個叠代亦或是處於最後一個叠代。

使用循環時，還可以使用 `@continue` 和 `@break` 循環或跳過當前叠代：

```blade
@foreach ($users as $user)
    @if ($user->type == 1)
        @continue
    @endif

    <li>{{ $user->name }}</li>

    @if ($user->number == 5)
        @break
    @endif
@endforeach
```

你還可以在指令聲明中包含繼續或中斷條件：

```blade
@foreach ($users as $user)
    @continue($user->type == 1)

    <li>{{ $user->name }}</li>

    @break($user->number == 5)
@endforeach
```



<a name="the-loop-variable"></a>
### Loop 變量

在遍歷 `foreach` 循環時，循環內部可以使用 `$loop` 變量。該變量提供了訪問一些諸如當前的循環索引和此次叠代是首次或是末次這樣的信息的方式：

```blade
@foreach ($users as $user)
    @if ($loop->first)
        This is the first iteration.
    @endif

    @if ($loop->last)
        This is the last iteration.
    @endif

    <p>This is user {{ $user->id }}</p>
@endforeach
```

如果你處於嵌套循環中，你可以使用循環的 `$loop` 變量的 `parent` 屬性訪問父級循環：

```blade
@foreach ($users as $user)
    @foreach ($user->posts as $post)
        @if ($loop->parent->first)
            This is the first iteration of the parent loop.
        @endif
    @endforeach
@endforeach
```

該 `$loop` 變量還包含各種各樣有用的屬性：

屬性  | 描述
------------- | -------------
`$loop->index`  |  當前叠代的索引（從 0 開始）。
`$loop->iteration`  |  當前循環的叠代次數（從 1 開始）。
`$loop->remaining`  |  循環剩余的叠代次數。
`$loop->count`  |  被叠代的數組的元素個數。
`$loop->first`  |  當前叠代是否是循環的首次叠代。
`$loop->last`  |  當前叠代是否是循環的末次叠代。
`$loop->even`  |  當前循環的叠代次數是否是偶數。
`$loop->odd`  |  當前循環的叠代次數是否是奇數。
`$loop->depth`  |  當前循環的嵌套深度。
`$loop->parent`  |  嵌套循環中的父級循環。

<a name="conditional-classes"></a>
### 有條件地編譯 class 樣式



該 `@class` 指令有條件地編譯 CSS class 樣式。該指令接收一個數組，其中數組的鍵包含你希望添加的一個或多個樣式的類名，而值是一個布爾表達式。如果數組元素有一個數值的鍵，它將始終包含在呈現的 class 列表中：

```blade
@php
    $isActive = false;
    $hasError = true;
@endphp

<span @class([
    'p-4',
    'font-bold' => $isActive,
    'text-gray-500' => ! $isActive,
    'bg-red' => $hasError,
])></span>

<span class="p-4 text-gray-500 bg-red"></span>
```

同樣，`@style` 指令可用於有條件地將內聯 CSS 樣式添加到一個 HTML 元素中。

```blade
@php
    $isActive = true;
@endphp

<span @style([
    'background-color: red',
    'font-weight: bold' => $isActive,
])></span>

<span style="background-color: red; font-weight: bold;"></span>
```

<a name="additional-attributes"></a>
### 附加屬性

為方便起見，你可以使用該 `@checked` 指令輕松判斷給定的 HTML 覆選框輸入是否被「選中（checked）」。如果提供的條件判斷為 `true` ，則此指令將回顯 `checked`：

```blade
<input type="checkbox"
        name="active"
        value="active"
        @checked(old('active', $user->active)) />
```

同樣，該 `@selected` 指令可用於判斷給定的選項是否被「選中（selected）」：

```blade
<select name="version">
    @foreach ($product->versions as $version)
        <option value="{{ $version }}" @selected(old('version') == $version)>
            {{ $version }}
        </option>
    @endforeach
</select>
```

此外，該 `@disabled` 指令可用於判斷給定元素是否為「禁用（disabled）」:

```blade
<button type="submit" @disabled($errors->isNotEmpty())>Submit</button>
```

此外，`@readonly` 指令可以用來指示某個元素是否應該是「只讀 （readonly）」的。

```blade
<input type="email"
        name="email"
        value="email@laravel.com"
        @readonly($user->isNotAdmin()) />
```



此外，`@required` 指令可以用來指示一個給定的元素是否應該是「必需的（required）」。

```blade
<input type="text"
        name="title"
        value="title"
        @required($user->isAdmin()) />
```

<a name="including-subviews"></a>
### 包含子視圖

> **技巧：**雖然你可以自由使用該 `@include` 指令，但是 Blade [組件](#components) 提供了類似的功能，並提供了優於該 `@include` 指令的功能，如數據和屬性綁定。

Blade 的 `@include` 指令允許你從一個視圖中包含另外一個 Blade 視圖。父視圖中的所有變量在子視圖中都可以使用：

```blade
<div>
    @include('shared.errors')

    <form>
        <!-- Form Contents -->
    </form>
</div>
```

盡管子視圖可以繼承父視圖中所有可以使用的數據，但是你也可以傳遞一個額外的數組，這個數組在子視圖中也可以使用:

```blade
@include('view.name', ['status' => 'complete'])
```

如果你想要使用 `@include` 包含一個不存在的視圖，Laravel 將會拋出一個錯誤。如果你想要包含一個可能存在也可能不存在的視圖，那麽你應該使用 `@includeIf` 指令:

```blade
@includeIf('view.name', ['status' => 'complete'])
```

如果想要使用 `@include`  包含一個給定值為 `true` 或 `false`的布爾表達式的視圖，那麽你可以使用 `@includeWhen` 和 `@includeUnless` 指令:

```blade
@includeWhen($boolean, 'view.name', ['status' => 'complete'])

@includeUnless($boolean, 'view.name', ['status' => 'complete'])
```

如果想要包含一個視圖數組中第一個存在的視圖，你可以使用 `includeFirst` 指令:

```blade
@includeFirst(['custom.admin', 'admin'], ['status' => 'complete'])
```

> **注意：**在視圖中，你應該避免使用 `__DIR__` 和 `__FILE__` 這些常量，因為他們將引用已緩存的和已編譯的視圖。



<a name="rendering-views-for-collections"></a>
#### 為集合渲染視圖

你可以使用 Blade 的 `@each` 指令將循環合並在一行內：

```blade
@each('view.name', $jobs, 'job')
```

該 `@each` 指令的第一個參數是數組或集合中的元素的要渲染的視圖片段。第二個參數是你想要叠代的數組或集合，當第三個參數是一個表示當前叠代的視圖的變量名。因此，如果你遍歷一個名為 `jobs` 的數組，通常會在視圖片段中使用 `job` 變量來訪問每一個 job （jobs 數組的元素）。在你的視圖片段中，可以使用 `key` 變量來訪問當前叠代的鍵。

你亦可傳遞第四個參數給 `@each` 指令。當給定的數組為空時，將會渲染該參數所對應的視圖。

```blade
@each('view.name', $jobs, 'job', 'view.empty')
```

> **注意：**通過 `@each` 指令渲染的視圖不會繼承父視圖的變量。如果子視圖需要使用這些變量，你可以使用 `@foreach` 和 `@include` 來代替它。

<a name="the-once-directive"></a>
### `@once` 指令

該 `@once` 指令允許你定義模板的一部分內容，這部分內容在每一個渲染周期中只會被計算一次。該指令在使用 [堆棧](#stacks) 推送一段特定的 JavaScript 代碼到頁面的頭部環境下是很有用的。例如，如果你想要在循環中渲染一個特定的 [組件](#components) ，你可能希望僅在組件渲染的首次推送 JavaScript 代碼到頭部：

```blade
@once
    @push('scripts')
        <script>
            // 你自定義的 JavaScript 代碼...
        </script>
    @endpush
@endonce
```



由於該 `@once` 指令經常與 `@push` 或 `@prepend` 指令一起使用，為了使用方便，我們提供了 `@pushOnce` 和 `@prependOnce` 指令：

```blade
@pushOnce('scripts')
    <script>
        // 你自定義的 JavaScript 代碼...
    </script>
@endPushOnce
```

<a name="raw-php"></a>
### 原始 PHP 語法

在許多情況下，嵌入 PHP 代碼到你的視圖中是很有用的。你可以在模板中使用 Blade 的 `@php` 指令執行原生的 PHP 代碼塊：

```blade
@php
    $counter = 1;
@endphp
```

如果只需要寫一條 PHP 語句，可以在 `@php` 指令中包含該語句。

```blade
@php($counter = 1)
```

<a name="comments"></a>
### 注釋

Blade 也允許你在視圖中定義注釋。但是，和 HTML 注釋不同， Blade 注釋不會被包含在應用返回的 HTML 中：

```blade
{{-- 這個注釋將不會出現在渲染的HTML中。 --}}
```

<a name="components"></a>
## 組件

組件和插槽的作用與區塊和布局的作用一致；不過，有些人可能覺著組件和插槽更易於理解。有兩種書寫組件的方法：基於類的組件和匿名組件。

你可以使用 `make:component` Artisan 命令來創建一個基於類的組件。我們將會創建一個簡單的  `Alert` 組件用於說明如何使用組件。該 `make:component` 命令將會把組件置於 `App\View\Components` 目錄中：

```shell
php artisan make:component Alert
```

該 `make:component` 命令將會為組件創建一個視圖模板。創建的視圖被置於 `resources/views/components` 目錄中。在為自己的應用程序編寫組件時，會在 `app/View/Components` 目錄和 `resources/views/components` 目錄中自動發現組件，因此通常不需要進一步的組件注冊。



你還可以在子目錄中創建組件：

```shell
php artisan make:component Forms/Input
```

上面的命令將在目錄中創建一個 `Input` 組件， `App\View\Components\Forms` 視圖將放置在 `resources/views/components/forms` 目錄中。

如果你想創建一個匿名組件（一個只有 Blade 模板並且沒有類的組件），你可以在調用命令  `make:component` 使用該 `--view` 標志：

```shell
php artisan make:component forms.input --view
```

上面的命令將在 `resources/views/components/forms/input.blade.php`創建一個 Blade 文件，該文件中可以通過 `<x-forms.input />`作為組件呈現。

<a name="manually-registering-package-components"></a>
#### 手動注冊包組件

當為你自己的應用編寫組件的時候，Laravel 將會自動發現位於 `app/View/Components` 目錄和 `resources/views/components` 目錄中的組件。

當然，如果你使用 Blade 組件編譯一個包，你可能需要手動注冊組件類及其 HTML 標簽別名。你應該在包的服務提供者的 `boot` 方法中注冊你的組件：

    use Illuminate\Support\Facades\Blade;

    /**
     * 注冊你的包的服務
     */
    public function boot(): void
    {
        Blade::component('package-alert', Alert::class);
    }

當組件注冊完成後，便可使用標簽別名來對其進行渲染。

```blade
<x-package-alert/>
```

或者，你可以使用該 `componentNamespace` 方法按照約定自動加載組件類。例如，一個 `Nightshade` 包可能有 `Calendar` 和 `ColorPicker` 組件駐留在 `Package\Views\Components` 命名空間中：

    use Illuminate\Support\Facades\Blade;

    /**
     * 注冊你的包的服務
     */
    public function boot(): void
    {
        Blade::componentNamespace('Nightshade\\Views\\Components', 'nightshade');
    }



這將允許他們的供應商命名空間使用包組件，使用以下 `package-name::` 語法：

```blade
<x-nightshade::calendar />
<x-nightshade::color-picker />
```

Blade 將自動檢測鏈接到該組件的類，通過對組件名稱進行帕斯卡大小寫。使用「點」表示法也支持子目錄。

<a name="rendering-components"></a>
### 顯示組件

要顯示一個組件，你可以在 Blade 模板中使用 Blade 組件標簽。 Blade 組件以  `x-` 字符串開始，其後緊接組件類 kebab case 形式的名稱（即單詞與單詞之間使用短橫線 `-` 進行連接）：

```blade
<x-alert/>

<x-user-profile/>
```

如果組件位於 `App\View\Components` 目錄的子目錄中，你可以使用 `.` 字符來指定目錄層級。例如，假設我們有一個組件位於 `App\View\Components\Inputs\Button.php`，那麽我們可以像這樣渲染它：

```blade
<x-inputs.button/>
```

如果你想有條件地渲染你的組件，你可以在你的組件類上定義一個 `shouldRender` 方法。如果 `shouldRender` 方法返回 `false`，該組件將不會被渲染。

    use Illuminate\Support\Str;

    /**
     * 該組件是否應該被渲染
     */
    public function shouldRender(): bool
    {
        return Str::length($this->message) > 0;
    }

<a name="passing-data-to-components"></a>
### 傳遞數據到組件中

你可以使用 HTML 屬性傳遞數據到 Blade 組件中。普通的值可以通過簡單的 HTML 屬性來傳遞給組件。PHP 表達式和變量應該通過以 `:` 字符作為前綴的變量來進行傳遞：

```blade
<x-alert type="error" :message="$message"/>
```

你應該在類的構造器中定義組件的必要數據。在組件的視圖中，組件的所有 public 類型的屬性都是可用的。不必通過組件類的 `render` 方法傳遞：

    <?php

    namespace App\View\Components;

    use Illuminate\View\Component;
    use Illuminate\View\View;

    class Alert extends Component
    {
        /**
         * 創建組件實例。
         */
        public function __construct(
            public string $type,
            public string $message,
        ) {}

        /**
         * 獲取代表該組件的視圖/內容
         */
        public function render(): View
        {
            return view('components.alert');
        }
    }



渲染組件時，你可以回顯變量名來顯示組件的 public 變量的內容：

```blade
<div class="alert alert-{{ $type }}">
    {{ $message }}
</div>
```

<a name="casing"></a>
#### 命名方式（Casing）

組件的構造器的參數應該使用 `駝峰式` 類型，在 HTML 屬性中引用參數名時應該使用 `短橫線隔開式 kebab-case ：單詞與單詞之間使用短橫線 - 進行連接）` 。例如，給定如下的組件構造器：

    /**
     * 創建一個組件實例
     */
    public function __construct(
        public string $alertType,
    ) {}

`$alertType`  參數可以像這樣使用：

```blade
<x-alert alert-type="danger" />
```

<a name="short-attribute-syntax"></a>
#### 短屬性語法/省略屬性語法

當向組件傳遞屬性時，你也可以使用「短屬性語法/省略屬性語法」（省略屬性書寫）。這通常很方便，因為屬性名稱經常與它們對應的變量名稱相匹配。

```blade
{{-- 短屬性語法/省略屬性語法... --}}
<x-profile :$userId :$name />

{{-- 等價於... --}}
<x-profile :user-id="$userId" :name="$name" />
```

<a name="escaping-attribute-rendering"></a>
#### 轉義屬性渲染

因為一些 JavaScript 框架，例如 Alpine.js 還可以使用冒號前綴屬性，你可以使用雙冒號 (`::`) 前綴通知 Blade 屬性不是 PHP 表達式。例如，給定以下組件：

```blade
<x-button ::class="{ danger: isDeleting }">
    Submit
</x-button>
```

Blade 將渲染出以下 HTML 內容：

```blade
<button :class="{ danger: isDeleting }">
    Submit
</button>
```

<a name="component-methods"></a>
#### #### 組件方法

除了組件模板可用的公共變量外，還可以調用組件上的任何公共方法。例如，假設一個組件有一個 `isSelected` 方法：

    /**
     * 確定給定選項是否為當前選定的選項。
     */
    public function isSelected(string $option): bool
    {
        return $option === $this->selected;
    }



你可以通過調用與方法名稱匹配的變量，從組件模板執行此方法：

```blade
<option {{ $isSelected($value) ? 'selected' : '' }} value="{{ $value }}">
    {{ $label }}
</option>
```

<a name="using-attributes-slots-within-component-class"></a>
#### 訪問組件類中的屬性和插槽

Blade 組件還允許你訪問類的 render 方法中的組件名稱、屬性和插槽。但是，為了訪問這些數據，應該從組件的 `render` 方法返回閉包。閉包將接收一個  `$data` 數組作為它的唯一參數。此數組將包含幾個元素，這些元素提供有關組件的信息：

    use Closure;

    /**
     * 獲取表示組件的視圖 / 內容
     */
    public function render(): Closure
    {
        return function (array $data) {
            // $data['componentName'];
            // $data['attributes'];
            // $data['slot'];

            return '<div>Components content</div>';
        };
    }

`componentName` 等於 `x-` 前綴後面的 HTML 標記中使用的名稱。所以 `<x-alert />` 的 `componentName` 將是 `alert` 。 `attributes` 元素將包含 HTML 標記上的所有屬性。 `slot` 元素是一個 `Illuminate\Support\HtmlString`實例，包含組件的插槽內容。

閉包應該返回一個字符串。如果返回的字符串與現有視圖相對應，則將呈現該視圖；否則，返回的字符串將作為內聯 Blade 視圖進行計算。

<a name="additional-dependencies"></a>
#### 附加依賴項

如果你的組件需要引入來自 Laravel 的 [服務容器](/docs/laravel/10.x/container)的依賴項，你可以在組件的任何數據屬性之前列出這些依賴項，這些依賴項將由容器自動注入：

```php
use App\Services\AlertCreator;

/**
 * 創建組件實例
 */
public function __construct(
    public AlertCreator $creator,
    public string $type,
    public string $message,
) {}
```



<a name="hiding-attributes-and-methods"></a>
#### 隱藏屬性/方法

如果要防止某些公共方法或屬性作為變量公開給組件模板，可以將它們添加到組件的 `$except` 數組屬性中：

    <?php

    namespace App\View\Components;

    use Illuminate\View\Component;

    class Alert extends Component
    {
        /**
         * 不應向組件模板公開的屬性/方法。
         *
         * @var array
         */
        protected $except = ['type'];

        /**
         * Create the component instance.
         */
        public function __construct(
            public string $type,
        ) {}
    }

<a name="component-attributes"></a>
### 組件屬性

我們已經研究了如何將數據屬性傳遞給組件；但是，有時你可能需要指定額外的 HTML 屬性，例如  `class`，這些屬性不是組件運行所需的數據的一部分。通常，你希望將這些附加屬性向下傳遞到組件模板的根元素。例如，假設我們要呈現一個 `alert` 組件，如下所示：

```blade
<x-alert type="error" :message="$message" class="mt-4"/>
```

所有不屬於組件的構造器的屬性都將被自動添加到組件的「屬性包」中。該屬性包將通過 `$attributes` 變量自動傳遞給組件。你可以通過回顯這個變量來渲染所有的屬性：

```blade
<div {{ $attributes }}>
    <!-- 組件內容 -->
</div>
```

> **注意：**此時不支持在組件中使用諸如 `@env` 這樣的指令。例如， `<x-alert :live="@env('production')"/>` 不會被編譯。

<a name="default-merged-attributes"></a>
#### 默認 / 合並屬性

某些時候，你可能需要指定屬性的默認值，或將其他值合並到組件的某些屬性中。為此，你可以使用屬性包的 `merge`方法。 此方法對於定義一組應始終應用於組件的默認 CSS 類特別有用：

```blade
<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>
```



假設我們如下方所示使用該組件：

```blade
<x-alert type="error" :message="$message" class="mb-4"/>
```

最終呈現的組件 HTML 將如下所示：

```blade
<div class="alert alert-error mb-4">
    <!-- Contents of the $message variable -->
</div>
```

<a name="conditionally-merge-classes"></a>
#### 有條件地合並類

有時你可能希望在給定條件為 `true` 時合並類。 你可以通過該 `class` 方法完成此操作，該方法接受一個類數組，其中數組鍵包含你希望添加的一個或多個類，而值是一個布爾表達式。如果數組元素有一個數字鍵，它將始終包含在呈現的類列表中：

```blade
<div {{ $attributes->class(['p-4', 'bg-red' => $hasError]) }}>
    {{ $message }}
</div>
```

如果需要將其他屬性合並到組件中，可以將 `merge` 方法鏈接到 `class` 方法中：

```blade
<button {{ $attributes->class(['p-4'])->merge(['type' => 'button']) }}>
    {{ $slot }}
</button>
```

> **技巧：**如果你需要有條件地編譯不應接收合並屬性的其他 HTML 元素上的類，你可以使用 [`@class` 指令](#conditional-classes)。

<a name="non-class-attribute-merging"></a>
#### 非 class 屬性的合並

當合並非 `class` 屬性的屬性時，提供給 `merge` 方法的值將被視為該屬性的「default」值。但是，與 `class` 屬性不同，這些屬性不會與注入的屬性值合並。相反，它們將被覆蓋。例如， `button` 組件的實現可能如下所示：

```blade
<button {{ $attributes->merge(['type' => 'button']) }}>
    {{ $slot }}
</button>
```



若要使用自定義 `type` 呈現按鈕組件，可以在使用該組件時指定它。如果未指定 `type`，則將使用 `button` 作為 type 值：

```blade
<x-button type="submit">
    Submit
</x-button>
```

本例中 `button` 組件渲染的 HTML 為：

```blade
<button type="submit">
    Submit
</button>
```

如果希望 `class` 以外的屬性將其默認值和注入值連接在一起，可以使用 `prepends` 方法。在本例中， `data-controller` 屬性始終以 `profile-controller` 開頭，並且任何其他注入 `data-controller` 的值都將放在該默認值之後：

```blade
<div {{ $attributes->merge(['data-controller' => $attributes->prepends('profile-controller')]) }}>
    {{ $slot }}
</div>
```

<a name="filtering-attributes"></a>
#### 保留屬性 / 過濾屬性

可以使用 `filter` 方法篩選屬性。如果希望在屬性包中保留屬性，此方法接受應返回 `true` 的閉包：

```blade
{{ $attributes->filter(fn (string $value, string $key) => $key == 'foo') }}
```

為了方便起見，你可以使用 `whereStartsWith` 方法檢索其鍵以給定字符串開頭的所有屬性：

```blade
{{ $attributes->whereStartsWith('wire:model') }}
```

相反，該 `whereDoesntStartWith` 方法可用於排除鍵以給定字符串開頭的所有屬性：

```blade
{{ $attributes->whereDoesntStartWith('wire:model') }}
```

使用 `first` 方法，可以呈現給定屬性包中的第一個屬性：

```blade
{{ $attributes->whereStartsWith('wire:model')->first() }}
```

如果要檢查組件上是否存在屬性，可以使用 `has` 方法。此方法接受屬性名稱作為其唯一參數，並返回一個布爾值，指示該屬性是否存在：

```blade
@if ($attributes->has('class'))
    <div>Class attribute is present</div>
@endif
```



你可以使用 `get` 方法檢索特定屬性的值：

```blade
{{ $attributes->get('class') }}
```

<a name="reserved-keywords"></a>
### 保留關鍵字

默認情況下，為了渲染組件，會保留一些關鍵字供 Blade 內部使用。以下關鍵字不能定義為組件中的公共屬性或方法名稱：

<div class="content-list" markdown="1">

- `data`
- `render`
- `resolveView`
- `shouldRender`
- `view`
- `withAttributes`
- `withName`

</div>

<a name="slots"></a>
### 插槽

你通常需要通過「插槽」將其他內容傳遞給組件。通過回顯 `$slot` 變量來呈現組件插槽。為了探索這個概念，我們假設 `alert` 組件具有以下內容：

```blade
<!-- /resources/views/components/alert.blade.php -->

<div class="alert alert-danger">
    {{ $slot }}
</div>
```

我們可以通過向組件中注入內容將內容傳遞到 `slot` ：

```blade
<x-alert>
    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```

有時候一個組件可能需要在它內部的不同位置放置多個不同的插槽。我們來修改一下 alert 組件，使其允許注入 「title」:

```blade
<!-- /resources/views/components/alert.blade.php -->

<span class="alert-title">{{ $title }}</span>

<div class="alert alert-danger">
    {{ $slot }}
</div>
```

你可以使用 `x-slot` 標簽來定義命名插槽的內容。任何沒有在 `x-slot` 標簽中的內容都將傳遞給  `$slot` 變量中的組件：

```xml
<x-alert>
    <x-slot:title>
        Server Error
    </x-slot>

    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```

<a name="scoped-slots"></a>
#### 作用域插槽

如果你使用諸如 Vue 這樣的 JavaScript 框架，那麽你應該很熟悉「作用域插槽」，它允許你從插槽中的組件訪問數據或者方法。 Laravel 中也有類似的用法，只需在你的組件中定義 public 方法或屬性，並且使用 `$component` 變量來訪問插槽中的組件。在此示例中，我們將假設組件在其組件類上定義了 `x-alert` 一個公共方法： `formatAlert`

```blade
<x-alert>
    <x-slot:title>
        {{ $component->formatAlert('Server Error') }}
    </x-slot>

    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```



<a name="slot-attributes"></a>
#### 插槽屬性

像 Blade 組件一樣，你可以為插槽分配額外的 [屬性](#component-attributes) ，例如 CSS 類名：

```xml
<x-card class="shadow-sm">
    <x-slot:heading class="font-bold">
        Heading
    </x-slot>

    Content

    <x-slot:footer class="text-sm">
        Footer
    </x-slot>
</x-card>
```

要與插槽屬性交互，你可以訪問 `attributes` 插槽變量的屬性。有關如何與屬性交互的更多信息，請參閱有關 [組件屬性](#component-attributes) 的文檔：

```blade
@props([
    'heading',
    'footer',
])

<div {{ $attributes->class(['border']) }}>
    <h1 {{ $heading->attributes->class(['text-lg']) }}>
        {{ $heading }}
    </h1>

    {{ $slot }}

    <footer {{ $footer->attributes->class(['text-gray-700']) }}>
        {{ $footer }}
    </footer>
</div>
```

<a name="inline-component-views"></a>
### 內聯組件視圖

對於小型組件而言，管理組件類和組件視圖模板可能會很麻煩。因此，你可以從 `render` 方法中返回組件的內容：

    /**
     * 獲取組件的視圖 / 內容。
     */
    public function render(): string
    {
        return <<<'blade'
            <div class="alert alert-danger">
                {{ $slot }}
            </div>
        blade;
    }

<a name="generating-inline-view-components"></a>
#### 生成內聯視圖組件

要創建一個渲染內聯視圖的組件，你可以在運行 `make:component` 命令時使用  `inline` ：

```shell
php artisan make:component Alert --inline
```

<a name="dynamic-components"></a>
### 動態組件

有時你可能需要渲染一個組件，但直到運行時才知道應該渲染哪個組件。在這種情況下, 你可以使用 Laravel 內置的 `dynamic-component` 組件, 根據運行時的值或變量來渲染組件:

```blade
<x-dynamic-component :component="$componentName" class="mt-4" />
```

<a name="manually-registering-components"></a>
### 手動注冊組件

> **注意：**以下關於手動注冊組件的文檔主要適用於那些正在編寫包含視圖組件的 Laravel 包的用戶。如果你不是在寫包，這一部分的組件文檔可能與你無關。



當為自己的應用程序編寫組件時，組件會在`app/View/Components`目錄和`resources/views/components`目錄下被自動發現。

但是，如果你正在建立一個利用 Blade 組件的包，或者將組件放在非傳統的目錄中，你將需要手動注冊你的組件類和它的 HTML 標簽別名，以便 Laravel 知道在哪里可以找到這個組件。你通常應該在你的包的服務提供者的`boot`方法中注冊你的組件：

    use Illuminate\Support\Facades\Blade;
    use VendorPackage\View\Components\AlertComponent;

    /**
     * 注冊你的包的服務。
     */
    public function boot(): void
    {
        Blade::component('package-alert', AlertComponent::class);
    }

一旦你的組件被注冊，它就可以使用它的標簽別名進行渲染。

```blade
<x-package-alert/>
```

#### 自動加載包組件

另外，你可以使用`componentNamespace`方法來自動加載組件類。例如，一個`Nightshade`包可能有`Calendar`和`ColorPicker`組件，它們位於`PackageViews\Components`命名空間中。

    use Illuminate\Support\Facades\Blade;

    /**
     * 注冊你的包的服務。
     */
    public function boot(): void
    {
        Blade::componentNamespace('Nightshade\\Views\\Components', 'nightshade');
    }

這將允許使用`package-name::`語法的供應商名稱空間來使用包的組件。

```blade
<x-nightshade::calendar />
<x-nightshade::color-picker />
```

Blade 將通過組件名稱的駝峰式大小寫 (pascal-casing) 自動檢測與該組件鏈接的類。也支持使用 "點 "符號的子目錄。

<a name="anonymous-components"></a>
### 匿名組件

與行內組件相同，匿名組件提供了一個通過單個文件管理組件的機制。然而，匿名組件使用的是一個沒有關聯類的單一視圖文件。要定義一個匿名組件，你只需將 Blade 模板置於 `resources/views/components` 目錄下。例如，假設你在 `resources/views/components/alert.blade.php`中定義了一個組件：

```blade
<x-alert/>
```


如果組件在 `components` 目錄的子目錄中，你可以使用 `.` 字符來指定其路徑。例如，假設組件被定義在 `resources/views/components/inputs/button.blade.php` 中，你可以像這樣渲染它：

```blade
<x-inputs.button/>
```

<a name="anonymous-index-components"></a>
#### 匿名索引組件

有時，當一個組件由許多 Blade 模板組成時，你可能希望將給定組件的模板分組到一個目錄中。例如，想象一個具有以下目錄結構的「可折疊」組件：

```none
/resources/views/components/accordion.blade.php
/resources/views/components/accordion/item.blade.php
```

此目錄結構允許你像這樣呈現組件及其項目：

```blade
<x-accordion>
    <x-accordion.item>
        ...
    </x-accordion.item>
</x-accordion>
```

然而，為了通過 `x-accordion` 渲染組件， 我們被迫將「索引」組件模板放置在 `resources/views/components` 目錄中，而不是與其他相關的模板嵌套在 `accordion` 目錄中。

幸運的是，Blade 允許你 `index.blade.php` 在組件的模板目錄中放置文件。當 `index.blade.php` 組件存在模板時，它將被呈現為組件的「根」節點。因此，我們可以繼續使用上面示例中給出的相同 Blade 語法；但是，我們將像這樣調整目錄結構：

```none
/resources/views/components/accordion/index.blade.php
/resources/views/components/accordion/item.blade.php
```

<a name="data-properties-attributes"></a>
#### 數據 / 屬性

由於匿名組件沒有任何關聯類，你可能想要區分哪些數據應該被作為變量傳遞給組件，而哪些屬性應該被存放於 [屬性包](#component-attributes)中。



你可以在組件的 Blade 模板的頂層使用 `@props` 指令來指定哪些屬性應該作為數據變量。組件中的其他屬性都將通過屬性包的形式提供。如果你想要為某個數據變量指定一個默認值，你可以將屬性名作為數組鍵，默認值作為數組值來實現：

```blade
<!-- /resources/views/components/alert.blade.php -->

@props(['type' => 'info', 'message'])

<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>
```

給定上面的組件定義，我們可以像這樣渲染組件：

```blade
<x-alert type="error" :message="$message" class="mb-4"/>
```

<a name="accessing-parent-data"></a>
#### 訪問父組件數據

有時你可能希望從子組件中的父組件訪問數據。在這些情況下，你可以使用該 `@aware` 指令。例如，假設我們正在構建一個由父 `<x-menu>` 和 子組成的覆雜菜單組件 `<x-menu.item>`：

```blade
<x-menu color="purple">
    <x-menu.item>...</x-menu.item>
    <x-menu.item>...</x-menu.item>
</x-menu>
```

該 `<x-menu>` 組件可能具有如下實現：

```blade
<!-- /resources/views/components/menu/index.blade.php -->

@props(['color' => 'gray'])

<ul {{ $attributes->merge(['class' => 'bg-'.$color.'-200']) }}>
    {{ $slot }}
</ul>
```

因為 `color` 只被傳遞到父級 (`<x-menu>`)中，所以 `<x-menu.item>` 在內部是不可用的。但是，如果我們使用該 `@aware` 指令，我們也可以使其在內部可用 `<x-menu.item>` ：

```blade
<!-- /resources/views/components/menu/item.blade.php -->

@aware(['color' => 'gray'])

<li {{ $attributes->merge(['class' => 'text-'.$color.'-800']) }}>
    {{ $slot }}
</li>
```

> **注意：**該 `@aware` 指令無法訪問未通過 HTML 屬性顯式傳遞給父組件的父數據。`@aware` 指令 不能訪問未顯式傳遞給父組件的默認值 `@props` 。


<a name="anonymous-component-paths"></a>
### 匿名組件路徑

如前所述，匿名組件通常是通過在你的`resources/views/components`目錄下放置一個 Blade 模板來定義的。然而，你可能偶爾想在 Laravel 注冊其他匿名組件的路徑，除了默認路徑。

`anonymousComponentPath`方法接受匿名組件位置的「路徑」作為它的第一個參數，並接受一個可選的「命名空間」作為它的第二個參數，組件應該被放在這個命名空間下。通常，這個方法應該從你的應用程序的一個[服務提供者](/docs/laravel/10.x/providers) 的`boot`方法中調用。

    /**
     * 引導任何應用服務。
     */
    public function boot(): void
    {
        Blade::anonymousComponentPath(__DIR__.'/../components');
    }

當組件路徑被注冊而沒有指定前綴時，就像上面的例子一樣，它們在你的 Blade 組件中可能也沒有相應的前綴。例如，如果一個`panel.blade.php`組件存在於上面注冊的路徑中，它可能會被呈現為這樣。

```blade
<x-panel />
```

前綴「命名空間」可以作為第二個參數提供給`anonymousComponentPath`方法。

    Blade::anonymousComponentPath(__DIR__.'/../components', 'dashboard');

當提供一個前綴時，在該「命名空間」內的組件可以在渲染時將該組件的命名空間前綴到該組件的名稱。

```blade
<x-dashboard::panel />
```

<a name="building-layouts"></a>
## 構建布局

<a name="layouts-using-components"></a>
### 使用組件布局

大多數 web 應用程序在不同的頁面上有相同的總體布局。如果我們必須在創建的每個視圖中重覆整個布局 HTML，那麽維護我們的應用程序將變得非常麻煩和困難。謝天謝地，將此布局定義為單個 [Blade 組件](#components) 並在整個應用程序中非常方便地使用它。


<a name="defining-the-layout-component"></a>
#### 定義布局組件

例如，假設我們正在構建一個「todo list」應用程序。我們可以定義如下所示的 `layout` 組件：

```blade
<!-- resources/views/components/layout.blade.php -->

<html>
    <head>
        <title>{{ $title ?? 'Todo Manager' }}</title>
    </head>
    <body>
        <h1>Todos</h1>
        <hr/>
        {{ $slot }}
    </body>
</html>
```

<a name="applying-the-layout-component"></a>
#### 應用布局組件

一旦定義了 `layout` 組件，我們就可以創建一個使用該組件的 Blade 視圖。在本例中，我們將定義一個顯示任務列表的簡單視圖：

```blade
<!-- resources/views/tasks.blade.php -->

<x-layout>
    @foreach ($tasks as $task)
        {{ $task }}
    @endforeach
</x-layout>
```

請記住，注入到組件中的內容將提供給 `layout` 組件中的默認 `$slot` 變量。正如你可能已經注意到的，如果提供了 `$title` 插槽，那麽我們的 `layout` 也會尊從該插槽；否則，將顯示默認的標題。我們可以使用組件文檔中討論的標準槽語法從任務列表視圖中插入自定義標題。 我們可以使用[組件文檔](#components)中討論的標準插槽語法從任務列表視圖中注入自定義標題：

```blade
<!-- resources/views/tasks.blade.php -->

<x-layout>
    <x-slot:title>
        Custom Title
    </x-slot>

    @foreach ($tasks as $task)
        {{ $task }}
    @endforeach
</x-layout>
```

現在我們已經定義了布局和任務列表視圖，我們只需要從路由中返回 `task` 視圖即可：

    use App\Models\Task;

    Route::get('/tasks', function () {
        return view('tasks', ['tasks' => Task::all()]);
    });

<a name="layouts-using-template-inheritance"></a>
### 使用模板繼承進行布局

<a name="defining-a-layout"></a>
#### 定義一個布局

布局也可以通過 「模板繼承」 創建。在引入 [組件](#components) 之前，這是構建應用程序的主要方法。



讓我們看一個簡單的例子做開頭。首先，我們將檢查頁面布局。由於大多數 web 應用程序在不同的頁面上保持相同的總體布局，因此將此布局定義為單一視圖非常方便：

```blade
<!-- resources/views/layouts/app.blade.php -->

<html>
    <head>
        <title>App Name - @yield('title')</title>
    </head>
    <body>
        @section('sidebar')
            這是一個主要的側邊欄
        @show

        <div class="container">
            @yield('content')
        </div>
    </body>
</html>
```

如你所見，此文件包含經典的 HTML 標記。但是，請注意 `@section` 和 `@yield` 指令。顧名思義， `@section` 指令定義內容的一部分，而 `@yield` 指令用於顯示給定部分的內容。

現在我們已經為應用程序定義了一個布局，讓我們定義一個繼承該布局的子頁面。

<a name="extending-a-layout"></a>
#### 繼承布局

定義子視圖時，請使用 `@extends` Blade 指令指定子視圖應「繼承」的布局。擴展 Blade 布局的視圖可以使用 `@section` 指令將內容注入布局的節點中。請記住，如上面的示例所示，這些部分的內容將使用 `@yield` 顯示在布局中：

```blade
<!-- resources/views/child.blade.php -->

@extends('layouts.app')

@section('title', 'Page Title')

@section('sidebar')
    @parent

    <p>This is appended to the master sidebar.</p>
@endsection

@section('content')
    <p>This is my body content.</p>
@endsection
```

在本例中，`sidebar` 部分使用 `@parent`  指令將內容追加（而不是覆蓋）到局部的側欄位置。在呈現視圖時， `@parent` 指令將被布局的內容替換。

> **技巧：**與前面的示例相反，本 `sidebar` 節以 `@endsection` 結束，而不是以 `@show` 結束。 `@endsection` 指令將只定義一個節，`@show` 將定義並 **立即 yield** 該節。


該 `@yield` 指令還接受默認值作為其第二個參數。如果要生成的節點未定義，則將呈現此內容：

```blade
@yield('content', 'Default content')
```

<a name="forms"></a>
## 表單

<a name="csrf-field"></a>
### CSRF 字段

無論何時在應用程序中定義 HTML 表單，都應該在表單中包含一個隱藏的 CSRF 令牌字段，以便 [CSRF 保護中間件](/docs/laravel/10.x/csrf) 可以驗證請求。你可以使用 `@csrf` Blade 指令生成令牌字段：

```blade
<form method="POST" action="/profile">
    @csrf

    ...
</form>
```

<a name="method-field"></a>
### Method 字段

由於 HTML 表單不能發出 `PUT`、`PATCH`或 `DELETE` 請求，因此需要添加一個隱藏的 `_method` 字段來欺騙這些 HTTP 動詞。 `@method` Blade 指令可以為你創建此字段：

```blade
<form action="/foo/bar" method="POST">
    @method('PUT')

    ...
</form>
```

<a name="validation-errors"></a>
### 表單校驗錯誤

該 `@error` 指令可用於快速檢查給定屬性是否存在 [驗證錯誤消息](/docs/laravel/10.x/validation#quick-displaying-the-validation-errors) 。在 `@error` 指令中，可以回顯 `$message` 變量以顯示錯誤消息：

```blade
<!-- /resources/views/post/create.blade.php -->

<label for="title">Post Title</label>

<input id="title"
    type="text"
    class="@error('title') is-invalid @enderror">

@error('title')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror
```

由於該 `@error` 指令編譯為「if」語句，因此你可以在 `@else` 屬性沒有錯誤時使用該指令來呈現內容：

```blade
<!-- /resources/views/auth.blade.php -->

<label for="email">Email address</label>

<input id="email"
    type="email"
    class="@error('email') is-invalid @else is-valid @enderror">
```



你可以將 [特定錯誤包的名稱](/docs/laravel/10.x/validation#named-error-bags) 作為第二個參數傳遞給 `@error` 指令，以便在包含多個表單的頁面上檢索驗證錯誤消息：

```blade
<!-- /resources/views/auth.blade.php -->

<label for="email">Email address</label>

<input id="email"
    type="email"
    class="@error('email', 'login') is-invalid @enderror">

@error('email', 'login')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror
```

<a name="stacks"></a>
## 堆棧

Blade 允許你推送到可以在其他視圖或布局中的其他地方渲染的命名堆棧。這對於指定子視圖所需的任何 JavaScript 庫特別有用：

```blade
@push('scripts')
    <script src="/example.js"></script>
@endpush
```

如果你想在給定的布爾表達式評估為 `true` 時 `@push` 內容，你可以使用 `@pushIf` 指令。

```blade
@pushIf($shouldPush, 'scripts')
    <script src="/example.js"></script>
@endPushIf
```

你可以根據需要多次推入堆棧。要呈現完整的堆棧內容，請將堆棧的名稱傳遞給 `@stack` 指令：

```blade
<head>
    <!-- Head Contents -->

    @stack('scripts')
</head>
```

如果要將內容前置到堆棧的開頭，應使用 `@prepend` 指令：

```blade
@push('scripts')
    This will be second...
@endpush

// Later...

@prepend('scripts')
    This will be first...
@endprepend
```

<a name="service-injection"></a>
## 服務注入

該 `@inject` 指令可用於從 Laravel [服務容器](/docs/laravel/10.x/container)中檢索服務。傳遞給 `@inject` 的第一個參數是要將服務放入的變量的名稱，而第二個參數是要解析的服務的類或接口名稱：

```blade
@inject('metrics', 'App\Services\MetricsService')

<div>
    Monthly Revenue: {{ $metrics->monthlyRevenue() }}.
</div>
```



<a name="rendering-inline-blade-templates"></a>
## 渲染內聯 Blade 模板

有時你可能需要將原始 Blade 模板字符串轉換為有效的 HTML。你可以使用 `Blade` 門面提供的 `render` 方法來完成此操作。該 `render` 方法接受 Blade 模板字符串和提供給模板的可選數據數組：

```php
use Illuminate\Support\Facades\Blade;

return Blade::render('Hello, {{ $name }}', ['name' => 'Julian Bashir']);
```

Laravel 通過將內聯 Blade 模板寫入 `storage/framework/views` 目錄來呈現它們。如果你希望 Laravel 在渲染 Blade 模板後刪除這些臨時文件，你可以為 `deleteCachedView` 方法提供參數：

```php
return Blade::render(
    'Hello, {{ $name }}',
    ['name' => 'Julian Bashir'],
    deleteCachedView: true
);
```

<a name="rendering-blade-fragments"></a>
## 渲染 Blade 片段

當使用 [Turbo](https://turbo.hotwired.dev/) 和 [htmx](https://htmx.org/) 等前端框架時，你可能偶爾需要在你的HTTP響應中只返回Blade模板的一個部分。Blade「片段（fragment）」允許你這樣做。要開始，將你的Blade模板的一部分放在`@fragment`和`@endfragment`指令中。

```blade
@fragment('user-list')
    <ul>
        @foreach ($users as $user)
            <li>{{ $user->name }}</li>
        @endforeach
    </ul>
@endfragment
```

然後，在渲染使用該模板的視圖時，你可以調用 `fragment` 方法來指定只有指定的片段應該被包含在傳出的 HTTP 響應中。

```php
return view('dashboard', ['users' => $users])->fragment('user-list');
```

`fragmentIf` 方法允許你根據一個給定的條件有條件地返回一個視圖的片段。否則，整個視圖將被返回。

```php
return view('dashboard', ['users' => $users])
    ->fragmentIf($request->hasHeader('HX-Request'), 'user-list');
```



`fragments` 和 `fragmentsIf` 方法允許你在響應中返回多個視圖片段。這些片段將被串聯起來。

```php
view('dashboard', ['users' => $users])
    ->fragments(['user-list', 'comment-list']);

view('dashboard', ['users' => $users])
    ->fragmentsIf(
        $request->hasHeader('HX-Request'),
        ['user-list', 'comment-list']
    );
```

<a name="extending-blade"></a>
## 擴展 Blade

Blade 允許你使用 `directive` 方法定義自己的自定義指令。當 Blade 編譯器遇到自定義指令時，它將使用該指令包含的表達式調用提供的回調。

下面的示例創建了一個 `@datetime($var)` 指令，該指令格式化給定的 `$var`，它應該是 `DateTime` 的一個實例：

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Blade;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * 注冊應用的服務
         */
        public function register(): void
        {
            // ...
        }

        /**
         * Bootstrap any application services.
         */
        public function boot(): void
        {
            Blade::directive('datetime', function (string $expression) {
                return "<?php echo ($expression)->format('m/d/Y H:i'); ?>";
            });
        }
    }

正如你所見，我們將 `format` 方法應用到傳遞給指令中的任何表達式上。因此，在本例中，此指令生成的最終 PHP 將是：

    <?php echo ($var)->format('m/d/Y H:i'); ?>

> **注意：**更新 Blade 指令的邏輯後，需要刪除所有緩存的 Blade 視圖。可以使用 `view:clear` Artisan 命令。

<a name="custom-echo-handlers"></a>
### 自定義回顯處理程序

如果你試圖使用 Blade 來「回顯」一個對象， 該對象的 `__toString` 方法將被調用。該[`__toString`](https://www.php.net/manual/en/language.oop5.magic.php#object.tostring) 方法是 PHP 內置的「魔術方法」之一。但是，有時你可能無法控制 `__toString` 給定類的方法，例如當你與之交互的類屬於第三方庫時。

在這些情況下，Blade 允許您為該特定類型的對象注冊自定義回顯處理程序。為此，您應該調用 Blade 的 `stringable` 方法。該 `stringable` 方法接受一個閉包。這個閉包類型應該提示它負責呈現的對象的類型。通常，應該在應用程序的 `AppServiceProvider` 類的 `boot` 方法中調用該 `stringable` 方法：

    use Illuminate\Support\Facades\Blade;
    use Money\Money;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Blade::stringable(function (Money $money) {
            return $money->formatTo('en_GB');
        });
    }

定義自定義回顯處理程序後，您可以簡單地回顯 Blade 模板中的對象：

```blade
Cost: {{ $money }}
```

<a name="custom-if-statements"></a>
### 自定義 if 聲明

在定義簡單的自定義條件語句時，編寫自定義指令通常比較覆雜。因此，Blade 提供了一個 Blade::if 方法，允許你使用閉包快速定義自定義條件指令。例如，讓我們定義一個自定義條件來檢查為應用程序配置的默認 「存儲」。我們可以在 AppServiceProvider 的 boot 方法中執行此操作：

    use Illuminate\Support\Facades\Blade;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Blade::if('disk', function (string $value) {
            return config('filesystems.default') === $value;
        });
    }

一旦定義了自定義條件，就可以在模板中使用它:

```blade
@disk('local')
    <!-- The application is using the local disk... -->
@elsedisk('s3')
    <!-- The application is using the s3 disk... -->
@else
    <!-- The application is using some other disk... -->
@enddisk

@unlessdisk('local')
    <!-- The application is not using the local disk... -->
@enddisk
```
