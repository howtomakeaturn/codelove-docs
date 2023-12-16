# 本地化

- [簡介](#introduction)
    - [發布語言文件](#publishing-the-language-files)
    - [配置語言環境](#configuring-the-locale)
    - [多語種](#pluralization-language)
- [定義翻譯字符串](#defining-translation-strings)
    - [使用短鍵](#using-short-keys)
    - [使用翻譯字符串作為鍵](#using-translation-strings-as-keys)
- [檢索翻譯字符串](#retrieving-translation-strings)
    - [替換翻譯字符串中的參數](#replacing-parameters-in-translation-strings)
    - [覆數化](#pluralization)
- [覆蓋擴展包的語言文件](#overriding-package-language-files)

<a name="introduction"></a>
## 簡介

> **技巧**
> 默認情況下，Laravel 應用程序框架不包含 `lang` 目錄。如果你想自定義 Laravel 的語言文件，可以通過 `lang:publish`  Artisan 命令發布它們。

Laravel 的本地化功能提供了一種方便的方法來檢索各種語言的字符串，從而使你可以輕松地在應用程序中支持多種語言。

Laravel 提供了兩種管理翻譯字符串的方法。首先，語言字符串可以存儲在 `lang` 目錄里的文件中。在此目錄中，可能存在應用程序支持的每種語言的子目錄。這是 Laravel 用於管理內置 Laravel 功能（例如驗證錯誤消息）的翻譯字符串的方法：

    /lang
        /en
            messages.php
        /es
            messages.php

或者，可以在 `lang` 目錄中放置的 JSON 文件中定義翻譯字符串。采用這種方法時，應用程序支持的每種語言在此目錄中都會有一個對應的 JSON 文件。對於具有大量可翻譯字符串的應用，建議使用此方法：

    /lang
        en.json
        es.json

我們將在本文檔中討論每種管理翻譯字符串的方法。

<a name="publishing-the-language-files"></a>
### 發布語言文件

默認情況下，Laravel 應用程序框架不包含 `lang` 目錄。如果你想自定義 Laravel 的語言文件或創建自己的語言文件，則應通過 `lang:publish` Artisan 命令構建 `lang` 目錄。 `lang:publish` 命令將在應用程序中創建 `lang` 目錄，並發布 Laravel 使用的默認語言文件集：

```shell
php artisan lang:publish
```

<a name="configuring-the-locale"></a>
### 配置語言環境

應用程序的默認語言存儲在 `config/app.php` 配置文件的 `locale` 配置選項中。你可以隨意修改此值以適合你的應用程序的需求。

你可以使用 `App` Facade 提供的 `setLocale` 方法，在運行時通過單個 HTTP 請求修改默認語言：

    use Illuminate\Support\Facades\App;

    Route::get('/greeting/{locale}', function (string $locale) {
        if (! in_array($locale, ['en', 'es', 'fr'])) {
            abort(400);
        }

        App::setLocale($locale);

        // ...
    });

你可以配置一個 「備用語言」，當當前語言不包含給定的翻譯字符串時，將使用該語言。和默認語言一樣，備用語言也是在 config/app.php 配置文件中配置的。

    'fallback_locale' => 'en',

<a name="determining-the-current-locale"></a>
#### 確定當前的語言環境

你可以使用 `currentLocale` 和 `isLocale` 方法來確定當前的 `locale` 或檢查 `locale` 是否是一個給定值。

    use Illuminate\Support\Facades\App;

    $locale = App::currentLocale();

    if (App::isLocale('en')) {
        // ...
    }

<a name="pluralization-language"></a>
### 多語種

你可以使用 Laravel 的「pluralizer」來使用英語以外的語言，Eloquent 和框架的其他部分使用它來將單數字字符串轉為覆數字符串。這可以通過調用應用程序服務提供的 `boot` 方法中的 `useLanguage` 方法來實現。覆數器目前支持的語言有 `法語`, `挪威語`, `葡萄牙語`, `西班牙語`, `土耳其語`:

    use Illuminate\Support\Pluralizer;

    /**
     * 引導任何應用程序服務。
     */
    public function boot(): void
    {
        Pluralizer::useLanguage('spanish');

        // ...
    }

> **注意**
> 如果你想自定義 pluralizer 的語言，則應該明確定義 Elquent 模型的 [表名](/docs/laravel/10.x/eloquentmd#table-names)。

<a name="defining-translation-strings"></a>
## 定義翻譯字符串

<a name="using-short-keys"></a>
### 使用短鍵

通常，翻譯字符串存儲在 `lang` 目錄中的文件中。在這個目錄中，應用程序支持的每種語言都應該有一個子目錄。這是 Laravel 用於管理內置 Laravel 功能（如驗證錯誤消息）的翻譯字符串的方法：

    /lang
        /en
            messages.php
        /es
            messages.php

所有的語言文件都會返回一個鍵值對數組。比如下方這個例子：

    <?php

    // lang/en/messages.php

    return [
        'welcome' => 'Welcome to our application!',
    ];

> **技巧**
> 對於不同地區的語言，應根據 ISO 15897 命名語言目錄。例如，英式英語應使用「en_GB」而不是 「en_gb」。

<a name="using-translation-strings-as-keys"></a>
### 使用翻譯字符串作為鍵

對於具有大量可翻譯字符串的應用程序，在視圖中引用鍵時，使用「短鍵」定義每個字符串可能會令人困惑，並且為應用程序支持的每個翻譯字符串不斷發明鍵會很麻煩。

出於這個原因，Laravel 還支持使用字符串的「默認」翻譯作為鍵來定義翻譯字符串。使用翻譯字符串作為鍵的翻譯文件作為 JSON 文件存儲在 `lang` 目錄中。例如，如果你的應用程序有西班牙語翻譯，你應該創建一個 `lang/es.json` 文件：

```json
{
    "I love programming.": "Me encanta programar."
}
```

#### 鍵 / 文件沖突

你不應該定義和其他翻譯文件的文件名存在沖突的鍵。例如，在 `nl/action.php` 文件存在，但 `nl.json` 文件不存在時，對 `NL` 語言翻譯 `__('Action')` 會導致翻譯器返回 `nl/action.php` 文件的全部內容。

<a name="retrieving-translation-strings"></a>
## 檢索翻譯字符串

你可以使用 `__` 輔助函數從語言文件中檢索翻譯字符串。 如果你使用 「短鍵」 來定義翻譯字符串，你應該使用 「.」 語法將包含鍵的文件和鍵本身傳遞給`__`函數。 例如，讓我們從 `lang/en/messages.php` 語言文件中檢索 `welcome` 翻譯字符串：

    echo __('messages.welcome');

如果指定的翻譯字符串不存在，`__` 函數將返回翻譯字符串鍵。 因此，使用上面的示例，如果翻譯字符串不存在，`__` 函數將返回 `messages.welcome`。

如果是使用 [默認翻譯字符串作為翻譯鍵](#using-translation-strings-as-keys)，則應將字符串的默認翻譯傳遞給 `__` 函數；

    echo __('I love programming.');

同理，如果翻譯字符串不存在，`__` 函數將返回給定的翻譯字符串鍵。

如果是使用的是 [Blade 模板引擎](/docs/laravel/10.x/blade)，則可以使用 `{{ }}` 語法來顯示翻譯字符串：

    {{ __('messages.welcome') }}

<a name="replacing-parameters-in-translation-strings"></a>
### 替換翻譯字符串中的參數

如果願意，可以在翻譯字符串中定義占位符。所有占位符的前綴都是 `:`。例如，可以使用占位符名稱定義歡迎消息：

    'welcome' => 'Welcome, :name',

在要檢索翻譯字符串時替換占位符，可以將替換數組作為第二個參數傳遞給 `__` 函數：

    echo __('messages.welcome', ['name' => 'dayle']);

如果占位符包含所有大寫字母，或僅首字母大寫，則轉換後的值將相應地轉換成大寫：

    'welcome' => 'Welcome, :NAME', // Welcome, DAYLE
    'goodbye' => 'Goodbye, :Name', // Goodbye, Dayle

<a name="object-replacement-formatting"></a>
#### 對象替換格式

如果試圖提供對象作為轉換占位符，則將調用對象的 `__toString` 方法。[`__toString`](https://www.php.net/manual/en/language.oop5.magic.php#object.tostring)方法是PHP內置的「神奇方法」之一。然而，有時你可能無法控制給定類的 `__toString` 方法，例如當你正在交互的類屬於第三方庫時。

在這些情況下，Laravel 允許你為特定類型的對象注冊自定義格式處理程序。要實現這一點，你應該調用轉換器的 `stringable` 方法。 `stringable` 方法接受閉包，閉包應類型提示其負責格式化的對象類型。通常，應在應用程序的 `AppServiceProvider` 類的 `boot` 方法中調用 `stringable` 方法：

    use Illuminate\Support\Facades\Lang;
    use Money\Money;

    /**
     * 引導任何應用程序服務。
     */
    public function boot(): void
    {
        Lang::stringable(function (Money $money) {
            return $money->formatTo('en_GB');
        });
    }

<a name="pluralization"></a>
### 覆數化

因為不同的語言有著各種覆雜的覆數化規則，所以覆數化是個覆雜的問題；不過 Laravel 可以根據你定義的覆數化規則幫助你翻譯字符串。使用 `|` 字符，可以區分字符串的單數形式和覆數形式：

    'apples' => 'There is one apple|There are many apples',

當然，使用 [翻譯字符串作為鍵](#using-translation-strings-as-keys) 時也支持覆數化：

```json
{
    "There is one apple|There are many apples": "Hay una manzana|Hay muchas manzanas"
}
```

你甚至可以創建更覆雜的覆數化規則，為多個值範圍指定轉換字符串：

    'apples' => '{0} There are none|[1,19] There are some|[20,*] There are many',

定義具有覆數選項的翻譯字符串後，可以使用 `trans_choice` 函數檢索給定「count」的行。在本例中，由於計數大於 1 ，因此返回翻譯字符串的覆數形式：

    echo trans_choice('messages.apples', 10);

也可以在覆數化字符串中定義占位符屬性。通過將數組作為第三個參數傳遞給 `trans_choice` 函數，可以替換這些占位符：

    'minutes_ago' => '{1} :value minute ago|[2,*] :value minutes ago',

    echo trans_choice('time.minutes_ago', 5, ['value' => 5]);

如果要顯示傳遞給 `trans_choice` 函數的整數值，可以使用內置的 `:count` 占位符：

    'apples' => '{0} There are none|{1} There is one|[2,*] There are :count',

<a name="overriding-package-language-files"></a>
## 覆蓋擴展包的語言文件

有些包可能隨自己的語言文件一起封裝。你可以將文件放置在 `lang/vendor/{package}/{locale}` 目錄中，而不是更改擴展包的核心文件來調整這些行。

例如，如果需要重寫位於名為 `skyrim/hearthfire` 的包的 `messages.php` 文件內容，應將語言文件放在： `lang/vendor/hearthfire/en/messages.php` 在這個文件中，你應該只定義要覆蓋的翻譯字符串。任何未重寫的翻譯字符串仍將從包的原始語言文件中加載。
