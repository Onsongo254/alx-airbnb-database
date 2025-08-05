-- ============================================================================
-- TABLE PARTITIONING IMPLEMENTATION FOR BOOKING TABLE
-- ============================================================================

-- Step 1: Create the partitioned table structure
-- We'll partition by start_date using RANGE partitioning

-- Drop the existing bookings table if it exists (in production, you'd migrate data)
-- DROP TABLE IF EXISTS bookings CASCADE;

-- Create the partitioned bookings table
CREATE TABLE bookings_partitioned (
    booking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL NOT NULL,
    status VARCHAR CHECK (status IN ('pending', 'confirmed', 'canceled')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_booking_property_partitioned FOREIGN KEY (property_id) REFERENCES properties(property_id),
    CONSTRAINT fk_booking_user_partitioned FOREIGN KEY (user_id) REFERENCES users(user_id)
) PARTITION BY RANGE (start_date);

-- Step 2: Create partitions for different date ranges
-- Create partitions for the last 3 years and future dates

-- 2022 partition
CREATE TABLE bookings_2022 PARTITION OF bookings_partitioned
FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

-- 2023 partition
CREATE TABLE bookings_2023 PARTITION OF bookings_partitioned
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- 2024 partition
CREATE TABLE bookings_2024 PARTITION OF bookings_partitioned
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- 2025 partition
CREATE TABLE bookings_2025 PARTITION OF bookings_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Future partition (for dates beyond 2025)
CREATE TABLE bookings_future PARTITION OF bookings_partitioned
FOR VALUES FROM ('2026-01-01') TO (MAXVALUE);

-- Default partition for any dates that don't fit the above ranges
CREATE TABLE bookings_default PARTITION OF bookings_partitioned DEFAULT;

-- Step 3: Create indexes on the partitioned table
-- These indexes will be automatically created on all partitions

-- Index on start_date for efficient partition pruning
CREATE INDEX idx_bookings_partitioned_start_date ON bookings_partitioned(start_date);

-- Composite index for common query patterns
CREATE INDEX idx_bookings_partitioned_user_date ON bookings_partitioned(user_id, start_date);
CREATE INDEX idx_bookings_partitioned_property_date ON bookings_partitioned(property_id, start_date);
CREATE INDEX idx_bookings_partitioned_status_date ON bookings_partitioned(status, start_date);

-- Step 4: Insert sample data to test partitioning
-- This simulates migrating existing data to the partitioned table

INSERT INTO bookings_partitioned (property_id, user_id, start_date, end_date, total_price, status)
SELECT 
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM bookings;

-- Step 5: Performance test queries

-- Query 1: Test partition pruning - bookings in 2024
EXPLAIN (ANALYZE, BUFFERS) 
SELECT COUNT(*) as bookings_2024
FROM bookings_partitioned 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Query 2: Test partition pruning - bookings in specific date range
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    booking_id,
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM bookings_partitioned 
WHERE start_date >= '2024-06-01' AND start_date <= '2024-08-31'
ORDER BY start_date;

-- Query 3: Test aggregation with partition pruning
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    DATE_TRUNC('month', start_date) as month,
    COUNT(*) as total_bookings,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value
FROM bookings_partitioned 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY month;

-- Query 4: Test join performance with partitioned table
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    p.name as property_name,
    p.location
FROM bookings_partitioned b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-01-01' AND b.start_date < '2025-01-01'
ORDER BY b.start_date;

-- Step 6: Compare performance with non-partitioned table
-- (Assuming original bookings table still exists)

-- Performance test on original table
EXPLAIN (ANALYZE, BUFFERS) 
SELECT COUNT(*) as bookings_2024_original
FROM bookings 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Performance test on partitioned table
EXPLAIN (ANALYZE, BUFFERS) 
SELECT COUNT(*) as bookings_2024_partitioned
FROM bookings_partitioned 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Step 7: Maintenance queries for partitioned table

-- Check partition sizes
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE tablename LIKE 'bookings_%'
ORDER BY tablename;

-- Check partition usage statistics
SELECT 
    schemaname,
    tablename,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_live_tup,
    n_dead_tup
FROM pg_stat_user_tables 
WHERE tablename LIKE 'bookings_%'
ORDER BY tablename;

-- Step 8: Create additional partitions if needed
-- Example: Create monthly partitions for better granularity (optional)

-- CREATE TABLE bookings_2024_01 PARTITION OF bookings_partitioned
-- FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- CREATE TABLE bookings_2024_02 PARTITION OF bookings_partitioned
-- FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Step 9: Cleanup and final verification

-- Verify partitions were created correctly
SELECT 
    parent.relname as table_name,
    child.relname as partition_name,
    pg_get_expr(child.relpartbound, child.oid) as partition_expression
FROM pg_inherits
JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
JOIN pg_class child ON pg_inherits.inhrelid = child.oid
WHERE parent.relname = 'bookings_partitioned'
ORDER BY child.relname;

-- Check data distribution across partitions
SELECT 
    'bookings_2022' as partition_name,
    COUNT(*) as record_count
FROM bookings_2022
UNION ALL
SELECT 
    'bookings_2023' as partition_name,
    COUNT(*) as record_count
FROM bookings_2023
UNION ALL
SELECT 
    'bookings_2024' as partition_name,
    COUNT(*) as record_count
FROM bookings_2024
UNION ALL
SELECT 
    'bookings_2025' as partition_name,
    COUNT(*) as record_count
FROM bookings_2025
UNION ALL
SELECT 
    'bookings_future' as partition_name,
    COUNT(*) as record_count
FROM bookings_future
UNION ALL
SELECT 
    'bookings_default' as partition_name,
    COUNT(*) as record_count
FROM bookings_default; 