# postgresql-sharding
PostgreSQL sharding example

### Setup the first shard
```shell
docker-compose up -d postgres_b1
docker exec -it postgres_b1 psql -U postgres -d books -f /scripts/shards.sql -a
```

Result:
```shell
docker exec -it postgres_b1 psql -U postgres -d books -c "select * from books"

 id | category_id | author | title | year 
----+-------------+--------+-------+------
(0 rows)
```

### Setup the second shard
```shell
docker-compose up -d postgres_b2
docker exec -it postgres_b2 psql -U postgres -d books -f /scripts/shards.sql -a
```

```shell
docker exec -it postgres_b2 psql -U postgres -d books -c "select * from books"

 id | category_id | author | title | year 
----+-------------+--------+-------+------
(0 rows)
```

### Setup the main server
```shell
docker-compose up -d postgres_b
docker exec -it postgres_b psql -U postgres -d books -f /scripts/shards.sql -a
```

Two demo rows have been already inserted
```sql
INSERT INTO books (id, category_id, author, title, year)
VALUES (4,1,'AA','BB',1980),
       (5,2,'Lina Kostenko','Incrustacii',1994);
```

```shell
docker exec -it postgres_b psql -U postgres -d books -c "select * from books"

 id | category_id |    author     |    title    | year 
----+-------------+---------------+-------------+------
  4 |           1 | AA            | BB          | 1980
  5 |           2 | Lina Kostenko | Incrustacii | 1994
(2 rows)

```

### Check shards after inserting 2 demo rows to main server
Shard 1 with constraint `category = 1`
```shell
docker exec -it postgres_b1 psql -U postgres -d books -c "select * from books"

 id | category_id | author | title | year 
----+-------------+--------+-------+------
  4 |           1 | AA     | BB    | 1980
(1 row)
```

Shard 2 with constraint `category = 2`
```shell
docker exec -it postgres_b2 psql -U postgres -d books -c "select * from books"

 id | category_id |    author     |    title    | year 
----+-------------+---------------+-------------+------
  5 |           2 | Lina Kostenko | Incrustacii | 1994
(1 row)
```


### Test insert performance with sharding
Add 1 000 000 rows

```shell
docker exec -it postgres_b psql -U postgres -d books -c '\timing' -f /scripts/seed.sql

Time: 356968.881 ms (05:56.969)
```

### Test insert performance without sharding
Add 1 000 000 rows

```shell
docker exec -it postgres_b psql -U postgres -d books -f /scripts/no_shards.sql -a
docker exec -it postgres_b psql -U postgres -d books -c '\timing' -f /scripts/seed_no_shards.sql

Time: 6179.055 ms (00:06.179)
```