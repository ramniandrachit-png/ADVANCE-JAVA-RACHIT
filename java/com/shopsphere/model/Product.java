package com.shopsphere.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;

public class Product implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum Status {
        ACTIVE, INACTIVE
    }

    private Long id;
    private Integer categoryId;
    private String categoryName;
    private String name;
    private String brand;
    private String description;
    private BigDecimal price;
    private BigDecimal discount; // percentage 0-100
    private Integer stock;
    private String imageUrl;
    private Status status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Additional display fields
    private double averageRating;
    private int reviewCount;

    public Product() {
        this.price = BigDecimal.ZERO;
        this.discount = BigDecimal.ZERO;
        this.stock = 0;
        this.status = Status.ACTIVE;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price != null ? price : BigDecimal.ZERO;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public BigDecimal getDiscount() {
        return discount != null ? discount : BigDecimal.ZERO;
    }

    public void setDiscount(BigDecimal discount) {
        this.discount = discount;
    }

    public Integer getStock() {
        return stock != null ? stock : 0;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public boolean isInStock() {
        return stock != null && stock > 0;
    }

    /**
     * Computes the final discounted selling price.
     */
    public BigDecimal getDiscountedPrice() {
        if (price == null) {
            return BigDecimal.ZERO;
        }
        if (discount == null || discount.compareTo(BigDecimal.ZERO) <= 0) {
            return price.setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal discountFactor = BigDecimal.ONE.subtract(discount.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP));
        return price.multiply(discountFactor).setScale(2, RoundingMode.HALF_UP);
    }

    public BigDecimal getSavings() {
        return getPrice().subtract(getDiscountedPrice()).setScale(2, RoundingMode.HALF_UP);
    }
}
