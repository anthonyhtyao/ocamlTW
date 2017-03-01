DROP DATABASE ocamltw;
CREATE DATABASE ocamltw;
\c ocamltw

CREATE TABLE IF NOT EXISTS users(
  login text NOT NULL,
  password text NOT NULL
);

CREATE TABLE IF NOT EXISTS theme(
    id serial primary key NOT NULL,
    title text NOT NULL,
    label text NOT NULL
);

CREATE TABLE IF NOT EXISTS category(
    id serial primary key NOT NULL,
    theme int references theme(id),
    title text,
    label text,
    article int,
    previous int references category(id),
    next int references category(id)
);

CREATE TABLE IF NOT EXISTS article(
  id serial primary key NOT NULL,
  created timestamp with time zone default current_timestamp,
  lastmodified timestamp with time zone default current_timestamp,
  category int references category(id) NOT NULL,
  title text NOT NULL,
  abstract text,
  content text NOT NULL,
  slg text unique NOT NULL,
  previous int references article(id),
  next int references article(id),
  ord int NOT NULL
);

-- Change last modified for all modified rows
CREATE OR REPLACE FUNCTION update_lastmodified_column()	
RETURNS TRIGGER AS $$
BEGIN
  NEW.lastmodified = now();
  RETURN NEW;	
END;
$$ language 'plpgsql';

CREATE TRIGGER update_article_modtime BEFORE UPDATE ON article FOR EACH ROW EXECUTE PROCEDURE  update_lastmodified_column();


INSERT INTO theme (id,title,label)
  VALUES
  (1, 'ocaml-tuto','OCaml 教學'),
  (2, 'related-articles','相關文章');

INSERT INTO category (id,theme,title,label,article)
  VALUES
  (1, 1, 'prepare-yourself', 'Preparéz-vous', 1),
  (2, 1, 'ocaml-core-language','OCaml 入門', 6),
  (3, 1, 'ocaml-module', 'OCaml 的 Module 系統', 15),
  (4, 2, null,null,null);


INSERT INTO article (id,category,title,content,slg,previous,next,ord)

VALUES

  (1, 1, 'Préparez-vous', 'Start to learn OCaml! 開始建立環境。',
  'prepare-yourself', null, 2,100),
  (2, 1, 'Why OCaml?', 'the article that explains the advantages
   of OCaml here', 'why-ocaml',1,3,200),
  (3, 1, 'How to install OCaml?', 'sudo apt-get install ocaml',
  'how-to-install-ocaml',2,4,300),
  (4, 1, 'Compile OCaml', 'ocamlc -o meow meow.ml', 'compile-ocaml',3,5,400),
  (5, 1, 'Hello World!', 'print_string "Hello World!"', 'hello-world',4,6,500),

  (6, 2, 'OCaml 入門', '從最核心的部份談起，包含基本的四則
   運算、函數定義、以及型別的概念等等', 'ocaml-core-language',5,7,600),
  (7, 2, '基本資料型別與運算子什麼的名稱實在太土了我絕對不想用',
  '從現在開始就正式進入我們 tuto 的第一堂課了，當然是從基礎中的基礎基本變數
   宣告、物件型別還有運算子開始講起囉！', 
  'declarations-operations-basic-types',6,8,700),
  (8, 2, '函數',
  '你 C 和 C++ 駕輕就熟同時也是 Java 能手你相信在第一節結束之後我們肯定是要
   講流程控制 if else, for 還有 while，然而竟然是函數！',
  'functions',7,21,800),
  (21, 2, 'List and Option',
  'list and option',
  'list-option',8,9,830),
  (9, 2, '型別', 'Let''s talk about types.', 'typing',21,10,900),
  (10, 2, 'Let''s write a tree', 
  '<pre><code>type tree = F of int | T of tree*tree</code></pre>',
  'let''s-write-a-tree',9,11,1000),
  (11, 2, 'Imperative features', 'for, ref, while, if else, mutable, array',
  'imperative-features',10,12,1100),
  (12,2,'例外處理','let x = try 1/0 with _ -> 10', 'exception',11,13,1200),
  (13,2,'Pretty printing',
  'Format.printf "@[an integer: %d and a string: %s@]@?" 5 "hehe"',
  'pretty-printing',12,14,1300),
  (14,2,'來寫些簡單的圖論演算法', 
  'Dijkstra, Floyd-Warshall, Kruskal, blosso, Ford-Fulkerson',
  'algorithms-for-graphs',13,15,1400),
  
  (15,3,'OCaml 的 Module 系統','哈哈我都不會反正要講 Module', 'module',14,16,1500),
  (16,3,'Module 基本', 'module M = struct let c = 100 let f x = c * x end', 
  'structure-signature',15,17,1600),
  (17,3,'Functor','Fuctor 很厲害','functor',16,18,1700),
  (18,3,'Seperate compilation','這是啥所以','seperate-compilation',17,null,1800);

INSERT INTO article (id,category,title,abstract,content,slg,previous,next,ord)
VALUES
  (19, 4, '談談 Functional Language', 
  'Functional Language 是什麼？他又跟一般我們習慣的程式語言如 C++,Java
   等有什麼不一樣呢',
  'Functional Language 是什麼？他又跟一般我們習慣的程式語言如 C++,Java
   等有什麼不一樣呢？在一個函數式語言裡面，函數是一個 first-class values，
   可以直接當作一個函數的變數或者回傳值...',
  'what-is-functional-language',null,4,0),
  (20, 4, '用 menhir 寫個 parser', 
  '今天我們要來聊聊一個 ocaml 相關的工具 menhir', 
  '今天我們要來聊聊一個 ocaml 相關的工具 menhir，就如同對於 C 有 yacc 一樣
   Ocaml 也有自己拿來寫 parser 的工具，叫做 ocamlyacc，而 menhir 則是...',
  'write-parser-with-menhir',3,null,0);
