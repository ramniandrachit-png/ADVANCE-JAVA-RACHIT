# 📘 ShopSphere E-Commerce System - Comprehensive Project Report

**Academic & Technical Project Documentation**  
**Project Title:** ShopSphere: A Full-Stack Enterprise E-Commerce Platform  
**Architecture:** Model-View-Controller (MVC) using Jakarta EE 10 (Servlets 6.0, JSP 3.1, JSTL 3.0), JDBC, and MySQL 8.x  
**Deployment Target:** Apache Tomcat 11  

---

## 1. Executive Summary & Introduction

### 1.1 Overview
The digital economy has transformed traditional commerce into dynamic, accessible online ecosystems. **ShopSphere** is a complete, full-stack, enterprise-grade e-commerce application designed to provide customers with an intuitive shopping experience while equipping store administrators with management tools to oversee inventory, fulfill orders, moderate reviews, and evaluate store performance.

Unlike modern systems that rely on heavy JavaScript client frameworks (e.g., React, Angular, Vue) paired with opinionated backend frameworks (e.g., Spring Boot), ShopSphere has been developed from first principles using **Java 17, Jakarta Servlets 6.0, JavaServer Pages (JSP 3.1), JavaServer Pages Standard Tag Library (JSTL 3.0), and raw Java Database Connectivity (JDBC)**. This ensures that the codebase remains clear, educational, reliable, and free of framework abstractions, making it suitable for academic assessment, college viva presentations, and real-world reference.

---

## 2. Problem Statement & Proposed Solution

### 2.1 Existing Problem
Many commercial e-commerce systems or educational tutorial applications suffer from critical architectural and security flaws:
1. **Security Vulnerabilities**: Passwords stored in plain text or using weak MD5/SHA-1 hashing; SQL injection vulnerabilities caused by raw SQL string concatenation; lack of server-side role validation where admin links are merely hidden in the CSS rather than authenticated on the server.
2. **Untrusted Client Inputs**: E-commerce carts calculating totals in client JavaScript, allowing malicious actors to manipulate prices or submit negative quantities before checkout.
3. **Lack of Transaction Atomicity**: Inability to manage concurrent inventory reductions, resulting in phantom orders and overselling when multiple users purchase the last available stock.
4. **Fragile Dependencies**: Overreliance on deprecated `javax.servlet.*` packages that are incompatible with modern servlet containers like Apache Tomcat 10.1 and Tomcat 11.

### 2.2 Proposed Solution (ShopSphere)
ShopSphere addresses every deficiency:
- **Zero-Trust Client Pricing**: The server recalculates all product prices, discounts, coupons, and shipping fees against live database records during checkout.
- **Atomic Transactions with Row-Level Locking**: Inventory updates execute inside an atomic JDBC transaction (`conn.setAutoCommit(false)` and `SELECT ... FOR UPDATE`), guaranteeing that stock can never drop below zero.
- **Enterprise-Grade Security**: BCrypt password hashing (`$2a$10$...`), centralized `AuthFilter` and `AdminFilter` request interception, session regeneration (`changeSessionId()`), and anti-duplicate submission idempotency tokens.
- **Modern Standards**: Fully compliant with **Jakarta EE 10 / Servlet 6.0**, optimized for Apache Tomcat 11.

---

## 3. System Requirements Specification

### 3.1 Functional Requirements

#### A. Authentication & User Management
- **Customer Registration**: New customers register with full name, email, phone number, and password.
- **Input Validation**: Server-side validation of email format, phone format, and password length (minimum 6 characters).
- **Authentication**: Secure login verifying BCrypt password hash.
- **Session Management**: Secure session creation with new session IDs on login to prevent session fixation.
- **Profile Management**: Customers can update personal details, change passwords, and save multiple delivery addresses with default selection.

#### B. Catalog & Search
- **Category Browsing**: Dynamic product listings categorized into Electronics, Fashion, Home Living, Sports, and Books.
- **Search Engine**: Case-insensitive search across product title, brand name, and description.
- **Multi-Factor Filtering**: Filter products simultaneously by category, minimum price, and maximum price.
- **Sorting**: Order catalog by price (low-to-high, high-to-low), customer rating, newest arrivals, or alphabetical name.
- **Pagination**: Paginate catalog results to ensure responsive page load times.

#### C. Shopping Cart & Wishlist
- **Dual-State Cart**: Supports guest shopping via HTTP sessions and automatically synchronizes session cart items into persistent database carts upon user login.
- **Inventory Validation**: Real-time stock validation preventing users from adding more items than available in stock.
- **Quantity Controls**: Inline increment, decrement, and removal of cart items.
- **Wishlist**: Customers can save items to their wishlist and move them directly to the cart.

#### D. Checkout & Order Fulfillment
- **Address Selection**: Customers can select from saved addresses or input a new address during checkout.
- **Coupon Engine**: Validates promo codes against expiry dates, minimum order thresholds, and usage limits before deducting percentage or fixed discounts.
- **Transactional Placement**: Creates order records, inserts snapshot order items, generates payment entries, increments coupon usage, and decrements product inventory within a single atomic database transaction.
- **Order Tracking**: Visual 4-stage tracking timeline (`Confirmed` &rarr; `Processing` &rarr; `Shipped` &rarr; `Delivered`), order history list, and itemized invoice receipt with browser printing support.

#### E. Administrative Panel
- **Executive Dashboard**: KPI metrics displaying real-time revenue, completed order counts, total catalog products, and registered customers.
- **Product CRUD**: Add new products, update specifications and pricing, adjust stock, toggle active/inactive status, and safe-delete.
- **Category CRUD**: Create and manage store departments with safety checks preventing deletion of categories containing active products.
- **Order Management**: Inspect order details and update fulfillment status and payment status.
- **Customer Moderation**: View customer list and suspend or reactivate accounts.
- **Coupon Management**: Create promotional coupons, set rules, and disable or delete existing coupons.
- **Review Moderation**: Moderate and remove inappropriate user reviews.

---

### 3.2 Non-Functional Requirements
- **Security**: Complete protection against SQL Injection, XSS, CSRF, and Session Fixation.
- **Reliability & ACID Properties**: Financial and inventory operations must satisfy Atomicity, Consistency, Isolation, and Durability.
- **Performance**: Lightweight pages rendered on the server with minimal external dependencies.
- **Usability & Responsiveness**: Mobile-first design system functioning seamlessly on desktop, tablet, and mobile screens.
- **Portability**: Maven-based build that compiles and packages identically across Windows, Linux, and macOS.

---

## 4. System Architecture & Design

### 4.1 Layered Architectural Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Client Browser                         │
│            (HTML5 / CSS3 / JavaScript / JSP UI)             │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTP Request (GET / POST)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       Filter Chain                          │
│  ├── EncodingFilter: UTF-8 encoding, Security Headers       │
│  ├── AuthFilter: Session validity, Protected customer routes│
│  └── AdminFilter: Role verification (Role.ADMIN)            │
└──────────────────────────────┬──────────────────────────────┘
                               │ Dispatched Request
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     Controller Layer                        │
│          (Jakarta EE 10 Servlets - Servlet 6.0)             │
│  HomeServlet, ProductServlet, CartServlet, CheckoutServlet, │
│  OrderServlet, ProfileServlet, WishlistServlet, Admin*      │
└──────────────────────────────┬──────────────────────────────┘
                               │ Method Invocation
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                          │
│      (Business Rules, Validations, Pricing, Security)       │
│  UserService, ProductService, CartService, CheckoutService, │
│  OrderService, AddressService, CouponService, ReviewService │
└──────────────────────────────┬──────────────────────────────┘
                               │ Data Persistence Operations
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        DAO Layer                            │
│           (JDBC PreparedStatements, Transactions)           │
│  UserDAO, ProductDAO, CategoryDAO, AddressDAO, CartDAO,     │
│  OrderDAO, PaymentDAO, WishlistDAO, ReviewDAO, CouponDAO    │
└──────────────────────────────┬──────────────────────────────┘
                               │ SQL Queries & Connections
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 MySQL 8.x Database Engine                   │
│                       (shopsphere)                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Database Schema & ER Design

The database schema is normalized to **Third Normal Form (3NF)** to eliminate redundancy and maintain referential integrity.

### 5.1 Tables Summary

| Table Name | Primary Key | Foreign Keys | Purpose |
| :--- | :--- | :--- | :--- |
| `users` | `id` (BIGINT) | None | User accounts, credentials, roles, statuses |
| `categories` | `id` (INT) | None | Product classifications & departments |
| `products` | `id` (BIGINT) | `category_id` &rarr; `categories(id)` | Product details, stock, pricing, discounts |
| `addresses` | `id` (BIGINT) | `user_id` &rarr; `users(id)` | Delivery destinations for orders |
| `carts` | `id` (BIGINT) | `user_id` &rarr; `users(id)` | Persistent shopping carts |
| `cart_items` | `id` (BIGINT) | `cart_id`, `product_id` | Individual items inside a cart |
| `orders` | `id` (BIGINT) | `user_id` &rarr; `users(id)` | Customer order master record |
| `order_items` | `id` (BIGINT) | `order_id`, `product_id` | Historical snapshot of purchased items |
| `payments` | `id` (BIGINT) | `order_id` &rarr; `orders(id)` | Transaction logs and payment status |
| `wishlist` | `id` (BIGINT) | `user_id`, `product_id` | Saved favorite products |
| `reviews` | `id` (BIGINT) | `user_id`, `product_id` | Customer feedback and star ratings |
| `coupons` | `id` (INT) | None | Discount codes and usage rules |

---

## 6. Security Analysis & Implementation

### 6.1 Cryptographic Password Hashing
ShopSphere utilizes **jBCrypt** with an adaptive work factor:
```java
// PasswordUtil.java
public static String hashPassword(String plainTextPassword) {
    return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(10));
}

public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
    return BCrypt.checkpw(plainTextPassword, hashedPassword);
}
```
Passwords are never logged or stored in cleartext.

### 6.2 SQL Injection Immunity
Every query uses `PreparedStatement` with typed parameter binding. No string concatenation is permitted for user input:
```java
// Example from UserDAO.java
String sql = "SELECT * FROM users WHERE LOWER(email) = LOWER(?)";
try (Connection conn = DBConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql)) {
    ps.setString(1, email.trim());
    ...
}
```

### 6.3 Anti-Duplicate Order Tokens (Idempotency)
Checkout forms generate a cryptographically random UUID token in the session:
```java
String checkoutToken = UUID.randomUUID().toString();
session.setAttribute("checkoutToken", checkoutToken);
```
Upon receiving a POST request, `CheckoutServlet` checks if the submitted token matches the session token and invalidates it immediately. Repeated submissions or page refreshes are rejected.

---

## 7. Testing & Verification

Automated unit tests were authored using **JUnit 5 (Jupiter)** covering key business logic:
- `DBConnectionTest`: Verifies driver loading, connection fallback, and URL parsing.
- `PasswordUtilTest`: Tests hashing, verification, and rejection of wrong passwords.
- `ProductTest`: Tests price calculations, savings formulas, and stock status evaluations.
- `CartTest`: Validates subtotal summing, free shipping thresholds, and coupon deductions.
- `CouponServiceTest`: Tests expiry dates, usage limit enforcement, and discount validations.

### Test Results
```
[INFO] Running com.shopsphere.model.CartTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.shopsphere.model.ProductTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.shopsphere.service.CouponServiceTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.shopsphere.util.DBConnectionTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
[INFO] Running com.shopsphere.util.PasswordUtilTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS - Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
```

---

## 8. Limitations & Future Enhancements

### 8.1 Current Limitations
1. **Live Payment Gateway**: Online card and UPI transactions are safe sandbox simulations because real payment gateways (such as Stripe or Razorpay) require live merchant credentials and HTTPS webhooks.
2. **Email Delivery**: Order confirmations are displayed on-screen rather than dispatched via SMTP email, eliminating the need for an external SMTP mail server configuration.

### 8.2 Future Enhancements
1. **Third-Party Payment Gateways**: Integrate real Stripe or Razorpay SDKs for real-world card processing.
2. **Transactional Email**: Integrate Jakarta Mail (JavaMail) with an SMTP relay (SendGrid/Amazon SES) to send automated order invoices and shipping updates.
3. **Advanced Product Variants**: Add support for dynamic product variations (e.g., sizes, colors, memory capacities).

---

## 9. Conclusion
The **ShopSphere** e-commerce project demonstrates how modern enterprise principles can be applied using foundational Java web technologies. By combining Jakarta Servlets 6.0, JSP 3.1, JSTL 3.0, JDBC, and MySQL 8.x inside a clean multi-tiered MVC architecture, the application achieves high performance, robust security, maintainability, and clean separation of concerns without relying on bulky framework abstractions.
