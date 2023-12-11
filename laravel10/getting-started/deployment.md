# 部署

- [介紹](#introduction)
- [服務器要求](#server-requirements)
- [服務器配置](#server-configuration)
  - [Nginx](#nginx)
- [優化](#optimization)
  - [優化自動加載器](#autoloader-optimization)
  - [優化配置加載](#optimizing-configuration-loading)
  - [優化路由加載](#optimizing-route-loading)
  - [優化視圖加載](#optimizing-view-loading)
- [調試模式](#debug-mode)
- [使用 Forge / Vapor 進行部署](#deploying-with-forge-or-vapor)

## 介紹 {#introduction}

當你準備將 Laravel 應用程序部署到生產環境時，你可以做一些重要的事情來確保應用程序盡可能高效地運行。本文將會提供幾個範本以使你的 Laravel 應用部署妥當。

## 服務器要求 {#server-requirements}

Laravel 框架有一些系統要求。你應該確保你的 Web 服務器具有以下最低 PHP 版本和擴展：

- PHP >= 8.1
- Ctype PHP 擴展
- cURL PHP 擴展
- DOM PHP 擴展
- Fileinfo PHP 擴展
- Filter PHP 擴展
- Hash PHP 擴展
- Mbstring PHP 擴展
- OpenSSL PHP 擴展
- PCRE PHP 擴展
- PDO PHP 擴展
- Session PHP 擴展
- Tokenizer PHP 擴展
- XML PHP 擴展

## 服務器配置 {#server-configuration}

### Nginx {#nginx}

如果你將應用程序部署到運行 Nginx 的服務器上，你可以將以下配置文件作為為你的 Web 服務器配置的起點。最有可能需要根據你的服務器配置自定義此文件。**如果你需要管理服務器，請考慮使用官方的 Laravel 服務器管理和部署服務，如 [Laravel Forge](https://forge.laravel.com)。**

請確保像以下配置一樣，你的 Web 服務器將所有請求指向應用程序的 `public/index.php` 文件。永遠不要嘗試將 `index.php` 文件移動到項目的根目錄，因為從項目根目錄為應用提供服務會將許多敏感配置文件暴露到公網。

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name example.com;
    root /srv/example.com/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

## 優化 {#optimization}

### 優化自動加載器 {#autoloader-optimization}

在部署到生產環境時，請確保你正在優化 Composer 的類自動加載器映射，以便 Composer 可以快速找到適合給定類加載的文件：

```shell
composer install --optimize-autoloader --no-dev
```

> **注意**
> 除了優化自動加載器之外，你還應該始終確保在項目的源代碼控制存儲庫中包括一個 `composer.lock` 文件。存在 `composer.lock` 文件時，可以更快地安裝項目的依賴項。

### 優化配置加載 {#optimizing-configuration-loading}

在將應用程序部署到生產環境時，你應該確保在部署過中運行 `config:cache` Artisan 命令來提前對一些配置文件做一下緩存：

```shell
php artisan config:cache
```

這個命令將把 Laravel 的所有配置文件合並成一個緩存文件，大大減少框在加載配置值時必須進行的文件系統訪問次數。

> **警告**
> 如果你在部署過程中執行 `config:cache` 命令，應確保僅從配置文件中調用 `env` 函數。一旦配置已被緩存，`.env` 文件將不再被加載，所有對於 `.env` 變量 env 函數的調用將返回 null。

### 優化路由加載 {#optimizing-route-loading}

如果你正在構建一個包含許多路由的大型應用程序，你應該確保在部署過程中運行 `route:cache` Artisan 命令：

```shell
php artisan route:cache
```

這個命令將所有路由注冊縮減成單個方法調用且放入緩存文件中，提高注冊大量路由時的性能。

### 優化視圖加載 {#optimizing-view-loading}

在將應用程序部署到生產環境時，你應該確保在部署過程中運行 `view:cache` Artisan 命令：

```shell
php artisan view:cache
```

這個命令預編譯了所有的 Blade 視圖，使它們不再是按需編譯，因此可以提高返回視圖的每個請求的性能。

## 調試模式 {#debug-mode}

在 `config/app.php` 配置文件中，調試選項決定了有多少錯誤信息實際上會顯示給用戶。默認情況下，該選項設置為遵守 `APP_DEBUG` 環境變量的值，該值存儲在你的應用程序的 `.env` 文件中。

**在生產環境中，這個值應該永遠是 `false`。如果在生產環境中將 `APP_DEBUG` 變量的值設置為 `true`，則存在將敏感配置值暴露給應用程序最終用戶的風險。**

## 使用 Forge / Vapor 部署 {#deploying-with-forge-or-vapor}

#### Laravel Forge {#laravel-forge}

如果你還不準備好管理自己的服務器配置，或者對於配置運行一個強大的 Laravel 應用程序所需的各種服務不太熟悉，那麽 [Laravel Forge](https://forge.laravel.com) 是一個非常好的選擇。

Laravel Forge 可以在諸如Linode、AWS 等多種基礎設施服務提供商上創建服務器。此外，Forge 還安裝和管理構建強大的 Laravel 應用程序所需的所有工具，例如 Nginx、MySQL、Redis、Memcached、Beanstalk 等等。

> **注意**
> 想獲取 Laravel Forge 完整部署指南嗎？請查看 [Laravel Bootcamp](https://bootcamp.laravel.com/deploying) 和 [Laracasts 上提供的 Forge 視頻系列](https://laracasts.com/series/learn-laravel-forge-2022-edition)。

#### Vapor {#laravel-vapor}

如果你想要一個為 Laravel 調整的完全無服務器、自動擴展的部署平台，請看看 [Laravel Vapor](https://vapor.laravel.com)。Laravel Vapor 是一個由 AWS 提供支持的基於無服務器概念的 Laravel 部署平台。在 Vapor 上啟動你的 Laravel 基礎架構，並愛上無服務器的可擴展簡單性。Laravel Vapor 由 Laravel 的創作者進行了精細調校，以便與框架無縫協作，因此你可以像以前一樣繼續編寫 Laravel 應用程序。
