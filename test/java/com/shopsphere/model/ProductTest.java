package com.shopsphere.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class ProductTest {

    @Test
    @DisplayName("Discounted price calculation should compute accurate rounded amounts")
    void testDiscountCalculation() {
        Product product = new Product();
        product.setPrice(new BigDecimal("100.00"));
        product.setDiscount(new BigDecimal("15.00")); // 15% off

        assertEquals(new BigDecimal("85.00"), product.getDiscountedPrice());
        assertEquals(new BigDecimal("15.00"), product.getSavings());

        // Zero discount
        product.setDiscount(BigDecimal.ZERO);
        assertEquals(new BigDecimal("100.00"), product.getDiscountedPrice());
        assertEquals(new BigDecimal("0.00"), product.getSavings());
    }

    @Test
    @DisplayName("Product in-stock evaluation")
    void testStockStatus() {
        Product product = new Product();
        product.setStock(10);
        assertTrue(product.isInStock());

        product.setStock(0);
        assertFalse(product.isInStock());
    }
}
