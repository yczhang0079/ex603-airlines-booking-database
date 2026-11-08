-- Task 5.1: Connect Producers to Their Data
-- Your first task is to connect information from different tables so leadership can better understand the producers identified in Assignment 4.

-- Who are the people behind the events? Write a query that joins three tables to display the actor who performed each event, the producer associated with the event, and the event's date and time.
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



-- Do the producers identified in Assignment 4 share certain catalog credentials or tags? Write a query that connects the producer table to the catalog table through the junction table. Return the producers associated with your theme's catalog tag.
-- VN204  Highest rate among high-volume flights
SELECT
    f.flight_id,
    f.flight_number,
    a.airport_id,
    a.iata_code,
    a.airport_name
FROM flights f
JOIN flight_routes fr
    ON f.flight_id = fr.flight_id
JOIN airports a
    ON fr.airport_id = a.airport_id
WHERE f.flight_number = 'VN204'
ORDER BY a.iata_code, f.flight_number;


-- How do the producers compare with one another? Write a self join to compare records within the producer table. Use the results to explore whether the producers identified in Assignment 4 share characteristics with other producers or whether differences in activity levels may explain their performance.
SELECT
    f1.origin_country,
    f1.flight_number AS flight_1,
	f1.seat_capacity,
	f1.is_active,
    f2.flight_number AS flight_2,
	f2.seat_capacity,
	f2.is_active
FROM flights f1
JOIN flights f2
    ON f1.origin_country = f2.origin_country
    AND f1.flight_id < f2.flight_id
ORDER BY f1.origin_country, f1.flight_number, f2.flight_number;