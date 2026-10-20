<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Moderate Reviews - ShopSphere Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="admin-layout">
        <c:set var="pageTitle" value="Manage Reviews" scope="request"/>
        <jsp:include page="../fragments/sidebar.jsp"/>

        <main class="admin-main">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <div>
                    <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">Customer Reviews Moderation</h1>
                    <p style="color: var(--text-muted); font-size: 0.95rem;">Review feedback from verified shoppers and maintain quality standards</p>
                </div>
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
                            <th>Product</th>
                            <th>Customer</th>
                            <th>Rating</th>
                            <th>Review Feedback</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="rev" items="${reviews}">
                            <tr>
                                <td style="font-weight: 700; color: var(--primary);">
                                    <a href="${pageContext.request.contextPath}/product?id=${rev.productId}" target="_blank">
                                        <c:out value="${rev.productName}"/>
                                    </a>
                                </td>
                                <td style="font-weight: 600;"><c:out value="${rev.userName}"/></td>
                                <td>
                                    <span class="stars">
                                        <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                                    </span>
                                    (${rev.rating}/5)
                                </td>
                                <td style="color: #334155; font-size: 0.9rem; max-width: 380px;">
                                    "<c:out value="${rev.reviewText}"/>"
                                </td>
                                <td style="font-size: 0.85rem; color: var(--text-muted);">
                                    <fmt:formatDate value="${rev.createdAt}" pattern="MMM dd, yyyy"/>
                                </td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/reviews/delete" method="post" style="display:inline;">
                                        <input type="hidden" name="reviewId" value="${rev.id}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" data-confirm="Remove this review permanently?">
                                            Delete Review
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>
