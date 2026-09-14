
1. Passengers
PRIMARY KEY is passenger_id: Uniquely identifies each passenger row; required by the actor role definition.
NOT NULL for passenger_name: Every passenger record must have a display name. An actor with no name is not a usable record.
No foreign keys for the root actor table.

2. Flights
PRIMARY KEY	is flight_id: Uniquely identifies each flight.
NOT NULL for flight_number: A flight must have a display identifier (e.g. "AA123") for it to be searched and booked.
UNIQUE for flight_number: Prevents two different flight records from sharing the same customer-facing flight number, which would create ambiguity in bookings and reporting.
NOT NULL, DEFAULT for is_active: Flights shouldn't be in an undefined state. Default to TRUE on creation.
CHECK for base_fare >= 0: A fare can't be negative. It protects the numeric filter attribute from bad data that would corrupt price-range searches.
No foreign keys for the producer table.

3. Bookings
PRIMARY KEY	is booking_id:	A primary key is needed because the same passenger can book the same flight more than once (ie. round-trip, rebooking)
NOT NULL for passenger_id: Every event must be tied to an actor; A booking with no passenger is meaningless.
NOT NULL for flight_id: Every booking must reference the flight being booked.
FOREIGN KEY passenger_id → Passengers.passenger_id : A booking can't reference a passenger who doesn't exist.
ON DELETE RESTRICT	(on passenger_id): Bookings are historical records. If a passenger account is deleted, silently deleting their booking history destroys revenue and audit data. 
FOREIGN KEY	flight_id → Flights.flight_id: A booking can't reference a flight that doesn't exist.
ON DELETE RESTRICT	(on flight_id):	Historical records should not be removed.
NOT NULL for booking_timestamp: Required for time-based aggregation.
CHECK fare_paid >= 0: This is to make sure aggregations to be meaningful.

4. Airports
PRIMARY KEY	is airport_code:  The natural key (IATA code) is already unique and meaningful.
NOT NULL for airport_name: Every catalog entry needs a readable label for display purposes.
CHECK for LENGTH(airport_code) = 3: IATA codes are fixed at 3 characters and this catches data-entry errors at the constraint level rather than downstream.
No foreign keys for catalog table.

5. Flight_routes
NOT NULL for flight_id: Every route row must belong to a flight.
NOT NULL for airport_code: Every route row must reference an airport.
NOT NULL for sequence_number: The stop order must always be known. It indicates whether it is currently in the origin, layover or destination.
CHECK	sequence_number >= 1 : Sequence numbers represent stop order starting from the first airport.
PRIMARY KEY	is (flight_id, sequence_number): This is the natural composite key: for a given flight, each position in the route can only be filled once.
UNIQUE for (flight_id, airport_code, sequence_number): A given airport shouldn't appear twice at the same sequence position for the same flight.
FOREIGN KEY	flight_id → Flights.flight_id:	Ensures every route row references a flight that actually exists — prevents orphaned routes pointing at non-existent flights.
ON DELETE CASCADE	(on flight_id):	If a flight is deleted, its route rows should be removed automatically.
FOREIGN KEY	airport_code → Airports.airport_code:	Ensures every route row references an airport that actually exists in the catalog.
ON DELETE RESTRICT	(on airport_code):	Deleting an airport should never be allowed to silently cascade and wipe out route data for potentially many unrelated flights; RESTRICT forces someone to reassign or remove those routes first, protecting data across the whole system.