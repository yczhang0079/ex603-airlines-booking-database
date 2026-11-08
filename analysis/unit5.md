* What feature or report on your platform could use the three-table join from Question 1? What information would it display?
This report would help administrators answer questions such as:
Which passengers booked which flights?
When were bookings made?
Which flights are receiving the most booking activity?
Are certain flights or routes more popular than others?
From a business perspective, the data is useful for operational monitoring, customer service, and booking trend analysis.

* Why is the junction table important for answering Question 2? What would make this analysis more difficult without it?
The junction table is important because it links flights to airports. This lets you see whether the top-performing flights share the same airport tags or associations.
Without the junction table, there would be no easy way to connect flights and airports, making it much harder to analyze shared characteristics and spot patterns among successful flights.

* Which producers were excluded by the inner join? Report their identifiers.
Flight id | Flight number
15	"VN215"
14	"VN214"

* What does it mean when a producer has no events? What are some possible explanations?
A producer with no events means there are no records in the events table associated with that producer's producer_id. In other words, the producer exists in the producers table but has never been linked to an event.
Some possible explanations include:
The producer is newly added to the system and has not yet organized any events.
The producer previously had events, but those event records were removed or archived.
Event data has not been entered yet due to delays or data-entry issues.
The producer is inactive and no longer hosts events.

* How could a report based only on an inner join give leadership an incomplete picture of the platform?
A report based only on an INNER JOIN would exclude producers who have no events, causing leadership to see only active producers. This could create the false impression that all producers are successfully hosting events and that platform engagement is higher than it actually is. As a result, leadership might overlook inactive or newly registered producers, miss opportunities for outreach or support, and make decisions based on incomplete information about overall platform participation.

* Why might leadership want to identify producers who have never been active?
Leadership may want to identify producers who have never been active because these producers may need additional support, training, or outreach to become engaged on the platform. Tracking inactive producers can help measure user adoption, identify barriers preventing participation, and improve retention strategies. It also ensures that leadership has an accurate understanding of platform activity rather than assuming all registered producers are contributing events.

* What action could leadership take based on these findings?
Based on these findings, leadership could reach out to inactive producers to understand why they have not created any events and offer assistance, training, or incentives to encourage participation. They could also use this information to improve onboarding processes, identify potential data quality issues, and develop engagement strategies that increase overall activity and event creation on the platform.

* Distinguish between what your data shows and what would require further investigation. For example, a producer with no events may be inactive, but the data alone may not explain why.
The data shows only that certain producers have no matching records in the events table, meaning they have not been associated with any recorded events. However, the data does not explain the reason. A producer with no events might be inactive, newly registered, experiencing onboarding issues, or affected by missing or incomplete data. Determining the actual cause would require further investigation, such as reviewing account activity, contacting the producer, or examining additional business and operational data.

* Give an example of when a Cartesian product could be useful on your platform, or explain why you would not need one.
A Cartesian product could be useful for generating all possible passenger-flight combinations when testing a booking system or validating recommendation logic. However, in normal operations, it is rarely needed because it creates every possible combination of rows, which can produce very large result sets. Most business queries require matching related records through joins rather than combining every row from two tables.

* Which join algorithms did PostgreSQL choose for your query?
PostgreSQL selected two join algorithms: a Hash Join and a Nested Loop. The Hash Join was used to join the bookings and passengers tables using passenger_id. The resulting rows were then joined to the flights table using a Nested Loop. The Nested Loop was supported by a Memoize node and an Index Scan on flights_pkey, improving lookup efficiency.

* What information in the execution plan helps explain those choices?
The execution plan shows sequential scans on bookings (200 rows) and passengers (30 rows), making a Hash Join efficient because both tables are small. The plan also shows an Index Scan on flights_pkey and Memoize statistics with 187 cache hits and only 13 misses. These details indicate that PostgreSQL expected repeated flight lookups and chose a Nested Loop with caching for fast indexed access.

* Why is it useful to understand the selected join algorithms?
Understanding join algorithms helps identify performance bottlenecks and explains why a query performs well or poorly. For example, the Hash Join is efficient for the small bookings and passengers tables, while the Nested Loop benefits from indexed access to flights. Knowing this allows developers to predict how performance may change as data grows and whether indexes or query rewrites may be needed.

* What changes to the data or database might make another join algorithm more appropriate?
If the tables grew significantly, PostgreSQL might choose a different algorithm. For example, much larger tables could make a Merge Join attractive if indexes existed on the join columns and the data was already sorted. A much larger number of distinct flight ids could also reduce the effectiveness of Memoize. Changes in row counts, data distribution, indexes, or available memory can all influence PostgreSQL's join selection.

* Reflection
PostgreSQL chose a Hash Join between the bookings and passengers tables and a Nested Loop join when accessing the flights table through its primary-key index. However, changes to the data or database schema could cause PostgreSQL to select different join algorithms.
One important factor is table size. The execution plan showed only 200 booking records and 30 passenger records, making a Hash Join efficient. If these tables grew to hundreds of thousands or millions of rows, PostgreSQL might choose a Merge Join, especially if the data was already sorted or indexed on the join columns.
Indexes also influence join selection. Adding indexes on frequently joined columns can make indexed lookups cheaper and encourage the use of Nested Loop joins. Conversely, if indexes are removed, PostgreSQL may rely more heavily on Hash Joins or Sequential Scans.
The number of matching records is another factor. If a join returns many rows, a Hash Join may become more expensive because larger hash tables require additional memory. PostgreSQL may then consider other strategies depending on available resources.
Understanding these factors is important because the best join algorithm depends on the current data distribution. As a database grows, query plans that perform well today may become less efficient, making indexing and performance monitoring essential for maintaining good query performance.