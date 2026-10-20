<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty pageTitle ? pageTitle : 'ShopSphere - Modern E-Commerce'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/images/favicon.ico">
</head>
<body>
    <header class="site-header">
        <div class="top-bar">
            <div class="container">
                <div class="top-bar-left">
                    <span>🌟 Enjoy FREE Shipping on all orders over $50! Use code <strong>WELCOME10</strong></span>
                </div>
                <div class="top-bar-right">
                    <span>📞 24/7 Support: +1 (800) 555-SPHERE</span>
                    <c:if test="${not empty sessionScope.currentUser && sessionScope.currentUser.admin}">
                        <a href="${pageContext.request.contextPath}/admin/dashboard" style="color: #facc15; font-weight: 700;">⚙️ Admin Panel</a>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="container">
            <nav class="navbar">
                <a href="${pageContext.request.contextPath}/" class="brand-logo">
                    <div class="brand-icon">S</div>
                    <span>Shop</span>Sphere
                </a>

                <form action="${pageContext.request.contextPath}/products" method="get" class="search-form">
                    <input type="text" name="q" value="${param.q}" class="search-input" placeholder="Search laptops, shoes, accessories..." required>
                    <button type="submit" class="search-btn" aria-label="Search">
                        🔍
                    </button>
                </form>

                <div class="nav-actions">
                    <a href="${pageContext.request.contextPath}/products" class="nav-link">Catalog</a>

                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <a href="${pageContext.request.contextPath}/wishlist" class="nav-link" title="Wishlist">
                                ❤️ <span class="nav-text">Wishlist</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/cart" class="nav-link" title="Shopping Cart">
                                🛒 <span class="nav-text">Cart</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/profile" class="nav-link" title="My Account">
                                👤 <span>${sessionScope.currentUser.name}</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-secondary" title="Logout">
                                Logout
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/cart" class="nav-link" title="Shopping Cart">
                                🛒 <span class="nav-text">Cart</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-sm btn-secondary">
                                Sign In
                            </a>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-sm btn-primary">
                                Register
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </nav>
        </div>
    </header>

    <div class="container" style="margin-top: 15px;">
        <!-- Global Flash Alerts -->
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

        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <span>⚠️ <c:out value="${error}"/></span>
                <button type="button" class="alert-close" onclick="this.parentElement.remove()">×</button>
            </div>
        </c:if>
    </div>
