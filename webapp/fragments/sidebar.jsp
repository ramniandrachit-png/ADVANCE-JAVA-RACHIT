<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="admin-sidebar">
    <div style="padding: 0 24px 20px 24px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); margin-bottom: 20px;">
        <div class="brand-logo" style="color: #ffffff; font-size: 1.25rem;">
            <div class="brand-icon" style="width: 30px; height: 30px; font-size: 1rem;">A</div>
            <span>Admin</span>Sphere
        </div>
        <div style="font-size: 0.8rem; color: #a5b4fc; margin-top: 4px;">Logged in as: ${sessionScope.currentUser.name}</div>
    </div>

    <ul class="admin-nav">
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-nav-link ${pageTitle == 'Admin Dashboard' ? 'active' : ''}">
                📊 Dashboard
            </a>
        </li>
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/admin/products" class="admin-nav-link ${pageTitle == 'Manage Products' ? 'active' : ''}">
                📦 Products
            </a>
        </li>
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/admin/categories" class="admin-nav-link ${pageTitle == 'Manage Categories' ? 'active' : ''}">
                🗂️ Categories
            </a>
        </li>
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/admin/orders" class="admin-nav-link ${pageTitle == 'Manage Orders' ? 'active' : ''}">
                🛍️ Orders
            </a>
        </li>
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/admin/users" class="admin-nav-link ${pageTitle == 'Manage Customers' ? 'active' : ''}">
                👥 Customers
            </a>
        </li>
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/admin/coupons" class="admin-nav-link ${pageTitle == 'Manage Coupons' ? 'active' : ''}">
                🏷️ Coupons &amp; Discounts
            </a>
        </li>
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/admin/reviews" class="admin-nav-link ${pageTitle == 'Manage Reviews' ? 'active' : ''}">
                ⭐ Reviews Moderation
            </a>
        </li>
        <li class="admin-nav-item" style="margin-top: 30px; padding-top: 15px; border-top: 1px solid rgba(255, 255, 255, 0.1);">
            <a href="${pageContext.request.contextPath}/" class="admin-nav-link" target="_blank">
                🌐 View Storefront &rarr;
            </a>
        </li>
        <li class="admin-nav-item">
            <a href="${pageContext.request.contextPath}/logout" class="admin-nav-link" style="color: #f87171;">
                🚪 Logout
            </a>
        </li>
    </ul>
</aside>
