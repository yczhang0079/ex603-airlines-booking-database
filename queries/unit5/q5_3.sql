-- Task 5.3: Understand Join Performance and Execution Plans

-- Part A: Explore CROSS JOIN
-- Count the Rows in Each Source Table
SELECT COUNT(*) AS airport_count
FROM airports; --5 rows
SELECT COUNT(*) AS flight_count
FROM flights; --15 rows

-- Perform the CROSS JOIN
SELECT
a.airport_id,
a.airport_name,
f.flight_id,
f.flight_number
FROM airports a
CROSS JOIN flights f; --75 rows

-- Validation of result
SELECT
  (SELECT COUNT(*) FROM flights) AS flights_n,
  (SELECT COUNT(*) FROM airports)   AS airports_n,
  (SELECT COUNT(*) FROM flights) * (SELECT COUNT(*) FROM airports) AS expected_rows,
  (SELECT COUNT(*) FROM flights CROSS JOIN airports) AS actual_rows;
-- A CROSS JOIN creates a Cartesian product, meaning every airport is paired with every flight. 
-- The total number of rows equals the number of rows in the first table multiplied by the number of rows in the second table. 
-- This can be useful when generating all possible combinations, such as testing schedules or creating route options. 
-- However, a Cartesian product can also indicate a query error if it occurs unintentionally due to a missing join condition, 
-- potentially producing many more rows than expected and leading to incorrect reports or poor query performance.

-- Part B: Examine a Query Execution Plan
-- Return to your three-table join from Task 5.1, 
-- Part A. Use PostgreSQL's EXPLAIN command to examine how the database plans to execute the query.
EXPLAIN
SELECT
    p.passenger_id,
    p.passenger_name,
    f.flight_number,
    b.booked_at,
	b.checked_in_at
FROM bookings b
JOIN passengers p
    ON b.passenger_id = p.passenger_id
JOIN flights f
    ON b.flight_id = f.flight_id
ORDER BY p.passenger_id, p.passenger_name;

EXPLAIN ANALYZE
SELECT
    p.passenger_id,
    p.passenger_name,
    f.flight_number,
    b.booked_at,
	b.checked_in_at
FROM bookings b
JOIN passengers p
    ON b.passenger_id = p.passenger_id
JOIN flights f
    ON b.flight_id = f.flight_id
ORDER BY p.passenger_id, p.passenger_name;

--Execution plan:
-- Sort  (cost=35.98..36.48 rows=200 width=536) (actual time=2.634..2.645 rows=200 loops=1)
--   Sort Key: p.passenger_id, p.passenger_name
--   Sort Method: quicksort  Memory: 37kB
--   -> Nested Loop  (cost=12.40..28.34 rows=200 width=536) (actual time=0.066..0.235 rows=200 loops=1)
--         -> Hash Join  (cost=12.25..17.80 rows=200 width=282) (actual time=0.050..0.128 rows=200 loops=1)
--               Hash Cond: (b.passenger_id = p.passenger_id)
--               -> Seq Scan on bookings b  (cost=0.00..5.00 rows=200 width=24) (actual time=0.009..0.036 rows=200 loops=1)
--               -> Hash  (cost=11.00..11.00 rows=100 width=262) (actual time=0.030..0.030 rows=30 loops=1)
--                     Buckets: 1024  Batches: 1  Memory Usage: 10kB
--                     -> Seq Scan on passengers p  (cost=0.00..11.00 rows=100 width=262)
--                        (actual time=0.007..0.011 rows=30 loops=1)
--         -> Memoize  (cost=0.15..0.41 rows=1 width=262) (actual time=0.000..0.000 rows=1 loops=200)
--               Cache Key: b.flight_id
--               Cache Mode: logical
--               Hits: 187  Misses: 13
--               Evictions: 0
--               Overflows: 0
--               Memory Usage: 2kB
--               -> Index Scan using flights_pkey on flights f
--                  (cost=0.14..0.40 rows=1 width=262)
--                  (actual time=0.002..0.002 rows=1 loops=13)
--                     Index Cond: (flight_id = b.flight_id)

-- Planning Time: 0.201 ms
-- Execution Time: 2.715 ms

-- The plan uses two join-related algorithms:
-- Hash Join
-- Hash Cond: (b.passenger_id = p.passenger_id)
-- This joins bookings (b) and passengers (p).
-- Nested Loop
-- This joins the result of the Hash Join with flights (f).

-- Why PostgreSQL Chose These Algorithms
-- Hash Join: bookings ↔ passengers
-- PostgreSQL likely chose a Hash Join because:
-- Equality join condition (passenger_id = passenger_id).
-- Small table sizes.
-- No indication that a useful index would be cheaper than scanning the entire tables.
-- Building a 30-row hash table is extremely cheap.
-- Nested Loop: previous result ↔ flights
-- PostgreSQL likely chose a Nested Loop because:
-- Each lookup into flights is very fast through the primary key index.
-- Memoization reduces repeated index scans.
-- For a relatively small outer result set, index lookups are efficient.

-- Which Part May Become Less Efficient as Data Grows?
-- The most likely bottleneck is Sequential Scans on bookings and passengers
-- If bookings grows to millions of rows, or passengers becomes very large,
-- then PostgreSQL must scan increasingly more data before performing the Hash Join.