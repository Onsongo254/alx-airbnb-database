INNER JOIN – Bookings with Users
Returns only records where a booking is linked to a user.

LEFT JOIN – Properties with Reviews
Returns all properties, including those without reviews.

FULL OUTER JOIN – Users and Bookings
Returns all users and all bookings, even when there’s no match between them.

Non-Correlated Subquery – This query retrieves all properties that have an average review rating greater than 4.0. The subquery calculates the average rating for each property and returns those meeting the condition, without depending on the outer query.

Correlated Subquery – This query retrieves all users who have made more than three bookings. The subquery is executed for each user in the outer query, counting their individual bookings and returning only those meeting the threshold.

Aggregation Query – This query calculates the total number of bookings made by each user. It uses COUNT with GROUP BY to group results per user and orders them by booking count in descending order.

Window Function Query – This query ranks properties based on how many bookings they have received. It uses RANK() as a window function over the aggregated booking counts to assign rankings.