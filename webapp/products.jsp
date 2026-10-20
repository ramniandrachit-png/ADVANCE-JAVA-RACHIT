<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Product Catalog - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <div class="catalog-layout">
            <!-- Filter Sidebar -->
            <aside class="filter-sidebar">
                <form action="${pageContext.request.contextPath}/products" method="get" id="filterForm">
                    <c:if test="${not empty keyword}">
                        <input type="hidden" name="q" value="<c:out value='${keyword}'/>">
                    </c:if>

                    <div class="filter-section">
                        <h4 class="filter-title">Categories</h4>
                        <ul class="filter-list">
                            <li class="filter-item">
                                <a href="${pageContext.request.contextPath}/products<c:if test='${not empty keyword}'>?q=${keyword}</c:if>" 
                                   class="filter-link ${empty selectedCategoryId ? 'active' : ''}">
                                    All Categories
                                </a>
                            </li>
                            <c:forEach var="cat" items="${categories}">
                                <li class="filter-item">
                                    <a href="${pageContext.request.contextPath}/products?category=${cat.id}<c:if test='${not empty keyword}'>&q=${keyword}</c:if>" 
                                       class="filter-link ${selectedCategoryId == cat.id ? 'active' : ''}">
                                        <span><c:out value="${cat.name}"/></span>
                                    </a>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>

                    <div class="filter-section">
                        <h4 class="filter-title">Price Range ($)</h4>
                        <div class="price-inputs">
                            <input type="number" name="minPrice" class="price-input" placeholder="Min" 
                                   value="${minPrice}" min="0" step="1">
                            <span>-</span>
                            <input type="number" name="maxPrice" class="price-input" placeholder="Max" 
                                   value="${maxPrice}" min="0" step="1">
                        </div>
                        <c:if test="${not empty selectedCategoryId}">
                            <input type="hidden" name="category" value="${selectedCategoryId}">
                        </c:if>
                        <c:if test="${not empty sortBy}">
                            <input type="hidden" name="sort" value="${sortBy}">
                        </c:if>
                        <button type="submit" class="btn btn-secondary btn-block btn-sm">Apply Price Filter</button>
                    </div>

                    <div style="margin-top: 20px;">
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-outline-danger btn-block btn-sm">
                            Reset All Filters
                        </a>
                    </div>
                </form>
            </aside>

            <!-- Products Results Area -->
            <section>
                <!-- Sorting & Results Summary Bar -->
                <div style="background-color: var(--bg-surface); padding: 14px 20px; border-radius: var(--radius-md); border: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <span style="font-weight: 600; color: #334155;">
                            Showing <strong>${totalProducts}</strong> products
                            <c:if test="${not empty keyword}">
                                for "<em><c:out value='${keyword}'/></em>"
                            </c:if>
                        </span>
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px;">
                        <label for="sortSelect" style="font-size: 0.9rem; font-weight: 600; color: var(--text-muted);">Sort By:</label>
                        <select id="sortSelect" class="form-control" style="width: auto; padding: 6px 12px; font-size: 0.9rem;"
                                onchange="location.href='${pageContext.request.contextPath}/products?category=${selectedCategoryId}&q=${keyword}&minPrice=${minPrice}&maxPrice=${maxPrice}&sort=' + this.value;">
                            <option value="newest" ${sortBy == 'newest' ? 'selected' : ''}>Newest Arrivals</option>
                            <option value="price_asc" ${sortBy == 'price_asc' ? 'selected' : ''}>Price: Low to High</option>
                            <option value="price_desc" ${sortBy == 'price_desc' ? 'selected' : ''}>Price: High to Low</option>
                            <option value="name_asc" ${sortBy == 'name_asc' ? 'selected' : ''}>Name: A to Z</option>
                            <option value="rating" ${sortBy == 'rating' ? 'selected' : ''}>Customer Rating</option>
                        </select>
                    </div>
                </div>

                <!-- Products Grid -->
                <c:choose>
                    <c:when test="${not empty products}">
                        <div class="products-grid">
                            <c:forEach var="prod" items="${products}">
                                <div class="product-card">
                                    <c:if test="${prod.discount > 0}">
                                        <div class="product-badge-discount"><fmt:formatNumber value="${prod.discount}" maxFractionDigits="0"/>% OFF</div>
                                    </c:if>

                                    <!-- Wishlist Button -->
                                    <form action="${pageContext.request.contextPath}/wishlist" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="productId" value="${prod.id}">
                                        <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/products?category=${selectedCategoryId}&q=${keyword}">
                                        <button type="submit" class="product-wishlist-btn" title="Add to Wishlist">❤️</button>
                                    </form>

                                    <div class="product-img-wrap">
                                        <a href="${pageContext.request.contextPath}/product?id=${prod.id}">
                                            <img src="${pageContext.request.contextPath}/${prod.imageUrl}" alt="${prod.name}" class="product-img">
                                        </a>
                                    </div>

                                    <div class="product-body">
                                        <div class="product-brand"><c:out value="${prod.brand}"/> &bull; <c:out value="${prod.categoryName}"/></div>
                                        <h3 class="product-title">
                                            <a href="${pageContext.request.contextPath}/product?id=${prod.id}"><c:out value="${prod.name}"/></a>
                                        </h3>

                                        <div class="product-rating">
                                            <span class="stars">★★★★★</span>
                                            <span class="rating-count">(${prod.reviewCount})</span>
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
                                                <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/products?category=${selectedCategoryId}&q=${keyword}">
                                                <button type="submit" class="btn btn-primary btn-block" ${prod.inStock ? '' : 'disabled'}>
                                                    ${prod.inStock ? 'Add to Cart 🛒' : 'Out of Stock'}
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Pagination -->
                        <c:if test="${totalPages > 1}">
                            <div style="display: flex; justify-content: center; gap: 8px; margin-top: 30px;">
                                <c:if test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/products?category=${selectedCategoryId}&q=${keyword}&minPrice=${minPrice}&maxPrice=${maxPrice}&sort=${sortBy}&page=${currentPage - 1}" 
                                       class="btn btn-secondary btn-sm">&laquo; Previous</a>
                                </c:if>

                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <a href="${pageContext.request.contextPath}/products?category=${selectedCategoryId}&q=${keyword}&minPrice=${minPrice}&maxPrice=${maxPrice}&sort=${sortBy}&page=${p}" 
                                       class="btn btn-sm ${currentPage == p ? 'btn-primary' : 'btn-secondary'}">${p}</a>
                                </c:forEach>

                                <c:if test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/products?category=${selectedCategoryId}&q=${keyword}&minPrice=${minPrice}&maxPrice=${maxPrice}&sort=${sortBy}&page=${currentPage + 1}" 
                                       class="btn btn-secondary btn-sm">Next &raquo;</a>
                                </c:if>
                            </div>
                        </c:if>
                    </c:when>

                    <c:otherwise>
                        <!-- Empty State -->
                        <div style="background-color: var(--bg-surface); border: 1px dashed var(--border-color); border-radius: var(--radius-lg); padding: 60px 20px; text-align: center;">
                            <div style="font-size: 3.5rem; margin-bottom: 15px;">🔍</div>
                            <h3 style="font-size: 1.4rem; font-weight: 700; color: #1e1b4b; margin-bottom: 8px;">No products match your criteria</h3>
                            <p style="color: var(--text-muted); margin-bottom: 24px;">Try refining your search keyword, adjusting your price filter, or browse all categories.</p>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">Browse All Products</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
