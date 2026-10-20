package com.shopsphere.service;

import com.shopsphere.dao.ProductDAO;
import com.shopsphere.model.Product;

import java.math.BigDecimal;
import java.util.List;

public class ProductService {

    private final ProductDAO productDAO;

    public ProductService() {
        this.productDAO = new ProductDAO();
    }

    public ProductService(ProductDAO productDAO) {
        this.productDAO = productDAO;
    }

    public Product getProductById(Long id) {
        if (id == null || id <= 0) return null;
        return productDAO.findById(id);
    }

    public List<Product> getFilteredProducts(Integer categoryId, String keyword, BigDecimal minPrice, BigDecimal maxPrice, String sortBy, int page, int pageSize) {
        int limit = (pageSize > 0) ? pageSize : 12;
        int offset = (page > 1) ? (page - 1) * limit : 0;
        return productDAO.findFiltered(categoryId, keyword, minPrice, maxPrice, sortBy, offset, limit);
    }

    public int countFilteredProducts(Integer categoryId, String keyword, BigDecimal minPrice, BigDecimal maxPrice) {
        return productDAO.countFiltered(categoryId, keyword, minPrice, maxPrice);
    }

    public List<Product> getFeaturedProducts(int limit) {
        return productDAO.findFeatured(limit > 0 ? limit : 8);
    }

    public List<Product> getRelatedProducts(Long productId, Integer categoryId, int limit) {
        return productDAO.findRelated(productId, categoryId, limit > 0 ? limit : 4);
    }

    public List<Product> getAllProductsForAdmin() {
        return productDAO.findAllForAdmin();
    }

    public boolean createProduct(Product product) {
        validateProduct(product);
        return productDAO.create(product);
    }

    public boolean updateProduct(Product product) {
        if (product.getId() == null || product.getId() <= 0) {
            throw new IllegalArgumentException("Valid Product ID is required.");
        }
        validateProduct(product);
        return productDAO.update(product);
    }

    public boolean deleteProduct(Long id) {
        if (id == null || id <= 0) return false;
        return productDAO.delete(id);
    }

    public int countTotalProducts() {
        return productDAO.countTotalProducts();
    }

    private void validateProduct(Product p) {
        if (p.getName() == null || p.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Product title is required.");
        }
        if (p.getCategoryId() == null || p.getCategoryId() <= 0) {
            throw new IllegalArgumentException("Product category is required.");
        }
        if (p.getPrice() == null || p.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Price must be a valid positive amount.");
        }
        if (p.getStock() == null || p.getStock() < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative.");
        }
        if (p.getDiscount() != null && (p.getDiscount().compareTo(BigDecimal.ZERO) < 0 || p.getDiscount().compareTo(new BigDecimal("100")) > 0)) {
            throw new IllegalArgumentException("Discount percentage must be between 0 and 100.");
        }
        if (p.getImageUrl() == null || p.getImageUrl().trim().isEmpty()) {
            p.setImageUrl("images/prod-default.jpg");
        }
    }
}
