package com.shopsphere.service;

import com.shopsphere.dao.WishlistDAO;
import com.shopsphere.model.WishlistItem;

import java.util.List;

public class WishlistService {

    private final WishlistDAO wishlistDAO;

    public WishlistService() {
        this.wishlistDAO = new WishlistDAO();
    }

    public WishlistService(WishlistDAO wishlistDAO) {
        this.wishlistDAO = wishlistDAO;
    }

    public List<WishlistItem> getWishlist(Long userId) {
        if (userId == null || userId <= 0) return List.of();
        return wishlistDAO.findByUserId(userId);
    }

    public boolean addToWishlist(Long userId, Long productId) {
        if (userId == null || productId == null) return false;
        return wishlistDAO.add(userId, productId);
    }

    public boolean removeFromWishlist(Long userId, Long productId) {
        if (userId == null || productId == null) return false;
        return wishlistDAO.remove(userId, productId);
    }

    public boolean isProductInWishlist(Long userId, Long productId) {
        if (userId == null || productId == null) return false;
        return wishlistDAO.isProductInWishlist(userId, productId);
    }

    public int getWishlistCount(Long userId) {
        if (userId == null || userId <= 0) return 0;
        return wishlistDAO.countByUserId(userId);
    }
}
