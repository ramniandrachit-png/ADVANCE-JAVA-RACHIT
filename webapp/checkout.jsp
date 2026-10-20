<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Secure Checkout - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <h1 style="font-size: 1.85rem; font-weight: 800; color: #1e1b4b; margin-bottom: 24px;">Secure Checkout</h1>

        <form action="${pageContext.request.contextPath}/checkout" method="post" id="checkoutForm">
            <!-- CSRF & Idempotency Token to prevent duplicate orders -->
            <input type="hidden" name="checkoutToken" value="${checkoutToken}">
            <c:if test="${not empty cart.appliedCoupon}">
                <input type="hidden" name="couponCode" value="${cart.appliedCoupon.code}">
            </c:if>

            <div class="cart-layout">
                <!-- Left Column: Shipping & Payment -->
                <div>
                    <!-- Section 1: Shipping Address -->
                    <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 28px; margin-bottom: 24px; box-shadow: var(--shadow-sm);">
                        <h2 style="font-size: 1.25rem; font-weight: 800; color: #1e1b4b; margin-bottom: 18px; display: flex; align-items: center; gap: 8px;">
                            <span>📍 1. Delivery Address</span>
                        </h2>

                        <!-- Existing Saved Addresses -->
                        <c:if test="${not empty addresses}">
                            <div style="margin-bottom: 20px;">
                                <label class="form-label">Select from your saved addresses:</label>
                                <div style="display: grid; gap: 12px;">
                                    <c:forEach var="addr" items="${addresses}" varStatus="status">
                                        <label style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 14px 18px; display: flex; align-items: flex-start; gap: 12px; cursor: pointer; transition: var(--transition);">
                                            <input type="radio" name="addressOption" value="saved" ${status.first ? 'checked' : ''} style="margin-top: 4px;">
                                            <input type="hidden" name="addressId" value="${addr.id}">
                                            <div>
                                                <strong><c:out value="${addr.recipientName}"/></strong> (${addr.phone})
                                                <div style="font-size: 0.9rem; color: var(--text-muted); margin-top: 2px;">
                                                    <c:out value="${addr.formattedAddress}"/>
                                                </div>
                                            </div>
                                        </label>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <!-- Option to enter new address -->
                        <div style="margin-top: 15px;">
                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 600;">
                                <input type="radio" name="addressOption" value="new" ${empty addresses ? 'checked' : ''}>
                                <span>+ Deliver to a new address</span>
                            </label>
                        </div>

                        <!-- New Address Form Fields -->
                        <div id="newAddressFields" style="margin-top: 20px; padding-top: 20px; border-top: 1px dashed var(--border-color); ${not empty addresses ? 'display: none;' : ''}">
                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Recipient Name</label>
                                    <input type="text" name="recipientName" class="form-control" placeholder="e.g. John Doe">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Contact Phone</label>
                                    <input type="tel" name="phone" class="form-control" placeholder="+91 9876543210">
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Address Line 1</label>
                                <input type="text" name="addressLine1" class="form-control" placeholder="House/Flat No., Building name, Street">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Address Line 2 (Optional)</label>
                                <input type="text" name="addressLine2" class="form-control" placeholder="Landmark, Area">
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">City</label>
                                    <input type="text" name="city" class="form-control" placeholder="e.g. Bengaluru">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">State</label>
                                    <input type="text" name="state" class="form-control" placeholder="e.g. Karnataka">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">PIN / Postal Code</label>
                                    <input type="text" name="postalCode" class="form-control" placeholder="e.g. 560038">
                                </div>
                            </div>

                            <div class="form-group">
                                <label style="display: flex; align-items: center; gap: 8px; font-size: 0.9rem; cursor: pointer;">
                                    <input type="checkbox" name="saveAsDefault">
                                    <span>Save as default delivery address</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Section 2: Payment Method -->
                    <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 28px; box-shadow: var(--shadow-sm);">
                        <h2 style="font-size: 1.25rem; font-weight: 800; color: #1e1b4b; margin-bottom: 18px; display: flex; align-items: center; gap: 8px;">
                            <span>💳 2. Payment Method</span>
                        </h2>

                        <div style="display: grid; gap: 14px;">
                            <label style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 16px; display: flex; align-items: flex-start; gap: 14px; cursor: pointer;">
                                <input type="radio" name="paymentMethod" value="COD" checked style="margin-top: 4px;">
                                <div>
                                    <div style="font-weight: 700; color: #1e293b;">💵 Cash on Delivery (COD)</div>
                                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 2px;">
                                        Pay via cash, UPI, or card upon receipt of delivery at your doorstep.
                                    </div>
                                </div>
                            </label>

                            <label style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 16px; display: flex; align-items: flex-start; gap: 14px; cursor: pointer;">
                                <input type="radio" name="paymentMethod" value="DEMO_UPI" style="margin-top: 4px;">
                                <div>
                                    <div style="font-weight: 700; color: #1e293b;">📱 Instant Demo UPI (GPay / PhonePe / Paytm)</div>
                                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 2px;">
                                        Safe academic sandbox simulated UPI transaction. No real money deducted.
                                    </div>
                                </div>
                            </label>

                            <label style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 16px; display: flex; align-items: flex-start; gap: 14px; cursor: pointer;">
                                <input type="radio" name="paymentMethod" value="DEMO_CARD" style="margin-top: 4px;">
                                <div>
                                    <div style="font-weight: 700; color: #1e293b;">💳 Demo Credit / Debit Card &amp; NetBanking</div>
                                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 2px;">
                                        Simulated test card gateway for demonstration and presentation testing.
                                    </div>
                                </div>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Final Order Summary -->
                <div class="cart-summary-card">
                    <h3 style="font-size: 1.25rem; font-weight: 800; color: #1e1b4b; margin-bottom: 20px;">Review Order</h3>

                    <!-- Itemized List -->
                    <div style="max-height: 240px; overflow-y: auto; margin-bottom: 16px; padding-right: 6px;">
                        <c:forEach var="item" items="${cart.items}">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 0.9rem;">
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="font-weight: 700; color: var(--primary);">${item.quantity}x</span>
                                    <span style="max-width: 170px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><c:out value="${item.product.name}"/></span>
                                </div>
                                <span style="font-weight: 600;">$<fmt:formatNumber value="${item.subtotal}" minFractionDigits="2" maxFractionDigits="2"/></span>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="summary-row">
                        <span>Items Subtotal:</span>
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
                        <span>Total Due:</span>
                        <span>$<fmt:formatNumber value="${cart.grandTotal}" minFractionDigits="2" maxFractionDigits="2"/></span>
                    </div>

                    <button type="submit" class="btn btn-primary btn-block btn-lg" id="btnPlaceOrder">
                        Confirm &amp; Place Order &rarr;
                    </button>

                    <div style="font-size: 0.78rem; color: var(--text-muted); text-align: center; margin-top: 14px;">
                        🔒 256-Bit SSL Encrypted &amp; Transaction Protected
                    </div>
                </div>
            </div>
        </form>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
