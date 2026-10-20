package com.shopsphere.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBConnection provides centralized, thread-safe JDBC connection handling
 * for the ShopSphere application.
 *
 * It reads credentials in the following order of precedence:
 * 1. Environment variables (DB_URL, DB_USER, DB_PASSWORD, DB_DRIVER)
 * 2. JVM System properties
 * 3. Classpath resource: db.properties
 * 4. Safe fallback defaults for local development (MySQL 3306, user: root, pass: root)
 */
public final class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static String dbUrl;
    private static String dbUser;
    private static String dbPassword;
    private static String dbDriver;

    static {
        loadConfiguration();
    }

    private DBConnection() {
        // Utility class: prevent instantiation
    }

    /**
     * Loads database configuration from environment variables or properties file.
     */
    public static synchronized void loadConfiguration() {
        Properties props = new Properties();

        // 1. Try to load from classpath db.properties
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Could not load db.properties from classpath; falling back to environment/defaults: {0}", e.getMessage());
        }

        // 2. Read with precedence: Env Var -> System Prop -> db.properties -> Default
        dbDriver = getSetting("DB_DRIVER", props.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
        dbUrl = getSetting("DB_URL", props.getProperty("db.url", "jdbc:mysql://localhost:3306/shopsphere?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8"));
        dbUser = getSetting("DB_USER", props.getProperty("db.user", "root"));
        dbPassword = getSetting("DB_PASSWORD", props.getProperty("db.password", "root"));

        // Register MySQL Driver
        try {
            Class.forName(dbDriver);
            LOGGER.info("MySQL JDBC Driver registered successfully: " + dbDriver);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found in classpath: " + dbDriver, e);
        }
    }

    private static String getSetting(String envKey, String fallback) {
        String envVal = System.getenv(envKey);
        if (envVal != null && !envVal.trim().isEmpty()) {
            return envVal.trim();
        }
        String sysProp = System.getProperty(envKey);
        if (sysProp != null && !sysProp.trim().isEmpty()) {
            return sysProp.trim();
        }
        return fallback;
    }

    /**
     * Retrieves a new active database Connection.
     *
     * @return Connection JDBC connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to obtain database connection from: " + dbUrl + " (User: " + dbUser + "). Verify MySQL service is running.", e);
            throw e;
        }
    }

    /**
     * Tests whether the database connection is currently alive and reachable.
     *
     * @return true if connection succeeds, false otherwise
     */
    public static boolean checkConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Database connectivity test failed: " + e.getMessage());
            return false;
        }
    }

    /**
     * Safely closes one or more closeable resources without throwing checked exceptions.
     *
     * @param resources JDBC statements, result sets, connections, or streams
     */
    public static void closeQuietly(AutoCloseable... resources) {
        if (resources == null) return;
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception ignored) {
                    // Ignored on cleanup
                }
            }
        }
    }

    public static String getDbUrl() {
        return dbUrl;
    }

    public static String getDbUser() {
        return dbUser;
    }
}
