# Artisan 命令行

- [介紹](#introduction)
    - [Tinker 命令 (REPL)](#tinker)
- [編寫命令](#writing-commands)
    - [生成命令](#generating-commands)
    - [命令結構](#command-structure)
    - [閉包命令](#closure-commands)
    - [單例命令](#isolatable-commands)
- [定義輸入期望值](#defining-input-expectations)
    - [參數](#arguments)
    - [選項](#options)
    - [輸入數組](#input-arrays)
    - [輸入說明](#input-descriptions)
- [I/O 命令](#command-io)
    - [檢索輸入](#retrieving-input)
    - [輸入提示](#prompting-for-input)
    - [編寫輸出](#writing-output)
- [注冊命令](#registering-commands)
- [在程序中執行命令](#programmatically-executing-commands)
    - [從其他命令調用命令](#calling-commands-from-other-commands)
- [信號處理](#signal-handling)
- [Stub 自定義](#stub-customization)
- [事件](#events)

<a name="introduction"></a>
## 介紹

Artisan 是 Laravel 中自帶的命令行接口。Artisan 以 `artisan ` 腳本的方式存在於應用的根目錄中，提供了許多有用的命令，幫助開發者創建應用。使用 `list` 命令可以查看所有可用的Artisan 命令：

```shell
php artisan list
```

每個命令都與 "help" 幫助界面，它能顯示和描述該命令可用的參數和選項。要查看幫助界面，請在命令前加上 `help` 即可：

```shell
php artisan help migrate
```

<a name="laravel-sail"></a>
#### Laravel Sail

如果你使用 [Laravel Sail](/docs/laravel/10.x/sail) 作為本地開發環境，記得使用 `sail` 命令行來調用 Artisan 命令。Sail 會在應用的 Docker容器中執行 Artisan 命令：

```shell
./vendor/bin/sail artisan list
```

<a name="tinker"></a>
### Tinker (REPL)

Laravel Tinker 是為 Laravel 提供的強大的 REPL（交互式解釋器），由 PsySH(https://github.com/bobthecow/psysh) 驅動支持。



<a name="installation"></a>
#### 安裝

所有的 Laravel 應用默認都自帶 Tinker。不過，如果你此前刪除了它，你可以使用 Composer 安裝：

```shell
composer require laravel/tinker
```

> **注意**
> 需要能與 Laravel 交互的圖形用戶界面嗎？試試 [Tinkerwell](https://tinkerwell.app)!

<a name="usage"></a>
#### 使用

Tinker 允許你在命令行中和整個 Laravel 應用交互，包括 Eloquent 模型、隊列、事件等等。要進入 Tinker 環境，只需運行 `tinker` Artisan 命令：

```shell
php artisan tinker
```

你可以使用 `vendor:publish` 命令發布 Tinker 的配置文件：

```shell
php artisan vendor:publish --provider="Laravel\Tinker\TinkerServiceProvider"
```

> **警告**
> `dispatch` 輔助函數及 `Dispatchable` 類中 `dispatch` 方法依賴於垃圾回收將任務放置到隊列中。因此，使用 tinker 時，請使用 `Bus::dispath` 或 `Queue::push` 來分發任務。

<a name="command-allow-list"></a>
#### 命令白名單

Tinker 使用白名單來確定哪些 Artisan 命令可以在其 Shell 中運行。默認情況下，你可以運行 `clear-compiled`、`down`、`env`、`inspire`、`migrate`、`optimize` 和 `up` 命令。如果你想允許更多命令，你可以將它們添加到 `tinker.php` 配置文件的 `commands` 數組中：

    'commands' => [
        // App\Console\Commands\ExampleCommand::class,
    ],

<a name="classes-that-should-not-be-aliased"></a>
#### 別名黑名單

一般而言，Tinker 會在你引入類時自動為其添加別名。不過，你可能不希望為某些類添加別名。你可以在 `tinker.php` 配置文件的 `dont_alias` 數組中列舉這些類來完成此操作：

    'dont_alias' => [
        App\Models\User::class,
    ],



<a name="writing-commands"></a>
## 編寫命令

除了 Artisan 提供的命令之外，你可以創建自定義命令。一般而言，命令保存在 `app/Console/Commands` 目錄；不過，你可以自由選擇命令的存儲位置，只要它能夠被 Composer 加載即可。

<a name="generating-commands"></a>
### 生成命令

要創建新命令，可以使用 `make:command` Artisan 命令。該命令會在 `app/Console/Commands` 目錄下創建一個新的命令類。如果該目錄不存在，也無需擔心 - 它會在第一次運行 `make:command` Artisan 命令的時候自動創建：

```shell
php artisan make:command SendEmails
```

<a name="command-structure"></a>
### 命令結構

生成命令後，應該為該類的 `signature` 和 `description` 屬性設置設當的值。當在 list 屏幕上顯示命令時，將使用這些屬性。`signature` 屬性也會讓你定義[命令輸入預期值](#defining-input-expectations)。`handle` 方法會在命令執行時被調用。你可以在該方法中編寫命令邏輯。

讓我們看一個示例命令。請注意，我們能夠通過命令的 `handle` 方法引入我們需要的任何依賴項。Laravel [服務容器](https://learnku.com/docs/laravel/9.x/container) 將自動注入此方法簽名中帶有類型提示的所有依賴項：

    <?php

    namespace App\Console\Commands;

    use App\Models\User;
    use App\Support\DripEmailer;
    use Illuminate\Console\Command;

    class SendEmails extends Command
    {
        /**
         * 控制台命令的名稱和簽名
         *
         * @var string
         */
        protected $signature = 'mail:send {user}';

        /**
         * 命令描述
         *
         * @var string
         */
        protected $description = 'Send a marketing email to a user';

        /**
         * 執行命令
         */
        public function handle(DripEmailer $drip): void
        {
            $drip->send(User::find($this->argument('user')));
        }
    }

> **注意**
> 為了更好地覆用代碼，請盡量讓你的命令類保持輕量並且能夠延遲到應用服務中完成。上例中，我們注入了一個服務類來進行發送電子郵件的「繁重工作」。



<a name="closure-commands"></a>
### 閉包命令

基於閉包的命令為將控制台命令定義為類提供了一種替代方法。與路由閉包可以替代控制器一樣，可以將命令閉包視為命令類的替代。在 `app/Console/Kernel.php` 文件的  `commands` 方法中 ，Laravel 加載 `routes/console.php` 文件：

    /**
     * 注冊閉包命令
     */
    protected function commands(): void
    {
        require base_path('routes/console.php');
    }

盡管該文件沒有定義 HTTP 路由，但它定義了進入應用程序的基於控制台的入口 (routes) 。在這個文件中，你可以使用 `Artisan::command` 方法定義所有的閉包路由。 `command` 方法接受兩個參數： [命令名稱](#defining-input-expectations) 和可調用的閉包，閉包接收命令的參數和選項：

    Artisan::command('mail:send {user}', function (string $user) {
        $this->info("Sending email to: {$user}!");
    });

該閉包綁定到基礎命令實例，因此你可以完全訪問通常可以在完整命令類上訪問的所有輔助方法。

<a name="type-hinting-dependencies"></a>
#### Type-Hinting Dependencies

除了接受命令參數及選項外，命令閉包也可以使用類型約束從 [服務容器](/docs/laravel/10.x/container) 中解析其他的依賴關系：

    use App\Models\User;
    use App\Support\DripEmailer;

    Artisan::command('mail:send {user}', function (DripEmailer $drip, string $user) {
        $drip->send(User::find($user));
    });

<a name="closure-command-descriptions"></a>
#### 閉包命令說明

在定義基於閉包的命令時，可以使用 `purpose` 方法向命令添加描述。當你運行 `php artisan list` 或 `php artisan help` 命令時，將顯示以下描述：

    Artisan::command('mail:send {user}', function (string $user) {
        // ...
    })->purpose('Send a marketing email to a user');



<a name="isolatable-commands"></a>
### 單例命令

> **警告**
> 要使用該特性，應用必須使用 `memcached`、`redis`、`dynamodb`、`database`、`file` 或 `array` 作為默認的緩存驅動。另外，所有的服務器必須與同一個中央緩存服務器通信。

有時您可能希望確保一次只能運行一個命令實例。為此，你可以在命令類上實現 `Illuminate\Contracts\Console\Isolatable` 接口：

    <?php

    namespace App\Console\Commands;

    use Illuminate\Console\Command;
    use Illuminate\Contracts\Console\Isolatable;

    class SendEmails extends Command implements Isolatable
    {
        // ...
    }

當命令被標記為 `Isolatable` 時，Laravel 會自動為該命令添加 `--isolated` 選項。當命令中使用這一選項時，Laravel 會確保不會有該命令的其他實例同時運行。Laravel 通過在應用的默認緩存驅動中使用原子鎖來實現這一功能。如果這一命令有其他實例在運行，則該命令不會執行；不過，該命令仍然會使用成功退出狀態碼退出：

```shell
php artisan mail:send 1 --isolated
```

如果你想自己指定命令無法執行時返回的退出狀態碼，你可用通過 `isolated` 選項提供：

```shell
php artisan mail:send 1 --isolated=12
```

<a name="lock-expiration-time"></a>
#### 原子鎖到期時間

默認情況下，單例鎖會在命令完成後過期。或者如果命令被打斷且無法完成的話，鎖會在一小時後過期。不過你也可以通過定義命令的 `isolationLockExpiresAt` 方法來調整過期時間：

```php
use DateTimeInterface;
use DateInterval;

/**
 * 定義單例鎖的到期時間
 */
public function isolationLockExpiresAt(): DateTimeInterface|DateInterval
{
    return now()->addMinutes(5);
}
```



<a name="defining-input-expectations"></a>
## 定義輸入期望

在編寫控制台命令時，通常是通過參數和選項來收集用戶輸入的。 Laravel 讓你可以非常方便地在 `signature` 屬性中定義你期望用戶輸入的內容。`signature` 屬性允許使用單一且可讀性高，類似路由的語法來定義命令的名稱、參數和選項。

<a name="arguments"></a>
### 參數

用戶提供的所有參數和選項都用花括號括起來。在下面的示例中，該命令定義了一個必需的參數 `user`:

    /**
     * 命令的名稱及其標識
     *
     * @var string
     */
    protected $signature = 'mail:send {user}';

你亦可創建可選參數或為參數定義默認值：

    // 可選參數...
    'mail:send {user?}'

    // 帶有默認值的可選參數...
    'mail:send {user=foo}'

<a name="options"></a>
### 選項

選項類似於參數，是用戶輸入的另一種形式。在命令行中指定選項的時候，它們以兩個短橫線 (`--`) 作為前綴。這有兩種類型的選項：接收值和不接受值。不接收值的選項就像是一個布爾「開關」。我們來看一下這種類型的選項的示例：

    /**
     * 命令的名稱及其標識
     *
     * @var string
     */
    protected $signature = 'mail:send {user} {--queue}';

在這個例子中，在調用 Artisan 命令時可以指定 `--queue` 的開關。如果傳遞了 `--queue` 選項，該選項的值將會是 `true`。否則，其值將會是 `false`：

```shell
php artisan mail:send 1 --queue
```



<a name="options-with-values"></a>
#### 帶值的選項

接下來，我們來看一下需要帶值的選項。如果用戶需要為一個選項指定一個值，則需要在選項名稱的末尾追加一個 `=` 號：

    /**
     * 命令名稱及標識
     *
     * @var string
     */
    protected $signature = 'mail:send {user} {--queue=}';

在這個例子中，用戶可以像如下所時的方式傳遞該選項的值。如果在調用命令時未指定該選項，則其值為 `null`：

```shell
php artisan mail:send 1 --queue=default
```

你還可以在選項名稱後指定其默認值。如果用戶沒有傳遞值給選項，將使用默認的值：

    'mail:send {user} {--queue=default}'

<a name="option-shortcuts"></a>
#### 選項簡寫

要在定義選項的時候指定一個簡寫，你可以在選項名前面使用 `|` 隔符將選項名稱與其簡寫分隔開來：

    'mail:send {user} {--Q|queue}'

在終端上調用命令時，選項簡寫的前綴只用一個連字符，在為選項指定值時不應該包括`=`字符。

```shell
php artisan mail:send 1 -Qdefault
```

<a name="input-arrays"></a>
### 輸入數組

如果你想要接收數組數組的參數或者選項，你可以使用 `*` 字符。首先，讓我們看一下指定了一個數組參數的例子：

    'mail:send {user*}'

當調用這個方法的時候，`user` 參數的輸入參數將按順序傳遞給命令。例如，以下命令將會設置 `user` 的值為 `foo` 和 `bar` ：

```shell
php artisan mail:send 1 2
```



 `*` 字符可以與可選的參數結合使用，允許您定義零個或多個參數實例：

    'mail:send {user?*}'

<a name="option-arrays"></a>
#### 選項數組

當定義需要多個輸入值的選項時，傳遞給命令的每個選項值都應以選項名稱作為前綴：

    'mail:send {--id=*}'

這樣的命令可以通過傳遞多個 `--id` 參數來調用：

```shell
php artisan mail:send --id=1 --id=2
```

<a name="input-descriptions"></a>
### 輸入說明

你可以通過使用冒號將參數名稱與描述分隔來為輸入參數和選項指定說明。如果你需要一些額外的空間來定義命令，可以將它自由的定義在多行中：

    /**
     * 控制台命令的名稱和簽名。
     *
     * @var string
     */
    protected $signature = 'mail:send
                            {user : The ID of the user}
                            {--queue : Whether the job should be queued}';

<a name="command-io"></a>
## 命令 I/O

<a name="retrieving-input"></a>
### 檢索輸入

當命令在執行時，你可能需要訪問命令所接受的參數和選項的值。為此，你可以使用 `argument` 和 `option` 方法。如果選項或參數不存在，將會返回`null`：

    /**
     * 執行控制台命令。
     */
    public function handle(): void
    {
        $userId = $this->argument('user');
    }

如果你需要檢索所有的參數做為 `array`，請調用 `arguments` 方法：

    $arguments = $this->arguments();

選項的檢索與參數一樣容易，使用 `option` 方法即可。如果要檢索所有的選項做為數組，請調用 `options` 方法：

    // 檢索一個指定的選項...
    $queueName = $this->option('queue');

    // 檢索所有選項做為數組...
    $options = $this->options();



<a name="prompting-for-input"></a>
### 交互式輸入

除了顯示輸出以外，你還可以要求用戶在執行命令期間提供輸入。`ask` 方法將詢問用戶指定的問題來接收用戶輸入，然後用戶輸入將會傳到你的命令中：

    /**
     * 執行命令指令
     */
    public function handle(): void
    {
        $name = $this->ask('What is your name?');

        // ...
    }

`secret` 方法與 `ask` 相似，區別在於用戶的輸入將不可見。這個方法在需要輸入一些諸如密碼之類的敏感信息時是非常有用的：

    $password = $this->secret('What is the password?');

<a name="asking-for-confirmation"></a>
#### 請求確認

如果你需要請求用戶進行一個簡單的確認，可以使用 `confirm` 方法來實現。默認情況下，這個方法會返回 `false`。當然，如果用戶輸入 `y` 或 `yes`，這個方法將會返回 `true`。

    if ($this->confirm('Do you wish to continue?')) {
        // ...
    }

如有必要，你可以通過將 `true` 作為第二個參數傳遞給 `confirm` 方法，這樣就可以在默認情況下返回 `true`：

    if ($this->confirm('Do you wish to continue?', true)) {
        // ...
    }

<a name="auto-completion"></a>
#### 自動補全

`anticipate` 方法可用於為可能的選項提供自動補全功能。用戶依然可以忽略自動補全的提示，進行任意回答：

    $name = $this->anticipate('What is your name?', ['Taylor', 'Dayle']);

或者，你可以將一個閉包作為第二個參數傳遞給 `anticipate` 方法。每當用戶鍵入字符時，閉包函數都會被調用。閉包函數應該接受一個包含用戶輸入的字符串形式的參數，並返回一個可供自動補全的選項的數組：

    $name = $this->anticipate('What is your address?', function (string $input) {
        // 返回自動完成配置...
    });



<a name="multiple-choice-questions"></a>
#### 多選擇問題

當詢問問題時，如果你需要給用戶一個預定義的選擇，你可以使用 `choice` 方法。如果沒有選項被選擇，你可以設置數組索引的默認值去返回，通過這個方法的第三個參數去傳入索引：

    $name = $this->choice(
        'What is your name?',
        ['Taylor', 'Dayle'],
        $defaultIndex
    );

此外， `choice` 方法接受第四和第五可選參數 ，用於確定選擇有效響應的最大嘗試次數以及是否允許多次選擇：

    $name = $this->choice(
        'What is your name?',
        ['Taylor', 'Dayle'],
        $defaultIndex,
        $maxAttempts = null,
        $allowMultipleSelections = false
    );

<a name="writing-output"></a>
### 文字輸出

你可以使用 `line`，`info`，`comment`，`question` 和 `error` 方法，發送輸出到控制台。 這些方法中的每一個都會使用合適的 ANSI 顏色以展示不同的用途。例如，我們要為用戶展示一些常規信息。通常，`info` 將會以綠色文本在控制台展示。

    /**
     * Execute the console command.
     */
    public function handle(): void
    {
        // ...

        $this->info('The command was successful!');
    }

輸出錯誤信息，使用 `error` 方法。錯誤信息通常使用紅色字體顯示：

    $this->error('Something went wrong!');

你可以使用 `line` 方法輸出無色文本：

    $this->line('Display this on the screen');

你可以使用 `newLine` 方法輸出空白行：

    // 輸出單行空白...
    $this->newLine();

    // 輸出三行空白...
    $this->newLine(3);



<a name="tables"></a>
#### 表格

`table` 方法可以輕松正確地格式化多行/多列數據。你需要做的就是提供表的列名和數據，Laravel 會自動為你計算合適的表格寬度和高度：

    use App\Models\User;

    $this->table(
        ['Name', 'Email'],
        User::all(['name', 'email'])->toArray()
    );

<a name="progress-bars"></a>
#### 進度條

對於長時間運行的任務，顯示一個進度條來告知用戶任務的完成情況會很有幫助。使用 `withProgressBar` 方法，Laravel 將顯示一個進度條，並在給定的可叠代值上推進每次叠代的進度：

    use App\Models\User;

    $users = $this->withProgressBar(User::all(), function (User $user) {
        $this->performTask($user);
    });

有時，你可能需要更多手動控制進度條的前進方式。首先，定義流程將叠代的步驟總數。然後，在處理完每個項目後推進進度條：

    $users = App\Models\User::all();

    $bar = $this->output->createProgressBar(count($users));

    $bar->start();

    foreach ($users as $user) {
        $this->performTask($user);

        $bar->advance();
    }

    $bar->finish();

> **技巧：**有關更多高級選項，請查看 [Symfony 進度條組件文檔](https://symfony.com/doc/current/components/console/helpers/progressbar.html).

<a name="registering-commands"></a>
## 注冊命令

你的所有控制台命令都在您的應用程序的 `App\Console\Kernel` 類中注冊，這是你的應用程序的「控制台內核」。在此類的 `commands` 方法中，你將看到對內核的 `load` 方法的調用。 `load` 方法將掃描 `app/Console/Commands` 目錄並自動將其中包含的每個命令注冊到 Artisan。 你甚至可以自由地調用 `load` 方法來掃描其他目錄以查找 Artisan 命令：

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');
        $this->load(__DIR__.'/../Domain/Orders/Commands');

        // ...
    }



如有必要，你可以通過將命令的類名添加到 `App\Console\Kernel` 類中的 `$commands` 屬性來手動注冊命令。如果你的內核上尚未定義此屬性，則應手動定義它。當 Artisan 啟動時，此屬性中列出的所有命令將由 [服務容器](/docs/laravel/10.x/container) 解析並注冊到 Artisan：

    protected $commands = [
        Commands\SendEmails::class
    ];

<a name="programmatically-executing-commands"></a>
## 以編程方式執行命令

有時你可能希望在 CLI 之外執行 Artisan 命令。例如，你可能希望從路由或控制器執行 Artisan 命令。你可以使用 `Artisan` 外觀上的 `call` 方法來完成此操作。 `call` 方法接受命令的簽名名稱或類名作為其第一個參數，以及一個命令參數數組作為第二個參數。將返回退出代碼：

    use Illuminate\Support\Facades\Artisan;

    Route::post('/user/{user}/mail', function (string $user) {
        $exitCode = Artisan::call('mail:send', [
            'user' => $user, '--queue' => 'default'
        ]);

        // ...
    });

或者，你可以將整個 Artisan 命令作為字符串傳遞給 `call` 方法：

    Artisan::call('mail:send 1 --queue=default');

<a name="passing-array-values"></a>
#### 傳遞數組值

如果你的命令定義了一個接受數組的選項，你可以將一組值傳遞給該選項：

    use Illuminate\Support\Facades\Artisan;

    Route::post('/mail', function () {
        $exitCode = Artisan::call('mail:send', [
            '--id' => [5, 13]
        ]);
    });

<a name="passing-boolean-values"></a>
#### 傳遞布爾值

如果你需要指定不接受字符串值的選項的值，例如 `migrate:refresh` 命令上的 `--force` 標志，則應傳遞 `true` 或 `false` 作為 選項：

    $exitCode = Artisan::call('migrate:refresh', [
        '--force' => true,
    ]);



<a name="queueing-artisan-commands"></a>
#### 隊列 Artisan 命令

使用 `Artisan` 門面的 `queue` 方法，你甚至可以對 Artisan 命令進行排隊，以便你的 [隊列工作者](/docs/laravel/10.x/queues) 在後台處理它們。在使用此方法之前，請確保你已配置隊列並正在運行隊列偵聽器：

    use Illuminate\Support\Facades\Artisan;

    Route::post('/user/{user}/mail', function (string $user) {
        Artisan::queue('mail:send', [
            'user' => $user, '--queue' => 'default'
        ]);

        // ...
    });

使用 `onConnection` 和 `onQueue` 方法，你可以指定 Artisan 命令應分派到的連接或隊列：

    Artisan::queue('mail:send', [
        'user' => 1, '--queue' => 'default'
    ])->onConnection('redis')->onQueue('commands');

<a name="calling-commands-from-other-commands"></a>
### 從其他命令調用命令

有時你可能希望從現有的 Artisan 命令調用其他命令。你可以使用 `call` 方法來執行此操作。這個 `call` 方法接受命令名稱和命令參數/選項數組：

    /**
     * Execute the console command.
     */
    public function handle(): void
    {
        $this->call('mail:send', [
            'user' => 1, '--queue' => 'default'
        ]);

        // ...
    }

如果你想調用另一個控制台命令並禁止其所有輸出，你可以使用 `callSilently` 方法。 `callSilently` 方法與 `call` 方法具有相同的簽名：

    $this->callSilently('mail:send', [
        'user' => 1, '--queue' => 'default'
    ]);

<a name="signal-handling"></a>
## 信號處理

正如你可能知道的，操作系統允許向運行中的進程發送信號。例如，「SIGTERM」信號是操作系統要求程序終止的方式。如果你想在 Artisan 控制台命令中監聽信號，並在信號發生時執行代碼，你可以使用 `trap` 方法。

    /**
     * 執行控制台命令。
     */
    public function handle(): void
    {
        $this->trap(SIGTERM, fn () => $this->shouldKeepRunning = false);

        while ($this->shouldKeepRunning) {
            // ...
        }
    }



為了一次監聽多個信號，你可以向 `trap` 方法提供一個信號數組。

    $this->trap([SIGTERM, SIGQUIT], function (int $signal) {
        $this->shouldKeepRunning = false;

        dump($signal); // SIGTERM / SIGQUIT
    });

<a name="stub-customization"></a>
## Stub 定制

Artisan 控制台的 `make` 命令用於創建各種類，例如控制器、作業、遷移和測試。這些類是使用「stub」文件生成的，這些文件中會根據你的輸入填充值。但是，你可能需要對 Artisan 生成的文件進行少量更改。為此，你可以使用以下 `stub:publish` 命令將最常見的 Stub 命令發布到你的應用程序中，以便可以自定義它們：

```shell
php artisan stub:publish
```

已發布的 stub 將存放於你的應用根目錄下的 `stubs` 目錄中。對這些 stub 進行任何改動都將在你使用 Artisan `make` 命令生成相應的類的時候反映出來。

<a name="events"></a>
## 事件

Artisan 在運行命令時會調度三個事件： `Illuminate\Console\Events\ArtisanStarting`，`Illuminate\Console\Events\CommandStarting` 和  `Illuminate\Console\Events\CommandFinished`。當 Artisan 開始運行時，會立即調度 `ArtisanStarting` 事件。接下來，在命令運行之前立即調度  `CommandStarting` 事件。最後，一旦命令執行完畢，就會調度  `CommandFinished` 事件。
