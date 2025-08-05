-- Aggregation: Total number of bookings made by each user
SELECT u.user_id, u.first_name, u.last_name, COUNT(b.booking_id) AS total_bookings
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;

-- Window ranking of properties by total bookings, showing both RANK() and ROW_NUMBER()
WITH property_counts AS (
    SELECT 
        p.property_id,
        p.name,
        COUNT(b.booking_id) AS total_bookings
    FROM Property p
    LEFT JOIN Booking b ON b.property_id = p.property_id
    GROUP BY p.property_id, p.name
)
SELECT
    property_id,
    name,
    total_bookings,
    RANK()       OVER (ORDER BY total_bookings DESC) AS booking_rank,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS booking_row_number
FROM property_counts
ORDER BY booking_rank, name;
