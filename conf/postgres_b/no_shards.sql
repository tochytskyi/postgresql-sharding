CREATE TABLE books_no_shards
(
    id          bigint            not null,
    category_id int not null,
    author character varying not null,
    title       character varying not null,
    year        int               not null
);

CREATE INDEX books_category_id_idx ON books_no_shards USING btree(category_id);

