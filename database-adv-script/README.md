INNER JOIN – Bookings with Users
Returns only records where a booking is linked to a user.

LEFT JOIN – Properties with Reviews
Returns all properties, including those without reviews.

FULL OUTER JOIN – Users and Bookings
Returns all users and all bookings, even when there’s no match between them.

Non-Correlated Subquery – This query retrieves all properties that have an average review rating greater than 4.0. The subquery calculates the average rating for each property and returns those meeting the condition, without depending on the outer query.

Correlated Subquery – This query retrieves all users who have made more than three bookings. The subquery is executed for each user in the outer query, counting their individual bookings and returning only those meeting the threshold.