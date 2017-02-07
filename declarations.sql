
UPDATE article
SET content =

'<h2>變數宣告 (Declaration of variables)</h2>

<p>
從現在起正式進入我們 tuto 的第一堂課，從最簡單的變數宣告開始。如果我們今天想要宣告一個變數 x 取值為 42，那該怎麼做呢？
在 C/C++/Java 我們寫 <code>int x = 42;</code>，在 Ada 的話要寫 <code>x:integer := 42;</code>，
在 Python 更是簡單易懂的 <code>x = 42</code>。而 OCaml 裡則是以下寫法

<pre><code>let x = 42</code></pre>

有沒有很簡單，這樣我們就成功宣告我們的第一個全域變數 (global variable) 了。
</p>

<p>
這裡有幾點要注意，首先，我們並不需要告訴程式我們變數的型別(type)，因為在 OCaml 裡有非常完善的型別推論 (type inference) 
系統，程式會自己推得與每個變數相符的型別。像是如果我們在互動環境輸入 <code>let x = 42;;</code> 螢幕會接著顯示

<pre><code>val x : int = 42</code></pre>

電腦很聰明的判斷出了 x 是一個 int。
</p>

<p>
再者，在 OCaml 中，對於變數宣告的理解跟 C 或者 Java 其實是不一樣的。OCaml 身為宣告式編程 
(declarative programming) 底下泛函編程 (Functional Programming) 的範疇，我們寫的與其說是程式的實現方式，
更可以視為單純的想要實現目標的性質，在函數式語言 (Functional Language) 中，一個程式本身可以被看作一個函數，
而我們描述的則是這個函數的定義、實作等等。
</p>

<p>
相信大家還記得在寫 C 的時候，實際上 <code>int x = 42;</code> 是由宣告 <code>int x;</code> 以及之後的定義 
<code>x = 42;</code> 合併而來的。我們先宣告一個變數的存在，之後再賦予它一個 value，然而在 OCaml 中的 
<code>let x = 42</code> 卻並非如此，我們是直接定義了 x 這個變數就代表 42 這個
數字，而我們之後是沒有任何辦法再去改變 x 的值的。果我們隨後寫到 <code>let x = 41</code> 的話，那我們並不是
將 x 的值改成 42，而是重新定義另一個 x 代表 41。不如考慮下面的 code：

<pre><code>let x = 42
let f y = x + y
let x = 0
let() = print_int (f(10))
</code></pre>

在第二行我們定義了一個函數 f，對於任意傳入的參數 y，回傳 x 與 y 的和，關於更詳細的函數相關內容請見下節。
</p>

<p>
如果要試圖在 C 或 python 寫出相等的程式碼，我們或許會想寫

<pre><code>#include &lt;stdio.h&gt;

int x = 42
int f(int y) {return x+y;}

int main(){
	int x = 0
	printf("%d",f(10))
}
</code></pre>

以及在 python:

<pre><code>x = 42
def f(y): return x+y
x = 0
print(f(10))
</code></pre></p>

<p>
然而我們分別執行上面三段程式碼後，得到的結果竟然是 52、10、10，OCaml 的結果跟別人的不一樣。因為正如前面所說的，在 OCaml 
裡第二個 x 跟第一個 x 是沒有關係的，也因此不會影響到已經被定義的函數。實際上直到我們第五節提到 OCaml 的 imperative
features 之前，我們定義的變數的值基本上都是不能在之後進行變更的，也因此避免了在寫程式時可能造成的副作用(side effect)，
可以說是寫函數語言的一大樂事。其他有的語言像是 Haskell，甚至可以說是完全沒有 side effect 呢！
</p>

<p>
當然如果你是程式新手，其實看完 let x = 42 怎麼寫後就可以直接跳往下一段落了(←也太晚說了)，不過我們推論這個網站的閱覽者
在寫程式這塊領域大概都有些歷練，所以可能也有人可以發現事實並非我上面所提的那麼簡單，的確用此來解釋 OCaml 變數宣告
的概念是不錯的，不過其實在 C++11 後我們也可以做到類似的效果

<pre><code>#include &lt;iostream&gt;
using namespace std;

int main(){
	int x = 42;
	auto f = [x](int y){return x+y;};
	x = 0;
	cout << f(10);
}
</code></pre>

一樣可以得到 52，那我就不囉嗦了，直接進如下一個段落，基本資料型態吧！</p>'

WHERE id = 7; 
