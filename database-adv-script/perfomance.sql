-- ============================================================================
-- COMPLEX QUERY: Initial Version (Before Optimization)
-- ============================================================================

-- Initial complex query that retrieves all bookings with user, property, and payment details
-- This query demonstrates common inefficiencies that need optimization

EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at as booking_created,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role as user_role,
    
    -- Property details
    p.property_id,
    p.name as property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at as property_created,
    
    -- Host details
    h.user_id as host_id,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    h.email as host_email,
    
    -- Payment details
    pay.payment_id,
    pay.amount as payment_amount,
    pay.payment_date,
    pay.payment_method,
    
    -- Review details (if exists)
    r.review_id,
    r.rating,
    r.comment as review_comment,
    r.created_at as review_created,
    
    -- Calculated fields
    (b.end_date - b.start_date) as nights_booked,
    CASE 
        WHEN b.status = 'confirmed' THEN 'Active'
        WHEN b.status = 'pending' THEN 'Awaiting Confirmation'
        WHEN b.status = 'canceled' THEN 'Cancelled'
        ELSE 'Unknown'
    END as status_description,
    
    -- Aggregated payment info
    COALESCE(SUM(pay.amount) OVER (PARTITION BY b.booking_id), 0) as total_paid,
    
    -- Property rating average
    AVG(r.rating) OVER (PARTITION BY p.property_id) as property_avg_rating,
    COUNT(r.review_id) OVER (PARTITION BY p.property_id) as property_review_count
    
FROM bookings b
-- Join with users (guests)
LEFT JOIN users u ON b.user_id = u.user_id
-- Join with properties
LEFT JOIN properties p ON b.property_id = p.property_id
-- Join with users again for host information
LEFT JOIN users h ON p.host_id = h.user_id
-- Join with payments
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
-- Join with reviews
LEFT JOIN reviews r ON b.property_id = r.property_id AND b.user_id = r.user_id
-- Additional joins for more data
LEFT JOIN (
    SELECT 
        property_id,
        COUNT(*) as total_bookings,
        AVG(total_price) as avg_booking_price
    FROM bookings 
    WHERE status = 'confirmed'
    GROUP BY property_id
) prop_stats ON p.property_id = prop_stats.property_id
LEFT JOIN (
    SELECT 
        user_id,
        COUNT(*) as user_total_bookings,
        SUM(total_price) as user_total_spent
    FROM bookings 
    GROUP BY user_id
) user_stats ON u.user_id = user_stats.user_id

WHERE b.created_at >= '2024-01-01'
ORDER BY b.created_at DESC, u.last_name, p.name;

-- ============================================================================
-- PERFORMANCE ANALYSIS OF INITIAL QUERY
-- ============================================================================

-- Issues identified:
-- 1. Multiple LEFT JOINs causing cartesian products
-- 2. Window functions on large datasets
-- 3. Subqueries in JOINs without proper indexing
-- 4. Complex WHERE clause without index optimization
-- 5. ORDER BY on multiple columns without composite index
-- 6. Redundant data retrieval

-- ============================================================================
-- OPTIMIZED QUERY: Refactored Version
-- ============================================================================

-- Step 1: Create supporting indexes for optimization
CREATE INDEX IF NOT EXISTS idx_bookings_created_at_status ON bookings(created_at, status);
CREATE INDEX IF NOT EXISTS idx_bookings_user_property ON bookings(user_id, property_id);
CREATE INDEX IF NOT EXISTS idx_properties_host_location ON properties(host_id, location);
CREATE INDEX IF NOT EXISTS idx_payments_booking_amount ON payments(booking_id, amount);
CREATE INDEX IF NOT EXISTS idx_reviews_property_user ON reviews(property_id, user_id);
CREATE INDEX IF NOT EXISTS idx_users_name_email ON users(last_name, first_name, email);

-- Step 2: Optimized query with better structure
EXPLAIN ANALYZE
WITH booking_base AS (
    -- Base booking data with essential joins only
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        b.created_at,
        b.user_id,
        b.property_id,
        (b.end_date - b.start_date) as nights_booked
    FROM bookings b
    WHERE b.created_at >= '2024-01-01'
),
user_data AS (
    -- Pre-aggregated user information
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.role,
        COUNT(b.booking_id) as user_total_bookings,
        SUM(b.total_price) as user_total_spent
    FROM users u
    LEFT JOIN bookings b ON u.user_id = b.user_id
    GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
),
property_data AS (
    -- Pre-aggregated property information
    SELECT 
        p.property_id,
        p.name,
        p.description,
        p.location,
        p.pricepernight,
        p.created_at,
        p.host_id,
        h.first_name as host_first_name,
        h.last_name as host_last_name,
        h.email as host_email,
        AVG(r.rating) as property_avg_rating,
        COUNT(r.review_id) as property_review_count,
        COUNT(b.booking_id) as property_total_bookings
    FROM properties p
    LEFT JOIN users h ON p.host_id = h.user_id
    LEFT JOIN reviews r ON p.property_id = r.property_id
    LEFT JOIN bookings b ON p.property_id = b.property_id AND b.status = 'confirmed'
    GROUP BY p.property_id, p.name, p.description, p.location, p.pricepernight, 
             p.created_at, p.host_id, h.first_name, h.last_name, h.email
),
payment_data AS (
    -- Pre-aggregated payment information
    SELECT 
        booking_id,
        SUM(amount) as total_paid,
        COUNT(*) as payment_count,
        MAX(payment_date) as last_payment_date
    FROM payments
    GROUP BY booking_id
),
review_data AS (
    -- Pre-aggregated review information for specific booking
    SELECT 
        property_id,
        user_id,
        review_id,
        rating,
        comment,
        created_at
    FROM reviews
    WHERE created_at IS NOT NULL
)
SELECT 
    bb.booking_id,
    bb.start_date,
    bb.end_date,
    bb.total_price,
    bb.status,
    bb.created_at as booking_created,
    bb.nights_booked,
    
    -- User details (from pre-aggregated data)
    ud.user_id,
    ud.first_name,
    ud.last_name,
    ud.email,
    ud.role as user_role,
    ud.user_total_bookings,
    ud.user_total_spent,
    
    -- Property details (from pre-aggregated data)
    pd.property_id,
    pd.name as property_name,
    pd.description,
    pd.location,
    pd.pricepernight,
    pd.created_at as property_created,
    pd.property_avg_rating,
    pd.property_review_count,
    pd.property_total_bookings,
    
    -- Host details
    pd.host_id,
    pd.host_first_name,
    pd.host_last_name,
    pd.host_email,
    
    -- Payment details (from pre-aggregated data)
    COALESCE(payd.total_paid, 0) as total_paid,
    payd.payment_count,
    payd.last_payment_date,
    
    -- Review details (if exists for this specific booking)
    rd.review_id,
    rd.rating,
    rd.comment as review_comment,
    rd.created_at as review_created,
    
    -- Status description
    CASE 
        WHEN bb.status = 'confirmed' THEN 'Active'
        WHEN bb.status = 'pending' THEN 'Awaiting Confirmation'
        WHEN bb.status = 'canceled' THEN 'Cancelled'
        ELSE 'Unknown'
    END as status_description
    
FROM booking_base bb
INNER JOIN user_data ud ON bb.user_id = ud.user_id
INNER JOIN property_data pd ON bb.property_id = pd.property_id
LEFT JOIN payment_data payd ON bb.booking_id = payd.booking_id
LEFT JOIN review_data rd ON bb.property_id = rd.property_id AND bb.user_id = rd.user_id

ORDER BY bb.created_at DESC, ud.last_name, pd.name;

-- ============================================================================
-- PERFORMANCE COMPARISON ANALYSIS
-- ============================================================================

-- Query 1: Check index usage for optimized query
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Query 2: Compare execution times
-- Note: The EXPLAIN ANALYZE output above shows the performance difference

-- Query 3: Check for any remaining performance bottlenecks
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
WHERE query LIKE '%bookings%'
ORDER BY total_time DESC
LIMIT 10; 