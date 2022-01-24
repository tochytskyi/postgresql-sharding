INSERT INTO books (category_id, author, title, year)
SELECT generate_series(1, 100),
       floor(random() * 3 + 1) ::int AS category_id,
       md5(random()::text) as author,
       md5(random()::text) as title,
       floor(random() * 100 + 1950) ::int AS year;