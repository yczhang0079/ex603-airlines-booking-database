-- Task 6.1: Compute across a window without collapsing
-- Compare each event to its producer’s average. 

-- Is an event unusual for its own producer? 
-- Return every event with its producer’s average metric on the same row. 
-- Returns every booking and shows the average fare paid for that booking's flight on the same row.
-- Use AVG(...) OVER (PARTITION BY ...). 
SELECT
    booking_id,
    flight_id,
    passenger_id,
    fare_paid,
    AVG(fare_paid) OVER (
        PARTITION BY flight_id
    ) AS avg_fare_for_flight
FROM bookings
ORDER BY flight_id, booking_id; 
--returns 200 rows

-- Then write the GROUP BY version:
SELECT
    flight_id,
    AVG(fare_paid) AS avg_fare_for_flight
FROM bookings
GROUP BY flight_id
ORDER BY flight_id;
--returns 13 rows

-- how many rows does each return, and what is lost?
-- The window-function query returns 200 rows, one for each booking, 
-- because it preserves the original rows and adds the average fare for that flight. 
-- The GROUP BY query returns 13 rows, one for each flight with bookings. 
-- The GROUP BY version loses the individual booking details 
-- because all bookings for a flight are aggregated into a single summary row, 
-- whereas the window-function version retains every booking while still showing the flight-level average.


-- Rank producers three ways. Leadership wants to publish a producer leaderboard. 
-- When two producers tie, the ranking method decides who appears higher. 
-- Rank producers by number of events using ROW_NUMBER(), RANK(), and DENSE_RANK(), side by side in one query. 
-- Make sure your output shows at least one tie.
WITH flight_booking_counts AS (
    SELECT
        f.flight_number,
        COUNT(*) AS booking_count
    FROM flights f
    JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY f.flight_number
)
SELECT
    flight_number,
    booking_count,
    ROW_NUMBER() OVER (ORDER BY booking_count DESC) AS row_number_rank,
    RANK() OVER (ORDER BY booking_count DESC) AS rank_rank,
    DENSE_RANK() OVER (ORDER BY booking_count DESC) AS dense_rank_rank
FROM flight_booking_counts
ORDER BY booking_count DESC, flight_number;


-- Sort producers into four bands. Use NTILE(4) to split producers into four groups by number of events. 
-- Look at what happens when tied producers land on both sides of a group boundary.
WITH flight_booking_counts AS (
    SELECT
        f.flight_number,
        COUNT(*) AS booking_count
    FROM flights f
    JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY f.flight_number
)
SELECT
    flight_number,
    booking_count,
    NTILE(4) OVER (ORDER BY booking_count DESC) AS quartile
FROM flight_booking_counts
ORDER BY booking_count DESC, flight_number;
-- Using NTILE(4) successfully divides flights into four performance bands, 
-- but it can separate flights with identical booking counts. 
-- In this dataset, flights VN207 and VN205 (18 bookings) 
-- and flights VN202 and VN211 (16 bookings) were placed into different quartiles despite having the same number of bookings. 
-- This shows that NTILE() prioritizes balanced group sizes over preserving ties, 
-- so producers with equal performance may appear in different bands.