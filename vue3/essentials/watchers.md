# 偵聽器 {#watchers}

## 基本示例 {#basic-example}

計算屬性允許我們聲明性地計算衍生值。然而在有些情況下，我們需要在狀態變化時執行一些“副作用”：例如更改 DOM，或是根據異步操作的結果去修改另一處的狀態。

<div class="options-api">

在選項式 API 中，我們可以使用 [`watch` 選項](/api/options-state#watch)在每次響應式屬性發生變化時觸發一個函數。

```js
export default {
  data() {
    return {
      question: '',
      answer: 'Questions usually contain a question mark. ;-)'
    }
  },
  watch: {
    // 每當 question 改變時，這個函數就會執行
    question(newQuestion, oldQuestion) {
      if (newQuestion.includes('?')) {
        this.getAnswer()
      }
    }
  },
  methods: {
    async getAnswer() {
      this.answer = 'Thinking...'
      try {
        const res = await fetch('https://yesno.wtf/api')
        this.answer = (await res.json()).answer
      } catch (error) {
        this.answer = 'Error! Could not reach the API. ' + error
      }
    }
  }
}
```

```vue-html
<p>
  Ask a yes/no question:
  <input v-model="question" />
</p>
<p>{{ answer }}</p>
```

[在演練場中嘗試一下](https://play.vuejs.org/#eNptUk2PmzAQ/SuvXAA1sdVrmt0qqnroqa3UIxcLhuCGjKk/wkYR/70OBJLuroRkPDPvzbznuSS7rhOnQMkm2brS6s4/F0wvnbEeFdUqtB6XgoFKeZXl0z9gyQfL8w34G8h5bXiDNF3NQcWuJxtDv25Zh+CCatszSsNeaYZakDgqexD4vM7TCT9cj2Ek65Uvm83cTUr0DTGdyN7RZaN4T24F32iHOnA5hnvdtrCBJ+RcnTH180wrmLaaL4s+QNd4LBOaK3r5UWfplzTHM9afHmoxdhV78rtRcpbPmVHEf1qO5BtTuUWNcmcu8QC9046kk4l4Qvq70XzQvBdC3CyKJfb8OEa01fn4OC7Wq15pj5qidVnaeN+5jZRncmxE72upOp0uY77ulU3gSCT+uOhXnt9yiy6U1zdBRtYa+9aK+9TfrgUf8NWEtgKbK6mKQN8Qdj+/C6T4iJHkXcsKjt9WLpsZL56OXas8xRuw7cYD2LlDXKYoT7K5b+OU22rugsdpfTQVtU9FMueLBHKikRNPpLtcbnuLYZjCW7m0TIZ/92UFiQ==)

`watch` 選項也支持把鍵設置成用 `.` 分隔的路徑：

```js
export default {
  watch: {
    // 注意：只能是簡單的路徑，不支持表達式。
    'some.nested.key'(newValue) {
      // ...
    }
  }
}
```

</div>

<div class="composition-api">

在組合式 API 中，我們可以使用 [`watch` 函數](/api/reactivity-core#watch)在每次響應式狀態發生變化時觸發回調函數：

```vue
<script setup>
import { ref, watch } from 'vue'

const question = ref('')
const answer = ref('Questions usually contain a question mark. ;-)')

// 可以直接偵聽一個 ref
watch(question, async (newQuestion, oldQuestion) => {
  if (newQuestion.indexOf('?') > -1) {
    answer.value = 'Thinking...'
    try {
      const res = await fetch('https://yesno.wtf/api')
      answer.value = (await res.json()).answer
    } catch (error) {
      answer.value = 'Error! Could not reach the API. ' + error
    }
  }
})
</script>

<template>
  <p>
    Ask a yes/no question:
    <input v-model="question" />
  </p>
  <p>{{ answer }}</p>
</template>
```

[在演練場中嘗試一下](https://play.vuejs.org/#eNplkkGPmzAQhf/KKxdA3Rj1mpJUUdVDT22lHrlYxDRuYOzaJjRC/PcdxyGr3b2A7PfmmzcMc3awVlxGlW2z2rdO2wCvwmj3DenBGhcww6nuCZMM7QkLOmcG5FyRN9RQa8gH/BuVD9oQdtFb5Hm5KpL8pNx6/+vu8xj9KPv+CnYFqQnyhTFIdxb4vCkjpaFb32JVnyD9lVoUpKaVVmK3x9wQoLtXgtB0VP9/cOMveYk9Np/K5MM9l7jIflScLv990nTW9EcIwXNFR3DX1YwYk4dxyrNXTlIHdCrGyk8hWL+tqqvyZMQUukpaHYOnujdtilTLHPHXGyrKUiRH8i9obx+5UM4Z98j6Pu23qH/AVzP2R5CJRMl14aRw+PldIMdH3Bh3bnzxY+FcdZW2zPvlQ1CD7WVQfALquPToP/gzL4RHqsg89rJNWq3JjgGXzWCOqt812ao3GaqEqRKHcfO8/gDLkq7r6tEyW54Bf5TTlg==)

### 偵聽數據源類型 {#watch-source-types}

`watch` 的第一個參數可以是不同形式的“數據源”：它可以是一個 ref (包括計算屬性)、一個響應式對象、一個 getter 函數、或多個數據源組成的數組：

```js
const x = ref(0)
const y = ref(0)

// 單個 ref
watch(x, (newX) => {
  console.log(`x is ${newX}`)
})

// getter 函數
watch(
  () => x.value + y.value,
  (sum) => {
    console.log(`sum of x + y is: ${sum}`)
  }
)

// 多個來源組成的數組
watch([x, () => y.value], ([newX, newY]) => {
  console.log(`x is ${newX} and y is ${newY}`)
})
```

注意，你不能直接偵聽響應式對象的屬性值，例如:

```js
const obj = reactive({ count: 0 })

// 錯誤，因為 watch() 得到的參數是一個 number
watch(obj.count, (count) => {
  console.log(`count is: ${count}`)
})
```

這里需要用一個返回該屬性的 getter 函數：

```js
// 提供一個 getter 函數
watch(
  () => obj.count,
  (count) => {
    console.log(`count is: ${count}`)
  }
)
```

</div>

## 深層偵聽器 {#deep-watchers}

<div class="options-api">

`watch` 默認是淺層的：被偵聽的屬性，僅在被賦新值時，才會觸發回調函數——而嵌套屬性的變化不會觸發。如果想偵聽所有嵌套的變更，你需要深層偵聽器：

```js
export default {
  watch: {
    someObject: {
      handler(newValue, oldValue) {
        // 注意：在嵌套的變更中，
        // 只要沒有替換對象本身，
        // 那麽這里的 `newValue` 和 `oldValue` 相同
      },
      deep: true
    }
  }
}
```

</div>

<div class="composition-api">

直接給 `watch()` 傳入一個響應式對象，會隱式地創建一個深層偵聽器——該回調函數在所有嵌套的變更時都會被觸發：

```js
const obj = reactive({ count: 0 })

watch(obj, (newValue, oldValue) => {
  // 在嵌套的屬性變更時觸發
  // 注意：`newValue` 此處和 `oldValue` 是相等的
  // 因為它們是同一個對象！
})

obj.count++
```

相比之下，一個返回響應式對象的 getter 函數，只有在返回不同的對象時，才會觸發回調：

```js
watch(
  () => state.someObject,
  () => {
    // 僅當 state.someObject 被替換時觸發
  }
)
```

你也可以給上面這個例子顯式地加上 `deep` 選項，強制轉成深層偵聽器：

```js
watch(
  () => state.someObject,
  (newValue, oldValue) => {
    // 注意：`newValue` 此處和 `oldValue` 是相等的
    // *除非* state.someObject 被整個替換了
  },
  { deep: true }
)
```

</div>

:::warning 謹慎使用
深度偵聽需要遍歷被偵聽對象中的所有嵌套的屬性，當用於大型數據結構時，開銷很大。因此請只在必要時才使用它，並且要留意性能。
:::

## 即時回調的偵聽器 {#eager-watchers}

`watch` 默認是懶執行的：僅當數據源變化時，才會執行回調。但在某些場景中，我們希望在創建偵聽器時，立即執行一遍回調。舉例來說，我們想請求一些初始數據，然後在相關狀態更改時重新請求數據。

<div class="options-api">

我們可以用一個對象來聲明偵聽器，這個對象有 `handler` 方法和 `immediate: true` 選項，這樣便能強制回調函數立即執行：

```js
export default {
  // ...
  watch: {
    question: {
      handler(newQuestion) {
        // 在組件實例創建時會立即調用
      },
      // 強制立即執行回調
      immediate: true
    }
  }
  // ...
}
```

回調函數的初次執行就發生在 `created` 鉤子之前。Vue 此時已經處理了 `data`、`computed` 和 `methods` 選項，所以這些屬性在第一次調用時就是可用的。

</div>

<div class="composition-api">

我們可以通過傳入 `immediate: true` 選項來強制偵聽器的回調立即執行：

```js
watch(source, (newValue, oldValue) => {
  // 立即執行，且當 `source` 改變時再次執行
}, { immediate: true })
```

</div>

<div class="composition-api">

## `watchEffect()` \*\* {#watcheffect}

偵聽器的回調使用與源完全相同的響應式狀態是很常見的。例如下面的代碼，在每當 `todoId` 的引用發生變化時使用偵聽器來加載一個遠程資源：

```js
const todoId = ref(1)
const data = ref(null)

watch(todoId, async () => {
  const response = await fetch(
    `https://jsonplaceholder.typicode.com/todos/${todoId.value}`
  )
  data.value = await response.json()
}, { immediate: true })
```

特別是注意偵聽器是如何兩次使用 `todoId` 的，一次是作為源，另一次是在回調中。

我們可以用 [`watchEffect` 函數](/api/reactivity-core#watcheffect) 來簡化上面的代碼。`watchEffect()` 允許我們自動跟蹤回調的響應式依賴。上面的偵聽器可以重寫為：

```js
watchEffect(async () => {
  const response = await fetch(
    `https://jsonplaceholder.typicode.com/todos/${todoId.value}`
  )
  data.value = await response.json()
})
```

這個例子中，回調會立即執行，不需要指定 `immediate: true`。在執行期間，它會自動追蹤 `todoId.value` 作為依賴（和計算屬性類似）。每當 `todoId.value` 變化時，回調會再次執行。有了 `watchEffect()`，我們不再需要明確傳遞 `todoId` 作為源值。

你可以參考一下[這個例子](/examples/#fetching-data)的 `watchEffect` 和響應式的數據請求的操作。

對於這種只有一個依賴項的例子來說，`watchEffect()` 的好處相對較小。但是對於有多個依賴項的偵聽器來說，使用 `watchEffect()` 可以消除手動維護依賴列表的負擔。此外，如果你需要偵聽一個嵌套數據結構中的幾個屬性，`watchEffect()` 可能會比深度偵聽器更有效，因為它將只跟蹤回調中被使用到的屬性，而不是遞歸地跟蹤所有的屬性。

:::tip
`watchEffect` 僅會在其**同步**執行期間，才追蹤依賴。在使用異步回調時，只有在第一個 `await` 正常工作前訪問到的屬性才會被追蹤。
:::

### `watch` vs. `watchEffect` {#watch-vs-watcheffect}

`watch` 和 `watchEffect` 都能響應式地執行有副作用的回調。它們之間的主要區別是追蹤響應式依賴的方式：

- `watch` 只追蹤明確偵聽的數據源。它不會追蹤任何在回調中訪問到的東西。另外，僅在數據源確實改變時才會觸發回調。`watch` 會避免在發生副作用時追蹤依賴，因此，我們能更加精確地控制回調函數的觸發時機。

- `watchEffect`，則會在副作用發生期間追蹤依賴。它會在同步執行過程中，自動追蹤所有能訪問到的響應式屬性。這更方便，而且代碼往往更簡潔，但有時其響應性依賴關系會不那麽明確。

</div>

## 回調的觸發時機 {#callback-flush-timing}

當你更改了響應式狀態，它可能會同時觸發 Vue 組件更新和偵聽器回調。

默認情況下，用戶創建的偵聽器回調，都會在 Vue 組件更新**之前**被調用。這意味著你在偵聽器回調中訪問的 DOM 將是被 Vue 更新之前的狀態。

如果想在偵聽器回調中能訪問被 Vue 更新**之後**的 DOM，你需要指明 `flush: 'post'` 選項：

<div class="options-api">

```js
export default {
  // ...
  watch: {
    key: {
      handler() {},
      flush: 'post'
    }
  }
}
```

</div>

<div class="composition-api">

```js
watch(source, callback, {
  flush: 'post'
})

watchEffect(callback, {
  flush: 'post'
})
```

後置刷新的 `watchEffect()` 有個更方便的別名 `watchPostEffect()`：

```js
import { watchPostEffect } from 'vue'

watchPostEffect(() => {
  /* 在 Vue 更新後執行 */
})
```

</div>

<div class="options-api">

## `this.$watch()` \* {#this-watch}

我們也可以使用組件實例的 [`$watch()` 方法](/api/component-instance#watch)來命令式地創建一個偵聽器：

```js
export default {
  created() {
    this.$watch('question', (newQuestion) => {
      // ...
    })
  }
}
```

如果要在特定條件下設置一個偵聽器，或者只偵聽響應用戶交互的內容，這方法很有用。它還允許你提前停止該偵聽器。

</div>

## 停止偵聽器 {#stopping-a-watcher}

<div class="options-api">

用 `watch` 選項或者 `$watch()` 實例方法聲明的偵聽器，會在宿主組件卸載時自動停止。因此，在大多數場景下，你無需關心怎麽停止它。

在少數情況下，你的確需要在組件卸載之前就停止一個偵聽器，這時可以調用 `$watch()` API 返回的函數：

```js
const unwatch = this.$watch('foo', callback)

// ...當該偵聽器不再需要時
unwatch()
```

</div>

<div class="composition-api">

在 `setup()` 或 `<script setup>` 中用同步語句創建的偵聽器，會自動綁定到宿主組件實例上，並且會在宿主組件卸載時自動停止。因此，在大多數情況下，你無需關心怎麽停止一個偵聽器。

一個關鍵點是，偵聽器必須用**同步**語句創建：如果用異步回調創建一個偵聽器，那麽它不會綁定到當前組件上，你必須手動停止它，以防內存泄漏。如下方這個例子：

```vue
<script setup>
import { watchEffect } from 'vue'

// 它會自動停止
watchEffect(() => {})

// ...這個則不會！
setTimeout(() => {
  watchEffect(() => {})
}, 100)
</script>
```

要手動停止一個偵聽器，請調用 `watch` 或 `watchEffect` 返回的函數：

```js
const unwatch = watchEffect(() => {})

// ...當該偵聽器不再需要時
unwatch()
```

注意，需要異步創建偵聽器的情況很少，請盡可能選擇同步創建。如果需要等待一些異步數據，你可以使用條件式的偵聽邏輯：

```js
// 需要異步請求得到的數據
const data = ref(null)

watchEffect(() => {
  if (data.value) {
    // 數據加載後執行某些操作...
  }
})
```

</div>

<!-- zhlint disabled -->
