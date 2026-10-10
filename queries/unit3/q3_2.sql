-- Part A: The rows that vanished
-- BROKEN QUERY: silently omits NULL rows
SELECT COUNT(*)
FROM bookings
WHERE cancellation_reason != 'Payment failed';      -- 27

-- ROWS THE BROKEN QUERY SILENTLY OMITTED
SELECT COUNT(*)
FROM bookings
WHERE cancellation_reason = 'Payment failed';        -- 7

-- TOTAL ROW COUNT
SELECT COUNT(*)
FROM bookings;                                       -- 200

SELECT
-- broken query count
(SELECT COUNT(*)
 FROM bookings
 WHERE cancellation_reason <> 'Payment failed') AS non_payment_failed_count,
-- rows the broken query silently omitted
(SELECT COUNT(*)
 FROM bookings
 WHERE cancellation_reason = 'Payment failed') AS payment_failed_count,
-- total row count
(SELECT COUNT(*)
 FROM bookings) AS total_count;


-- FIXED QUERY: correctly includes NULL using COALESCE
SELECT COUNT(*)
FROM bookings
WHERE COALESCE(cancellation_reason, 'No reason provided') <> 'Payment failed';   -- 193

SELECT
-- broken query count
(SELECT COUNT(*)
 FROM bookings
 WHERE COALESCE(cancellation_reason, 'No reason provided') <> 'Payment failed') AS non_payment_failed_count,
-- rows the broken query silently omitted
(SELECT COUNT(*)
 FROM bookings
 WHERE cancellation_reason = 'Payment failed') AS payment_failed_count,
-- total row count
(SELECT COUNT(*)
 FROM bookings) AS total_count;

-- Part B: The alias that did not exist yet
-- SQL is written FROM, WHERE, SELECT, ORDER BY, but it is not evaluated in that order.

-- Write a query defining an alias in SELECT and referencing that alias in WHERE. 
-- Capture the error message verbatim.
SELECT
    seat_capacity / 10 AS capacity_bucket
FROM flights
WHERE capacity_bucket > 20;
-- ERROR:  column "capacity_bucket" does not exist
-- LINE 4: WHERE capacity_bucket > 20;

-- Produce two correct rewrites: 
-- one repeating the expression in WHERE
SELECT
    seat_capacity / 10 AS capacity_bucket
FROM flights
WHERE seat_capacity / 10 > 20;

-- one wrapping the query in a CTE or subquery so the alias becomes a real column
WITH flight_buckets AS (
    SELECT
        seat_capacity / 10 AS capacity_bucket,
        flight_number
    FROM flights
)
SELECT capacity_bucket
FROM flight_buckets
WHERE capacity_bucket > 20;
