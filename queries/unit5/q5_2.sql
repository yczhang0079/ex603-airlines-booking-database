-- Task 5.2: Find Records That Joins May Exclude

-- Part A: Compare INNER JOIN and LEFT JOIN
-- Write two queries to compare the results of an inner join and a left join.

-- Use LEFT JOIN to return all producers, including those who have never had an event.
-- Write an equivalent query using INNER JOIN.
-- Compare the results and determine how many producers are excluded by the inner join.
-- Explain which producers are missing and why.
-- Your results must include a count of the producers excluded by the inner join.
-- Hint: When counting producers, 
-- use their unique identifiers so that producers with multiple events are not counted more than once.
-- Query 1: LEFT JOIN (returns all flights)
SELECT DISTINCT
    f.flight_id,
    f.flight_number
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id
ORDER BY f.flight_id;
-- Result: 15 unique flights
-- Query 2: INNER JOIN (returns only flights with bookings)
SELECT DISTINCT
    f.flight_id,
    f.flight_number
FROM flights f
INNER JOIN bookings b
    ON f.flight_id = b.flight_id
ORDER BY f.flight_id;
-- Result: 13 unique flights
-- The LEFT JOIN returned 15 unique flights, while the INNER JOIN returned 13 unique flights. 
-- This means that 2 flights were excluded by the INNER JOIN. 
-- The missing flights are those that do not have any matching records in the bookings table. 
-- A LEFT JOIN includes all flights regardless of whether they have bookings, 
-- whereas an INNER JOIN only returns flights with at least one associated booking. 
-- Therefore, the 2 excluded flights are flights that have never been booked, 
-- causing them to appear in the LEFT JOIN results but not in the INNER JOIN results.


-- Part B: Explore RIGHT JOIN and FULL OUTER JOIN
-- Next, examine the same relationship using two additional join types.
-- Write a RIGHT JOIN that returns the same records as your LEFT JOIN from Part A.
SELECT DISTINCT
    f.flight_id,
    f.flight_number
FROM bookings b
RIGHT JOIN flights f
    ON b.flight_id = f.flight_id
ORDER BY f.flight_id;
-- Result: 15 unique flights
-- Compare the results to confirm that they match.
-- Write a FULL OUTER JOIN that includes matching and unmatched records from both tables.
SELECT DISTINCT
    f.flight_id,
    f.flight_number
FROM flights f
FULL OUTER JOIN bookings b
    ON f.flight_id = b.flight_id
ORDER BY f.flight_id;
-- Result: 15 unique flights

-- Explain what a full outer join can reveal that a left join or right join alone may not show.
-- Be sure to verify your results rather than assuming the queries are equivalent.

-- A FULL OUTER JOIN shows both situations at once: flights without bookings and bookings without matching flights.
-- This makes a FULL OUTER JOIN especially useful for identifying data integrity issues, 
-- such as orphaned bookings that reference nonexistent flights, while also showing flights that have never been booked. 
-- It provides the most complete view of how the two tables relate by highlighting all matches 
-- and all mismatches in a single query.


-- Part C: Find Producers with No Events Using Two Approaches
-- Write two queries that identify producers who have never had an event and compare them.

-- ✓  NOT EXISTS.
SELECT f.flight_id,
       f.flight_number
FROM flights f
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.flight_id = f.flight_id
);

-- ✓  EXCEPT.
SELECT flight_id,
       flight_number
FROM flights

EXCEPT

SELECT
    f.flight_id,
    f.flight_number
FROM flights f
JOIN bookings b
    ON f.flight_id = b.flight_id;

-- Run both queries and compare their results.
--Results match.

-- In one or two sentences, explain how the approaches differ and confirm whether they identify the same producers.
-- Both queries return producers who have never had an event. 
-- The NOT EXISTS approach checks each producer individually and returns those without a matching event, 
-- while the EXCEPT approach returns all producers and then removes those who appear in the events table. 
-- When run on the same data, both queries should identify the same set of producers, 
-- assuming producer_id uniquely identifies each producer.
