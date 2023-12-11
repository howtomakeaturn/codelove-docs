# 起步套件

- [介紹](#introduction)
- [Laravel Breeze](#laravel-breeze)
    - [安裝](#laravel-breeze-installation)
    - [Breeze & Blade](#breeze-and-blade)
    - [Breeze & Livewire](#breeze-and-livewire)
    - [Breeze & React / Vue](#breeze-and-inertia)
    - [Breeze & Next.js / API](#breeze-and-next)
- [Laravel Jetstream](#laravel-jetstream)

## 介紹 {#introduction}

為了幫助你快速構建 Laravel 應用，我們很高興提供認證和應用程序起始套件。這些套件會自動使用所需的路由、控制器和視圖來注冊和驗證應用程序的用戶。

雖然你可以使用這些起始套件，但它們並非必需品。你可以通過安裝全新的 Laravel 來從頭開始構建自己的應用程序。無論你選擇哪種方式，我們相信你都能構建出很棒的應用程序！

## Laravel Breeze {#laravel-breeze}

[Laravel Breeze](https://github.com/laravel/breeze) 是 Laravel 的 [認證功能](/docs/laravel/10.x/authentication) 的一種簡單、最小實現，包括登錄、注冊、密碼重置、電子郵件驗證和密碼確認。此外，Breeze 還包括一個簡單的「個人資料」頁面，用戶可以在該頁面上更新其姓名、電子郵件地址和密碼。

Laravel Breeze 的默認視圖層由簡單的 [Blade 模版](/docs/laravel/10.x/blade) 和 [Tailwind CSS](https://tailwindcss.com) 組成。除此之外，Breeze 還可以使用 Vue 或 React 和 [Inertia](https://inertiajs.com) 來構建應用。

Breeze 為開始全新的 Laravel 應用程序提供了很好的起點，並且對於打算使用 [Laravel Livewire](https://laravel-livewire.com) 將 Blade 模板提升新的水平的項目來說，也是一個不錯的選擇。

![](https://laravel.com/img/docs/breeze-register.png)

#### Laravel 訓練營

如果你是 Laravel 的新手，歡迎加入 [Laravel 訓練營](https://bootcamp.laravel.com)。 Laravel 訓練營將帶領你通過使用 Breeze 構建你的第一個 Laravel 應用程序。這是一個很好的方式，讓你了解 Laravel 和 Breeze 提供的所有功能。

### 安裝 {#laravel-breeze-installation}

首先，你應該 [創建一個新的 Laravel 應用程序](/docs/laravel/10.x/installation)，配置好數據庫並運行 [數據庫遷移](/docs/laravel/10.x/migrations)。在創建了一個新的 Laravel 應用程序之後，你可以使用 Composer 來安裝 Laravel Breeze：

```shell
composer require laravel/breeze --dev
```

安裝完 Breeze 後，你可以使用下文中提到的 Breeze「棧」來快速構建你的應用程序。

### Breeze & Blade {#breeze-and-blade}

在使用 Composer 安裝好 Laravel Breeze 之後，你可以運行 `breeze:install` Artisan 命令。這個命令會將身份驗證視圖、路由、控制器和其他資源覆制到你的應用程序中。Laravel Breeze 將其所有代碼都覆制到你的應用程序中，這樣你就可以完全控制和查看其功能和實現。

默認的 Breeze「棧」是 Blade 棧，它使用簡單的 [Blade 模板](/docs/laravel/10.x/blade) 來渲染你的應用程序前端。你可以通過調用 `breeze:install` 命令來安裝 Blade 棧，而無需其他額外的參數。在 Breeze 的腳手架安裝完後，你還需要編譯應用程序的前端資源：

```shell
php artisan breeze:install

php artisan migrate
npm install
npm run dev
```

接下來，你可以在 Web 瀏覽器中打開應用程序的 `/login` 或 `/register` 的 URL。所有 Breeze 的路由都定義在 `routes/auth.php` 文件中。

#### 黑暗模式 {#dark-mode}

如果你希望 Breeze 在構建應用程序前端時支持「黑暗模式」，只需要在執行 `breeze:install` 命令時提供 `--dark` 指令即可：

```shell
php artisan breeze:install --dark
```

> **注意**
> 要了解有關編譯應用程序的 CSS 和 JavaScript 的更多信息，請查看 Laravel 的 [Vite 編譯 Assets](/docs/laravel/10.x/vitemd#running-vite).

### Breeze & Livewire {#breeze-and-livewire}

Laravel Breeze 還提供了 [Livewire](https://livewire.laravel.com/) 腳手架。Livewire 是一種僅使用 PHP 構建動態、反應式前端 UI 的強大方法。

Livewire 非常適合主要使用 Blade 模板，並且正在尋找 JavaScript 驅動的 SPA 框架（如 Vue 和 React）的更簡單的替代方案的團隊。

要使用 Livewire 棧，您可以在執行 `breeze:install` Artisan 命令時選擇 Livewire 前端棧。在安裝 Breeze 的腳手架後，您應當運行數據庫遷移：

```shell
php artisan breeze:install

php artisan migrate
```

### Breeze & React / Vue {#breeze-and-inertia}

Laravel Breeze 還通過 [Inertia](https://inertiajs.com) 前端實現提供 React 和 Vue 腳手架。 Inertia 允許你使用經典的服務器端路由和控制器構建目前流行的單頁 React 和 Vue 應用程序。

Inertia 讓你享受 React 和 Vue 的前端強大功能以及 Laravel 令人難以置信的後端生產力和快如閃電的 [Vite](https://vitejs.dev) 編譯。 如果要指定技術棧，請在執行 `breeze:install` Artisan 命令時指定 `vue` 或 `react` 作為你想要的技術棧。 安裝 Breeze 的腳手架後，你就可以安裝依賴及運行前端項目：

```shell
php artisan breeze:install vue

# 或者。。。

php artisan breeze:install react

php artisan migrate
npm install
npm run dev
```

接下來，你就可以在瀏覽器中訪問 `/login` 或 `/register` URL。 Breeze 的所有路由都在 `routes/auth.php` 文件中定義。

#### 服務器端渲染 {#server-side-rendering}

如果你希望 Breeze 支持 [Inertia SSR](https://inertiajs.com/server-side-rendering)，你可以在調用 `breeze:install` 命令時提供 `ssr` 選項：

```shell
php artisan breeze:install vue --ssr
php artisan breeze:install react --ssr
```

### Breeze & Next.js / API {#breeze-and-next}

Laravel Breeze 還可以生成身份驗證 API，可以準備驗證現代 JavaScript 應用程序，例如由 [Next](https://nextjs.org/)，[Nuxt](https://nuxtjs.org/) 等驅動的應用。要開始，請在執行 `breeze:install` Artisan 命令時指定 `api` 堆棧作為所需的堆棧：

```shell
php artisan breeze:install api

php artisan migrate
```

在安裝期間，Breeze 將在應用程序的 `.env` 文件中添加 `FRONTEND_URL` 環境變量。該 URL 應該是你的 JavaScript 應用程序的 URL。在本地開發期間，這通常是 `http://localhost:3000`。另外，你應該確保 `APP_URL` 設置為 `http://localhost:8000`，這是 `serve` Artisan 命令使用的默認 URL。

#### Next.js 參考實現 {#next-reference-implementation}

最後，你可以將此後端與你選擇的前端配對。Breeze 前端的 Next 參考實現在 [在GitHub上提供](https://github.com/laravel/breeze-next)。此前端由 Laravel 維護，並包含與 Breeze 提供的傳統 Blade 和 Inertia 堆棧相同的用戶界面。

## Laravel Jetstream {#laravel-jetstream}

雖然 Laravel Breeze 為構建 Laravel 應用程序提供了簡單和最小的起點，但 Jetstream 通過更強大的功能和附加的前端技術棧增強了該功能。**對於全新接觸 Laravel 的用戶，我們建議使用 Laravel Breeze 學習一段時間後再嘗試 Laravel Jetstream。**

Jetstream 為 Laravel 提供了美觀的應用程序腳手架，並包括登錄、注冊、電子郵件驗證、雙因素身份驗證、會話管理、通過 Laravel Sanctum 支持的 API 以及可選的團隊管理。Jetstream 使用 [Tailwind CSS](https://tailwindcss.com/) 設計，並提供你選擇使用 [Livewire](https://laravel-livewire.com/) 或 [Inertia](https://inertiajs.com/) 驅動的前端腳手架。

有關安裝 Laravel Jetstream 的完整文檔，請參閱 [Jetstream 官方文檔](https://jetstream.laravel.com/3.x/introduction.html)。
