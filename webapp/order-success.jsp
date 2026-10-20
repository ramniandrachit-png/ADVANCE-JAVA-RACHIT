<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Order Placed Successfully! - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container" style="max-width: 800px;">
        <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 40px; box-shadow: var(--shadow-md); text-align: center;">
            <div style="width: 72px; height: 72px; background-color: var(--success-light); color: var(--success); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2.2rem; margin: 0 auto 20px;">
                ✓
            </div>

            <h1 style="font-size: 2rem; font-weight: 800; color: #1e1b4b; margin-bottom: 8px;">Order Confirmed!</h1>
            <p style="color: var(--text-muted); font-size: 1.05rem; margin-bottom: 24px;">
                Thank you for shopping with ShopSphere. Your order has been placed and is being prepared for dispatch.
            </p>

            <div style="background-color: var(--bg-subtle); padding: 16px 24px; border-radius: var(--radius-md); display: inline-flex; gap: 30px; text-align: left; margin-bottom: 30px; flex-wrap: wrap;">
                <div>
                    <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Order Number</span>
                    <div style="font-weight: 800; font-size: 1.1rem; color: var(--primary);">${order.orderNumber}</div>
                </div>
                <div>
                    <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Date</span>
                    <div style="font-weight: 700; font-size: 1rem;"><fmt:formatDate value="${order.createdAt}" pattern="MMM dd, yyyy HH:mm"/></div>
                </div>
                <div>
                    <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Total Amount</span>
                    <div style="font-weight: 800; font-size: 1.1rem; color: #0f172a;">$<fmt:formatNumber value="${order.totalAmount}" minFractionDigits="2" maxFractionDigits="2"/></div>
                </div>
                <div>
                    <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Payment</span>
                    <div style="font-weight: 700; font-size: 1rem;">${order.paymentMethod} (${order.paymentStatus})</div>
                </div>
            </div>

            <!-- Receipt Breakdown Table -->
            <div style="text-align: left; margin-bottom: 30px;">
                <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 14px; border-bottom: 1px solid var(--border-color); padding-bottom: 8px;">Purchased Items</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Quantity</th>
                            <th>Unit Price</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${order.items}">
                            <tr>
                                <td style="font-weight: 600;"><c:out value="${item.productName}"/></td>
                                <td>${item.quantity}</td>
                                <td>$<fmt:formatNumber value="${item.unitPrice}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                <td style="font-weight: 700;">$<fmt:formatNumber value="${item.subtotal}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <div style="background-color: var(--bg-subtle); padding: 16px; border-radius: var(--radius-md); margin-top: 20px;">
                    <div style="font-weight: 700; font-size: 0.95rem; margin-bottom: 6px;">📦 Shipping To:</div>
                    <div style="font-size: 0.9rem; color: #334155;">
                        <strong><c:out value="${order.recipientName}"/></strong> (${order.recipientPhone})<br>
                        <c:out value="${order.shippingAddress}"/>
                    </div>
                </div>
            </div>

            <div style="display: flex; gap: 14px; justify-content: center; flex-wrap: wrap;">
                <button type="button" onclick="window.print()" class="btn btn-secondary">
                    🖨️ Print Receipt
                </button>
                <a href="${pageContext.request.contextPath}/orders" class="btn btn-secondary">
                    View My Orders
                </a>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                    Continue Shopping &rarr;
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
