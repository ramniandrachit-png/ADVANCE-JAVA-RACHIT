package com.shopsphere.service;

import com.shopsphere.dao.CategoryDAO;
import com.shopsphere.model.Category;

import java.util.List;

public class CategoryService {

    private final CategoryDAO categoryDAO;

    public CategoryService() {
        this.categoryDAO = new CategoryDAO();
    }

    public CategoryService(CategoryDAO categoryDAO) {
        this.categoryDAO = categoryDAO;
    }

    public List<Category> getActiveCategories() {
        return categoryDAO.findAllActive();
    }

    public List<Category> getAllCategoriesWithCount() {
        return categoryDAO.findAllWithProductCount();
    }

    public Category getCategoryById(Integer id) {
        if (id == null || id <= 0) return null;
        return categoryDAO.findById(id);
    }

    public Category getCategoryBySlug(String slug) {
        if (slug == null || slug.trim().isEmpty()) return null;
        return categoryDAO.findBySlug(slug.trim());
    }

    public boolean createCategory(String name, String description, String imageUrl) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Category name is required.");
        }
        String cleanName = name.trim();
        String slug = cleanName.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");

        Category c = new Category();
        c.setName(cleanName);
        c.setSlug(slug);
        c.setDescription(description != null ? description.trim() : "");
        c.setImageUrl(imageUrl != null ? imageUrl.trim() : "images/cat-default.jpg");
        c.setStatus(Category.Status.ACTIVE);

        return categoryDAO.create(c);
    }

    public boolean updateCategory(Integer id, String name, String description, String imageUrl, String status) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException("Invalid category ID.");
        }
        Category c = categoryDAO.findById(id);
        if (c == null) {
            return false;
        }

        String cleanName = name != null ? name.trim() : c.getName();
        String slug = cleanName.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");

        c.setName(cleanName);
        c.setSlug(slug);
        c.setDescription(description != null ? description.trim() : c.getDescription());
        c.setImageUrl(imageUrl != null ? imageUrl.trim() : c.getImageUrl());
        if (status != null && !status.trim().isEmpty()) {
            c.setStatus(Category.Status.valueOf(status.trim().toUpperCase()));
        }

        return categoryDAO.update(c);
    }

    public boolean deleteCategory(Integer id) {
        if (id == null || id <= 0) return false;
        return categoryDAO.delete(id);
    }

    public int countTotalCategories() {
        return categoryDAO.countTotalCategories();
    }
}
