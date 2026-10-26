-- Part A: Two numbers in one pass
-- For each producer(flights), compute the total number of events(bookings) 
-- and the total number of events classified as failures, 
-- in a single pass over the event table, without a WHERE clause filtering the whole query. 
-- The outliers here are the producers you will name in your finding.
-- ✓  CASE used inside an aggregate — for example SUM(CASE WHEN ... THEN 1 ELSE 0 END) or COUNT(CASE WHEN ... END).
-- ✓  Both totals appearing as separate columns in one result set.
SELECT
    f.flight_id,
    f.flight_number,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN b.booking_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY cancelled_bookings DESC, total_bookings DESC;


-- Part B: Subtotals and a grand total
-- The regional director wants subtotals per region and a platform grand total, not the detail rows. 
-- Write a query that produces regional subtotals and a platform-wide grand total 
-- without including the individual detail rows.
-- ✓  GROUP BY ROLLUP (...), or GROUPING SETS or CUBE.
-- ✓  A written note identifying which rows are the subtotals and which is the grand total.
SELECT
    CASE WHEN GROUPING(b.booking_country) = 1 THEN 'ALL REGIONS'
         ELSE b.booking_country END AS region,
    COUNT(*)                        AS booking_count,
    SUM(b.fare_paid)                AS total_fare
FROM bookings b
GROUP BY ROLLUP (b.booking_country)
ORDER BY GROUPING(b.booking_country), b.booking_country;


-- Part C: A two-step pipeline
-- Leadership wants to establish a baseline for evaluating high-volume producers. 
-- That needs two steps: use a WITH clause to create an intermediate result that summarizes performance for each producer, 
-- then use a second aggregation or filter on that intermediate result to calculate a baseline for high-volume producers.
-- ✓  A WITH clause producing an intermediate aggregate.
-- ✓  A second aggregation or filter applied to that intermediate result.
WITH flight_summary AS (
    SELECT
        f.flight_id,
        f.flight_number,
        COUNT(*)                                                         AS total_bookings,
        SUM(CASE WHEN b.booking_status = 'cancelled' THEN 1 ELSE 0 END)  AS cancelled_bookings,
        AVG(b.fare_paid)                                                 AS avg_fare
    FROM bookings b
    JOIN flights f ON f.flight_id = b.flight_id
    GROUP BY f.flight_id, f.flight_number
)

SELECT
    COUNT(*)                                                   AS high_volume_flights,
    ROUND(AVG(avg_fare), 2)                                    AS baseline_avg_fare,
    ROUND(100.0 * SUM(cancelled_bookings) / SUM(total_bookings), 1) AS baseline_cancel_rate_pct
FROM flight_summary
WHERE total_bookings >= 16;
