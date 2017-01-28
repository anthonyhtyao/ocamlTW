CREATE TABLE IF NOT EXISTS category(
    id int primary key NOT NULL,
    theme text NOT NULL,
    chapter text NOT NULL);

CREATE TABLE IF NOT EXISTS article(
  id int primary key NOT NULL,
  category int references category(id) NOT NULL,
  title text NOT NULL,
  abstract text NOT NULL,
  content text NOT NULL,
  slg text NOT NULL);

INSERT INTO category
  SELECT 1, 'OCamlTuto', 'Basics' 
  WHERE NOT EXISTS (SELECT id FROM category WHERE id = 1);

INSERT INTO category
  SELECT 2, 'Related', 'N/A'
  WHERE NOT EXISTS (SELECT id FROM category WHERE id = 2);

INSERT INTO article
  SELECT 1, 1, 'Why OCaml?', '', 'the article that explains the advantages
  of OCaml here', 'why-ocaml'
  WHERE NOT EXISTS (SELECT id FROM article WHERE id = 1);

INSERT INTO article
  SELECT 2, 2, '談談 Functional Language', 
  'Functional Language 是什麼？他又跟一般我們習慣的程式語言如 C++,Java
   等有什麼不一樣呢',
  'Functional Language 是什麼？他又跟一般我們習慣的程式語言如 C++,Java
   等有什麼不一樣呢？在一個函數式語言裡面，函數是一個 first-class values，
   可以直接當作一個函數的變數或者回傳值...',
  'what-is-functional-language'
  WHERE NOT EXISTS (SELECT id FROM article WHERE id = 2);

INSERT INTO article
  SELECT 3, 2, '用 menhir 寫個 parser', 
  '今天我們要來聊聊一個 ocaml 相關的工具 menhir', 
  '今天我們要來聊聊一個 ocaml 相關的工具 menhir，就如同對於 C 有 yacc 一樣
   Ocaml 也有自己拿來寫 parser 的工具，叫做 ocamlyacc，而 menhir 則是...',
  'write-parser-with-menhir'
  WHERE NOT EXISTS (SELECT id FROM article WHERE id = 3);
