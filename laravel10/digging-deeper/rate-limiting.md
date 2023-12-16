
# 限流

- [簡介](#introduction)
    - [緩存配置](#cache-configuration)
- [基礎用法](#basic-usage)
    - [手動增加請求次數](#manually-incrementing-attempts)
    - [清除請求](#clearing-attempts)

<a name="introduction"></a>
## 簡介

Laravel 包含了一個開箱即用的，基於 [緩存](cache) 實現的限流器，提供了一個簡單的方法來限制指定時間內的任何操作。

> **技巧**
> 了解更多關於如何限制 HTTP 請求，請參考 [請求頻率限制中間件](routing#rate-limiting)。

<a name="cache-configuration"></a>
### 緩存配置

通常情況下，限流器使用你默認的緩存驅動，由 `cache` 配置文件中的 `default` 鍵定義。你也可以通過在你的應用程序的 `cache` 配置文件中定義一個 `limiter` 來指定限流器應該使用哪一個緩存來驅動：

    'default' => 'memcached',

    'limiter' => 'redis',

<a name="basic-usage"></a>
## 基本用法

可以通過 `Illuminate\Support\Facades\RateLimiter` 來操作限流器。限流器提供的最簡單的方法是 `attempt` 方法，它將一個給定的回調函數執行次數限制在一個給定的秒數內。

當回調函數執行次數超過限制時， `attempt` 方法返回 `false` ；否則， `attempt` 方法將返回回調的結果或 `true` 。 `attempt` 方法接受的第一個參數是一個速率限制器 「key」 ，它可以是你選擇的任何字符串，代表被限制速率的動作：

    use Illuminate\Support\Facades\RateLimiter;

    $executed = RateLimiter::attempt(
        'send-message:'.$user->id,
        $perMinute = 5,
        function() {
            // 發送消息...
        }
    );

    if (! $executed) {
      return 'Too many messages sent!';
    }



<a name="manually-incrementing-attempts"></a>
### 手動配置嘗試次數

如果您想手動與限流器交互，可以使用多種方法。例如，您可以調用 `tooManyAttempts` 方法來確定給定的限流器是否超過了每分鐘允許的最大嘗試次數：

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
        return 'Too many attempts!';
    }

或者，您可以使用 `remaining` 方法檢索給定密鑰的剩余嘗試次數。如果給定的密鑰還有重試次數，您可以調用 `hit` 方法來增加總嘗試次數：

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::remaining('send-message:'.$user->id, $perMinute = 5)) {
        RateLimiter::hit('send-message:'.$user->id);

        // 發送消息...
    }

<a name="determining-limiter-availability"></a>
#### 確定限流器可用性

當一個鍵沒有更多的嘗試次數時，`availableIn` 方法返回在嘗試可用之前需等待的剩余秒數：

    use Illuminate\Support\Facades\RateLimiter;

    if (RateLimiter::tooManyAttempts('send-message:'.$user->id, $perMinute = 5)) {
        $seconds = RateLimiter::availableIn('send-message:'.$user->id);

        return 'You may try again in '.$seconds.' seconds.';
    }

<a name="clearing-attempts"></a>
### 清除嘗試次數

您可以使用 `clear` 方法重置給定速率限制鍵的嘗試次數。例如，當接收者讀取給定消息時，您可以重置嘗試次數：

    use App\Models\Message;
    use Illuminate\Support\Facades\RateLimiter;

    /**
     * 標記消息為已讀。
     */
    public function read(Message $message): Message
    {
        $message->markAsRead();

        RateLimiter::clear('send-message:'.$message->user_id);

        return $message;
    }
