<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Sign In - ShopSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body style="background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;">
    <div style="background-color: #ffffff; border-radius: var(--radius-lg); width: 100%; max-width: 440px; padding: 40px; box-shadow: var(--shadow-xl);">
        <div style="text-align: center; margin-bottom: 24px;">
            <div class="brand-icon" style="margin: 0 auto 12px; width: 48px; height: 48px; font-size: 1.5rem;">S</div>
            <h1 style="font-size: 1.6rem; font-weight: 800; color: #1e1b4b;">Admin Control Center</h1>
            <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 4px;">Authorized administrative access only</p>
        </div>

        <!-- Demo Admin Credentials helper -->
        <div class="demo-credentials-pill" style="background-color: #fffbeb; border-color: #fde68a; color: #92400e;">
            <strong>🔐 Default Administrator Credentials:</strong><br>
            Email: <code>admin@shopsphere.com</code><br>
            Password: <code>Admin@123</code>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger" style="margin-bottom: 20px;">
                <span>⚠️ <c:out value="${error}"/></span>
            </div>
        </c:if>

        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-danger" style="margin-bottom: 20px;">
                <span>⚠️ <c:out value="${sessionScope.flashError}"/></span>
            </div>
            <c:remove var="flashError" scope="session"/>
        </c:if>

        <form action="${pageContext.request.contextPath}/admin/login" method="post">
            <div class="form-group">
                <label class="form-label" for="adminEmail">Administrator Email</label>
                <input type="email" id="adminEmail" name="email" class="form-control" 
                       value="<c:out value='${email != null ? email : \"admin@shopsphere.com\"}'/>" required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label" for="adminPassword">Master Password</label>
                <input type="password" id="adminPassword" name="password" class="form-control" 
                       value="Admin@123" placeholder="••••••••" required>
            </div>

            <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top: 10px;">
                Enter Admin Console &rarr;
            </button>
        </form>

        <div style="text-align: center; margin-top: 24px; font-size: 0.85rem;">
            <a href="${pageContext.request.contextPath}/" style="color: var(--text-muted);">&larr; Return to Customer Storefront</a>
        </div>
    </div>
</body>
</html>
