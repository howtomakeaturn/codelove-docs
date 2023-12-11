# 安裝

- [認識 Laravel](#meet-laravel)
   - [為什麽選擇 Laravel?](#why-laravel)
- [你的第一個 Laravel 項目](#your-first-laravel-project)
- [Laravel & Docker](#laravel-and-docker)
   - [macOS 入門](#getting-started-on-macos)
   - [Windows 入門](#getting-started-on-windows)
   - [Linux 入門](#getting-started-on-linux)
   - [選擇 Sail 服務](#choosing-your-sail-services)
- [初始化](#initial-configuration)
   - [基於環境的配置](#environment-based-configuration)
   - [目錄配置](#databases-and-migrations)
- [下一步](#next-steps)
   - [將 Laravel 用作全棧框架](#laravel-the-fullstack-framework)
   - [將 Laravel 用作 API 後端](#laravel-the-api-backend)

## 認識 Laravel {#meet-laravel}
Laravel 是一個 Web 應用框架， 有著表現力強、語法優雅的特點。Web 框架為創建應用提供了一個結構和起點，你只需要專注於創造，我們來為你處理細節。

Laravel 致力於提供出色的開發體驗，同時提供強大的特性，例如完全的依賴注入，富有表現力的數據庫抽象層，隊列和計劃任務，單元和集成測試等等。

無論你是剛剛接觸 PHP 和 Web 框架的新人，亦或是有著多年經驗的老手， Laravel 都是一個可以與你一同成長的框架。我們將幫助你邁出成為 Web 開發者的第一步，或是將你的經驗提高到下一個等級。我們迫不及待的想看看你的作品。

### 為什麽選擇 Laravel? {#why-laravel}

有非常多的工具和框架可以被用於構建一個 Web 應用。但我們相信 Laravel 是構建現代化、全棧 Web 應用的最佳選擇。

#### 一個漸進式框架

我們喜歡稱 Laravel 是一個「漸進式」框架。意思是 Laravel 將與你一同成長。如果你是首次進入 Web 開發， Laravel 大量的文檔、指南和 [視頻教程](https://laracasts.com) 將幫助你熟悉使用技巧而不至於不知所措。

如果你是高級開發人員, Laravel 為你提供了強大的工具用於 [依賴注入](/docs/laravel/10.x/container)、 [單元測試](/docs/laravel/10.x/testing)、 [隊列](/docs/laravel/10.x/queues)、 [廣播系統](/docs/laravel/10.x/broadcasting) 等等。 Laravel 為構建專業的 Web 應用程序進行了微調，並準備好處理企業工作負載。

#### 一個可擴展的框架

Laravel 具有難以置信的可擴展性。由於 PHP 的靈活性以及 Laravel 對 Redis 等快速分布式緩存系統的內置支持，使用 Laravel 進行擴展是輕而易舉的事。事實上，Laravel 應用程序已經很容易擴展到每月處理數億個請求。

需要節省開發費用嗎？ [Laravel Vapor](https://vapor.laravel.com) 允許你在 AWS 最新的無服務器技術上以幾乎無限的規模運行 Laravel 應用程序。

#### 一個社區化的框架

Laravel 結合了 PHP 生態系統中最好的軟件包，提供了最健壯、對開發人員友好的框架。此外，來自世界各地的數千名有才華的開發人員 [為框架做出了貢獻](https://github.com/laravel/framework) 。誰知道呢，也許你就是下一個 Laravel 的貢獻者。

## 你的第一個 Laravel 項目 {#your-first-laravel-project}

在創建你的第一個Laravel項目之前, 你應該確保你的本地機器上已經安裝了 PHP 和 [Composer](https://getcomposer.org) 。 如果你是在 macOS 上開發， PHP 和 Composer 可以通過 [Homebrew](https://brew.sh/) 來安裝。 此外, 我們建議你 [安裝 Node 和 NPM](https://nodejs.org)。

安裝 PHP 和 Composer 後，你可以通過`create-project`命令創建一個新的 Laravel 項目：

```nothing
composer create-project laravel/laravel example-app
```

或者，你可以通過 Laravel 安裝器作為全局 Composer 依賴：

```nothing
composer global require laravel/installer

laravel new example-app
```

當應用程序創建完成後，你可以通過 Artisan CLI 的`serve`命令來啟動 Laravel 的本地服務：

```nothing
cd example-app

php artisan serve
```

啟動 Artisan 開發服務器後，你便可在 Web 瀏覽器中通過`http://localhost:8000`訪問。 接下來，[你已經準備好開始進入 Laravel 生態系統的下一步](#next-steps)。 當然， 你也可能需要 [配置數據庫](#databases-and-migrations)。

> **技巧**
> 如果你想在開發Laravel應用程序時領先一步， 可以考慮使用我們的 [入門套件](/docs/laravel/10.x/starter-kits)。 Laravel 的入門套件為你的新 Laravel 應用程序提供後端和前端身份驗證腳手架。

## Laravel & Docker {#laravel-and-docker}

我們希望盡可能輕松地開始使用 Laravel，無論你喜歡哪種操作系統。因此，在本地計算機上開發和運行 Laravel 項目有多種選擇。雖然你可能希望稍後探索這些選項，但 Laravel 提供了 [Sail](/docs/laravel/10.x/sail)，這是一個使用 [Docker](https://www.docker.com) 運行 Laravel 項目的內置解決方案。

Docker 是一種在小型、輕量級「容器」中運行應用程序和服務的工具，不會幹擾本地機器上已安裝的軟件或配置。這意味著你不必擔心在本地機器上配置或設置覆雜的開發工具，如 Web 服務器和數據庫。要開始，你只需要安裝 [Docker Desktop](https://www.docker.com/products/docker-desktop).

Laravel Sail 是一個輕量級的命令行界面，用於與 Laravel 的默認 Docker 配置進行交互。Sail 為使用 PHP、MySQL 和 Redis 構建 Laravel 應用程序提供了一個很好的起點，而無需之前的 Docker 經驗。

> **技巧**
> 已經是 Docker 專家？別擔心！關於 Sail 的一切都可以使用 Laravel 附帶的文件 `docker-compose.yml` 進行自定義。

### macOS 入門 {#getting-started-on-macos}

如果你在 Mac 上開發並且已經安裝了 [Docker Desktop](https://www.docker.com/products/docker-desktop)，你可以使用一個簡單的終端命令來創建一個新的 Laravel 項目。 例如，要在名為「example-app」的目錄中創建一個新的 Laravel 應用程序，你可以在終端中運行以下命令：

```shell
curl -s "https://laravel.build/example-app" | bash
```

當然，你可以將此 URL 中的「example-app」更改為你喜歡的任何內容。Laravel 應用程序的目錄將在你執行命令的目錄中創建。

創建項目後，你可以導航到應用程序目錄並啟動 Laravel Sail。Laravel Sail 提供了一個簡單的命令行界面，用於與 Laravel 的默認 Docker 配置進行交互：

```shell
cd example-app

./vendor/bin/sail up
```

第一次運行 Sail `up` 命令時， Sail 的應用程序容器將在你的機器上構建。這可能需要幾分鐘。 **不用擔心，隨後嘗試啟動 Sail 會快得多。**

啟動應用程序的 Docker 容器後，你可以在 Web 瀏覽器中訪問應用程序： http://localhost 。

> **技巧**
> 要繼續了解有關 Laravel Sail 的更多信息，請查看其 [完整文檔](/docs/laravel/10.x/sail)。

### Windows 入門 {#getting-started-on-windows}

在創建 Laravel 應用前，請確保你的 Windows 電腦已經安裝了 [Docker Desktop](https://www.docker.com/products/docker-desktop)。請確保已經安裝並啟用了適用於 Linux 的 Windows 子系統 2（WSL2），WSL 允許你在 Windows10 上運行 Linux 二進制文件。關於如何安裝並啟用 WSL2，請參閱微軟 [開發者環境文檔](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

> **技巧**
> 安裝並啟用 WSL2 後，請確保 Docker Desktop 已經 [配置為使用 WSL2 後端](https://docs.docker.com/docker-for-windows/wsl/).

接下來，準備創建你的第一個 Laravel 項目，啟動 Windows Terminal，為 WSL2 Linux 操作系統打開一個終端。之後，你可以使用簡單的命令來新建 Laravel 項目。比如，想要在「example-app」文件夾中新建 Laravel 應用，可以在終端中運行以下命令：

```shell
curl -s https://laravel.build/example-app | bash
```

當然，你可以將此 URL 中的「example-app」更改為你喜歡的任何內容，只需確保應用程序名稱僅包含字母數字字符、破折號和下劃線 Laravel 應用程序的目錄將在你執行命令的目錄中創建。

Sail 安裝可能需要幾分鐘時間，因為 Sail 的應用程序容器是在你的本地計算機上構建的。

創建項目後，你可以導航到應用程序目錄並啟動 Laravel Sail。 Laravel Sail 提供了一個簡單的命令行界面來與 Laravel 的默認 Docker 配置進行交互：

```shell
cd example-app

./vendor/bin/sail up
```

一旦應用的 Docker 容器啟動了，你便可在 Web 瀏覽器中通過 localhost 訪問你的應用了。

> **技巧**
> 要繼續學習更多關於 Laravel Sail 的知識，請參閱 [詳細文檔](/docs/laravel/10.x/sail).

#### 使用 WSL2 進行開發

當然，你需要能夠修改在 WSL2 安裝中創建的 Laravel 應用程序文件。我們推薦你使用微軟的 [Visual Studio Code](https://code.visualstudio.com) 編輯器並搭配其 [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) 擴展，它們可以幫助你解決這個問題。

一旦這些工具成功安裝，你可以使用 Windows Terminal 在應用根目錄執行 `code .` 命令來打開任何 Laravel 項目。

### 在 Linux 使用 Laravel Sail {#getting-started-on-linux}

如果在 Linux 開發，並且已經安裝了 [Docker Compose](https://docs.docker.com/compose/install/) 你可以使用簡單的終端命令來創建一個新的 Laravel 項目。例如，要在「example-app」目錄中創建新的 Laravel 應用，你可以在終端中運行如下命令：

```shell
curl -s https://laravel.build/example-app | bash
```

當然，你可以將 URL 中的「example-app」替換為任何你喜歡的內容。Laravel 應用程序的目錄將在執行命令的目錄中創建。

在項目創建完成後，你可以導航至應用目錄和啟動 Laravel Sail。Laravel Sail 提供了一個簡單的命令行接口，用於與 Laravel 的默認 Docker 配置進行交互：

```shell
cd example-app

./vendor/bin/sail up
```
在你首次運行 Sail 的 `up` 命令的時候，Sail 的應用容器將會在你的機器上進行編譯。這個過程將會花費一段時間。**不要擔心，以後就會很快了。**

一旦應用的 Docker 容器啟動了，你便可在 Web 瀏覽器中通過 http://localhost 訪問你的應用了。

> **技巧**
> 要繼續學習更多關於 Laravel Sail 的知識，請參閱 [ 詳細文檔](/docs/laravel/10.x/sail)。

### 選擇 Sail 服務 {#choosing-your-sail-services}

通過 Sail 創建 Laravel 程序時，可以使用 `with` 查詢字符串變量來選擇程序的 `docker-compose.yml` 文件配置哪些服務。可用的服務包括 `mysql`, `pgsql`, `mariadb`, `redis`, `memcached`, `meilisearch`, `minio`, `selenium`, 和 `mailpit`:

```shell
curl -s "https://laravel.build/example-app?with=mysql,redis" | bash
```

如果不指定配置服務，將使用 `mysql`, `redis`, `meilisearch`, `mailpit`, 和 `selenium` 作為默認配置。

還可以通過 `devcontainer`參數添加到 URL 來安裝默認的 [Devcontainer](/docs/laravel/10.x/sailmd#using-devcontainers):

```shell
curl -s "https://laravel.build/example-app?with=mysql,redis&devcontainer" | bash
```

## 安裝配置 {#initial-configuration}

Laravel 框架將所有的配置文件都放在 `config` 目錄中。每個選項都有一個文件，因此可以瀏覽文件並熟悉可用的選項。

Laravel 開箱可用，不需要額外配置，你可以自由的開發！然而，你可能希望查看 `config/app.php` 文件及其文檔。它包含幾個選項，例如你可能希望根據程序更改 `timezone` 和 `locale`。

### 環境配置 {#environment-based-configuration}

Laravel 的許多配置選項值可能會根據運行的環境有所不同，因此許多重要的配置選項值是在 `.env` 文件中定義的。

你的 `.env` 文件不應該提交到應用程序的源代碼控制中，因為使用你的應用程序的每個開發者/服務器可能需要不同的環境配置。此外，如果入侵者訪問了你的源代碼倉庫，這將成為安全風險，因為任何敏感數據都會被公開。

> **注意**
> 若要了解更多關於 `.env` 文件和基於環境的配置的信息，請查看完整的 [配置文檔](/docs/laravel/10.x/configurationmd#environment-configuration)。

### 數據庫和遷移 {#databases-and-migrations}

現在，你已經創建了 Laravel 應用程序，可能想在數據庫中存儲一些數據。默認情況下，你的應用程序的 `.env` 配置文件指定 Laravel 將與 MySQL 數據庫交互，並訪問 `127.0.0.1` 中的數據庫。如果你在 macOS 上開發並需要在本地安裝 MySQL、Postgres 或 Redis，則可能會發現使用 [DBngin](https://dbngin.com/) 非常方便。

如果你不想在本地機器上安裝 MySQL 或 Postgres，你總可以使用 [SQLite](https://www.sqlite.org/index.html) 數據庫。SQLite 是一個小型、快速、自包含的數據庫引擎。要開始使用，只需創建一個空的 SQLite 文件來創建 SQLite 數據庫。通常，這個文件將存在於 Laravel 應用程序的 `database` 目錄中：

```shell
touch database/database.sqlite
```

接下來，更新你的 `.env` 配置文件以使用 Laravel 的 `sqlite` 數據庫驅動程序。你可以刪除其他數據庫配置選項：

```ini
DB_CONNECTION=sqlite # [tl! add]
DB_CONNECTION=mysql # [tl! remove]
DB_HOST=127.0.0.1 # [tl! remove]
DB_PORT=3306 # [tl! remove]
DB_DATABASE=laravel # [tl! remove]
DB_USERNAME=root # [tl! remove]
DB_PASSWORD= # [tl! remove]
```

一旦你配置了 SQLite 數據庫，你可以運行你的應用程序的 [數據庫遷移](/docs/laravel/10.x/migrations)，這將創建你的應用程序的數據庫表：

```shell
php artisan migrate
```

## 下一步 {#next-steps}

現在你已經創建了你的 Laravel 項目，你可能在想下一步該學什麽。首先，我們強烈建議通過閱讀以下文檔來了解 Laravel 的工作方式：


-   [請求生命周期](/docs/laravel/10.x/lifecycle)
  -   [配置](/docs/laravel/10.x/configuration)
  -   [目錄結構](/docs/laravel/10.x/structure)
  -   [前端](/docs/laravel/10.x/frontend)
  -   [服務容器](/docs/laravel/10.x/container)
  -   [門面](/docs/laravel/10.x/facades)


你如何使用 Laravel 也會決定你的下一步。Laravel 有多種使用方式，下面我們將探索框架的兩個主要用例。

> **注意**
> 是第一次使用 Laravel 嗎？請查看 [Laravel Bootcamp](https://bootcamp.laravel.com) 可讓你實際操作 Laravel 框架並帶你構建第一個 Laravel 應用程序。

### Laravel 全棧框架 {#laravel-the-fullstack-framework}

Laravel 可以作為一個全棧框架。全棧框架意味著你將使用 Laravel 將請求路由到你的應用程序，並通過 [Blade 模板](/docs/laravel/10.x/blade) 或像 [Inertia](https://inertiajs.com) 這樣的單頁應用混合技術來渲染你的前端。這是使用 Laravel 框架最常見的方式，在我們看來，這也是使用 Laravel 最高效的方式。

如果你打算使用 Laravel 進行全棧開發，你可能想查看我們的 [前端開發文檔](/docs/laravel/10.x/frontend)、[路由文檔](/docs/laravel/10.x/routing)、[視圖文檔](/docs/laravel/10.x/views) 或 [Eloquent ORM](/docs/laravel/10.x/eloquent)。此外，你可能會對學習像 [Livewire](https://laravel-livewire.com) 和 [Inertia](https://inertiajs.com) 這樣的社區包感興趣。這些包允許你將 Laravel 用作全棧框架，同時享受單頁 JavaScript 應用程序提供的許多 UI 好處。

如果你使用 Laravel 作為全棧框架，我們也強烈建議你學習如何使用 [Vite](/docs/laravel/10.x/vite) 編譯應用程序的 CSS 和 JavaScript 。

> 技巧：如果你想盡快構建你的應用程序，請查看我們的官方 [應用程序入門工具包](/docs/laravel/10.x/starter-kits)。

### Laravel API 後端 {#laravel-the-api-backend}

Laravel 也可以作為 JavaScript 單頁應用程序或移動應用程序的 API 後端。例如，你可以使用 Laravel 作為 [Next.js](https://nextjs.org) 應用程序的 API 後端。在這種情況下，你可以使用 Laravel 為你的應用程序提供 [身份驗證](/docs/laravel/10.x/sanctum) 和數據存儲/檢索，同時還可以利用 Laravel 的強大服務，例如隊列、電子郵件、通知等。

如果這是你計劃使用 Laravel 的方式，你可能需要查看我們關於 [路由](/docs/laravel/10.x/routing)，[Laravel Sanctum](/docs/laravel/10.x/sanctum) 和 [Eloquent ORM](/docs/laravel/10.x/eloquent) 的文檔。

> 技巧：需要搶先搭建 Laravel 後端和 Next.js 前端的腳手架？Laravel Breeze 提供了 [API 堆棧](/docs/laravel/10.x/starter-kitsmd#breeze-and-next) 以及 [Next.js 前端實現](https://github.com/laravel/breeze-next) ，因此你可以在幾分鐘內開始使用。
