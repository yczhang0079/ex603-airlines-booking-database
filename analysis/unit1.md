## Modelling Justification

## Choosing primary keys. 
For Passengers, Flights, and Airports, I used single-column keys. Passengers and Flights get simple auto-generated IDs, while Airports uses its IATA code directly, since that code is already unique and easy to recognize — adding a separate ID would just be extra work for no benefit. Bookings uses its own ID rather than combining passenger and flight IDs together, because the same passenger really can book the same flight more than once - for a round trip, a rebooking, or booking a seat for someone else. So that pairing alone can't be trusted to stay unique. Flight_routes uses a combination of flight ID and sequence number, because what actually makes a route row unique isn't "this flight touches this airport" — it's "this is stop number 3 on this flight's journey." Building the key around position also means the table still works even if a flight happens to pass through the same airport twice.

## Deciding what happens on delete. 
I split these rules into two groups. When a row only exists because of its parent — like a route row that only makes sense next to its flight — I let it delete automatically along with that flight. There's no reason to keep a route entry pointing at a flight that no longer exists. Everywhere else, I blocked deletion instead. Bookings can't be deleted just because a passenger or flight is deleted, since bookings are financial records — losing that data by accident could mean losing revenue history. The better approach is to deactivate a flight or account, not erase it. The same logic applies to airports: they're shared across many flights, so deleting one shouldn't be allowed to wipe out routes for flights that have nothing to do with the reason it was deleted.

## What the schema should enforce vs. what the app should handle. 
I built simple, clear-cut rules into the database: fares can't be negative, every booking needs a timestamp, airport codes must be exactly three letters, flight numbers must be unique, and every reference between tables has to point to something real. These are cases where a wrong value is obviously wrong and expensive to catch later. I left more flexible, judgment-based rules to the app, including whether a passenger is allowed to hold overlapping bookings. Those rules are more related to changing business, they are not as straightforwad as question like "fare can't be negative".



## Reflection

One decision in this schema that a different designer could reasonably challenge is how I resolved `Flight_routes`: using a `sequence_number` column instead of a categorical `route_role` (origin/destination/layover) to distinguish airports on the same flight. A reasonable designer optimizing for query readability might prefer `route_role`, since `WHERE route_role = 'origin'` is more self-documenting than `WHERE sequence_number = 1`.

I chose `sequence_number` because it help to make the whole system more flexisble. When airline routes has more than two stops`sequence_number` scales to any number of stops without adding new categorical values. On the read side, if we query by `ORDER BY sequence_number` it will show the whole picture of the flight clearly.

The trade-off is that `sequence_number` is less readable at first glance and could have potential question like "which number is the origin?" 
For a platform that needs to support multi-leg itineraries and frequent route reconstruction, I judged that scalability and correct ordering outweighed that minor readability cost.