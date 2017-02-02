DROP DATABASE ocamltw;
CREATE DATABASE ocamltw;
\c ocamltw

CREATE TABLE IF NOT EXISTS users(
  login text NOT NULL,
  password text NOT NULL
);

CREATE TABLE IF NOT EXISTS category(
    id serial primary key NOT NULL,
    theme text NOT NULL,
    theme_label text NOT NULL,
    chapter text,
    chapter_label text,
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
  abstract text NOT NULL,
  content text NOT NULL,
  slg text unique NOT NULL,
  previous int references article(id),
  next int references article(id)
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

INSERT INTO category (id,theme,theme_label,chapter,chapter_label,article)
  VALUES
  (1, 'ocamltuto','OCaml 教學', 'OCaml core language','OCaml 入門', 1),
  (2, 'Related','相關文章',null,null,null);

INSERT INTO article (id,category,title,abstract,content,slg,previous,next)
  VALUES
  (1, 1, 'OCaml core language', '', '從最核心的部份談起，包含基本的四則
    運算、函數定義、以及型別的概念等等', 'ocaml-core-language',null,2),
  (2, 1, 'Why OCaml?', '', 'the article that explains the advantages
  of OCaml here', 'why-ocaml',1,null),
  (3, 2, '談談 Functional Language', 
  'Functional Language 是什麼？他又跟一般我們習慣的程式語言如 C++,Java
   等有什麼不一樣呢',
  'Functional Language 是什麼？他又跟一般我們習慣的程式語言如 C++,Java
   等有什麼不一樣呢？在一個函數式語言裡面，函數是一個 first-class values，
   可以直接當作一個函數的變數或者回傳值...',
  'what-is-functional-language',null,4),
  (4, 2, '用 menhir 寫個 parser', 
  '今天我們要來聊聊一個 ocaml 相關的工具 menhir', 
  '今天我們要來聊聊一個 ocaml 相關的工具 menhir，就如同對於 C 有 yacc 一樣
   Ocaml 也有自己拿來寫 parser 的工具，叫做 ocamlyacc，而 menhir 則是...',
  'write-parser-with-menhir',3,null);
