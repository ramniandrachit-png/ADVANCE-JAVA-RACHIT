<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="category-navbar" style="background-color: #ffffff; border-bottom: 1px solid var(--border-color); padding: 8px 0;">
    <div class="container" style="display: flex; gap: 24px; overflow-x: auto; white-space: nowrap;">
        <a href="${pageContext.request.contextPath}/products" style="color: #475569; font-weight: 600; font-size: 0.9rem; padding: 4px 8px; border-radius: 4px;">All Products</a>
        <a href="${pageContext.request.contextPath}/products?category=electronics" style="color: #475569; font-weight: 500; font-size: 0.9rem; padding: 4px 8px;">📱 Electronics</a>
        <a href="${pageContext.request.contextPath}/products?category=fashion" style="color: #475569; font-weight: 500; font-size: 0.9rem; padding: 4px 8px;">👕 Fashion</a>
        <a href="${pageContext.request.contextPath}/products?category=home-living" style="color: #475569; font-weight: 500; font-size: 0.9rem; padding: 4px 8px;">🛋️ Home & Living</a>
        <a href="${pageContext.request.contextPath}/products?category=sports-fitness" style="color: #475569; font-weight: 500; font-size: 0.9rem; padding: 4px 8px;">🏋️ Sports</a>
        <a href="${pageContext.request.contextPath}/products?category=books-stationery" style="color: #475569; font-weight: 500; font-size: 0.9rem; padding: 4px 8px;">📚 Books</a>
    </div>
</div>
