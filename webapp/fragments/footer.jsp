<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <footer class="site-footer">
        <div class="container">
            <div class="footer-grid">
                <div>
                    <div class="brand-logo" style="color: #ffffff;">
                        <div class="brand-icon">S</div>
                        <span>Shop</span>Sphere
                    </div>
                    <p class="footer-brand-desc">
                        ShopSphere is a premier full-stack enterprise e-commerce platform built with robust Java Servlets, JSP, JSTL, and MySQL. Delivering seamless shopping experiences.
                    </p>
                </div>
                <div>
                    <h4 class="footer-col-title">Shop by Category</h4>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/products?category=electronics">Electronics & Gadgets</a></li>
                        <li><a href="${pageContext.request.contextPath}/products?category=fashion">Fashion & Apparel</a></li>
                        <li><a href="${pageContext.request.contextPath}/products?category=home-living">Home & Living</a></li>
                        <li><a href="${pageContext.request.contextPath}/products?category=sports-fitness">Sports & Fitness</a></li>
                        <li><a href="${pageContext.request.contextPath}/products?category=books-stationery">Books & Stationery</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-col-title">Customer Service</h4>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/orders">Order Tracking</a></li>
                        <li><a href="${pageContext.request.contextPath}/cart">View Cart</a></li>
                        <li><a href="${pageContext.request.contextPath}/wishlist">My Wishlist</a></li>
                        <li><a href="${pageContext.request.contextPath}/profile">My Profile & Addresses</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-col-title">Demo Credentials</h4>
                    <ul class="footer-links" style="font-size: 0.85rem; line-height: 1.8;">
                        <li><strong>Customer:</strong> john@example.com</li>
                        <li><strong>Password:</strong> Customer@123</li>
                        <li><strong>Admin:</strong> admin@shopsphere.com</li>
                        <li><strong>Password:</strong> Admin@123</li>
                        <li><a href="${pageContext.request.contextPath}/admin/login" style="color: #facc15; font-weight: bold; margin-top: 8px; display: inline-block;">Admin Portal &rarr;</a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="footer-bottom">
            <div class="container">
                <p>&copy; 2026 ShopSphere E-Commerce System. All Rights Reserved. Built with Jakarta Servlets 6.0 &amp; Tomcat 11.</p>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>
