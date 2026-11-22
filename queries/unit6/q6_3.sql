-- Task 6.3: Build the reporting patterns
-- Two patterns you will meet in nearly every analytics job.

-- Part A: Top N per category
-- Return the top three events by metric for each producer. Most leaderboards and recommendation features are built this way.
-- A ranking window function, partitioned by producer.
-- A CTE or subquery that filters to rank <= 3.
-- FIRST_VALUE() or LAST_VALUE() used somewhere in your solution. If you use LAST_VALUE(), add ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING; 
-- with the default frame it returns the wrong value.
-- A comment saying how ties at third place are handled, and why.
WITH ranked_bookings AS (
    SELECT
        f.flight_number,
        b.booking_id,
        b.booked_at,
        b.fare_paid,

        RANK() OVER (
            PARTITION BY b.flight_id
            ORDER BY b.fare_paid DESC
        ) AS fare_rank,

        FIRST_VALUE(b.fare_paid) OVER (
            PARTITION BY b.flight_id
            ORDER BY b.fare_paid DESC
        ) AS highest_fare_for_flight

    FROM bookings b
    JOIN flights f
        ON b.flight_id = f.flight_id
)
SELECT
    flight_number,
    booking_id,
    booked_at,
    fare_paid,
    fare_rank,
    highest_fare_for_flight
FROM ranked_bookings
WHERE fare_rank <= 3
ORDER BY flight_number, fare_rank, fare_paid DESC;
-- I use RANK() since it gives identical fares the same rank.
-- Ties at third place are included.
-- RANK() assigns the same rank to equal fare values,
-- so if multiple bookings tie for third-highest fare,
-- all of them are returned. This is fair because bookings
-- with the same fare should receive the same leaderboard position.


-- Part B: Period over period
-- Is the platform getting better or worse each month? This is the founder’s real question. 
-- Group your events by calendar month, then compare each month with the month before.
-- Group events into months (for example, with DATE_TRUNC('month', ...)).
-- LAG() over the monthly series.
-- A percent-change column that avoids division by zero (for example, with NULLIF(..., 0)).
-- A check for missing months. LAG counts rows, so a missing month makes it compare the wrong months.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', booked_at)::date AS month_start,
        SUM(fare_paid) AS revenue
    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)
),
month_comparison AS (
    SELECT
        month_start,
        revenue,
        LAG(month_start) OVER (ORDER BY month_start) AS previous_month,
        LAG(revenue) OVER (ORDER BY month_start) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    month_start,
    revenue,
    previous_month,
    previous_revenue,
    revenue - previous_revenue AS revenue_change,
    ROUND(
        100.0 * (revenue - previous_revenue)
        / NULLIF(previous_revenue, 0),
        2
    ) AS percent_change,
    CASE
        WHEN previous_month IS NULL THEN 'first month'
        WHEN month_start <> previous_month + INTERVAL '1 month'
             THEN 'MISSING MONTHS DETECTED'
        ELSE 'continuous'
    END AS month_check
FROM month_comparison
ORDER BY month_start;