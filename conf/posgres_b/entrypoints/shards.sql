CREATE TABLE books
(
    id          bigint            not null,
    category_id int               not null,
    author      character varying not null,
    title       character varying not null,
    year        int               not null
);

CREATE INDEX books_category_id_idx ON books USING btree(category_id);

CREATE EXTENSION postgres_fdw;

/* SHARD 1 */
CREATE SERVER books_1_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS ( host 'postgres_b1', port '5432', dbname 'books' );

CREATE USER MAPPING FOR "postgres"
    SERVER books_1_server
    OPTIONS (user 'postgres', password 'postgres');

CREATE FOREIGN TABLE books_1
    (
        id bigint not null,
        category_id int not null,
        author character varying not null,
        title character varying not null,
        year int not null
        ) SERVER books_1_server
    OPTIONS (schema_name 'public', table_name 'books');


/* SHARD 2 */
CREATE SERVER books_2_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS ( host 'postgres_b2', port '5432', dbname 'books' );

CREATE USER MAPPING FOR "postgres"
    SERVER books_2_server
    OPTIONS (user 'postgres', password 'postgres');

CREATE FOREIGN TABLE books_2
    (
        id bigint not null,
        category_id int not null,
        author character varying not null,
        title character varying not null,
        year int not null
        ) SERVER books_2_server
    OPTIONS (schema_name 'public', table_name 'books');


CREATE VIEW books_view AS
SELECT *
FROM books_1
UNION ALL
SELECT *
FROM books_2;

CREATE RULE books_insert AS ON INSERT TO books_view
    DO INSTEAD NOTHING;
CREATE RULE books_update AS ON UPDATE TO books_view
    DO INSTEAD NOTHING;
CREATE RULE books_delete AS ON DELETE TO books_view
    DO INSTEAD NOTHING;

CREATE RULE books_insert_to_1 AS ON INSERT TO books_view
    WHERE (category_id = 1)
    DO INSTEAD INSERT INTO books_1
               VALUES (NEW.*);

CREATE RULE books_insert_to_2 AS ON INSERT TO books_view
    WHERE (category_id = 2)
    DO INSTEAD INSERT INTO books_2
               VALUES (NEW.*);

INSERT INTO books (id, category_id, author, title, year)
VALUES (4,1,'AA','BB',1980),
       (5,2,'Lina Kostenko','Incrustacii',1994);
