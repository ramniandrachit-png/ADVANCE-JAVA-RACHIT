<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Products - ShopSphere Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="admin-layout">
        <c:set var="pageTitle" value="Manage Products" scope="request"/>
        <jsp:include page="../fragments/sidebar.jsp"/>

        <main class="admin-main">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">Product Catalog Inventory</h1>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Add, update prices, manage stock quantities and product availability</p>
                </div>
                <button type="button" class="btn btn-primary" onclick="openModal('addProductModal')">+ Create Product</button>
            </div>

            <!-- Flash Alerts -->
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

            <!-- Products Table -->
            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-sm);">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Category</th>
                            <th>Base Price</th>
                            <th>Discount</th>
                            <th>Final Price</th>
                            <th>Stock</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${products}">
                            <tr>
                                <td>
                                    <div class="cart-item-row">
                                        <img src="${pageContext.request.contextPath}/${p.imageUrl}" alt="${p.name}" class="cart-item-thumb">
                                        <div>
                                            <div style="font-size: 0.75rem; font-weight: 700; color: var(--primary); text-transform: uppercase;"><c:out value="${p.brand}"/></div>
                                            <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;"><c:out value="${p.name}"/></div>
                                        </div>
                                    </div>
                                </td>
                                <td><c:out value="${p.categoryName}"/></td>
                                <td>$<fmt:formatNumber value="${p.price}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.discount > 0}">
                                            <span style="color: var(--danger); font-weight: 700;">${p.discount}%</span>
                                        </c:when>
                                        <c:otherwise>0%</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-weight: 800; color: #0f172a;">
                                    $<fmt:formatNumber value="${p.discountedPrice}" minFractionDigits="2" maxFractionDigits="2"/>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.stock > 10}">
                                            <span style="font-weight: 700; color: var(--success);">${p.stock} in stock</span>
                                        </c:when>
                                        <c:when test="${p.stock > 0}">
                                            <span style="font-weight: 700; color: var(--warning);">${p.stock} low stock</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-weight: 700; color: var(--danger);">0 (Out)</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="badge ${p.status == 'ACTIVE' ? 'badge-active' : 'badge-inactive'}">
                                        ${p.status}
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <!-- Edit Button with dynamic data attributes -->
                                        <button type="button" class="btn btn-sm btn-secondary" 
                                                onclick="editProduct(${p.id}, '${p.name}', '${p.brand}', ${p.categoryId}, '${p.price}', '${p.discount}', ${p.stock}, '${p.imageUrl}', '${p.status}', `${p.description}`)">
                                            ✏️ Edit
                                        </button>

                                        <!-- Toggle Status -->
                                        <form action="${pageContext.request.contextPath}/admin/products" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="toggleStatus">
                                            <input type="hidden" name="id" value="${p.id}">
                                            <button type="submit" class="btn btn-sm btn-secondary" title="Toggle Active/Inactive">
                                                ${p.status == 'ACTIVE' ? 'Pause' : 'Activate'}
                                            </button>
                                        </form>

                                        <!-- Delete / Deactivate -->
                                        <form action="${pageContext.request.contextPath}/admin/products" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${p.id}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" data-confirm="Are you sure you want to delete/deactivate this product?">
                                                🗑️
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- Create Product Modal -->
    <div id="addProductModal" class="modal">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 class="modal-title">Create New Product</h3>
                <button type="button" class="modal-close" onclick="closeModal('addProductModal')">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/products" method="post">
                <input type="hidden" name="action" value="create">

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Product Name</label>
                        <input type="text" name="name" class="form-control" required placeholder="e.g. Ultra Gaming Laptop">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Brand / Manufacturer</label>
                        <input type="text" name="brand" class="form-control" required placeholder="e.g. SphereTech">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <select name="categoryId" class="form-control" required>
                            <c:forEach var="c" items="${categories}">
                                <option value="${c.id}"><c:out value="${c.name}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-control">
                            <option value="ACTIVE">ACTIVE</option>
                            <option value="INACTIVE">INACTIVE</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Price ($)</label>
                        <input type="number" step="0.01" name="price" class="form-control" required placeholder="99.99">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Discount (%)</label>
                        <input type="number" step="0.01" name="discount" class="form-control" value="0.00" min="0" max="100">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Stock Quantity</label>
                        <input type="number" name="stock" class="form-control" value="50" min="0" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Image URL / Path</label>
                    <input type="text" name="imageUrl" class="form-control" value="images/prod-default.jpg">
                </div>

                <div class="form-group">
                    <label class="form-label">Product Description</label>
                    <textarea name="description" rows="3" class="form-control" placeholder="Provide full features and specifications..."></textarea>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('addProductModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Product</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Product Modal -->
    <div id="editProductModal" class="modal">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 class="modal-title">Edit Product Details</h3>
                <button type="button" class="modal-close" onclick="closeModal('editProductModal')">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/products" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" id="editProdId" name="id">

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Product Name</label>
                        <input type="text" id="editProdName" name="name" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Brand</label>
                        <input type="text" id="editProdBrand" name="brand" class="form-control" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <select id="editProdCategoryId" name="categoryId" class="form-control" required>
                            <c:forEach var="c" items="${categories}">
                                <option value="${c.id}"><c:out value="${c.name}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select id="editProdStatus" name="status" class="form-control">
                            <option value="ACTIVE">ACTIVE</option>
                            <option value="INACTIVE">INACTIVE</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Price ($)</label>
                        <input type="number" step="0.01" id="editProdPrice" name="price" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Discount (%)</label>
                        <input type="number" step="0.01" id="editProdDiscount" name="discount" class="form-control" min="0" max="100">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Stock Quantity</label>
                        <input type="number" id="editProdStock" name="stock" class="form-control" min="0" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Image URL / Path</label>
                    <input type="text" id="editProdImageUrl" name="imageUrl" class="form-control">
                </div>

                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea id="editProdDesc" name="description" rows="3" class="form-control"></textarea>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('editProductModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Product</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
    <script>
        function editProduct(id, name, brand, catId, price, discount, stock, img, status, desc) {
            document.getElementById("editProdId").value = id;
            document.getElementById("editProdName").value = name;
            document.getElementById("editProdBrand").value = brand;
            document.getElementById("editProdCategoryId").value = catId;
            document.getElementById("editProdPrice").value = price;
            document.getElementById("editProdDiscount").value = discount;
            document.getElementById("editProdStock").value = stock;
            document.getElementById("editProdImageUrl").value = img;
            document.getElementById("editProdStatus").value = status;
            document.getElementById("editProdDesc").value = desc;
            openModal("editProductModal");
        }
    </script>
</body>
</html>
