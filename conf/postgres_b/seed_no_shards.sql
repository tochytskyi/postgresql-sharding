INSERT INTO books_no_shards (id, category_id, author, title, year)
SELECT generate_series(1, 1000000),
       round(random() + 1) ::int AS category_id,
       md5(random()::text) as author,
       md5(random()::text) as title,
       floor(random() * 100 + 1950) ::int AS year;