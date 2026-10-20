<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Coupons - ShopSphere Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="admin-layout">
        <c:set var="pageTitle" value="Manage Coupons" scope="request"/>
        <jsp:include page="../fragments/sidebar.jsp"/>

        <main class="admin-main">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">Coupons &amp; Promotional Codes</h1>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Configure marketing promotions, discount percentages, and minimum thresholds</p>
                </div>
                <button type="button" class="btn btn-primary" onclick="openModal('addCouponModal')">+ Create Coupon</button>
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

            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-sm);">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Coupon Code</th>
                            <th>Discount</th>
                            <th>Min. Order</th>
                            <th>Usage Limit</th>
                            <th>Times Used</th>
                            <th>Expiry Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cp" items="${coupons}">
                            <tr>
                                <td>
                                    <span style="font-family: monospace; font-size: 1.05rem; font-weight: 800; color: var(--primary); background: var(--primary-light); padding: 4px 8px; border-radius: 4px;">
                                        ${cp.code}
                                    </span>
                                </td>
                                <td style="font-weight: 700;">
                                    <c:choose>
                                        <c:when test="${cp.discountType == 'PERCENTAGE'}">
                                            <fmt:formatNumber value="${cp.discountValue}" maxFractionDigits="0"/>% OFF
                                        </c:when>
                                        <c:otherwise>
                                            $<fmt:formatNumber value="${cp.discountValue}" minFractionDigits="2"/> FLAT OFF
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>$<fmt:formatNumber value="${cp.minOrderAmount}" minFractionDigits="2"/></td>
                                <td>${cp.usageLimit}</td>
                                <td style="font-weight: 700; color: #1e1b4b;">${cp.timesUsed}</td>
                                <td><fmt:formatDate value="${cp.expiryDate}" pattern="yyyy-MM-dd"/></td>
                                <td>
                                    <span class="badge ${cp.status == 'ACTIVE' ? 'badge-active' : 'badge-inactive'}">
                                        ${cp.status}
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <form action="${pageContext.request.contextPath}/admin/coupons" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="toggleStatus">
                                            <input type="hidden" name="id" value="${cp.id}">
                                            <button type="submit" class="btn btn-sm btn-secondary">
                                                ${cp.status == 'ACTIVE' ? 'Disable' : 'Enable'}
                                            </button>
                                        </form>

                                        <form action="${pageContext.request.contextPath}/admin/coupons" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${cp.id}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" data-confirm="Delete this coupon?">
                                                🗑️
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- Add Coupon Modal -->
    <div id="addCouponModal" class="modal">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 class="modal-title">Create Promo Coupon</h3>
                <button type="button" class="modal-close" onclick="closeModal('addCouponModal')">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/coupons" method="post">
                <input type="hidden" name="action" value="create">

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Coupon Code (Alphanumeric)</label>
                        <input type="text" name="code" class="form-control" placeholder="e.g. SUMMER30" required style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Discount Type</label>
                        <select name="discountType" class="form-control" required>
                            <option value="PERCENTAGE">PERCENTAGE (%)</option>
                            <option value="FIXED">FIXED ($)</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Discount Value</label>
                        <input type="number" step="0.01" name="discountValue" class="form-control" placeholder="e.g. 15.00" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Min. Order Value ($)</label>
                        <input type="number" step="0.01" name="minOrderAmount" class="form-control" value="0.00" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Usage Limit</label>
                        <input type="number" name="usageLimit" class="form-control" value="100" min="1" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Expiry Date</label>
                        <input type="date" name="expiryDate" class="form-control" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Initial Status</label>
                    <select name="status" class="form-control">
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="DISABLED">DISABLED</option>
                    </select>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('addCouponModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Coupon</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>
