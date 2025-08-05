# AirBnB Database Indexing Strategy

## Overview
This document outlines the comprehensive indexing strategy implemented for the AirBnB clone database to optimize query performance across common use cases.

## Index Categories

### 1. Primary Key Indexes
- All primary keys are automatically indexed by PostgreSQL
- `user_id`, `property_id`, `booking_id`, `payment_id`, `review_id`, `message_id`

### 2. Foreign Key Indexes
- `host_id` in properties table (frequently used in JOINs)
- `user_id` in bookings table (user booking history queries)
- `property_id` in bookings table (property availability queries)
- `booking_id` in payments table (payment tracking)
- `sender_id` and `recipient_id` in messages table (conversation queries)

### 3. Search and Filter Indexes
- `email` in users table (user authentication)
- `location` in properties table (property search)
- `pricepernight` in properties table (price filtering)
- `status` in bookings table (booking status filtering)
- `rating` in reviews table (rating-based queries)

### 4. Temporal Indexes
- `created_at` across all tables (chronological queries)
- `start_date` and `end_date` in bookings table (availability queries)
- `sent_at` in messages table (message history)

### 5. Composite Indexes
- `location, pricepernight` for property search
- `user_id, status` for user booking status queries
- `property_id, start_date, end_date` for availability checks
- `sender_id, recipient_id, sent_at` for conversation queries

## Performance Benefits

### Query Optimization
- **User Authentication**: `idx_users_email` speeds up login queries
- **Property Search**: `idx_properties_location_price` optimizes location and price filtering
- **Booking Queries**: `idx_bookings_user_dates` improves user booking history retrieval
- **Review Aggregation**: `idx_reviews_property_rating` speeds up rating calculations
- **Message Conversations**: `idx_messages_conversation_chrono` optimizes conversation retrieval

### Common Query Patterns Supported
1. User login and profile queries
2. Property search and filtering
3. Booking availability checks
4. User booking history
5. Property review aggregation
6. Message conversation threads
7. Payment tracking and reporting

## Maintenance Considerations
- Monitor index usage with `pg_stat_user_indexes`
- Consider dropping unused indexes to reduce write overhead
- Regularly analyze query performance with `EXPLAIN ANALYZE`
- Update statistics with `ANALYZE` after significant data changes

## Usage Examples
```sql
-- Property search with location and price filter
EXPLAIN ANALYZE SELECT * FROM properties 
WHERE location = 'Paris' AND pricepernight BETWEEN 100 AND 500;

-- User booking history
EXPLAIN ANALYZE SELECT * FROM bookings 
WHERE user_id = 'uuid' ORDER BY created_at DESC;

-- Property reviews with rating filter
EXPLAIN ANALYZE SELECT AVG(rating) FROM reviews 
WHERE property_id = 'uuid' AND rating >= 4;
```
```

The indexing strategy I've created addresses the most common query patterns in an AirBnB-like application:

1. **User-related queries**: Email lookups, role-based filtering, name searches
2. **Property queries**: Location-based search, price filtering, host-based queries
3. **Booking queries**: Date range searches, user booking history, status filtering
4. **Review queries**: Rating aggregations, property-based reviews
5. **Message queries**: Conversation threading, chronological ordering

The composite indexes are particularly important for queries that filter on multiple columns simultaneously, which is common in search and filtering operations. The temporal indexes support chronological queries and reporting features.

To measure performance improvements, you can use:
- `EXPLAIN ANALYZE` to see query execution plans
- `pg_stat_user_indexes` to monitor index usage
- Compare query execution times before and after index creation