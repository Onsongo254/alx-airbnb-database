-- USERS
INSERT INTO users (user_id, first_name, last_name, email, password_hash, phone_number, role)
VALUES 
    ('00000000-0000-0000-0000-000000000001', 'Alice', 'Anderson', 'alice@example.com', 'hashed_pw_1', '1234567890', 'guest'),
    ('00000000-0000-0000-0000-000000000002', 'Bob', 'Brown', 'bob@example.com', 'hashed_pw_2', '2345678901', 'host'),
    ('00000000-0000-0000-0000-000000000003', 'Carol', 'Clark', 'carol@example.com', 'hashed_pw_3', NULL, 'admin'),
    ('00000000-0000-0000-0000-000000000004', 'Dan', 'Davis', 'dan@example.com', 'hashed_pw_4', '3456789012', 'guest');

-- PROPERTIES
INSERT INTO properties (property_id, host_id, name, description, location, pricepernight)
VALUES
    ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Sunny Loft', 'A sunny apartment in the city center', 'Nairobi', 75.00),
    ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', 'Beachside Bungalow', 'Relax by the beach with this cozy spot', 'Mombasa', 120.00);

-- BOOKINGS
INSERT INTO bookings (booking_id, property_id, user_id, start_date, end_date, total_price, status)
VALUES
    ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '2025-08-01', '2025-08-05', 300.00, 'confirmed'),
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', '2025-09-10', '2025-09-12', 240.00, 'pending');

-- PAYMENTS
INSERT INTO payments (payment_id, booking_id, amount, payment_method)
VALUES
    ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 300.00, 'credit_card');

-- REVIEWS
INSERT INTO reviews (review_id, property_id, user_id, rating, comment)
VALUES
    ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 5, 'Lovely place, clean and central!'),
    ('40000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', 4, 'Nice location, just a bit noisy at night.');

-- MESSAGES
INSERT INTO messages (message_id, sender_id, recipient_id, message_body)
VALUES
    ('50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Hi, is your apartment available in September?'),
    ('50000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Yes, it is available for those dates.');
