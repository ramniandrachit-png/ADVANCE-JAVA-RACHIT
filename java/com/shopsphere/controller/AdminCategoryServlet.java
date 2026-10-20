package com.shopsphere.controller;

import com.shopsphere.model.Category;
import com.shopsphere.service.CategoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {

    private CategoryService categoryService;

    @Override
    public void init() throws ServletException {
        this.categoryService = new CategoryService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Category> categories = categoryService.getAllCategoriesWithCount();
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create": {
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    String imageUrl = request.getParameter("imageUrl");
                    categoryService.createCategory(name, description, imageUrl);
                    session.setAttribute("flashSuccess", "Category '" + name + "' created successfully.");
                    break;
                }
                case "update": {
                    Integer id = Integer.parseInt(request.getParameter("id"));
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    String imageUrl = request.getParameter("imageUrl");
                    String status = request.getParameter("status");
                    categoryService.updateCategory(id, name, description, imageUrl, status);
                    session.setAttribute("flashSuccess", "Category updated successfully.");
                    break;
                }
                case "delete": {
                    Integer id = Integer.parseInt(request.getParameter("id"));
                    boolean deleted = categoryService.deleteCategory(id);
                    if (deleted) {
                        session.setAttribute("flashSuccess", "Category deleted successfully.");
                    } else {
                        session.setAttribute("flashError", "Cannot delete category containing products. Reassign or delete products first.");
                    }
                    break;
                }
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("flashError", "Category operation failed: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }
}
