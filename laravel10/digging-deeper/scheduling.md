# 任務調度

- [簡介](#introduction)
- [定義調度](#defining-schedules)
    - [Artisan 命令調度](#scheduling-artisan-commands)
    - [隊列任務調度](#scheduling-queued-jobs)
    - [Shell 命令調度](#scheduling-shell-commands)
    - [調度頻率設置](#schedule-frequency-options)
    - [時區](#timezones)
    - [避免任務重覆](#preventing-task-overlaps)
    - [單機任務調度](#running-tasks-on-one-server)
    - [後台任務](#background-tasks)
    - [維護模式](#maintenance-mode)
- [運行調度程序](#running-the-scheduler)
    - [本地運行調度程序](#running-the-scheduler-locally)
- [任務輸出](#task-output)
- [任務鉤子](#task-hooks)
- [事件](#events)

<a name="introduction"></a>
## 簡介

過去，你可能需要在服務器上為每一個調度任務去創建 Cron 條目。因為這些任務的調度不是通過代碼控制的，你要查看或新增任務調度都需要通過 SSH 遠程登錄到服務器上去操作，所以這種方式很快會讓人變得痛苦不堪。

Laravel 的命令行調度器允許你在 Laravel 中清晰明了地定義命令調度。在使用這個任務調度器時，你只需要在你的服務器上創建單個 Cron 入口。你的任務調度在 `app/Console/Kernel.php` 的 `schedule` 方法中進行定義。為了幫助你更好的入門，這個方法中有個簡單的例子。

<a name="defining-schedules"></a>
## 定義調度

你可以在 `App\Console\Kernel` 類的 `schedule` 方法中定義所有的調度任務。在開始之前，我們來看一個例子：我們計劃每天午夜執行一個閉包，這個閉包會執行一次數據庫語句去清空一張表：

    <?php

    namespace App\Console;

    use Illuminate\Console\Scheduling\Schedule;
    use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
    use Illuminate\Support\Facades\DB;

    class Kernel extends ConsoleKernel
    {
        /**
         * 定義應用中的命令調度
         */
        protected function schedule(Schedule $schedule): void
        {
            $schedule->call(function () {
                DB::table('recent_users')->delete();
            })->daily();
        }
    }

除了調用閉包這種方式來調度外，你還可以調用 [可調用對象](https://secure.php.net/manual/en/language.oop5.magic.php#object.invoke)。 可調用對象是簡單的 PHP 類，包含一個 `__invoke` 方法：

    $schedule->call(new DeleteRecentUsers)->daily();

如果你想查看任務計劃的概述及其下次計劃運行時間，你可以使用 `schedule:list` Artisan 命令：

```bash
php artisan schedule:list
```

<a name="scheduling-artisan-commands"></a>
### Artisan 命令調度

調度方式不僅有調用閉包，還有調用 [Artisan commands](/docs/laravel/10.x/artisan) 和操作系統命令。例如，你可以給 command 方法傳遞命令名稱或類來調度一個 `Artisan` 命令：

當使用命令類名調度 `Artisan` 命令時，你可以通過一個數組傳遞附加的命令行參數，且這些參數需要在命令觸發時提供：

    use App\Console\Commands\SendEmailsCommand;

    $schedule->command('emails:send Taylor --force')->daily();

    $schedule->command(SendEmailsCommand::class, ['Taylor', '--force'])->daily();

<a name="scheduling-queued-jobs"></a>
### 隊列任務調度

`job` 方法可以用來調度 [queued job](/docs/laravel/10.x/queues)。此方法提供了一種快捷方式來調度任務，而無需使用 `call` 方法創建閉包來調度任務：

    use App\Jobs\Heartbeat;

    $schedule->job(new Heartbeat)->everyFiveMinutes();

`job` 方法提供了可選的第二，三參數，分別指定任務將被放置的隊列名稱及連接：

    use App\Jobs\Heartbeat;

    // 分發任務到「heartbeats」隊列及「sqs」連接...
    $schedule->job(new Heartbeat, 'heartbeats', 'sqs')->everyFiveMinutes();


<a name="scheduling-shell-commands"></a>
### Shell 命令調度

`exec` 方法可發送命令到操作系統：

    $schedule->exec('node /home/forge/script.js')->daily();

<a name="schedule-frequency-options"></a>
### 調度頻率選項

我們已經看到了幾個如何設置任務在指定時間間隔運行的例子。不僅如此，你還有更多的任務調度頻率可選：

方法  | 描述
------------- | -------------
`->cron('* * * * *');`  |  按自定義 cron 計劃運行任務
`->everySecond();`  |  每秒運行一次任務
`->everyTwoSeconds();`  |  每兩秒運行一次任務
`->everyFiveSeconds();`  |  每五秒運行一次任務
`->everyTenSeconds();`  |  每十秒運行一次任務
`->everyFifteenSeconds();`  |  每 15 秒運行一次任務
`->everyTwentySeconds();`  |  每 20 秒運行一次任務
`->everyThirtySeconds();`  |  每 30 秒運行一次任務
`->everyMinute();`  |  每分鐘運行一次任務
`->everyTwoMinutes();`  |  每兩分鐘運行一次任務
`->everyThreeMinutes();`  |  每三分鐘運行一次任務
`->everyFourMinutes();`  |  每四分鐘運行一次任務
`->everyFiveMinutes();`  |  每五分鐘運行一次任務
`->everyTenMinutes();`  |  每十分鐘運行一次任務
`->everyFifteenMinutes();`  |  每 15 分鐘運行一次任務
`->everyThirtyMinutes();`  |  每 30 分鐘運行一次任務
`->hourly();`  |  每小時運行一次任務
`->hourlyAt(17);`  |  每小時第十七分鐘時執行一次任務
`->everyOddHour($minutes = 0);`  |  每奇數小時運行一次任務
`->everyTwoHours($minutes = 0);`  |  每兩小時運行一次任務
`->everyThreeHours($minutes = 0);`  |  每三小時運行一次任務
`->everyFourHours($minutes = 0);`  |  每四小時運行一次任務
`->everySixHours($minutes = 0);`  |  每六小時運行一次任務
`->daily();`  |  每天 00:00 執行一次任務
`->dailyAt('13:00');`  |  每天 13:00 運行任務
`->twiceDaily(1, 13);`  |  每天在 1:00 和 13:00 運行任務
`->twiceDailyAt(1, 13, 15);`  |  每天在 1:15 和 13:15 運行任務
`->weekly();`  |  每周日00:00運行任務
`->weeklyOn(1, '8:00');`  |  每周一 8:00 運行任務
`->monthly();`  |  每月第一天 00:00 運行任務
`->monthlyOn(4, '15:00');`  |  每月第四天 15:00 運行任務
`->twiceMonthly(1, 16, '13:00');`  |  每月第一天和第十六天的 13:00 運行任務
`->lastDayOfMonth('15:00');`  |  每月的最後一天 15:00 運行任務
`->quarterly();`  |  每個季度的第一天 00:00 運行任務
`->quarterlyOn(4, '14:00');`  |  每季度 4 日 14:00 運行任務
`->yearly();`  |  每年的第一天 00:00 運行任務
`->yearlyOn(6, 1, '17:00');`  |  每年 6 月 1 日 17:00 運行任務
`->timezone('America/New_York');`  |  設置任務的時區

這些方法與額外的約束條件相結合後，可用於創建在一周的特定時間運行甚至更精細的計劃任務。例如，在每周一執行命令：

    // 在每周一 13:00 執行...
    $schedule->call(function () {
        // ...
    })->weekly()->mondays()->at('13:00');

    // 在每個工作日 8:00 到 17:00 之間的每小時周期執行...
    $schedule->command('foo')
              ->weekdays()
              ->hourly()
              ->timezone('America/Chicago')
              ->between('8:00', '17:00');

下方列出了額外的約束條件：

<div class="overflow-auto" markdown="1">

方法  | 描述
:------------- | :-------------
`->weekdays();`  |  限制任務在工作日執行
`->weekends();`  |  限制任務在周末執行
`->sundays();`  |  限制任務在周日執行
`->mondays();`  |  限制任務在周一執行
`->tuesdays();`  |  限制任務在周二執行
`->wednesdays();`  |  限制任務在周三執行
`->thursdays();`  |  限制任務在周四執行
`->fridays();`  |  限制任務在周五執行
`->saturdays();`  |  限制任務在周六執行
`->days(array\|mixed);`  |  限制任務在每周的指定日期執行
`->between($startTime, $endTime);`  |  限制任務在 `$startTime` 和 `$endTime` 區間執行
`->unlessBetween($startTime, $endTime);`  |  限制任務不在 `$startTime` 和 `$endTime` 區間執行
`->when(Closure);`  |  限制任務在閉包返回為真時執行
`->environments($env);`  |  限制任務在特定環境中執行

</div>

<a name="day-constraints"></a>
#### 周幾（Day）限制

`days` 方法可以用於限制任務在每周的指定日期執行。舉個例子，你可以在讓一個命令每周日和每周三每小時執行一次：

    $schedule->command('emails:send')
                    ->hourly()
                    ->days([0, 3]);

不僅如此，你還可以使用 `Illuminate\Console\Scheduling\Schedule` 類中的常量來設置任務在指定日期運行：

    use Illuminate\Console\Scheduling\Schedule;

    $schedule->command('emails:send')
                    ->hourly()
                    ->days([Schedule::SUNDAY, Schedule::WEDNESDAY]);

<a name="between-time-constraints"></a>
#### 時間範圍限制

`between` 方法可用於限制任務在一天中的某個時間段執行：

    $schedule->command('emails:send')
                        ->hourly()
                        ->between('7:00', '22:00');

同樣， `unlessBetween` 方法也可用於限制任務不在一天中的某個時間段執行：

    $schedule->command('emails:send')
                        ->hourly()
                        ->unlessBetween('23:00', '4:00');

<a name="truth-test-constraints"></a>
#### 真值檢測限制

`when` 方法可根據閉包返回結果來執行任務。換言之，若給定的閉包返回 `true`，若無其他限制條件阻止，任務就會一直執行：

    $schedule->command('emails:send')->daily()->when(function () {
        return true;
    });

`skip` 可看作是 `when` 的逆方法。若 `skip` 方法返回 `true`，任務將不會執行：

    $schedule->command('emails:send')->daily()->skip(function () {
        return true;
    });

當鏈式調用 `when` 方法時，僅當所有 `when` 都返回 `true` 時，任務才會執行。

<a name="environment-constraints"></a>
#### 環境限制

`environments` 方法可限制任務在指定環境中執行（由 `APP_ENV` [環境變量](/docs/laravel/10.x/configurationmd#environment-configuration) 定義）：

    $schedule->command('emails:send')
                ->daily()
                ->environments(['staging', 'production']);

<a name="timezones"></a>
### 時區

`timezone` 方法可指定在某一時區的時間執行計劃任務：

    $schedule->command('report:generate')
             ->timezone('America/New_York')
             ->at('2:00')

若想給所有計劃任務分配相同的時區，那麽需要在 `app/Console/Kernel.php` 類中定義 `scheduleTimezone` 方法。該方法會返回一個默認時區，最終分配給所有計劃任務：

    use DateTimeZone;

    /**
     * 獲取計劃事件默認使用的時區
     */
    protected function scheduleTimezone(): DateTimeZone|string|null
    {
        return 'America/Chicago';
    }

> **注意**
> 請記住，有些時區會使用夏令時。當夏令時發生調整時，你的任務可能會執行兩次，甚至根本不會執行。因此，我們建議盡可能避免使用時區來安排計劃任務。

<a name="preventing-task-overlaps"></a>
### 避免任務重覆

默認情況下，即使之前的任務實例還在執行，調度內的任務也會執行。為避免這種情況的發生，你可以使用 `withoutOverlapping` 方法：

    $schedule->command('emails:send')->withoutOverlapping();

在此例中，若 `emails:send` [Artisan 命令](/docs/laravel/10.x/artisan) 還未運行，那它將會每分鐘執行一次。如果你的任務執行時間非常不確定，導致你無法準確預測任務的執行時間，那 `withoutOverlapping` 方法會特別有用。

如有需要，你可以在 `withoutOverlapping` 鎖過期之前，指定它的過期分鐘數。默認情況下，這個鎖會在 24 小時後過期：

    $schedule->command('emails:send')->withoutOverlapping(10);

上面這種場景中，`withoutOverlapping` 方法使用應用程序的 [緩存](/docs/laravel/10.x/cache) 獲取鎖。如有必要，可以使用`schedule:clear cache` Artisan命令清除這些緩存鎖。這通常只有在任務由於意外的服務器問題而卡住時才需要。

<a name="running-tasks-on-one-server"></a>
### 任務只運行在一台服務器上

> **注意**
> 要使用此功能，你的應用程序必須使用 `database`, `memcached`, `dynamodb`, 或 `redis` 緩存驅動程序作為應用程序的默認緩存驅動程序。此外，所有服務器必須和同一個中央緩存服務器通信。

如果你的應用運行在多台服務器上，可能需要限制調度任務只在某台服務器上運行。 例如，假設你有一個每個星期五晚上生成新報告的調度任務，如果任務調度器運行在三台服務器上，調度任務會在三台服務器上運行並且生成三次報告，不夠優雅！

要指示任務應僅在一台服務器上運行，請在定義計劃任務時使用 `onOneServer` 方法。第一台獲取到該任務的服務器會給任務上一把原子鎖以阻止其他服務器同時運行該任務:

    $schedule->command('report:generate')
                    ->fridays()
                    ->at('17:00')
                    ->onOneServer();

<a name="naming-unique-jobs"></a>
#### 命名單服務器作業

有時，你可能需要使用不同的參數調度相同的作業，同時使其仍然在單個服務器上運行作業。為此，你可以使用 `name` 方法為每個作業定義一個唯一的名字：

```php
$schedule->job(new CheckUptime('https://laravel.com'))
            ->name('check_uptime:laravel.com')
            ->everyFiveMinutes()
            ->onOneServer();

$schedule->job(new CheckUptime('https://vapor.laravel.com'))
            ->name('check_uptime:vapor.laravel.com')
            ->everyFiveMinutes()
            ->onOneServer();
```

如果你使用閉包來定義單服務器作業，則必須為他們定義一個名字

```php
$schedule->call(fn () => User::resetApiRequestCount())
    ->name('reset-api-request-count')
    ->daily()
    ->onOneServer();
```

<a name="background-tasks"></a>
### 後台任務

默認情況下，同時運行多個任務將根據它們在 `schedule` 方法中定義的順序執行。如果你有一些長時間運行的任務，將會導致後續任務比預期時間更晚啟動。 如果你想在後台運行任務，以便它們可以同時運行，則可以使用 `runInBackground` 方法:

    $schedule->command('analytics:report')
             ->daily()
             ->runInBackground();

> **注意**
> `runInBackground` 方法只有在通過 `command` 和 `exec` 方法調度任務時才可以使用

<a name="maintenance-mode"></a>
### 維護模式

當應用處於 [維護模式](/docs/laravel/10.x/configurationmd#maintenance-mode) 時，Laravel 的隊列任務將不會運行。因為我們不想調度任務幹擾到服務器上可能還未完成的維護項目。不過，如果你想強制任務在維護模式下運行，你可以使用 `evenInMaintenanceMode` 方法：

    $schedule->command('emails:send')->evenInMaintenanceMode();

<a name="running-the-scheduler"></a>
## 運行調度程序

現在，我們已經學會了如何定義計劃任務，接下來讓我們討論如何真正在服務器上運行它們。`schedule:run` Artisan 命令將評估你的所有計劃任務，並根據服務器的當前時間決定它們是否運行。

因此，當使用 Laravel 的調度程序時，我們只需要向服務器添加一個 cron 配置項，該項每分鐘運行一次 `schedule:run` 命令。如果你不知道如何向服務器添加 cron 配置項，請考慮使用 [Laravel Forge](https://forge.laravel.com) 之類的服務來為你管理 cron 配置項：

```shell
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

<a name="running-the-scheduler-locally"></a>
### 本地運行調度程序

通常，你不會直接將 cron 配置項添加到本地開發計算機。你反而可以使用 `schedule:work` Artisan 命令。該命令將在前台運行，並每分鐘調用一次調度程序，直到你終止該命令為止：

```shell
php artisan schedule:work
```

<a name="task-output"></a>
## 任務輸出

Laravel 調度器提供了一些簡便方法來處理調度任務生成的輸出。首先，你可以使用 `sendOutputTo` 方法將輸出發送到文件中以便後續檢查：

    $schedule->command('emails:send')
             ->daily()
             ->sendOutputTo($filePath);

如果希望將輸出追加到指定文件，可使用 `appendOutputTo` 方法：

    $schedule->command('emails:send')
             ->daily()
             ->appendOutputTo($filePath);

使用 `emailOutputTo` 方法，你可以將輸出發送到指定郵箱。在發送郵件之前，你需要先配置 Laravel 的 [郵件服務](/docs/laravel/10.x/mail):

    $schedule->command('report:generate')
             ->daily()
             ->sendOutputTo($filePath)
             ->emailOutputTo('taylor@example.com');

如果你只想在命令執行失敗時將輸出發送到郵箱，可使用 `emailOutputOnFailure` 方法：

    $schedule->command('report:generate')
             ->daily()
             ->emailOutputOnFailure('taylor@example.com');

> **注意**
> `emailOutputTo`, `emailOutputOnFailure`, `sendOutputTo` 和 `appendOutputTo` 是 `command` 和 `exec` 獨有的方法。

<a name="task-hooks"></a>
## 任務鉤子

使用 `before` 和 `after` 方法，你可以決定在調度任務執行前或者執行後來運行代碼：

    $schedule->command('emails:send')
             ->daily()
             ->before(function () {
                 // 任務即將執行。。。
             })
             ->after(function () {
                 // 任務已經執行。。。
             });



使用 `onSuccess` 和 `onFailure` 方法，你可以決定在調度任務成功或者失敗運行代碼。失敗表示 Artisan 或系統命令以非零退出碼終止：

    $schedule->command('emails:send')
             ->daily()
             ->onSuccess(function () {
                 // 任務執行成功。。。
             })
             ->onFailure(function () {
                 // 任務執行失敗。。。
             });

如果你的命令有輸出，你可以使用`after`, `onSuccess` 或 `onFailure`鉤子並傳入類型為`Illuminate\Support\Stringable`的`$output`參數的閉包來訪問任務輸出：

    use Illuminate\Support\Stringable;

    $schedule->command('emails:send')
             ->daily()
             ->onSuccess(function (Stringable $output) {
                 // The task succeeded...
             })
             ->onFailure(function (Stringable $output) {
                 // The task failed...
             });

<a name="pinging-urls"></a>
#### Pinging 網址

使用 `pingBefore` 和 `thenPing` 方法，你可以在任務完成之前或完成之後來 ping 指定的 URL。當前方法在通知外部服務，如 [Envoyer](https://envoyer.io)，計劃任務在將要執行或已完成時會很有用：

    $schedule->command('emails:send')
             ->daily()
             ->pingBefore($url)
             ->thenPing($url);

只有當條件為 `true` 時，才可以使用 `pingBeforeIf` 和 `thenPingIf` 方法來 ping 指定 URL ：

    $schedule->command('emails:send')
             ->daily()
             ->pingBeforeIf($condition, $url)
             ->thenPingIf($condition, $url);

當任務成功或失敗時，可使用 `pingOnSuccess` 和 `pingOnFailure` 方法來 ping 給定 URL。失敗表示 Artisan 或系統命令以非零退出碼終止：

    $schedule->command('emails:send')
             ->daily()
             ->pingOnSuccess($successUrl)
             ->pingOnFailure($failureUrl);



所有 ping 方法都依賴 Guzzle HTTP 庫。通常，Guzzle 已在所有新的 Laravel 項目中默認安裝，不過，若意外將 Guzzle 刪除，則可以使用 Composer 包管理器將 Guzzle 手動安裝到項目中：

```shell
composer require guzzlehttp/guzzle
```

<a name="events"></a>
## 事件

如果需要，你可以監聽調度程序調度的 [事件](/docs/laravel/10.x/events)。通常，事件偵聽器映射將在你的應用程序的 `App\Providers\EventServiceProvider` 類中定義：

    /**
     * 應用的事件監聽器映射
     *
     * @var array
     */
    protected $listen = [
        'Illuminate\Console\Events\ScheduledTaskStarting' => [
            'App\Listeners\LogScheduledTaskStarting',
        ],

        'Illuminate\Console\Events\ScheduledTaskFinished' => [
            'App\Listeners\LogScheduledTaskFinished',
        ],

        'Illuminate\Console\Events\ScheduledBackgroundTaskFinished' => [
            'App\Listeners\LogScheduledBackgroundTaskFinished',
        ],

        'Illuminate\Console\Events\ScheduledTaskSkipped' => [
            'App\Listeners\LogScheduledTaskSkipped',
        ],

        'Illuminate\Console\Events\ScheduledTaskFailed' => [
            'App\Listeners\LogScheduledTaskFailed',
        ],
    ];
