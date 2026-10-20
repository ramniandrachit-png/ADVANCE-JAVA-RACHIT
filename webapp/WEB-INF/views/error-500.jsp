<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Error (500) - ShopSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body style="min-height: 100vh; display: flex; align-items: center; justify-content: center; background-color: var(--bg-body); padding: 20px;">
    <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 50px 30px; text-align: center; max-width: 540px; box-shadow: var(--shadow-lg);">
        <div style="font-size: 5rem; font-weight: 900; color: var(--danger); line-height: 1; margin-bottom: 12px;">500</div>
        <h1 style="font-size: 1.6rem; font-weight: 800; color: #1e1b4b; margin-bottom: 12px;">Internal Server Error</h1>
        <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 24px;">
            An unexpected error occurred while processing your request. If MySQL is not currently running, please start the database service and verify the credentials.
        </p>

        <c:if test="${not empty pageContext.exception}">
            <div style="background-color: var(--bg-subtle); padding: 12px; border-radius: var(--radius-sm); font-family: monospace; font-size: 0.8rem; color: #b91c1c; text-align: left; margin-bottom: 24px; max-height: 120px; overflow-y: auto;">
                <c:out value="${pageContext.exception.message}"/>
            </div>
        </c:if>

        <div style="display: flex; gap: 12px; justify-content: center;">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Storefront</a>
            <a href="javascript:history.back()" class="btn btn-secondary">Go Back</a>
        </div>
    </div>
</body>
</html>
