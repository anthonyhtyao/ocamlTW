
UPDATE article
SET content = 

'<h2>變數宣告 (Declaration of variables)</h2>

<p>
從現在起正式進入我們 tuto 的第一堂課，從最簡單的變數宣告開始。如果我們今天想要宣告一個變數 x 取值為 42，那該怎麼做呢？在 C/C++/Java 我們寫 <code>int x = 42;</code>，在 Ada 的話要寫 <code>x:integer := 42;</code>，在 Python 更是簡單易懂的 <code>x = 42</code>。而 OCaml 裡則是以下寫法

<pre><code>let x = 42</code></pre>

有沒有很簡單，這樣我們就成功宣告我們的第一個全域變數 (global variable) 了。
</p>

<p>
這裡有幾點要注意，首先，我們並不需要告訴程式我們變數的型別 (type)，因為在 OCaml 裡有非常完善的型別推論 (type inference) 系統，程式會自己推得與每個變數相符的型別。像是如果我們在互動環境輸入 <code>let x = 42;;</code> 螢幕會接著顯示

<pre><code>val x : int = 42</code></pre>

電腦很聰明的判斷出了 x 是一個 int。接著還有一個小細節，OCaml 的變數一定是以一個小寫英文字母開頭，因為大寫英文字幕開頭的字是預留給模組名稱 (Module) 使用的。
</p>

<p>
最後，在 OCaml 中，對於變數宣告的理解跟 C 或者 Java 其實是不一樣的。OCaml 身為宣告式編程 (declarative programming) 底下泛函編程 (Functional Programming) 的範疇，我們寫的與其說是程式的實現方式，更可以視為單純的想要實現目標的性質，在函數式語言 (Functional Language) 中，一個程式本身可以被看作一個函數，而我們描述的則是這個函數的定義、實作等等。
</p>

<p>
相信大家還記得在寫 C 的時候，實際上 <code>int x = 42;</code> 是由宣告 <code>int x;</code> 以及之後的定義 <code>x = 42;</code> 合併而來的。我們先宣告一個變數的存在，之後再賦予它一個 value，然而在 OCaml 中的 <code>let x = 42</code> 卻並非如此，我們是直接定義了 x 這個變數就代表 42 這個數字，而我們之後是沒有任何辦法再去改變 x 的值的。果我們隨後寫到 <code>let x = 41</code> 的話，那我們並不是將 x 的值改成 42，而是重新定義另一個 x 代表 41。不如考慮下面的 code：

<pre><code>let x = 42
let f y = x + y
let x = 0
let() = print_int (f(10))
</code></pre>

在第二行我們定義了一個函數 f，對於任意傳入的參數 y，回傳 x 與 y 的和，關於更詳細的函數相關內容請見下節。
</p>

<p>
如果要試圖在 C 或 Python 寫出相等的程式碼，我們或許會想寫

<pre><code>#include &lt;stdio.h&gt;

int x = 42
int f(int y) {return x+y;}

int main(){
	int x = 0
	printf("%d",f(10))
}
</code></pre>

以及在 Python:

<pre><code>x = 42
def f(y): return x+y
x = 0
print(f(10))
</code></pre></p>

<p>
然而我們分別執行上面三段程式碼後，得到的結果竟然是 52、10、10，OCaml 的結果跟別人的不一樣。因為正如前面所說的，在 OCaml 
裡第二個 x 跟第一個 x 是沒有關係的，也因此不會影響到已經被定義的函數。實際上直到我們第五節提到 OCaml 的 imperative features 之前，我們定義的變數的值基本上都是不能在之後進行變更的，也因此避免了在寫程式時可能造成的副作用 (side effect)，可以說是寫函數語言的一大樂事。其他有的語言像是 Haskell，甚至可以說是完全沒有 side effect 呢！
</p>

<p>
當然如果你是程式新手，其實看完 let x = 42 怎麼寫後就可以直接跳往下一段落了(←也太晚說了)，不過我們推論這個網站的閱覽者在寫程式這塊領域大概都有些歷練，所以可能也有人可以發現事實並非我上面所提的那麼簡單，的確用此來解釋 OCaml 變數宣告的概念是不錯的，不過其實在 C++11 後我們也可以做到類似的效果

<pre><code>#include &lt;iostream&gt;
using namespace std;

int main(){
	int x = 42;
	auto f = [x](int y){return x+y;};
	x = 0;
	cout << f(10);
}
</code></pre>

一樣可以得到 52，那我就不囉嗦了，直接進如下一個段落，基本資料型別吧！</p>


<h2>基本資料型別 (Basic Data types)</h2>

<p>
OCaml 身為一個強型別 (strongly typed) 程式語言，要將其精通對於其型別系統 (type system) 的掌握是不可或缺的 (正好比寫 Java 不能不懂 object 一樣)，也因此在之後我們將會花一整節來好好講解 OCaml 中型別的概念。不過大家先不用緊張，一步一步按部就班，這裡先從最基本的整數、浮點數等等講起，讓大家對於自己平常會操作到的值有個簡單的概念。
</p>

<h3>整數 (int)</h3>
<p>
第一個最基本的資料型別當然就是整數了，包含了正整數以及負整數，由於電腦的儲存空間有限 (malheureusement, on est en informatique, pas en mathématiques)，如果你使用的是 32 位元的電腦，整數本身的範圍是從 -2^30 到 2^30-1，類似的若是 64 位元的電腦的話，則是從 -2^62 到 2^62-1，下面以 64 位元為例
</p>

<pre><code># 3;;
- : int = 3
# 20 + 5;;
- : int = 25
# -40 - 2;;
- : int = -42
# max_int;;
- : int = 4611686018427387903
# min_int;;
- : int = -4611686018427387904
# min_int - 1;;
- : int = 4611686018427387903
</code></pre>

<p>
正如我們上面所看到的，在發生溢位 (overflow) 的情況下，跟 C 一樣，電腦是不會有任何警告的，所以請自己務必小心。然後相信聰明的你已經發現到了，為什麼這裡整數似乎少用了一位呢？實際上這跟與 OCaml 內部 value 的表示方式有關，為了讓 OCaml 自己的 GC (garbage collector) 能夠判讀一個位置儲存的是否是指標，真正的整數實際表示上最後一位都是 1，因此 1,2,3 其實在機器裡分別是用了 1,3,5 的二進制表示法，再加上 alignment 的關係，當看到一個 value 最後一位是 0 的時候，GC 就能馬上理解那是個指標了喔。(是說這裡竟然提到了指標，難道 OCaml 裡面也有指標嗎?實際上每個語言在將某些特定的資料型態儲存在電腦的記憶體裡的時候，或多或少都必須用到指標的概念，像是在 Pascal 要儲存一個 record，或者在 C# 要儲存一個 object 等等，然而並不是說一定會像 C/C++ 一樣直接操作到指標喔。) 另外如果你真的非常希望使用 64 位元的整數的話，OCaml 也有提供一個叫做 Int64 的 module，不過我想一般情況是不會用到的吧。
</p>

<h3>浮點數 (float)</h3>

<p>
在 OCaml 裡的浮點數遵守 IEEE 754 標準，而且是使用 double precision number，因此表示的能力是如同 C 裡的 double 的，除了一般的小數以外，還有 <code>infinity</code>, <code>neg_infinity</code> 和 <code>nan</code> 三個特殊值用來處理特殊的情況 (好比在 Python 裡打 <code>float("inf")</code> 一樣)。
</p>

<pre><code># 3.5;;
- : float = 3.5
# 8.18 +. 6.16;;
- : float = 14.34
# 8.7e-1;; 
- : float = 0.87
# infinity;;
- : float = infinity
# let x = 0. /. 0.;;
val x : float = nan
# let pi = 4.0 *. atan 1.0;;
val pi : float = 3.14159265358979312
</code></pre>

<h3>布林值 (bool)</h3>

<p>
真真假假，以假亂真，OCaml 也有提供布林型別，真跟假分別是 <code>true</code> 跟 <code>false</code>，第一個字母是小寫請注意。
</p>

<pre><code># true;;
- : bool = true
# false;;
- : bool = false
# let z = 3 in let b = 5 in z > b;;
- : bool = false
</code></pre>

<h3>字元 (char)</h3>

<p>
OCaml 裡面的 char 型別就相當於 256 個 ASCII 字元 (不過我們也知道在 ASCII 裡第 129 個字元以後是沒有正式定義的)，一般就是將要打的字元放在兩個 '' 之間，對於特殊字元 '' 以及 \ 的情況，必須在前面加上跳脫符號 \ 。<code>int_of_char</code> 以及 <code>char_of_int</code> 兩個函數負責字元與 ASCII code 之間的轉換。
</p>

<pre><code># ''a'';;
- : char = ''a''
# <u>''</u>'''';;
Error: Syntax error
# ''\'''';;
- : char = ''\''''
# int_of_char ''@'';;
- : int = 64
# let c = char_of_int 99;
val c : char = ''c''
</code></pre>

<h3>字串 (string)</h3>

<p>
接著要談的是 string 字串，其實字串已經不能算是原始型別了，因為若要進行更進一步的操作，必須要用到 <a href=''https://caml.inria.fr/pub/docs/manual-ocaml/libref/String.html''>String</a> 這個 module，在下面我們會有一些簡單的例子，如果想要更深入了解就請直接參考前面的連結。不過既然我們都已經寫過 Hello World! 了，這裡不介紹一下字串也說不太過去，string 的內容必須打在兩個雙引號 " 裡面，規則就一如往常，要換行打 <code>\n</code>，要打出 " 則要使用跳脫字元所以要打 <code>\"</code> 等等。
</p>

<pre><code># "Hello world!";;
- : string = "Hello world!"
# print_string "RMT\n";;
RMT
- : unit = ()
# string_of_int 777;; (*將整數轉成字串*)	
- : string = "777"
# string_of_float 33.0;; (*將浮點數轉成字串*)
- : string = "33."
# int_of_string "512";; (*將字串轉成整數*)
- : int = 512
# int_of_string "1e";;
Exception: Failure "int_of_string".
</code></pre>

<p>
呼叫一個 module 的函數使用的語法是 <code>&lt;Module&gt;.&lt;function&gt;</code>，下面舉幾個 String 裡面的例子：

<pre><code># String.length "This is a string";; (*字串長度*)
- : int = 17
# String.make 2 ''@'';; (*重複一個字元數次構成一個字串*)
- : string = "@@"
# String.sub "Akatsuki no deban ne, mite nasai" 0 8;; (*子字串*)
- : string = "Akatsuki"
</code></pre>

在 OCaml 4.02.0 之後字串型態變成不可動 (immutable) 的了，而可動的字串型態則由另一種叫做 byte 的型態代替，不過由於 imperative 的部分要留到日後再談，更深入的細節就不在這多提了。另外關於 string，除了使用跳脫字元外，實際上在版本 4.02.0 之後還有另一種能夠直接打出我們想要的內容的語法，即 <code>{|...|}</code>，目標字串擺在正中間，甚至是 <code>{id|...|id}</code>，這裡 <code>id</code> 是前後兩個任意相同的字串等等。
</p>

<pre><code># {|"OCaml tutorial\n"|};; 
- : string = "\"OCaml tutorial\\n\""
# {|This doesn''t work.|}<u>|}</u>;; 
Error: Syntax error
# {meow|But this works!|}|meow}
- : string = "But this works!|}"
</code></pre>

<h3>Type unit</h3>

<p>
在 OCaml 中 unit 型別只包含單一值記作 ()，有點類似 C 跟 Java 中的 void，可以理解為相對應的值並不存在，例如一個沒有任何回傳值的函數回傳的就是這個型別，一個指令 (詳見 Imperative features 的章節) 本身也是被視作這個型別。
</p>

<pre><code># ();;
- : unit = ();;
# print_endline "This instruction has type unit.";;
This instruction has type unit.
- : unit = ();;
</code></pre>

<h3>n 元組 (n-tuple)</h3>

<p>
最後要提到的是 tuple，可以很方便的讓我們將好幾個不同的數值記在一起，在一個 tuple 內的元素不需要是同樣的 type，而 tuple 本身 type 的表示則是好幾個不同的 type 中間以 * 相連，另外要注意的是像是 <code>a * b * c</code> 以及 <code>(a * b) * c</code> 兩個的 type 是不一樣的。

<pre><code># "meow", 42;;
- : string * int = ("meow", 42)
# (3,5,7);;
- : int * int * int = (3, 5, 7)
# (3,5),7;;
- : (int * int) * int = ((3, 5), 7)
# 3,5,7 = <u>(3,5)</u>,7;;
Error: This expression has type ''a * ''b
       but an expression was expected of type int
</code></pre>

在只有兩個元素也就是 pair 的情況，我們可以分別利用 <code>fst</code> 和 <code>snd</code> 取得它第一個以及第二個值，在有更多元素的情況下，其實只要在左邊撰寫可以對應起來的變數組合即可
</p>

<pre><code># let p = "hibiki", "inazuma";;
val p : string * string = ("hibiki", "inazuma")
# fst p;;
- : string = "hibiki"

# let xyz = 17,23,97.;;
val xyw : int * int * float = (17, 23, 97.)
# let x, y, z = xyz;;
val x : int = 17
val y : int = 23
val z : float = 97.
# let a, b = <u>xyz</u>;;
Error: This expression has type int * int * float
       but an expression was expected of type ''a * ''b
	   
# let abc = (''a'',"b"),99;;
val abc : (char * string) * int = ((''a'', "b"), 99)
# let ab, c = abc;;
val ab : char * string = (''a'', "b")
val c : int = 99
# let (a,b),c = abc;;
val a : char = ''a''
val b : string = "b"
val c : int = 99
# let a,b,c = <u>abc</u>;;
Error: This expression has type (char * string) * int
       but an expression was expected of type ''a * ''b * ''c
</code></pre>


<p>
在看過這些基本的 type 後，要記住一件事情，在 OCaml 中，無論兩種資料型別多麼接近，像是 int 和 float 又或者 char 和 string，只要未經過撰寫程式的人明確地進行型別轉換的話，兩個不同型別的值就是不相容的 (no compatible)，也就是說，隱式型別轉換 (implicit type conversion) 並不存在，只要在寫 OCaml，那遇到 type error 就是家常便飯，這在下面運算子的段落你將會有更深的體會，平常寫 JavaScript 習慣的人要頭痛了呢 (笑。
</p>'

WHERE id = 7;
