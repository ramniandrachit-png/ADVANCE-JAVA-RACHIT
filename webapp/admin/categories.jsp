<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Categories - ShopSphere Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="admin-layout">
        <c:set var="pageTitle" value="Manage Categories" scope="request"/>
        <jsp:include page="../fragments/sidebar.jsp"/>

        <main class="admin-main">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">Product Categories</h1>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Organize items into high-converting collections and store departments</p>
                </div>
                <button type="button" class="btn btn-primary" onclick="openModal('addCategoryModal')">+ Add Category</button>
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

            <div style="background-color: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-sm);">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Category Name</th>
                            <th>Slug / URL</th>
                            <th>Description</th>
                            <th>Products Count</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="c" items="${categories}">
                            <tr>
                                <td style="font-weight: 700; color: #1e1b4b;"><c:out value="${c.name}"/></td>
                                <td><code>${c.slug}</code></td>
                                <td style="color: var(--text-muted); font-size: 0.9rem; max-width: 280px;"><c:out value="${c.description}"/></td>
                                <td>
                                    <span style="font-weight: 700; color: var(--primary);">${c.productCount} products</span>
                                </td>
                                <td>
                                    <span class="badge ${c.status == 'ACTIVE' ? 'badge-active' : 'badge-inactive'}">
                                        ${c.status}
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
                                        <button type="button" class="btn btn-sm btn-secondary" 
                                                onclick="editCategory(${c.id}, '${c.name}', '${c.imageUrl}', '${c.status}', `${c.description}`)">
                                            ✏️ Edit
                                        </button>

                                        <form action="${pageContext.request.contextPath}/admin/categories" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${c.id}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" data-confirm="Delete this category?">
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

    <!-- Add Category Modal -->
    <div id="addCategoryModal" class="modal">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 class="modal-title">Create Category</h3>
                <button type="button" class="modal-close" onclick="closeModal('addCategoryModal')">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/categories" method="post">
                <input type="hidden" name="action" value="create">

                <div class="form-group">
                    <label class="form-label">Category Name</label>
                    <input type="text" name="name" class="form-control" required placeholder="e.g. Gaming &amp; VR">
                </div>

                <div class="form-group">
                    <label class="form-label">Image Path / URL</label>
                    <input type="text" name="imageUrl" class="form-control" value="images/cat-default.jpg">
                </div>

                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea name="description" rows="3" class="form-control" placeholder="Brief summary of items in this category..."></textarea>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('addCategoryModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Category</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Category Modal -->
    <div id="editCategoryModal" class="modal">
        <div class="modal-dialog">
            <div class="modal-header">
                <h3 class="modal-title">Edit Category</h3>
                <button type="button" class="modal-close" onclick="closeModal('editCategoryModal')">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/categories" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" id="editCatId" name="id">

                <div class="form-group">
                    <label class="form-label">Category Name</label>
                    <input type="text" id="editCatName" name="name" class="form-control" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Image Path / URL</label>
                        <input type="text" id="editCatImageUrl" name="imageUrl" class="form-control">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select id="editCatStatus" name="status" class="form-control">
                            <option value="ACTIVE">ACTIVE</option>
                            <option value="INACTIVE">INACTIVE</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea id="editCatDesc" name="description" rows="3" class="form-control"></textarea>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('editCategoryModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
    <script>
        function editCategory(id, name, img, status, desc) {
            document.getElementById("editCatId").value = id;
            document.getElementById("editCatName").value = name;
            document.getElementById("editCatImageUrl").value = img;
            document.getElementById("editCatStatus").value = status;
            document.getElementById("editCatDesc").value = desc;
            openModal("editCategoryModal");
        }
    </script>
</body>
</html>
