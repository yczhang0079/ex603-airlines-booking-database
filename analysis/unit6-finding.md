# Is the failure problem getting better or worse over the time your data covers? What should the team do next quarter? Support every claim with a query you ran.

To evaluate whether the platform is getting better or worse over time, I measured monthly revenue using the fare_paid metric. 
Revenue is a useful indicator because it reflects the financial outcome of all booking activity.

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', booked_at)::date AS month_start,
        SUM(fare_paid) AS revenue
    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)
),
month_comparison AS (
    SELECT
        month_start,
        revenue,
        LAG(revenue) OVER (ORDER BY month_start) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    month_start,
    revenue,
    previous_revenue,
    ROUND(
        100.0 * (revenue - previous_revenue)
        / NULLIF(previous_revenue, 0),
        2
    ) AS percent_change
FROM month_comparison
ORDER BY month_start;

If the later months generally have higher revenue than earlier months, say the platform's performance is improving.
If revenue trends downward, say performance is worsening.
If revenue fluctuates significantly, say the trend is mixed and requires additional investigation.

Next quarter, the team should focus on the flights and months that generated the highest revenue growth and investigate what drove that success. 
If certain flights consistently outperform others, marketing and operational resources can be concentrated on similar routes. 
The month-over-month revenue analysis should continue to be monitored because it measures whether improvements are translating into actual business results.