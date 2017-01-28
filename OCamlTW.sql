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

INSERT INTO article
  SELECT 1, 1, 'Why OCaml?', '', 'the article that explains the advantages
  of OCaml here', 'why-ocaml'
  WHERE NOT EXISTS (SELECT id FROM article WHERE id = 1);
