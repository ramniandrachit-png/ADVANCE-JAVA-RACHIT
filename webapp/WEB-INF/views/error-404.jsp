<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found (404) - ShopSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body style="min-height: 100vh; display: flex; align-items: center; justify-content: center; background-color: var(--bg-body); padding: 20px;">
    <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 50px 30px; text-align: center; max-width: 520px; box-shadow: var(--shadow-lg);">
        <div style="font-size: 5rem; font-weight: 900; color: var(--primary); line-height: 1; margin-bottom: 12px;">404</div>
        <h1 style="font-size: 1.6rem; font-weight: 800; color: #1e1b4b; margin-bottom: 12px;">Oops! Page Not Found</h1>
        <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 28px;">
            The page you are looking for might have been moved, removed, or the link you followed may be incorrect.
        </p>
        <div style="display: flex; gap: 12px; justify-content: center;">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Home</a>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary">Browse Catalog</a>
        </div>
    </div>
</body>
</html>
