# Unit 4 Finding: Booking Cancellations by Flight

## The headline
Across 200 bookings, 34 were cancelled, an overall
cancellation rate of 17%. This is the baseline against which each flight is judged.

## How it varies across flights
Looking only at flights with at least 16 bookings (enough for a rate to be meaningful),
the typical flight cancels about 15.2% of its bookings. 
Flights with fewer than 16 bookings were left out, because a single cancellation
on a flight with 4 bookings looks like a 25% rate but says almost nothing.

## Flights I would investigate
| Flight Number | Bookings | Cancelled | Cancel Rate | Why it stands out |
|---|---|---|---|---|
| VN204 | 6 | 6 | 33.3% | Highest rate among high-volume flights, 16.3 points above baseline |
| VN211 | 16 | 5 | 31.3% | High cancel rate with very large volume, so most lost bookings |

## What I would do next
Check the cancellation reasons recorded for these flights, and whether the
cancellations cluster in a particular month or booking country. This summary
shows where the problem is, not why it happens.

## Reflection
Conditional aggregation computes several answers in a single pass over the data. With COUNT(*) and SUM(CASE WHEN ... THEN 1 ELSE 0 END) in the same SELECT, the database reads each row once and updates both totals as it goes. The alternative is two filtered queries: one counting all bookings and one counting cancelled bookings with a WHERE. Each query scans the table separately, so the work roughly doubles. A filtered query also loses the denominator, so a rate needs a second query regardless.

At a million rows, the difference matters in three ways. First, cost: two full scans take about twice the time and I/O, and that grows with every extra metric. Conditional aggregation adds a metric for almost nothing. Second, consistency: if bookings are inserted or cancelled between the two queries, the numerator and denominator come from different moments, and the rate can be slightly wrong. One pass guarantees both numbers describe the same snapshot. Third, maintainability: one query is easier to check than two that must be kept in sync. On a small table none of this is noticeable, but at scale a single pass is faster, cheaper, and more trustworthy.