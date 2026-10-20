<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders - ShopSphere Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="admin-layout">
        <c:set var="pageTitle" value="Manage Orders" scope="request"/>
        <jsp:include page="../fragments/sidebar.jsp"/>

        <main class="admin-main">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">Customer Orders Management</h1>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Track shipments, verify payments, and update fulfillment statuses</p>
                </div>
            </div>

            <!-- Flash Alerts -->
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

            <!-- Selected Order Quick Inspection Card (if param ?id=...) -->
            <c:if test="${not empty selectedOrder}">
                <div style="background-color: var(--bg-surface); border: 2px solid var(--primary); border-radius: var(--radius-lg); padding: 24px; margin-bottom: 30px; box-shadow: var(--shadow-md);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                        <h3 style="font-size: 1.2rem; font-weight: 800; color: #1e1b4b;">
                            Inspecting Order #${selectedOrder.orderNumber}
                        </h3>
                        <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-sm btn-secondary">Close Inspector &times;</a>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 16px; font-size: 0.95rem;">
                        <div>
                            <strong>Customer:</strong> <c:out value="${selectedOrder.userName}"/> (<c:out value="${selectedOrder.userEmail}"/>)<br>
                            <strong>Recipient:</strong> <c:out value="${selectedOrder.recipientName}"/> (<c:out value="${selectedOrder.recipientPhone}"/>)<br>
                            <strong>Shipping Address:</strong> <c:out value="${selectedOrder.shippingAddress}"/>
                        </div>
                        <div>
                            <strong>Total Amount:</strong> $<fmt:formatNumber value="${selectedOrder.totalAmount}" minFractionDigits="2" maxFractionDigits="2"/><br>
                            <strong>Payment Method:</strong> ${selectedOrder.paymentMethod} (${selectedOrder.paymentStatus})<br>
                            <strong>Placed On:</strong> <fmt:formatDate value="${selectedOrder.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                        </div>
                    </div>

                    <h4 style="font-size: 0.95rem; font-weight: 700; margin-bottom: 8px;">Order Items:</h4>
                    <ul style="list-style: none; margin-bottom: 20px;">
                        <c:forEach var="item" items="${selectedOrder.items}">
                            <li style="padding: 6px 0; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between;">
                                <span><strong>${item.quantity}x</strong> <c:out value="${item.productName}"/></span>
                                <span>$<fmt:formatNumber value="${item.subtotal}" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </li>
                        </c:forEach>
                    </ul>

                    <!-- Update Status Inline Forms -->
                    <div style="display: flex; gap: 20px; align-items: flex-end;">
                        <form action="${pageContext.request.contextPath}/admin/orders" method="post" style="display: flex; gap: 8px; align-items: flex-end;">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="orderId" value="${selectedOrder.id}">
                            <div>
                                <label class="form-label">Change Fulfillment Status</label>
                                <select name="orderStatus" class="form-control" style="width: auto;">
                                    <option value="PENDING" ${selectedOrder.orderStatus == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                    <option value="CONFIRMED" ${selectedOrder.orderStatus == 'CONFIRMED' ? 'selected' : ''}>CONFIRMED</option>
                                    <option value="PROCESSING" ${selectedOrder.orderStatus == 'PROCESSING' ? 'selected' : ''}>PROCESSING</option>
                                    <option value="SHIPPED" ${selectedOrder.orderStatus == 'SHIPPED' ? 'selected' : ''}>SHIPPED</option>
                                    <option value="DELIVERED" ${selectedOrder.orderStatus == 'DELIVERED' ? 'selected' : ''}>DELIVERED</option>
                                    <option value="CANCELLED" ${selectedOrder.orderStatus == 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary">Update Status</button>
                        </form>

                        <form action="${pageContext.request.contextPath}/admin/orders" method="post" style="display: flex; gap: 8px; align-items: flex-end;">
                            <input type="hidden" name="action" value="updatePayment">
                            <input type="hidden" name="orderId" value="${selectedOrder.id}">
                            <div>
                                <label class="form-label">Payment Status</label>
                                <select name="paymentStatus" class="form-control" style="width: auto;">
                                    <option value="PENDING" ${selectedOrder.paymentStatus == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                    <option value="PAID" ${selectedOrder.paymentStatus == 'PAID' ? 'selected' : ''}>PAID</option>
                                    <option value="FAILED" ${selectedOrder.paymentStatus == 'FAILED' ? 'selected' : ''}>FAILED</option>
                                    <option value="REFUNDED" ${selectedOrder.paymentStatus == 'REFUNDED' ? 'selected' : ''}>REFUNDED</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-secondary">Update Payment</button>
                        </form>
                    </div>
                </div>
            </c:if>

            <!-- Orders Table -->
            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-sm);">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Order #</th>
                            <th>Customer</th>
                            <th>Total Due</th>
                            <th>Fulfillment</th>
                            <th>Payment</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ord" items="${orders}">
                            <tr>
                                <td>
                                    <a href="${pageContext.request.contextPath}/admin/orders?id=${ord.id}" style="font-weight: 700; color: var(--primary);">
                                        ${ord.orderNumber}
                                    </a>
                                </td>
                                <td>
                                    <div style="font-weight: 600;"><c:out value="${ord.userName}"/></div>
                                    <div style="font-size: 0.8rem; color: var(--text-muted);"><c:out value="${ord.userEmail}"/></div>
                                </td>
                                <td style="font-weight: 700;">
                                    $<fmt:formatNumber value="${ord.totalAmount}" minFractionDigits="2" maxFractionDigits="2"/>
                                </td>
                                <td>
                                    <span class="badge badge-${ord.orderStatus.name().toLowerCase()}">
                                        ${ord.orderStatus}
                                    </span>
                                </td>
                                <td>
                                    <span style="font-size: 0.85rem; font-weight: 700; color: ${ord.paymentStatus == 'PAID' ? 'var(--success)' : 'var(--warning)'};">
                                        ${ord.paymentStatus}
                                    </span>
                                    <div style="font-size: 0.75rem; color: var(--text-muted);">${ord.paymentMethod}</div>
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
            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>
