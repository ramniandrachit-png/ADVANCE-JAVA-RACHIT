<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Shopping Cart - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <h1 style="font-size: 1.85rem; font-weight: 800; color: #1e1b4b; margin-bottom: 24px;">Your Shopping Cart</h1>

        <c:choose>
            <c:when test="${not empty cart and not empty cart.items}">
                <div class="cart-layout">
                    <!-- Cart Items Table -->
                    <div class="cart-table-card">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Unit Price</th>
                                    <th>Quantity</th>
                                    <th>Subtotal</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${cart.items}">
                                    <tr>
                                        <td>
                                            <div class="cart-item-row">
                                                <img src="${pageContext.request.contextPath}/${item.product.imageUrl}" alt="${item.product.name}" class="cart-item-thumb">
                                                <div>
                                                    <div style="font-size: 0.8rem; font-weight: 700; color: var(--primary); text-transform: uppercase;">
                                                        <c:out value="${item.product.brand}"/>
                                                    </div>
                                                    <a href="${pageContext.request.contextPath}/product?id=${item.productId}" style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">
                                                        <c:out value="${item.product.name}"/>
                                                    </a>
                                                </div>
                                            </div>
                                        </td>
                                        <td style="font-weight: 600;">
                                            $<fmt:formatNumber value="${item.product.discountedPrice}" minFractionDigits="2" maxFractionDigits="2"/>
                                        </td>
                                        <td>
                                            <!-- Update Quantity Form -->
                                            <form action="${pageContext.request.contextPath}/cart" method="post" style="display: flex; align-items: center;">
                                                <input type="hidden" name="action" value="update">
                                                <input type="hidden" name="productId" value="${item.productId}">
                                                <div class="quantity-picker" style="margin-bottom: 0;">
                                                    <button type="submit" name="quantity" value="${item.quantity - 1}" class="qty-btn">-</button>
                                                    <input type="text" class="qty-input" value="${item.quantity}" readonly>
                                                    <button type="submit" name="quantity" value="${item.quantity + 1}" class="qty-btn" ${item.quantity >= item.product.stock ? 'disabled' : ''}>+</button>
                                                </div>
                                            </form>
                                        </td>
                                        <td style="font-weight: 700; color: #0f172a; font-size: 1.05rem;">
                                            $<fmt:formatNumber value="${item.subtotal}" minFractionDigits="2" maxFractionDigits="2"/>
                                        </td>
                                        <td>
                                            <form action="${pageContext.request.contextPath}/cart" method="post">
                                                <input type="hidden" name="action" value="remove">
                                                <input type="hidden" name="productId" value="${item.productId}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Remove Item">
                                                    🗑️
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 20px; border-top: 1px solid var(--border-color);">
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary">
                                &larr; Continue Shopping
                            </a>

                            <form action="${pageContext.request.contextPath}/cart" method="post">
                                <input type="hidden" name="action" value="clear">
                                <button type="submit" class="btn btn-outline-danger btn-sm" data-confirm="Are you sure you want to empty your entire cart?">
                                    Clear Cart
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Order Summary Card -->
                    <div class="cart-summary-card">
                        <h3 style="font-size: 1.25rem; font-weight: 800; color: #1e1b4b; margin-bottom: 20px;">Order Summary</h3>

                        <div class="summary-row">
                            <span>Items Subtotal (${cart.totalQuantity} pcs):</span>
                            <span style="font-weight: 600;">$<fmt:formatNumber value="${cart.subtotal}" minFractionDigits="2" maxFractionDigits="2"/></span>
                        </div>

                        <c:if test="${not empty cart.appliedCoupon}">
                            <div class="summary-row" style="color: var(--success); font-weight: 600;">
                                <span>Coupon (${cart.appliedCoupon.code}):</span>
                                <span>-$<fmt:formatNumber value="${cart.couponDiscount}" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </div>
                        </c:if>

                        <div class="summary-row">
                            <span>Shipping Fee:</span>
                            <c:choose>
                                <c:when test="${cart.shippingFee == 0}">
                                    <span style="color: var(--success); font-weight: 700;">FREE</span>
                                </c:when>
                                <c:otherwise>
                                    <span>$<fmt:formatNumber value="${cart.shippingFee}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="summary-total">
                            <span>Grand Total:</span>
                            <span>$<fmt:formatNumber value="${cart.grandTotal}" minFractionDigits="2" maxFractionDigits="2"/></span>
                        </div>

                        <!-- Coupon Form -->
                        <c:choose>
                            <c:when test="${not empty cart.appliedCoupon}">
                                <div style="background-color: var(--success-light); border: 1px solid #a7f3d0; border-radius: var(--radius-md); padding: 12px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                                    <span style="font-size: 0.85rem; color: #065f46; font-weight: 600;">
                                        🏷️ Code <strong>${cart.appliedCoupon.code}</strong> applied!
                                    </span>
                                    <form action="${pageContext.request.contextPath}/cart" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="removeCoupon">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" style="padding: 2px 8px; font-size: 0.75rem;">Remove</button>
                                    </form>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/cart" method="post" class="coupon-box">
                                    <input type="hidden" name="action" value="applyCoupon">
                                    <input type="text" name="couponCode" class="form-control" placeholder="Promo / Coupon Code" style="text-transform: uppercase;" required>
                                    <button type="submit" class="btn btn-secondary">Apply</button>
                                </form>
                                <div style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 20px;">
                                    Try: <code>WELCOME10</code> or <code>SAVE50</code>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary btn-block btn-lg">
                            Proceed to Checkout &rarr;
                        </a>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <!-- Empty Cart State -->
                <div style="background-color: var(--bg-surface); border: 1px dashed var(--border-color); border-radius: var(--radius-lg); padding: 80px 20px; text-align: center; max-width: 600px; margin: 40px auto;">
                    <div style="font-size: 4rem; margin-bottom: 16px;">🛒</div>
                    <h2 style="font-size: 1.5rem; font-weight: 800; color: #1e1b4b; margin-bottom: 8px;">Your Shopping Cart is Empty</h2>
                    <p style="color: var(--text-muted); margin-bottom: 28px;">Looks like you haven't added any products to your cart yet. Explore our premier catalog to find exciting offers.</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">Start Shopping Now</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
