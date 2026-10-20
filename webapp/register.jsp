<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Create Account - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>

<main class="main-content">
    <div class="container">
        <div class="auth-wrapper">
            <div class="auth-header">
                <h1 class="auth-title">Create Your Account</h1>
                <p class="auth-subtitle">Join ShopSphere today to start saving on top brands</p>
            </div>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-group">
                    <label class="form-label" for="regName">Full Name</label>
                    <input type="text" id="regName" name="name" class="form-control" 
                           value="<c:out value='${name}'/>" 
                           placeholder="e.g. John Doe" required autofocus>
                </div>

                <div class="form-group">
                    <label class="form-label" for="regEmail">Email Address</label>
                    <input type="email" id="regEmail" name="email" class="form-control" 
                           value="<c:out value='${email}'/>" 
                           placeholder="e.g. john@example.com" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="regPhone">Mobile Phone (Optional)</label>
                    <input type="tel" id="regPhone" name="phone" class="form-control" 
                           value="<c:out value='${phone}'/>" 
                           placeholder="+91 9876543210">
                </div>

                <div class="form-group">
                    <label class="form-label" for="regPassword">Password</label>
                    <input type="password" id="regPassword" name="password" class="form-control" 
                           placeholder="At least 6 characters" minlength="6" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="regConfirm">Confirm Password</label>
                    <input type="password" id="regConfirm" name="confirmPassword" class="form-control" 
                           placeholder="Re-enter password" minlength="6" required>
                    <span id="regMismatchHint" style="display: none; color: var(--danger); font-size: 0.85rem; margin-top: 4px;">
                        ⚠️ Passwords do not match.
                    </span>
                </div>

                <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: 10px;">
                    Register Now &rarr;
                </button>
            </form>

            <div style="text-align: center; margin-top: 24px; font-size: 0.95rem; color: var(--text-muted);">
                Already have an account? 
                <a href="${pageContext.request.contextPath}/login" style="font-weight: 700;">Sign in here</a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
