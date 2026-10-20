package com.shopsphere.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DBConnectionTest {

    @Test
    @DisplayName("Should correctly load MySQL driver class and configuration properties")
    void testDriverAndConfigurationLoaded() {
        assertNotNull(DBConnection.getDbUrl(), "Database URL must not be null");
        assertTrue(DBConnection.getDbUrl().contains("shopsphere"), "Database URL should target 'shopsphere' schema");
        assertNotNull(DBConnection.getDbUser(), "Database user must not be null");
    }

    @Test
    @DisplayName("Driver class should be available on classpath")
    void testDriverClassExists() throws ClassNotFoundException {
        Class<?> driverClass = Class.forName("com.mysql.cj.jdbc.Driver");
        assertNotNull(driverClass, "MySQL Driver class must be available on the classpath");
    }
}
