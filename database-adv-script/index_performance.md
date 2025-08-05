# AirBnB Database Indexing Strategy with Performance Analysis

## Overview
This project implements a comprehensive indexing strategy for the AirBnB clone database, including performance measurement using `EXPLAIN ANALYZE` to demonstrate the impact of indexes on query performance.

## Key Features

### Performance Measurement
- **Before/After Analysis**: Each query is tested both before and after index creation
- **EXPLAIN ANALYZE**: Detailed execution plans showing timing and resource usage
- **Index Usage Monitoring**: Tracks which indexes are actually being used

### Index Categories

#### 1. Single-Column Indexes
- **User Table**: `role`, `created_at`, `first_name + last_name`
- **Property Table**: `host_id`, `location`, `pricepernight`, `created_at`
- **Booking Table**: `user_id`, `status`, `created_at`, `start_date + end_date`
- **Review Table**: `rating`, `user_id`, `created_at`
- **Message Table**: `sender_id`, `recipient_id`, `sent_at`

#### 2. Composite Indexes
- **Property Search**: `location + pricepernight + created_at`
- **Booking Queries**: `user_id + start_date + end_date`
- **Review Aggregation**: `property_id + rating + created_at`
- **Message Conversations**: `sender_id + recipient_id + sent_at DESC`

### Test Queries Included

1. **User Authentication**: Email-based user lookup
2. **Property Search**: Location and price range filtering
3. **Booking History**: User's booking history with property details
4. **Availability Check**: Property availability for specific dates
5. **Review Aggregation**: Average ratings with filtering
6. **Host Dashboard**: Host's properties with booking counts
7. **Message Conversations**: Conversation thread retrieval

## Performance Benefits

### Expected Improvements
- **User Authentication**: 90%+ reduction in query time with email index
- **Property Search**: 70-80% improvement with composite location/price index
- **Booking Queries**: 60-70% faster with user_id and date indexes
- **Review Aggregation**: 50-60% improvement with property_id + rating index
- **Message Queries**: 80%+ faster with conversation composite index

### Query Optimization Examples

```sql
-- Before: Sequential scan of entire users table
-- After: Index scan on email column
SELECT * FROM users WHERE email = 'user@example.com';

-- Before: Full table scan with expensive filtering
-- After: Index scan on location + price range
SELECT * FROM properties 
WHERE location = 'Paris' AND pricepernight BETWEEN 100 AND 500;

-- Before: Nested loop join with full table scans
-- After: Index-based joins with sorted results
SELECT b.*, p.name 
FROM bookings b 
JOIN properties p ON b.property_id = p.property_id 
WHERE b.user_id = 'uuid' 
ORDER BY b.created_at DESC;
```

## Usage Instructions

1. **Run the complete script**: Execute `database_index.sql` to create indexes and measure performance
2. **Analyze results**: Compare the EXPLAIN ANALYZE output before and after index creation
3. **Monitor usage**: Use the index usage queries to see which indexes are most effective
4. **Optimize further**: Based on actual usage patterns, consider adding or removing indexes

## Maintenance Considerations

- **Regular Monitoring**: Check index usage with `pg_stat_user_indexes`
- **Performance Tuning**: Use `ANALYZE` after significant data changes
- **Index Maintenance**: Consider dropping unused indexes to reduce write overhead
- **Query Optimization**: Regularly review slow queries and adjust indexes accordingly

## Index Strategy Rationale

1. **High-Usage Columns**: Index columns frequently used in WHERE, JOIN, ORDER BY clauses
2. **Composite Indexes**: Support multi-column queries efficiently
3. **Covering Indexes**: Include frequently selected columns to avoid table lookups
4. **Selective Indexes**: Focus on columns with high selectivity (many unique values)
5. **Temporal Indexes**: Support chronological queries and reporting

This indexing strategy provides comprehensive performance optimization for typical AirBnB application workloads while maintaining reasonable write performance and storage overhead.