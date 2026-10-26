**4.1**
**Who acts on it:** the revenue manager who sets prices and seat allocation for each flight.

**What the aggregate hides:**
- **The average hides the spread.** An average fare of 220 could mean everyone paid about 220, or half paid 100 and half paid 340. Free fares (`fare_paid = 0`) or a few high-multiplier bookings can also skew it.
- **The count hides who is counted.** It includes cancelled bookings, repeat bookers (200 bookings could be 20 people), and says nothing about capacity (200 bookings fills a 200-seat plane but not a 400-seat one).

**What I'd need to see next:**
- The **median and min/max fare** per flight, to see the spread.
- **Active bookings** compared to `seat_capacity`.
- **Distinct passengers** versus total bookings.
- The same breakdown **by time range**, to see if a flight is rising or declining.


**4.2**
**Part A, state the two questions your conditional aggregation answers side by side.**
- How busy is each flight? COUNT(*) gives total bookings per flight.
- How often do its bookings fail? SUM(CASE WHEN booking_status = 'cancelled' THEN 1 ELSE 0 END) gives cancelled bookings per flight.

**Part B, name the reader who needs subtotals rather than detail rows, and say what decision the grand total supports that the group rows do not.**
- The regional director needs subtotals rather than detail rows. They are accountable for each region as a whole, not for individual flights or status combinations, so a table of every row would bury the comparison they need. One row per region lets them see which regions are carrying revenue and bookings.

**Part C, state the question the pipeline answers.**
- What does normal performance look like for high-volume flights?