# 前端

- [介紹](#introduction)
- [使用 PHP](#using-php)
    - [PHP 和 Blade](#php-and-blade)
    - [Livewire](#livewire)
    - [入門套件](#php-starter-kits)
- [使用 Vue / React](#using-vue-react)
    - [Inertia](#inertia)
    - [入門套件](#inertia-starter-kits)
- [打包資源](#bundling-assets)

<a name="introduction"></a>
## 介紹

Laravel 是一個後端框架，提供了構建現代 Web 應用所需的所有功能，例如 [路由](/docs/laravel/10.x/routing)、[驗證](/docs/laravel/10.x/validation)、[緩存](/docs/laravel/10.x/cache)、[隊列](/docs/laravel/10.x/queues)、[文件存儲](/docs/laravel/10.x/filesystem) 等等。然而，我們認為為開發人員提供美觀的全棧體驗，包括構建應用前端的強大方法，是非常重要的。

在使用 Laravel 構建應用時，有兩種主要的方式來解決前端開發問題，選擇哪種方式取決於你是否想通過 PHP 或使用像 Vue 和 React 這樣的 JavaScript 框架來構建前端。我們將在下面討論這兩種選項，以便你可以做出有關應用程序前端開發的最佳方法的明智決策。

<a name="using-php"></a>
## 使用 PHP

<a name="php-and-blade"></a>
### PHP 和 Blade

過去，大多數 PHP 應用程序使用簡單的 HTML 模板和 PHP `echo` 語句將數據呈現給瀏覽器，這些語句在請求期間從數據庫檢索數據：

```blade
<div>
    <?php foreach ($users as $user): ?>
        Hello, <?php echo $user->name; ?> <br />
    <?php endforeach; ?>
</div>
```

在 Laravel 中，仍可以使用 視圖 和 Blade 來實現呈現 HTML 的這種方法。Blade 是一種非常輕量級的模板語言，提供方便、簡短的語法，用於顯示數據、叠代數據等：

```blade
<div>
    @foreach ($users as $user)
        Hello, {{ $user->name }} <br />
    @endforeach
</div>
```

當使用這種方法構建應用程序時，表單提交和其他頁面交互通常會從服務器接收一個全新的 HTML 文檔，整個頁面將由瀏覽器重新渲染。即使今天，許多應用程序也可能非常適合使用簡單的 Blade 模板構建其前端。

<a name="growing-expectations"></a>
#### 不斷提高的期望

然而，隨著用戶對 Web 應用程序的期望不斷提高，許多開發人員發現需要構建更具有互動性和更具現代感的動態前端。為此，一些開發人員選擇使用諸如 Vue 和 React 等 JavaScript 框架開始構建應用程序的前端。

其他人則更喜歡使用他們熟悉的後端語言，開發出可利用他們首選的後端語言構建現代 Web 應用程序 UI 的解決方案。例如，在[Rails](https://rubyonrails.org/)生態系統中，這促使了諸如[Turbo](https://turbo.hotwired.dev/)、[Hotwire](https://hotwired.dev/)和[Stimulus](https://stimulus.hotwired.dev/)等庫的創建。

在 Laravel 生態系統中，需要主要使用PHP創建現代動態前端已經導致了[Laravel Livewire](https://laravel-livewire.com/)和[Alpine.js](https://alpinejs.dev/)的創建。

<a name="livewire"></a>
### Livewire

[Laravel Livewire](https://laravel-livewire.com/)是一個用於構建 Laravel 前端的框架，具有與使用現代 JavaScript 框架（如 Vue 和 React ）構建的前端一樣的動態、現代和生動的感覺。

在使用 Livewire 時，你將創建 Livewire "組件"，這些組件將呈現 UI 的一個離散部分，並公開可以從應用程序的前端調用和互動的方法和數據。例如，一個簡單的"計數器"組件可能如下所示：


    <?php

    namespace App\Http\Livewire;

    use Livewire\Component;

    class Counter extends Component
    {
        public $count = 0;

        public function increment()
        {
            $this->count++;
        }

        public function render()
        {
            return view('livewire.counter');
        }
    }

對於計數器，相應的模板將會像這樣寫：

```blade
<div>
    <button wire:click="increment">+</button>
    <h1>{{ $count }}</h1>
</div>
```

正如你所見，Livewire 使你能夠編寫新的 HTML 屬性，例如 `wire:click`，以連接 Laravel 應用程序的前端和後端。此外，你可以使用簡單的 Blade 表達式呈現組件的當前狀態。

對於許多人來說，Livewire 改變了 Laravel 的前端開發方式，使他們可以在 Laravel 的舒適環境下構建現代、動態的 Web 應用程序。通常，使用 Livewire 的開發人員也會利用 [Alpine.js](https://alpinejs.dev/) 僅在需要時 "適度地添加" JavaScript 到他們的前端，比如為了渲染對話框窗口。

如果你是 Laravel 新手，我們建議你先了解 [views](/docs/laravel/10.x/views) 和 [Blade](/docs/laravel/10.x/blade) 的基本用法。然後，查閱官方的 [Laravel Livewire 文檔](https://laravel-livewire.com/docs)，學習如何通過交互式 Livewire 組件將你的應用程序提升到新的水平。

<a name="php-starter-kits"></a>
### 入門套件

如果你想使用 PHP 和 Livewire 構建你的前端，你可以利用我們的 Breeze 或 Jetstream [入門套件](/docs/laravel/10.x/starter-kits) 來快速啟動你的應用程序開發。這兩個入門套件都使用 [Blade](/docs/laravel/10.x/blade) 和 [Tailwind](https://tailwindcss.com/) 構建你的應用程序後端和前端身份驗證流程，讓你可以輕松開始構建你的下一個大項目。

<a name="using-vue-react"></a>
## 使用 Vue / React

盡管使用 Laravel 和 Livewire 可以構建現代的前端，但許多開發人員仍然喜歡利用像 Vue 或 React 這樣的 JavaScript 框架的強大功能。這使開發人員能夠利用通過 NPM 可用的豐富的 JavaScript 包和工具生態系統。

然而，如果沒有額外的工具支持，將 Laravel 與 Vue 或 React 配對會遇到各種覆雜的問題，例如客戶端路由、數據注入和身份驗證。使用諸如 [Nuxt](https://nuxtjs.org/) 和 [Next](https://nextjs.org/) 等具有觀點的 Vue / React 框架可以簡化客戶端路由；但是，當將類似 Laravel 這樣的後端框架與這些前端框架配對時，數據注入和身份驗證仍然是覆雜而麻煩的問題。

此外，開發人員需要維護兩個單獨的代碼存儲庫，通常需要在兩個存儲庫之間協調維護、發布和部署。雖然這些問題並非不可解決，但我們認為這不是開發應用程序的一種有成效或令人愉快的方式。

<a name="inertia"></a>
### Inertia

值得慶幸的是，Laravel 提供了兩全其美的解決方案。[Inertia](https://inertiajs.com/) 可以橋接你的 Laravel 應用程序和現代 Vue 或 React 前端，使你可以使用 Vue 或 React 構建完整的現代前端，同時利用 Laravel 路由和控制器進行路由、數據注入和身份驗證 - 所有這些都在單個代碼存儲庫中完成。使用這種方法，你可以同時享受 Laravel 和 Vue / React 的全部功能，而不會破壞任何一種工具的能力。

在將 Inertia 安裝到你的 Laravel 應用程序後，你將像平常一樣編寫路由和控制器。但是，你將返回 Inertia 頁面而不是從控制器返回 Blade 模板：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\User;
    use Inertia\Inertia;
    use Inertia\Response;

    class UserController extends Controller {
        /**
         * 顯示給定用戶的個人資料
         */
        public function show(string $id): Response {
            return Inertia::render('Users/Profile', [
                'user' => User::findOrFail($id)
            ]);
        }
    }

Inertia 頁面對應於 Vue 或 React 組件，通常存儲在應用程序的 `resources/js/Pages` 目錄中。通過 `Inertia::render` 方法傳遞給頁面的數據將用於填充頁面組件的 "props"：

```vue
<script setup>
import Layout from '@/Layouts/Authenticated.vue';
import { Head } from '@inertiajs/vue3';

const props = defineProps(['user']);
</script>

<template>
    <Head title="用戶資料" />

    <Layout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">
                資料
            </h2>
        </template>

        <div class="py-12">
            你好，{{ user.name }}
        </div>
    </Layout>
</template>
```

正如你所看到的，使用 Inertia 可以在構建前端時充分利用 Vue 或 React 的強大功能，同時為 Laravel 驅動的後端和 JavaScript 驅動的前端提供了輕量級的橋梁。

#### 服務器端渲染

如果你因為應用程序需要服務器端渲染而擔心使用 Inertia，不用擔心。Inertia 提供了 [服務器端渲染支持](https://inertiajs.com/server-side-rendering)。並且，在通過 [Laravel Forge](https://forge.laravel.com/) 部署應用程序時，輕松確保 Inertia 的服務器端渲染過程始終運行。

<a name="inertia-starter-kits"></a>
### 入門套件

如果你想使用 Inertia 和 Vue / React 構建前端，可以利用我們的 Breeze 或 Jetstream [入門套件](/docs/laravel/10.x/starter-kits) 來加速應用程序的開發。這兩個入門套件使用 Inertia、Vue / React、[Tailwind](https://tailwindcss.com/) 和 [Vite](https://vitejs.dev/) 構建應用程序的後端和前端身份驗證流程，讓你可以開始構建下一個大型項目。

<a name="bundling-assets"></a>
## 打包資源

無論你選擇使用 Blade 和 Livewire 還是 Vue/React 和 Inertia 來開發你的前端，你都可能需要將你的應用程序的 CSS 打包成生產就緒的資源。當然，如果你選擇用 Vue 或 React 來構建你的應用程序的前端，你也需要將你的組件打包成瀏覽器準備好的 JavaScript 資源。

默認情況下，Laravel 利用 [Vite](https://vitejs.dev) 來打包你的資源。Vite 在本地開發過程中提供了閃電般的構建時間和接近即時的熱模塊替換（HMR）。在所有新的 Laravel 應用程序中，包括那些使用我們的 [入門套件](/docs/laravel/10.x/starter-kit)，你會發現一個 `vite.config.js` 文件，加載我們輕量級的 Laravel Vite 插件，使 Vite 在 Laravel 應用程序中使用起來非常愉快。

開始使用 Laravel 和 Vite 的最快方法是使用 [Laravel Breeze](/docs/laravel/10.x/starter-kitsmd#laravel-breeze) 開始你的應用程序的開發，我們最簡單的入門套件，通過提供前端和後端的認證支架來啟動你的應用程序。

> **注意**
> 關於利用 Vite 和 Laravel 的更多詳細文檔，請看我們的 [關於打包和編譯資源的專用文檔](/docs/laravel/10.x/vite)。
