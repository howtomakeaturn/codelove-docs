# 輔助函數

- [簡介](#introduction)
- [可用方法](#available-methods)
- [其他實用工具](#other-utilities)
  - [Benchmarking](#benchmarking)
  - [Pipeline](#pipeline)
  - [Lottery](#lottery)

<a name="introduction"></a>
## 簡介

Laravel 包含各種各樣的全局 PHP 「輔助」函數，框架本身也大量的使用了這些功能函數；如果你覺的方便，你可以在你的應用中任意使用這些函數。

<a name="available-methods"></a>
## 可用方法

<style>
    .collection-method-list > p {
        columns: 10.8em 3; -moz-columns: 10.8em 3; -webkit-columns: 10.8em 3;
    }

    .collection-method-list a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

</style>

<a name="arrays-and-objects-method-list"></a>
### 數組 & 對象

<div class="collection-method-list" markdown="1">

[Arr::accessible](#method-array-accessible)
[Arr::add](#method-array-add)
[Arr::collapse](#method-array-collapse)
[Arr::crossJoin](#method-array-crossjoin)
[Arr::divide](#method-array-divide)
[Arr::dot](#method-array-dot)
[Arr::except](#method-array-except)
[Arr::exists](#method-array-exists)
[Arr::first](#method-array-first)
[Arr::flatten](#method-array-flatten)
[Arr::forget](#method-array-forget)
[Arr::get](#method-array-get)
[Arr::has](#method-array-has)
[Arr::hasAny](#method-array-hasany)
[Arr::isAssoc](#method-array-isassoc)
[Arr::isList](#method-array-islist)
[Arr::join](#method-array-join)
[Arr::keyBy](#method-array-keyby)
[Arr::last](#method-array-last)
[Arr::map](#method-array-map)
[Arr::only](#method-array-only)
[Arr::pluck](#method-array-pluck)
[Arr::prepend](#method-array-prepend)
[Arr::prependKeysWith](#method-array-prependkeyswith)
[Arr::pull](#method-array-pull)
[Arr::query](#method-array-query)
[Arr::random](#method-array-random)
[Arr::set](#method-array-set)
[Arr::shuffle](#method-array-shuffle)
[Arr::sort](#method-array-sort)
[Arr::sortDesc](#method-array-sort-desc)
[Arr::sortRecursive](#method-array-sort-recursive)
[Arr::toCssClasses](#method-array-to-css-classes)
[Arr::undot](#method-array-undot)
[Arr::where](#method-array-where)
[Arr::whereNotNull](#method-array-where-not-null)
[Arr::wrap](#method-array-wrap)
[data_fill](#method-data-fill)
[data_get](#method-data-get)
[data_set](#method-data-set)
[head](#method-head)
[last](#method-last)

</div>

<a name="paths-method-list"></a>
### 路徑

<div class="collection-method-list" markdown="1">

[app_path](#method-app-path)
[base_path](#method-base-path)
[config_path](#method-config-path)
[database_path](#method-database-path)
[lang_path](#method-lang-path)
[mix](#method-mix)
[public_path](#method-public-path)
[resource_path](#method-resource-path)
[storage_path](#method-storage-path)

</div>

<a name="strings-method-list"></a>
### 字符串

<div class="collection-method-list" markdown="1">

[\__](#method-__)
[class_basename](#method-class-basename)
[e](#method-e)
[preg_replace_array](#method-preg-replace-array)
[Str::after](#method-str-after)
[Str::afterLast](#method-str-after-last)
[Str::ascii](#method-str-ascii)
[Str::before](#method-str-before)
[Str::beforeLast](#method-str-before-last)
[Str::between](#method-str-between)
[Str::betweenFirst](#method-str-between-first)
[Str::camel](#method-camel-case)
[Str::contains](#method-str-contains)
[Str::containsAll](#method-str-contains-all)
[Str::endsWith](#method-ends-with)
[Str::excerpt](#method-excerpt)
[Str::finish](#method-str-finish)
[Str::headline](#method-str-headline)
[Str::inlineMarkdown](#method-str-inline-markdown)
[Str::is](#method-str-is)
[Str::isAscii](#method-str-is-ascii)
[Str::isJson](#method-str-is-json)
[Str::isUlid](#method-str-is-ulid)
[Str::isUuid](#method-str-is-uuid)
[Str::kebab](#method-kebab-case)
[Str::lcfirst](#method-str-lcfirst)
[Str::length](#method-str-length)
[Str::limit](#method-str-limit)
[Str::lower](#method-str-lower)
[Str::markdown](#method-str-markdown)
[Str::mask](#method-str-mask)
[Str::orderedUuid](#method-str-ordered-uuid)
[Str::padBoth](#method-str-padboth)
[Str::padLeft](#method-str-padleft)
[Str::padRight](#method-str-padright)
[Str::password](#method-str-password)
[Str::plural](#method-str-plural)
[Str::pluralStudly](#method-str-plural-studly)
[Str::random](#method-str-random)
[Str::remove](#method-str-remove)
[Str::replace](#method-str-replace)
[Str::replaceArray](#method-str-replace-array)
[Str::replaceFirst](#method-str-replace-first)
[Str::replaceLast](#method-str-replace-last)
[Str::reverse](#method-str-reverse)
[Str::singular](#method-str-singular)
[Str::slug](#method-str-slug)
[Str::snake](#method-snake-case)
[Str::squish](#method-str-squish)
[Str::start](#method-str-start)
[Str::startsWith](#method-starts-with)
[Str::studly](#method-studly-case)
[Str::substr](#method-str-substr)
[Str::substrCount](#method-str-substrcount)
[Str::substrReplace](#method-str-substrreplace)
[Str::swap](#method-str-swap)
[Str::title](#method-title-case)
[Str::toHtmlString](#method-str-to-html-string)
[Str::ucfirst](#method-str-ucfirst)
[Str::ucsplit](#method-str-ucsplit)
[Str::upper](#method-str-upper)
[Str::ulid](#method-str-ulid)
[Str::uuid](#method-str-uuid)
[Str::wordCount](#method-str-word-count)
[Str::words](#method-str-words)
[str](#method-str)
[trans](#method-trans)
[trans_choice](#method-trans-choice)

</div>

<a name="fluent-strings-method-list"></a>
### 字符流處理

<div class="collection-method-list" markdown="1">

[after](#method-fluent-str-after)
[afterLast](#method-fluent-str-after-last)
[append](#method-fluent-str-append)
[ascii](#method-fluent-str-ascii)
[basename](#method-fluent-str-basename)
[before](#method-fluent-str-before)
[beforeLast](#method-fluent-str-before-last)
[between](#method-fluent-str-between)
[betweenFirst](#method-fluent-str-between-first)
[camel](#method-fluent-str-camel)
[classBasename](#method-fluent-str-class-basename)
[contains](#method-fluent-str-contains)
[containsAll](#method-fluent-str-contains-all)
[dirname](#method-fluent-str-dirname)
[endsWith](#method-fluent-str-ends-with)
[excerpt](#method-fluent-str-excerpt)
[exactly](#method-fluent-str-exactly)
[explode](#method-fluent-str-explode)
[finish](#method-fluent-str-finish)
[headline](#method-fluent-str-headline)
[inlineMarkdown](#method-fluent-str-inline-markdown)
[is](#method-fluent-str-is)
[isAscii](#method-fluent-str-is-ascii)
[isEmpty](#method-fluent-str-is-empty)
[isNotEmpty](#method-fluent-str-is-not-empty)
[isJson](#method-fluent-str-is-json)
[isUlid](#method-fluent-str-is-ulid)
[isUuid](#method-fluent-str-is-uuid)
[kebab](#method-fluent-str-kebab)
[lcfirst](#method-fluent-str-lcfirst)
[length](#method-fluent-str-length)
[limit](#method-fluent-str-limit)
[lower](#method-fluent-str-lower)
[ltrim](#method-fluent-str-ltrim)
[markdown](#method-fluent-str-markdown)
[mask](#method-fluent-str-mask)
[match](#method-fluent-str-match)
[matchAll](#method-fluent-str-match-all)
[isMatch](#method-fluent-str-is-match)
[newLine](#method-fluent-str-new-line)
[padBoth](#method-fluent-str-padboth)
[padLeft](#method-fluent-str-padleft)
[padRight](#method-fluent-str-padright)
[pipe](#method-fluent-str-pipe)
[plural](#method-fluent-str-plural)
[prepend](#method-fluent-str-prepend)
[remove](#method-fluent-str-remove)
[replace](#method-fluent-str-replace)
[replaceArray](#method-fluent-str-replace-array)
[replaceFirst](#method-fluent-str-replace-first)
[replaceLast](#method-fluent-str-replace-last)
[replaceMatches](#method-fluent-str-replace-matches)
[rtrim](#method-fluent-str-rtrim)
[scan](#method-fluent-str-scan)
[singular](#method-fluent-str-singular)
[slug](#method-fluent-str-slug)
[snake](#method-fluent-str-snake)
[split](#method-fluent-str-split)
[squish](#method-fluent-str-squish)
[start](#method-fluent-str-start)
[startsWith](#method-fluent-str-starts-with)
[studly](#method-fluent-str-studly)
[substr](#method-fluent-str-substr)
[substrReplace](#method-fluent-str-substrreplace)
[swap](#method-fluent-str-swap)
[tap](#method-fluent-str-tap)
[test](#method-fluent-str-test)
[title](#method-fluent-str-title)
[trim](#method-fluent-str-trim)
[ucfirst](#method-fluent-str-ucfirst)
[ucsplit](#method-fluent-str-ucsplit)
[upper](#method-fluent-str-upper)
[when](#method-fluent-str-when)
[whenContains](#method-fluent-str-when-contains)
[whenContainsAll](#method-fluent-str-when-contains-all)
[whenEmpty](#method-fluent-str-when-empty)
[whenNotEmpty](#method-fluent-str-when-not-empty)
[whenStartsWith](#method-fluent-str-when-starts-with)
[whenEndsWith](#method-fluent-str-when-ends-with)
[whenExactly](#method-fluent-str-when-exactly)
[whenNotExactly](#method-fluent-str-when-not-exactly)
[whenIs](#method-fluent-str-when-is)
[whenIsAscii](#method-fluent-str-when-is-ascii)
[whenIsUlid](#method-fluent-str-when-is-ulid)
[whenIsUuid](#method-fluent-str-when-is-uuid)
[whenTest](#method-fluent-str-when-test)
[wordCount](#method-fluent-str-word-count)
[words](#method-fluent-str-words)

</div>

<a name="urls-method-list"></a>
### URLs

<div class="collection-method-list" markdown="1">

[action](#method-action)
[asset](#method-asset)
[route](#method-route)
[secure_asset](#method-secure-asset)
[secure_url](#method-secure-url)
[to_route](#method-to-route)
[url](#method-url)

</div>

<a name="miscellaneous-method-list"></a>
### 雜項

<div class="collection-method-list" markdown="1">

[abort](#method-abort)
[abort_if](#method-abort-if)
[abort_unless](#method-abort-unless)
[app](#method-app)
[auth](#method-auth)
[back](#method-back)
[bcrypt](#method-bcrypt)
[blank](#method-blank)
[broadcast](#method-broadcast)
[cache](#method-cache)
[class_uses_recursive](#method-class-uses-recursive)
[collect](#method-collect)
[config](#method-config)
[cookie](#method-cookie)
[csrf_field](#method-csrf-field)
[csrf_token](#method-csrf-token)
[decrypt](#method-decrypt)
[dd](#method-dd)
[dispatch](#method-dispatch)
[dump](#method-dump)
[encrypt](#method-encrypt)
[env](#method-env)
[event](#method-event)
[fake](#method-fake)
[filled](#method-filled)
[info](#method-info)
[logger](#method-logger)
[method_field](#method-method-field)
[now](#method-now)
[old](#method-old)
[optional](#method-optional)
[policy](#method-policy)
[redirect](#method-redirect)
[report](#method-report)
[report_if](#method-report-if)
[report_unless](#method-report-unless)
[request](#method-request)
[rescue](#method-rescue)
[resolve](#method-resolve)
[response](#method-response)
[retry](#method-retry)
[session](#method-session)
[tap](#method-tap)
[throw_if](#method-throw-if)
[throw_unless](#method-throw-unless)
[today](#method-today)
[trait_uses_recursive](#method-trait-uses-recursive)
[transform](#method-transform)
[validator](#method-validator)
[value](#method-value)
[view](#method-view)
[with](#method-with)

</div>

<a name="method-listing"></a>
## 方法列表

<style>
    .collection-method code {
        font-size: 14px;
    }

    .collection-method:not(.first-collection-method) {
        margin-top: 50px;
    }

</style>

<a name="arrays"></a>
## 數組 & 對象

<a name="method-array-accessible"></a>
#### `Arr::accessible()` {.collection-method .first-collection-method}

 `Arr::accessible` 方法檢查給定的值是否可被數組式訪問：

    use Illuminate\Support\Arr;
    use Illuminate\Support\Collection;

    $isAccessible = Arr::accessible(['a' => 1, 'b' => 2]);

    // true

    $isAccessible = Arr::accessible(new Collection);

    // true

    $isAccessible = Arr::accessible('abc');

    // false

    $isAccessible = Arr::accessible(new stdClass);

    // false

<a name="method-array-add"></a>
#### `Arr::add()` {.collection-method}

如果給定的鍵名在數組中不存在鍵值或該鍵值設置為 `null` ，那麽 `Arr::add` 方法將會把給定的鍵值對添加到數組中：

    use Illuminate\Support\Arr;

    $array = Arr::add(['name' => 'Desk'], 'price', 100);

    // ['name' => 'Desk', 'price' => 100]

    $array = Arr::add(['name' => 'Desk', 'price' => null], 'price', 100);

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-collapse"></a>
#### `Arr::collapse()` {.collection-method}

`Arr::collapse` 方法將多個數組合並為一個數組：

    use Illuminate\Support\Arr;

    $array = Arr::collapse([[1, 2, 3], [4, 5, 6], [7, 8, 9]]);

    // [1, 2, 3, 4, 5, 6, 7, 8, 9]

<a name="method-array-crossjoin"></a>
#### `Arr::crossJoin()` {.collection-method}

`Arr::crossJoin` 方法交叉連接給定的數組，返回具有所有可能排列的笛卡爾乘積：

    use Illuminate\Support\Arr;

    $matrix = Arr::crossJoin([1, 2], ['a', 'b']);

    /*
        [
            [1, 'a'],
            [1, 'b'],
            [2, 'a'],
            [2, 'b'],
        ]
    */

    $matrix = Arr::crossJoin([1, 2], ['a', 'b'], ['I', 'II']);

    /*
        [
            [1, 'a', 'I'],
            [1, 'a', 'II'],
            [1, 'b', 'I'],
            [1, 'b', 'II'],
            [2, 'a', 'I'],
            [2, 'a', 'II'],
            [2, 'b', 'I'],
            [2, 'b', 'II'],
        ]
    */

<a name="method-array-divide"></a>
#### `Arr::divide()` {.collection-method}

`Arr::divide` 方法返回一個二維數組，一個值包含原數組的鍵，另一個值包含原數組的值：

    use Illuminate\Support\Arr;

    [$keys, $values] = Arr::divide(['name' => 'Desk']);

    // $keys: ['name']

    // $values: ['Desk']

<a name="method-array-dot"></a>
#### `Arr::dot()` {.collection-method}

`Arr::dot` 方法將多維數組中所有的鍵平鋪到一維數組中，新數組使用「.」符號表示層級包含關系：

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    $flattened = Arr::dot($array);

    // ['products.desk.price' => 100]

<a name="method-array-except"></a>
#### `Arr::except()` {.collection-method}

`Arr::except` 方法從數組中刪除指定的鍵值對：

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100];

    $filtered = Arr::except($array, ['price']);

    // ['name' => 'Desk']

<a name="method-array-exists"></a>
#### `Arr::exists()` {.collection-method}

`Arr::exists` 方法檢查給定的鍵是否存在提供的數組中：

    use Illuminate\Support\Arr;

    $array = ['name' => 'John Doe', 'age' => 17];

    $exists = Arr::exists($array, 'name');

    // true

    $exists = Arr::exists($array, 'salary');

    // false

<a name="method-array-first"></a>
#### `Arr::first()` {.collection-method}

`Arr::first` 方法返回數組中滿足指定條件的第一個元素：

    use Illuminate\Support\Arr;

    $array = [100, 200, 300];

    $first = Arr::first($array, function (int $value, int $key) {
        return $value >= 150;
    });

    // 200

可將默認值作為第三個參數傳遞給該方法，如果數組中沒有值滿足指定條件，則返回該默認值：

    use Illuminate\Support\Arr;

    $first = Arr::first($array, $callback, $default);

<a name="method-array-flatten"></a>

#### `Arr::flatten()` {.collection-method}

 `Arr::flatten` 方法將多維數組中數組的值取出平鋪為一維數組：

    use Illuminate\Support\Arr;

    $array = ['name' => 'Joe', 'languages' => ['PHP', 'Ruby']];

    $flattened = Arr::flatten($array);

    // ['Joe', 'PHP', 'Ruby']

<a name="method-array-forget"></a>
#### `Arr::forget()` {.collection-method}

`Arr::forget` 方法使用「.」符號從深度嵌套的數組中刪除給定的鍵值對：

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    Arr::forget($array, 'products.desk');

    // ['products' => []]

<a name="method-array-get"></a>
#### `Arr::get()` {.collection-method}

`Arr::get` 方法使用「.」符號從深度嵌套的數組中根據指定鍵檢索值：

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    $price = Arr::get($array, 'products.desk.price');

    // 100

 `Arr::get` 方法也可以接受一個默認值，如果數組中不存在指定的鍵，則返回默認值：

    use Illuminate\Support\Arr;

    $discount = Arr::get($array, 'products.desk.discount', 0);

    // 0

<a name="method-array-has"></a>
#### `Arr::has()` {.collection-method}

`Arr::has` 方法使用「.」符號判斷數組中是否存在指定的一個或多個鍵：

    use Illuminate\Support\Arr;

    $array = ['product' => ['name' => 'Desk', 'price' => 100]];

    $contains = Arr::has($array, 'product.name');

    // true

    $contains = Arr::has($array, ['product.price', 'product.discount']);

    // false

<a name="method-array-hasany"></a>
#### `Arr::hasAny()` {.collection-method}

`Arr::hasAny` 方法使用「.」符號判斷給定集合中的任一值是否存在於數組中：

    use Illuminate\Support\Arr;

    $array = ['product' => ['name' => 'Desk', 'price' => 100]];

    $contains = Arr::hasAny($array, 'product.name');

    // true

    $contains = Arr::hasAny($array, ['product.name', 'product.discount']);

    // true

    $contains = Arr::hasAny($array, ['category', 'product.discount']);

    // false

<a name="method-array-isassoc"></a>
#### `Arr::isAssoc()` {.collection-method}

如果給定數組是關聯數組，則 `Arr::isAssoc` 方法返回 `true`，如果該數組沒有以零開頭的順序數字鍵，則將其視為「關聯」數組：

    use Illuminate\Support\Arr;

    $isAssoc = Arr::isAssoc(['product' => ['name' => 'Desk', 'price' => 100]]);

    // true

    $isAssoc = Arr::isAssoc([1, 2, 3]);

    // false

<a name="method-array-islist"></a>
#### `Arr::isList()` {.collection-method}

如果給定數組的鍵是從零開始的連續整數，則 `Arr::isList` 方法返回 `true`：

    use Illuminate\Support\Arr;

    $isList = Arr::isList(['foo', 'bar', 'baz']);

    // true

    $isList = Arr::isList(['product' => ['name' => 'Desk', 'price' => 100]]);

    // false

<a name="method-array-join"></a>
#### `Arr::join()` {.collection-method}

`Arr::join()`方法將給定數組的所有值通過給定字符串連接起來。使用此方法的第二個參數，您還可以為數組中的最後一個元素指定連接的字符串：

    use Illuminate\Support\Arr;

    $array = ['Tailwind', 'Alpine', 'Laravel', 'Livewire'];

    $joined = Arr::join($array, ', ');

    // Tailwind, Alpine, Laravel, Livewire

    $joined = Arr::join($array, ', ', ' and ');

    // Tailwind, Alpine, Laravel and Livewire

<a name="method-array-keyby"></a>
#### `Arr::keyBy()` {.collection-method}

`Arr::keyBy()`方法通過給定鍵名的值對該數組進行重組。如果數組中存在多個相同的值，則只有最後一個值會出現在新數組中：

    use Illuminate\Support\Arr;

    $array = [
        ['product_id' => 'prod-100', 'name' => 'Desk'],
        ['product_id' => 'prod-200', 'name' => 'Chair'],
    ];

    $keyed = Arr::keyBy($array, 'product_id');

    /*
        [
            'prod-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
            'prod-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
        ]
    */

<a name="method-array-last"></a>
#### `Arr::last()` {.collection-method}

`Arr::last` 方法返回數組中滿足指定條件的最後一個元素：

    use Illuminate\Support\Arr;

    $array = [100, 200, 300, 110];

    $last = Arr::last($array, function (int $value, int $key) {
        return $value >= 150;
    });

    // 300

將默認值作為第三個參數傳遞給該方法，如果沒有值滿足條件，則返回該默認值：

    use Illuminate\Support\Arr;

    $last = Arr::last($array, $callback, $default);

<a name="method-array-map"></a>
#### `Arr::map()` {.collection-method}

`Arr::map` 方法用來遍歷數組，並將每個值和鍵傳遞給給定的回調。數組值由回調返回的值替換：

    use Illuminate\Support\Arr;

    $array = ['first' => 'james', 'last' => 'kirk'];

    $mapped = Arr::map($array, function (string $value, string $key) {
        return ucfirst($value);
    });

    // ['first' => 'James', 'last' => 'Kirk']

<a name="method-array-only"></a>
#### `Arr::only()` {.collection-method}

`Arr::only` 方法僅返回給定數組中的指定鍵/值對：

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100, 'orders' => 10];

    $slice = Arr::only($array, ['name', 'price']);

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-pluck"></a>
#### `Arr::pluck()` {.collection-method}

`Arr::pluck` 方法從數組中檢索給定鍵的所有值:

    use Illuminate\Support\Arr;

    $array = [
        ['developer' => ['id' => 1, 'name' => 'Taylor']],
        ['developer' => ['id' => 2, 'name' => 'Abigail']],
    ];

    $names = Arr::pluck($array, 'developer.name');

    // ['Taylor', 'Abigail']

你也可以指定結果的鍵:

    use Illuminate\Support\Arr;

    $names = Arr::pluck($array, 'developer.name', 'developer.id');

    // [1 => 'Taylor', 2 => 'Abigail']

<a name="method-array-prepend"></a>

<a name="method-array-last"></a>
#### `Arr::last()` {.collection-method}

`Arr::last`  方法返回數組中滿足指定條件的最後一個元素：

    use Illuminate\Support\Arr;

    $array = [100, 200, 300, 110];

    $last = Arr::last($array, function (int $value, int $key) {
        return $value >= 150;
    });

    // 300

將默認值作為第三個參數傳遞給該方法，如果沒有值滿足指定條件，則返回該默認值：

    use Illuminate\Support\Arr;

    $last = Arr::last($array, $callback, $default);

<a name="method-array-map"></a>
#### `Arr::map()` {.collection-method}

`Arr::map` 方法遍歷數組並將每個鍵和值傳遞至給定的回調方法。數組的值將替換為該回調方法返回的值：

    use Illuminate\Support\Arr;

    $array = ['first' => 'james', 'last' => 'kirk'];

    $mapped = Arr::map($array, function (string $value, string $key) {
        return ucfirst($value);
    });

    // ['first' => 'James', 'last' => 'Kirk']

<a name="method-array-only"></a>
#### `Arr::only()` {.collection-method}

`Arr::only` 方法只返回給定數組中指定的鍵值對：

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100, 'orders' => 10];

    $slice = Arr::only($array, ['name', 'price']);

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-pluck"></a>
#### `Arr::pluck()` {.collection-method}

`Arr::pluck` 方法從數組中檢索給定鍵的所有值：

    use Illuminate\Support\Arr;

    $array = [
        ['developer' => ['id' => 1, 'name' => 'Taylor']],
        ['developer' => ['id' => 2, 'name' => 'Abigail']],
    ];

    $names = Arr::pluck($array, 'developer.name');

    // ['Taylor', 'Abigail']

你還可以指定結果的鍵：

    use Illuminate\Support\Arr;

    $names = Arr::pluck($array, 'developer.name', 'developer.id');

    // [1 => 'Taylor', 2 => 'Abigail']

<a name="method-array-prepend"></a>
#### `Arr::prepend()` {.collection-method}

 `Arr::prepend` 方法將一個值插入到數組的開始位置：

    use Illuminate\Support\Arr;

    $array = ['one', 'two', 'three', 'four'];

    $array = Arr::prepend($array, 'zero');

    // ['zero', 'one', 'two', 'three', 'four']

你也可以指定插入值的鍵：

    use Illuminate\Support\Arr;

    $array = ['price' => 100];

    $array = Arr::prepend($array, 'Desk', 'name');

    // ['name' => 'Desk', 'price' => 100]

<a name="method-array-prependkeyswith"></a>
#### `Arr::prependKeysWith()` {.collection-method}

`Arr::prependKeysWith` 方法為關聯數組中的所有鍵添加給定前綴：

    use Illuminate\Support\Arr;

    $array = [
        'name' => 'Desk',
        'price' => 100,
    ];

    $keyed = Arr::prependKeysWith($array, 'product.');

    /*
        [
            'product.name' => 'Desk',
            'product.price' => 100,
        ]
    */

<a name="method-array-pull"></a>
#### `Arr::pull()` {.collection-method}

`Arr::pull` 方法從數組中返回指定鍵的值並刪除此鍵值對：

    use Illuminate\Support\Arr;

    $array = ['name' => 'Desk', 'price' => 100];

    $name = Arr::pull($array, 'name');

    // $name: Desk

    // $array: ['price' => 100]

默認值可以作為第三個參數傳遞給該方法。如果指定鍵不存在，則返回該值：

    use Illuminate\Support\Arr;

    $value = Arr::pull($array, $key, $default);

<a name="method-array-query"></a>
#### `Arr::query()` {.collection-method}

`Arr::query` 方法將數組轉換為查詢字符串：

    use Illuminate\Support\Arr;

    $array = [
        'name' => 'Taylor',
        'order' => [
            'column' => 'created_at',
            'direction' => 'desc'
        ]
    ];

    Arr::query($array);

    // name=Taylor&order[column]=created_at&order[direction]=desc

<a name="method-array-random"></a>
#### `Arr::random()` {.collection-method}

`Arr::random` 方法從數組中隨機返回一個值：

    use Illuminate\Support\Arr;

    $array = [1, 2, 3, 4, 5];

    $random = Arr::random($array);

    // 4 - (retrieved randomly)

你還可以指定返回值的數量作為可選的第二個參數傳遞給該方法，請注意，提供這個參數會返回一個數組，即使是你只需要一項：

    use Illuminate\Support\Arr;

    $items = Arr::random($array, 2);

    // [2, 5] - (retrieved randomly)

<a name="method-array-set"></a>
#### `Arr::set()` {.collection-method}

`Arr::set` 方法使用「.」符號在多維數組中設置指定鍵的值：

    use Illuminate\Support\Arr;

    $array = ['products' => ['desk' => ['price' => 100]]];

    Arr::set($array, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 200]]]

<a name="method-array-shuffle"></a>
#### `Arr::shuffle()` {.collection-method}

`Arr::shuffle` 方法將數組中值進行隨機排序：

    use Illuminate\Support\Arr;

    $array = Arr::shuffle([1, 2, 3, 4, 5]);

    // [3, 2, 5, 1, 4] - (generated randomly)

<a name="method-array-sort"></a>
#### `Arr::sort()` {.collection-method}

`Arr::sort` 方法根據給定數組的值進行升序排序：

    use Illuminate\Support\Arr;

    $array = ['Desk', 'Table', 'Chair'];

    $sorted = Arr::sort($array);

    // ['Chair', 'Desk', 'Table']

你還可以根據給定回調方法的返回結果對數組進行排序：

    use Illuminate\Support\Arr;

    $array = [
        ['name' => 'Desk'],
        ['name' => 'Table'],
        ['name' => 'Chair'],
    ];

    $sorted = array_values(Arr::sort($array, function (array $value) {
        return $value['name'];
    }));

    /*
        [
            ['name' => 'Chair'],
            ['name' => 'Desk'],
            ['name' => 'Table'],
        ]
    */

<a name="method-array-sort-desc"></a>
#### `Arr::sortDesc()` {.collection-method}

`Arr::sortDesc`  方法根據給定數組的值進行降序排序：

    use Illuminate\Support\Arr;

    $array = ['Desk', 'Table', 'Chair'];

    $sorted = Arr::sortDesc($array);

    // ['Table', 'Desk', 'Chair']

你還可以根據給定回調方法的返回結果對數組進行排序：

    use Illuminate\Support\Arr;

    $array = [
        ['name' => 'Desk'],
        ['name' => 'Table'],
        ['name' => 'Chair'],
    ];

    $sorted = array_values(Arr::sortDesc($array, function (array $value) {
        return $value['name'];
    }));

    /*
        [
            ['name' => 'Table'],
            ['name' => 'Desk'],
            ['name' => 'Chair'],
        ]
    */

<a name="method-array-sort-recursive"></a>
#### `Arr::sortRecursive()` {.collection-method}

`Arr::sortRecursive` 方法對給定數組進行遞歸排序，使用 `sort` 方法對數字索引子數組進行按值升序排序，使用 `ksort` 方法對關聯子數組進行按鍵升序排序：

    use Illuminate\Support\Arr;

    $array = [
        ['Roman', 'Taylor', 'Li'],
        ['PHP', 'Ruby', 'JavaScript'],
        ['one' => 1, 'two' => 2, 'three' => 3],
    ];

    $sorted = Arr::sortRecursive($array);

    /*
        [
            ['JavaScript', 'PHP', 'Ruby'],
            ['one' => 1, 'three' => 3, 'two' => 2],
            ['Li', 'Roman', 'Taylor'],
        ]
    */



<a name="method-array-to-css-classes"></a>
#### `Arr::toCssClasses()` {.collection-method}

`Arr::toCssClasses` 方法根據給定的條件編譯並返回 CSS 類字符串。該方法接受一個類數組，其中數組鍵包含你希望添加的一個或多個 CSS Class，而值是一個布爾表達式。如果數組元素有一個數字鍵，它將始終包含在呈現的類列表中：

    use Illuminate\Support\Arr;

    $isActive = false;
    $hasError = true;

    $array = ['p-4', 'font-bold' => $isActive, 'bg-red' => $hasError];

    $classes = Arr::toCssClasses($array);

    /*
        'p-4 bg-red'
    */

Laravel 基於該方法實現 [Blade 組件里的條件合並類](/docs/laravel/10.x/blademd#conditionally-merge-classes) 以及 `@class` [Blade 指令](/docs/laravel/10.x/blademd#conditional-classes)：

<a name="method-array-undot"></a>
#### `Arr::undot()` {.collection-method}

`Arr::undot` 方法使用「.」符號將一維數組擴展為多維數組：

    use Illuminate\Support\Arr;

    $array = [
        'user.name' => 'Kevin Malone',
        'user.occupation' => 'Accountant',
    ];

    $array = Arr::undot($array);

    // ['user' => ['name' => 'Kevin Malone', 'occupation' => 'Accountant']]

<a name="method-array-where"></a>

#### `Arr::where()` {.collection-method}

`Arr::where` 方法使用給定的回調函數返回的結果過濾數組：

    use Illuminate\Support\Arr;

    $array = [100, '200', 300, '400', 500];

    $filtered = Arr::where($array, function (string|int $value, int $key) {
        return is_string($value);
    });

    // [1 => '200', 3 => '400']

<a name="method-array-where-not-null"></a>
#### `Arr::whereNotNull()` {.collection-method}

`Arr::whereNotNull` 方法將從給定數組中刪除所有 `null` 值：

    use Illuminate\Support\Arr;

    $array = [0, null];

    $filtered = Arr::whereNotNull($array);

    // [0 => 0]

<a name="method-array-wrap"></a>
#### `Arr::wrap()` {.collection-method}

`Arr::wrap` 方法可以將給定值轉換為一個數組，如果給定的值已經是一個數組，它將原樣返回：

    use Illuminate\Support\Arr;

    $string = 'Laravel';

    $array = Arr::wrap($string);

    // ['Laravel']

如果給定值是 `null` ，將返回一個空數組：

    use Illuminate\Support\Arr;

    $array = Arr::wrap(null);

    // []

<a name="method-data-fill"></a>
#### `data_fill()` {#collection-method}

`data_fill` 函數使用「.」符號給多維數組或對象設置缺少的值：

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_fill($data, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 100]]]

    data_fill($data, 'products.desk.discount', 10);

    // ['products' => ['desk' => ['price' => 100, 'discount' => 10]]]

也可以接收 「\*」 作為通配符，設置相應缺少的值：

    $data = [
        'products' => [
            ['name' => 'Desk 1', 'price' => 100],
            ['name' => 'Desk 2'],
        ],
    ];

    data_fill($data, 'products.*.price', 200);

    /*
        [
            'products' => [
                ['name' => 'Desk 1', 'price' => 100],
                ['name' => 'Desk 2', 'price' => 200],
            ],
        ]
    */

<a name="method-data-get"></a>
#### `data_get()` {#collection-method}

`data_get` 函數使用 「.」 符號從多維數組或對象中根據指定鍵檢索值

    $data = ['products' => ['desk' => ['price' => 100]]];

    $price = data_get($data, 'products.desk.price');

    // 100

`data_get` 函數也接受一個默認值，如果沒有找到指定的鍵，將返回默認值：

    $discount = data_get($data, 'products.desk.discount', 0);

    // 0

該函數還接受「\*」作為通配符，來指向數組或對象的任何鍵：

    $data = [
        'product-one' => ['name' => 'Desk 1', 'price' => 100],
        'product-two' => ['name' => 'Desk 2', 'price' => 150],
    ];

    data_get($data, '*.name');

    // ['Desk 1', 'Desk 2'];

<a name="method-data-set"></a>
#### `data_set()` {#collection-method}

`data_set` 函數使用「.」符號從多維數組或對象中根據指定鍵設置值：

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_set($data, 'products.desk.price', 200);

    // ['products' => ['desk' => ['price' => 200]]]

同 `data_get` 一樣，函數也支持使用「\*」 作為通配符給相應鍵名賦值：

    $data = [
        'products' => [
            ['name' => 'Desk 1', 'price' => 100],
            ['name' => 'Desk 2', 'price' => 150],
        ],
    ];

    data_set($data, 'products.*.price', 200);

    /*
        [
            'products' => [
                ['name' => 'Desk 1', 'price' => 200],
                ['name' => 'Desk 2', 'price' => 200],
            ],
        ]
    */

通常情況下，已存在的值將會被覆蓋。如果只是希望設置一個目前不存在的值，你可以增加一個 `false` 作為函數的第四個參數：

    $data = ['products' => ['desk' => ['price' => 100]]];

    data_set($data, 'products.desk.price', 200, overwrite: false);

    // ['products' => ['desk' => ['price' => 100]]]

<a name="method-head"></a>
#### `head()` {#collection-method}

`head` 函數將返回數組中的第一個值：

    $array = [100, 200, 300];

    $first = head($array);

    // 100

<a name="method-last"></a>

#### `last()` {.collection-method}

`last` 函數將返回數組中的最後一個值：

    $array = [100, 200, 300];

    $last = last($array);

    // 300

<a name="paths"></a>
## 路徑

<a name="method-app-path"></a>
#### `app_path()` {.collection-method}

`app_path` 函數返回 `app` 目錄的完整路徑。你也可以使用 `app_path` 函數來生成應用目錄下特定文件的完整路徑：

    $path = app_path();

    $path = app_path('Http/Controllers/Controller.php');

<a name="method-base-path"></a>
#### `base_path()` {#collection-method}

`base_path` 函數返回項目根目錄的完整路徑。你也可以使用 `base_path` 函數生成項目根目錄下特定文件的完整路徑：

    $path = base_path();

    $path = base_path('vendor/bin');

<a name="method-config-path"></a>
#### `config_path()` {#collection-method}

`config_path` 函數返回項目配置目錄 (config) 的完整路徑。你也可以使用 `config_path` 函數來生成應用配置目錄中的特定文件的完整路徑：

    $path = config_path();

    $path = config_path('app.php');

<a name="method-database-path"></a>
#### `database_path()` {.collection-method}

`database_path` 函數返回 `database` 目錄的完整路徑。你可以使用 `database_path` 函數來生成數據庫目錄下指定文件的完整路徑：

    $path = database_path();

    $path = database_path('factories/UserFactory.php');

<a name="method-lang-path"></a>
#### `lang_path()` {.collection-method}

The `lang_path` 函數返回 `lang` 目錄的完整路徑。你可以使用 `lang_path`  函數來生成自定義語言目錄下指定文件的完整路徑：

    $path = lang_path();

    $path = lang_path('en/messages.php');

> **注意**
> 默認情況下，Laravel 框架不包含 `lang` 目錄。如果你想自定義 Laravel 的語言文件，可以通過 Artisan 命令 `lang:publish` 來發布它們。

<a name="method-mix"></a>
#### `mix()` {.collection-method}

`mix` 函數返回 [編譯前端資源（Mix）的路徑](/docs/laravel/10.x/mix)，便於加載 css，js 等靜態文件：

    $path = mix('css/app.css');

<a name="method-public-path"></a>
#### `public_path()` {.collection-method}

`public_path` 函數返回 `public` 目錄的完整路徑。你可以使用 `public_path` 函數來生成`public` 目錄下指定文件的完整路徑：

    $path = public_path();

    $path = public_path('css/app.css');

<a name="method-resource-path"></a>
#### `resource_path()` {.collection-method}

`resource_path` 函數返回 `resource` 目錄的完整路徑。你可以使用 `resource_path` 函數來生成位於資源路徑中指定文件的完整路徑：

    $path = resource_path();

    $path = resource_path('sass/app.scss');

<a name="method-storage-path"></a>
#### `storage_path()`

`storage_path` 函數返回 `storage` 目錄的完整路徑。 你也可以用 `storage_path` 函數來生成位於資源路徑中的特定文件路徑

    $path = storage_path();

    $path = storage_path('app/file.txt');

<a name="strings"></a>

## 字符串

<a name="method-__"></a>

#### `__()`

`__`函數可使用 [本地化文件](/docs/laravel/10.x/localization) 來翻譯指定的字符串或特定的 key

    echo __('Welcome to our application');

    echo __('messages.welcome');

如果給定翻譯的字符串或者 key 不存在， 則 `__` 會返回你指定的值。所以上述例子中， 如果給定翻譯的字符串或者 key 不存在，則 `__` 函數會返回 `messages.welcome`。

<a name="method-class-basename"></a>

#### `class_basename()`

`class_basename` 函數返回不帶命名空間的特定類的類名：

    $class = class_basename('Foo\Bar\Baz');

    // Baz

<a name="method-e"></a>

#### `e()`

`e` 函數運行 PHP 的 `htmlspecialchars` 函數，且 `double_encode` 默認設定為 `true`：

    echo e('<html>foo</html>');

    // &lt;html&gt;foo&lt;/html&gt;

<a name="method-preg-replace-array"></a>

#### `preg_replace_array()` {.collection-method}

`preg_replace_array` 函數按數組順序替換字符串中符合給定模式的字符：

    $string = 'The event will take place between :start and :end';

    $replaced = preg_replace_array('/:[a-z_]+/', ['8:30', '9:00'], $string);

    // The event will take place between 8:30 and 9:00

<a name="method-str-after"></a>

#### `Str::after()`

`Str::after` 方法返回字符串中指定值之後的所有內容。如果字符串中不存在這個值，它將返回整個字符串：

    use Illuminate\Support\Str;

    $slice = Str::after('This is my name', 'This is');

    // ' my name'



<a name="method-str-after-last"></a>

#### `Str::afterLast()`

`Str::afterLast` 方法返回字符串中指定值最後一次出現後的所有內容。如果字符串中不存在這個值，它將返回整個字符串：

    use Illuminate\Support\Str;

    $slice = Str::afterLast('App\Http\Controllers\Controller', '\\');

    // 'Controller'

<a name="method-str-ascii"></a>

#### `Str::ascii()`

`Str::ascii` 方法嘗試將字符串轉換為 ASCII 值：

    use Illuminate\Support\Str;

    $slice = Str::ascii('û');

    // 'u'

<a name="method-str-before"></a>

#### `Str::before()`

`Str::before` 方法返回字符串中指定值之前的所有內容：

    use Illuminate\Support\Str;

    $slice = Str::before('This is my name', 'my name');

    // 'This is '

<a name="method-str-before-last"></a>

#### `Str::beforeLast()`

`Str::beforeLast` 方法返回字符串中指定值最後一次出現前的所有內容：

    use Illuminate\Support\Str;

    $slice = Str::beforeLast('This is my name', 'is');

    // 'This '

<a name="method-str-between"></a>

#### `Str::between()`

`Str::between` 方法返回字符串在指定兩個值之間的內容：

    use Illuminate\Support\Str;

    $slice = Str::between('This is my name', 'This', 'name');

    // ' is my '

<a name="method-str-between-first"></a>

#### `Str::betweenFirst()`

 `Str::betweenFirst` 方法返回字符串在指定兩個值之間的最小可能的部分：

    use Illuminate\Support\Str;

    $slice = Str::betweenFirst('[a] bc [d]', '[', ']');

    // 'a'

<a name="method-camel-case"></a>

#### `Str::camel()`

`Str::camel` 方法將指定字符串轉換為 `駝峰式` 表示方法：

    use Illuminate\Support\Str;

    $converted = Str::camel('foo_bar');

    // fooBar



<a name="method-str-contains"></a>

#### `Str::contains()`

`Str::contains` 方法判斷指定字符串中是否包含另一指定字符串（區分大小寫）：

    use Illuminate\Support\Str;

    $contains = Str::contains('This is my name', 'my');

    // true

你也可以傳遞一個數組來判斷指定字符串是否包含數組中的任一值：

    use Illuminate\Support\Str;

    $contains = Str::contains('This is my name', ['my', 'foo']);

    // true

<a name="method-str-contains-all"></a>
#### `Str::containsAll()`

`Str::containsAll` 方法用於判斷指定字符串是否包含指定數組中的所有值：

    use Illuminate\Support\Str;

    $containsAll = Str::containsAll('This is my name', ['my', 'name']);

    // true

<a name="method-ends-with"></a>
#### `Str::endsWith()`

`Str::endsWith` 方法用於判斷指定字符串是否以另一指定字符串結尾：

    use Illuminate\Support\Str;

    $result = Str::endsWith('This is my name', 'name');

    // true

你也可以傳一個數組來判斷指定字符串是否以指定數組中的任一值結尾：

    use Illuminate\Support\Str;

    $result = Str::endsWith('This is my name', ['name', 'foo']);

    // true

    $result = Str::endsWith('This is my name', ['this', 'foo']);

    // false

<a name="method-excerpt"></a>
#### `Str::excerpt()`

`Str::excerpt` 方法提取字符串中給定短語匹配到的第一個片段：

    use Illuminate\Support\Str;

    $excerpt = Str::excerpt('This is my name', 'my', [
        'radius' => 3
    ]);

    // '...is my na...'

`radius` 選項默認為 `100`，允許你定義應出現在截斷字符串前後的字符數。

此外，你可以使用`omission`選項來定義將附加到截斷字符串的字符串：

    use Illuminate\Support\Str;

    $excerpt = Str::excerpt('This is my name', 'name', [
        'radius' => 3,
        'omission' => '(...) '
    ]);

    // '(...) my name'

<a name="method-str-finish"></a>

#### `Str::finish()` {.collection-method}

`Str::finish`方法將指定的字符串修改為以指定的值結尾的形式：

    use Illuminate\Support\Str;

    $adjusted = Str::finish('this/string', '/');

    // this/string/

    $adjusted = Str::finish('this/string/', '/');

    // this/string/

<a name="method-str-headline"></a>
#### `Str::headline()` {.collection-method}

`Str::headline`方法會將由大小寫、連字符或下劃線分隔的字符串轉換為空格分隔的字符串，同時保證每個單詞的首字母大寫：

    use Illuminate\Support\Str;

    $headline = Str::headline('steve_jobs');

    // Steve Jobs

    $headline = Str::headline('郵件通知發送');

    // 郵件通知發送

<a name="method-str-inline-markdown"></a>
#### `Str::inlineMarkdown()` {.collection-method}

`Str::inlineMarkdown`方法使用[通用標記](https://commonmark.thephpleague.com/)將 GitHub 風味 Markdown 轉換為內聯 HTML。然而，與`markdown`方法不同的是，它不會將所有生成的 HTML 都包裝在塊級元素中:

    use Illuminate\Support\Str;

    $html = Str::inlineMarkdown('**Laravel**');

    // <strong>Laravel</strong>

<a name="method-str-is"></a>
#### `Str::is()` {.collection-method}

`Str::is`方法用來判斷字符串是否與指定模式匹配。星號`*`可用於表示通配符：

    use Illuminate\Support\Str;

    $matches = Str::is('foo*', 'foobar');

    // true

    $matches = Str::is('baz*', 'foobar');

    // false

<a name="method-str-is-ascii"></a>
#### `Str::isAscii()` {.collection-method}

`Str::isAscii`方法用於判斷字符串是否是 7 位 ASCII：

    use Illuminate\Support\Str;

    $isAscii = Str::isAscii('Taylor');

    // true

    $isAscii = Str::isAscii('ü');

    // false

<a name="method-str-is-json"></a>
#### `Str::isJson()` {.collection-method}

`Str::isJson`方法確定給定的字符串是否是有效的 JSON：

    use Illuminate\Support\Str;

    $result = Str::isJson('[1,2,3]');

    // true

    $result = Str::isJson('{"first": "John", "last": "Doe"}');

    // true

    $result = Str::isJson('{first: "John", last: "Doe"}');

    // false

<a name="method-str-is-ulid"></a>
#### `Str::isUlid()` {.collection-method}

`Str::isUlid`方法用於判斷指定字符串是否是有效的 ULID：

    use Illuminate\Support\Str;

    $isUlid = Str::isUlid('01gd6r360bp37zj17nxb55yv40');

    // true

    $isUlid = Str::isUlid('laravel');

    // false

<a name="method-str-is-uuid"></a>
#### `Str::isUuid()` {.collection-method}

`Str::isUuid`方法用於判斷指定字符串是否是有效的 UUID：

    use Illuminate\Support\Str;

    $isUuid = Str::isUuid('a0a2a2d2-0b87-4a18-83f2-2529882be2de');

    // true

    $isUuid = Str::isUuid('laravel');

    // false

<a name="method-kebab-case"></a>
#### `Str::kebab()` {.collection-method}

`Str::kebab`方法將字符串轉換為`烤串式（ kebab-case ）`表示方法：

    use Illuminate\Support\Str;

    $converted = Str::kebab('fooBar');

    // foo-bar

<a name="method-str-lcfirst"></a>
#### `Str::lcfirst()` {.collection-method}

`Str::lcfirst`方法返回第一個小寫字符的給定字符串:

    use Illuminate\Support\Str;

    $string = Str::lcfirst('Foo Bar');

    // foo Bar

<a name="method-str-length"></a>
#### `Str::length()` {.collection-method}

`Str::length`方法返回指定字符串的長度：

    use Illuminate\Support\Str;

    $length = Str::length('Laravel');

    // 7

<a name="method-str-limit"></a>
#### `Str::limit()` {.collection-method}

`Str::limit`方法將字符串以指定長度進行截斷：

    use Illuminate\Support\Str;

    $truncated = Str::limit('敏捷的棕色狐貍跳過懶惰的狗', 20);

    // 敏捷的棕色狐貍...

你也可通過第三個參數來改變追加到末尾的字符串：

    use Illuminate\Support\Str;

    $truncated = Str::limit('敏捷的棕色狐貍跳過懶惰的狗', 20, ' (...)');

    // 敏捷的棕色狐貍 (...)

<a name="method-str-lower"></a>
#### `Str::lower()` {.collection-method}

`Str::lower`方法用於將字符串轉換為小寫：

    use Illuminate\Support\Str;

    $converted = Str::lower('LARAVEL');

    // laravel

<a name="method-str-markdown"></a>
#### `Str::markdown()` {.collection-method}

`Str::markdown`方法將 GitHub 風格的 Markdown 轉換為 HTML 使用 [通用標記](https://commonmark.thephpleague.com/):

    use Illuminate\Support\Str;

    $html = Str::markdown('# Laravel');

    // <h1>Laravel</h1>

    $html = Str::markdown('# Taylor <b>Otwell</b>', [
        'html_input' => 'strip',
    ]);

    // <h1>Taylor Otwell</h1>

<a name="method-str-mask"></a>
#### `Str::mask()` {.collection-method}

`Str::mask`方法會使用重覆的字符掩蓋字符串的一部分，並可用於混淆字符串段，例如電子郵件地址和電話號碼：

    use Illuminate\Support\Str;

    $string = Str::mask('taylor@example.com', '*', 3);

    // tay***************

你可以提供一個負數作為`mask`方法的第三個參數，這將指示該方法在距字符串末尾的給定距離處開始屏蔽：

    $string = Str::mask('taylor@example.com', '*', -15, 3);

    // tay***@example.com

<a name="method-str-ordered-uuid"></a>
#### `Str::orderedUuid()` {.collection-method}

`Str::orderedUuid`方法用於生成一個「時間戳優先」的 UUID ，它可作為數據庫索引列的有效值。使用此方法生成的每個 UUID 將排在之前使用該方法生成的 UUID 後面：

    use Illuminate\Support\Str;

    return (string) Str::orderedUuid();

<a name="method-str-padboth"></a>
#### `Str::padBoth()` {.collection-method}

`Str::padBoth`方法包裝了 PHP 的`str_pad 方法`，在指定字符串的兩側填充上另一字符串：

    use Illuminate\Support\Str;

    $padded = Str::padBoth('James', 10, '_');

    // '__James___'

    $padded = Str::padBoth('James', 10);

    // '  James   '

<a name="method-str-padleft"></a>
#### `Str::padLeft()` {.collection-method}

`Str::padLeft`方法包裝了 PHP 的`str_pad`方法，在指定字符串的左側填充上另一字符串：

    use Illuminate\Support\Str;

    $padded = Str::padLeft('James', 10, '-=');

    // '-=-=-James'

    $padded = Str::padLeft('James', 10);

    // '     James'

<a name="method-str-padright"></a>
#### `Str::padRight()` {.collection-method}

`Str::padRight`方法包裝了 PHP 的`str_pad`方法，在指定字符串的右側填充上另一字符串：

    use Illuminate\Support\Str;

    $padded = Str::padRight('James', 10, '-');

    // 'James-----'

    $padded = Str::padRight('James', 10);

    // 'James     '

<a name="method-str-password"></a>
#### `Str::password()` {.collection-method}

`Str::password`方法可用於生成給定長度的安全隨機密碼。密碼由字母、數字、符號和空格組成。默認情況下，密碼長度為32位:

    use Illuminate\Support\Str;

    $password = Str::password();

    // 'EbJo2vE-AS:U,$%_gkrV4n,q~1xy/-_4'

    $password = Str::password(12);

    // 'qwuar>#V|i]N'

<a name="method-str-plural"></a>
#### `Str::plural()` {.collection-method}

`Str::plural`方法將單數形式的字符串轉換為覆數形式。此方法支持 [Laravel 覆數形式所支持的任何語言](/docs/laravel/10.x/localizationmd#pluralization-language)：

    use Illuminate\Support\Str;

    $plural = Str::plural('car');

    // cars

    $plural = Str::plural('child');

    // children

你可以提供一個整數作為方法的第二個參數來檢索字符串的單數或覆數形式：

    use Illuminate\Support\Str;

    $plural = Str::plural('child', 2);

    // children

    $singular = Str::plural('child', 1);

    // child

<a name="method-str-plural-studly"></a>
#### `Str::pluralStudly()` {.collection-method}

`Str::pluralStudly`方法將以駝峰格式的單數字符串轉化為其覆數形式。此方法支持 [Laravel 覆數形式所支持的任何語言](/docs/laravel/10.x/localization#pluralization-language)：

    use Illuminate\Support\Str;

    $plural = Str::pluralStudly('VerifiedHuman');

    // VerifiedHumans

    $plural = Str::pluralStudly('UserFeedback');

    // UserFeedback

你可以提供一個整數作為方法的第二個參數來檢索字符串的單數或覆數形式：

    use Illuminate\Support\Str;

    $plural = Str::pluralStudly('VerifiedHuman', 2);

    // VerifiedHumans

    $singular = Str::pluralStudly('VerifiedHuman', 1);

    // VerifiedHuman

<a name="method-str-random"></a>
#### `Str::random()` {.collection-method}

`Str::random` 方法用於生成指定長度的隨機字符串。這個方法使用了PHP的 `random_bytes` 函數：

    use Illuminate\Support\Str;

    $random = Str::random(40);

<a name="method-str-remove"></a>
#### `Str::remove()` {.collection-method}

`Str::remove` 方法從字符串中刪除給定值或給定數組內的所有值：

    use Illuminate\Support\Str;

    $string = 'Peter Piper picked a peck of pickled peppers.';

    $removed = Str::remove('e', $string);

    // Ptr Pipr pickd a pck of pickld ppprs.

你還可以將`false`作為第三個參數傳遞給`remove`方法以在刪除字符串時忽略大小寫。

<a name="method-str-replace"></a>
#### `Str::replace()` {.collection-method}

`Str::replace` 方法用於替換字符串中的給定字符串：

    use Illuminate\Support\Str;

    $string = 'Laravel 10.x';

    $replaced = Str::replace('9.x', '10.x', $string);

    // Laravel 10.x

<a name="method-str-replace-array"></a>
#### `Str::replaceArray()` {.collection-method}

`Str::replaceArray` 方法使用數組有序的替換字符串中的特定字符：

    use Illuminate\Support\Str;

    $string = '該活動將在 ? 至 ? 舉行';

    $replaced = Str::replaceArray('?', ['8:30', '9:00'], $string);

    // 該活動將在 8:30 至 9:00 舉行

<a name="method-str-replace-first"></a>
#### `Str::replaceFirst()` {.collection-method}

`Str::replaceFirst` 方法替換字符串中給定值的第一個匹配項：

    use Illuminate\Support\Str;

    $replaced = Str::replaceFirst('the', 'a', 'the quick brown fox jumps over the lazy dog');

    // a quick brown fox jumps over the lazy dog

<a name="method-str-replace-last"></a>
#### `Str::replaceLast()` {.collection-method}

`Str::replaceLast` 方法替換字符串中最後一次出現的給定值：

    use Illuminate\Support\Str;

    $replaced = Str::replaceLast('the', 'a', 'the quick brown fox jumps over the lazy dog');

    // the quick brown fox jumps over a lazy dog

<a name="method-str-reverse"></a>
#### `Str::reverse()` {.collection-method}

`Str::reverse` 方法用於反轉給定的字符串：

    use Illuminate\Support\Str;

    $reversed = Str::reverse('Hello World');

    // dlroW olleH

<a name="method-str-singular"></a>
#### `Str::singular()` {.collection-method}

`Str::singular` 方法將字符串轉換為單數形式。此方法支持 [Laravel 覆數形式所支持的任何語言](/docs/laravel/10.x/localizationmd#pluralization-language)：

    use Illuminate\Support\Str;

    $singular = Str::singular('cars');

    // car

    $singular = Str::singular('children');

    // child

<a name="method-str-slug"></a>
#### `Str::slug()` {.collection-method}

`Str::slug` 方法將給定的字符串生成一個 URL 友好的「slug」：

    use Illuminate\Support\Str;

    $slug = Str::slug('Laravel 10 Framework', '-');

    // laravel-10-framework

<a name="method-snake-case"></a>
#### `Str::snake()` {.collection-method}

`Str::snake` 方法是將駝峰的函數名或者字符串轉換成 `_` 命名的函數或者字符串，例如 `snakeCase` 轉換成 `snake_case`：

    use Illuminate\Support\Str;

    $converted = Str::snake('fooBar');

    // foo_bar

    $converted = Str::snake('fooBar', '-');

    // foo-bar

<a name="method-str-squish"></a>
#### `Str::squish()` {.collection-method}

`Str::squish`方法刪除字符串中所有多余的空白，包括單詞之間多余的空白:

    use Illuminate\Support\Str;

    $string = Str::squish('    laravel    framework    ');

    // laravel framework

<a name="method-str-start"></a>
#### `Str::start()` {.collection-method}

`Str::start`方法是將給定的值添加到字符串的開始位置，例如：

    use Illuminate\Support\Str;

    $adjusted = Str::start('this/string', '/');

    // /this/string

    $adjusted = Str::start('/this/string', '/');

    // /this/string

<a name="method-starts-with"></a>
#### `Str::startsWith()` {.collection-method}

`Str::startsWith`方法用來判斷給定的字符串是否為給定值的開頭：

    use Illuminate\Support\Str;

    $result = Str::startsWith('This is my name', 'This');

    // true

如果傳遞了一個可能值的數組且字符串以任何給定值開頭，則`startsWith`方法將返回`true`：

    $result = Str::startsWith('This is my name', ['This', 'That', 'There']);

    // true

<a name="method-studly-case"></a>
#### `Str::studly()` {.collection-method}

`Str::studly`方法將給定的字符串轉換為`駝峰命名`的字符串：

    use Illuminate\Support\Str;

    $converted = Str::studly('foo_bar');

    // FooBar

<a name="method-str-substr"></a>
#### `Str::substr()` {.collection-method}

`Str::substr`方法返回由 start 和 length 參數指定的字符串部分:

    use Illuminate\Support\Str;

    $converted = Str::substr('The Laravel Framework', 4, 7);

    // Laravel

<a name="method-str-substrcount"></a>
#### `Str::substrCount()` {.collection-method}

`Str::substrCount` 方法返回給定字符串中給定值的出現次數：

    use Illuminate\Support\Str;

    $count = Str::substrCount('If you like ice cream, you will like snow cones.', 'like');

    // 2

<a name="method-str-substrreplace"></a>
#### `Str::substrReplace()` {.collection-method}

`Str::substrReplace` 方法替換字符串一部分中的文本，從第三個參數指定的位置開始，替換第四個參數指定的字符數。 當「0」傳遞給方法的第四個參數將在指定位置插入字符串，而不是替換字符串中的任何現有字符：

    use Illuminate\Support\Str;

    $result = Str::substrReplace('1300', ':', 2);
    // 13:

    $result = Str::substrReplace('1300', ':', 2, 0);
    // 13:00

<a name="method-str-swap"></a>
#### `Str::swap()` {.collection-method}

`Str::swap` 方法使用 PHP 的 `strtr` 函數替換給定字符串中的多個值：

    use Illuminate\Support\Str;

    $string = Str::swap([
        'Tacos' => 'Burritos',
        'great' => 'fantastic',
    ], 'Tacos are great!');

    // Burritos are fantastic！

<a name="method-title-case"></a>
#### `Str::title()` {.collection-method}

`Str::title` 方法將給定的字符串轉換為 `Title Case`：

    use Illuminate\Support\Str;

    $converted = Str::title('a nice title uses the correct case');

    // A Nice Title Uses The Correct Case

<a name="method-str-to-html-string"></a>
#### `Str::toHtmlString()` {.collection-method}

`Str::toHtmlString` 方法將字符串實例轉換為 `Illuminate\Support\HtmlString` 的實例，它可以顯示在 Blade 模板中：

    use Illuminate\Support\Str;

    $htmlString = Str::of('Nuno Maduro')->toHtmlString();

<a name="method-str-ucfirst"></a>
#### `Str::ucfirst()` {.collection-method}

`Str::ucfirst` 方法返回第一個字符大寫的給定字符串：

    use Illuminate\Support\Str;

    $string = Str::ucfirst('foo bar');

    // Foo bar

<a name="method-str-ucsplit"></a>
#### `Str::ucsplit()` {.collection-method}

`Str::ucsplit` 方法將給定的字符串按大寫字符拆分為數組：

    use Illuminate\Support\Str;

    $segments = Str::ucsplit('FooBar');

    // [0 => 'Foo', 1 => 'Bar']

<a name="method-str-upper"></a>
#### `Str::upper()` {.collection-method}

`Str::upper` 方法將給定的字符串轉換為大寫：

    use Illuminate\Support\Str;

    $string = Str::upper('laravel');

    // LARAVEL

<a name="method-str-ulid"></a>
#### `Str::ulid()` {.collection-method}

`Str::ulid` 方法生成一個 ULID：

    use Illuminate\Support\Str;

    return (string) Str::ulid();

    // 01gd6r360bp37zj17nxb55yv40

<a name="method-str-uuid"></a>
#### `Str::uuid()` {.collection-method}

`Str::uuid` 方法生成一個 UUID（版本 4）：

    use Illuminate\Support\Str;

    return (string) Str::uuid();

<a name="method-str-word-count"></a>
#### `Str::wordCount()` {.collection-method}

`Str::wordCount` 方法返回字符串包含的單詞數

```php
use Illuminate\Support\Str;

Str::wordCount('Hello, world!'); // 2
```

<a name="method-str-words"></a>
#### `Str::words()` {.collection-method}

`Str::words` 方法限制字符串中的單詞數。 可以通過其第三個參數將附加字符串傳遞給此方法，以指定應將這個字符串附加到截斷後的字符串末尾：

    use Illuminate\Support\Str;

    return Str::words('Perfectly balanced, as all things should be.', 3, ' >>>');

    // Perfectly balanced, as >>>

<a name="method-str"></a>
#### `str()` {.collection-method}

`str` 函數返回給定字符串的新 `Illuminate\Support\Stringable` 實例。 此函數等效於 `Str::of` 方法：

    $string = str('Taylor')->append(' Otwell');

    // 'Taylor Otwell'

如果沒有為 `str` 函數提供參數，該函數將返回 `Illuminate\Support\Str` 的實例：

    $snake = str()->snake('FooBar');

    // 'foo_bar'

<a name="method-trans"></a>
#### `trans()` {.collection-method}

`trans` 函數使用你的 [語言文件](/docs/laravel/10.x/localization) 翻譯給定的翻譯鍵：

```
     echo trans('messages.welcome');
```

如果指定的翻譯鍵不存在，`trans` 函數將返回給定的鍵。 因此，使用上面的示例，如果翻譯鍵不存在，`trans` 函數將返回 `messages.welcome`。

<a name="method-trans-choice"></a>

#### `trans_choice()` {.collection-method}

`trans_choice` 函數用詞形變化翻譯給定的翻譯鍵：

```
     echo trans_choice('messages.notifications', $unreadCount);
```

如果指定的翻譯鍵不存在，`trans_choice` 函數將返回給定的鍵。 因此，使用上面的示例，如果翻譯鍵不存在，`trans_choice` 函數將返回 `messages.notifications`。

<a name="fluent-strings"></a>
## 字符流處理

Fluent strings 提供了一個更流暢的、面向對象的接口來處理字符串值，與傳統的字符串操作相比，允許你使用更易讀的語法將多個字符串操作鏈接在一起。

<a name="method-fluent-str-after"></a>
#### `after` {.collection-method}

`after` 方法返回字符串中給定值之後的所有內容。 如果字符串中不存在該值，則將返回整個字符串：

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->after('This is');

    // ' my name'

<a name="method-fluent-str-after-last"></a>
#### `afterLast` {.collection-method}

`afterLast` 方法返回字符串中最後一次出現給定值之後的所有內容。 如果字符串中不存在該值，則將返回整個字符串

    use Illuminate\Support\Str;

    $slice = Str::of('App\Http\Controllers\Controller')->afterLast('\\');

    // 'Controller'

<a name="method-fluent-str-append"></a>
#### `append` {.collection-method}

`append` 方法將給定的值附加到字符串：

    use Illuminate\Support\Str;

    $string = Str::of('Taylor')->append(' Otwell');

    // 'Taylor Otwell'

<a name="method-fluent-str-ascii"></a>
#### `ascii` {.collection-method}

`ascii` 方法將嘗試將字符串音譯為 ASCII 值：

    use Illuminate\Support\Str;

    $string = Str::of('ü')->ascii();

    // 'u'

<a name="method-fluent-str-basename"></a>
#### `basename` {.collection-method}

`basename` 方法將返回給定字符串的結尾名稱部分：

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->basename();

    // 'baz'

如果需要，你可以提供將從尾隨組件中刪除的「擴展名」：

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz.jpg')->basename('.jpg');

    // 'baz'

<a name="method-fluent-str-before"></a>
#### `before` {.collection-method}

`before` 方法返回字符串中給定值之前的所有內容：

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->before('my name');

    // 'This is '

<a name="method-fluent-str-before-last"></a>
#### `beforeLast` {.collection-method}

`beforeLast` 方法返回字符串中最後一次出現給定值之前的所有內容：

    use Illuminate\Support\Str;

    $slice = Str::of('This is my name')->beforeLast('is');

    // 'This '

<a name="method-fluent-str-between"></a>
#### `between` {.collection-method}

`between` 方法返回兩個值之間的字符串部分：

    use Illuminate\Support\Str;

    $converted = Str::of('This is my name')->between('This', 'name');

    // ' is my '

<a name="method-fluent-str-between-first"></a>
#### `betweenFirst` {.collection-method}

`betweenFirst` 方法返回兩個值之間字符串的最小可能部分：

    use Illuminate\Support\Str;

    $converted = Str::of('[a] bc [d]')->betweenFirst('[', ']');

    // 'a'

<a name="method-fluent-str-camel"></a>
#### `camel` {.collection-method}

`camel` 方法將給定的字符串轉換為 `camelCase`：

    use Illuminate\Support\Str;

    $converted = Str::of('foo_bar')->camel();

    // fooBar

<a name="method-fluent-str-class-basename"></a>
#### `classBasename` {.collection-method}

`classBasename` 方法返回給定類的類名，刪除了類的命名空間：

    use Illuminate\Support\Str;

    $class = Str::of('Foo\Bar\Baz')->classBasename();

    // Baz

<a name="method-fluent-str-contains"></a>
#### `contains` {.collection-method}

`contains` 方法確定給定的字符串是否包含給定的值。 此方法區分大小寫：

    use Illuminate\Support\Str;

    $contains = Str::of('This is my name')->contains('my');

    // true

你還可以傳遞一個值數組來確定給定字符串是否包含數組中的任意值：

    use Illuminate\Support\Str;

    $contains = Str::of('This is my name')->contains(['my', 'foo']);

    // true

<a name="method-fluent-str-contains-all"></a>
#### `containsAll` {.collection-method}

`containsAll` 方法確定給定字符串是否包含給定數組中的所有值：

    use Illuminate\Support\Str;

    $containsAll = Str::of('This is my name')->containsAll(['my', 'name']);

    // true

<a name="method-fluent-str-dirname"></a>
#### `dirname` {.collection-method}

`dirname` 方法返回給定字符串的父目錄部分：

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->dirname();

    // '/foo/bar'

如有必要，你還可以指定要從字符串中刪除多少目錄級別：

    use Illuminate\Support\Str;

    $string = Str::of('/foo/bar/baz')->dirname(2);

    // '/foo'

<a name="method-fluent-str-excerpt"></a>
#### `excerpt` {.collection-method}

`excerpt` 方法從字符串中提取與該字符串中短語的第一個實例匹配的摘錄：

    use Illuminate\Support\Str;

    $excerpt = Str::of('This is my name')->excerpt('my', [
        'radius' => 3
    ]);

    // '...is my na...'

`radius` 選項默認為 `100`，允許你定義應出現在截斷字符串每一側的字符數。

此外，還可以使用 `omission` 選項更改將添加到截斷字符串之前和附加的字符串

    use Illuminate\Support\Str;

    $excerpt = Str::of('This is my name')->excerpt('name', [
        'radius' => 3,
        'omission' => '(...) '
    ]);

    // '(...) my name'

<a name="method-fluent-str-ends-with"></a>
#### `endsWith` {.collection-method}

`endsWith` 方法確定給定字符串是否以給定值結尾：

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->endsWith('name');

    // true

你還可以傳遞一個值數組來確定給定字符串是否以數組中的任何值結尾：

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->endsWith(['name', 'foo']);

    // true

    $result = Str::of('This is my name')->endsWith(['this', 'foo']);

    // false

<a name="method-fluent-str-exactly"></a>
#### `exactly` {.collection-method}

`exactly` 方法確定給定的字符串是否與另一個字符串完全匹配：

    use Illuminate\Support\Str;

    $result = Str::of('Laravel')->exactly('Laravel');

    // true

<a name="method-fluent-str-explode"></a>
#### `explode` {.collection-method}

`explode` 方法按給定的分隔符拆分字符串並返回包含拆分字符串的每個部分的集合：

    use Illuminate\Support\Str;

    $collection = Str::of('foo bar baz')->explode(' ');

    // collect(['foo', 'bar', 'baz'])

<a name="method-fluent-str-finish"></a>
#### `finish` {.collection-method}

`finish` 方法將給定值的單個實例添加到字符串中（如果它尚未以該值結尾）：
    use Illuminate\Support\Str;

    $adjusted = Str::of('this/string')->finish('/');

    // this/string/

    $adjusted = Str::of('this/string/')->finish('/');

    // this/string/

<a name="method-fluent-str-headline"></a>
#### `headline` {.collection-method}

`headline` 方法會將由大小寫、連字符或下劃線分隔的字符串轉換為空格分隔的字符串，每個單詞的首字母大寫：

    use Illuminate\Support\Str;

    $headline = Str::of('taylor_otwell')->headline();

    // Taylor Otwell

    $headline = Str::of('EmailNotificationSent')->headline();

    // Email Notification Sent

<a name="method-fluent-str-inline-markdown"></a>
#### `inlineMarkdown` {.collection-method}

`inlineMarkdown` 方法使用 [CommonMark](https://commonmark.thephpleague.com/) 將 GitHub 風格的 Markdown 轉換為內聯 HTML。 但是，與 `markdown` 方法不同，它不會將所有生成的 HTML 包裝在塊級元素中：

    use Illuminate\Support\Str;

    $html = Str::of('**Laravel**')->inlineMarkdown();

    // <strong>Laravel</strong>

<a name="method-fluent-str-is"></a>
#### `is` {.collection-method}

`is` 方法確定給定字符串是否與給定模式匹配。 星號可用作通配符值

    use Illuminate\Support\Str;

    $matches = Str::of('foobar')->is('foo*');

    // true

    $matches = Str::of('foobar')->is('baz*');

    // false

<a name="method-fluent-str-is-ascii"></a>
#### `isAscii` {.collection-method}

`isAscii` 方法確定給定字符串是否為 ASCII 字符串：

    use Illuminate\Support\Str;

    $result = Str::of('Taylor')->isAscii();

    // true

    $result = Str::of('ü')->isAscii();

    // false

<a name="method-fluent-str-is-empty"></a>
#### `isEmpty` {.collection-method}

`isEmpty` 方法確定給定的字符串是否為空：

    use Illuminate\Support\Str;

    $result = Str::of('  ')->trim()->isEmpty();

    // true

    $result = Str::of('Laravel')->trim()->isEmpty();

    // false

<a name="method-fluent-str-is-not-empty"></a>
#### `isNotEmpty` {.collection-method}

`isNotEmpty` 方法確定給定的字符串是否不為空：

    use Illuminate\Support\Str;

    $result = Str::of('  ')->trim()->isNotEmpty();

    // false

    $result = Str::of('Laravel')->trim()->isNotEmpty();

    // true

<a name="method-fluent-str-is-json"></a>
#### `isJson` {.collection-method}

`isJson` 方法確定給定的字符串是否是有效的 JSON:

    use Illuminate\Support\Str;

    $result = Str::of('[1,2,3]')->isJson();

    // true

    $result = Str::of('{"first": "John", "last": "Doe"}')->isJson();

    // true

    $result = Str::of('{first: "John", last: "Doe"}')->isJson();

    // false

<a name="method-fluent-str-is-ulid"></a>
#### `isUlid` {.collection-method}

`isUlid` 方法確定給定的字符串是否一個 ULID:

    use Illuminate\Support\Str;

    $result = Str::of('01gd6r360bp37zj17nxb55yv40')->isUlid();

    // true

    $result = Str::of('Taylor')->isUlid();

    // false

<a name="method-fluent-str-is-uuid"></a>
#### `isUuid` {.collection-method}

`isUuid` 方法確定給定的字符串是否是一個 UUID:

    use Illuminate\Support\Str;

    $result = Str::of('5ace9ab9-e9cf-4ec6-a19d-5881212a452c')->isUuid();

    // true

    $result = Str::of('Taylor')->isUuid();

    // false

<a name="method-fluent-str-kebab"></a>
#### `kebab` {.collection-method}

`kebab` 方法轉變給定的字符串為 `kebab-case`:

    use Illuminate\Support\Str;

    $converted = Str::of('fooBar')->kebab();

    // foo-bar

<a name="method-fluent-str-lcfirst"></a>

#### `lcfirst` {.collection-method}

`lcfirst` 方法返回給定的字符串的第一個字符為小寫字母:

    use Illuminate\Support\Str;

    $string = Str::of('Foo Bar')->lcfirst();

    // foo Bar

<a name="method-fluent-str-length"></a>

#### `length` {.collection-method}

`length` 方法返回給定字符串的長度:

    use Illuminate\Support\Str;

    $length = Str::of('Laravel')->length();

    // 7

<a name="method-fluent-str-limit"></a>
#### `limit` {.collection-method}

`limit` 方法將給定的字符串截斷為指定的長度:

    use Illuminate\Support\Str;

    $truncated = Str::of('The quick brown fox jumps over the lazy dog')->limit(20);

    // The quick brown fox...

你也可以通過第二個參數來改變追加到末尾的字符串：

    use Illuminate\Support\Str;

    $truncated = Str::of('The quick brown fox jumps over the lazy dog')->limit(20, ' (...)');

    // The quick brown fox (...)

<a name="method-fluent-str-lower"></a>
#### `lower`

`lower` 方法將指定字符串轉換為小寫：

    use Illuminate\Support\Str;

    $result = Str::of('LARAVEL')->lower();

    // 'laravel'

<a name="method-fluent-str-ltrim"></a>
#### `ltrim`

`ltrim` 方法移除字符串左端指定的字符：

    use Illuminate\Support\Str;

    $string = Str::of('  Laravel  ')->ltrim();

    // 'Laravel  '

    $string = Str::of('/Laravel/')->ltrim('/');

    // 'Laravel/'

<a name="method-fluent-str-markdown"></a>

#### `markdown` {.collection-method}
`markdown` 方法將 Github 風格的 Markdown 轉換為 HTML：

    use Illuminate\Support\Str;

    $html = Str::of('# Laravel')->markdown();

    // <h1>Laravel</h1>

    $html = Str::of('# Taylor <b>Otwell</b>')->markdown([
        'html_input' => 'strip',
    ]);

    // <h1>Taylor Otwell</h1>

<a name="method-fluent-str-mask"></a>
#### `mask`

`mask` 方法用重覆字符掩蓋字符串的一部分，可用於模糊處理字符串的某些段，例如電子郵件地址和電話號碼：

    use Illuminate\Support\Str;

    $string = Str::of('taylor@example.com')->mask('*', 3);

    // tay***************

需要的話，你可以提供一個負數作為 `mask` 方法的第三或第四個參數，這將指示該方法在距字符串末尾的給定距離處開始屏蔽：

    $string = Str::of('taylor@example.com')->mask('*', -15, 3);

    // tay***@example.com

    $string = Str::of('taylor@example.com')->mask('*', 4, -4);

    // tayl**********.com

<a name="method-fluent-str-match"></a>
#### `match`

`match` 方法將會返回字符串中和指定正則表達式匹配的部分：

    use Illuminate\Support\Str;

    $result = Str::of('foo bar')->match('/bar/');

    // 'bar'

    $result = Str::of('foo bar')->match('/foo (.*)/');

    // 'bar'

<a name="method-fluent-str-match-all"></a>
#### `matchAll`

`matchAll` 方法將會返回一個集合，該集合包含了字符串中與指定正則表達式匹配的部分

    use Illuminate\Support\Str;

    $result = Str::of('bar foo bar')->matchAll('/bar/');

    // collect(['bar', 'bar'])

如果你在正則表達式中指定了一個匹配組， Laravel 將會返回與該組匹配的集合：

    use Illuminate\Support\Str;

    $result = Str::of('bar fun bar fly')->matchAll('/f(\w*)/');

    // collect(['un', 'ly']);

如果沒有找到任何匹配項，則返回空集合。

<a name="method-fluent-str-is-match"></a>
#### `isMatch`

`isMatch` 方法用於判斷給定的字符串是否與正則表達式匹配：

    use Illuminate\Support\Str;

    $result = Str::of('foo bar')->isMatch('/foo (.*)/');

    // true

    $result = Str::of('laravel')->match('/foo (.*)/');

    // false

<a name="method-fluent-str-new-line"></a>
#### `newLine`

`newLine` 方法將給字符串追加換行的字符：

    use Illuminate\Support\Str;

    $padded = Str::of('Laravel')->newLine()->append('Framework');

    // 'Laravel
    //  Framework'

<a name="method-fluent-str-padboth"></a>
#### `padBoth`

`padBoth` 方法包裝了 PHP 的 `str_pad` 函數，在指定字符串的兩側填充上另一字符串，直至該字符串到達指定的長度：

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padBoth(10, '_');

    // '__James___'

    $padded = Str::of('James')->padBoth(10);

    // '  James   '

<a name="method-fluent-str-padleft"></a>
#### `padLeft`

The `padLeft` 方法包裝了 PHP 的 `str_pad` 函數，在指定字符串的左側填充上另一字符串，直至該字符串到達指定的長度：

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padLeft(10, '-=');

    // '-=-=-James'

    $padded = Str::of('James')->padLeft(10);

    // '     James'

<a name="method-fluent-str-padright"></a>
#### `padRight`

`padRight` 方法包裝了 PHP 的 `str_pad` 函數，在指定字符串的右側填充上另一字符串，直至該字符串到達指定的長度：

    use Illuminate\Support\Str;

    $padded = Str::of('James')->padRight(10, '-');

    // 'James-----'

    $padded = Str::of('James')->padRight(10);

    // 'James     '

<a name="method-fluent-str-pipe"></a>
#### `pipe`

`pipe` 方法將把字符串的當前值傳遞給指定的函數來轉換字符串：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $hash = Str::of('Laravel')->pipe('md5')->prepend('Checksum: ');

    // 'Checksum: a5c95b86291ea299fcbe64458ed12702'

    $closure = Str::of('foo')->pipe(function (Stringable $str) {
        return 'bar';
    });

    // 'bar'

<a name="method-fluent-str-plural"></a>
#### `plural`

`plural` 方法將單數形式的字符串轉換為覆數形式。該此函數支持 [Laravel的覆數化器支持的任何語言](/docs/laravel/10.x/localizationmd#pluralization-language)

    use Illuminate\Support\Str;

    $plural = Str::of('car')->plural();

    // cars

    $plural = Str::of('child')->plural();

    // children

你也可以給該函數提供一個整數作為第二個參數，用於檢索字符串的單數或覆數形式：

    use Illuminate\Support\Str;

    $plural = Str::of('child')->plural(2);

    // children

    $plural = Str::of('child')->plural(1);

    // child

<a name="method-fluent-str-prepend"></a>
#### `prepend`

`prepend` 方法用於在指定字符串的開頭插入另一指定字符串：

    use Illuminate\Support\Str;

    $string = Str::of('Framework')->prepend('Laravel ');

    // Laravel Framework

<a name="method-fluent-str-remove"></a>
#### `remove`

`remove` 方法用於從字符串中刪除給定的值或值數組：

    use Illuminate\Support\Str;

    $string = Str::of('Arkansas is quite beautiful!')->remove('quite');

    // Arkansas is beautiful!

你也可以傳遞 `false` 作為第二個參數以在刪除字符串時忽略大小寫。

<a name="method-fluent-str-replace"></a>
#### `replace`

`replace` 方法用於將字符串中的指定字符串替換為另一指定字符串：

    use Illuminate\Support\Str;

    $replaced = Str::of('Laravel 9.x')->replace('9.x', '10.x');

    // Laravel 10.x

<a name="method-fluent-str-replace-array"></a>
#### `replaceArray`

`replaceArray` 方法使用數組順序替換字符串中的給定值：

    use Illuminate\Support\Str;

    $string = 'The event will take place between ? and ?';

    $replaced = Str::of($string)->replaceArray('?', ['8:30', '9:00']);

    // The event will take place between 8:30 and 9:00

<a name="method-fluent-str-replace-first"></a>
#### `replaceFirst`

`replaceFirst` 方法替換字符串中給定值的第一個匹配項：

    use Illuminate\Support\Str;

    $replaced = Str::of('the quick brown fox jumps over the lazy dog')->replaceFirst('the', 'a');

    // a quick brown fox jumps over the lazy dog

<a name="method-fluent-str-replace-last"></a>
#### `replaceLast`

`replaceLast` 方法替換字符串中給定值的最後一個匹配項：

    use Illuminate\Support\Str;

    $replaced = Str::of('the quick brown fox jumps over the lazy dog')->replaceLast('the', 'a');

    // the quick brown fox jumps over a lazy dog

<a name="method-fluent-str-replace-matches"></a>
#### `replaceMatches`

`replaceMatches` 方法用給定的替換字符串替換與模式匹配的字符串的所有部分

    use Illuminate\Support\Str;

    $replaced = Str::of('(+1) 501-555-1000')->replaceMatches('/[^A-Za-z0-9]++/', '')

    // '15015551000'

`replaceMatches` 方法還接受一個閉包，該閉包將在字符串的每個部分與給定模式匹配時調用，從而允許你在閉包中執行替換邏輯並返回替換的值：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $replaced = Str::of('123')->replaceMatches('/\d/', function (Stringable $match) {
        return '['.$match[0].']';
    });

    // '[1][2][3]'

<a name="method-fluent-str-rtrim"></a>
#### `rtrim`

`rtrim` 方法修剪給定字符串的右側：

    use Illuminate\Support\Str;

    $string = Str::of('  Laravel  ')->rtrim();

    // '  Laravel'

    $string = Str::of('/Laravel/')->rtrim('/');

    // '/Laravel'

<a name="method-fluent-str-scan"></a>
#### `scan`

`scan` 方法根據 [PHP 函數 sscanf](https://www.php.net/manual/en/function.sscanf.php) 支持的格式把字符串中的輸入解析為集合：

    use Illuminate\Support\Str;

    $collection = Str::of('filename.jpg')->scan('%[^.].%s');

    // collect(['filename', 'jpg'])

<a name="method-fluent-str-singular"></a>
#### `singular`

`singular` 方法將字符串轉換為其單數形式。此函數支持 [Laravel的覆數化器支持的任何語言](/docs/laravel/10.x/localizationmd#pluralization-language) ：

    use Illuminate\Support\Str;

    $singular = Str::of('cars')->singular();

    // car

    $singular = Str::of('children')->singular();

    // child

<a name="method-fluent-str-slug"></a>
#### `slug` {.collection-method}

`slug` 方法從給定字符串生成 URL 友好的 "slug"：

    use Illuminate\Support\Str;

    $slug = Str::of('Laravel Framework')->slug('-');

    // laravel-framework

<a name="method-fluent-str-snake"></a>
#### `snake` {.collection-method}

`snake` 方法將給定字符串轉換為 `snake_case`

    use Illuminate\Support\Str;

    $converted = Str::of('fooBar')->snake();

    // foo_bar

<a name="method-fluent-str-split"></a>
#### `split` {.collection-method}

split 方法使用正則表達式將字符串拆分為集合：

    use Illuminate\Support\Str;

    $segments = Str::of('one, two, three')->split('/[\s,]+/');

    // collect(["one", "two", "three"])

<a name="method-fluent-str-squish"></a>
#### `squish` {.collection-method}

`squish` 方法刪除字符串中所有無關緊要的空白,包括字符串之間的空白:

    use Illuminate\Support\Str;

    $string = Str::of('    laravel    framework    ')->squish();

    // laravel framework

<a name="method-fluent-str-start"></a>
#### `start` {.collection-method}

`start` 方法將給定值的單個實例添加到字符串中，前提是該字符串尚未以該值開頭：

    use Illuminate\Support\Str;

    $adjusted = Str::of('this/string')->start('/');

    // /this/string

    $adjusted = Str::of('/this/string')->start('/');

    // /this/string

<a name="method-fluent-str-starts-with"></a>
#### `startsWith` {.collection-method}

`startsWith` 方法確定給定字符串是否以給定值開頭：

    use Illuminate\Support\Str;

    $result = Str::of('This is my name')->startsWith('This');

    // true

<a name="method-fluent-str-studly"></a>
#### `studly` {.collection-method}

`studly` 方法將給定字符串轉換為 `StudlyCase`：

    use Illuminate\Support\Str;

    $converted = Str::of('foo_bar')->studly();

    // FooBar

<a name="method-fluent-str-substr"></a>
#### `substr` {.collection-method}

`substr` 方法返回由給定的起始參數和長度參數指定的字符串部分：

    use Illuminate\Support\Str;

    $string = Str::of('Laravel Framework')->substr(8);

    // Framework

    $string = Str::of('Laravel Framework')->substr(8, 5);

    // Frame

<a name="method-fluent-str-substrreplace"></a>
#### `substrReplace` {.collection-method}

`substrReplace` 方法在字符串的一部分中替換文本，從第二個參數指定的位置開始替換第三個參數指定的字符數。將 `0` 傳遞給方法的第三個參數將在指定位置插入字符串，而不替換字符串中的任何現有字符：

    use Illuminate\Support\Str;

    $string = Str::of('1300')->substrReplace(':', 2);

    // 13:

    $string = Str::of('The Framework')->substrReplace(' Laravel', 3, 0);

    // The Laravel Framework

<a name="method-fluent-str-swap"></a>
#### `swap` {.collection-method}

`swap` 方法使用 PHP 的 `strtr` 函數替換字符串中的多個值：

    use Illuminate\Support\Str;

    $string = Str::of('Tacos are great!')
        ->swap([
            'Tacos' => 'Burritos',
            'great' => 'fantastic',
        ]);

    // Burritos are fantastic!

<a name="method-fluent-str-tap"></a>

#### `tap` {.collection-method}

`tap` 方法將字符串傳遞給給定的閉包，允許你在不影響字符串本身的情況下檢查字符串並與之交互。`tap` 方法返回原始字符串，而不管閉包返回什麽：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('Laravel')
        ->append(' Framework')
        ->tap(function (Stringable $string) {
            dump('String after append: '.$string);
        })
        ->upper();

    // LARAVEL FRAMEWORK

<a name="method-fluent-str-test"></a>
#### `test` {.collection-method}

`test` 方法確定字符串是否與給定的正則表達式模式匹配：

    use Illuminate\Support\Str;

    $result = Str::of('Laravel Framework')->test('/Laravel/');

    // true

<a name="method-fluent-str-title"></a>

#### `title` {.collection-method}

`title` 方法將給定字符串轉換為 `title Case`：

    use Illuminate\Support\Str;

    $converted = Str::of('a nice title uses the correct case')->title();

    // A Nice Title Uses The Correct Case

<a name="method-fluent-str-trim"></a>
#### `trim` {.collection-method}

`trim` 方法修剪給定字符串：

    use Illuminate\Support\Str;

    $string = Str::of('  Laravel  ')->trim();

    // 'Laravel'

    $string = Str::of('/Laravel/')->trim('/');

    // 'Laravel'

<a name="method-fluent-str-ucfirst"></a>
#### `ucfirst` {.collection-method}

`ucfirst` 方法返回第一個字符大寫的給定字符串

    use Illuminate\Support\Str;

    $string = Str::of('foo bar')->ucfirst();

    // Foo bar

<a name="method-fluent-str-ucsplit"></a>
#### `ucsplit` {.collection-method}

`ucsplit` 方法將給定的字符串按大寫字符分割為一個集合:

    use Illuminate\Support\Str;

    $string = Str::of('Foo Bar')->ucsplit();

    // collect(['Foo', 'Bar'])

<a name="method-fluent-str-upper"></a>
#### `upper` {.collection-method}

`upper` 方法將給定字符串轉換為大寫：

    use Illuminate\Support\Str;

    $adjusted = Str::of('laravel')->upper();

    // LARAVEL

<a name="method-fluent-str-when"></a>
#### `when` {.collection-method}

如果給定的條件為 `true`，則 `when` 方法調用給定的閉包。閉包將接收一個流暢字符串實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('Taylor')
                    ->when(true, function (Stringable $string) {
                        return $string->append(' Otwell');
                    });

    // 'Taylor Otwell'

如果需要，可以將另一個閉包作為第三個參數傳遞給 `when` 方法。如果條件參數的計算結果為 `false`，則將執行此閉包。

<a name="method-fluent-str-when-contains"></a>
#### `whenContains` {.collection-method}

`whenContains` 方法會在字符串包含給定的值的前提下，調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('tony stark')
                ->whenContains('tony', function (Stringable $string) {
                    return $string->title();
                });

    // 'Tony Stark'

如有必要，你可以將另一個閉包作為第三個參數傳遞給 `whenContains` 方法。如果字符串不包含給定值，則此閉包將執行。

你還可以傳遞一個值數組來確定給定的字符串是否包含數組中的任何值：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('tony stark')
                ->whenContains(['tony', 'hulk'], function (Stringable $string) {
                    return $string->title();
                });

    // Tony Stark

<a name="method-fluent-str-when-contains-all"></a>
#### `whenContainsAll` {.collection-method}

`whenContainsAll` 方法會在字符串包含所有給定的子字符串時，調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('tony stark')
                    ->whenContainsAll(['tony', 'stark'], function (Stringable $string) {
                        return $string->title();
                    });

    // 'Tony Stark'

如有必要，你可以將另一個閉包作為第三個參數傳遞給 `whenContainsAll` 方法。如果條件參數評估為 `false`，則此閉包將執行。

<a name="method-fluent-str-when-empty"></a>
#### `whenEmpty` {.collection-method}

如果字符串為空，`whenEmpty` 方法將調用給定的閉包。如果閉包返回一個值，`whenEmpty` 方法也將返回該值。如果閉包不返回值，則將返回字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('  ')->whenEmpty(function (Stringable $string) {
        return $string->trim()->prepend('Laravel');
    });

    // 'Laravel'

<a name="method-fluent-str-when-not-empty"></a>
#### `whenNotEmpty` {.collection-method}

如果字符串不為空，`whenNotEmpty` 方法會調用給定的閉包。如果閉包返回一個值，那麽 `whenNotEmpty` 方法也將返回該值。如果閉包沒有返回值，則返回字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('Framework')->whenNotEmpty(function (Stringable $string) {
        return $string->prepend('Laravel ');
    });

    // 'Laravel Framework'

<a name="method-fluent-str-when-starts-with"></a>
#### `whenStartsWith` {.collection-method}

如果字符串以給定的子字符串開頭，`whenStartsWith` 方法會調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('disney world')->whenStartsWith('disney', function (Stringable $string) {
        return $string->title();
    });

    // 'Disney World'

<a name="method-fluent-str-when-ends-with"></a>
#### `whenEndsWith` {.collection-method}

如果字符串以給定的子字符串結尾，`whenEndsWith` 方法會調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('disney world')->whenEndsWith('world', function (Stringable $string) {
        return $string->title();
    });

    // 'Disney World'

<a name="method-fluent-str-when-exactly"></a>
#### `whenExactly` {.collection-method}

如果字符串與給定字符串完全匹配，`whenExactly` 方法會調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('laravel')->whenExactly('laravel', function (Stringable $string) {
        return $string->title();
    });

    // 'Laravel'

<a name="method-fluent-str-when-not-exactly"></a>
#### `whenNotExactly` {.collection-method}

如果字符串與給定字符串不完全匹配，`whenNotExactly`方法將調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('framework')->whenNotExactly('laravel', function (Stringable $string) {
        return $string->title();
    });

    // 'Framework'

<a name="method-fluent-str-when-is"></a>
#### `whenIs` {.collection-method}

如果字符串匹配給定的模式，`whenIs` 方法會調用給定的閉包。星號可用作通配符值。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('foo/bar')->whenIs('foo/*', function (Stringable $string) {
        return $string->append('/baz');
    });

    // 'foo/bar/baz'

<a name="method-fluent-str-when-is-ascii"></a>
#### `whenIsAscii` {.collection-method}

如果字符串是 7 位 ASCII，`whenIsAscii` 方法會調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('laravel')->whenIsAscii(function (Stringable $string) {
        return $string->title();
    });

    // 'Laravel'

<a name="method-fluent-str-when-is-ulid"></a>
#### `whenIsUlid` {.collection-method}

如果字符串是有效的 ULID，`whenIsUlid` 方法會調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;

    $string = Str::of('01gd6r360bp37zj17nxb55yv40')->whenIsUlid(function (Stringable $string) {
        return $string->substr(0, 8);
    });

    // '01gd6r36'

<a name="method-fluent-str-when-is-uuid"></a>
#### `whenIsUuid` {.collection-method}

如果字符串是有效的 UUID，`whenIsUuid` 方法會調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('a0a2a2d2-0b87-4a18-83f2-2529882be2de')->whenIsUuid(function (Stringable $string) {
        return $string->substr(0, 8);
    });

    // 'a0a2a2d2'

<a name="method-fluent-str-when-test"></a>
#### `whenTest` {.collection-method}

如果字符串匹配給定的正則表達式，`whenTest` 方法會調用給定的閉包。閉包將接收字符流處理實例：

    use Illuminate\Support\Str;
    use Illuminate\Support\Stringable;

    $string = Str::of('laravel framework')->whenTest('/laravel/', function (Stringable $string) {
        return $string->title();
    });

    // 'Laravel Framework'

<a name="method-fluent-str-word-count"></a>
#### `wordCount` {.collection-method}

`wordCount` 方法返回字符串包含的單詞數：

```php
use Illuminate\Support\Str;

Str::of('Hello, world!')->wordCount(); // 2
```

<a name="method-fluent-str-words"></a>
#### `words` {.collection-method}

`words` 方法限制字符串中的字數。如有必要，可以指定附加到截斷字符串的附加字符串：

    use Illuminate\Support\Str;

    $string = Str::of('Perfectly balanced, as all things should be.')->words(3, ' >>>');

    // Perfectly balanced, as >>>

<a name="urls"></a>
## URLs

<a name="method-action"></a>
#### `action()` {.collection-method}

`action` 函數為給定的控制器操作生成 URL：

    use App\Http\Controllers\HomeController;

    $url = action([HomeController::class, 'index']);

如果該方法接受路由參數，則可以將它們作為第二個參數傳遞給該方法：

    $url = action([UserController::class, 'profile'], ['id' => 1]);

<a name="method-asset"></a>
#### `asset()` {.collection-method}

`asset` 函數使用請求的當前方案（HTTP 或 HTTPS）生成 URL：

    $url = asset('img/photo.jpg');

你可以通過在`.env` 文件中設置 `ASSET_URL` 變量來配置資產 URL 主機。如果你將資產托管在外部服務（如 Amazon S3 或其他 CDN）上，這將非常有用：

    // ASSET_URL=http://example.com/assets

    $url = asset('img/photo.jpg'); // http://example.com/assets/img/photo.jpg

<a name="method-route"></a>

#### `route()` {.collection-method}

`route` 函數為給定的 [命名路由](/docs/laravel/10.x/routingmd#named-routes)：

    $url = route('route.name');

如果路由接受參數，則可以將其作為第二個參數傳遞給函數：

    $url = route('route.name', ['id' => 1]);

默認情況下，`route` 函數會生成一個絕對路徑的 URL。 如果想生成一個相對路徑 URL，你可以傳遞 `false` 作為函數的第三個參數：

    $url = route('route.name', ['id' => 1], false);

<a name="method-secure-asset"></a>
#### `secure_asset()` {.collection-method}

`secure_asset` 函數使用 HTTPS 為靜態資源生成 URL：

    $url = secure_asset('img/photo.jpg');

<a name="method-secure-url"></a>
#### `secure_url()` {.collection-method}

`secure_url` 函數生成給定路徑的完全限定 HTTPS URL。 可以在函數的第二個參數中傳遞額外的 URL 段：

    $url = secure_url('user/profile');

    $url = secure_url('user/profile', [1]);

<a name="method-to-route"></a>
#### `to_route()` {.collection-method}

`to_route` 函數為給定的 [命名路由](/docs/laravel/10.x/routingmd#named-routes) 生成一個 [重定向 HTTP 響應](/docs/laravel/10.x/responsesmd#redirects)：

    return to_route('users.show', ['user' => 1]);

如有必要，你可以將應分配給重定向的 HTTP 狀態代碼和任何其他響應標頭作為第三個和第四個參數傳遞給 `to_route` 方法：

    return to_route('users.show', ['user' => 1], 302, ['X-Framework' => 'Laravel']);

<a name="method-url"></a>
#### `url()` {.collection-method}

`url` 函數生成給定路徑的完全限定 URL：

    $url = url('user/profile');

    $url = url('user/profile', [1]);

如果未提供路徑，則返回一個 `Illuminate\Routing\UrlGenerator` 實例：

    $current = url()->current();

    $full = url()->full();

    $previous = url()->previous();

<a name="miscellaneous"></a>
## 雜項

<a name="method-abort"></a>
#### `abort()` {.collection-method}

使用`abort` 函數拋出一個 [HTTP 異常](/docs/laravel/10.x/errorsmd#http-exceptions) 交給 [異常處理](/docs/laravel/10.x/errorsmd#the-exception-handler "異常處理程序")

    abort(403);

你還可以提供應發送到瀏覽器的異常消息和自定義 HTTP 響應標頭：

    abort(403, 'Unauthorized.', $headers);

<a name="method-abort-if"></a>
#### `abort_if()` {.collection-method}

如果給定的布爾表達式的計算結果為 `true`，則 `abort_if` 函數會拋出 HTTP 異常：

    abort_if(! Auth::user()->isAdmin(), 403);

與 `abort` 方法一樣，你還可以提供異常的響應文本作為函數的第三個參數，並提供自定義響應標頭數組作為函數的第四個參數。

<a name="method-abort-unless"></a>
#### `abort_unless()` {.collection-method}

如果給定的布爾表達式的計算結果為 `false`，則 `abort_unless` 函數會拋出 HTTP 異常：

    abort_unless(Auth::user()->isAdmin(), 403);

與 `abort` 方法一樣，你還可以提供異常的響應文本作為函數的第三個參數，並提供自定義響應標頭數組作為函數的第四個參數。

<a name="method-app"></a>
#### `app()` {.collection-method}

`app` 函數返回 [服務容器](/docs/laravel/10.x/container) 實例：

    $container = app();

你可以傳遞一個類或接口名稱以從容器中解析它：

    $api = app('HelpSpot\API');

<a name="method-auth"></a>
#### `auth()` {.collection-method}

`auth` 函數返回一個 [authenticator](/docs/laravel/10.x/authentication) 實例。 你可以將它用作 `Auth` 門面的替代品：

    $user = auth()->user();

如果需要，你可以指定要訪問的守衛實例：

    $user = auth('admin')->user();

<a name="method-back"></a>
#### `back()` {.collection-method}

`back` 函數生成一個 [重定向 HTTP 響應](/docs/laravel/10.x/responsesmd#redirects) 到用戶之前的位置：

    return back($status = 302, $headers = [], $fallback = '/');

    return back();

<a name="method-bcrypt"></a>
#### `bcrypt()` {.collection-method}

`bcrypt` 函數 [hashes](/docs/laravel/10.x/hashing) 使用 Bcrypt 的給定值。 您可以使用此函數作為 `Hash` 門面的替代方法：

    $password = bcrypt('my-secret-password');

<a name="method-blank"></a>
#### `blank()` {.collection-method}

`blank` 函數確定給定值是否為「空白」：

    blank('');
    blank('   ');
    blank(null);
    blank(collect());

    // true

    blank(0);
    blank(true);
    blank(false);

    // false

對於 `blank` 的反轉，請參閱 [`filled`](#method-filled) 方法。

<a name="method-broadcast"></a>
#### `broadcast()` {.collection-method}

`broadcast` 函數 [broadcasts](/docs/laravel/10.x/broadcasting) 給定的 [event](/docs/laravel/10.x/events) 給它的聽眾：

    broadcast(new UserRegistered($user));

    broadcast(new UserRegistered($user))->toOthers();

<a name="method-cache"></a>
#### `cache()` {.collection-method}

`cache` 函數可用於從 [cache](/docs/laravel/10.x/cache) 中獲取值。 如果緩存中不存在給定的鍵，將返回一個可選的默認值：

    $value = cache('key');

    $value = cache('key', 'default');

你可以通過將鍵/值對數組傳遞給函數來將項目添加到緩存中。 你應該傳遞緩存值應被視為有效的秒數或持續時間：

    cache(['key' => 'value'], 300);

    cache(['key' => 'value'], now()->addSeconds(10));

<a name="method-class-uses-recursive"></a>
#### `class_uses_recursive()` {.collection-method}

`class_uses_recursive` 函數返回一個類使用的所有特征，包括其所有父類使用的特征：

    $traits = class_uses_recursive(App\Models\User::class);

<a name="method-collect"></a>
#### `collect()` {.collection-method}

`collect` 函數根據給定值創建一個 [collection](/docs/laravel/10.x/collections) 實例：

    $collection = collect(['taylor', 'abigail']);

<a name="method-config"></a>
#### `config()` {.collection-method}

`config` 函數獲取 [configuration](/docs/laravel/10.x/configuration) 變量的值。 可以使用「點」語法訪問配置值，其中包括文件名和你希望訪問的選項。 如果配置選項不存在，可以指定默認值並返回：

    $value = config('app.timezone');

    $value = config('app.timezone', $default);

你可以通過傳遞鍵/值對數組在運行時設置配置變量。 但是請注意，此函數只會影響當前請求的配置值，不會更新您的實際配置值：

    config(['app.debug' => true]);

<a name="method-cookie"></a>
#### `cookie()` {.collection-method}

`cookie` 函數創建一個新的 [cookie](/docs/laravel/10.x/requestsmd#cookies) 實例：

    $cookie = cookie('name', 'value', $minutes);

<a name="method-csrf-field"></a>
#### `csrf_field()` {.collection-method}

`csrf_field` 函數生成一個 HTML `hidden` 輸入字段，其中包含 CSRF 令牌的值。 例如，使用 [Blade 語法](/docs/laravel/10.x/blade)：

    {{ csrf_field() }}

<a name="method-csrf-token"></a>
#### `csrf_token()` {.collection-method}

`csrf_token` 函數檢索當前 CSRF 令牌的值：

    $token = csrf_token();

<a name="method-decrypt"></a>
#### `decrypt()` {.collection-method}

`decrypt` 函數 [解密](/docs/laravel/10.x/encryption) 給定的值。 你可以使用此函數作為 `Crypt` 門面的替代方法：

    $password = decrypt($value);

<a name="method-dd"></a>
#### `dd()` {.collection-method}

`dd` 函數轉儲給定的變量並結束腳本的執行：

    dd($value);

    dd($value1, $value2, $value3, ...);

如果你不想停止腳本的執行，請改用 [`dump`](#method-dump) 函數。

<a name="method-dispatch"></a>
#### `dispatch()` {.collection-method}

`dispatch` 函數將給定的 [job](/docs/laravel/10.x/queuesmd#creating-jobs) 推送到 Laravel [job queue](/docs/laravel/10.x/queues)：

    dispatch(new App\Jobs\SendEmails);

<a name="method-dump"></a>
#### `dump()` {.collection-method}

`dump` 函數轉儲給定的變量：

    dump($value);

    dump($value1, $value2, $value3, ...);

如果要在轉儲變量後停止執行腳本，請改用 [`dd`](#method-dd) 函數。

<a name="method-encrypt"></a>
#### `encrypt()` {.collection-method}

`encrypt` 函數 [encrypts](/docs/laravel/10.x/encryption) 給定值。 你可以使用此函數作為 `Crypt` 門面的替代方法：

    $secret = encrypt('my-secret-value');

<a name="method-env"></a>
#### `env()` {.collection-method}

`env` 函數檢索 [環境變量](/docs/laravel/10.x/configurationmd#environment-configuration) 的值或返回默認值：

    $env = env('APP_ENV');

    $env = env('APP_ENV', 'production');

> **警告**
> 如果你在部署過程中執行 `config:cache` 命令，你應該確保只從配置文件中調用 `env` 函數。 一旦配置被緩存，`.env` 文件將不會被加載，所有對 `env` 函數的調用都將返回 `null`。

<a name="method-event"></a>
#### `event()` {.collection-method}

`event` 函數將給定的 [event](/docs/laravel/10.x/events) 分派給它的監聽器：

    event(new UserRegistered($user));

<a name="method-fake"></a>
#### `fake()` {.collection-method}

`fake` 函數解析容器中的 [Faker](https://github.com/FakerPHP/Faker) 單例，這在模型工廠、數據庫填充、測試和原型視圖中創建假數據時非常有用：

```blade
@for($i = 0; $i < 10; $i++)
    <dl>
        <dt>Name</dt>
        <dd>{{ fake()->name() }}</dd>

        <dt>Email</dt>
        <dd>{{ fake()->unique()->safeEmail() }}</dd>
    </dl>
@endfor
```

默認情況下，`fake` 函數將使用 `config/app.php` 配置文件中的 `app.faker_locale` 配置選項； 但是，你也可以通過將語言環境傳遞給 `fake` 函數來指定語言環境。 每個語言環境將解析一個單獨的單例：

    fake('nl_NL')->name()

<a name="method-filled"></a>
#### `filled()` {.collection-method}

`filled` 函數確定給定值是否不是「空白」：

    filled(0);
    filled(true);
    filled(false);

    // true

    filled('');
    filled('   ');
    filled(null);
    filled(collect());

    // false

對於 `filled` 的反轉，請參閱 [`blank`](#method-blank) 方法。

<a name="method-info"></a>
#### `info()` {.collection-method}

`info` 函數會將信息寫入應用程序的 [log](/docs/laravel/10.x/logging)：

    info('Some helpful information!');

上下文數據數組也可以傳遞給函數：

    info('User login attempt failed.', ['id' => $user->id]);

<a name="method-logger"></a>
#### `logger()` {.collection-method}

`logger` 函數可用於將 `debug` 級別的消息寫入 [log](/docs/laravel/10.x/logging)：

    logger('Debug message');

上下文數據數組也可以傳遞給函數：

    logger('User has logged in.', ['id' => $user->id]);

如果沒有值傳遞給函數，將返回一個 [logger](/docs/laravel/10.x/errorsmd#logging) 實例：

    logger()->error('You are not allowed here.');

<a name="method-method-field"></a>
#### `method_field()` {.collection-method}

`method_field` 函數生成一個 HTML `hidden` 輸入字段，其中包含表單 HTTP 謂詞的欺騙值。 例如，使用 [Blade 語法](/docs/laravel/10.x/blade)：

    <form method="POST">
        {{ method_field('DELETE') }}
    </form>

<a name="method-now"></a>
#### `now()` {.collection-method}

`now` 函數為當前時間創建一個新的 `Illuminate\Support\Carbon` 實例：

    $now = now();

<a name="method-old"></a>
#### `old()` {.collection-method}

`old` 函數 [retrieves](/docs/laravel/10.x/requestsmd#retrieving-input) 一個 [old input](/docs/laravel/10.x/requestsmd#old-input) 值閃入Session :

    $value = old('value');

    $value = old('value', 'default');

由於作為 `old` 函數的第二個參數提供的「默認值」通常是 Eloquent 模型的一個屬性，Laravel 允許你簡單地將整個 Eloquent 模型作為第二個參數傳遞給 `old` 函數。 這樣做時，Laravel 將假定提供給 old 函數的第一個參數是 Eloquent 屬性的名稱，該屬性應被視為「默認值」：

    {{ old('name', $user->name) }}

    // 相當於...

    {{ old('name', $user) }}

<a name="method-optional"></a>
#### `optional()` {.collection-method}

`optional` 函數接受任何參數並允許您訪問該對象的屬性或調用方法。 如果給定對象為「null」，屬性和方法將返回「null」而不是導致錯誤：

    return optional($user->address)->street;

    {!! old('name', optional($user)->name) !!}

`optional` 函數也接受一個閉包作為它的第二個參數。 如果作為第一個參數提供的值不為空，則將調用閉包：

    return optional(User::find($id), function (User $user) {
        return $user->name;
    });

<a name="method-policy"></a>
#### `policy()` {.collection-method}

`policy` 方法檢索給定類的 [policy](/docs/laravel/10.x/authorizationmd#creating-policies) 實例：

    $policy = policy(App\Models\User::class);

<a name="method-redirect"></a>
#### `redirect()` {.collection-method}

`redirect` 函數返回一個[重定向 HTTP 響應](/docs/laravel/10.x/responsesmd#redirects)，或者如果不帶參數調用則返回重定向器實例：

    return redirect($to = null, $status = 302, $headers = [], $https = null);

    return redirect('/home');

    return redirect()->route('route.name');

<a name="method-report"></a>
#### `report()` {.collection-method}

`report` 函數將使用您的 [異常處理程序](/docs/laravel/10.x/errorsmd#the-exception-handler) 報告異常：

    report($e);

`report` 函數也接受一個字符串作為參數。 當給函數一個字符串時，該函數將創建一個異常，並將給定的字符串作為其消息：

    report('Something went wrong.');

<a name="method-report-if"></a>
#### `report_if()` {.collection-method}

如果給定條件為「true」，「report_if」函數將使用您的 [異常處理程序](/docs/laravel/10.x/errorsmd#the-exception-handler) 報告異常：

    report_if($shouldReport, $e);

    report_if($shouldReport, 'Something went wrong.');

<a name="method-report-unless"></a>
#### `report_unless()` {.collection-method}

如果給定條件為 `false`，`report_unless` 函數將使用你的 [異常處理程序](/docs/laravel/10.x/errorsmd#the-exception-handler) 報告異常：

    report_unless($reportingDisabled, $e);

    report_unless($reportingDisabled, 'Something went wrong.');

<a name="method-request"></a>
#### `request()` {.collection-method}

`request` 函數返回當前的 [request](/docs/laravel/10.x/requests) 實例或從當前請求中獲取輸入字段的值：

    $request = request();

    $value = request('key', $default);

<a name="method-rescue"></a>
#### `rescue()` {.collection-method}

`rescue` 函數執行給定的閉包並捕獲其執行期間發生的任何異常。 捕獲的所有異常都將發送到你的[異常處理程序](/docs/laravel/10.x/errorsmd#the-exception-handler)； 但是，請求將繼續處理：

    return rescue(function () {
        return $this->method();
    });

你還可以將第二個參數傳遞給「rescue」函數。 如果在執行閉包時發生異常，這個參數將是應該返回的「默認」值：

    return rescue(function () {
        return $this->method();
    }, false);

    return rescue(function () {
        return $this->method();
    }, function () {
        return $this->failure();
    });

<a name="method-resolve"></a>
#### `resolve()` {.collection-method}

`resolve` 函數使用 [服務容器](/docs/laravel/10.x/container) 將給定的類或接口名稱解析為實例：

    $api = resolve('HelpSpot\API');

<a name="method-response"></a>
#### `response()` {.collection-method}

`response` 函數創建一個 [response](/docs/laravel/10.x/responses) 實例或獲取響應工廠的實例：

    return response('Hello World', 200, $headers);

    return response()->json(['foo' => 'bar'], 200, $headers);

<a name="method-retry"></a>
#### `retry()` {.collection-method}

`retry` 函數嘗試執行給定的回調，直到達到給定的最大嘗試閾值。 如果回調沒有拋出異常，則返回它的返回值。 如果回調拋出異常，它會自動重試。 如果超過最大嘗試次數，將拋出異常：

    return retry(5, function () {
        // 嘗試 5 次，兩次嘗試之間休息 100 ms...
    }, 100);

如果想手動計算兩次嘗試之間休眠的毫秒數，你可以將閉包作為第三個參數傳遞給 `retry` 函數：

    use Exception;

    return retry(5, function () {
        // ...
    }, function (int $attempt, Exception $exception) {
        return $attempt * 100;
    });

為方便起見，你可以提供一個數組作為「retry」函數的第一個參數。 該數組將用於確定後續嘗試之間要休眠多少毫秒：

    return retry([100, 200], function () {
        // 第一次重試時休眠 100 ms，第二次重試時休眠 200 ms...
    });

要僅在特定條件下重試，您可以將閉包作為第四個參數傳遞給 `retry` 函數：

    use Exception;

    return retry(5, function () {
        // ...
    }, 100, function (Exception $exception) {
        return $exception instanceof RetryException;
    });

<a name="method-session"></a>
#### `session()` {.collection-method}

`session` 函數可用於獲取或設置 [session](/docs/laravel/10.x/session) 值：

    $value = session('key');

你可以通過將鍵/值對數組傳遞給函數來設置值：

    session(['chairs' => 7, 'instruments' => 3]);

如果沒有值傳遞給函數，會話存儲將被返回：

    $value = session()->get('key');

    session()->put('key', $value);

<a name="method-tap"></a>
#### `tap()` {.collection-method}

`tap` 函數接受兩個參數：一個任意的 `$value` 和一個閉包。 `$value` 將傳遞給閉包，然後由 `tap` 函數返回。 閉包的返回值是無關緊要的：

    $user = tap(User::first(), function (User $user) {
        $user->name = 'taylor';

        $user->save();
    });

如果沒有閉包傳遞給 `tap` 函數，你可以調用給定的 `$value` 上的任何方法。 你調用的方法的返回值將始終為「$value」，無論該方法在其定義中實際返回什麽。 例如，Eloquent 的 update 方法通常返回一個整數。 但是，我們可以通過 tap 函數鏈接 update 方法調用來強制該方法返回模型本身：

    $user = tap($user)->update([
        'name' => $name,
        'email' => $email,
    ]);

要向類添加 `tap` 方法，你可以向類添加 `Illuminate\Support\Traits\Tappable` trait。 這個特征的 `tap` 方法接受一個閉包作為它唯一的參數。 對象實例本身將被傳遞給閉包，然後由 `tap` 方法返回：

    return $user->tap(function (User $user) {
        // ...
    });

<a name="method-throw-if"></a>
#### `throw_if()` {.collection-method}

如果給定的布爾表達式的計算結果為「真」，則 `throw_if` 函數會拋出給定的異常：

    throw_if(! Auth::user()->isAdmin(), AuthorizationException::class);

    throw_if(
        ! Auth::user()->isAdmin(),
        AuthorizationException::class,
        '你不允許訪問此頁面。'
    );

<a name="method-throw-unless"></a>
#### `throw_unless()` {.collection-method}

如果給定的布爾表達式的計算結果為 `false`，則 `throw_unless` 函數會拋出給定的異常：

    throw_unless(Auth::user()->isAdmin(), AuthorizationException::class);

    throw_unless(
        Auth::user()->isAdmin(),
        AuthorizationException::class,
        '你不允許訪問此頁面。'
    );

<a name="method-today"></a>
#### `today()` {.collection-method}

`today` 函數根據當前日期創建新的 `Illuminate\Support\Carbon` 實例：

    $today = today();

<a name="method-trait-uses-recursive"></a>
#### `trait_uses_recursive()` {.collection-method}

`trait_uses_recursive` 函數返回特征使用的所有 trait：

    $traits = trait_uses_recursive(\Illuminate\Notifications\Notifiable::class);

<a name="method-transform"></a>
#### `transform()` {.collection-method}

如果值不是 [blank](#method-blank)，則 transform 函數會對給定值執行閉包，然後返回閉包的返回值：

    $callback = function (int $value) {
        return $value * 2;
    };

    $result = transform(5, $callback);

    // 10

默認值或閉包可以作為函數的第三個參數傳遞。 如果給定值為空，將返回此值：

    $result = transform(null, $callback, 'The value is blank');

    // The value is blank

<a name="method-validator"></a>
#### `validator()` {.collection-method}

`validator` 函數使用給定的參數創建一個新的 [validator](/docs/laravel/10.x/validation) 實例。 你可以將它用作 `Validator` 門面的替代品：

    $validator = validator($data, $rules, $messages);

<a name="method-value"></a>

#### `value()` {.collection-method}

`value` 函數返回給定的值。 但是，如果將閉包傳遞給函數，則將執行閉包並返回其返回值：

    $result = value(true);

    // true

    $result = value(function () {
        return false;
    });

    // false

可以將其他參數傳遞給「value」函數。 如果第一個參數是一個閉包，那麽附加參數將作為參數傳遞給閉包，否則它們將被忽略：

    $result = value(function (string $name) {
        return $name;
    }, 'Taylor');

    // 'Taylor'

<a name="method-view"></a>
#### `view()` {.collection-method}

`view` 函數檢索一個 [view](/docs/laravel/10.x/views) 實例：

    return view('auth.login');

<a name="method-with"></a>
#### `with()` {.collection-method}

`with` 函數返回給定的值。 如果將閉包作為函數的第二個參數傳遞，則將執行閉包並返回其返回值：

    $callback = function (mixed $value) {
        return is_numeric($value) ? $value * 2 : 0;
    };

    $result = with(5, $callback);

    // 10

    $result = with(null, $callback);

    // 0

    $result = with(5, null);

    // 5

<a name="other-utilities"></a>
## 其他

<a name="benchmarking"></a>
### 基準測試

有時你可能希望快速測試應用程序某些部分的性能。 在這些情況下，您可以使用 Benchmark 支持類來測量給定回調完成所需的毫秒數：

    <?php

    use App\Models\User;
    use Illuminate\Support\Benchmark;

    Benchmark::dd(fn () => User::find(1)); // 0.1 ms

    Benchmark::dd([
        'Scenario 1' => fn () => User::count(), // 0.5 ms
        'Scenario 2' => fn () => User::all()->count(), // 20.0 ms
    ]);

默認情況下，給定的回調將執行一次（一次叠代），並且它們的持續時間將顯示在瀏覽器/控制台中。

要多次調用回調，你可以將回調應調用的叠代次數指定為方法的第二個參數。 當多次執行回調時，「基準」類將返回在所有叠代中執行回調所花費的平均毫秒數：

    Benchmark::dd(fn () => User::count(), iterations: 10); // 0.5 ms

<a name="pipeline"></a>
### 管道

Laravel 的 Pipeline 門面提供了一種便捷的方式來通過一系列可調用類、閉包或可調用對象「管道」給定輸入，讓每個類都有機會檢查或修改輸入並調用管道中的下一個可調用對象：

    use Closure;
    use App\Models\User;
    use Illuminate\Support\Facades\Pipeline;

    $user = Pipeline::send($user)
            ->through([
                function (User $user, Closure $next) {
                    // ...

                    return $next($user);
                },
                function (User $user, Closure $next) {
                    // ...

                    return $next($user);
                },
            ])
            ->then(fn (User $user) => $user);

如你所見，管道中的每個可調用類或閉包都提供了輸入和一個 `$next` 閉包。 調用 `$next` 閉包將調用管道中的下一個可調用對象。 你可能已經注意到，這與 [middleware](/docs/laravel/10.x/middleware) 非常相似。

當管道中的最後一個可調用對象調用 `$next` 閉包時，提供給 `then` 方法的可調用對象將被調用。 通常，此可調用對象將簡單地返回給定的輸入。

當然，如前所述，你不僅限於為管道提供閉包。 你還可以提供可調用的類。 如果提供了類名，該類將通過 Laravel 的 [服務容器](/docs/laravel/10.x/container) 實例化，允許將依賴項注入可調用類：

    $user = Pipeline::send($user)
            ->through([
                GenerateProfilePhoto::class,
                ActivateSubscription::class,
                SendWelcomeEmail::class,
            ])
            ->then(fn (User $user) => $user);

<a name="lottery"></a>
### 彩票

Laravel 的 Lottery 類可用於根據一組給定的賠率執行回調。 當你只想為一定比例的傳入請求執行代碼時，這會特別有用：

    use Illuminate\Support\Lottery;

    Lottery::odds(1, 20)
        ->winner(fn () => $user->won())
        ->loser(fn () => $user->lost())
        ->choose();

你可以將 Laravel 的彩票類與其他 Laravel 功能結合使用。 例如，你可能希望只向異常處理程序報告一小部分慢速查詢。 而且，由於 Lottery 類是可調用的，我們可以將類的實例傳遞給任何接受可調用對象的方法：

    use Carbon\CarbonInterval;
    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\Lottery;

    DB::whenQueryingForLongerThan(
        CarbonInterval::seconds(2),
        Lottery::odds(1, 100)->winner(fn () => report('Querying > 2 seconds.')),
    );

<a name="testing-lotteries"></a>
#### 測試彩票

Laravel 提供了一些簡單的方法來讓你輕松測試應用程序的 Lottery 調用：

    // 彩票總是取勝...
    Lottery::alwaysWin();

    // 彩票總是獲敗...
    Lottery::alwaysLose();

    // 彩票會先贏後輸，最後恢覆到正常行為...
    Lottery::fix([true, false]);

    // 彩票將恢覆到正常行為...
    Lottery::determineResultsNormally();
