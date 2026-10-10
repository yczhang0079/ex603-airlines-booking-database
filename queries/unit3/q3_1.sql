-- Question 1
-- Find active, highly rated producers (flights). 
-- Use your theme’s filter condition from the appendix. 
-- Sort them and return the first ten.
SELECT flight_id, flight_number, seat_capacity
FROM flights
WHERE is_active = TRUE
AND seat_capacity >= 100
ORDER BY seat_capacity DESC
LIMIT 10;


-- Question 2
-- Find all possible event (bookings) statuses. Display the distinct values in the event status column. 
-- Look carefully at the results. Are there more statuses than you expected? null value is unexpected.
SELECT DISTINCT cancellation_reason
FROM bookings
ORDER BY cancellation_reason;

-- Question 3
-- Filter the events(bookings) in two different ways. 
-- Write: one query that filters a numeric range. (filter by fare_paid)
-- and one query that filters using an explicit list of values with IN. (filter by booking_status)
SELECT *
FROM bookings
WHERE fare_paid BETWEEN 50 AND 100;

SELECT *
FROM bookings
WHERE booking_status IN ('disputed', 'cancelled');

-- Question 4
-- Work with text and missing values. Write queries that: 
-- find producers(flights) whose names match a text pattern using LIKE, 
-- and identify records where a reason/value is missing (NULL). 
-- Use COALESCE to replace a missing value with a useful label such as: No reason provided.
SELECT
    f.flight_id,
    f.flight_number,
    b.booking_id,
    COALESCE(b.cancellation_reason, 'No reason provided') AS cancellation_reason
FROM flights AS f
LEFT JOIN bookings AS b
    ON b.flight_id = f.flight_id
WHERE f.flight_number LIKE '%21%';

-- Question 5
-- Make the results easier to understand. 
-- Create a query with calculated/computed columns (split into 3 cases for different seat_capacity)
-- that would make sense to someone who does not work with SQL.
SELECT
    f.flight_number,
    CASE
        WHEN f.seat_capacity >= 300 THEN 'Large aircraft'
        WHEN f.seat_capacity >= 180 THEN 'Standard aircraft'
        ELSE 'Small aircraft'
    END AS aircraft_size_category,
    f.origin_country
FROM flights AS f
WHERE f.flight_number LIKE '%21%';
