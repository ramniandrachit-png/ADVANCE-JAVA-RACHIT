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

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "ProductServlet", urlPatterns = {"/products"})
public class ProductServlet extends HttpServlet {

    private ProductService productService;
    private CategoryService categoryService;

    private static final int PAGE_SIZE = 9;

    @Override
    public void init() throws ServletException {
        this.productService = new ProductService();
        this.categoryService = new CategoryService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Parse category filter (supports either category id or slug)
        Integer categoryId = null;
        String catParam = request.getParameter("category");
        if (catParam != null && !catParam.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(catParam.trim());
            } catch (NumberFormatException e) {
                Category cat = categoryService.getCategoryBySlug(catParam.trim());
                if (cat != null) {
                    categoryId = cat.getId();
                }
            }
        }

        // Parse search query
        String keyword = request.getParameter("q");
        if (keyword != null) {
            keyword = keyword.trim();
        }

        // Parse price range
        BigDecimal minPrice = null;
        BigDecimal maxPrice = null;
        try {
            String minParam = request.getParameter("minPrice");
            if (minParam != null && !minParam.trim().isEmpty()) {
                minPrice = new BigDecimal(minParam.trim());
            }
        } catch (Exception ignored) {
        }
        try {
            String maxParam = request.getParameter("maxPrice");
            if (maxParam != null && !maxParam.trim().isEmpty()) {
                maxPrice = new BigDecimal(maxParam.trim());
            }
        } catch (Exception ignored) {
        }

        // Parse sort
        String sortBy = request.getParameter("sort");

        // Parse page
        int page = 1;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            }
        } catch (NumberFormatException ignored) {
        }

        // Fetch filtered results
        int totalProducts = productService.countFilteredProducts(categoryId, keyword, minPrice, maxPrice);
        int totalPages = (int) Math.ceil((double) totalProducts / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Product> products = productService.getFilteredProducts(categoryId, keyword, minPrice, maxPrice, sortBy, page, PAGE_SIZE);
        List<Category> categories = categoryService.getActiveCategories();

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("keyword", keyword);
        request.setAttribute("minPrice", minPrice);
        request.setAttribute("maxPrice", maxPrice);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }
}
