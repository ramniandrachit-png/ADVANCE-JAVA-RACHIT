<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Order #${order.orderNumber} - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container" style="max-width: 900px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
            <div>
                <a href="${pageContext.request.contextPath}/orders" style="font-size: 0.9rem; color: var(--text-muted);">&larr; Back to Orders</a>
                <h1 style="font-size: 1.85rem; font-weight: 800; color: #1e1b4b; margin-top: 4px;">
                    Order #${order.orderNumber}
                </h1>
            </div>
            <div>
                <button type="button" onclick="window.print()" class="btn btn-secondary btn-sm">🖨️ Print Invoice</button>
            </div>
        </div>

        <!-- Order Status Progress Tracker -->
        <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 24px; margin-bottom: 30px; box-shadow: var(--shadow-sm);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <span style="font-size: 0.9rem; font-weight: 700; color: #334155;">Current Fulfillment Status:</span>
                <span class="badge badge-${order.orderStatus.name().toLowerCase()}" style="font-size: 0.85rem; padding: 6px 14px;">
                    ${order.orderStatus}
                </span>
            </div>

            <!-- Visual Progress Dots -->
            <div style="display: flex; justify-content: space-between; position: relative; margin: 30px 20px 10px;">
                <div style="position: absolute; top: 12px; left: 0; right: 0; height: 4px; background-color: var(--border-color); z-index: 1;"></div>
                
                <div style="position: relative; z-index: 2; text-align: center;">
                    <div style="width: 28px; height: 28px; border-radius: 50%; background-color: var(--primary); color: #ffffff; display: flex; align-items: center; justify-content: center; margin: 0 auto 6px; font-weight: 700; font-size: 0.8rem;">1</div>
                    <span style="font-size: 0.8rem; font-weight: 600;">Confirmed</span>
                </div>

                <div style="position: relative; z-index: 2; text-align: center;">
                    <div style="width: 28px; height: 28px; border-radius: 50%; background-color: ${order.orderStatus == 'PROCESSING' or order.orderStatus == 'SHIPPED' or order.orderStatus == 'DELIVERED' ? 'var(--primary)' : 'var(--bg-subtle)'}; color: ${order.orderStatus == 'PROCESSING' or order.orderStatus == 'SHIPPED' or order.orderStatus == 'DELIVERED' ? '#fff' : 'var(--text-muted)'}; display: flex; align-items: center; justify-content: center; margin: 0 auto 6px; font-weight: 700; font-size: 0.8rem;">2</div>
                    <span style="font-size: 0.8rem; font-weight: 600;">Processing</span>
                </div>

                <div style="position: relative; z-index: 2; text-align: center;">
                    <div style="width: 28px; height: 28px; border-radius: 50%; background-color: ${order.orderStatus == 'SHIPPED' or order.orderStatus == 'DELIVERED' ? 'var(--primary)' : 'var(--bg-subtle)'}; color: ${order.orderStatus == 'SHIPPED' or order.orderStatus == 'DELIVERED' ? '#fff' : 'var(--text-muted)'}; display: flex; align-items: center; justify-content: center; margin: 0 auto 6px; font-weight: 700; font-size: 0.8rem;">3</div>
                    <span style="font-size: 0.8rem; font-weight: 600;">Shipped</span>
                </div>

                <div style="position: relative; z-index: 2; text-align: center;">
                    <div style="width: 28px; height: 28px; border-radius: 50%; background-color: ${order.orderStatus == 'DELIVERED' ? 'var(--success)' : 'var(--bg-subtle)'}; color: ${order.orderStatus == 'DELIVERED' ? '#fff' : 'var(--text-muted)'}; display: flex; align-items: center; justify-content: center; margin: 0 auto 6px; font-weight: 700; font-size: 0.8rem;">4</div>
                    <span style="font-size: 0.8rem; font-weight: 600;">Delivered</span>
                </div>
            </div>
        </div>

        <!-- Items Table -->
        <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 28px; margin-bottom: 30px; box-shadow: var(--shadow-sm);">
            <h3 style="font-size: 1.15rem; font-weight: 800; color: #1e1b4b; margin-bottom: 16px;">Items in this Order</h3>
            <table class="table">
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Unit Price</th>
                        <th>Qty</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${order.items}">
                        <tr>
                            <td>
                                <div class="cart-item-row">
                                    <img src="${pageContext.request.contextPath}/${item.productImageUrl}" alt="${item.productName}" class="cart-item-thumb">
                                    <div>
                                        <a href="${pageContext.request.contextPath}/product?id=${item.productId}" style="font-weight: 700; color: #1e293b;">
                                            <c:out value="${item.productName}"/>
                                        </a>
                                    </div>
                                </div>
                            </td>
                            <td>$<fmt:formatNumber value="${item.unitPrice}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td style="font-weight: 700;">${item.quantity}</td>
                            <td style="font-weight: 700; color: #0f172a;">$<fmt:formatNumber value="${item.subtotal}" minFractionDigits="2" maxFractionDigits="2"/></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <!-- Financial Summary -->
            <div style="max-width: 340px; margin-left: auto; margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                <div class="summary-row">
                    <span>Subtotal:</span>
                    <span>$<fmt:formatNumber value="${order.subtotal}" minFractionDigits="2" maxFractionDigits="2"/></span>
                </div>
                <c:if test="${order.discountAmount > 0}">
                    <div class="summary-row" style="color: var(--success); font-weight: 600;">
                        <span>Discount (${order.couponCode}):</span>
                        <span>-$<fmt:formatNumber value="${order.discountAmount}" minFractionDigits="2" maxFractionDigits="2"/></span>
                    </div>
                </c:if>
                <div class="summary-row">
                    <span>Shipping Fee:</span>
                    <span>${order.shippingFee == 0 ? 'FREE' : '$' + order.shippingFee}</span>
                </div>
                <div class="summary-total" style="margin-bottom: 0;">
                    <span>Grand Total:</span>
                    <span>$<fmt:formatNumber value="${order.totalAmount}" minFractionDigits="2" maxFractionDigits="2"/></span>
                </div>
            </div>
        </div>

        <!-- Shipping & Payment Details Cards -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 40px;">
            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 24px;">
                <h4 style="font-size: 1rem; font-weight: 700; margin-bottom: 12px; color: #1e1b4b;">📦 Delivery Address</h4>
                <div style="font-size: 0.95rem; color: #334155; line-height: 1.6;">
                    <strong><c:out value="${order.recipientName}"/></strong><br>
                    Phone: <c:out value="${order.recipientPhone}"/><br>
                    <c:out value="${order.shippingAddress}"/>
                </div>
            </div>

            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 24px;">
                <h4 style="font-size: 1rem; font-weight: 700; margin-bottom: 12px; color: #1e1b4b;">💳 Payment Information</h4>
                <div style="font-size: 0.95rem; color: #334155; line-height: 1.6;">
                    Method: <strong>${order.paymentMethod}</strong><br>
                    Status: <span style="font-weight: 700; color: ${order.paymentStatus == 'PAID' ? 'var(--success)' : 'var(--warning)'};">${order.paymentStatus}</span><br>
                    Ordered On: <fmt:formatDate value="${order.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
