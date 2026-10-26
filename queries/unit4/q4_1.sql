-- Calculate the following statistics across the entire event (bookings) table using your theme's metric: 
-- the count, total, average, minimum, and maximum of your theme’s metric across the whole event table, 
-- and how many distinct actors (passengers) appear. Review your results carefully. 
-- For example, if your metric should never be zero but your minimum value is zero, 
-- this may indicate another data-quality issue that needs investigation.
-- Theme: airline flight booking (passengers, flights, airports, bookings, flight routes).
SELECT
    COUNT(*)                     AS booking_count,
    SUM(fare_paid)               AS total_fare,
    AVG(fare_paid)               AS avg_fare,
    MIN(fare_paid)               AS min_fare,
    MAX(fare_paid)               AS max_fare,
    COUNT(DISTINCT passenger_id) AS distinct_passengers
FROM bookings;

-- Write a query that calculates the event (bookings) count and average metric for each producer(flights). 
-- Sort the results from the producer(flights) with the most events to the producer with the fewest. 
-- Consider what these results tell you about differences in activity and performance across producers.
SELECT
    f.flight_id,
    f.flight_number,
    COUNT(b.booking_id) AS booking_count,
    AVG(b.fare_paid)    AS avg_fare
FROM Flights f
LEFT JOIN Bookings b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY booking_count DESC, f.flight_number;
-- This gives a preview of different flights booking counts and the average fare, 
-- it also shows null value in the fare showing some missing fare from dataset.

-- Which producers have enough volume for their rate to mean anything? 
-- A producer with only a few events may have a high failure rate that is not representative of their usual performance. 
-- Choose a minimum event-count threshold and use HAVING to include only producers who meet that threshold. 
-- Explain why you selected your threshold.
SELECT
    f.flight_id,
    f.flight_number,
    COUNT(b.booking_id) AS booking_count,
    AVG(b.fare_paid)    AS avg_fare
FROM Flights f
JOIN Bookings b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number
HAVING COUNT(b.booking_id) >= 16
ORDER BY booking_count DESC, f.flight_number;
-- The threshold is choosed based on the result from question 2, 
-- the booking_count range from 21 to 6. So I pick a medium value of 16.


-- How does the picture change along two dimensions at once? 
-- Leadership also wants to understand how performance varies across regions. 
-- Write a query that groups the data by two dimensions, including region, and calculates the relevant summary statistics. 
-- Your results should contain one row for each combination of the two dimensions 
-- so that regional leaders can review their results.
SELECT
    b.booking_country,
    b.booking_status,
    COUNT(*)                AS booking_count,
    COUNT(DISTINCT b.passenger_id) AS distinct_passengers,
    ROUND(AVG(b.fare_paid), 2)     AS avg_fare,
    MIN(b.fare_paid)        AS min_fare,
    MAX(b.fare_paid)        AS max_fare,
    SUM(b.fare_paid)        AS total_fare
FROM bookings b
GROUP BY b.booking_country, b.booking_status
ORDER BY b.booking_country, booking_count DESC;