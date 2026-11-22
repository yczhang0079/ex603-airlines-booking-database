## 6.1
## Write a question that needs each row shown next to its group’s average. Explain why the group average alone (GROUP BY) cannot answer it.
Question: Which bookings paid more than the average fare for their flight?
To answer this, each booking must be displayed alongside the average fare of its flight, but after GROUP BY, the original bookings are collapsed into a single row per flight, you cannot determine which specific bookings were above or below their flight's average fare.

## Ranking is never neutral: someone is being ordered, and tie handling decides who counts as equal. 
## Name a platform feature that would use your ranking, and explain which of the three functions it should use and why.
A useful platform feature would be a "Top Flights Leaderboard" that highlights the most-booked flights on the airline platform.
For this feature, I would use RANK().
RANK() is appropriate because flights with the same number of bookings should be considered equally successful. For example, if VN205 and VN207 both have 18 bookings, they should share the same rank rather than one being arbitrarily placed above the other. This is fairer than ROW_NUMBER(), which would force one flight to appear higher even though their performance is identical.



## 6.2
## What would a large delta tell someone about your platform, and what should they do about it?
A large delta (fare_paid - previous_fare) indicates a significant change between consecutive bookings for the same flight. This could suggest a fare increase, a promotion ending, a surge in demand, a cancellation, or unusual booking behavior. Leadership should investigate the cause by reviewing pricing policies, flight demand, booking status, and any operational events occurring around the same time. A large delta is a signal that something changed, but additional analysis is needed to determine why.

## Why does a running total answer a question that a plain SUM cannot?
A plain SUM(fare_paid) gives only the final total revenue. A running total provides progress over time, not just the final outcome.

## Why did you pick your moving-average window size? A different size tells a different story.
I used a 7-row moving average because it smooths short-term fluctuations while still showing recent trends. A smaller window (such as 3 rows) would react quickly to individual bookings and appear more volatile. A larger window (such as 14 rows) would smooth the data more heavily and could hide recent changes in booking activity.

## What does a gap mean in your platform: a data quality problem, a real stop in activity, or a side effect of how events were recorded? Each needs a different response. Say which one yours is and how you know.
In this airline booking platform, a gap means there was a period during which a flight received no recorded bookings. Based on the available data alone, I cannot determine whether the gap represents a real pause in customer activity, a data-quality issue, or a side effect of how bookings were recorded. The booking records only show that no events occurred during that period. Determining the cause would require additional evidence, such as flight schedules, operational logs, or data-ingestion records. Therefore, the query identifies the gap, but the reason for the gap requires further investigation.



# 6.3
# Name the feature in your platform that top-N would power. Explain why three is the right number, rather than one or ten.
A top-N query could power a "Top 3 Highest-Revenue Bookings per Flight" feature for airline managers. This feature would help identify the bookings generating the most revenue for each flight and highlight patterns such high-demand periods.
Three is a good choice because it provides enough examples to reveal patterns without overwhelming the user. Showing only one booking could make an unusual outlier appear more important than it really is, while showing ten bookings would make the leaderboard less focused and harder to review quickly. A top three list balances visibility and simplicity, making it easier for managers to compare flights and identify high-value bookings.

# What would a large month-over-month change mean in your domain, and what should someone do about it?
In an airline booking platform, a large month-over-month change in revenue or booking activity could indicate a significant shift in demand, pricing, flight availability, promotions, or operational disruptions. For example, a sharp increase might result from successful marketing campaigns or seasonal travel demand, while a sharp decrease could signal flight cancellations, lower demand, or customer retention problems.
Someone should investigate the cause rather than simply reporting the number. If revenue rises, management should identify the factors driving growth and consider expanding those efforts. If revenue falls, they should determine whether the decline is due to operational issues, pricing decisions, competitive pressures, or data-quality problems. The metric is useful only if it leads to actions that improve performance or address emerging risks.


# Reflection
# Window functions keep rows; aggregates collapse them. 
# Describe a reporting question in your theme that is easy with a window function but awkward or impossible with GROUP BY alone. Explain why.
A reporting question in this airline platform that is easy with a window function is:Which bookings paid more than the average fare for their flight?
Because it keeps every booking row while also showing the average fare for that flight.
From this result, we can immediately compare each booking's fare_paid to its flight's average fare and identify above-average or below-average bookings.
A GROUP BY query is awkward because it collapses all bookings for a flight into a single row.
As a result, you can no longer see which specific bookings were above or below the average without performing additional joins back to the original table.
Therefore, the window function is the better choice because it combines detailed booking data and flight-level summary statistics in the same result set, while GROUP BY only provides the summary and loses the booking-level context.