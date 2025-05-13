# Horizon Travels Booking Website

Horizon Travels is a full-stack booking platform built with Flask and MySQL. It allows users easily search for and book air, train, and coach travel. You can register, log in, browse routes, make one-way or return bookings, manage your profile, and adjust your bookings all in one place. Pricing adjusts based on travel class and how far in advance you book, and the system checks seat availability in real time.

For admins, there's a separate dashboard to manage users (including promotions and demotions), update travel routes, cancel bookings, and view sales insights. The app uses secure password hashing and session management to keep user data safe. 

As of May 2025 - The whole system runs in Docker with separate containers for Flask and MySQL. When you start it, the database is set up automatically with tables and sample data.

##  How to Run

```bash
docker-compose up --build -d
```
Access in browser: `http://localhost:8000`

## Test Accounts

| Email                 | Password |
|-----------------------|----------|
| admin@admin.com       | 123      |
| standard@standard.com | 123      |
| test@test.com         | 123      |

