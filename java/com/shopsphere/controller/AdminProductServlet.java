package com.shopsphere.controller;

import com.shopsphere.model.Category;
import com.shopsphere.model.Product;
import com.shopsphere.service.CategoryService;
import com.shopsphere.service.ProductService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products"})
public class AdminProductServlet extends HttpServlet {

    private ProductService productService;
    private CategoryService categoryService;

    @Override
    public void init() throws ServletException {
        this.productService = new ProductService();
        this.categoryService = new CategoryService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Product> products = productService.getAllProductsForAdmin();
        List<Category> categories = categoryService.getActiveCategories();

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/admin/products.jsp").forward(request, response);
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
                    Product p = new Product();
                    p.setName(request.getParameter("name"));
                    p.setBrand(request.getParameter("brand"));
                    p.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
                    p.setDescription(request.getParameter("description"));
                    p.setPrice(new BigDecimal(request.getParameter("price")));
                    p.setDiscount(new BigDecimal(request.getParameter("discount")));
                    p.setStock(Integer.parseInt(request.getParameter("stock")));
                    p.setImageUrl(request.getParameter("imageUrl"));
                    p.setStatus(Product.Status.valueOf(request.getParameter("status")));

                    productService.createProduct(p);
                    session.setAttribute("flashSuccess", "Product '" + p.getName() + "' created successfully.");
                    break;
                }
                case "update": {
                    Long id = Long.parseLong(request.getParameter("id"));
                    Product p = productService.getProductById(id);
                    if (p != null) {
                        p.setName(request.getParameter("name"));
                        p.setBrand(request.getParameter("brand"));
                        p.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
                        p.setDescription(request.getParameter("description"));
                        p.setPrice(new BigDecimal(request.getParameter("price")));
                        p.setDiscount(new BigDecimal(request.getParameter("discount")));
                        p.setStock(Integer.parseInt(request.getParameter("stock")));
                        p.setImageUrl(request.getParameter("imageUrl"));
                        p.setStatus(Product.Status.valueOf(request.getParameter("status")));

                        productService.updateProduct(p);
                        session.setAttribute("flashSuccess", "Product '" + p.getName() + "' updated successfully.");
                    }
                    break;
                }
                case "delete": {
                    Long id = Long.parseLong(request.getParameter("id"));
                    boolean deleted = productService.deleteProduct(id);
                    if (deleted) {
                        session.setAttribute("flashSuccess", "Product deleted or deactivated successfully.");
                    } else {
                        session.setAttribute("flashError", "Could not delete product.");
                    }
                    break;
                }
                case "toggleStatus": {
                    Long id = Long.parseLong(request.getParameter("id"));
                    Product p = productService.getProductById(id);
                    if (p != null) {
                        p.setStatus(p.getStatus() == Product.Status.ACTIVE ? Product.Status.INACTIVE : Product.Status.ACTIVE);
                        productService.updateProduct(p);
                        session.setAttribute("flashSuccess", "Product status changed to " + p.getStatus());
                    }
                    break;
                }
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("flashError", "Failed to process product action: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/products");
    }
}
