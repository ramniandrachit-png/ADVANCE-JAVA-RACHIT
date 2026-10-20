<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="${product.name} - ShopSphere" scope="request"/>
<jsp:include page="fragments/header.jsp"/>
<jsp:include page="fragments/navbar.jsp"/>

<main class="main-content">
    <div class="container">
        <!-- Breadcrumb -->
        <nav style="margin-bottom: 20px; font-size: 0.9rem; color: var(--text-muted);">
            <a href="${pageContext.request.contextPath}/">Home</a> &rsaquo;
            <a href="${pageContext.request.contextPath}/products">Products</a> &rsaquo;
            <a href="${pageContext.request.contextPath}/products?category=${product.categoryId}"><c:out value="${product.categoryName}"/></a> &rsaquo;
            <span style="color: var(--text-main); font-weight: 600;"><c:out value="${product.name}"/></span>
        </nav>

        <!-- Product Overview Box -->
        <div class="product-detail-grid">
            <div class="detail-img-box">
                <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.name}" class="detail-img">
            </div>

            <div>
                <div class="detail-brand"><c:out value="${product.brand}"/> &bull; <c:out value="${product.categoryName}"/></div>
                <h1 class="detail-title"><c:out value="${product.name}"/></h1>

                <div class="product-rating" style="margin-bottom: 16px;">
                    <span class="stars" style="font-size: 1.1rem;">★★★★★</span>
                    <span style="font-weight: 700; color: #1e293b;"><fmt:formatNumber value="${product.averageRating}" maxFractionDigits="1"/></span>
                    <span class="rating-count">(${product.reviewCount} verified reviews)</span>
                </div>

                <div class="detail-price-box">
                    <div>
                        <span class="price-current" style="font-size: 2rem;">$<fmt:formatNumber value="${product.discountedPrice}" minFractionDigits="2" maxFractionDigits="2"/></span>
                        <c:if test="${product.discount > 0}">
                            <span class="price-original" style="font-size: 1.1rem; margin-left: 8px;">$<fmt:formatNumber value="${product.price}" minFractionDigits="2" maxFractionDigits="2"/></span>
                        </c:if>
                    </div>
                    <c:if test="${product.discount > 0}">
                        <div class="product-badge-discount" style="position: static; font-size: 0.85rem;">
                            <fmt:formatNumber value="${product.discount}" maxFractionDigits="0"/>% OFF (Save $<fmt:formatNumber value="${product.savings}" minFractionDigits="2" maxFractionDigits="2"/>)
                        </div>
                    </c:if>
                </div>

                <div>
                    <c:choose>
                        <c:when test="${product.inStock}">
                            <span class="stock-badge stock-in">✓ In Stock (${product.stock} units available)</span>
                        </c:when>
                        <c:otherwise>
                            <span class="stock-badge stock-out">✗ Currently Out of Stock</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <p class="detail-desc">
                    <c:out value="${product.description}"/>
                </p>

                <!-- Add to Cart Form -->
                <form action="${pageContext.request.contextPath}/cart" method="post" style="margin-bottom: 24px;">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="productId" value="${product.id}">

                    <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
                        <div class="quantity-picker" style="margin-bottom: 0;">
                            <button type="button" class="qty-btn qty-dec">-</button>
                            <input type="number" name="quantity" class="qty-input" value="1" min="1" max="${product.stock}">
                            <button type="button" class="qty-btn qty-inc">+</button>
                        </div>

                        <button type="submit" class="btn btn-primary btn-lg" style="flex: 1;" ${product.inStock ? '' : 'disabled'}>
                            ${product.inStock ? 'Add to Cart 🛒' : 'Out of Stock'}
                        </button>
                    </div>
                </form>

                <!-- Wishlist Action -->
                <div style="display: flex; gap: 10px;">
                    <form action="${pageContext.request.contextPath}/wishlist" method="post">
                        <input type="hidden" name="action" value="${inWishlist ? 'remove' : 'add'}">
                        <input type="hidden" name="productId" value="${product.id}">
                        <input type="hidden" name="returnUrl" value="${pageContext.request.contextPath}/product?id=${product.id}">
                        <button type="submit" class="btn btn-secondary">
                            ${inWishlist ? '❤️ Remove from Wishlist' : '🤍 Add to Wishlist'}
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Customer Reviews & Rating Submission -->
        <section class="reviews-container">
            <div class="section-header">
                <div>
                    <h2 class="section-title">Customer Reviews &amp; Ratings</h2>
                    <p style="color: var(--text-muted); font-size: 0.95rem; margin-top: 4px;">Verified user feedback for this product</p>
                </div>
            </div>

            <!-- Review Submission Form for Logged in Users -->
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <c:if test="${not hasReviewed}">
                        <div style="background-color: var(--bg-subtle); padding: 24px; border-radius: var(--radius-md); margin-bottom: 30px; border: 1px solid var(--border-color);">
                            <h4 style="font-weight: 700; margin-bottom: 12px; color: #1e1b4b;">Write a Product Review</h4>
                            <form action="${pageContext.request.contextPath}/reviews/submit" method="post">
                                <input type="hidden" name="productId" value="${product.id}">
                                
                                <div class="form-group" style="max-width: 220px;">
                                    <label class="form-label" for="reviewRating">Your Rating</label>
                                    <select id="reviewRating" name="rating" class="form-control" required>
                                        <option value="5">⭐⭐⭐⭐⭐ (5 - Exceptional)</option>
                                        <option value="4">⭐⭐⭐⭐ (4 - Very Good)</option>
                                        <option value="3">⭐⭐⭐ (3 - Average)</option>
                                        <option value="2">⭐⭐ (2 - Below Average)</option>
                                        <option value="1">⭐ (1 - Disappointed)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="reviewText">Your Review</label>
                                    <textarea id="reviewText" name="reviewText" rows="3" class="form-control" 
                                              placeholder="Share details of your experience with this item..." required></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary">Submit Review</button>
                            </form>
                        </div>
                    </c:if>
                    <c:if test="${hasReviewed}">
                        <div class="alert alert-success" style="margin-bottom: 20px;">
                            ✓ You have already reviewed this product. Thank you for your feedback!
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning" style="margin-bottom: 20px;">
                        <span>Want to leave a review? <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/product?id=${product.id}" style="font-weight: 700;">Sign in to your account</a> to rate this product.</span>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Reviews List -->
            <c:choose>
                <c:when test="${not empty reviews}">
                    <c:forEach var="rev" items="${reviews}">
                        <div class="review-item">
                            <div class="review-header">
                                <div>
                                    <span class="reviewer-name"><c:out value="${rev.userName}"/></span>
                                    <span class="stars" style="margin-left: 8px;">
                                        <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                                    </span>
                                </div>
                                <span class="review-date"><fmt:formatDate value="${rev.createdAt}" pattern="MMM dd, yyyy"/></span>
                            </div>
                            <p style="color: #334155; font-size: 0.95rem; line-height: 1.6;">
                                <c:out value="${rev.reviewText}"/>
                            </p>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="color: var(--text-muted); font-style: italic; padding: 20px 0;">No reviews yet for this product. Be the first to share your thoughts!</p>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- Related Products Section -->
        <c:if test="${not empty relatedProducts}">
            <section style="margin-bottom: 40px;">
                <div class="section-header">
                    <div>
                        <h2 class="section-title">Similar Products You May Like</h2>
                    </div>
                </div>

                <div class="products-grid">
                    <c:forEach var="rel" items="${relatedProducts}">
                        <div class="product-card">
                            <div class="product-img-wrap">
                                <a href="${pageContext.request.contextPath}/product?id=${rel.id}">
                                    <img src="${pageContext.request.contextPath}/${rel.imageUrl}" alt="${rel.name}" class="product-img">
                                </a>
                            </div>

                            <div class="product-body">
                                <div class="product-brand"><c:out value="${rel.brand}"/></div>
                                <h3 class="product-title">
                                    <a href="${pageContext.request.contextPath}/product?id=${rel.id}"><c:out value="${rel.name}"/></a>
                                </h3>
                                <div class="product-price-row">
                                    <span class="price-current">$<fmt:formatNumber value="${rel.discountedPrice}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                </div>
                                <div class="product-footer">
                                    <a href="${pageContext.request.contextPath}/product?id=${rel.id}" class="btn btn-secondary btn-block">View Item</a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </c:if>
    </div>
</main>

<jsp:include page="fragments/footer.jsp"/>
