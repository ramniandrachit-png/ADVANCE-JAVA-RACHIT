package com.shopsphere.service;

import com.shopsphere.dao.CartDAO;
import com.shopsphere.dao.ProductDAO;
import com.shopsphere.model.Cart;
import com.shopsphere.model.CartItem;
import com.shopsphere.model.Product;
import jakarta.servlet.http.HttpSession;

public class CartService {

    private final CartDAO cartDAO;
    private final ProductDAO productDAO;

    public CartService() {
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
    }

    public CartService(CartDAO cartDAO, ProductDAO productDAO) {
        this.cartDAO = cartDAO;
        this.productDAO = productDAO;
    }

    /**
     * Retrieves the current cart for the user or guest session.
     */
    public Cart getCart(HttpSession session, Long userId) {
        if (userId != null && userId > 0) {
            Cart cart = cartDAO.getOrCreateCartForUser(userId);
            // Refresh product details and prices from DB
            refreshCartProductDetails(cart);
            return cart;
        }

        Cart sessionCart = (Cart) session.getAttribute("sessionCart");
        if (sessionCart == null) {
            sessionCart = new Cart();
            session.setAttribute("sessionCart", sessionCart);
        } else {
            refreshCartProductDetails(sessionCart);
        }
        return sessionCart;
    }

    /**
     * Adds an item to the cart after validating stock and product status.
     */
    public void addItem(HttpSession session, Long userId, Long productId, int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be greater than zero.");
        }

        Product product = productDAO.findById(productId);
        if (product == null || product.getStatus() != Product.Status.ACTIVE) {
            throw new IllegalArgumentException("Product is unavailable or inactive.");
        }

        if (product.getStock() < quantity) {
            throw new IllegalArgumentException("Only " + product.getStock() + " unit(s) available in stock.");
        }

        if (userId != null && userId > 0) {
            Cart cart = cartDAO.getOrCreateCartForUser(userId);
            // Check existing quantity
            for (CartItem item : cart.getItems()) {
                if (item.getProductId().equals(productId)) {
                    if (item.getQuantity() + quantity > product.getStock()) {
                        throw new IllegalArgumentException("Cannot add more. Reached available stock limit (" + product.getStock() + ").");
                    }
                }
            }
            cartDAO.addItem(cart.getId(), productId, quantity);
        } else {
            Cart cart = getCart(session, null);
            for (CartItem item : cart.getItems()) {
                if (item.getProductId().equals(productId)) {
                    if (item.getQuantity() + quantity > product.getStock()) {
                        throw new IllegalArgumentException("Cannot add more. Reached available stock limit (" + product.getStock() + ").");
                    }
                }
            }
            cart.addItem(new CartItem(productId, product, quantity));
            session.setAttribute("sessionCart", cart);
        }
    }

    /**
     * Updates an existing cart item's quantity.
     */
    public void updateQuantity(HttpSession session, Long userId, Long productId, int quantity) {
        if (quantity <= 0) {
            removeItem(session, userId, productId);
            return;
        }

        Product product = productDAO.findById(productId);
        if (product == null) {
            removeItem(session, userId, productId);
            return;
        }

        if (quantity > product.getStock()) {
            throw new IllegalArgumentException("Requested quantity exceeds available stock (" + product.getStock() + ").");
        }

        if (userId != null && userId > 0) {
            Cart cart = cartDAO.getOrCreateCartForUser(userId);
            cartDAO.updateItemQuantity(cart.getId(), productId, quantity);
        } else {
            Cart cart = getCart(session, null);
            cart.updateQuantity(productId, quantity);
            session.setAttribute("sessionCart", cart);
        }
    }

    /**
     * Removes an item from the cart.
     */
    public void removeItem(HttpSession session, Long userId, Long productId) {
        if (userId != null && userId > 0) {
            Cart cart = cartDAO.getOrCreateCartForUser(userId);
            cartDAO.removeItem(cart.getId(), productId);
        } else {
            Cart cart = getCart(session, null);
            cart.removeItem(productId);
            session.setAttribute("sessionCart", cart);
        }
    }

    /**
     * Clears all items from the cart.
     */
    public void clearCart(HttpSession session, Long userId) {
        if (userId != null && userId > 0) {
            Cart cart = cartDAO.getOrCreateCartForUser(userId);
            cartDAO.clearCart(cart.getId());
        }
        Cart sessionCart = (Cart) session.getAttribute("sessionCart");
        if (sessionCart != null) {
            sessionCart.clear();
        }
    }

    /**
     * Merges guest session cart items into user's DB cart upon login.
     */
    public void syncCartOnLogin(HttpSession session, Long userId) {
        Cart sessionCart = (Cart) session.getAttribute("sessionCart");
        if (sessionCart != null && !sessionCart.getItems().isEmpty()) {
            Cart dbCart = cartDAO.getOrCreateCartForUser(userId);
            for (CartItem item : sessionCart.getItems()) {
                cartDAO.addItem(dbCart.getId(), item.getProductId(), item.getQuantity());
            }
            sessionCart.clear();
            session.removeAttribute("sessionCart");
        }
    }

    private void refreshCartProductDetails(Cart cart) {
        if (cart == null || cart.getItems() == null) return;
        for (CartItem item : cart.getItems()) {
            Product fresh = productDAO.findById(item.getProductId());
            if (fresh != null) {
                item.setProduct(fresh);
            }
        }
    }
}
