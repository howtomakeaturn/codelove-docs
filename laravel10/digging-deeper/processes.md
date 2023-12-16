# 進程管理

- [介紹](#introduction)
- [調用過程](#invoking-processes)
    - [進程選項](#process-options)
    - [進程輸出](#process-output)
- [異步進程](#asynchronous-processes)
    - [進程 ID 和信號](#process-ids-and-signals)
    - [異步進程輸出](#asynchronous-process-output)
- [並行進程](#concurrent-processes)
    - [命名進程池中的進程](#naming-pool-processes)
    - [進程池進程 ID 和信號](#pool-process-ids-and-signals)
- [測試](#testing)
    - [偽造進程](#faking-processes)
    - [偽造指定進程](#faking-specific-processes)
    - [偽造進程序列](#faking-process-sequences)
    - [偽造異步進程的生命周期](#faking-asynchronous-process-lifecycles)
    - [可用的斷言](#available-assertions)
    - [防止運行未被偽造的進程](#preventing-stray-processes)

<a name="introduction"></a>
## 介紹

Laravel 通過 [Symfony Process 組件](https://symfony.com/doc/current/components/process.html) 提供了一個小而美的 API，讓你可以方便地從 Laravel 應用程序中調用外部進程。 Laravel 的進程管理功能專注於提供最常見的用例和提升開發人員體驗。

<a name="invoking-processes"></a>
## 調用過程

調用一個進程，你可以使用 Process 門面提供的 run 和 start 方法。`run` 方法將調用一個進程並等待進程執行完畢，而 `start` 方法用於異步進程執行。我們將在本文檔中探究這兩種方法。首先，讓我們了解一下如何調用基本的同步進程並檢查其結果：

```php
use Illuminate\Support\Facades\Process;

$result = Process::run('ls -la');

return $result->output();
```

當然，由 `run` 方法返回的 `Illuminate\Contracts\Process\ProcessResult` 實例提供了多種有用的方法，用於檢查進程處理結果：

```php
$result = Process::run('ls -la');

$result->successful();
$result->failed();
$result->exitCode();
$result->output();
$result->errorOutput();
```

<a name="throwing-exceptions"></a>
#### 拋出異常

如果你有一個進程結果，並且希望在退出代碼大於零（以此表明失敗）的情況下拋出`Illuminate\Process\Exceptions\ProcessFailedException`的一個實例，你可以使用`throw` 和 `throwIf` 方法。 如果進程沒有失敗，將返回進程結果實例：

```php
$result = Process::run('ls -la')->throw();

$result = Process::run('ls -la')->throwIf($condition);
```

<a name="process-options"></a>
### 進程選項

當然，你可能需要在調用進程之前自定義進程的行為。幸運的是，Laravel允許你調整各種進程特性，比如工作目錄、超時和環境變量。

<a name="working-directory-path"></a>
#### 工作目錄路徑

你可以使用 `path` 方法指定進程的工作目錄。如果不調用這個方法，進程將繼承當前正在執行的PHP腳本的工作目錄

```php
$result = Process::path(__DIR__)->run('ls -la');
```

<a name="input"></a>
#### 輸入

你可以使用 `input` 方法通過進程的“標準輸入”提供輸入：

```php
$result = Process::input('Hello World')->run('cat');
```

<a name="timeouts"></a>
#### 超時

默認情況下，進程在執行超過60秒後將拋出`Illuminate\Process\Exceptions\ProcessTimedOutException` 實例。但是，你可以通過 `timeout` 方法自定義此行為：

```php
$result = Process::timeout(120)->run('bash import.sh');
```

或者，如果要完全禁用進程超時，你可以調用 `forever` 方法：

```php
$result = Process::forever()->run('bash import.sh');
```

` idleTimeout`  方法可用於指定進程在不返回任何輸出的情況下最多運行的秒數：

```php
$result = Process::timeout(60)->idleTimeout(30)->run('bash import.sh');
```

<a name="environment-variables"></a>
#### 環境變量

可以通過 ` env ` 方法向進程提供環境變量。 調用的進程還將繼承系統定義的所有環境變量：

```php
$result = Process::forever()
            ->env(['IMPORT_PATH' => __DIR__])
            ->run('bash import.sh');
```

如果你希望從調用的進程中刪除繼承的環境變量，則可以為該環境變量提供值為 false：

```php
$result = Process::forever()
            ->env(['LOAD_PATH' => false])
            ->run('bash import.sh');
```

<a name="tty-mode"></a>
#### TTY 模式

`tty` 方法可以用於為你的進程啟用 TTY 模式。 TTY 模式將進程的輸入和輸出連接到你的程序的輸入和輸出，允許你的進程作為一個進程打開編輯器（如 Vim 或 Nano）：

```php
Process::forever()->tty()->run('vim');
```

<a name="process-output"></a>
### 進程輸出

如前所述，進程輸出可以使用進程結果的 ` output` （標準輸出）和 ` errorOutput` （標準錯誤輸出）方法訪問：

```php
use Illuminate\Support\Facades\Process;

$result = Process::run('ls -la');

echo $result->output();
echo $result->errorOutput();
```

但是，通過將閉包作為 ` run`  方法的第二個參數，輸出也可以實時收集。閉包將接收兩個參數：輸出的“類型”（stdout 或 stderr）和輸出字符串本身：

```php
$result = Process::run('ls -la', function (string $type, string $output) {
    echo $output;
});
```

Laravel 還提供了 `seeInOutput` 和 `seeInErrorOutput`方法，這提供了一種方便的方式來確定進程輸出中是否包含給定的字符串：

```php
if (Process::run('ls -la')->seeInOutput('laravel')) {
    // ...
}
```

<a name="disabling-process-output"></a>
#### 禁用進程輸出

如果你的進程寫入了大量你不感興趣的輸出，則可以通過在構建進程時調用 `quietly` 方法來禁用輸出檢索。為此，請執行以下操作：

```php
use Illuminate\Support\Facades\Process;

$result = Process::quietly()->run('bash import.sh');
```

<a name="asynchronous-processes"></a>
## 異步進程

`start` 方法可以用來異步地調用進程，與之相對的是同步的 `run` 方法。使用 `start` 方法可以讓進程在後台運行，而不會阻塞應用的其他任務。一旦進程被調用，你可以使用 `running` 方法來檢查進程是否仍在運行：

```php
$process = Process::timeout(120)->start('bash import.sh');

while ($process->running()) {
    // ...
}

$result = $process->wait();
```

你可以使用 `wait`方法來等待進程執行完畢，並檢索進程的執行結果實例：

```php
$process = Process::timeout(120)->start('bash import.sh');

// ...

$result = $process->wait();
```

<a name="process-ids-and-signals"></a>
### 進程 ID 和信號

`id` 方法可以用來檢索正在運行進程的操作系統分配的進程 ID：

```php
$process = Process::start('bash import.sh');

return $process->id();
```

你可以使用 `signal` 方法向正在運行的進程發送“信號”。在 [PHP 文檔中可以找到預定義的信號常量列表](https://www.php.net/manual/en/pcntl.constants.php):

```php
$process->signal(SIGUSR2);
```

<a name="asynchronous-process-output"></a>
### 異步進程輸出

當異步進程在運行時，你可以使用 `output` 和 `errorOutput` 方法訪問其整個當前輸出；但是，你可以使用`latestOutput` 和 `latestErrorOutput` 方法訪問自上次檢索輸出以來的進程輸出：

```php
$process = Process::timeout(120)->start('bash import.sh');

while ($process->running()) {
    echo $process->latestOutput();
    echo $process->latestErrorOutput();

    sleep(1);
}
```

與 `run` 方法一樣，也可以通過在 `start` 方法的第二個參數中傳遞一個閉包來從異步進程中實時收集輸出。閉包將接收兩個參數：輸出類型（`stdout` 或 `stderr`）和輸出字符串本身：

```php
$process = Process::start('bash import.sh', function (string $type, string $output) {
    echo $output;
});

$result = $process->wait();
```

<a name="concurrent-processes"></a>
## 並行處理

Laravel 還可以輕松地管理一組並發的異步進程，使你能夠輕松地同時執行多個任務。要開始，請調用 pool 方法，該方法接受一個閉包，該閉包接收 Illuminate\Process\Pool 實例。

在此閉包中，你可以定義屬於該池的進程。一旦通過 `start` 方法啟動了進程池，你可以通過 `running` 方法訪問正在運行的進程 [集合](/docs/laravel/10.x/collections)：

```php
use Illuminate\Process\Pool;
use Illuminate\Support\Facades\Process;

$pool = Process::pool(function (Pool $pool) {
    $pool->path(__DIR__)->command('bash import-1.sh');
    $pool->path(__DIR__)->command('bash import-2.sh');
    $pool->path(__DIR__)->command('bash import-3.sh');
})->start(function (string $type, string $output, int $key) {
    // ...
});

while ($pool->running()->isNotEmpty()) {
    // ...
}

$results = $pool->wait();
```

可以看到，你可以通過 `wait` 方法等待所有池進程完成執行並解析它們的結果。`wait` 方法返回一個可訪問進程結果實例的數組對象，通過其鍵可以訪問池中每個進程的進程結果實例：

```php
$results = $pool->wait();

echo $results[0]->output();
```

或者，為方便起見，可以使用 `concurrently` 方法啟動異步進程池並立即等待其結果。結合 PHP 的數組解構功能，這可以提供特別表達式的語法：

```php
[$first, $second, $third] = Process::concurrently(function (Pool $pool) {
    $pool->path(__DIR__)->command('ls -la');
    $pool->path(app_path())->command('ls -la');
    $pool->path(storage_path())->command('ls -la');
});

echo $first->output();
```

<a name="naming-pool-processes"></a>
### 命名進程池中的進程

通過數字鍵訪問進程池結果不太具有表達性，因此 Laravel 允許你通過 `as` 方法為進程池中的每個進程分配字符串鍵。該鍵也將傳遞給提供給 `start` 方法的閉包，使你能夠確定輸出屬於哪個進程：

```php
$pool = Process::pool(function (Pool $pool) {
    $pool->as('first')->command('bash import-1.sh');
    $pool->as('second')->command('bash import-2.sh');
    $pool->as('third')->command('bash import-3.sh');
})->start(function (string $type, string $output, string $key) {
    // ...
});

$results = $pool->wait();

return $results['first']->output();
```

<a name="pool-process-ids-and-signals"></a>
### 進程池進程 ID 和信號

由於進程池的 `running` 方法提供了一個包含池中所有已調用進程的集合，因此你可以輕松地訪問基礎池進程 ID：

```php
$processIds = $pool->running()->each->id();
```

為了方便起見，你可以在進程池上調用 `signal` 方法，向池中的每個進程發送信號：

```php
$pool->signal(SIGUSR2);
```

<a name="testing"></a>
## 測試

許多 Laravel 服務都提供功能，以幫助你輕松、有表達力地編寫測試，Laravel 的進程服務也不例外。`Process` 門面的 `fake` 方法允許你指示 Laravel 在調用進程時返回存根/偽造結果。

<a name="faking-processes"></a>
### 偽造進程

在探索 Laravel 的偽造進程能力時，讓我們想象一下調用進程的路由：

```php
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\Route;

Route::get('/import', function () {
    Process::run('bash import.sh');

    return 'Import complete!';
});
```

在測試這個路由時，我們可以通過在 `Process` 門面上調用無參數的 `fake` 方法，讓 Laravel 返回一個偽造的成功進程結果。此外，我們甚至可以斷言某個進程“已運行”：

```php
<?php

namespace Tests\Feature;

use Illuminate\Process\PendingProcess;
use Illuminate\Contracts\Process\ProcessResult;
use Illuminate\Support\Facades\Process;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_process_is_invoked(): void
    {
        Process::fake();

        $response = $this->get('/');

        // 簡單的流程斷言...
        Process::assertRan('bash import.sh');

        // 或者，檢查流程配置...
        Process::assertRan(function (PendingProcess $process, ProcessResult $result) {
            return $process->command === 'bash import.sh' &&
                   $process->timeout === 60;
        });
    }
}
```

如前所述，在 `Process` 門面上調用 `fake` 方法將指示 Laravel 始終返回一個沒有輸出的成功進程結果。但是，你可以使用 `Process` 門面的 `result` 方法輕松指定偽造進程的輸出和退出碼：

```php
Process::fake([
    '*' => Process::result(
        output: 'Test output',
        errorOutput: 'Test error output',
        exitCode: 1,
    ),
]);
```

<a name="faking-specific-processes"></a>
### 偽造指定進程

在你測試的過程中，如果要偽造不同的進程執行結果，你可以通過傳遞一個數組給 `fake` 方法來實現。

數組的鍵應該表示你想偽造的命令模式及其相關結果。星號 `*` 字符可用作通配符，任何未被偽造的進程命令將會被實際執行。你可以使用 `Process` Facade的 `result` 方法為這些命令構建 stub/fake 結果：

```php
Process::fake([
    'cat *' => Process::result(
        output: 'Test "cat" output',
    ),
    'ls *' => Process::result(
        output: 'Test "ls" output',
    ),
]);
```

如果不需要自定義偽造進程的退出碼或錯誤輸出，你可以更方便地將偽造進程結果指定為簡單字符串：

```php
Process::fake([
    'cat *' => 'Test "cat" output',
    'ls *' => 'Test "ls" output',
]);
```

<a name="faking-process-sequences"></a>
### 偽造進程序列

如果你測試的代碼調用了多個相同命令的進程，你可能希望為每個進程調用分配不同的偽造進程結果。你可以使用 `Process` Facade 的 `sequence`方法來實現這一點：

```php
Process::fake([
    'ls *' => Process::sequence()
                ->push(Process::result('First invocation'))
                ->push(Process::result('Second invocation')),
]);
```

<a name="faking-asynchronous-process-lifecycles"></a>
### 偽造異步進程的生命周期

到目前為止，我們主要討論了偽造使用 `run` 方法同步調用的進程。但是，如果你正在嘗試測試與通過 `start` 調用的異步進程交互的代碼，則可能需要更覆雜的方法來描述偽造進程。

例如，讓我們想象以下使用異步進程交互的路由：

```php
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;

Route::get('/import', function () {
    $process = Process::start('bash import.sh');

    while ($process->running()) {
        Log::info($process->latestOutput());
        Log::info($process->latestErrorOutput());
    }

    return 'Done';
});
```

為了正確地偽造這個進程，我們需要能夠描述 `running` 方法應返回 `true` 的次數。此外，我們可能想要指定多行順序返回的輸出。為了實現這一點，我們可以使用 `Process` Facade 的 `describe` 方法：

```php
Process::fake([
    'bash import.sh' => Process::describe()
            ->output('First line of standard output')
            ->errorOutput('First line of error output')
            ->output('Second line of standard output')
            ->exitCode(0)
            ->iterations(3),
]);
```

讓我們深入研究上面的例子。使用 `output` 和 `errorOutput` 方法，我們可以指定順序返回的多行輸出。`exitCode` 方法可用於指定偽造進程的最終退出碼。最後，`iterations` 方法可用於指定 `running` 方法應返回 `true` 的次數。

<a name="available-assertions"></a>
### 可用的斷言

 [如前所述](#faking-processes)，Laravel 為你的功能測試提供了幾個進程斷言。我們將在下面討論每個斷言。

<a name="assert-process-ran"></a>
#### assertRan

斷言已經執行了給定的進程：

```php
use Illuminate\Support\Facades\Process;

Process::assertRan('ls -la');
```

`assertRan` 方法還接受一個閉包，該閉包將接收一個進程實例和一個進程結果，使你可以檢查進程的配置選項。如果此閉包返回 `true`，則斷言將“通過”：

```php
Process::assertRan(fn ($process, $result) =>
    $process->command === 'ls -la' &&
    $process->path === __DIR__ &&
    $process->timeout === 60
);
```

傳遞給 `assertRan` 閉包的 `$process` 是 `Illuminate\Process\PendingProcess` 的實例，而 $result 是 `Illuminate\Contracts\Process\ProcessResult` 的實例。

<a name="assert-process-didnt-run"></a>
#### assertDidntRun

斷言給定的進程沒有被調用：

```php
use Illuminate\Support\Facades\Process;

Process::assertDidntRun('ls -la');
```

與 `assertRan` 方法類似，`assertDidntRun` 方法也接受一個閉包，該閉包將接收一個進程實例和一個進程結果，允許你檢查進程的配置選項。如果此閉包返回 `true`，則斷言將“失敗”：

```php
Process::assertDidntRun(fn (PendingProcess $process, ProcessResult $result) =>
    $process->command === 'ls -la'
);
```

<a name="assert-process-ran-times"></a>
#### assertRanTimes

斷言給定的進程被調用了指定的次數：

```php
use Illuminate\Support\Facades\Process;

Process::assertRanTimes('ls -la', times: 3);
```

`assertRanTimes` 方法也接受一個閉包，該閉包將接收一個進程實例和一個進程結果，允許你檢查進程的配置選項。如果此閉包返回 `true` 並且進程被調用了指定的次數，則斷言將“通過”：

```php
Process::assertRanTimes(function (PendingProcess $process, ProcessResult $result) {
    return $process->command === 'ls -la';
}, times: 3);
```

<a name="preventing-stray-processes"></a>
### 防止運行未被偽造的進程

如果你想確保在單個測試或完整的測試套件中，所有被調用的進程都已經被偽造，你可以調用`preventStrayProcesses` 方法。調用此方法後，任何沒有相應的偽造結果的進程都將引發異常，而不是啟動實際進程：

    use Illuminate\Support\Facades\Process;

    Process::preventStrayProcesses();

    Process::fake([
        'ls *' => 'Test output...',
    ]);

    // 返回假響應...
    Process::run('ls -la');

    // 拋出一個異常...
    Process::run('bash import.sh');
