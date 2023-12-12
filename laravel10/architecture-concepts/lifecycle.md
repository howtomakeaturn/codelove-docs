
# 請求的生命周期

- [簡介](#introduction)
- [生命周期概述](#lifecycle-overview)
    - [第一步](#first-steps)
    - [HTTP / Console 內核](#http-console-kernels)
    - [服務提供者](#service-providers)
    - [路由](#routing)
    - [請求結束](#finishing-up)
- [關注服務提供者](#focus-on-service-providers)

<a name="introduction"></a>
## 簡介

在「真實世界」中使用任何工具時，如果你了解該工具的工作原理，你會更加自信。應用程序開發也不例外。當您了解開發工具的功能時，你會覺得使用它們更舒服、更自信。

本文的目的是讓您對 Laravel 框架的工作原理有一個良好的、高層次的理解。通過更好地了解整個框架，一切感覺都不那麽「神奇」，你將更有信心構建你的應用程序。如果你不明白所有的規則，不要灰心！只要試著對正在發生的事情有一個基本的掌握，你的知識就會隨著你探索文檔的其他部分而增長。

<a name="lifecycle-overview"></a>
## 生命周期概述

<a name="first-steps"></a>
### 第一步

Laravel 應用程序的所有請求的入口點都是 `public/index.php` 文件。所有請求都由你的 web 服務器（Apache/Nginx）配置定向到此文件。那個 `index.php` 文件不包含太多代碼。相反，它是加載框架其余部分的起點。

`index.php` 文件將加載 Composer 生成的自動加載器定義，然後從 `bootstrap/app.php` 中檢索 Laravel 應用程序的實例。Laravel 本身采取的第一個操作是創建應用 / [服務容器](/docs/laravel/10.x/container) 的實例。



<a name="http-console-kernels"></a>
### HTTP / Console 內核

接下來，根據進入應用的請求類型，傳入的請求將被發送到 HTTP 內核或者 Console 內核。這兩個內核充當所有請求流經的中心位置。現在，我們只關注位於`app/Http/Kernel.php`中的 HTTP 內核。

HTTP 內核繼承了`Illuminate\Foundation\Http\Kernel`類，該類定義了一個將在執行請求之前運行的`bootstrappers` 數組。這些引導程序用來配置異常處理、配置日志、[檢測應用程序環境](/docs/laravel/10.x/configuration#environment-configuration)，並執行在實際處理請求之前需要完成的其他任務。通常，這些類處理你無需擔心的內部 Laravel 配置。

HTTP 內核還定義了一個 HTTP [中間件](/docs/laravel/10.x/middleware)列表，所有請求在被應用程序處理之前都必須通過該列表。這些中間件處理讀寫[HTTP 會話](/docs/laravel/10.x/session) ，確定應用程序是否處於維護模式， [校驗 CSRF 令牌](/docs/laravel/10.x/csrf), 等等。我們接下來會做詳細的討論。

HTTP 內核的`handle`方法的簽名非常簡單：它接收`Request`接口並返回`Response`接口。把內核想象成一個代表整個應用程序的大黑匣子。向它提供 HTTP 請求，它將返回 HTTP 響應。

<a name="service-providers"></a>
### 服務提供者

最重要的內核引導操作之一是為應用程序加載[服務提供者 ](/docs/laravel/10.x/providers)。應用程序的所有服務提供程序都在`config/app.php`文件中的`providers` 數組。



Laravel 將遍歷這個提供者列表並實例化它們中的每一個。實例化提供程序後，將在所有提供程序上調用`register`方法。然後，一旦所有的提供者都被注冊了，就會對每個提供程序調用`boot`方法。服務提供者可能依賴於在執行`boot`方法時注冊並可用的每個容器綁定。

服務提供者負責引導框架的所有不同組件，如數據庫、隊列、驗證和路由組件。基本上，Laravel 提供的每個主要功能都是由服務提供商引導和配置的。由於它們引導和配置框架提供的許多特性，服務提供者是整個 Laravel 引導過程中最重要的部分。

<a name="routing"></a>
### 路由

應用程序中最重要的服務提供者之一是`App\Providers\RouteServiceProvider`。此服務提供者加載應用程序的`routes`目錄中包含的路由文件。繼續，打開`RouteServiceProvider`代碼，看看它是如何工作的！

一旦應用程序被引導並且所有服務提供者都被注冊，`Request`將被傳遞給路由器進行調度。路由器將請求發送到路由或控制器，並運行任何路由特定的中間件。

中間件為過濾或檢查進入應用程序的 HTTP 請求提供了一種方便的機制。例如，Laravel 包含一個這樣的中間件，用於驗證應用程序的用戶是否經過身份驗證。如果用戶未通過身份驗證，中間件將用戶重定向到登錄頁。但是，如果用戶經過身份驗證，中間件將允許請求進一步進入應用程序。一些中間件被分配給應用程序中的所有路由，比如那些在 HTTP 內核的`$middleware`屬性中定義的路由，而一些只被分配給特定的路由或路由組。你可以通過閱讀完整的[中間件文檔](/docs/laravel/10.x/middleware)來了解關於中間件的信息。


如果請求通過了所有匹配路由分配的中間件，則執行路由或控制器方法，並通過路由的中間件鏈路返回路由或控制器方法的響應。

<a name="finishing-up"></a>
### 最後

一旦路由或控制器方法返回一個響應，該響應將通過路由的中間件返回，從而使應用程序有機會修改或檢查傳出的響應。

最後，一旦響應通過中間件返回，HTTP 內核的`handle`方法將返回響應對象，並且`index.php`文件在返回的響應上調用`send`方法。`send`方法將響應內容發送到用戶的 Web 瀏覽器。至此，我們已經完成了整個 Laravel 請求生命周期的旅程！

<a name="focus-on-service-providers"></a>
## 關注服務提供者

服務提供者確實是引導 Laravel 應用程序的關鍵。創建應用程序實例，注冊服務提供者，並將請求傳遞給引導應用程序。就這麽簡單！

牢牢掌握服務提供者的構建和其對 Laravel 應用處理機制的原理是非常有價值的。你的應用的默認服務提供會存放在`app/Providers`目錄下面。

默認情況下，`AppServiceProvider`是空白的。這里是用於你添加應用自身的引導處理和服務容器綁定的一個非常棒的地方。在大型項目中，你可能希望創建多個服務提供者，每個服務提供者都為應用程序使用的特定服務提供更細粒度的引導。
