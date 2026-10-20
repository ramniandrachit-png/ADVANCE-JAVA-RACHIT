# 🛍️ ShopSphere - Complete Full-Stack Java E-Commerce Platform

[![Java Version](https://img.shields.io/badge/Java-17%2B-blue.svg)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10%20(Servlet%206.0)-orange.svg)](https://jakarta.ee/)
[![Server](https://img.shields.io/badge/Server-Apache%20Tomcat%2011-yellow.svg)](https://tomcat.apache.org/)
[![Database](https://img.shields.io/badge/Database-MySQL%208.x-blue.svg)](https://www.mysql.com/)
[![Build](https://img.shields.io/badge/Build-Maven%203.9%2B-brightgreen.svg)](https://maven.apache.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

ShopSphere is an enterprise-grade, secure, responsive, full-stack e-commerce web application built from scratch using a pure **Jakarta Servlets 6.0 + JSP 3.1 + JSTL 3.0 + JDBC** layered architecture. It features a modern customer storefront and a complete administrative control panel.

---

## 📑 Table of Contents

1. [Architectural Overview](#-architectural-overview)
2. [Project Structure](#-project-structure)
3. [Key Features](#-key-features)
4. [Prerequisites](#-prerequisites)
5. [Step-by-Step Setup Guide](#-step-by-step-setup-guide)
   - [1. Database Import](#1-import-mysql-database)
   - [2. Configuration](#2-configure-database-connection)
   - [3. Building the Project](#3-build-the-application-with-maven)
   - [4. Running on Apache Tomcat 11](#4-run-on-apache-tomcat-11)
   - [5. Running in Visual Studio Code](#5-running--debugging-in-vs-code)
6. [Demo Accounts & Credentials](#-demo-accounts--credentials)
7. [Application Route Cheat Sheet](#-application-route-cheat-sheet)
8. [Security & Architectural Safeguards](#-security--architectural-safeguards)
9. [Troubleshooting & Common Solutions](#-troubleshooting--common-solutions)

---

## 🏛️ Architectural Overview

ShopSphere adheres to the classic **MVC (Model-View-Controller)** pattern divided into distinct decoupled layers:

```
[ Browser / Client ]
       │
   (HTTP Requests: GET / POST)
       ▼
[ Filters ] ──────► EncodingFilter (UTF-8) ──► AuthFilter ──► AdminFilter
       │
       ▼
[ Controller Layer (Jakarta Servlets 6.0) ]
   HomeServlet, ProductServlet, CartServlet, CheckoutServlet, OrderServlet, etc.
       │
       ▼
[ Service Layer (Business Logic) ]
   ProductService, CartService, CheckoutService, UserService, CouponService, etc.
       │
       ▼
[ DAO Layer (JDBC Data Access) ]
   PreparedStatement exclusively (SQL Injection prevention)
       │
       ▼
[ MySQL 8.x Database (shopsphere) ]
       │
       ▲
[ View Layer (JSP 3.1 + JSTL 3.0 + CSS3 + Vanilla JS) ]
   Rendered dynamic HTML returned to the client
```

---

## 📂 Project Structure

```
ShopSphere/
├── pom.xml                               # Root Maven Parent POM
├── README.md                             # Comprehensive User & Setup Documentation
├── .gitignore                            # Excluded build artifacts & sensitive configs
├── database/
│   └── shopsphere.sql                    # Complete MySQL 8.x schema and sample seed data
├── docs/
│   └── project-report.md                 # Full Academic / Architecture Project Report
└── web/                                  # Web Application Module (WAR)
    ├── pom.xml                           # WAR configuration & Jakarta EE dependencies
    ├── src/
    │   ├── main/
    │   │   ├── java/com/shopsphere/
    │   │   │   ├── controller/           # Jakarta Servlets (Routes & Actions)
    │   │   │   │   ├── HomeServlet.java
    │   │   │   │   ├── LoginServlet.java
    │   │   │   │   ├── RegisterServlet.java
    │   │   │   │   ├── LogoutServlet.java
    │   │   │   │   ├── ProductServlet.java
    │   │   │   │   ├── ProductDetailsServlet.java
    │   │   │   │   ├── CartServlet.java
    │   │   │   │   ├── CheckoutServlet.java
    │   │   │   │   ├── OrderServlet.java
    │   │   │   │   ├── ProfileServlet.java
    │   │   │   │   ├── WishlistServlet.java
    │   │   │   │   ├── ReviewServlet.java
    │   │   │   │   ├── AdminLoginServlet.java
    │   │   │   │   ├── AdminDashboardServlet.java
    │   │   │   │   ├── AdminProductServlet.java
    │   │   │   │   ├── AdminCategoryServlet.java
    │   │   │   │   ├── AdminOrderServlet.java
    │   │   │   │   ├── AdminUserServlet.java
    │   │   │   │   ├── AdminCouponServlet.java
    │   │   │   │   └── AdminReviewServlet.java
    │   │   │   ├── service/              # Core Business Logic Layer
    │   │   │   │   ├── UserService.java
    │   │   │   │   ├── ProductService.java
    │   │   │   │   ├── CategoryService.java
    │   │   │   │   ├── CartService.java
    │   │   │   │   ├── CheckoutService.java
    │   │   │   │   ├── OrderService.java
    │   │   │   │   ├── AddressService.java
    │   │   │   │   ├── WishlistService.java
    │   │   │   │   ├── ReviewService.java
    │   │   │   │   └── CouponService.java
    │   │   │   ├── dao/                  # JDBC Data Access Layer
    │   │   │   │   ├── UserDAO.java
    │   │   │   │   ├── ProductDAO.java
    │   │   │   │   ├── CategoryDAO.java
    │   │   │   │   ├── AddressDAO.java
    │   │   │   │   ├── CartDAO.java
    │   │   │   │   ├── OrderDAO.java
    │   │   │   │   ├── PaymentDAO.java
    │   │   │   │   ├── WishlistDAO.java
    │   │   │   │   ├── ReviewDAO.java
    │   │   │   │   └── CouponDAO.java
    │   │   │   ├── model/                # Data Entities / POJOs
    │   │   │   │   ├── User.java
    │   │   │   │   ├── Product.java
    │   │   │   │   ├── Category.java
    │   │   │   │   ├── Address.java
    │   │   │   │   ├── Cart.java
    │   │   │   │   ├── CartItem.java
    │   │   │   │   ├── Order.java
    │   │   │   │   ├── OrderItem.java
    │   │   │   │   ├── Payment.java
    │   │   │   │   ├── WishlistItem.java
    │   │   │   │   ├── Review.java
    │   │   │   │   └── Coupon.java
    │   │   │   ├── filter/               # Request & Security Interceptors
    │   │   │   │   ├── EncodingFilter.java
    │   │   │   │   ├── AuthFilter.java
    │   │   │   │   └── AdminFilter.java
    │   │   │   ├── listener/             # Lifecycle Listener
    │   │   │   │   └── AppContextListener.java
    │   │   │   └── util/                 # Utilities
    │   │   │       ├── DBConnection.java
    │   │   │       └── PasswordUtil.java
    │   │   ├── resources/
    │   │   │   ├── db.properties         # JDBC Configuration
    │   │   │   ├── messages_en.properties
    │   │   │   └── messages_hi.properties
    │   │   └── webapp/                   # Frontend Web Assets & JSP Pages
    │   │       ├── index.jsp             # Home Storefront
    │   │       ├── login.jsp             # Customer Sign In
    │   │       ├── register.jsp          # Customer Registration
    │   │       ├── products.jsp          # Catalog with Search & Filters
    │   │       ├── product-details.jsp   # Product Details & Reviews
    │   │       ├── cart.jsp              # Shopping Cart
    │   │       ├── checkout.jsp          # Multi-step Checkout
    │   │       ├── order-success.jsp     # Order Confirmation Receipt
    │   │       ├── orders.jsp            # User Order History
    │   │       ├── order-details.jsp     # Order Timeline & Items
    │   │       ├── profile.jsp           # Account & Addresses Management
    │   │       ├── wishlist.jsp          # Saved Wishlist Items
    │   │       ├── fragments/            # Reusable JSP Components
    │   │       │   ├── header.jsp
    │   │       │   ├── navbar.jsp
    │   │       │   ├── footer.jsp
    │   │       │   └── sidebar.jsp
    │   │       ├── admin/                # Administrator Panel
    │   │       │   ├── login.jsp
    │   │       │   ├── dashboard.jsp
    │   │       │   ├── products.jsp
    │   │       │   ├── categories.jsp
    │   │       │   ├── orders.jsp
    │   │       │   ├── users.jsp
    │   │       │   ├── coupons.jsp
    │   │       │   └── reviews.jsp
    │   │       ├── css/style.css         # Modern Responsive Design System
    │   │       ├── js/script.js          # Interactive UI Scripts
    │   │       ├── images/               # High-Res SVG & Product Assets
    │   │       └── WEB-INF/
    │   │           ├── web.xml           # Servlet 6.0 Deployment Descriptor
    │   │           └── views/
    │   │               ├── error-404.jsp # Friendly 404 Page
    │   │               └── error-500.jsp # Friendly 500 Page
    │   └── test/java/com/shopsphere/     # JUnit 5 Automated Unit & Integration Tests
    │       ├── util/DBConnectionTest.java
    │       ├── util/PasswordUtilTest.java
    │       ├── model/ProductTest.java
    │       ├── model/CartTest.java
    │       └── service/CouponServiceTest.java
```

---

## 🌟 Key Features

### 🛒 Customer Storefront
- **Dynamic Catalog**: Full catalog browsing with brand, categories, prices, ratings, and live stock statuses.
- **Search & Multi-Facet Filtering**: Real-time keyword search, category filtering, min/max price sliders, and sorting (Price Low/High, Rating, Newest, Name).
- **Product Details & Customer Reviews**: Detailed views, verified customer reviews (1-5 stars), review submission, and related products carousel.
- **Interactive Shopping Cart**: Session-based for guests and database-persisted for registered users with automatic cart synchronization upon login.
- **Transactional Checkout**:
  - Live stock re-validation during order submission.
  - Server-side price calculation (prices are never trusted from the browser).
  - Multiple delivery addresses manager with default address selection.
  - Promo coupon redemption (`WELCOME10`, `SAVE50`).
  - Cash on Delivery (COD) and clearly labelled Sandbox Demo UPI / Card payment methods.
  - Anti-duplicate submission token protecting against double submissions.
  - Atomic database transactions with rollback on failure.
- **Order Tracking**: Visual status timeline (`Confirmed` &rarr; `Processing` &rarr; `Shipped` &rarr; `Delivered`), itemized invoices, and printable receipts.
- **Account & Address Management**: Change personal info, change password, manage delivery addresses.
- **Wishlist**: Save favorite items and move them to cart with a single click.

### 🛡️ Administrator Control Center
- **Executive Dashboard**: KPI metrics (Revenue, Orders, Products, Active Customers), and recent orders table.
- **Product Management**: Full CRUD, stock quantity adjustment, discount setup, image URL, category assignment, and status pause/activate.
- **Category Management**: Full CRUD with product count protection (prevents deletion of categories containing active products).
- **Order Management**: Real-time order inspector, fulfillment status changer (`Pending`, `Confirmed`, `Processing`, `Shipped`, `Delivered`, `Cancelled`), and payment status updater.
- **Customer Moderation**: Customer accounts list, role badges, and account suspension/activation safeguards.
- **Coupons Management**: Create percentage or fixed-amount discounts, set usage limits, minimum order thresholds, and expiry dates.
- **Review Moderation**: Moderate and remove inappropriate customer reviews.

---

## 💻 Prerequisites

Ensure you have the following installed:
1. **Java Development Kit (JDK 17 or higher)** (Java 17, 21, or 25).
2. **Apache Maven 3.9+** (Provided in user tools or system PATH).
3. **MySQL Server 8.x** (Running on port 3306).
4. **Apache Tomcat 11** (Tomcat 11 implements Jakarta EE 10 / Servlet 6.0).

---

## 🚀 Step-by-Step Setup Guide

### 1. Import MySQL Database

1. Open **MySQL Command Line Client**, **MySQL Workbench**, or your preferred SQL tool.
2. Run the SQL script located at `database/shopsphere.sql`:
   ```bash
   mysql -u root -p < "database/shopsphere.sql"
   ```
   *Or open `database/shopsphere.sql` inside MySQL Workbench and click **Execute (⚡)**.*
3. This creates the database `shopsphere` and seeds initial categories, products, coupons, and test accounts.

---

### 2. Configure Database Connection

Open `web/src/main/resources/db.properties` and verify your MySQL credentials:

```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/shopsphere?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8
db.user=root
db.password=root
```

> **Tip:** You can also override database credentials using system environment variables without changing files:
> - `DB_URL`
> - `DB_USER`
> - `DB_PASSWORD`

---

### 3. Build the Application with Maven

From the root project directory (`ShopSphere`), run:

```bash
mvn clean package
```

This compiles all 58 Java classes, executes all JUnit 5 tests, and builds the deployable WAR file:
`web/target/shopsphere.war`

---

### 4. Run on Apache Tomcat 11

#### Option A: Using the included Portable Tomcat 11
A portable Apache Tomcat 11 distribution is available at `../tools/apache-tomcat-11.0.4/`:

1. Copy the generated `web/target/shopsphere.war` into Tomcat's `webapps/` folder:
   ```powershell
   Copy-Item "web/target/shopsphere.war" -Destination "../tools/apache-tomcat-11.0.4/webapps/"
   ```
2. Start Tomcat:
   ```powershell
   & "../tools/apache-tomcat-11.0.4/bin/startup.bat"
   ```
3. Open your browser and navigate to:
   ```
   http://localhost:8080/shopsphere/
   ```
4. To stop Tomcat:
   ```powershell
   & "../tools/apache-tomcat-11.0.4/bin/shutdown.bat"
   ```

#### Option B: Using an Existing Local Tomcat 11
1. Copy `web/target/shopsphere.war` into your Tomcat installation's `webapps/` directory.
2. Start Tomcat using `bin/startup.bat` (Windows) or `bin/startup.sh` (Linux/Mac).
3. Access the web app at `http://localhost:8080/shopsphere/`.

---

### 5. Running & Debugging in VS Code

1. Install the following VS Code extensions:
   - **Extension Pack for Java** (by Microsoft)
   - **Community Server Connectors** or **Tomcat for Java**
2. Open the `ShopSphere` folder in VS Code.
3. Open the **Tomcat** panel in the Explorer sidebar.
4. Click **Add Server** and point to your Apache Tomcat 11 directory.
5. Right-click the server, choose **Add Deployment** &rarr; select `web/target/shopsphere.war`.
6. Click **Start Server** or **Debug Server**.

---

## 🔑 Demo Accounts & Credentials

| Role | Email Address | Password | Privileges |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin@shopsphere.com` | `Admin@123` | Full access to Admin Panel & Storefront |
| **Customer** | `john@example.com` | `Customer@123` | Cart, Orders, Checkout, Wishlist, Reviews |
| **Customer** | `priya@example.com` | `Customer@123` | Cart, Orders, Checkout, Wishlist, Reviews |

---

## 🧭 Application Route Cheat Sheet

### Customer Storefront
- **Home Page**: `http://localhost:8080/shopsphere/`
- **Product Catalog**: `http://localhost:8080/shopsphere/products`
- **Product Details**: `http://localhost:8080/shopsphere/product?id=1`
- **Shopping Cart**: `http://localhost:8080/shopsphere/cart`
- **Checkout**: `http://localhost:8080/shopsphere/checkout`
- **My Orders**: `http://localhost:8080/shopsphere/orders`
- **Order Details**: `http://localhost:8080/shopsphere/orders/details?orderNumber=...`
- **My Profile**: `http://localhost:8080/shopsphere/profile`
- **Wishlist**: `http://localhost:8080/shopsphere/wishlist`
- **Sign In**: `http://localhost:8080/shopsphere/login`
- **Register**: `http://localhost:8080/shopsphere/register`

### Administrator Control Center
- **Admin Login**: `http://localhost:8080/shopsphere/admin/login`
- **Admin Dashboard**: `http://localhost:8080/shopsphere/admin/dashboard`
- **Manage Products**: `http://localhost:8080/shopsphere/admin/products`
- **Manage Categories**: `http://localhost:8080/shopsphere/admin/categories`
- **Manage Orders**: `http://localhost:8080/shopsphere/admin/orders`
- **Manage Customers**: `http://localhost:8080/shopsphere/admin/users`
- **Manage Coupons**: `http://localhost:8080/shopsphere/admin/coupons`
- **Moderate Reviews**: `http://localhost:8080/shopsphere/admin/reviews`

---

## 🔒 Security & Architectural Safeguards

1. **SQL Injection Prevention**:
   - Every single SQL operation uses `PreparedStatement` with typed parameters (`?`). No dynamic string concatenation is used for SQL queries.
2. **Password Security**:
   - Passwords are never stored in plain text.
   - Hashed using **jBCrypt** with an adaptive salt work factor (`$2a$10$...`).
3. **Role-Based Server-Side Authorization (`AdminFilter`)**:
   - Every `/admin/*` endpoint is guarded by server-side checks. Non-administrators attempting to access administrative URLs receive an instant redirect or access denied response.
4. **Session Fixation Defense**:
   - `request.changeSessionId()` is invoked upon successful authentication to thwart session fixation attacks.
5. **Anti-Duplicate Submission Tokens**:
   - Cryptographically random UUID tokens ensure checkout requests cannot be double-submitted by rapid clicking or browser refresh.
6. **Stock Integrity & Server-Side Pricing**:
   - Item prices and discounts are re-queried from the MySQL database on the server at checkout. Prices submitted via browser requests are never trusted.
   - Stock is decremented within an atomic `connection.setAutoCommit(false)` transaction. If any item is out of stock, the transaction rolls back cleanly.
7. **XSS & Content Escaping**:
   - Dynamic user-supplied outputs in JSP files are escaped using `<c:out value="..."/>` to prevent Cross-Site Scripting.

---

## 🛠️ Troubleshooting & Common Solutions

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `CommunicationsException: Communications link failure` | MySQL service is stopped or port 3306 is blocked. | Start MySQL Server via Services or MySQL Workbench. Verify `db.properties`. |
| `Port 8080 already in use` | Another process is using port 8080. | Stop the conflicting process or change port in `conf/server.xml` to `8088`. |
| `ClassCastException: ... jakarta.servlet.*` | Using an old Tomcat version (Tomcat 9 or 8). | ShopSphere uses Jakarta EE 10. Run on **Apache Tomcat 11** or **Tomcat 10.1+**. |
| `404 Not Found on index.jsp` | WAR name was changed. | The WAR is packaged as `shopsphere.war`. Ensure the context path matches `/shopsphere`. |
| Images display as placeholders | External image URLs blocked. | ShopSphere includes built-in high-resolution SVG product artwork stored locally in `images/`. |

---

## 📜 License & Academic Integrity
Created for educational purposes, software engineering demonstrations, and university project submissions. Feel free to customize and extend!
