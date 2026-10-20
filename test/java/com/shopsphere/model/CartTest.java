package com.shopsphere.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class CartTest {

    @Test
    @DisplayName("Cart subtotal and free shipping thresholds")
    void testCartCalculations() {
        Cart cart = new Cart();
        assertEquals(0, cart.getSubtotal().compareTo(BigDecimal.ZERO));
        assertEquals(0, cart.getShippingFee().compareTo(BigDecimal.ZERO));

        Product p1 = new Product();
        p1.setId(1L);
        p1.setPrice(new BigDecimal("30.00"));
        p1.setDiscount(BigDecimal.ZERO);

        cart.addItem(new CartItem(1L, p1, 1));
        assertEquals(0, cart.getSubtotal().compareTo(new BigDecimal("30.00")));
        // Under $50, shipping is $5.00
        assertEquals(0, cart.getShippingFee().compareTo(new BigDecimal("5.00")));
        assertEquals(0, cart.getGrandTotal().compareTo(new BigDecimal("35.00")));

        // Add second item so subtotal becomes $60 (exceeds $50)
        cart.addItem(new CartItem(1L, p1, 1));
        assertEquals(0, cart.getSubtotal().compareTo(new BigDecimal("60.00")));
        assertEquals(0, cart.getShippingFee().compareTo(BigDecimal.ZERO));
        assertEquals(0, cart.getGrandTotal().compareTo(new BigDecimal("60.00")));
    }
}
