-- Database Indexes for AirBnB Clone with Performance Analysis
-- This file creates indexes and measures performance improvements using EXPLAIN ANALYZE

-- ============================================================================
-- PERFORMANCE ANALYSIS: BEFORE INDEXES
-- ============================================================================

-- Test 1: User authentication query performance
EXPLAIN ANALYZE SELECT user_id, first_name, last_name, role 
FROM users 
WHERE email = 'test@example.com';

-- Test 2: Property search by location and price
EXPLAIN ANALYZE SELECT property_id, name, location, pricepernight 
FROM properties 
WHERE location = 'Paris' AND pricepernight BETWEEN 100 AND 500;

-- Test 3: User booking history
EXPLAIN ANALYZE SELECT b.booking_id, b.start_date, b.end_date, b.status,
       p.name as property_name
FROM bookings b
JOIN properties p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY b.created_at DESC;

-- Test 4: Property availability check
EXPLAIN ANALYZE SELECT COUNT(*) 
FROM bookings 
WHERE property_id = '550e8400-e29b-41d4-a716-446655440001'
  AND start_date <= '2024-06-15' 
  AND end_date >= '2024-06-10'
  AND status = 'confirmed';

-- Test 5: Property reviews aggregation
EXPLAIN ANALYZE SELECT p.property_id, p.name, AVG(r.rating) as avg_rating, COUNT(r.review_id) as review_count
FROM properties p
LEFT JOIN reviews r ON p.property_id = r.property_id
WHERE p.location = 'Paris'
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) >= 4.0;

-- Test 6: Host properties listing
EXPLAIN ANALYZE SELECT p.property_id, p.name, p.location, p.pricepernight,
       COUNT(b.booking_id) as total_bookings
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
WHERE p.host_id = '550e8400-e29b-41d4-a716-446655440002'
GROUP BY p.property_id, p.name, p.location, p.pricepernight;

-- Test 7: Message conversation query
EXPLAIN ANALYZE SELECT message_id, sender_id, message_body, sent_at
FROM messages 
WHERE (sender_id = '550e8400-e29b-41d4-a716-446655440003' AND recipient_id = '550e8400-e29b-41d4-a716-446655440004')
   OR (sender_id = '550e8400-e29b-41d4-a716-446655440004' AND recipient_id = '550e8400-e29b-41d4-a716-446655440003')
ORDER BY sent_at DESC;

-- ============================================================================
-- CREATING ADDITIONAL INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- USER TABLE INDEXES
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_name_search ON users(first_name, last_name);

-- PROPERTY TABLE INDEXES
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_price ON properties(pricepernight);
CREATE INDEX idx_properties_created_at ON properties(created_at);
CREATE INDEX idx_properties_location_price ON properties(location, pricepernight);

-- BOOKING TABLE INDEXES
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
CREATE INDEX idx_bookings_user_status ON bookings(user_id, status);
CREATE INDEX idx_bookings_property_dates ON bookings(property_id, start_date, end_date);

-- PAYMENT TABLE INDEXES
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_payments_method ON payments(payment_method);
CREATE INDEX idx_payments_amount ON payments(amount);

-- REVIEW TABLE INDEXES
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_property_rating ON reviews(property_id, rating);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

-- MESSAGE TABLE INDEXES
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);
CREATE INDEX idx_messages_conversation ON messages(sender_id, recipient_id, sent_at);

-- COMPOSITE INDEXES FOR COMMON QUERY PATTERNS
CREATE INDEX idx_properties_search ON properties(location, pricepernight, created_at);
CREATE INDEX idx_bookings_user_dates ON bookings(user_id, start_date, end_date);
CREATE INDEX idx_reviews_property_rating_date ON reviews(property_id, rating, created_at);
CREATE INDEX idx_messages_conversation_chrono ON messages(sender_id, recipient_id, sent_at DESC);

-- ============================================================================
-- PERFORMANCE ANALYSIS: AFTER INDEXES
-- ============================================================================

-- Test 1: User authentication query performance (AFTER)
EXPLAIN ANALYZE SELECT user_id, first_name, last_name, role 
FROM users 
WHERE email = 'test@example.com';

-- Test 2: Property search by location and price (AFTER)
EXPLAIN ANALYZE SELECT property_id, name, location, pricepernight 
FROM properties 
WHERE location = 'Paris' AND pricepernight BETWEEN 100 AND 500;

-- Test 3: User booking history (AFTER)
EXPLAIN ANALYZE SELECT b.booking_id, b.start_date, b.end_date, b.status,
       p.name as property_name
FROM bookings b
JOIN properties p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY b.created_at DESC;

-- Test 4: Property availability check (AFTER)
EXPLAIN ANALYZE SELECT COUNT(*) 
FROM bookings 
WHERE property_id = '550e8400-e29b-41d4-a716-446655440001'
  AND start_date <= '2024-06-15' 
  AND end_date >= '2024-06-10'
  AND status = 'confirmed';

-- Test 5: Property reviews aggregation (AFTER)
EXPLAIN ANALYZE SELECT p.property_id, p.name, AVG(r.rating) as avg_rating, COUNT(r.review_id) as review_count
FROM properties p
LEFT JOIN reviews r ON p.property_id = r.property_id
WHERE p.location = 'Paris'
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) >= 4.0;

-- Test 6: Host properties listing (AFTER)
EXPLAIN ANALYZE SELECT p.property_id, p.name, p.location, p.pricepernight,
       COUNT(b.booking_id) as total_bookings
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
WHERE p.host_id = '550e8400-e29b-41d4-a716-446655440002'
GROUP BY p.property_id, p.name, p.location, p.pricepernight;

-- Test 7: Message conversation query (AFTER)
EXPLAIN ANALYZE SELECT message_id, sender_id, message_body, sent_at
FROM messages 
WHERE (sender_id = '550e8400-e29b-41d4-a716-446655440003' AND recipient_id = '550e8400-e29b-41d4-a716-446655440004')
   OR (sender_id = '550e8400-e29b-41d4-a716-446655440004' AND recipient_id = '550e8400-e29b-41d4-a716-446655440003')
ORDER BY sent_at DESC;

-- ============================================================================
-- INDEX USAGE ANALYSIS
-- ============================================================================

-- Check which indexes are being used
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Check table statistics
SELECT schemaname, tablename, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY seq_scan DESC; 