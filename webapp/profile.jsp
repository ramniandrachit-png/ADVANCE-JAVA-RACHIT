<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="My Profile - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <h1 style="font-size: 1.85rem; font-weight: 800; color: #1e1b4b; margin-bottom: 24px;">My Account Profile</h1>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 40px;">
            <!-- Personal Information Form -->
            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 30px; box-shadow: var(--shadow-sm);">
                <h2 style="font-size: 1.25rem; font-weight: 800; color: #1e1b4b; margin-bottom: 20px;">Personal Details</h2>

                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <input type="hidden" name="action" value="updateDetails">

                    <div class="form-group">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="name" class="form-control" value="<c:out value='${user.name}'/>" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email Address (Immutable)</label>
                        <input type="email" class="form-control" value="<c:out value='${user.email}'/>" disabled style="background-color: var(--bg-subtle);">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Phone Number</label>
                        <input type="tel" name="phone" class="form-control" value="<c:out value='${user.phone}'/>" placeholder="+91 9876543210">
                    </div>

                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </form>
            </div>

            <!-- Password Change Form -->
            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 30px; box-shadow: var(--shadow-sm);">
                <h2 style="font-size: 1.25rem; font-weight: 800; color: #1e1b4b; margin-bottom: 20px;">Security &amp; Password</h2>

                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <input type="hidden" name="action" value="changePassword">

                    <div class="form-group">
                        <label class="form-label">Current Password</label>
                        <input type="password" name="currentPassword" class="form-control" placeholder="••••••••" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <input type="password" name="newPassword" class="form-control" placeholder="Min. 6 characters" minlength="6" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" name="confirmPassword" class="form-control" placeholder="Repeat new password" minlength="6" required>
                    </div>

                    <button type="submit" class="btn btn-secondary">Update Password</button>
                </form>
            </div>
        </div>

        <!-- Saved Addresses Section -->
        <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 30px; box-shadow: var(--shadow-sm); margin-bottom: 40px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2 style="font-size: 1.25rem; font-weight: 800; color: #1e1b4b;">Saved Delivery Addresses</h2>
                <button type="button" class="btn btn-sm btn-primary" onclick="openModal('addAddressModal')">+ Add New Address</button>
            </div>

            <c:choose>
                <c:when test="${not empty addresses}">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px;">
                        <c:forEach var="addr" items="${addresses}">
                            <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 20px; position: relative;">
                                <c:if test="${addr.default}">
                                    <span class="badge badge-active" style="position: absolute; top: 14px; right: 14px;">Default</span>
                                </c:if>

                                <div style="font-weight: 700; font-size: 1.05rem; margin-bottom: 4px;">
                                    <c:out value="${addr.recipientName}"/>
                                </div>
                                <div style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 8px;">
                                    📞 <c:out value="${addr.phone}"/>
                                </div>
                                <div style="font-size: 0.9rem; color: #334155; line-height: 1.5; margin-bottom: 16px;">
                                    <c:out value="${addr.formattedAddress}"/>
                                </div>

                                <div style="display: flex; gap: 8px; align-items: center;">
                                    <c:if test="${not addr.default}">
                                        <form action="${pageContext.request.contextPath}/profile" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="setDefaultAddress">
                                            <input type="hidden" name="addressId" value="${addr.id}">
                                            <button type="submit" class="btn btn-sm btn-secondary">Set as Default</button>
                                        </form>
                                    </c:if>

                                    <form action="${pageContext.request.contextPath}/profile" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="deleteAddress">
                                        <input type="hidden" name="addressId" value="${addr.id}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" data-confirm="Remove this address?">Delete</button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <p style="color: var(--text-muted); font-style: italic;">No saved addresses yet. Click "+ Add New Address" above to add one.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<!-- Add Address Modal -->
<div id="addAddressModal" class="modal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Add Delivery Address</h3>
            <button type="button" class="modal-close" onclick="closeModal('addAddressModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/profile" method="post">
            <input type="hidden" name="action" value="addAddress">

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Recipient Name</label>
                    <input type="text" name="recipientName" class="form-control" required placeholder="e.g. John Doe">
                </div>
                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input type="tel" name="phone" class="form-control" required placeholder="+91 9876543210">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Address Line 1</label>
                <input type="text" name="addressLine1" class="form-control" required placeholder="House/Flat No., Apartment, Street">
            </div>

            <div class="form-group">
                <label class="form-label">Address Line 2 (Optional)</label>
                <input type="text" name="addressLine2" class="form-control" placeholder="Landmark, Area">
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">City</label>
                    <input type="text" name="city" class="form-control" required placeholder="e.g. Bengaluru">
                </div>
                <div class="form-group">
                    <label class="form-label">State</label>
                    <input type="text" name="state" class="form-control" required placeholder="e.g. Karnataka">
                </div>
                <div class="form-group">
                    <label class="form-label">PIN / Postal Code</label>
                    <input type="text" name="postalCode" class="form-control" required placeholder="e.g. 560038">
                </div>
            </div>

            <div class="form-group">
                <label style="display: flex; align-items: center; gap: 8px; font-size: 0.9rem; cursor: pointer;">
                    <input type="checkbox" name="isDefault">
                    <span>Set as default delivery address</span>
                </label>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('addAddressModal')">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Address</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="fragments/footer.jsp"/>
