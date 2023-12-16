# 集合

- [介紹](#introduction)
     - [創建集合](#creating-collections)
     - [擴展集合](#extending-collections)
- [可用方法](#available-methods)
- [高階消息](#higher-order-messages)
- [惰性集合](#lazy-collections)
     - [介紹](#lazy-collection-introduction)
     - [創建惰性集合](#creating-lazy-collections)
     - [枚舉契約](#the-enumerable-contract)
     - [惰性集合方法](#lazy-collection-methods)

<a name="introduction"></a>
## 介紹

`Illuminate\Support\Collection` 類為處理數據數組提供了一個流暢、方便的包裝器。 例如，查看以下代碼。 我們將使用 `collect` 助手從數組中創建一個新的集合實例，對每個元素運行 `strtoupper` 函數，然後刪除所有空元素：

    $collection = collect(['taylor', 'abigail', null])->map(function (string $name) {
        return strtoupper($name);
    })->reject(function (string $name) {
        return empty($name);
    });

如你所見，`Collection` 類允許你鏈接其方法以執行流暢的映射和減少底層數組。一般來說，集合是不可變的，這意味著每個 `Collection` 方法都會返回一個全新的 `Collection` 實例。

<a name="creating-collections"></a>
### 創建集合

如上所述，`collect` 幫助器為給定數組返回一個新的 `Illuminate\Support\Collection` 實例。因此，創建一個集合非常簡單：

    $collection = collect([1, 2, 3]);

> **技巧：**[Eloquent](/docs/laravel/10.x/eloquent) 查詢的結果總是作為 `Collection` 實例返回。

<a name="extending-collections"></a>
### 擴展集合

集合是「可宏化的」，它允許你在運行時向 `Collection` 類添加其他方法。 `Illuminate\Support\Collection` 類的 `macro` 方法接受一個閉包，該閉包將在調用宏時執行。宏閉包可以通過 `$this` 訪問集合的其他方法，就像它是集合類的真實方法一樣。例如，以下代碼在 `Collection` 類中添加了 `toUpper` 方法：

    use Illuminate\Support\Collection;
    use Illuminate\Support\Str;

    Collection::macro('toUpper', function () {
        return $this->map(function (string $value) {
            return Str::upper($value);
        });
    });

    $collection = collect(['first', 'second']);

    $upper = $collection->toUpper();

    // ['FIRST', 'SECOND']



通常，你應該在[服務提供者](/docs/laravel/10.x/providers)的 `boot` 方法中聲明集合宏。

<a name="macro-arguments"></a>
#### 宏參數

如有必要，可以定義接受其他參數的宏：

    use Illuminate\Support\Collection;
    use Illuminate\Support\Facades\Lang;

    Collection::macro('toLocale', function (string $locale) {
        return $this->map(function (string $value) use ($locale) {
            return Lang::get($value, [], $locale);
        });
    });

    $collection = collect(['first', 'second']);

    $translated = $collection->toLocale('es');

<a name="available-methods"></a>
## 可用的方法

對於剩余的大部分集合文檔，我們將討論 `Collection` 類中可用的每個方法。請記住，所有這些方法都可以鏈式調用，以便流暢地操作底層數組。此外，幾乎每個方法都會返回一個新的 `Collection` 實例，允許你在必要時保留集合的原始副本：

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

<div class="collection-method-list" markdown="1">

[all](#method-all)
[average](#method-average)
[avg](#method-avg)
[chunk](#method-chunk)
[chunkWhile](#method-chunkwhile)
[collapse](#method-collapse)
[collect](#method-collect)
[combine](#method-combine)
[concat](#method-concat)
[contains](#method-contains)
[containsOneItem](#method-containsoneitem)
[containsStrict](#method-containsstrict)
[count](#method-count)
[countBy](#method-countBy)
[crossJoin](#method-crossjoin)
[dd](#method-dd)
[diff](#method-diff)
[diffAssoc](#method-diffassoc)
[diffKeys](#method-diffkeys)
[doesntContain](#method-doesntcontain)
[dump](#method-dump)
[duplicates](#method-duplicates)
[duplicatesStrict](#method-duplicatesstrict)
[each](#method-each)
[eachSpread](#method-eachspread)
[every](#method-every)
[except](#method-except)
[filter](#method-filter)
[first](#method-first)
[firstOrFail](#method-first-or-fail)
[firstWhere](#method-first-where)
[flatMap](#method-flatmap)
[flatten](#method-flatten)
[flip](#method-flip)
[forget](#method-forget)
[forPage](#method-forpage)
[get](#method-get)
[groupBy](#method-groupby)
[has](#method-has)
[hasAny](#method-hasany)
[implode](#method-implode)
[intersect](#method-intersect)
[intersectAssoc](#method-intersectAssoc)
[intersectByKeys](#method-intersectbykeys)
[isEmpty](#method-isempty)
[isNotEmpty](#method-isnotempty)
[join](#method-join)
[keyBy](#method-keyby)
[keys](#method-keys)
[last](#method-last)
[lazy](#method-lazy)
[macro](#method-macro)
[make](#method-make)
[map](#method-map)
[mapInto](#method-mapinto)
[mapSpread](#method-mapspread)
[mapToGroups](#method-maptogroups)
[mapWithKeys](#method-mapwithkeys)
[max](#method-max)
[median](#method-median)
[merge](#method-merge)
[mergeRecursive](#method-mergerecursive)
[min](#method-min)
[mode](#method-mode)
[nth](#method-nth)
[only](#method-only)
[pad](#method-pad)
[partition](#method-partition)
[pipe](#method-pipe)
[pipeInto](#method-pipeinto)
[pipeThrough](#method-pipethrough)
[pluck](#method-pluck)
[pop](#method-pop)
[prepend](#method-prepend)
[pull](#method-pull)
[push](#method-push)
[put](#method-put)
[random](#method-random)
[range](#method-range)
[reduce](#method-reduce)
[reduceSpread](#method-reduce-spread)
[reject](#method-reject)
[replace](#method-replace)
[replaceRecursive](#method-replacerecursive)
[reverse](#method-reverse)
[search](#method-search)
[shift](#method-shift)
[shuffle](#method-shuffle)
[skip](#method-skip)
[skipUntil](#method-skipuntil)
[skipWhile](#method-skipwhile)
[slice](#method-slice)
[sliding](#method-sliding)
[sole](#method-sole)
[some](#method-some)
[sort](#method-sort)
[sortBy](#method-sortby)
[sortByDesc](#method-sortbydesc)
[sortDesc](#method-sortdesc)
[sortKeys](#method-sortkeys)
[sortKeysDesc](#method-sortkeysdesc)
[sortKeysUsing](#method-sortkeysusing)
[splice](#method-splice)
[split](#method-split)
[splitIn](#method-splitin)
[sum](#method-sum)
[take](#method-take)
[takeUntil](#method-takeuntil)
[takeWhile](#method-takewhile)
[tap](#method-tap)
[times](#method-times)
[toArray](#method-toarray)
[toJson](#method-tojson)
[transform](#method-transform)
[undot](#method-undot)
[union](#method-union)
[unique](#method-unique)
[uniqueStrict](#method-uniquestrict)
[unless](#method-unless)
[unlessEmpty](#method-unlessempty)
[unlessNotEmpty](#method-unlessnotempty)
[unwrap](#method-unwrap)
[value](#method-value)
[values](#method-values)
[when](#method-when)
[whenEmpty](#method-whenempty)
[whenNotEmpty](#method-whennotempty)
[where](#method-where)
[whereStrict](#method-wherestrict)
[whereBetween](#method-wherebetween)
[whereIn](#method-wherein)
[whereInStrict](#method-whereinstrict)
[whereInstanceOf](#method-whereinstanceof)
[whereNotBetween](#method-wherenotbetween)
[whereNotIn](#method-wherenotin)
[whereNotInStrict](#method-wherenotinstrict)
[whereNotNull](#method-wherenotnull)
[whereNull](#method-wherenull)
[wrap](#method-wrap)
[zip](#method-zip)

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

<a name="method-all"></a>
#### `all()` {.collection-method .first-collection-method}

`all` 方法返回由集合表示的底層數組：

    collect([1, 2, 3])->all();

    // [1, 2, 3]

<a name="method-average"></a>
#### `average()` {.collection-method}

[`avg`](#method-avg) 方法的別名。

<a name="method-avg"></a>
#### `avg()` {.collection-method}

`avg` 方法返回給定鍵的 [平均值](https://en.wikipedia.org/wiki/Average)：

    $average = collect([
        ['foo' => 10],
        ['foo' => 10],
        ['foo' => 20],
        ['foo' => 40]
    ])->avg('foo');

    // 20

    $average = collect([1, 1, 2, 4])->avg();

    // 2

<a name="method-chunk"></a>
#### `chunk()` {.collection-method}

`chunk` 方法將集合分成多個給定大小的較小集合：

    $collection = collect([1, 2, 3, 4, 5, 6, 7]);

    $chunks = $collection->chunk(4);

    $chunks->all();

    // [[1, 2, 3, 4], [5, 6, 7]]

當使用諸如 [Bootstrap](https://getbootstrap.com/docs/4.1/layout/grid/) 之類的網格系統時，此方法在 [views](/docs/laravel/10.x/views) 中特別有用。例如，假設你有一組 [Eloquent](/docs/laravel/10.x/eloquent) 模型要在網格中顯示：

```blade
@foreach ($products->chunk(3) as $chunk)
    <div class="row">
        @foreach ($chunk as $product)
            <div class="col-xs-4">{{ $product->name }}</div>
        @endforeach
    </div>
@endforeach
```

<a name="method-chunkwhile"></a>
#### `chunkWhile()` {.collection-method}

`chunkWhile` 方法根據給定回調的評估將集合分成多個更小的集合。傳遞給閉包的 `$chunk` 變量可用於檢查前一個元素：

    $collection = collect(str_split('AABBCCCD'));

    $chunks = $collection->chunkWhile(function (string $value, int $key, Collection $chunk) {
        return $value === $chunk->last();
    });

    $chunks->all();

    // [['A', 'A'], ['B', 'B'], ['C', 'C', 'C'], ['D']]

<a name="method-collapse"></a>


#### `collapse()` {.collection-method}

`collapse` 方法將數組集合折疊成一個單一的平面集合：

    $collection = collect([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
    ]);

    $collapsed = $collection->collapse();

    $collapsed->all();

    // [1, 2, 3, 4, 5, 6, 7, 8, 9]

<a name="method-collect"></a>
#### `collect()` {.collection-method}

`collect` 方法返回一個新的 `Collection` 實例，其中包含當前集合中的項目：

    $collectionA = collect([1, 2, 3]);

    $collectionB = $collectionA->collect();

    $collectionB->all();

    // [1, 2, 3]

`collect` 方法主要用於將 [惰性集合](#lazy-collections) 轉換為標準的 `Collection` 實例：

    $lazyCollection = LazyCollection::make(function () {
        yield 1;
        yield 2;
        yield 3;
    });

    $collection = $lazyCollection->collect();

    get_class($collection);

    // 'Illuminate\Support\Collection'

    $collection->all();

    // [1, 2, 3]

> **技巧：**當你有一個 `Enumerable` 的實例並且需要一個非惰性集合實例時，`collect` 方法特別有用。由於 `collect()` 是 `Enumerable` 合約的一部分，你可以安全地使用它來獲取 `Collection` 實例。

<a name="method-combine"></a>
#### `combine()` {.collection-method}

`combine` 方法將集合的值作為鍵與另一個數組或集合的值組合：

    $collection = collect(['name', 'age']);

    $combined = $collection->combine(['George', 29]);

    $combined->all();

    // ['name' => 'George', 'age' => 29]

<a name="method-concat"></a>
#### `concat()` {.collection-method}

`concat` 方法將給定的 `array` 或集合的值附加到另一個集合的末尾：

    $collection = collect(['John Doe']);

    $concatenated = $collection->concat(['Jane Doe'])->concat(['name' => 'Johnny Doe']);

    $concatenated->all();

    // ['John Doe', 'Jane Doe', 'Johnny Doe']

`concat` 方法在數字上重新索引連接到原始集合上的項目的鍵。要維護關聯集合中的鍵，請參閱 [merge](#method-merge) 方法。

<a name="method-contains"></a>
#### `contains()` {.collection-method}

`contains` 方法確定集合是否包含給定項目。你可以將閉包傳遞給 `contains` 方法，以確定集合中是否存在與給定真值測試匹配的元素：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->contains(function (int $value, int $key) {
        return $value > 5;
    });

    // false



或者，你可以將字符串傳遞給 `contains` 方法，以確定集合是否包含給定的項目值：

    $collection = collect(['name' => 'Desk', 'price' => 100]);

    $collection->contains('Desk');

    // true

    $collection->contains('New York');

    // false

你還可以將鍵/值對傳遞給 `contains` 方法，該方法將確定給定對是否存在於集合中：

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
    ]);

    $collection->contains('product', 'Bookcase');

    // false

`contains` 方法在檢查項目值時使用“松散”比較，這意味著具有整數值的字符串將被視為等於具有相同值的整數。使用 [`containsStrict`](#method-containsstrict) 方法使用“嚴格”比較進行過濾。

對於 `contains` 的逆操作，請參見 [doesntContain](#method-doesntcontain) 方法。

<a name="method-containsoneitem"></a>
#### `containsOneItem()` {.collection-method}

`containsOneItem` 方法決定了集合是否包含一個項目。

    collect([])->containsOneItem();

    // false

    collect(['1'])->containsOneItem();

    // true

    collect(['1', '2'])->containsOneItem();

    // false

<a name="method-containsstrict"></a>
#### `containsStrict()` {.collection-method}

此方法與 [`contains`](#method-contains) 方法具有相同的簽名；但是，所有值都使用「嚴格」比較進行比較。

> **技巧：**使用 [Eloquent Collections](/docs/laravel/10.x/eloquent-collections#method-contains) 時會修改此方法的行為。

<a name="method-count"></a>
#### `count()` {.collection-method}

`count` 方法返回集合中的項目總數：

    $collection = collect([1, 2, 3, 4]);

    $collection->count();

    // 4

<a name="method-countBy"></a>
#### `countBy()` {.collection-method}

`countBy` 方法計算集合中值的出現次數。默認情況下，該方法計算每個元素的出現次數，允許你計算集合中元素的某些“類型”：

    $collection = collect([1, 2, 2, 2, 3]);

    $counted = $collection->countBy();

    $counted->all();

    // [1 => 1, 2 => 3, 3 => 1]



你將閉包傳遞給 `countBy` 方法以按自定義值計算所有項目：

    $collection = collect(['alice@gmail.com', 'bob@yahoo.com', 'carlos@gmail.com']);

    $counted = $collection->countBy(function (string $email) {
        return substr(strrchr($email, "@"), 1);
    });

    $counted->all();

    // ['gmail.com' => 2, 'yahoo.com' => 1]

<a name="method-crossjoin"></a>
#### `crossJoin()` {.collection-method}

`crossJoin` 方法在給定的數組或集合中交叉連接集合的值，返回具有所有可能排列的笛卡爾積：

    $collection = collect([1, 2]);

    $matrix = $collection->crossJoin(['a', 'b']);

    $matrix->all();

    /*
        [
            [1, 'a'],
            [1, 'b'],
            [2, 'a'],
            [2, 'b'],
        ]
    */

    $collection = collect([1, 2]);

    $matrix = $collection->crossJoin(['a', 'b'], ['I', 'II']);

    $matrix->all();

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

<a name="method-dd"></a>
#### `dd()` {.collection-method}

`dd` 方法轉儲集合的項目並結束腳本的執行：

    $collection = collect(['John Doe', 'Jane Doe']);

    $collection->dd();

    /*
        Collection {
            #items: array:2 [
                0 => "John Doe"
                1 => "Jane Doe"
            ]
        }
    */

如果你不想停止執行腳本，請改用 [`dump`](#method-dump) 方法。

<a name="method-diff"></a>
#### `diff()` {.collection-method}

`diff` 方法根據集合的值將集合與另一個集合或普通 PHP `array` 進行比較。此方法將返回給定集合中不存在的原始集合中的值：

    $collection = collect([1, 2, 3, 4, 5]);

    $diff = $collection->diff([2, 4, 6, 8]);

    $diff->all();

    // [1, 3, 5]

> **技巧：**此方法的行為在使用 [Eloquent Collections](/docs/laravel/10.x/eloquent-collections#method-diff) 時被修改。

<a name="method-diffassoc"></a>
#### `diffAssoc()` {.collection-method}

`diffAssoc` 方法根據其鍵和值將集合與另一個集合或普通 PHP `array` 進行比較。此方法將返回給定集合中不存在的原始集合中的鍵/值對：

    $collection = collect([
        'color' => 'orange',
        'type' => 'fruit',
        'remain' => 6,
    ]);

    $diff = $collection->diffAssoc([
        'color' => 'yellow',
        'type' => 'fruit',
        'remain' => 3,
        'used' => 6,
    ]);

    $diff->all();

    // ['color' => 'orange', 'remain' => 6]



<a name="method-diffkeys"></a>
#### `diffKeys()` {.collection-method}

`diffKeys` 方法將集合與另一個集合或基於其鍵的普通 PHP `array` 進行比較。此方法將返回給定集合中不存在的原始集合中的鍵/值對：

    $collection = collect([
        'one' => 10,
        'two' => 20,
        'three' => 30,
        'four' => 40,
        'five' => 50,
    ]);

    $diff = $collection->diffKeys([
        'two' => 2,
        'four' => 4,
        'six' => 6,
        'eight' => 8,
    ]);

    $diff->all();

    // ['one' => 10, 'three' => 30, 'five' => 50]

<a name="method-doesntcontain"></a>
#### `doesntContain()` {.collection-method}

`doesntContain` 方法確定集合是否不包含給定項目。你可以將閉包傳遞給 `doesntContain` 方法，以確定集合中是否不存在與給定真值測試匹配的元素：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->doesntContain(function (int $value, int $key) {
        return $value < 5;
    });

    // false

或者，你可以將字符串傳遞給 `doesntContain` 方法，以確定集合是否不包含給定的項目值：

    $collection = collect(['name' => 'Desk', 'price' => 100]);

    $collection->doesntContain('Table');

    // true

    $collection->doesntContain('Desk');

    // false

你還可以將鍵/值對傳遞給 `doesntContain` 方法，該方法將確定給定對是否不存在於集合中：

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
    ]);

    $collection->doesntContain('product', 'Bookcase');

    // true

`doesntContain` 方法在檢查項目值時使用「松散」比較，這意味著具有整數值的字符串將被視為等於具有相同值的整數。

<a name="method-dump"></a>
#### `dump()` {.collection-method}

`dump` 方法轉儲集合的項目：

    $collection = collect(['John Doe', 'Jane Doe']);

    $collection->dump();

    /*
        Collection {
            #items: array:2 [
                0 => "John Doe"
                1 => "Jane Doe"
            ]
        }
    */

如果要在轉儲集合後停止執行腳本，請改用 [`dd`](#method-dd) 方法。



<a name="method-duplicates"></a>
#### `duplicates()` {.collection-method}

`duplicates` 方法從集合中檢索並返回重覆值：

    $collection = collect(['a', 'b', 'a', 'c', 'b']);

    $collection->duplicates();

    // [2 => 'a', 4 => 'b']

如果集合包含數組或對象，你可以傳遞要檢查重覆值的屬性的鍵：

    $employees = collect([
        ['email' => 'abigail@example.com', 'position' => 'Developer'],
        ['email' => 'james@example.com', 'position' => 'Designer'],
        ['email' => 'victoria@example.com', 'position' => 'Developer'],
    ]);

    $employees->duplicates('position');

    // [2 => 'Developer']

<a name="method-duplicatesstrict"></a>
#### `duplicatesStrict()` {.collection-method}

此方法與 [`duplicates`](#method-duplicates) 方法具有相同的簽名；但是，所有值都使用「嚴格」比較進行比較。

<a name="method-each"></a>
#### `each()` {.collection-method}

`each` 方法遍歷集合中的項目並將每個項目傳遞給閉包：

    $collection = collect([1, 2, 3, 4]);

    $collection->each(function (int $item, int $key) {
        // ...
    });

如果你想停止遍歷這些項目，你可以從你的閉包中返回 `false`：

    $collection->each(function (int $item, int $key) {
        if (/* condition */) {
            return false;
        }
    });

<a name="method-eachspread"></a>
#### `eachSpread()` {.collection-method}

`eachSpread` 方法叠代集合的項目，將每個嵌套項目值傳遞給給定的回調：

    $collection = collect([['John Doe', 35], ['Jane Doe', 33]]);

    $collection->eachSpread(function (string $name, int $age) {
        // ...
    });

你可以通過從回調中返回 `false` 來停止遍歷項目：

    $collection->eachSpread(function (string $name, int $age) {
        return false;
    });

<a name="method-every"></a>
#### `every()` {.collection-method}

`every` 方法可用於驗證集合的所有元素是否通過給定的真值測試：

    collect([1, 2, 3, 4])->every(function (int $value, int $key) {
        return $value > 2;
    });

    // false



如果集合為空，`every` 方法將返回 true：

    $collection = collect([]);

    $collection->every(function (int $value, int $key) {
        return $value > 2;
    });

    // true

<a name="method-except"></a>
#### `except()` {.collection-method}

`except` 方法返回集合中的所有項目，除了具有指定鍵的項目：

    $collection = collect(['product_id' => 1, 'price' => 100, 'discount' => false]);

    $filtered = $collection->except(['price', 'discount']);

    $filtered->all();

    // ['product_id' => 1]

對於 `except` 的反義詞，請參見 [only](#method-only) 方法。

> 技巧：此方法的行為在使用 [Eloquent Collections](/docs/laravel/10.x/eloquent-collections#method-except) 時被修改。

<a name="method-filter"></a>
#### `filter()` {.collection-method}

`filter` 方法使用給定的回調過濾集合，只保留那些通過給定真值測試的項目：

    $collection = collect([1, 2, 3, 4]);

    $filtered = $collection->filter(function (int $value, int $key) {
        return $value > 2;
    });

    $filtered->all();

    // [3, 4]

如果沒有提供回調，則集合中所有相當於 `false` 的條目都將被刪除：

    $collection = collect([1, 2, 3, null, false, '', 0, []]);

    $collection->filter()->all();

    // [1, 2, 3]

對於 `filter` 的逆操作，請參見 [reject](#method-reject) 方法。

<a name="method-first"></a>
#### `first()` {.collection-method}

`first` 方法返回集合中通過給定真值測試的第一個元素：

    collect([1, 2, 3, 4])->first(function (int $value, int $key) {
        return $value > 2;
    });

    // 3

你也可以調用不帶參數的 `first` 方法來獲取集合中的第一個元素。如果集合為空，則返回 `null`：

    collect([1, 2, 3, 4])->first();

    // 1

<a name="method-first-or-fail"></a>
#### `firstOrFail()` {.collection-method}

`firstOrFail` 方法與 `first` 方法相同；但是，如果沒有找到結果，將拋出 `Illuminate/Support/ItemNotFoundException` 異常。

    collect([1, 2, 3, 4])->firstOrFail(function (int $value, int $key) {
        return $value > 5;
    });

    // Throws ItemNotFoundException...



你也可以調用 `firstOrFail` 方法，沒有參數，以獲得集合中的第一個元素。如果集合是空的，將拋出一個 `Illuminate\Support\ItemNotFoundException` 異常。

    collect([])->firstOrFail();

    // Throws ItemNotFoundException...

<a name="method-first-where"></a>
#### `firstWhere()` {.collection-method}

`firstWhere` 方法返回集合中具有給定鍵/值對的第一個元素：

    $collection = collect([
        ['name' => 'Regena', 'age' => null],
        ['name' => 'Linda', 'age' => 14],
        ['name' => 'Diego', 'age' => 23],
        ['name' => 'Linda', 'age' => 84],
    ]);

    $collection->firstWhere('name', 'Linda');

    // ['name' => 'Linda', 'age' => 14]

你還可以使用比較運算符調用 `firstWhere` 方法：

    $collection->firstWhere('age', '>=', 18);

    // ['name' => 'Diego', 'age' => 23]

與 [where](#method-where) 方法一樣，你可以將一個參數傳遞給 `firstWhere` 方法。在這種情況下，`firstWhere` 方法將返回給定項目鍵值為「真」的第一個項目：

    $collection->firstWhere('age');

    // ['name' => 'Linda', 'age' => 14]

<a name="method-flatmap"></a>
#### `flatMap()` {.collection-method}

`flatMap` 方法遍歷集合並將每個值傳遞給給定的閉包。閉包可以自由修改項目並將其返回，從而形成一個新的修改項目集合。然後，數組被展平一層：

    $collection = collect([
        ['name' => 'Sally'],
        ['school' => 'Arkansas'],
        ['age' => 28]
    ]);

    $flattened = $collection->flatMap(function (array $values) {
        return array_map('strtoupper', $values);
    });

    $flattened->all();

    // ['name' => 'SALLY', 'school' => 'ARKANSAS', 'age' => '28'];

<a name="method-flatten"></a>
#### `flatten()` {.collection-method}

`flatten` 方法將多維集合展平為一維：

    $collection = collect([
        'name' => 'taylor',
        'languages' => [
            'php', 'javascript'
        ]
    ]);

    $flattened = $collection->flatten();

    $flattened->all();

    // ['taylor', 'php', 'javascript'];

如有必要，你可以向 `flatten` 方法傳遞一個「深度」參數：

    $collection = collect([
        'Apple' => [
            [
                'name' => 'iPhone 6S',
                'brand' => 'Apple'
            ],
        ],
        'Samsung' => [
            [
                'name' => 'Galaxy S7',
                'brand' => 'Samsung'
            ],
        ],
    ]);

    $products = $collection->flatten(1);

    $products->values()->all();

    /*
        [
            ['name' => 'iPhone 6S', 'brand' => 'Apple'],
            ['name' => 'Galaxy S7', 'brand' => 'Samsung'],
        ]
    */



在此示例中，調用 `flatten` 而不提供深度也會使嵌套數組變平，從而導致 `['iPhone 6S', 'Apple', 'Galaxy S7', 'Samsung']`。提供深度允許你指定嵌套數組將被展平的級別數。

<a name="method-flip"></a>
#### `flip()` {.collection-method}

`flip` 方法將集合的鍵與其對應的值交換：

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $flipped = $collection->flip();

    $flipped->all();

    // ['taylor' => 'name', 'laravel' => 'framework']

<a name="method-forget"></a>
#### `forget()` {.collection-method}

該 `forget` 方法將通過指定的鍵來移除集合中對應的元素：

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $collection->forget('name');

    $collection->all();

    // ['framework' => 'laravel']

> **注意：**與大多數集合的方法不同的是， `forget` 不會返回修改後的新集合；它會直接修改原集合。

<a name="method-forpage"></a>
#### `forPage()` {.collection-method}

該 `forPage` 方法返回一個含有指定頁碼數集合項的新集合。這個方法接受頁碼數作為其第一個參數，每頁顯示的項數作為其第二個參數：

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9]);

    $chunk = $collection->forPage(2, 3);

    $chunk->all();

    // [4, 5, 6]

<a name="method-get"></a>
#### `get()` {.collection-method}

該 `get` 方法返回指定鍵的集合項，如果該鍵在集合中不存在，則返回 null：

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $value = $collection->get('name');

    // taylor

你可以任選一個默認值作為第二個參數傳遞：

    $collection = collect(['name' => 'taylor', 'framework' => 'laravel']);

    $value = $collection->get('age', 34);

    // 34

你甚至可以將一個回調函數作為默認值傳遞。如果指定的鍵不存在，就會返回回調函數的結果：

    $collection->get('email', function () {
        return 'taylor@example.com';
    });

    // taylor@example.com



<a name="method-groupby"></a>
#### `groupBy()` {.collection-method}

該 `groupBy` 方法根據指定鍵對集合項進行分組：

    $collection = collect([
        ['account_id' => 'account-x10', 'product' => 'Chair'],
        ['account_id' => 'account-x10', 'product' => 'Bookcase'],
        ['account_id' => 'account-x11', 'product' => 'Desk'],
    ]);

    $grouped = $collection->groupBy('account_id');

    $grouped->all();

    /*
        [
            'account-x10' => [
                ['account_id' => 'account-x10', 'product' => 'Chair'],
                ['account_id' => 'account-x10', 'product' => 'Bookcase'],
            ],
            'account-x11' => [
                ['account_id' => 'account-x11', 'product' => 'Desk'],
            ],
        ]
    */

你可以傳遞回調，而不是傳遞字符串 `key`。回調應返回你希望通過以下方式鍵入組的值：

    $grouped = $collection->groupBy(function (array $item, int $key) {
        return substr($item['account_id'], -3);
    });

    $grouped->all();

    /*
        [
            'x10' => [
                ['account_id' => 'account-x10', 'product' => 'Chair'],
                ['account_id' => 'account-x10', 'product' => 'Bookcase'],
            ],
            'x11' => [
                ['account_id' => 'account-x11', 'product' => 'Desk'],
            ],
        ]
    */

多個分組標準可以作為數組傳遞。每個數組元素將應用於多維數組中的相應級別：

    $data = new Collection([
        10 => ['user' => 1, 'skill' => 1, 'roles' => ['Role_1', 'Role_3']],
        20 => ['user' => 2, 'skill' => 1, 'roles' => ['Role_1', 'Role_2']],
        30 => ['user' => 3, 'skill' => 2, 'roles' => ['Role_1']],
        40 => ['user' => 4, 'skill' => 2, 'roles' => ['Role_2']],
    ]);

    $result = $data->groupBy(['skill', function (array $item) {
        return $item['roles'];
    }], preserveKeys: true);

    /*
    [
        1 => [
            'Role_1' => [
                10 => ['user' => 1, 'skill' => 1, 'roles' => ['Role_1', 'Role_3']],
                20 => ['user' => 2, 'skill' => 1, 'roles' => ['Role_1', 'Role_2']],
            ],
            'Role_2' => [
                20 => ['user' => 2, 'skill' => 1, 'roles' => ['Role_1', 'Role_2']],
            ],
            'Role_3' => [
                10 => ['user' => 1, 'skill' => 1, 'roles' => ['Role_1', 'Role_3']],
            ],
        ],
        2 => [
            'Role_1' => [
                30 => ['user' => 3, 'skill' => 2, 'roles' => ['Role_1']],
            ],
            'Role_2' => [
                40 => ['user' => 4, 'skill' => 2, 'roles' => ['Role_2']],
            ],
        ],
    ];
    */

<a name="method-has"></a>
#### `has()` {.collection-method}

`has` 方法確定集合中是否存在給定鍵：

    $collection = collect(['account_id' => 1, 'product' => 'Desk', 'amount' => 5]);

    $collection->has('product');

    // true

    $collection->has(['product', 'amount']);

    // true

    $collection->has(['amount', 'price']);

    // false



<a name="method-hasany"></a>
#### `hasAny()` {.collection-method}

`hasAny` 方法確定在集合中是否存在任何給定的鍵。

    $collection = collect(['account_id' => 1, 'product' => 'Desk', 'amount' => 5]);

    $collection->hasAny(['product', 'price']);

    // true

    $collection->hasAny(['name', 'price']);

    // false

<a name="method-implode"></a>
#### `implode()` {.collection-method}

`implode` 方法連接集合中的項目。它的參數取決於集合中項目的類型。如果集合包含數組或對象，你應該傳遞你希望加入的屬性的鍵，以及你希望放置在值之間的「膠水」字符串：

    $collection = collect([
        ['account_id' => 1, 'product' => 'Desk'],
        ['account_id' => 2, 'product' => 'Chair'],
    ]);

    $collection->implode('product', ', ');

    // Desk, Chair

如果集合包含簡單的字符串或數值，則應將「膠水」作為唯一參數傳遞給該方法：

    collect([1, 2, 3, 4, 5])->implode('-');

    // '1-2-3-4-5'

如果你想對被內部處理的值進行格式化，你可以給 `implode` 方法傳遞一個閉包。

    $collection->implode(function (array $item, int $key) {
        return strtoupper($item['product']);
    }, ', ');

    // DESK, CHAIR

<a name="method-intersect"></a>
#### `intersect()` {.collection-method}

`intersect` 方法從原始集合中刪除任何不存在於給定 `array` 或集合中的值。生成的集合將保留原始集合的鍵：

    $collection = collect(['Desk', 'Sofa', 'Chair']);

    $intersect = $collection->intersect(['Desk', 'Chair', 'Bookcase']);

    $intersect->all();

    // [0 => 'Desk', 2 => 'Chair']

> 技巧：使用 [Eloquent Collections](/docs/laravel/10.x/eloquent-collections#method-intersect) 時會修改此方法的行為。

<a name="method-intersectAssoc"></a>
#### `intersectAssoc()` {.collection-method}

`intersectAssoc` 方法將原始集合與另一個集合或`array`進行比較，返回所有給定集合中存在的鍵/值對:

    $collection = collect([
        'color' => 'red',
        'size' => 'M',
        'material' => 'cotton'
    ]);

    $intersect = $collection->intersectAssoc([
        'color' => 'blue',
        'size' => 'M',
        'material' => 'polyester'
    ]);

    $intersect->all();

    // ['size' => 'M']



<a name="method-intersectbykeys"></a>
#### `intersectByKeys()` {.collection-method}

`intersectByKeys` 方法刪除了原始集合中不存在於給定的 `array` 或集合中的任何鍵和其相應的值。

    $collection = collect([
        'serial' => 'UX301', 'type' => 'screen', 'year' => 2009,
    ]);

    $intersect = $collection->intersectByKeys([
        'reference' => 'UX404', 'type' => 'tab', 'year' => 2011,
    ]);

    $intersect->all();

    // ['type' => 'screen', 'year' => 2009]

<a name="method-isempty"></a>
#### `isEmpty()` {.collection-method}

如果集合為空，`isEmpty` 方法返回 `true`；否則，返回 `false`：

    collect([])->isEmpty();

    // true

<a name="method-isnotempty"></a>
#### `isNotEmpty()` {.collection-method}

如果集合不為空，`isNotEmpty` 方法返回 `true`；否則，返回 `false`：

    collect([])->isNotEmpty();

    // false

<a name="method-join"></a>
#### `join()` {.collection-method}

`join` 方法將集合的值與字符串連接起來。使用此方法的第二個參數，你還可以指定最終元素應如何附加到字符串：

    collect(['a', 'b', 'c'])->join(', '); // 'a, b, c'
    collect(['a', 'b', 'c'])->join(', ', ', and '); // 'a, b, and c'
    collect(['a', 'b'])->join(', ', ' and '); // 'a and b'
    collect(['a'])->join(', ', ' and '); // 'a'
    collect([])->join(', ', ' and '); // ''

<a name="method-keyby"></a>
#### `keyBy()` {.collection-method}

`keyBy` 方法通過給定鍵對集合進行鍵控。如果多個項目具有相同的鍵，則只有最後一個會出現在新集合中：

    $collection = collect([
        ['product_id' => 'prod-100', 'name' => 'Desk'],
        ['product_id' => 'prod-200', 'name' => 'Chair'],
    ]);

    $keyed = $collection->keyBy('product_id');

    $keyed->all();

    /*
        [
            'prod-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
            'prod-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
        ]
    */



你也可以將回調傳遞給該方法。回調應通過以下方式返回值以作為集合的鍵：

    $keyed = $collection->keyBy(function (array $item, int $key) {
        return strtoupper($item['product_id']);
    });

    $keyed->all();

    /*
        [
            'PROD-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
            'PROD-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
        ]
    */

<a name="method-keys"></a>
#### `keys()` {.collection-method}

`keys` 方法返回集合的所有鍵：

    $collection = collect([
        'prod-100' => ['product_id' => 'prod-100', 'name' => 'Desk'],
        'prod-200' => ['product_id' => 'prod-200', 'name' => 'Chair'],
    ]);

    $keys = $collection->keys();

    $keys->all();

    // ['prod-100', 'prod-200']

<a name="method-last"></a>
#### `last()` {.collection-method}

`last` 方法返回集合中通過給定真值測試的最後一個元素：

    collect([1, 2, 3, 4])->last(function (int $value, int $key) {
        return $value < 3;
    });

    // 2

你也可以調用不帶參數的`last`方法來獲取集合中的最後一個元素。如果集合為空，則返回 `null`：

    collect([1, 2, 3, 4])->last();

    // 4

<a name="method-lazy"></a>
#### `lazy()` {.collection-method}


`lazy` 方法從底層的項目數組中返回一個新的 [`LazyCollection`](#lazy-collections) 實例。

    $lazyCollection = collect([1, 2, 3, 4])->lazy();

    get_class($lazyCollection);

    // Illuminate\Support\LazyCollection

    $lazyCollection->all();

    // [1, 2, 3, 4]

當你需要對一個包含許多項目的巨大 `Collection` 進行轉換時，這一點特別有用。

    $count = $hugeCollection
        ->lazy()
        ->where('country', 'FR')
        ->where('balance', '>', '100')
        ->count();

通過將集合轉換為 `LazyCollection`，我們避免了分配大量的額外內存。雖然原始集合仍然在內存中保留 _它的_ 值，但後續的過濾器不會。因此，在過濾集合的結果時，幾乎沒有額外的內存被分配。



<a name="method-macro"></a>
#### `macro()` {.collection-method}

靜態`macro()`方法允許你在運行時向「集合」類添加方法。有關詳細信息，請參閱有關 [擴展集合](#extending-collections) 的文檔。

<a name="method-make"></a>
#### `make()` {.collection-method}

靜態 `make` 方法可以創建一個新的集合實例。請參照 [創建集合](#creating-collections) 部分。

<a name="method-map"></a>
#### `map()` {.collection-method}

`map` 方法叠代集合並將每個值傳遞給給定的回調。回調可以自由地修改項目並返回它，從而形成修改項目的新集合：

    $collection = collect([1, 2, 3, 4, 5]);

    $multiplied = $collection->map(function (int $item, int $key) {
        return $item * 2;
    });

    $multiplied->all();

    // [2, 4, 6, 8, 10]

> **注意：**與其他大多數集合方法一樣， `map` 會返回一個新的集合實例；它不會修改原集合。如果你想修改原集合，請使用 [`transform`](#method-transform) 方法。

<a name="method-mapinto"></a>
#### `mapInto()` {.collection-method}

該 `mapInto()` 方法可以叠代集合，通過將值傳遞給構造函數來創建給定類的新實例：

    class Currency
    {
        /**
         * Create a new currency instance.
         */
        function __construct(
            public string $code
        ) {}
    }

    $collection = collect(['USD', 'EUR', 'GBP']);

    $currencies = $collection->mapInto(Currency::class);

    $currencies->all();

    // [Currency('USD'), Currency('EUR'), Currency('GBP')]

<a name="method-mapspread"></a>
#### `mapSpread()` {.collection-method}

該 `mapSpread` 方法可以叠代集合，將每個嵌套項值給指定的回調函數。該回調函數可以自由修改該集合項並返回，從而生成被修改過集合項的新集合：

    $collection = collect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

    $chunks = $collection->chunk(2);

    $sequence = $chunks->mapSpread(function (int $even, int $odd) {
        return $even + $odd;
    });

    $sequence->all();

    // [1, 5, 9, 13, 17]



<a name="method-maptogroups"></a>
#### `mapToGroups()` {.collection-method}

該 `mapToGroups` 方法通過給定的回調函數對集合項進行分組。該回調函數應該返回一個包含單個鍵 / 值對的關聯數組，從而生成一個分組值的新集合：

    $collection = collect([
        [
            'name' => 'John Doe',
            'department' => 'Sales',
        ],
        [
            'name' => 'Jane Doe',
            'department' => 'Sales',
        ],
        [
            'name' => 'Johnny Doe',
            'department' => 'Marketing',
        ]
    ]);

    $grouped = $collection->mapToGroups(function (array $item, int $key) {
        return [$item['department'] => $item['name']];
    });

    $grouped->all();

    /*
        [
            'Sales' => ['John Doe', 'Jane Doe'],
            'Marketing' => ['Johnny Doe'],
        ]
    */

    $grouped->get('Sales')->all();

    // ['John Doe', 'Jane Doe']

<a name="method-mapwithkeys"></a>
#### `mapWithKeys()` {.collection-method}

`mapWithKeys` 方法遍歷集合並將每個值傳遞給給定的回調。回調應返回包含單個鍵/值對的關聯數組：

    $collection = collect([
        [
            'name' => 'John',
            'department' => 'Sales',
            'email' => 'john@example.com',
        ],
        [
            'name' => 'Jane',
            'department' => 'Marketing',
            'email' => 'jane@example.com',
        ]
    ]);

    $keyed = $collection->mapWithKeys(function (array $item, int $key) {
        return [$item['email'] => $item['name']];
    });

    $keyed->all();

    /*
        [
            'john@example.com' => 'John',
            'jane@example.com' => 'Jane',
        ]
    */

<a name="method-max"></a>
#### `max()` {.collection-method}

`max` 方法返回給定鍵的最大值：

    $max = collect([
        ['foo' => 10],
        ['foo' => 20]
    ])->max('foo');

    // 20

    $max = collect([1, 2, 3, 4, 5])->max();

    // 5

<a name="method-median"></a>
#### `median()` {.collection-method}

`median` 方法返回給定鍵的 [中值](https://en.wikipedia.org/wiki/Median)：

    $median = collect([
        ['foo' => 10],
        ['foo' => 10],
        ['foo' => 20],
        ['foo' => 40]
    ])->median('foo');

    // 15

    $median = collect([1, 1, 2, 4])->median();

    // 1.5

<a name="method-merge"></a>
#### `merge()` {.collection-method}

`merge` 方法將給定的數組或集合與原始集合合並。如果給定項目中的字符串鍵與原始集合中的字符串鍵匹配，則給定項目的值將覆蓋原始集合中的值：

    $collection = collect(['product_id' => 1, 'price' => 100]);

    $merged = $collection->merge(['price' => 200, 'discount' => false]);

    $merged->all();

    // ['product_id' => 1, 'price' => 200, 'discount' => false]



如果給定項目的鍵是數字，則值將附加到集合的末尾：

    $collection = collect(['Desk', 'Chair']);

    $merged = $collection->merge(['Bookcase', 'Door']);

    $merged->all();

    // ['Desk', 'Chair', 'Bookcase', 'Door']

<a name="method-mergerecursive"></a>
#### `mergeRecursive()` {.collection-method}

`mergeRecursive` 方法將給定的數組或集合遞歸地與原始集合合並。如果給定項目中的字符串鍵與原始集合中的字符串鍵匹配，則這些鍵的值將合並到一個數組中，這是遞歸完成的：

    $collection = collect(['product_id' => 1, 'price' => 100]);

    $merged = $collection->mergeRecursive([
        'product_id' => 2,
        'price' => 200,
        'discount' => false
    ]);

    $merged->all();

    // ['product_id' => [1, 2], 'price' => [100, 200], 'discount' => false]

<a name="method-min"></a>
#### `min()` {.collection-method}

`min` 方法返回給定鍵的最小值：

    $min = collect([['foo' => 10], ['foo' => 20]])->min('foo');

    // 10

    $min = collect([1, 2, 3, 4, 5])->min();

    // 1

<a name="method-mode"></a>
#### `mode()` {.collection-method}

`mode` 方法返回給定鍵的 [mode 值](https://en.wikipedia.org/wiki/Mode_(statistics))：

    $mode = collect([
        ['foo' => 10],
        ['foo' => 10],
        ['foo' => 20],
        ['foo' => 40]
    ])->mode('foo');

    // [10]

    $mode = collect([1, 1, 2, 4])->mode();

    // [1]

    $mode = collect([1, 1, 2, 2])->mode();

    // [1, 2]

<a name="method-nth"></a>
#### `nth()` {.collection-method}

`nth` 方法創建一個由每個第 n 個元素組成的新集合：

    $collection = collect(['a', 'b', 'c', 'd', 'e', 'f']);

    $collection->nth(4);

    // ['a', 'e']

你可以選擇將起始偏移量作為第二個參數傳遞：

    $collection->nth(4, 1);

    // ['b', 'f']

<a name="method-only"></a>
#### `only()` {.collection-method}

`only` 方法返回集合中具有指定鍵的項目：

    $collection = collect([
        'product_id' => 1,
        'name' => 'Desk',
        'price' => 100,
        'discount' => false
    ]);

    $filtered = $collection->only(['product_id', 'name']);

    $filtered->all();

    // ['product_id' => 1, 'name' => 'Desk']



關於 `only` 的反義詞，見[except](#method-except) 方法。

> **技巧：**使用 [Eloquent Collections](/docs/laravel/9.x/eloquent-collections#method-only) 時會修改此方法的行為。

<a name="method-pad"></a>
#### `pad()` {.collection-method}

`pad` 方法將用給定的值填充數組，直到數組達到指定的大小。此方法的行為類似於 [array_pad](https://secure.php.net/manual/en/function.array-pad.php) PHP 函數。

要向左填充，你應該指定一個負尺寸。如果給定大小的絕對值小於或等於數組的長度，則不會發生填充：

    $collection = collect(['A', 'B', 'C']);

    $filtered = $collection->pad(5, 0);

    $filtered->all();

    // ['A', 'B', 'C', 0, 0]

    $filtered = $collection->pad(-5, 0);

    $filtered->all();

    // [0, 0, 'A', 'B', 'C']

<a name="method-partition"></a>
#### `partition()` {.collection-method}

該 `partition` 方法可以與 PHP 數組解構相結合，以將通過給定真值測試的元素與未通過的元素分開：

    $collection = collect([1, 2, 3, 4, 5, 6]);

    [$underThree, $equalOrAboveThree] = $collection->partition(function (int $i) {
        return $i < 3;
    });

    $underThree->all();

    // [1, 2]

    $equalOrAboveThree->all();

    // [3, 4, 5, 6]

<a name="method-pipe"></a>
#### `pipe()` {.collection-method}

該 `pipe` 可以把集合放到回調參數中並返回回調的結果：

    $collection = collect([1, 2, 3]);

    $piped = $collection->pipe(function (Collection $collection) {
        return $collection->sum();
    });

    // 6

<a name="method-pipeinto"></a>
#### `pipeInto()` {.collection-method}

該 `pipeInto` 方法創建一個給定類的新實例，並將集合傳遞給構造函數：

    class ResourceCollection
    {
        /**
         * Create a new ResourceCollection instance.
         */
        public function __construct(
          public Collection $collection,
        ) {}
    }

    $collection = collect([1, 2, 3]);

    $resource = $collection->pipeInto(ResourceCollection::class);

    $resource->collection->all();

    // [1, 2, 3]

<a name="method-pipethrough"></a>


#### `pipeThrough()` {.collection-method}

該 `pipeThrough` 方法將集合傳遞給給定的閉包數組並返回執行的閉包的結果：

    use Illuminate\Support\Collection;

    $collection = collect([1, 2, 3]);

    $result = $collection->pipeThrough([
        function (Collection $collection) {
            return $collection->merge([4, 5]);
        },
        function (Collection $collection) {
            return $collection->sum();
        },
    ]);

    // 15

<a name="method-pluck"></a>
#### `pluck()` {.collection-method}

該 `pluck` 可以獲取集合中指定鍵對應的所有值：

    $collection = collect([
        ['product_id' => 'prod-100', 'name' => 'Desk'],
        ['product_id' => 'prod-200', 'name' => 'Chair'],
    ]);

    $plucked = $collection->pluck('name');

    $plucked->all();

    // ['Desk', 'Chair']

你也可以通過傳入第二個參數來指定生成集合的 key（鍵）：

    $plucked = $collection->pluck('name', 'product_id');

    $plucked->all();

    // ['prod-100' => 'Desk', 'prod-200' => 'Chair']

該 `pluck` 也支持利用「.」標記的方法取出多維數組的鍵值：

    $collection = collect([
        [
            'name' => 'Laracon',
            'speakers' => [
                'first_day' => ['Rosa', 'Judith'],
            ],
        ],
        [
            'name' => 'VueConf',
            'speakers' => [
                'first_day' => ['Abigail', 'Joey'],
            ],
        ],
    ]);

    $plucked = $collection->pluck('speakers.first_day');

    $plucked->all();

    // [['Rosa', 'Judith'], ['Abigail', 'Joey']]

如果存在重覆鍵，則將最後一個匹配元素插入到 plucked 集合中：

    $collection = collect([
        ['brand' => 'Tesla',  'color' => 'red'],
        ['brand' => 'Pagani', 'color' => 'white'],
        ['brand' => 'Tesla',  'color' => 'black'],
        ['brand' => 'Pagani', 'color' => 'orange'],
    ]);

    $plucked = $collection->pluck('color', 'brand');

    $plucked->all();

    // ['Tesla' => 'black', 'Pagani' => 'orange']

<a name="method-pop"></a>
#### `pop()` {.collection-method}

`pop` 方法刪除並返回集合中的最後一項：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->pop();

    // 5

    $collection->all();

    // [1, 2, 3, 4]

你可以將整數傳遞給 `pop` 方法以從集合末尾刪除並返回多個項目：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->pop(3);

    // collect([5, 4, 3])

    $collection->all();

    // [1, 2]

<a name="method-prepend"></a>
#### `prepend()` {.collection-method}



`prepend` 方法將一個項目添加到集合的開頭：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->prepend(0);

    $collection->all();

    // [0, 1, 2, 3, 4, 5]

你還可以傳遞第二個參數來指定前置項的鍵：

    $collection = collect(['one' => 1, 'two' => 2]);

    $collection->prepend(0, 'zero');

    $collection->all();

    // ['zero' => 0, 'one' => 1, 'two' => 2]

<a name="method-pull"></a>
#### `pull()` {.collection-method}

`pull` 方法通過它的鍵從集合中移除並返回一個項目：

    $collection = collect(['product_id' => 'prod-100', 'name' => 'Desk']);

    $collection->pull('name');

    // 'Desk'

    $collection->all();

    // ['product_id' => 'prod-100']

<a name="method-push"></a>
#### `push()` {.collection-method}

`push` 方法將一個項目附加到集合的末尾：

    $collection = collect([1, 2, 3, 4]);

    $collection->push(5);

    $collection->all();

    // [1, 2, 3, 4, 5]

<a name="method-put"></a>
#### `put()` {.collection-method}

`put` 方法在集合中設置給定的鍵和值：

    $collection = collect(['product_id' => 1, 'name' => 'Desk']);

    $collection->put('price', 100);

    $collection->all();

    // ['product_id' => 1, 'name' => 'Desk', 'price' => 100]

<a name="method-random"></a>
#### `random()` {.collection-method}

`random` 方法從集合中返回一個隨機項：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->random();

    // 4 - (retrieved randomly)

你可以將一個整數傳遞給 `random`，以指定要隨機檢索的項目數。當明確傳遞你希望接收的項目數時，始終返回項目集合：

    $random = $collection->random(3);

    $random->all();

    // [2, 4, 5] - (retrieved randomly)

如果集合實例的項目少於請求的項目，則 `random` 方法將拋出 `InvalidArgumentException`。

`random` 方法也接受一個閉包，它將接收當前集合實例。

    use Illuminate\Support\Collection;

    $random = $collection->random(fn (Collection $items) => min(10, count($items)));

    $random->all();

    // [1, 2, 3, 4, 5] - (retrieved randomly)



<a name="method-range"></a>
#### `range()` {.collection-method}

`range` 方法返回一個包含指定範圍之間整數的集合：

    $collection = collect()->range(3, 6);

    $collection->all();

    // [3, 4, 5, 6]

<a name="method-reduce"></a>
#### `reduce()` {.collection-method}

`reduce` 方法將集合減少為單個值，將每次叠代的結果傳遞給後續叠代：

    $collection = collect([1, 2, 3]);

    $total = $collection->reduce(function (int $carry, int $item) {
        return $carry + $item;
    });

    // 6

`$carry` 在第一次叠代時的值為 `null`；但是，你可以通過將第二個參數傳遞給 `reduce` 來指定其初始值：

    $collection->reduce(function (int $carry, int $item) {
        return $carry + $item;
    }, 4);

    // 10

`reduce` 方法還將關聯集合中的數組鍵傳遞給給定的回調：

    $collection = collect([
        'usd' => 1400,
        'gbp' => 1200,
        'eur' => 1000,
    ]);

    $ratio = [
        'usd' => 1,
        'gbp' => 1.37,
        'eur' => 1.22,
    ];

    $collection->reduce(function (int $carry, int $value, int $key) use ($ratio) {
        return $carry + ($value * $ratio[$key]);
    });

    // 4264

<a name="method-reduce-spread"></a>
#### `reduceSpread()` {.collection-method}

`reduceSpread` 方法將集合縮減為一個值數組，將每次叠代的結果傳遞給後續叠代。此方法類似於 `reduce` 方法；但是，它可以接受多個初始值：

    [$creditsRemaining, $batch] = Image::where('status', 'unprocessed')
        ->get()
        ->reduceSpread(function (int $creditsRemaining, Collection $batch, Image $image) {
            if ($creditsRemaining >= $image->creditsRequired()) {
                $batch->push($image);

                $creditsRemaining -= $image->creditsRequired();
            }

            return [$creditsRemaining, $batch];
        }, $creditsAvailable, collect());

<a name="method-reject"></a>
#### `reject()` {.collection-method}

`reject` 方法使用給定的閉包過濾集合。如果應從結果集合中刪除項目，則閉包應返回 `true`：

    $collection = collect([1, 2, 3, 4]);

    $filtered = $collection->reject(function (int $value, int $key) {
        return $value > 2;
    });

    $filtered->all();

    // [1, 2]



對於 `reject` 方法的逆操作，請參見 [`filter`](#method-filter) 方法。

<a name="method-replace"></a>
#### `replace()` {.collection-method}



    $collection = collect(['Taylor', 'Abigail', 'James']);

    $replaced = $collection->replace([1 => 'Victoria', 3 => 'Finn']);

    $replaced->all();

    // ['Taylor', 'Victoria', 'James', 'Finn']

<a name="method-replacerecursive"></a>
#### `replaceRecursive()` {.collection-method}

此方法的工作方式類似於 `replace`，但它會重覆出現在數組中並對內部值應用相同的替換過程：

    $collection = collect([
        'Taylor',
        'Abigail',
        [
            'James',
            'Victoria',
            'Finn'
        ]
    ]);

    $replaced = $collection->replaceRecursive([
        'Charlie',
        2 => [1 => 'King']
    ]);

    $replaced->all();

    // ['Charlie', 'Abigail', ['James', 'King', 'Finn']]

<a name="method-reverse"></a>
#### `reverse()` {.collection-method}

`reverse` 方法反轉集合項的順序，保留原始鍵：

    $collection = collect(['a', 'b', 'c', 'd', 'e']);

    $reversed = $collection->reverse();

    $reversed->all();

    /*
        [
            4 => 'e',
            3 => 'd',
            2 => 'c',
            1 => 'b',
            0 => 'a',
        ]
    */

<a name="method-search"></a>
#### `search()` {.collection-method}

`search` 方法在集合中搜索給定值，如果找到則返回其鍵。如果未找到該項目，則返回 `false`：

    $collection = collect([2, 4, 6, 8]);

    $collection->search(4);

    // 1

搜索是使用「松散」比較完成的，這意味著具有整數值的字符串將被視為等於具有相同值的整數。要使用「嚴格」比較，請將 `true` 作為第二個參數傳遞給方法：

    collect([2, 4, 6, 8])->search('4', $strict = true);

    // false

或者，你可以提供自己的閉包來搜索通過給定真值測試的第一個項目：

    collect([2, 4, 6, 8])->search(function (int $item, int $key) {
        return $item > 5;
    });

    // 2



<a name="method-shift"></a>
#### `shift()` {.collection-method}

`shift` 方法從集合中移除並返回第一項：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->shift();

    // 1

    $collection->all();

    // [2, 3, 4, 5]

你可以將整數傳遞給 `shift` 方法以從集合的開頭刪除並返回多個項目：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->shift(3);

    // collect([1, 2, 3])

    $collection->all();

    // [4, 5]

<a name="method-shuffle"></a>
#### `shuffle()` {.collection-method}

`shuffle` 方法隨機打亂集合中的項目：

    $collection = collect([1, 2, 3, 4, 5]);

    $shuffled = $collection->shuffle();

    $shuffled->all();

    // [3, 2, 5, 1, 4] - (generated randomly)

<a name="method-skip"></a>
#### `skip()` {.collection-method}

`skip` 方法返回一個新的集合，並從集合的開始刪除指定數量的元素。

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    $collection = $collection->skip(4);

    $collection->all();

    // [5, 6, 7, 8, 9, 10]

<a name="method-skipuntil"></a>
#### `skipUntil()` {.collection-method}

`skipUntil` 方法跳過集合中的項目，直到給定的回調返回 `true`，然後將集合中的剩余項目作為新的集合實例返回：

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->skipUntil(function (int $item) {
        return $item >= 3;
    });

    $subset->all();

    // [3, 4]

你還可以將一個簡單的值傳遞給 `skipUntil` 方法以跳過所有項目，直到找到給定值：

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->skipUntil(3);

    $subset->all();

    // [3, 4]

> **注意：**如果沒有找到給定的值或者回調從未返回 `true`，`skipUntil` 方法將返回一個空集合。

<a name="method-skipwhile"></a>
#### `skipWhile()` {.collection-method}

`skipWhile` 方法在給定回調返回 `true` 時跳過集合中的項目，然後將集合中的剩余項目作為新集合返回：

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->skipWhile(function (int $item) {
        return $item <= 3;
    });

    $subset->all();

    // [4]

> **注意：**如果回調從未返回 `false`，`skipWhile` 方法將返回一個空集合。



<a name="method-slice"></a>
#### `slice()` {.collection-method}

`slice` 方法返回從給定索引開始的集合的一個片斷。

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    $slice = $collection->slice(4);

    $slice->all();

    // [5, 6, 7, 8, 9, 10]

如果你想限制返回切片的大小，請將所需的大小作為第二個參數傳給該方法。

    $slice = $collection->slice(4, 2);

    $slice->all();

    // [5, 6]

返回的切片將默認保留鍵值。如果你不希望保留原始鍵，你可以使用 [`values`](#method-values) 方法來重新索引它們。

<a name="method-sliding"></a>
#### `sliding()` {.collection-method}

`sliding` 方法返回一個新的塊集合，表示集合中項目的「滑動窗口」視圖：

    $collection = collect([1, 2, 3, 4, 5]);

    $chunks = $collection->sliding(2);

    $chunks->toArray();

    // [[1, 2], [2, 3], [3, 4], [4, 5]]

這與 [`eachSpread`](#method-eachspread) 方法結合使用特別有用：

    $transactions->sliding(2)->eachSpread(function (Collection $previous, Collection $current) {
        $current->total = $previous->total + $current->amount;
    });

你可以選擇傳遞第二個「步長」值，該值確定每個塊的第一項之間的距離：

    $collection = collect([1, 2, 3, 4, 5]);

    $chunks = $collection->sliding(3, step: 2);

    $chunks->toArray();

    // [[1, 2, 3], [3, 4, 5]]

<a name="method-sole"></a>
#### `sole()` {.collection-method}

`sole` 方法返回集合中第一個通過給定真值測試的元素，但只有在真值測試正好匹配一個元素的情況下。

    collect([1, 2, 3, 4])->sole(function (int $value, int $key) {
        return $value === 2;
    });

    // 2

你也可以向 `sole` 方法傳遞一個鍵/值對，它將返回集合中第一個與給定對相匹配的元素，但只有當它正好有一個元素相匹配時。

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
    ]);

    $collection->sole('product', 'Chair');

    // ['product' => 'Chair', 'price' => 100]



另外，如果只有一個元素，你也可以調用沒有參數的 `sole` 方法來獲得集合中的第一個元素。

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
    ]);

    $collection->sole();

    // ['product' => 'Desk', 'price' => 200]

如果集合中沒有應該由 `sole` 方法返回的元素，則會拋出 `\Illuminate\Collections\ItemNotFoundException` 異常。如果應該返回多個元素，則會拋出 `\Illuminate\Collections\MultipleItemsFoundException`。

<a name="method-some"></a>
#### `some()` {.collection-method}

[`contains`](#method-contains) 方法的別名。

<a name="method-sort"></a>
#### `sort()` {.collection-method}

`sort` 方法對集合進行排序。排序後的集合保留了原始數組鍵，因此在下面的示例中，我們將使用 [`values`](#method-values) 方法將鍵重置為連續編號的索引：

    $collection = collect([5, 3, 1, 2, 4]);

    $sorted = $collection->sort();

    $sorted->values()->all();

    // [1, 2, 3, 4, 5]

如果你的排序需求更高級，你可以使用自己的算法將回調傳遞給「排序」。參考 PHP 文檔[`uasort`](https://secure.php.net/manual/en/function.uasort.php#refsect1-function.uasort-parameters)，就是集合的`sort`方法 調用內部使用。

> **技巧：**如果你需要對嵌套數組或對象的集合進行排序，請參閱 [`sortBy`](#method-sortby) 和 [`sortByDesc`](#method-sortbydesc) 方法。

<a name="method-sortby"></a>
#### `sortBy()` {.collection-method}

`sortBy` 方法按給定鍵對集合進行排序。排序後的集合保留了原始數組鍵，因此在下面的示例中，我們將使用 [`values`](#method-values) 方法將鍵重置為連續編號的索引：

    $collection = collect([
        ['name' => 'Desk', 'price' => 200],
        ['name' => 'Chair', 'price' => 100],
        ['name' => 'Bookcase', 'price' => 150],
    ]);

    $sorted = $collection->sortBy('price');

    $sorted->values()->all();

    /*
        [
            ['name' => 'Chair', 'price' => 100],
            ['name' => 'Bookcase', 'price' => 150],
            ['name' => 'Desk', 'price' => 200],
        ]
    */



`sortBy` 方法接受 [sort flags](https://www.php.net/manual/en/function.sort.php) 作為其第二個參數：

    $collection = collect([
        ['title' => 'Item 1'],
        ['title' => 'Item 12'],
        ['title' => 'Item 3'],
    ]);

    $sorted = $collection->sortBy('title', SORT_NATURAL);

    $sorted->values()->all();

    /*
        [
            ['title' => 'Item 1'],
            ['title' => 'Item 3'],
            ['title' => 'Item 12'],
        ]
    */

或者，你可以傳遞自己的閉包來確定如何對集合的值進行排序：

    $collection = collect([
        ['name' => 'Desk', 'colors' => ['Black', 'Mahogany']],
        ['name' => 'Chair', 'colors' => ['Black']],
        ['name' => 'Bookcase', 'colors' => ['Red', 'Beige', 'Brown']],
    ]);

    $sorted = $collection->sortBy(function (array $product, int $key) {
        return count($product['colors']);
    });

    $sorted->values()->all();

    /*
        [
            ['name' => 'Chair', 'colors' => ['Black']],
            ['name' => 'Desk', 'colors' => ['Black', 'Mahogany']],
            ['name' => 'Bookcase', 'colors' => ['Red', 'Beige', 'Brown']],
        ]
    */

如果你想按多個屬性對集合進行排序，可以將排序操作數組傳遞給 `sortBy` 方法。每個排序操作都應該是一個數組，由你希望排序的屬性和所需排序的方向組成：

    $collection = collect([
        ['name' => 'Taylor Otwell', 'age' => 34],
        ['name' => 'Abigail Otwell', 'age' => 30],
        ['name' => 'Taylor Otwell', 'age' => 36],
        ['name' => 'Abigail Otwell', 'age' => 32],
    ]);

    $sorted = $collection->sortBy([
        ['name', 'asc'],
        ['age', 'desc'],
    ]);

    $sorted->values()->all();

    /*
        [
            ['name' => 'Abigail Otwell', 'age' => 32],
            ['name' => 'Abigail Otwell', 'age' => 30],
            ['name' => 'Taylor Otwell', 'age' => 36],
            ['name' => 'Taylor Otwell', 'age' => 34],
        ]
    */

當按多個屬性對集合進行排序時，你還可以提供定義每個排序操作的閉包：

    $collection = collect([
        ['name' => 'Taylor Otwell', 'age' => 34],
        ['name' => 'Abigail Otwell', 'age' => 30],
        ['name' => 'Taylor Otwell', 'age' => 36],
        ['name' => 'Abigail Otwell', 'age' => 32],
    ]);

    $sorted = $collection->sortBy([
        fn (array $a, array $b) => $a['name'] <=> $b['name'],
        fn (array $a, array $b) => $b['age'] <=> $a['age'],
    ]);

    $sorted->values()->all();

    /*
        [
            ['name' => 'Abigail Otwell', 'age' => 32],
            ['name' => 'Abigail Otwell', 'age' => 30],
            ['name' => 'Taylor Otwell', 'age' => 36],
            ['name' => 'Taylor Otwell', 'age' => 34],
        ]
    */



<a name="method-sortbydesc"></a>
#### `sortByDesc()` {.collection-method}

此方法與 [`sortBy`](#method-sortby) 方法具有相同的簽名，但將以相反的順序對集合進行排序。

<a name="method-sortdesc"></a>
#### `sortDesc()` {.collection-method}

此方法將按照與 [`sort`](#method-sort) 方法相反的順序對集合進行排序：

    $collection = collect([5, 3, 1, 2, 4]);

    $sorted = $collection->sortDesc();

    $sorted->values()->all();

    // [5, 4, 3, 2, 1]

與 `sort` 不同，你不能將閉包傳遞給 `sortDesc`。相反，你應該使用 [`sort`](#method-sort) 方法並反轉比較。

<a name="method-sortkeys"></a>
#### `sortKeys()` {.collection-method}

`sortKeys` 方法通過底層關聯數組的鍵對集合進行排序：

    $collection = collect([
        'id' => 22345,
        'first' => 'John',
        'last' => 'Doe',
    ]);

    $sorted = $collection->sortKeys();

    $sorted->all();

    /*
        [
            'first' => 'John',
            'id' => 22345,
            'last' => 'Doe',
        ]
    */

<a name="method-sortkeysdesc"></a>
#### `sortKeysDesc()` {.collection-method}

此方法與 [`sortKeys`](#method-sortkeys) 方法具有相同的簽名，但將以相反的順序對集合進行排序。

<a name="method-sortkeysusing"></a>
#### `sortKeysUsing()` {.collection-method}

`sortKeysUsing` 方法使用回調通過底層關聯數組的鍵對集合進行排序：

    $collection = collect([
        'ID' => 22345,
        'first' => 'John',
        'last' => 'Doe',
    ]);

    $sorted = $collection->sortKeysUsing('strnatcasecmp');

    $sorted->all();

    /*
        [
            'first' => 'John',
            'ID' => 22345,
            'last' => 'Doe',
        ]
    */

回調必須是返回小於、等於或大於零的整數的比較函數。有關更多信息，請參閱 [`uksort`](https://www.php.net/manual/en/function.uksort.php#refsect1-function.uksort-parameters) 上的 PHP 文檔，這是 PHP 函數 `sortKeysUsing` 方法在內部使用。

<a name="method-splice"></a>
#### `splice()` {.collection-method}

`splice` 方法刪除並返回從指定索引開始的項目切片：

    $collection = collect([1, 2, 3, 4, 5]);

    $chunk = $collection->splice(2);

    $chunk->all();

    // [3, 4, 5]

    $collection->all();

    // [1, 2]



你可以傳遞第二個參數來限制結果集合的大小：

    $collection = collect([1, 2, 3, 4, 5]);

    $chunk = $collection->splice(2, 1);

    $chunk->all();

    // [3]

    $collection->all();

    // [1, 2, 4, 5]

此外，你可以傳遞包含新項目的第三個參數來替換從集合中刪除的項目：

    $collection = collect([1, 2, 3, 4, 5]);

    $chunk = $collection->splice(2, 1, [10, 11]);

    $chunk->all();

    // [3]

    $collection->all();

    // [1, 2, 10, 11, 4, 5]

<a name="method-split"></a>
#### `split()` {.collection-method}

`split` 方法將集合分成給定數量的組：

    $collection = collect([1, 2, 3, 4, 5]);

    $groups = $collection->split(3);

    $groups->all();

    // [[1, 2], [3, 4], [5]]

<a name="method-splitin"></a>
#### `splitIn()` {.collection-method}

`splitIn` 方法將集合分成給定數量的組，在將剩余部分分配給最終組之前完全填充非終端組：

    $collection = collect([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    $groups = $collection->splitIn(3);

    $groups->all();

    // [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10]]

<a name="method-sum"></a>
#### `sum()` {.collection-method}

`sum` 方法返回集合中所有項目的總和：

    collect([1, 2, 3, 4, 5])->sum();

    // 15

如果集合包含嵌套數組或對象，則應傳遞一個鍵，用於確定要對哪些值求和：

    $collection = collect([
        ['name' => 'JavaScript: The Good Parts', 'pages' => 176],
        ['name' => 'JavaScript: The Definitive Guide', 'pages' => 1096],
    ]);

    $collection->sum('pages');

    // 1272

此外，你可以傳遞自己的閉包來確定要對集合的哪些值求和：

    $collection = collect([
        ['name' => 'Chair', 'colors' => ['Black']],
        ['name' => 'Desk', 'colors' => ['Black', 'Mahogany']],
        ['name' => 'Bookcase', 'colors' => ['Red', 'Beige', 'Brown']],
    ]);

    $collection->sum(function (array $product) {
        return count($product['colors']);
    });

    // 6

<a name="method-take"></a>
#### `take()` {.collection-method}

`take` 方法返回一個具有指定數量項目的新集合：

    $collection = collect([0, 1, 2, 3, 4, 5]);

    $chunk = $collection->take(3);

    $chunk->all();

    // [0, 1, 2]

你還可以傳遞一個負整數以從集合末尾獲取指定數量的項目：

    $collection = collect([0, 1, 2, 3, 4, 5]);

    $chunk = $collection->take(-2);

    $chunk->all();

    // [4, 5]



<a name="method-takeuntil"></a>
#### `takeUntil()` {.collection-method}

`takeUntil` 方法返回集合中的項目，直到給定的回調返回 `true`：

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->takeUntil(function (int $item) {
        return $item >= 3;
    });

    $subset->all();

    // [1, 2]

你還可以將一個簡單的值傳遞給 `takeUntil` 方法以獲取項目，直到找到給定值：

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->takeUntil(3);

    $subset->all();

    // [1, 2]

> **注意：**如果未找到給定值或回調從未返回 `true`，則 `takeUntil` 方法將返回集合中的所有項目。

<a name="method-takewhile"></a>
#### `takeWhile()` {.collection-method}

`takeWhile` 方法返回集合中的項目，直到給定的回調返回 `false`：

    $collection = collect([1, 2, 3, 4]);

    $subset = $collection->takeWhile(function (int $item) {
        return $item < 3;
    });

    $subset->all();

    // [1, 2]

> **注意：**如果回調從不返回 `false`，則 `takeWhile` 方法將返回集合中的所有項目。

<a name="method-tap"></a>
#### `tap()` {.collection-method}

`tap` 方法將集合傳遞給給定的回調，允許你在特定點「點擊」到集合中並在不影響集合本身的情況下對項目執行某些操作。然後集合由 `tap` 方法返回：

    collect([2, 4, 3, 1, 5])
        ->sort()
        ->tap(function (Collection $collection) {
            Log::debug('Values after sorting', $collection->values()->all());
        })
        ->shift();

    // 1

<a name="method-times"></a>
#### `times()` {.collection-method}

靜態 `times` 方法通過調用給定次數的回調函數來創建新集合：

    $collection = Collection::times(10, function (int $number) {
        return $number * 9;
    });

    $collection->all();

    // [9, 18, 27, 36, 45, 54, 63, 72, 81, 90]

<a name="method-toarray"></a>
#### `toArray()` {.collection-method}

該 `toArray` 方法將集合轉換成 PHP `array`。如果集合的值是 [Eloquent](/docs/laravel/10.x/eloquent) 模型，那也會被轉換成數組：

    $collection = collect(['name' => 'Desk', 'price' => 200]);

    $collection->toArray();

    /*
        [
            ['name' => 'Desk', 'price' => 200],
        ]
    */

> **注意：**`toArray` 也會將 `Arrayable` 的實例、所有集合的嵌套對象轉換為數組。如果你想獲取原數組，可以使用 [`all`](#method-all) 方法。


<a name="method-tojson"></a>
#### `toJson()` {.collection-method}

該 `toJson` 方法將集合轉換成 JSON 字符串：

    $collection = collect(['name' => 'Desk', 'price' => 200]);

    $collection->toJson();

    // '{"name":"Desk", "price":200}'

<a name="method-transform"></a>
#### `transform()` {.collection-method}

該 `transform` 方法會遍歷整個集合，並對集合中的每個元素都會調用其回調函數。集合中的元素將被替換為回調函數返回的值：

    $collection = collect([1, 2, 3, 4, 5]);

    $collection->transform(function (int $item, int $key) {
        return $item * 2;
    });

    $collection->all();

    // [2, 4, 6, 8, 10]

> **注意：**與大多數集合方法不同，`transform` 會修改集合本身。如果你想創建新集合，可以使用 [`map`](#method-map) 方法。

<a name="method-undot"></a>
#### `undot()` {.collection-method}

`undot()` 方法將使用「點」表示法的一維集合擴展為多維集合：

    $person = collect([
        'name.first_name' => 'Marie',
        'name.last_name' => 'Valentine',
        'address.line_1' => '2992 Eagle Drive',
        'address.line_2' => '',
        'address.suburb' => 'Detroit',
        'address.state' => 'MI',
        'address.postcode' => '48219'
    ]);

    $person = $person->undot();

    $person->toArray();

    /*
        [
            "name" => [
                "first_name" => "Marie",
                "last_name" => "Valentine",
            ],
            "address" => [
                "line_1" => "2992 Eagle Drive",
                "line_2" => "",
                "suburb" => "Detroit",
                "state" => "MI",
                "postcode" => "48219",
            ],
        ]
    */

<a name="method-union"></a>
#### `union()` {.collection-method}

該 `union` 方法將給定數組添加到集合中。如果給定的數組含有與原集合一樣的鍵，則首選原始集合的值：

    $collection = collect([1 => ['a'], 2 => ['b']]);

    $union = $collection->union([3 => ['c'], 1 => ['d']]);

    $union->all();

    // [1 => ['a'], 2 => ['b'], 3 => ['c']]

<a name="method-unique"></a>
#### `unique()` {.collection-method}

該 `unique` 方法返回集合中所有唯一項。返回的集合保留著原數組的鍵，所以在這個例子中，我們使用 [`values`](#method-values) 方法把鍵重置為連續編號的索引：

    $collection = collect([1, 1, 2, 2, 3, 4, 2]);

    $unique = $collection->unique();

    $unique->values()->all();

    // [1, 2, 3, 4]



當處理嵌套數組或對象時，你可以指定用於確定唯一性的鍵：

    $collection = collect([
        ['name' => 'iPhone 6', 'brand' => 'Apple', 'type' => 'phone'],
        ['name' => 'iPhone 5', 'brand' => 'Apple', 'type' => 'phone'],
        ['name' => 'Apple Watch', 'brand' => 'Apple', 'type' => 'watch'],
        ['name' => 'Galaxy S6', 'brand' => 'Samsung', 'type' => 'phone'],
        ['name' => 'Galaxy Gear', 'brand' => 'Samsung', 'type' => 'watch'],
    ]);

    $unique = $collection->unique('brand');

    $unique->values()->all();

    /*
        [
            ['name' => 'iPhone 6', 'brand' => 'Apple', 'type' => 'phone'],
            ['name' => 'Galaxy S6', 'brand' => 'Samsung', 'type' => 'phone'],
        ]
    */

最後，你還可以將自己的閉包傳遞給該 `unique` 方法，以指定哪個值應確定項目的唯一性：

    $unique = $collection->unique(function (array $item) {
        return $item['brand'].$item['type'];
    });

    $unique->values()->all();

    /*
        [
            ['name' => 'iPhone 6', 'brand' => 'Apple', 'type' => 'phone'],
            ['name' => 'Apple Watch', 'brand' => 'Apple', 'type' => 'watch'],
            ['name' => 'Galaxy S6', 'brand' => 'Samsung', 'type' => 'phone'],
            ['name' => 'Galaxy Gear', 'brand' => 'Samsung', 'type' => 'watch'],
        ]
    */

該 `unique` 方法在檢查項目值時使用「寬松」模式比較，意味著具有整數值的字符串將被視為等於相同值的整數。你可以使用  [`uniqueStrict`](#method-uniquestrict)  方法做「嚴格」模式比較。

> **技巧：**這個方法的行為在使用 [Eloquent 集合](/docs/laravel/10.x/eloquent-collections#method-unique) 時被修改。

<a name="method-uniquestrict"></a>
#### `uniqueStrict()` {.collection-method}

這個方法與 [`unique`](#method-unique) 方法一樣，然而，所有的值是用「嚴格」模式來比較的。

<a name="method-unless"></a>
#### `unless()` {.collection-method}

該 `unless` 方法當傳入的第一個參數不為 `true` 的時候，將執行給定的回調函數：

    $collection = collect([1, 2, 3]);

    $collection->unless(true, function (Collection $collection) {
        return $collection->push(4);
    });

    $collection->unless(false, function (Collection $collection) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 5]



可以將第二個回調傳遞給該 `unless` 方法。 `unless` 當給方法的第一個參數計算結果為時，將執行第二個回調 `true`:

    $collection = collect([1, 2, 3]);

    $collection->unless(true, function (Collection $collection) {
        return $collection->push(4);
    }, function (Collection $collection) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 5]

與 `unless` 相反的，請參見 [`when`](#method-when) 方法。

<a name="method-unlessempty"></a>
#### `unlessEmpty()` {.collection-method}

[`whenNotEmpty`](#method-whennotempty) 的別名方法。

<a name="method-unlessnotempty"></a>
#### `unlessNotEmpty()` {.collection-method}

[`whenEmpty`](#method-whenempty) 的別名方法。

<a name="method-unwrap"></a>
#### `unwrap()` {.collection-method}

靜態 `unwrap` 方法返回集合內部的可用元素：

    Collection::unwrap(collect('John Doe'));

    // ['John Doe']

    Collection::unwrap(['John Doe']);

    // ['John Doe']

    Collection::unwrap('John Doe');

    // 'John Doe'

<a name="method-value"></a>
#### `value()` {.collection-method}

`value` 方法從集合的第一個元素中檢索一個給定的值。

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Speaker', 'price' => 400],
    ]);

    $value = $collection->value('price');

    // 200

<a name="method-values"></a>
#### `values()` {.collection-method}

該 `values` 方法返回鍵被重置為連續編號的新集合：

    $collection = collect([
        10 => ['product' => 'Desk', 'price' => 200],
        11 => ['product' => 'Desk', 'price' => 200],
    ]);

    $values = $collection->values();

    $values->all();

    /*
        [
            0 => ['product' => 'Desk', 'price' => 200],
            1 => ['product' => 'Desk', 'price' => 200],
        ]
    */

<a name="method-when"></a>
#### `when()` {.collection-method}

當 `when` 方法的第一個參數傳入為 `true` 時，將執行給定的回調函數。
集合實例和給到 `when` 方法的第一個參數將被提供給閉包。

    $collection = collect([1, 2, 3]);

    $collection->when(true, function (Collection $collection, int $value) {
        return $collection->push(4);
    });

    $collection->when(false, function (Collection $collection, int $value) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 4]



可以將第二個回調傳遞給該 `when` 方法。當給 `when` 方法的第一個參數計算結果為 `false` 時，將執行第二個回調：

    $collection = collect([1, 2, 3]);

    $collection->when(false, function (Collection $collection, int $value) {
        return $collection->push(4);
    }, function (Collection $collection) {
        return $collection->push(5);
    });

    $collection->all();

    // [1, 2, 3, 5]

與 `when` 相反的方法，請查看 [`unless`](#method-unless) 方法。

<a name="method-whenempty"></a>
#### `whenEmpty()` {.collection-method}

該 `whenEmpty` 方法是當集合為空時，將執行給定的回調函數：

    $collection = collect(['Michael', 'Tom']);

    $collection->whenEmpty(function (Collection $collection) {
        return $collection->push('Adam');
    });

    $collection->all();

    // ['Michael', 'Tom']


    $collection = collect();

    $collection->whenEmpty(function (Collection $collection) {
        return $collection->push('Adam');
    });

    $collection->all();

    // ['Adam']

當集合不為空時，可以將第二個閉包傳遞給 `whenEmpty` 將要執行的方法：

    $collection = collect(['Michael', 'Tom']);

    $collection->whenEmpty(function (Collection $collection) {
        return $collection->push('Adam');
    }, function (Collection $collection) {
        return $collection->push('Taylor');
    });

    $collection->all();

    // ['Michael', 'Tom', 'Taylor']

與 `whenEmpty` 相反的方法，請查看 [`whenNotEmpty`](#method-whennotempty) 方法。

<a name="method-whennotempty"></a>
#### `whenNotEmpty()` {.collection-method}

該 `whenNotEmpty` 方法當集合不為空時，將執行給定的回調函數：

    $collection = collect(['michael', 'tom']);

    $collection->whenNotEmpty(function (Collection $collection) {
        return $collection->push('adam');
    });

    $collection->all();

    // ['michael', 'tom', 'adam']


    $collection = collect();

    $collection->whenNotEmpty(function (Collection $collection) {
        return $collection->push('adam');
    });

    $collection->all();

    // []

可以將第二個閉包傳遞給 `whenNotEmpty` 將在集合為空時執行的方法：

    $collection = collect();

    $collection->whenNotEmpty(function (Collection $collection) {
        return $collection->push('adam');
    }, function (Collection $collection) {
        return $collection->push('taylor');
    });

    $collection->all();

    // ['taylor']



與 `whenNotEmpty` 相反的方法，請查看 [`whenEmpty`](#method-whenempty) 方法。

<a name="method-where"></a>
#### `where()` {.collection-method}

該 `where` 方法通過給定的鍵 / 值對查詢過濾集合的結果：

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->where('price', 100);

    $filtered->all();

    /*
        [
            ['product' => 'Chair', 'price' => 100],
            ['product' => 'Door', 'price' => 100],
        ]
    */

該 `where` 方法在檢查集合項值時使用「寬松」模式比較，這意味著具有整數值的字符串會被認為等於相同值的整數。你可以使用 [`whereStrict`](#method-wherestrict) 方法進行「嚴格」模式比較。

而且，你還可以將一個比較運算符作為第二個參數傳遞。
支持的運算符是有 '===', '！==', '！=', '==', '=', '<>', '>', '<', '>=', 和 '<='。

    $collection = collect([
        ['name' => 'Jim', 'deleted_at' => '2019-01-01 00:00:00'],
        ['name' => 'Sally', 'deleted_at' => '2019-01-02 00:00:00'],
        ['name' => 'Sue', 'deleted_at' => null],
    ]);

    $filtered = $collection->where('deleted_at', '!=', null);

    $filtered->all();

    /*
        [
            ['name' => 'Jim', 'deleted_at' => '2019-01-01 00:00:00'],
            ['name' => 'Sally', 'deleted_at' => '2019-01-02 00:00:00'],
        ]
    */

<a name="method-wherestrict"></a>
#### `whereStrict()` {.collection-method}

此方法和 [`where`](#method-where) 方法使用相似；但是它是「嚴格」模式去匹配值和類型。

<a name="method-wherebetween"></a>
#### `whereBetween()` {.collection-method}

該 `whereBetween` 方法會篩選給定範圍的集合：

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 80],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Pencil', 'price' => 30],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereBetween('price', [100, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Desk', 'price' => 200],
            ['product' => 'Bookcase', 'price' => 150],
            ['product' => 'Door', 'price' => 100],
        ]
    */



<a name="method-wherein"></a>
#### `whereIn()` {.collection-method}

該 `whereIn` 方法會根據包含給定數組的鍵 / 值對來過濾集合：

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereIn('price', [150, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Desk', 'price' => 200],
            ['product' => 'Bookcase', 'price' => 150],
        ]
    */

`whereIn` 方法在檢查項目值時使用 "loose" 比較，這意味著具有整數值的字符串將被視為等於相同值的整數。使用 [`whereInStrict`](#method-whereinstrict) 方法使用「strict」比較進行過濾。

<a name="method-whereinstrict"></a>
#### `whereInStrict()` {.collection-method}

此方法與 [`whereIn`](#method-wherein) 方法具有相同的簽名；但是，所有值都使用「strict」比較進行比較。

<a name="method-whereinstanceof"></a>
#### `whereInstanceOf()` {.collection-method}

`whereInstanceOf` 方法按給定的類類型過濾集合：

    use App\Models\User;
    use App\Models\Post;

    $collection = collect([
        new User,
        new User,
        new Post,
    ]);

    $filtered = $collection->whereInstanceOf(User::class);

    $filtered->all();

    // [App\Models\User, App\Models\User]

<a name="method-wherenotbetween"></a>
#### `whereNotBetween()` {.collection-method}

`whereNotBetween` 方法通過確定指定項的值是否超出給定範圍來過濾集合：

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 80],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Pencil', 'price' => 30],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereNotBetween('price', [100, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Chair', 'price' => 80],
            ['product' => 'Pencil', 'price' => 30],
        ]
    */

<a name="method-wherenotin"></a>
#### `whereNotIn()` {.collection-method}

`whereNotIn` 方法從集合中刪除具有給定數組中包含的指定項值的元素：

    $collection = collect([
        ['product' => 'Desk', 'price' => 200],
        ['product' => 'Chair', 'price' => 100],
        ['product' => 'Bookcase', 'price' => 150],
        ['product' => 'Door', 'price' => 100],
    ]);

    $filtered = $collection->whereNotIn('price', [150, 200]);

    $filtered->all();

    /*
        [
            ['product' => 'Chair', 'price' => 100],
            ['product' => 'Door', 'price' => 100],
        ]
    */



`whereNotIn` 方法在檢查項目值時使用「loose」比較，這意味著具有整數值的字符串將被視為等於具有相同值的整數。使用 [`whereNotInStrict`](#method-wherenotinstrict) 方法使用「strict」比較進行過濾。

<a name="method-wherenotinstrict"></a>
#### `whereNotInStrict()` {.collection-method}

這個方法與 [`whereNotIn`](#method-wherenotin) 方法類似；不同的是會使用「嚴格」模式比較。

<a name="method-wherenotnull"></a>
#### `whereNotNull()` {.collection-method}

該 `whereNotNull` 方法篩選給定鍵不為 `null`的項：

    $collection = collect([
        ['name' => 'Desk'],
        ['name' => null],
        ['name' => 'Bookcase'],
    ]);

    $filtered = $collection->whereNotNull('name');

    $filtered->all();

    /*
        [
            ['name' => 'Desk'],
            ['name' => 'Bookcase'],
        ]
    */

<a name="method-wherenull"></a>
#### `whereNull()` {.collection-method}

該 `whereNull` 方法篩選給定鍵為 `null`的項：

    $collection = collect([
        ['name' => 'Desk'],
        ['name' => null],
        ['name' => 'Bookcase'],
    ]);

    $filtered = $collection->whereNull('name');

    $filtered->all();

    /*
        [
            ['name' => null],
        ]
    */


<a name="method-wrap"></a>
#### `wrap()` {.collection-method}

靜態 `wrap` 方法會將給定值封裝到集合中：

    use Illuminate\Support\Collection;

    $collection = Collection::wrap('John Doe');

    $collection->all();

    // ['John Doe']

    $collection = Collection::wrap(['John Doe']);

    $collection->all();

    // ['John Doe']

    $collection = Collection::wrap(collect('John Doe'));

    $collection->all();

    // ['John Doe']

<a name="method-zip"></a>
#### `zip()` {.collection-method}

該 `zip` 方法在與集合的值對應的索引處合並給定數組的值：

    $collection = collect(['Chair', 'Desk']);

    $zipped = $collection->zip([100, 200]);

    $zipped->all();

    // [['Chair', 100], ['Desk', 200]]

<a name="higher-order-messages"></a>
## Higher Order Messages

集合也提供對「高階消息傳遞」的支持，即集合常見操作的快捷方式。支持高階消息傳遞的集合方法有： [`average`](#method-average)、[`avg`](#method-avg)、[`contains`](#method-contains)、[`each`](#method-each)、[`every`](#method-every)、[`filter`](#method-filter)、[`first`](#method-first)、[`flatMap`](#method-flatmap)、[`groupBy`](#method-groupby)、[`keyBy`](#method-keyby)、[`map`](#method-map)、[`max`](#method-max)、[`min`](#method-min)、[`partition`](#method-partition)、[`reject`](#method-reject)、[`skipUntil`](#method-skipuntil)、[`skipWhile`](#method-skipwhile)、[`some`](#method-some)、[`sortBy`](#method-sortby)、[`sortByDesc`](#method-sortbydesc)、[`sum`](#method-sum)、[`takeUntil`](#method-takeuntil)、[`takeWhile`](#method-takeewhile) 和 [`unique`](#method-unique)。


每個高階消息都可以作為集合實例上的動態屬性進行訪問。例如，讓我們使用 `each` 高階消息來調用集合中每個對象的方法：

    use App\Models\User;

    $users = User::where('votes', '>', 500)->get();

    $users->each->markAsVip();

同樣，我們可以使用 `sum` 高階消息來收集用戶集合的「votes」總數：

    $users = User::where('group', 'Development')->get();

    return $users->sum->votes;

<a name="lazy-collections"></a>
## 惰性集合

<a name="lazy-collection-introduction"></a>
### 介紹

> **注意：**在進一步了解 Laravel 的惰性集合之前，花點時間熟悉一下 [PHP 生成器](https://www.php.net/manual/en/language.generators.overview.php).

為了補充已經強大的 `Collection` 類，`LazyCollection` 類利用 PHP 的 [generators](https://www.php.net/manual/en/language.generators.overview.php) 允許你使用非常 大型數據集，同時保持較低的內存使用率。

例如，假設你的應用程序需要處理數 GB 的日志文件，同時利用 Laravel 的集合方法來解析日志。可以使用惰性集合在給定時間僅將文件的一小部分保留在內存中，而不是一次將整個文件讀入內存：

    use App\Models\LogEntry;
    use Illuminate\Support\LazyCollection;

    LazyCollection::make(function () {
        $handle = fopen('log.txt', 'r');

        while (($line = fgets($handle)) !== false) {
            yield $line;
        }
    })->chunk(4)->map(function (array $lines) {
        return LogEntry::fromLines($lines);
    })->each(function (LogEntry $logEntry) {
        // Process the log entry...
    });



或者，假設你需要遍歷 10,000 個 Eloquent 模型。使用傳統 Laravel 集合時，所有 10,000 個 Eloquent 模型必須同時加載到內存中：

    use App\Models\User;

    $users = User::all()->filter(function (User $user) {
        return $user->id > 500;
    });

但是，查詢構建器的 `cursor` 方法返回一個 `LazyCollection` 實例。這允許你仍然只對數據庫運行一個查詢，而且一次只在內存中加載一個 Eloquent 模型。在這個例子中，`filter` 回調在我們實際單獨遍歷每個用戶之前不會執行，從而可以大幅減少內存使用量：

    use App\Models\User;

    $users = User::cursor()->filter(function (User $user) {
        return $user->id > 500;
    });

    foreach ($users as $user) {
        echo $user->id;
    }

<a name="creating-lazy-collections"></a>
### 創建惰性集合

要創建惰性集合實例，你應該將 PHP 生成器函數傳遞給集合的 `make` 方法：

    use Illuminate\Support\LazyCollection;

    LazyCollection::make(function () {
        $handle = fopen('log.txt', 'r');

        while (($line = fgets($handle)) !== false) {
            yield $line;
        }
    });

<a name="the-enumerable-contract"></a>
### 枚舉契約

`Collection` 類上幾乎所有可用的方法也可以在 `LazyCollection` 類上使用。這兩個類都實現了 `Illuminate\Support\Enumerable` 契約，它定義了以下方法：

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

<div class="collection-method-list" markdown="1">

[all](#method-all)
[average](#method-average)
[avg](#method-avg)
[chunk](#method-chunk)
[chunkWhile](#method-chunkwhile)
[collapse](#method-collapse)
[collect](#method-collect)
[combine](#method-combine)
[concat](#method-concat)
[contains](#method-contains)
[containsStrict](#method-containsstrict)
[count](#method-count)
[countBy](#method-countBy)
[crossJoin](#method-crossjoin)
[dd](#method-dd)
[diff](#method-diff)
[diffAssoc](#method-diffassoc)
[diffKeys](#method-diffkeys)
[dump](#method-dump)
[duplicates](#method-duplicates)
[duplicatesStrict](#method-duplicatesstrict)
[each](#method-each)
[eachSpread](#method-eachspread)
[every](#method-every)
[except](#method-except)
[filter](#method-filter)
[first](#method-first)
[firstOrFail](#method-first-or-fail)
[firstWhere](#method-first-where)
[flatMap](#method-flatmap)
[flatten](#method-flatten)
[flip](#method-flip)
[forPage](#method-forpage)
[get](#method-get)
[groupBy](#method-groupby)
[has](#method-has)
[implode](#method-implode)
[intersect](#method-intersect)
[intersectAssoc](#method-intersectAssoc)
[intersectByKeys](#method-intersectbykeys)
[isEmpty](#method-isempty)
[isNotEmpty](#method-isnotempty)
[join](#method-join)
[keyBy](#method-keyby)
[keys](#method-keys)
[last](#method-last)
[macro](#method-macro)
[make](#method-make)
[map](#method-map)
[mapInto](#method-mapinto)
[mapSpread](#method-mapspread)
[mapToGroups](#method-maptogroups)
[mapWithKeys](#method-mapwithkeys)
[max](#method-max)
[median](#method-median)
[merge](#method-merge)
[mergeRecursive](#method-mergerecursive)
[min](#method-min)
[mode](#method-mode)
[nth](#method-nth)
[only](#method-only)
[pad](#method-pad)
[partition](#method-partition)
[pipe](#method-pipe)
[pluck](#method-pluck)
[random](#method-random)
[reduce](#method-reduce)
[reject](#method-reject)
[replace](#method-replace)
[replaceRecursive](#method-replacerecursive)
[reverse](#method-reverse)
[search](#method-search)
[shuffle](#method-shuffle)
[skip](#method-skip)
[slice](#method-slice)
[sole](#method-sole)
[some](#method-some)
[sort](#method-sort)
[sortBy](#method-sortby)
[sortByDesc](#method-sortbydesc)
[sortKeys](#method-sortkeys)
[sortKeysDesc](#method-sortkeysdesc)
[split](#method-split)
[sum](#method-sum)
[take](#method-take)
[tap](#method-tap)
[times](#method-times)
[toArray](#method-toarray)
[toJson](#method-tojson)
[union](#method-union)
[unique](#method-unique)
[uniqueStrict](#method-uniquestrict)
[unless](#method-unless)
[unlessEmpty](#method-unlessempty)
[unlessNotEmpty](#method-unlessnotempty)
[unwrap](#method-unwrap)
[values](#method-values)
[when](#method-when)
[whenEmpty](#method-whenempty)
[whenNotEmpty](#method-whennotempty)
[where](#method-where)
[whereStrict](#method-wherestrict)
[whereBetween](#method-wherebetween)
[whereIn](#method-wherein)
[whereInStrict](#method-whereinstrict)
[whereInstanceOf](#method-whereinstanceof)
[whereNotBetween](#method-wherenotbetween)
[whereNotIn](#method-wherenotin)
[whereNotInStrict](#method-wherenotinstrict)
[wrap](#method-wrap)
[zip](#method-zip)

</div>

> **注意：**改變集合的方法（例如 `shift`、`pop`、`prepend` 等）在 `LazyCollection` 類中**不**可用。


<a name="lazy-collection-methods"></a>
### 惰性集合方法

除了在 `Enumerable` 契約中定義的方法外， `LazyCollection` 類還包含以下方法：

<a name="method-takeUntilTimeout"></a>
#### `takeUntilTimeout()` {.collection-method}

`takeUntilTimeout` 方法返回新的惰性集合，它會在給定時間前去枚舉集合值，之後集合將停止枚舉：

    $lazyCollection = LazyCollection::times(INF)
        ->takeUntilTimeout(now()->addMinute());

    $lazyCollection->each(function (int $number) {
        dump($number);

        sleep(1);
    });

    // 1
    // 2
    // ...
    // 58
    // 59

為了具體闡述此方法，請設想一個使用遊標從數據庫提交發票的例子。你可以定義一個 [計劃任務](/docs/laravel/10.x/scheduling)，它每十五分鐘執行一次，並且只執行發票提交操作的最大時間是 14 分鐘：

    use App\Models\Invoice;
    use Illuminate\Support\Carbon;

    Invoice::pending()->cursor()
        ->takeUntilTimeout(
            Carbon::createFromTimestamp(LARAVEL_START)->add(14, 'minutes')
        )
        ->each(fn (Invoice $invoice) => $invoice->submit());

<a name="method-tapEach"></a>
#### `tapEach()` {.collection-method}

當 `each` 方法為集合中每一個元素調用給定回調時， `tapEach` 方法僅調用給定回調，因為這些元素正在逐個從列表中拉出：

    // 沒有任何輸出
    $lazyCollection = LazyCollection::times(INF)->tapEach(function (int $value) {
        dump($value);
    });

    // 打印出三條數據
    $array = $lazyCollection->take(3)->all();

    // 1
    // 2
    // 3

<a name="method-remember"></a>
#### `remember()` {.collection-method}

`remember` 方法返回一個新的惰性集合，這個集合已經記住（緩存）已枚舉的所有值，當再次枚舉該集合時不會獲取它們：

    // 沒執行任何查詢
    $users = User::cursor()->remember();

    //  執行了查詢操作
    // The first 5 users are hydrated from the database...
    $users->take(5)->all();

    // 前 5 個用戶數據從緩存中獲取
    // The rest are hydrated from the database...
    $users->take(20)->all();
