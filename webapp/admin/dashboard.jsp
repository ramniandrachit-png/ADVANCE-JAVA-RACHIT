<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - ShopSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="admin-layout">
        <c:set var="pageTitle" value="Admin Dashboard" scope="request"/>
        <jsp:include page="../fragments/sidebar.jsp"/>

        <main class="admin-main">
            <!-- Header bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px;">
                <div>
                    <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">Executive Store Dashboard</h1>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Real-time overview of orders, revenue, inventory, and active customers</p>
                </div>

                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-primary btn-sm">+ Add New Product</a>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary btn-sm">Process Orders</a>
                </div>
            </div>

            <!-- Global Flash Alerts -->
            <c:if test="${not empty sessionScope.flashSuccess}">
                <div class="alert alert-success">
                    <span>✓ <c:out value="${sessionScope.flashSuccess}"/></span>
                    <button type="button" class="alert-close" onclick="this.parentElement.remove()">×</button>
                </div>
                <c:remove var="flashSuccess" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.flashError}">
                <div class="alert alert-danger">
                    <span>⚠️ <c:out value="${sessionScope.flashError}"/></span>
                    <button type="button" class="alert-close" onclick="this.parentElement.remove()">×</button>
                </div>
                <c:remove var="flashError" scope="session"/>
            </c:if>

            <!-- Metrics Cards Grid -->
            <div class="admin-metrics">
                <div class="metric-card">
                    <div class="metric-icon green">💰</div>
                    <div>
                        <div class="metric-value">$<fmt:formatNumber value="${totalRevenue}" minFractionDigits="2" maxFractionDigits="2"/></div>
                        <div class="metric-label">Total Store Revenue</div>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon blue">🛍️</div>
                    <div>
                        <div class="metric-value">${totalOrders}</div>
                        <div class="metric-label">Total Completed Orders</div>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon purple">📦</div>
                    <div>
                        <div class="metric-value">${totalProducts}</div>
                        <div class="metric-label">Products in Catalog</div>
                    </div>
                </div>

                <div class="metric-card">
                    <div class="metric-icon orange">👥</div>
                    <div>
                        <div class="metric-value">${totalCustomers}</div>
                        <div class="metric-label">Active Customers</div>
                    </div>
                </div>
            </div>

            <!-- Recent Orders Section -->
            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 24px; box-shadow: var(--shadow-sm);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h3 style="font-size: 1.25rem; font-weight: 800; color: #0f172a;">Recent Orders</h3>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary btn-sm">View All Orders &rarr;</a>
                </div>

                <c:choose>
                    <c:when test="${not empty recentOrders}">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Order #</th>
                                    <th>Customer</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Payment</th>
                                    <th>Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="ord" items="${recentOrders}">
                                    <tr>
                                        <td style="font-weight: 700; color: var(--primary);">${ord.orderNumber}</td>
                                        <td>
                                            <div style="font-weight: 600;"><c:out value="${ord.userName}"/></div>
                                            <div style="font-size: 0.8rem; color: var(--text-muted);"><c:out value="${ord.userEmail}"/></div>
                                        </td>
                                        <td style="font-weight: 700;">$<fmt:formatNumber value="${ord.totalAmount}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                        <td>
                                            <span class="badge badge-${ord.orderStatus.name().toLowerCase()}">
                                                ${ord.orderStatus}
                                            </span>
                                        </td>
                                        <td>
                                            <span style="font-size: 0.85rem; font-weight: 600;">${ord.paymentStatus}</span>
                                        </td>
                                        <td style="font-size: 0.85rem; color: var(--text-muted);">
                                            <fmt:formatDate value="${ord.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/orders?id=${ord.id}" class="btn btn-sm btn-secondary">
                                                Manage
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p style="color: var(--text-muted); padding: 20px 0; font-style: italic;">No orders placed yet.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>
