-- USER TABLE INDEXES
-- Email is already indexed in schema, but adding composite indexes for common queries
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_name_search ON users(first_name, last_name);

-- PROPERTY TABLE INDEXES
-- host_id is frequently used in WHERE clauses and JOINs
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_price ON properties(pricepernight);
CREATE INDEX idx_properties_created_at ON properties(created_at);
CREATE INDEX idx_properties_location_price ON properties(location, pricepernight);

-- BOOKING TABLE INDEXES
-- user_id is frequently used in WHERE clauses and JOINs
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
CREATE INDEX idx_bookings_user_status ON bookings(user_id, status);
CREATE INDEX idx_bookings_property_dates ON bookings(property_id, start_date, end_date);

-- PAYMENT TABLE INDEXES
-- payment_date for chronological queries
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_payments_method ON payments(payment_method);
CREATE INDEX idx_payments_amount ON payments(amount);

-- REVIEW TABLE INDEXES
-- rating is frequently used in WHERE clauses and aggregations
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_property_rating ON reviews(property_id, rating);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

-- MESSAGE TABLE INDEXES
-- sender_id and recipient_id for message queries
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);
CREATE INDEX idx_messages_conversation ON messages(sender_id, recipient_id, sent_at);

-- COMPOSITE INDEXES FOR COMMON QUERY PATTERNS
-- For property search by location and price range
CREATE INDEX idx_properties_search ON properties(location, pricepernight, created_at);

-- For booking queries by user and date range
CREATE INDEX idx_bookings_user_dates ON bookings(user_id, start_date, end_date);

-- For review aggregation queries
CREATE INDEX idx_reviews_property_rating_date ON reviews(property_id, rating, created_at);

-- For message conversation queries
CREATE INDEX idx_messages_conversation_chrono ON messages(sender_id, recipient_id, sent_at DESC); 