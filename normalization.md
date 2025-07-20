# Normalization to Third Normal Form (3NF)

## Objective

To apply normalization principles and ensure the Airbnb database schema adheres to the Third Normal Form (3NF), minimizing redundancy and ensuring data integrity.

---

## Step 1: First Normal Form (1NF)

**Definition:**  
A relation is in 1NF if:
- It has only atomic (indivisible) values.
- Each record is unique.
- Each field contains only one value (no repeating groups or arrays).

**Application:**  
All entities in the schema (User, Property, Booking, Payment, Review, Message) satisfy 1NF:
- Fields such as names, descriptions, and dates are atomic.
- No multivalued or composite fields exist.
- Each table has a defined primary key (e.g., `user_id`, `property_id`).

✅ **All tables are in 1NF.**

---

## Step 2: Second Normal Form (2NF)

**Definition:**  
A relation is in 2NF if:
- It is in 1NF.
- All non-key attributes are fully functionally dependent on the whole primary key.

**Application:**  
Each table has a **single-column primary key** (UUID), so there are no partial dependencies.

- In the `Booking` table, fields like `start_date`, `end_date`, `total_price`, and `status` depend fully on `booking_id`.
- In the `Property` table, fields like `name`, `description`, `location`, and `pricepernight` depend fully on `property_id`.

✅ **All tables are in 2NF.**

---

## Step 3: Third Normal Form (3NF)

**Definition:**  
A relation is in 3NF if:
- It is in 2NF.
- There are no transitive dependencies (i.e., non-key attributes do not depend on other non-key attributes).

**Application:**  
- In the `User` table, no attribute depends on another non-key attribute.
- In `Property`, `Booking`, `Payment`, `Review`, and `Message` tables, all non-key fields are directly dependent on their respective primary keys and not on each other.

Examples:
- In the `Payment` table, `amount`, `payment_date`, and `payment_method` are all directly dependent on `payment_id`, and not on `booking_id` or any other non-key attribute.
- In the `Review` table, `rating` and `comment` are dependent on `review_id`, not indirectly through `user_id` or `property_id`.

✅ **All tables are in 3NF.**

---

## Summary

The Airbnb database schema has been reviewed for normalization. Each entity satisfies the requirements for:
- **1NF** (atomic fields, no repeating groups),
- **2NF** (full functional dependency on the primary key),
- **3NF** (no transitive dependencies).

No schema adjustments were necessary. The design is already in Third Normal Form (3NF).

