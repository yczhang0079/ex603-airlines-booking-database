-- which actors were involved in the disputed events — and express it three ways.

-- subquery using IN or NOT IN.
SELECT
    p.passenger_id,
    p.passenger_name
FROM passengers AS p
WHERE p.passenger_id IN (
    SELECT b.passenger_id
    FROM bookings AS b
    WHERE b.cancellation_reason IS NOT NULL
);

-- Common Table Expression using WITH
WITH disputed_passengers AS (
    SELECT DISTINCT b.passenger_id
    FROM bookings AS b
    WHERE b.cancellation_reason IS NOT NULL
)
SELECT
    p.passenger_id,
    p.passenger_name
FROM passengers AS p
JOIN disputed_passengers AS d
    ON p.passenger_id = d.passenger_id;

-- Third distinct rewrite — EXISTS (set‑based)
SELECT
    p.passenger_id,
    p.passenger_name
FROM passengers AS p
WHERE EXISTS (
    SELECT 1
    FROM bookings AS b
    WHERE b.passenger_id = p.passenger_id
      AND b.cancellation_reason IS NOT NULL
);

-- Demonstrating that all three return identical rows
-- IN vs CTE
-- If this returns zero rows, the two result sets match exactly.
(
    SELECT p.passenger_id, p.passenger_name
    FROM passengers AS p
    WHERE p.passenger_id IN (
        SELECT b.passenger_id
        FROM bookings AS b
        WHERE b.cancellation_reason IS NOT NULL
    )
)
EXCEPT
(
    WITH disputed_passengers AS (
        SELECT DISTINCT b.passenger_id
        FROM bookings AS b
        WHERE b.cancellation_reason IS NOT NULL
    )
    SELECT p.passenger_id, p.passenger_name
    FROM passengers AS p
    JOIN disputed_passengers AS d
        ON p.passenger_id = d.passenger_id
);

-- CTE vs EXISTS
-- If this returns zero rows, the two result sets match exactly.
(
    SELECT p.passenger_id, p.passenger_name
    FROM passengers AS p
    WHERE EXISTS (
        SELECT 1
        FROM bookings AS b
        WHERE b.passenger_id = p.passenger_id
          AND b.cancellation_reason IS NOT NULL
    )
)
EXCEPT
(
    SELECT p.passenger_id, p.passenger_name
    FROM passengers AS p
    WHERE p.passenger_id IN (
        SELECT b.passenger_id
        FROM bookings AS b
        WHERE b.cancellation_reason IS NOT NULL
    )
);

-- EXISTS vs IN
-- If this returns zero rows, the two result sets match exactly.
(
    SELECT p.passenger_id, p.passenger_name
    FROM passengers AS p
    WHERE EXISTS (
        SELECT 1
        FROM bookings AS b
        WHERE b.passenger_id = p.passenger_id
          AND b.cancellation_reason IS NOT NULL
    )
)
EXCEPT
(
    SELECT p.passenger_id, p.passenger_name
    FROM passengers AS p
    WHERE p.passenger_id IN (
        SELECT b.passenger_id
        FROM bookings AS b
        WHERE b.cancellation_reason IS NOT NULL
    )
);


-- One input condition under which the three would NOT be equivalent
-- NULLs inside the subquery
-- If b.passenger_id can be NULL, 
-- then IN (SELECT passenger_id …) fails, because IN with NULLs produces unknown, not true

-- EXISTS still works

-- CTE works if filtered out NULLs


