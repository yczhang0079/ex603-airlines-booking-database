-- Task 6.2: Compare each row to its neighbors

-- Part A: Row to row
-- Is a producer’s metric going up or down over time, not just high or low overall? For each event, 
-- show the metric from the previous event and the next event, in time order.
-- LAG() and LEAD(), partitioned by producer and ordered by timestamp.
-- A delta column: the current metric minus the previous metric.
-- In the final output, filter to one producer of your choice so the trend is easy to read.
SELECT
    flight_number,
    booking_id,
    booked_at,
    fare_paid,
    LAG(fare_paid) OVER (
        PARTITION BY b.flight_id
        ORDER BY booked_at
    ) AS previous_fare,
    LEAD(fare_paid) OVER (
        PARTITION BY b.flight_id
        ORDER BY booked_at
    ) AS next_fare,
    fare_paid
      - LAG(fare_paid) OVER (
            PARTITION BY b.flight_id
            ORDER BY booked_at
        ) AS fare_delta
FROM bookings b
JOIN flights f
    ON b.flight_id = f.flight_id
WHERE f.flight_number = 'VN205'
ORDER BY booked_at;


-- Part B: Cumulative and smoothed
-- How is the platform doing over time, both in total and on a recent average? Leadership wants to see where things stand now and how they got there.
-- SUM(...) OVER (ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) for a running total.
-- AVG(...) OVER (... ROWS BETWEEN n PRECEDING AND CURRENT ROW) for a moving average. Note: ROWS counts rows, not days. 
-- If some days have no events, a 7-row window covers more than 7 days.
-- Choose a target (for example, a total for the quarter), state it, and show how close the running total gets to it.
-- One or two sentences on how ROWS differs from RANGE when two rows have the same ORDER BY value.
WITH daily_revenue AS (
    SELECT
        DATE(booked_at) AS booking_date,
        SUM(fare_paid) AS daily_revenue
    FROM bookings
    GROUP BY DATE(booked_at)
)
SELECT
    booking_date,
    daily_revenue,

    SUM(daily_revenue) OVER (
        ORDER BY booking_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_total,

    AVG(daily_revenue) OVER (
        ORDER BY booking_date
        ROWS BETWEEN 6 PRECEDING
                 AND CURRENT ROW
    ) AS moving_avg_7_rows,

    4000 - SUM(daily_revenue) OVER (
        ORDER BY booking_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS amount_remaining_to_target
FROM daily_revenue
ORDER BY booking_date;
-- The running total shows overall progress toward the revenue goal.
-- The moving average smooths short-term fluctuations and helps leadership see 
-- whether booking revenue is generally trending upward or downward rather than reacting to one unusually high or low day.
-- ROWS counts physical rows. A window always includes exactly seven rows when available.
-- RANGE groups together rows that have the same ORDER BY value. 
-- If multiple rows share the same date, a RANGE frame can include more rows than expected because all rows with that date are treated as peers. 
-- Therefore, ROWS is based on row position, while RANGE is based on the values being ordered.

-- Part C: Where the series stops
-- One producer stops for a while and then starts again. Find that gap. 
-- Then think about what you cannot tell yet: did the producer leave, or did your data lose them?
-- LAG() or LEAD() comparing adjacent rows.
-- A CTE or subquery that computes the gap, and a WHERE in the outer query that keeps only the gaps. 
-- (You cannot filter a window function result with WHERE or HAVING in the same query, because the window function runs after them.)
WITH booking_gaps AS (
    SELECT
        f.flight_number,
        b.booking_id,
        b.booked_at,
        LAG(b.booked_at) OVER (
            PARTITION BY b.flight_id
            ORDER BY b.booked_at
        ) AS previous_booking_time,
        b.booked_at
            - LAG(b.booked_at) OVER (
                PARTITION BY b.flight_id
                ORDER BY b.booked_at
            ) AS gap_length
    FROM bookings b
    JOIN flights f
        ON b.flight_id = f.flight_id
)
SELECT
    flight_number,
    booking_id,
    previous_booking_time,
    booked_at,
    gap_length
FROM booking_gaps
WHERE gap_length > INTERVAL '30 days'
ORDER BY gap_length DESC;