1.Passengers (Actor)
passenger_id: INTEGER, 
passenger_name: VARCHAR(100)

Primary Key: passenger_id


2.Flights (Producer)
flight_id: INTEGER, 
flight_number: VARCHAR(10), 
is_active: BOOLEAN
base_fair: DECIMAL(10,2)

Primary Key: flight_id

3.Bookings (Event)
booking_id: INTEGER, 
passenger_id: INTEGER, 
flight_id: INTEGER, 
booking_timestamp: DATETIME, 
fare_paid: DECIMAL(10,2)

Primary Key: booking_id
Foreign Keys: passenger_id → Passengers, flight_id → Flights


4.Airports (Catalog)
airport_code: CHAR(3)
airport_name: VARCHAR(100)

Primary Key: airport_code


5.Flight_routes (Junction)
flight_id: INTEGER, 
airport_code: CHAR(3)
sequence_number: INTEGER

Primary Key: composite — (flight_id, sequence_number)
Foreign Keys: airport_code → Airports
