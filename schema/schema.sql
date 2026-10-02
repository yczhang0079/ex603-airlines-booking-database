-- =================================================================
-- EX 603 Assignment 2 - schema.sql
-- Theme: Airline flight booking
-- Author: Yicheng
-- Target: PostgreSQL 14+
-- =================================================================
-- Reset. Reverse creation order, so no dependency blocks a drop.

DROP TABLE IF EXISTS flight_routes CASCADE;
DROP TABLE IF EXISTS bookings      CASCADE;
DROP TABLE IF EXISTS airports      CASCADE;
DROP TABLE IF EXISTS flights       CASCADE;
DROP TABLE IF EXISTS passengers    CASCADE;

-- ----------------------------------------------------------------
-- 1. passengers - first, because it references nothing.
-- ----------------------------------------------------------------
CREATE TABLE passengers (
    passenger_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    passenger_name VARCHAR(100) NOT NULL
);

-- ----------------------------------------------------------------
-- 2. flights - references nothing, so it can precede bookings and
--    flight_routes, which both point at it.
-- ----------------------------------------------------------------
CREATE TABLE flights (
    flight_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_number VARCHAR(10)   NOT NULL,
    base_fair     NUMERIC(10,2) NOT NULL,
    is_active     BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_flights_flight_number UNIQUE (flight_number),
    CONSTRAINT chk_flights_base_fair_nonneg CHECK (base_fair >= 0)
);

-- ----------------------------------------------------------------
-- 3. airports - references nothing. The IATA code is a natural key,
--    so there is no identity column.
-- ----------------------------------------------------------------
CREATE TABLE airports (
    airport_code VARCHAR(3)   PRIMARY KEY,
    airport_name VARCHAR(100) NOT NULL,
    CONSTRAINT chk_airports_code_format CHECK (airport_code ~ '^[A-Z]{3}$')
);

-- ----------------------------------------------------------------
-- 4. bookings - needs passengers and flights to exist first.
-- ----------------------------------------------------------------
CREATE TABLE bookings (
    booking_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    passenger_id      INTEGER       NOT NULL,
    flight_id         INTEGER       NOT NULL,
    booking_timestamp TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fare_paid         NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_bookings_passenger
        FOREIGN KEY (passenger_id) REFERENCES passengers (passenger_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_bookings_flight
        FOREIGN KEY (flight_id) REFERENCES flights (flight_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_bookings_fare_paid_nonneg CHECK (fare_paid >= 0)
);

-- ----------------------------------------------------------------
-- 5. flight_routes - last, because it needs flights and airports.
--    Resolves the M:N between flights and airports. The primary key
--    is (flight_id, sequence_number), so a flight can visit many
--    airports in order, and each stop number is used once per flight.
-- ----------------------------------------------------------------
CREATE TABLE flight_routes (
    flight_id       INTEGER    NOT NULL,
    sequence_number INTEGER    NOT NULL,
    airport_code    VARCHAR(3) NOT NULL,
    CONSTRAINT pk_flight_routes PRIMARY KEY (flight_id, sequence_number),
    CONSTRAINT fk_flight_routes_flight
        FOREIGN KEY (flight_id) REFERENCES flights (flight_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_flight_routes_airport
        FOREIGN KEY (airport_code) REFERENCES airports (airport_code)
        ON DELETE RESTRICT,
    CONSTRAINT chk_flight_routes_sequence_positive CHECK (sequence_number >= 1)
);