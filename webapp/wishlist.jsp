<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="My Wishlist - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <h1 style="font-size: 1.85rem; font-weight: 800; color: #1e1b4b; margin-bottom: 24px;">My Saved Wishlist</h1>

        <c:choose>
            <c:when test="${not empty wishlistItems}">
                <div class="products-grid">
                    <c:forEach var="item" items="${wishlistItems}">
                        <div class="product-card">
                            <c:if test="${item.product.discount > 0}">
                                <div class="product-badge-discount"><fmt:formatNumber value="${item.product.discount}" maxFractionDigits="0"/>% OFF</div>
                            </c:if>

                            <div class="product-img-wrap">
                                <a href="${pageContext.request.contextPath}/product?id=${item.productId}">
                                    <img src="${pageContext.request.contextPath}/${item.product.imageUrl}" alt="${item.product.name}" class="product-img">
                                </a>
                            </div>

                            <div class="product-body">
                                <div class="product-brand"><c:out value="${item.product.brand}"/></div>
                                <h3 class="product-title">
                                    <a href="${pageContext.request.contextPath}/product?id=${item.productId}"><c:out value="${item.product.name}"/></a>
                                </h3>

                                <div class="product-price-row">
                                    <span class="price-current">$<fmt:formatNumber value="${item.product.discountedPrice}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                    <c:if test="${item.product.discount > 0}">
                                        <span class="price-original">$<fmt:formatNumber value="${item.product.price}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                    </c:if>
                                </div>

                                <div style="display: flex; gap: 8px;">
                                    <form action="${pageContext.request.contextPath}/wishlist" method="post" style="flex: 1;">
                                        <input type="hidden" name="action" value="moveToCart">
                                        <input type="hidden" name="productId" value="${item.productId}">
                                        <button type="submit" class="btn btn-primary btn-block btn-sm" ${item.product.inStock ? '' : 'disabled'}>
                                            Move to Cart 🛒
                                        </button>
                                    </form>

                                    <form action="${pageContext.request.contextPath}/wishlist" method="post">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="productId" value="${item.productId}">
                                        <button type="submit" class="btn btn-outline-danger btn-sm" title="Remove from Wishlist">
                                            🗑️
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div style="background-color: var(--bg-surface); border: 1px dashed var(--border-color); border-radius: var(--radius-lg); padding: 80px 20px; text-align: center; max-width: 600px; margin: 40px auto;">
                    <div style="font-size: 3.5rem; margin-bottom: 16px;">❤️</div>
                    <h2 style="font-size: 1.5rem; font-weight: 800; color: #1e1b4b; margin-bottom: 8px;">Your Wishlist is Empty</h2>
                    <p style="color: var(--text-muted); margin-bottom: 24px;">Save your favorite products to easily purchase them later or track price drops.</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">Discover Products</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
