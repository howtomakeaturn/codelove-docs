# 文件存儲

- [簡介](#introduction)
- [配置](#configuration)
    - [本地驅動](#the-local-driver)
    - [公共磁盤](#the-public-disk)
    - [驅動先決要求](#driver-prerequisites)
    - [分區和只讀文件系統](#scoped-and-read-only-filesystems)
    - [Amazon S3 兼容文件系統](#amazon-s3-compatible-filesystems)
- [獲取磁盤實例](#obtaining-disk-instances)
    - [按需配置磁盤](#on-demand-disks)
- [檢索文件](#retrieving-files)
    - [下載文件](#downloading-files)
    - [文件 URL](#file-urls)
    - [臨時 URL](#temporary-urls)
    - [文件元數據](#file-metadata)
- [保存文件](#storing-files)
    - [預置和附加文件](#prepending-appending-to-files)
    - [覆制和移動文件](#copying-moving-files)
    - [自動流式傳輸](#automatic-streaming)
    - [文件上傳](#file-uploads)
    - [文件可見性](#file-visibility)
- [刪除文件](#deleting-files)
- [目錄](#directories)
- [測試](#testing)
- [自定義文件系統](#custom-filesystems)

<a name="introduction"></a>
## 簡介

Laravel 提供了一個強大的文件系統抽象，這要感謝 Frank de Jonge 的 [Flysystem](https://github.com/thephpleague/flysystem) PHP 包。Laravel 的 Flysystem 集成提供了 簡單的驅動來處理本地文件系統、SFTP 和 Amazon S3。更棒的是，在你的本地開發機器和生產服務器之間切換這些存儲選項是非常簡單的，因為每個系統的 API 都是一樣的。

<a name="configuration"></a>
## 配置

Laravel 的文件系統配置文件位於 `config/filesystems.php`。 在這個文件中，你可以配置你所有的文件系統「磁盤」。每個磁盤代表一個特定的存儲驅動器和存儲位置。 每種支持的驅動器的配置示例都包含在配置文件中, 因此你可以修改配置以反映你的存儲偏好和證書。

`local` 驅動用於與運行Laravel應用程序的服務器上存儲的文件進行交互，而 `s3` 驅動用於寫入 Amazon 的 S3 雲存儲服務。

> **注意**
> 你可以配置任意數量的磁盤，甚至可以添加多個使用相同驅動的磁盤。



<a name="the-local-driver"></a>
### 本地驅動

使用  `local` 驅動時，所有文件操作都與 `filesystems` 配置文件中定義的 `root` 目錄相關。 默認情況下，此值設置為 `storage/app` 目錄。因此，以下方法會把文件存儲在 `storage/app/example.txt`中：

    use Illuminate\Support\Facades\Storage;

    Storage::disk('local')->put('example.txt', 'Contents');

<a name="the-public-disk"></a>
### 公共磁盤

在 `filesystems` 配置文件中定義的 `public` 磁盤適用於要公開訪問的文件。默認情況下， `public` 磁盤使用 `local` 驅動，並且將這些文件存儲在 `storage/app/public`目錄下。

要使這些文件可從 web 訪問，應創建從 `public/storage` 到 `storage/app/public`的符號鏈接。這種方式能把可公開訪問文件都保留在同一個目錄下，以便在使用零停機時間部署系統如 [Envoyer](https://envoyer.io) 的時候，就可以輕松地在不同的部署之間共享這些文件。

你可以使用 Artisan 命令 `storage:link` 來創建符號鏈接：

```shell
php artisan storage:link
```

一旦一個文件被存儲並且已經創建了符號鏈接，你就可以使用輔助函數 `asset` 來創建文件的 URL：

    echo asset('storage/file.txt');

你可以在 `filesystems` 配置文件中配置額外的符號鏈接。這些鏈接將會在運行 `storage:link` 命令時自動創建：

    'links' => [
        public_path('storage') => storage_path('app/public'),
        public_path('images') => storage_path('app/images'),
    ],

<a name="driver-prerequisites"></a>


### 驅動先決要求

<a name="s3-driver-configuration"></a>
#### S3 驅動配置

在使用 S3 驅動之前，你需要通過 Composer 包管理器安裝 Flysystem S3 軟件包：

```shell
composer require league/flysystem-aws-s3-v3 "^3.0"
```

S3 驅動配置信息位於你的 `config/filesystems.php` 配置文件中。該文件包含一個 S3 驅動的示例配置數組。你可以自由使用自己的 S3 配置和憑證修改此數組。為方便起見，這些環境變量與 AWS CLI 使用的命名約定相匹配。

<a name="ftp-driver-configuration"></a>
#### FTP 驅動配置

在使用 FTP 驅動之前，你需要通過 Composer 包管理器安裝 Flysystem FTP 包：

```shell
composer require league/flysystem-ftp "^3.0"
```

Laravel 的 Flysystem 能與 FTP 很好的適配；然而，框架的默認 `filesystems.php` 配置文件中並未包含示例配置。如果你需要配置 FTP 文件系統，可以使用下面的配置示例：

    'ftp' => [
        'driver' => 'ftp',
        'host' => env('FTP_HOST'),
        'username' => env('FTP_USERNAME'),
        'password' => env('FTP_PASSWORD'),

        // 可選的 FTP 設置...
        // 'port' => env('FTP_PORT', 21),
        // 'root' => env('FTP_ROOT'),
        // 'passive' => true,
        // 'ssl' => true,
        // 'timeout' => 30,
    ],

<a name="sftp-driver-configuration"></a>
#### SFTP 驅動配置

在使用 SFTP 驅動之前，你需要通過 Composer 包管理器安裝 Flysystem SFTP 軟件包。

```shell
composer require league/flysystem-sftp-v3 "^3.0"
```

Laravel 的 Flysystem 能與 SFTP 很好的適配；然而，框架默認的 `filesystems.php` 配置文件中並未包含示例配置。如果你需要配置 SFTP 文件系統，可以使用下面的配置示例：

    'sftp' => [
        'driver' => 'sftp',
        'host' => env('SFTP_HOST'),

        // 基本認證的設置...
        'username' => env('SFTP_USERNAME'),
        'password' => env('SFTP_PASSWORD'),

        // 基於SSH密鑰的認證與加密密碼的設置...
        'privateKey' => env('SFTP_PRIVATE_KEY'),
        'passphrase' => env('SFTP_PASSPHRASE'),

        // 可選的SFTP設置...
        // 'hostFingerprint' => env('SFTP_HOST_FINGERPRINT'),
        // 'maxTries' => 4,
        // 'passphrase' => env('SFTP_PASSPHRASE'),
        // 'port' => env('SFTP_PORT', 22),
        // 'root' => env('SFTP_ROOT', ''),
        // 'timeout' => 30,
        // 'useAgent' => true,
    ],



### 驅動先決條件

<a name="s3-driver-configuration"></a>
#### S3 驅動配置

在使用 S3 驅動之前，你需要通過 Composer 安裝 Flysystem S3 包：

```shell
composer require league/flysystem-aws-s3-v3 "^3.0"
```

S3 驅動配置信息位於你的 `config/filesystems.php` 配置文件中。 此文件包含 S3 驅動的示例配置數組。 你可以使用自己的 S3 配置和憑據自由修改此數組。 為方便起見，這些環境變量與 AWS CLI 使用的命名約定相匹配。

<a name="ftp-driver-configuration"></a>
#### FTP 驅動配置

在使用 FTP 驅動之前，你需要通過 Composer 安裝 Flysystem FTP 包：

```shell
composer require league/flysystem-ftp "^3.0"
```

Laravel 的 Flysystem 集成與 FTP 配合得很好； 但是，框架的默認 `filesystems.php` 配置文件中不包含示例配置。 如果需要配置 FTP 文件系統，可以使用下面的配置示例：

    'ftp' => [
        'driver' => 'ftp',
        'host' => env('FTP_HOST'),
        'username' => env('FTP_USERNAME'),
        'password' => env('FTP_PASSWORD'),

        // 可選的 FTP 設置...
        // 'port' => env('FTP_PORT', 21),
        // 'root' => env('FTP_ROOT'),
        // 'passive' => true,
        // 'ssl' => true,
        // 'timeout' => 30,
    ],

<a name="sftp-driver-configuration"></a>
#### SFTP 驅動配置

在使用 SFTP 驅動之前，你需要通過 Composer 安裝 Flysystem SFTP 包：

```shell
composer require league/flysystem-sftp-v3 "^3.0"
```

Laravel 的 Flysystem 集成與 SFTP 配合得很好； 但是，框架的默認 `filesystems.php` 配置文件中不包含示例配置。 如果你需要配置 SFTP 文件系統，可以使用下面的配置示例：

    'sftp' => [
        'driver' => 'sftp',
        'host' => env('SFTP_HOST'),

        // 基本身份驗證設置...
        'username' => env('SFTP_USERNAME'),
        'password' => env('SFTP_PASSWORD'),

        // 基於SSH密鑰的加密密碼認證設置…
        'privateKey' => env('SFTP_PRIVATE_KEY'),
        'passphrase' => env('SFTP_PASSPHRASE'),

        // 可選的 SFTP 設置...
        // 'hostFingerprint' => env('SFTP_HOST_FINGERPRINT'),
        // 'maxTries' => 4,
        // 'passphrase' => env('SFTP_PASSPHRASE'),
        // 'port' => env('SFTP_PORT', 22),
        // 'root' => env('SFTP_ROOT', ''),
        // 'timeout' => 30,
        // 'useAgent' => true,
    ],



<a name="scoped-and-read-only-filesystems"></a>
### 分區和只讀文件系統

分區磁盤允許你定義一個文件系統，其中所有的路徑都自動帶有給定的路徑前綴。在創建一個分區文件系統磁盤之前，你需要通過 Composer 包管理器安裝一個額外的 Flysystem 包：

```shell
composer require league/flysystem-path-prefixing "^3.0"
```

你可以通過定義一個使用 `scoped` 驅動的磁盤來創建任何現有文件系統磁盤的路徑分區實例。例如，你可以創建一個磁盤，它將你現有的 `s3` 磁盤限定在特定的路徑前綴上，然後使用你的分區磁盤進行的每個文件操作都將使用指定的前綴：

```php
's3-videos' => [
    'driver' => 'scoped',
    'disk' => 's3',
    'prefix' => 'path/to/videos',
],
```

「只讀」磁盤允許你創建不允許寫入操作的文件系統磁盤。在使用 `read-only` 配置選項之前，你需要通過 Composer 包管理器安裝一個額外的 Flysystem 包：

```shell
composer require league/flysystem-read-only "^3.0"
```

接下來，你可以在一個或多個磁盤的配置數組中包含 `read-only` 配置選項：

```php
's3-videos' => [
    'driver' => 's3',
    // ...
    'read-only' => true,
],
```

<a name="amazon-s3-compatible-filesystems"></a>
### Amazon S3 兼容文件系統

默認情況下，你的應用程序的 `filesystems` 配置文件包含一個 `s3` 磁盤的磁盤配置。除了使用此磁盤與 Amazon S3 交互外，你還可以使用它與任何兼容 S3 的文件存儲服務（如 [MinIO](https://github.com/minio/minio) 或 [DigitalOcean Spaces](https://www.digitalocean.com/products/spaces/)）進行交互。

通常，在更新磁盤憑據以匹配你計劃使用的服務的憑據後，你只需要更新  `endpoint` 配置選項的值。此選項的值通常通過 `AWS_ENDPOINT` 環境變量定義：

    'endpoint' => env('AWS_ENDPOINT', 'https://minio:9000'),



<a name="minio"></a>
#### MinIO

為了讓 Laravel 的 Flysystem 集成在使用 MinIO 時生成正確的 URL，你應該定義 `AWS_URL` 環境變量，使其與你的應用程序的本地 URL 匹配，並在 URL 路徑中包含存儲桶名稱：

```ini
AWS_URL=http://localhost:9000/local
```

> **警告**
> 當使用 MinIO 時，不支持通過 `temporaryUrl` 方法生成臨時存儲 URL。

<a name="obtaining-disk-instances"></a>
## 獲取磁盤實例

`Storage` Facade 可用於與所有已配置的磁盤進行交互。例如，你可以使用 Facade 中的 `put` 方法將頭像存儲到默認磁盤。如果你在未先調用 `disk` 方法的情況下調用 `Storage` Facade 中的方法，則該方法將自動傳遞給默認磁盤：

    use Illuminate\Support\Facades\Storage;

    Storage::put('avatars/1', $content);

如果你的應用與多個磁盤進行交互，可使用 `Storage` Facade 中的 `disk` 方法對特定磁盤上的文件進行操作：

    Storage::disk('s3')->put('avatars/1', $content);

<a name="on-demand-disks"></a>
### 按需配置磁盤

有時你可能希望在運行時使用給定配置創建磁盤，而無需在應用程序的 `filesystems` 配置文件中實際存在該配置。為了實現這一點，你可以將配置數組傳遞給 `Storage` Facade 的 `build` 方法：

```php
use Illuminate\Support\Facades\Storage;

$disk = Storage::build([
    'driver' => 'local',
    'root' => '/path/to/root',
]);

$disk->put('image.jpg', $content);
```

<a name="retrieving-files"></a>
## 檢索文件

`get` 方法可用於檢索文件的內容。該方法將返回文件的原始字符串內容。切記，所有文件路徑的指定都應該相對於該磁盤所配置的「root」目錄：

    $contents = Storage::get('file.jpg');



`exists` 方法可以用來判斷一個文件是否存在於磁盤上：

    if (Storage::disk('s3')->exists('file.jpg')) {
        // ...
    }

`missing` 方法可以用來判斷一個文件是否缺失於磁盤上：

    if (Storage::disk('s3')->missing('file.jpg')) {
        // ...
    }

<a name="downloading-files"></a>
### 下載文件

`download` 方法可以用來生成一個響應，強制用戶的瀏覽器下載給定路徑的文件。`download` 方法接受一個文件名作為方法的第二個參數，這將決定用戶下載文件時看到的文件名。最後，你可以傳遞一個 HTTP 頭部的數組作為方法的第三個參數：

    return Storage::download('file.jpg');

    return Storage::download('file.jpg', $name, $headers);

<a name="file-urls"></a>
### 文件 URL

你可以使用 `url` 方法來獲取給定文件的 URL。如果你使用的是`local` 驅動，這通常只會在給定路徑前加上 `/storage`，並返回一個相對 URL 到文件。如果你使用的是 `s3` 驅動，將返回完全限定的遠程 URL：

    use Illuminate\Support\Facades\Storage;

    $url = Storage::url('file.jpg');

當使用 `local` 驅動時，所有應該公開訪問的文件都應放置在 `storage/app/public` 目錄中。此外，你應該在 `public/storage` 處 [創建一個符號連接](#the-public-disk) 指向 `storage/app/public` 目錄。

> **警告**
> 當使用 `local` 驅動時，url 的返回值不是 URL 編碼的。因此，我們建議始終使用能夠創建有效 URL 的名稱存儲文件。



<a name="url-host-customization"></a>
#### 定制 URL 的 Host

如果你想預定義使用 `Storage` Facade 生成的 URL 的 Host，則可以在磁盤的配置數組中添加一個 `url` 選項：

    'public' => [
        'driver' => 'local',
        'root' => storage_path('app/public'),
        'url' => env('APP_URL').'/storage',
        'visibility' => 'public',
    ],

<a name="temporary-urls"></a>
### 臨時 URL

使用 `temporaryUrl` 方法，你可以為使用 `s3` 驅動存儲的文件創建臨時 URL。此方法接受一個路徑和一個 `DateTime` 實例，指定 URL 的過期時間：

    use Illuminate\Support\Facades\Storage;

    $url = Storage::temporaryUrl(
        'file.jpg', now()->addMinutes(5)
    );

如果你需要指定額外的 [S3 請求參數](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGET.html#RESTObjectGET-requests)，你可以將請求參數數組作為第三個參數傳遞給`temporaryUrl` 方法。

    $url = Storage::temporaryUrl(
        'file.jpg',
        now()->addMinutes(5),
        [
            'ResponseContentType' => 'application/octet-stream',
            'ResponseContentDisposition' => 'attachment; filename=file2.jpg',
        ]
    );

如果你需要為一個特定的存儲磁盤定制臨時 URL 的創建方式，可以使用 `buildTemporaryUrlsUsing` 方法。例如，如果你有一個控制器允許你通過不支持臨時 URL 的磁盤下載存儲的文件，這可能很有用。通常，此方法應從服務提供者的 `boot` 方法中調用：

    <?php

    namespace App\Providers;

    use DateTime;
    use Illuminate\Support\Facades\Storage;
    use Illuminate\Support\Facades\URL;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * 啟動任何應用程序服務。
         */
        public function boot(): void
        {
            Storage::disk('local')->buildTemporaryUrlsUsing(
                function (string $path, DateTime $expiration, array $options) {
                    return URL::temporarySignedRoute(
                        'files.download',
                        $expiration,
                        array_merge($options, ['path' => $path])
                    );
                }
            );
        }
    }

<a name="url-host-customization"></a>
#### URL Host 自定義

如果你想為使用 `Storage` Facade 生成的 URL 預定義 Host，可以將 `url` 選項添加到磁盤的配置數組：

    'public' => [
        'driver' => 'local',
        'root' => storage_path('app/public'),
        'url' => env('APP_URL').'/storage',
        'visibility' => 'public',
    ],


<a name="temporary-upload-urls"></a>
#### 臨時上傳 URL

> **警告**
> 生成臨時上傳 URL 的能力僅由 `s3` 驅動支持。

如果你需要生成一個臨時 URL，可以直接從客戶端應用程序上傳文件，你可以使用 `temporaryUploadUrl` 方法。此方法接受一個路徑和一個 `DateTime` 實例，指定 URL 應該在何時過期。`temporaryUploadUrl` 方法返回一個關聯數組，可以解構為上傳 URL 和應該包含在上傳請求中的頭部：

    use Illuminate\Support\Facades\Storage;

    ['url' => $url, 'headers' => $headers] = Storage::temporaryUploadUrl(
        'file.jpg', now()->addMinutes(5)
    );

此方法主要用於無服務器環境，需要客戶端應用程序直接將文件上傳到雲存儲系統（如 Amazon S3）。

<a name="file-metadata"></a>
### 文件元數據

除了讀寫文件，Laravel 還可以提供有關文件本身的信息。例如，`size` 方法可用於獲取文件大小（以字節為單位）：

    use Illuminate\Support\Facades\Storage;

    $size = Storage::size('file.jpg');

`lastModified` 方法返回上次修改文件時的時間戳：

    $time = Storage::lastModified('file.jpg');

可以通過 `mimeType` 方法獲取給定文件的 MIME 類型：

    $mime = Storage::mimeType('file.jpg')

<a name="file-paths"></a>
#### 文件路徑

你可以使用 `path` 方法獲取給定文件的路徑。如果你使用的是 `local` 驅動，這將返回文件的絕對路徑。如果你使用的是 `s3` 驅動，此方法將返回 S3 存儲桶中文件的相對路徑：

    use Illuminate\Support\Facades\Storage;

    $path = Storage::path('file.jpg');

<a name="storing-files"></a>
## 保存文件

可以使用 `put` 方法將文件內容存儲在磁盤上。你還可以將 PHP `resource` 傳遞給 `put` 方法，該方法將使用 Flysystem 的底層流支持。請記住，應相對於為磁盤配置的「根」目錄指定所有文件路徑：

    use Illuminate\Support\Facades\Storage;

    Storage::put('file.jpg', $contents);

    Storage::put('file.jpg', $resource);

<a name="failed-writes"></a>
#### 寫入失敗

如果 `put` 方法（或其他「寫入」操作）無法將文件寫入磁盤，將返回 `false`。

    if (! Storage::put('file.jpg', $contents)) {
        // 該文件無法寫入磁盤...
    }

你可以在你的文件系統磁盤的配置數組中定義 `throw` 選項。當這個選項被定義為 `true` 時，「寫入」的方法如 `put` 將在寫入操作失敗時拋出一個 `League\Flysystem\UnableToWriteFile` 的實例。

    'public' => [
        'driver' => 'local',
        // ...
        'throw' => true,
    ],

<a name="prepending-appending-to-files"></a>
### 追加內容到文件開頭或結尾

`prepend` 和 `append` 方法允許你將內容寫入文件的開頭或結尾：

    Storage::prepend('file.log', 'Prepended Text');

    Storage::append('file.log', 'Appended Text');

<a name="copying-moving-files"></a>
### 覆制 / 移動文件

`copy` 方法可用於將現有文件覆制到磁盤上的新位置，而 `move` 方法可用於重命名現有文件或將其移動到新位置：

    Storage::copy('old/file.jpg', 'new/file.jpg');

    Storage::move('old/file.jpg', 'new/file.jpg');

<a name="automatic-streaming"></a>


### 自動流式傳輸

將文件流式傳輸到存儲位置可顯著減少內存使用量。如果你希望 Laravel 自動管理將給定文件流式傳輸到你的存儲位置，你可以使用 `putFile` 或 `putFileAs` 方法。此方法接受一個 `Illuminate\Http\File` 或 `Illuminate\Http\UploadedFile` 實例，並自動將文件流式傳輸到你所需的位置：

    use Illuminate\Http\File;
    use Illuminate\Support\Facades\Storage;

    // 為文件名自動生成一個唯一的 ID...
    $path = Storage::putFile('photos', new File('/path/to/photo'));

    // 手動指定一個文件名...
    $path = Storage::putFileAs('photos', new File('/path/to/photo'), 'photo.jpg');

關於 putFile 方法有幾點重要的注意事項。注意，我們只指定了目錄名稱而不是文件名。默認情況下，`putFile` 方法將生成一個唯一的 ID 作為文件名。文件的擴展名將通過檢查文件的 MIME 類型來確定。文件的路徑將由 `putFile` 方法返回，因此你可以將路徑（包括生成的文件名）存儲在數據庫中。

`putFile` 和 `putFileAs` 方法還接受一個參數來指定存儲文件的「可見性」。如果你將文件存儲在雲盤（如 Amazon S3）上，並希望文件通過生成的 URL 公開訪問，這一點特別有用：

    Storage::putFile('photos', new File('/path/to/photo'), 'public');

<a name="file-uploads"></a>
### 文件上傳

在網絡應用程序中，存儲文件的最常見用例之一是存儲用戶上傳的文件，如照片和文檔。Laravel 使用上傳文件實例上的 `store` 方法非常容易地存儲上傳的文件。使用你希望存儲上傳文件的路徑調用 `store` 方法：

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Http\Request;

    class UserAvatarController extends Controller
    {
        /**
         * 更新用戶的頭像。
         */
        public function update(Request $request): string
        {
            $path = $request->file('avatar')->store('avatars');

            return $path;
        }
    }


關於這個例子有幾點重要的注意事項。注意，我們只指定了目錄名稱而不是文件名。默認情況下，`store` 方法將生成一個唯一的 ID 作為文件名。文件的擴展名將通過檢查文件的 MIME 類型來確定。文件的路徑將由 `store` 方法返回，因此你可以將路徑（包括生成的文件名）存儲在數據庫中。

你也可以在 `Storage` Facade 上調用 `putFile` 方法來執行與上面示例相同的文件存儲操作：

    $path = Storage::putFile('avatars', $request->file('avatar'));

<a name="specifying-a-file-name"></a>
#### 指定一個文件名

如果你不希望文件名被自動分配給你存儲的文件，你可以使用 `storeAs` 方法，該方法接收路徑、文件名和（可選的）磁盤作為其參數：

    $path = $request->file('avatar')->storeAs(
        'avatars', $request->user()->id
    );

你也可以在 `Storage` Facade 使用 `putFileAs` 方法，它將執行與上面示例相同的文件存儲操作：

    $path = Storage::putFileAs(
        'avatars', $request->file('avatar'), $request->user()->id
    );

> **警告**
> 不可打印和無效的 Unicode 字符將自動從文件路徑中刪除。因此，你可能希望在將文件路徑傳遞給 Laravel 的文件存儲方法之前對其進行清理。文件路徑使用 `League\Flysystem\WhitespacePathNormalizer::normalizePath` 方法進行規範化。

<a name="specifying-a-disk"></a>
#### 指定一個磁盤

默認情況下，此上傳文件的 `store` 方法將使用你的默認磁盤。如果你想指定另一個磁盤，將磁盤名稱作為第二個參數傳遞給 `store` 方法：

    $path = $request->file('avatar')->store(
        'avatars/'.$request->user()->id, 's3'
    );


如果你正在使用 `storeAs` 方法，你可以將磁盤名稱作為第三個參數傳遞給該方法：

    $path = $request->file('avatar')->storeAs(
        'avatars',
        $request->user()->id,
        's3'
    );

<a name="other-uploaded-file-information"></a>
#### 其他上傳文件的信息

如果您想獲取上傳文件的原始名稱和擴展名，可以使用 `getClientOriginalName` 和 `getClientOriginalExtension` 方法來實現：

    $file = $request->file('avatar');

    $name = $file->getClientOriginalName();
    $extension = $file->getClientOriginalExtension();

然而，請記住，`getClientOriginalName` 和 `getClientOriginalExtension` 方法被認為是不安全的，因為文件名和擴展名可能被惡意用戶篡改。因此，你通常應該更喜歡使用 `hashName` 和 `extension` 方法來獲取給定文件上傳的名稱和擴展名：

    $file = $request->file('avatar');

    $name = $file->hashName(); // 生成一個唯一的、隨機的名字...
    $extension = $file->extension(); // 根據文件的 MIME 類型來確定文件的擴展名...

<a name="file-visibility"></a>
### 文件可見性

在 Laravel 的 Flysystem 集成中，「visibility」 是跨多個平台的文件權限的抽象。文件可以被聲明為 `public` 或 `private`。當一個文件被聲明為 `public` 時，你表示該文件通常應該被其他人訪問。例如，在使用 S3 驅動程序時，你可以檢索 `public` 文件的 URL。

你可以通過 `put` 方法在寫入文件時設置可見性：

    use Illuminate\Support\Facades\Storage;

    Storage::put('file.jpg', $contents, 'public');

如果文件已經被存儲，可以通過 `getVisibility` 和 `setVisibility` 方法檢索和設置其可見性：

    $visibility = Storage::getVisibility('file.jpg');

    Storage::setVisibility('file.jpg', 'public');


在與上傳文件交互時，你可以使用 `storePublicly` 和 `storePubliclyAs` 方法將上傳文件存儲為 `public` 可見性

    $path = $request->file('avatar')->storePublicly('avatars', 's3');

    $path = $request->file('avatar')->storePubliclyAs(
        'avatars',
        $request->user()->id,
        's3'
    );

<a name="local-files-and-visibility"></a>
#### 本地文件和可見性

當使用 `local` 驅動時，`public`[可見性](#file-visibility)轉換為目錄的 `0755` 權限和文件的 `0644` 權限。你可以在你的應用程序的 `filesystems` 配置文件中修改權限映射：

    'local' => [
        'driver' => 'local',
        'root' => storage_path('app'),
        'permissions' => [
            'file' => [
                'public' => 0644,
                'private' => 0600,
            ],
            'dir' => [
                'public' => 0755,
                'private' => 0700,
            ],
        ],
    ],

<a name="deleting-files"></a>
## 刪除文件

`delete` 方法接收一個文件名或一個文件名數組來將其從磁盤中刪除：

    use Illuminate\Support\Facades\Storage;

    Storage::delete('file.jpg');

    Storage::delete(['file.jpg', 'file2.jpg']);

如果需要，你可以指定應從哪個磁盤刪除文件。

    use Illuminate\Support\Facades\Storage;

    Storage::disk('s3')->delete('path/file.jpg');

<a name="directories"></a>
## 目錄

<a name="get-all-files-within-a-directory"></a>
#### 獲取目錄下所有的文件

`files` 將以數組的形式返回給定目錄下所有的文件。如果你想要檢索給定目錄的所有文件及其子目錄的所有文件，你可以使用 `allFiles` 方法：

    use Illuminate\Support\Facades\Storage;

    $files = Storage::files($directory);

    $files = Storage::allFiles($directory);

<a name="get-all-directories-within-a-directory"></a>
#### 獲取特定目錄下的子目錄

`directories` 方法以數組的形式返回給定目錄中的所有目錄。此外，你還可以使用 `allDirectories` 方法遞歸地獲取給定目錄中的所有目錄及其子目錄中的目錄：

    $directories = Storage::directories($directory);

    $directories = Storage::allDirectories($directory);



<a name="create-a-directory"></a>
#### 創建目錄

`makeDirectory` 方法可遞歸的創建指定的目錄：

    Storage::makeDirectory($directory);

<a name="delete-a-directory"></a>
#### 刪除一個目錄

最後，`deleteDirectory` 方法可用於刪除一個目錄及其下所有的文件：

    Storage::deleteDirectory($directory);

<a name="testing"></a>
## 測試

`Storage` 門面類的 `fake` 方法可以輕松創建一個虛擬磁盤，與`Illuminate\Http\UploadedFile` 類配合使用，大大簡化了文件的上傳測試。例如：

    <?php

    namespace Tests\Feature;

    use Illuminate\Http\UploadedFile;
    use Illuminate\Support\Facades\Storage;
    use Tests\TestCase;

    class ExampleTest extends TestCase
    {
        public function test_albums_can_be_uploaded(): void
        {
            Storage::fake('photos');

            $response = $this->json('POST', '/photos', [
                UploadedFile::fake()->image('photo1.jpg'),
                UploadedFile::fake()->image('photo2.jpg')
            ]);

            // 斷言存儲了一個或多個文件。
            Storage::disk('photos')->assertExists('photo1.jpg');
            Storage::disk('photos')->assertExists(['photo1.jpg', 'photo2.jpg']);

            // 斷言一個或多個文件未存儲。
            Storage::disk('photos')->assertMissing('missing.jpg');
            Storage::disk('photos')->assertMissing(['missing.jpg', 'non-existing.jpg']);

            // 斷言給定目錄為空。
            Storage::disk('photos')->assertDirectoryEmpty('/wallpapers');
        }
    }


默認情況下，`fake` 方法將刪除臨時目錄中的所有文件。如果你想保留這些文件，你可以使用 "persistentFake" 方法代替。有關測試文件上傳的更多信息，您可以查閱 [HTTP 測試文檔的文件上傳](/docs/laravel/10.x/http-tests#testing-file-uploads).

> **警告**
> `image` 方法需要 [GD 擴展](https://www.php.net/manual/en/book.image.php) .



<a name="custom-filesystems"></a>
## 自定義文件系統

Laravel 內置的文件系統提供了一些開箱即用的驅動；當然，它不僅僅是這些，它還提供了與其他存儲系統的適配器。通過這些適配器，你可以在你的 Laravel 應用中創建自定義驅動。

要安裝自定義文件系統，你可能需要一個文件系統適配器。讓我們將社區維護的 Dropbox 適配器添加到項目中：

```shell
composer require spatie/flysystem-dropbox
```

接下來，你可以在 [服務提供者](/docs/laravel/10.x/providers) 中注冊一個帶有 `boot` 方法的驅動。在提供者的 `boot` 方法中，你可以使用 `Storage` 門面的 `extend` 方法來定義一個自定義驅動：

    <?php

    namespace App\Providers;

    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Filesystem\FilesystemAdapter;
    use Illuminate\Support\Facades\Storage;
    use Illuminate\Support\ServiceProvider;
    use League\Flysystem\Filesystem;
    use Spatie\Dropbox\Client as DropboxClient;
    use Spatie\FlysystemDropbox\DropboxAdapter;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * 注冊任意應用程序服務。
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
            Storage::extend('dropbox', function (Application $app, array $config) {
                $adapter = new DropboxAdapter(new DropboxClient(
                    $config['authorization_token']
                ));

                return new FilesystemAdapter(
                    new Filesystem($adapter, $config),
                    $adapter,
                    $config
                );
            });
        }
    }

`extend` 方法的第一個參數是驅動程序的名稱，第二個參數是接收 `$app` 和 `$config` 變量的閉包。閉包必須返回的實例 `League\Flysystem\Filesystem`。`$config` 變量包含 `config/filesystems.php` 為指定磁盤定義的值。

一旦創建並注冊了擴展的服務提供商，就可以 `dropbox` 在 `config/filesystems.php` 配置文件中使用該驅動程序。
