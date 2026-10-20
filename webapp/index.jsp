<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${empty featuredProducts}">
    <jsp:forward page="/home"/>
</c:if>

<c:set var="pageTitle" value="ShopSphere - Premier Modern Online Shopping" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <!-- Hero Banner -->
        <section class="hero-banner">
            <div class="hero-content">
                <span class="hero-tag">✨ Season Grand Sale 2026</span>
                <h1 class="hero-title">Elevate Your Lifestyle with ShopSphere</h1>
                <p class="hero-subtitle">
                    Discover cutting-edge gadgets, high fashion, luxury home decor, and athletic gear with guaranteed authenticity and lightning-fast delivery.
                </p>
                <div class="hero-btns">
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">Explore Catalog</a>
                    <a href="${pageContext.request.contextPath}/products?category=electronics" class="btn btn-secondary btn-lg">Tech Deals</a>
                </div>
            </div>
        </section>

        <!-- Feature Guarantees Strip -->
        <section class="features-strip">
            <div class="feature-box">
                <div class="feature-icon">🚚</div>
                <div>
                    <h4 class="feature-title">Free Express Delivery</h4>
                    <p class="feature-desc">On all orders exceeding $50</p>
                </div>
            </div>
            <div class="feature-box">
                <div class="feature-icon">🔒</div>
                <div>
                    <h4 class="feature-title">100% Secure Checkout</h4>
                    <p class="feature-desc">Safe payment &amp; Cash on Delivery</p>
                </div>
            </div>
            <div class="feature-box">
                <div class="feature-icon">🔄</div>
                <div>
                    <h4 class="feature-title">30-Day Hassle-Free Returns</h4>
                    <p class="feature-desc">Easy exchange or instant refund</p>
                </div>
            </div>
            <div class="feature-box">
                <div class="feature-icon">🎧</div>
                <div>
                    <h4 class="feature-title">Dedicated 24/7 Support</h4>
                    <p class="feature-desc">Direct assistance whenever needed</p>
                </div>
            </div>
        </section>

        <!-- Product Categories -->
        <section style="margin-bottom: 50px;">
            <div class="section-header">
                <div>
                    <h2 class="section-title">Shop by Category</h2>
                </div>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-sm btn-secondary">View All &rarr;</a>
            </div>

            <div class="categories-grid">
                <c:forEach var="cat" items="${categories}">
                    <a href="${pageContext.request.contextPath}/products?category=${cat.slug}" class="category-card">
                        <div class="category-icon-circle">
                            <c:choose>
                                <c:when test="${cat.slug == 'electronics'}">💻</c:when>
                                <c:when test="${cat.slug == 'fashion'}">👔</c:when>
                                <c:when test="${cat.slug == 'home-living'}">🏠</c:when>
                                <c:when test="${cat.slug == 'sports-fitness'}">⚽</c:when>
                                <c:when test="${cat.slug == 'books-stationery'}">📖</c:when>
                                <c:otherwise>📦</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="category-name"><c:out value="${cat.name}"/></div>
                    </a>
                </c:forEach>
            </div>
        </section>

        <!-- Featured Products Section -->
        <section style="margin-bottom: 50px;">
            <div class="section-header">
                <div>
                    <h2 class="section-title">Featured Deals &amp; Discounts</h2>
                </div>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-sm btn-secondary">Browse All Products &rarr;</a>
            </div>

            <div class="products-grid">
                <c:forEach var="prod" items="${featuredProducts}">
                    <div class="product-card">
                        <c:if test="${prod.discount > 0}">
                            <div class="product-badge-discount"><fmt:formatNumber value="${prod.discount}" maxFractionDigits="0"/>% OFF</div>
                        </c:if>

                        <!-- Wishlist Form Button -->
                        <form action="${pageContext.request.contextPath}/wishlist" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="${prod.id}">
                            <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/">
                            <button type="submit" class="product-wishlist-btn" title="Add to Wishlist">❤️</button>
                        </form>

                        <div class="product-img-wrap">
                            <a href="${pageContext.request.contextPath}/product?id=${prod.id}">
                                <img src="${pageContext.request.contextPath}/${prod.imageUrl}" alt="${prod.name}" class="product-img">
                            </a>
                        </div>

                        <div class="product-body">
                            <div class="product-brand"><c:out value="${prod.brand}"/></div>
                            <h3 class="product-title">
                                <a href="${pageContext.request.contextPath}/product?id=${prod.id}"><c:out value="${prod.name}"/></a>
                            </h3>

                            <div class="product-rating">
                                <span class="stars">★★★★★</span>
                                <span class="rating-count">(${prod.reviewCount > 0 ? prod.reviewCount : 5})</span>
                            </div>

                            <div class="product-price-row">
                                <span class="price-current">$<fmt:formatNumber value="${prod.discountedPrice}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                <c:if test="${prod.discount > 0}">
                                    <span class="price-original">$<fmt:formatNumber value="${prod.price}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                </c:if>
                            </div>

                            <div class="product-footer">
                                <form action="${pageContext.request.contextPath}/cart" method="post" style="width: 100%;">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="productId" value="${prod.id}">
                                    <input type="hidden" name="quantity" value="1">
                                    <button type="submit" class="btn btn-primary btn-block" ${prod.inStock ? '' : 'disabled'}>
                                        ${prod.inStock ? 'Add to Cart 🛒' : 'Out of Stock'}
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>

        <!-- New Arrivals Section -->
        <section style="margin-bottom: 50px;">
            <div class="section-header">
                <div>
                    <h2 class="section-title">New Arrivals</h2>
                </div>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-sm btn-secondary">Explore More &rarr;</a>
            </div>

            <div class="products-grid">
                <c:forEach var="prod" items="${latestProducts}">
                    <div class="product-card">
                        <c:if test="${prod.discount > 0}">
                            <div class="product-badge-discount"><fmt:formatNumber value="${prod.discount}" maxFractionDigits="0"/>% OFF</div>
                        </c:if>

                        <div class="product-img-wrap">
                            <a href="${pageContext.request.contextPath}/product?id=${prod.id}">
                                <img src="${pageContext.request.contextPath}/${prod.imageUrl}" alt="${prod.name}" class="product-img">
                            </a>
                        </div>

                        <div class="product-body">
                            <div class="product-brand"><c:out value="${prod.brand}"/></div>
                            <h3 class="product-title">
                                <a href="${pageContext.request.contextPath}/product?id=${prod.id}"><c:out value="${prod.name}"/></a>
                            </h3>

                            <div class="product-price-row">
                                <span class="price-current">$<fmt:formatNumber value="${prod.discountedPrice}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                <c:if test="${prod.discount > 0}">
                                    <span class="price-original">$<fmt:formatNumber value="${prod.price}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                </c:if>
                            </div>

                            <div class="product-footer">
                                <a href="${pageContext.request.contextPath}/product?id=${prod.id}" class="btn btn-secondary btn-block">View Details</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
