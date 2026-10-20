package com.shopsphere.service;

import com.shopsphere.dao.AddressDAO;
import com.shopsphere.dao.OrderDAO;
import com.shopsphere.dao.ProductDAO;
import com.shopsphere.model.Address;
import com.shopsphere.model.Cart;
import com.shopsphere.model.CartItem;
import com.shopsphere.model.Coupon;
import com.shopsphere.model.Order;
import com.shopsphere.model.OrderItem;
import com.shopsphere.model.Payment;
import com.shopsphere.model.Product;
import com.shopsphere.model.User;
import jakarta.servlet.http.HttpSession;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CheckoutService {

    private final OrderDAO orderDAO;
    private final AddressDAO addressDAO;
    private final ProductDAO productDAO;
    private final CartService cartService;
    private final CouponService couponService;

    public CheckoutService() {
        this.orderDAO = new OrderDAO();
        this.addressDAO = new AddressDAO();
        this.productDAO = new ProductDAO();
        this.cartService = new CartService();
        this.couponService = new CouponService();
    }

    public CheckoutService(OrderDAO orderDAO, AddressDAO addressDAO, ProductDAO productDAO, CartService cartService, CouponService couponService) {
        this.orderDAO = orderDAO;
        this.addressDAO = addressDAO;
        this.productDAO = productDAO;
        this.cartService = cartService;
        this.couponService = couponService;
    }

    /**
     * Executes the checkout process with server-side pricing, stock checks,
     * coupon validation, and atomic database transaction.
     */
    public Order processCheckout(User user, Long addressId, Address newAddress, String paymentMethod, String couponCode, HttpSession session) {
        if (user == null || user.getId() == null) {
            throw new IllegalArgumentException("User must be logged in to complete checkout.");
        }

        // 1. Resolve Delivery Address
        Address deliveryAddress = null;
        if (addressId != null && addressId > 0) {
            deliveryAddress = addressDAO.findById(addressId);
            if (deliveryAddress == null || !deliveryAddress.getUserId().equals(user.getId())) {
                throw new IllegalArgumentException("Selected address was not found.");
            }
        } else if (newAddress != null) {
            newAddress.setUserId(user.getId());
            boolean created = addressDAO.create(newAddress);
            if (!created) {
                throw new IllegalStateException("Failed to save delivery address.");
            }
            deliveryAddress = newAddress;
        }

        if (deliveryAddress == null) {
            throw new IllegalArgumentException("Please select or enter a delivery address.");
        }

        // 2. Retrieve Cart
        Cart cart = cartService.getCart(session, user.getId());
        if (cart == null || cart.getItems().isEmpty()) {
            throw new IllegalStateException("Your shopping cart is empty.");
        }

        // 3. Validate Stock & Fresh Prices for all items
        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal calculatedSubtotal = BigDecimal.ZERO;

        for (CartItem item : cart.getItems()) {
            Product freshProduct = productDAO.findById(item.getProductId());
            if (freshProduct == null || freshProduct.getStatus() != Product.Status.ACTIVE) {
                throw new IllegalStateException("Product '" + (item.getProduct() != null ? item.getProduct().getName() : item.getProductId()) + "' is no longer available.");
            }
            if (freshProduct.getStock() < item.getQuantity()) {
                throw new IllegalStateException("Insufficient stock for '" + freshProduct.getName() + "'. Only " + freshProduct.getStock() + " available.");
            }

            BigDecimal unitPrice = freshProduct.getPrice();
            BigDecimal discount = freshProduct.getDiscount();
            BigDecimal discountedUnitPrice = freshProduct.getDiscountedPrice();
            BigDecimal itemSubtotal = discountedUnitPrice.multiply(BigDecimal.valueOf(item.getQuantity())).setScale(2, RoundingMode.HALF_UP);

            OrderItem orderItem = new OrderItem();
            orderItem.setProductId(freshProduct.getId());
            orderItem.setProductName(freshProduct.getName());
            orderItem.setProductImageUrl(freshProduct.getImageUrl());
            orderItem.setUnitPrice(unitPrice);
            orderItem.setDiscountApplied(discount);
            orderItem.setQuantity(item.getQuantity());
            orderItem.setSubtotal(itemSubtotal);

            orderItems.add(orderItem);
            calculatedSubtotal = calculatedSubtotal.add(itemSubtotal);
        }

        // 4. Calculate Coupon Discount on Server
        BigDecimal couponDiscount = BigDecimal.ZERO;
        String cleanCouponCode = null;
        if (couponCode != null && !couponCode.trim().isEmpty()) {
            try {
                Coupon coupon = couponService.validateCoupon(couponCode, calculatedSubtotal);
                if (coupon.getDiscountType() == Coupon.DiscountType.PERCENTAGE) {
                    couponDiscount = calculatedSubtotal.multiply(coupon.getDiscountValue().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP));
                } else {
                    couponDiscount = coupon.getDiscountValue();
                }
                if (couponDiscount.compareTo(calculatedSubtotal) > 0) {
                    couponDiscount = calculatedSubtotal;
                }
                cleanCouponCode = coupon.getCode();
            } catch (Exception e) {
                throw new IllegalArgumentException("Coupon error: " + e.getMessage());
            }
        }

        // 5. Calculate Shipping Fee
        BigDecimal shippingFee = (calculatedSubtotal.compareTo(new BigDecimal("50.00")) >= 0) 
                ? BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP) 
                : new BigDecimal("5.00").setScale(2, RoundingMode.HALF_UP);

        BigDecimal grandTotal = calculatedSubtotal.subtract(couponDiscount).add(shippingFee);
        if (grandTotal.compareTo(BigDecimal.ZERO) < 0) {
            grandTotal = BigDecimal.ZERO;
        }
        grandTotal = grandTotal.setScale(2, RoundingMode.HALF_UP);

        // 6. Build Order Object
        String orderNumber = "ORD-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        Order order = new Order();
        order.setOrderNumber(orderNumber);
        order.setUserId(user.getId());
        order.setRecipientName(deliveryAddress.getRecipientName());
        order.setRecipientPhone(deliveryAddress.getPhone());
        order.setShippingAddress(deliveryAddress.getFormattedAddress());
        order.setSubtotal(calculatedSubtotal);
        order.setDiscountAmount(couponDiscount);
        order.setShippingFee(shippingFee);
        order.setTotalAmount(grandTotal);
        order.setOrderStatus(Order.OrderStatus.CONFIRMED);
        order.setCouponCode(cleanCouponCode);

        // Payment setup
        String method = (paymentMethod != null && !paymentMethod.trim().isEmpty()) ? paymentMethod.trim().toUpperCase() : "COD";
        order.setPaymentMethod(method);

        Payment payment = new Payment();
        payment.setAmount(grandTotal);
        payment.setMethod(method);

        if ("COD".equalsIgnoreCase(method)) {
            order.setPaymentStatus(Order.PaymentStatus.PENDING);
            payment.setStatus(Payment.Status.PENDING);
            payment.setTransactionRef("COD-PENDING");
        } else {
            // Demo Card or Demo UPI
            order.setPaymentStatus(Order.PaymentStatus.PAID);
            payment.setStatus(Payment.Status.SUCCESS);
            payment.setTransactionRef("DEMO-TXN-" + System.currentTimeMillis());
        }

        // 7. Execute Atomic Transaction in DB
        boolean success = orderDAO.placeOrderTransaction(order, orderItems, payment, cart.getId());
        if (!success) {
            throw new IllegalStateException("Could not complete order. Inventory may have changed or transaction failed. Please try again.");
        }

        // Clear session cart too
        Cart sessionCart = (Cart) session.getAttribute("sessionCart");
        if (sessionCart != null) {
            sessionCart.clear();
        }

        order.setItems(orderItems);
        return order;
    }
}
