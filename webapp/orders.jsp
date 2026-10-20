<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="My Orders - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
            <h1 style="font-size: 1.85rem; font-weight: 800; color: #1e1b4b;">My Order History</h1>
            <a href="${pageContext.request.contextPath}/profile" class="btn btn-secondary btn-sm">&larr; Back to Profile</a>
        </div>

        <c:choose>
            <c:when test="${not empty orders}">
                <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-sm);">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Items</th>
                                <th>Total</th>
                                <th>Order Status</th>
                                <th>Payment</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="ord" items="${orders}">
                                <tr>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/orders/details?orderNumber=${ord.orderNumber}" style="font-weight: 700; color: var(--primary);">
                                            ${ord.orderNumber}
                                        </a>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${ord.createdAt}" pattern="MMM dd, yyyy"/>
                                    </td>
                                    <td>
                                        ${ord.totalQuantity} items
                                    </td>
                                    <td style="font-weight: 800; color: #0f172a;">
                                        $<fmt:formatNumber value="${ord.totalAmount}" minFractionDigits="2" maxFractionDigits="2"/>
                                    </td>
                                    <td>
                                        <span class="badge badge-${ord.orderStatus.name().toLowerCase()}">
                                            ${ord.orderStatus}
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-size: 0.85rem; font-weight: 600;">
                                            ${ord.paymentMethod}
                                            <span style="color: ${ord.paymentStatus.name() == 'PAID' ? 'var(--success)' : 'var(--warning)'}; font-weight: 700;">
                                                (${ord.paymentStatus})
                                            </span>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/orders/details?orderNumber=${ord.orderNumber}" class="btn btn-sm btn-secondary">
                                            View Details
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>

            <c:otherwise>
                <div style="background-color: var(--bg-surface); border: 1px dashed var(--border-color); border-radius: var(--radius-lg); padding: 80px 20px; text-align: center; max-width: 600px; margin: 40px auto;">
                    <div style="font-size: 3.5rem; margin-bottom: 16px;">📦</div>
                    <h2 style="font-size: 1.5rem; font-weight: 800; color: #1e1b4b; margin-bottom: 8px;">No Orders Found</h2>
                    <p style="color: var(--text-muted); margin-bottom: 24px;">You haven't placed any orders yet. Start exploring our catalog to make your first purchase!</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">Browse Products</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
