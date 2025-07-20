# Airbnb Database Schema

This project contains SQL definitions for an Airbnb-like platform. The schema is normalized to 3NF and includes:

- `users`: Holds guest, host, and admin accounts.
- `properties`: Listings created by hosts.
- `bookings`: Tracks property reservations.
- `payments`: Linked to bookings.
- `reviews`: User feedback on properties.
- `messages`: Direct user communication.

### Schema Highlights
- UUIDs used for all primary keys.
- ENUMs (via VARCHAR + CHECK) for roles and statuses.
- Foreign key constraints maintain relational integrity.
- Indexes added on frequently queried columns (e.g., email, property_id).