<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Sign In - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>

<main class="main-content">
    <div class="container">
        <div class="auth-wrapper">
            <div class="auth-header">
                <h1 class="auth-title">Welcome Back</h1>
                <p class="auth-subtitle">Sign in to access your orders, saved addresses, and wishlist</p>
            </div>

            <!-- Demo Credentials Helper Card -->
            <div class="demo-credentials-pill">
                <strong>🔑 Demo Customer Account:</strong><br>
                Email: <code>john@example.com</code><br>
                Password: <code>Customer@123</code>
            </div>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <input type="hidden" name="redirect" value="<c:out value='${redirect != null ? redirect : param.redirect}'/>">

                <div class="form-group">
                    <label class="form-label" for="loginEmail">Email Address</label>
                    <input type="email" id="loginEmail" name="email" class="form-control" 
                           value="<c:out value='${email != null ? email : param.email}'/>" 
                           placeholder="e.g. john@example.com" required autofocus>
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between;">
                        <label class="form-label" for="loginPassword">Password</label>
                    </div>
                    <input type="password" id="loginPassword" name="password" class="form-control" 
                           placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: 10px;">
                    Sign In &rarr;
                </button>
            </form>

            <div style="text-align: center; margin-top: 24px; font-size: 0.95rem; color: var(--text-muted);">
                Don't have an account yet? 
                <a href="${pageContext.request.contextPath}/register" style="font-weight: 700;">Create one here</a>
            </div>

            <div style="text-align: center; margin-top: 15px; font-size: 0.85rem; border-top: 1px solid var(--border-color); padding-top: 15px;">
                Administrator? <a href="${pageContext.request.contextPath}/admin/login" style="color: var(--primary); font-weight: 600;">Sign in to Admin Control Center &rarr;</a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
