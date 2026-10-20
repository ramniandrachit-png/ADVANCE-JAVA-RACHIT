package com.shopsphere.listener;

import com.shopsphere.util.DBConnection;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Enumeration;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Initializes application-wide resources and performs sanity checks on startup.
 * Deregisters JDBC drivers on shutdown to eliminate Tomcat classloader memory leaks.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(AppContextListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("=================================================");
        LOGGER.info("   Starting ShopSphere E-Commerce Application    ");
        LOGGER.info("=================================================");
        LOGGER.info("Testing database connection on startup...");

        boolean connected = DBConnection.checkConnection();
        if (connected) {
            LOGGER.info(">>> SUCCESS: Connected to ShopSphere MySQL database at " + DBConnection.getDbUrl());
        } else {
            LOGGER.warning(">>> NOTICE: Could not connect to MySQL database at " + DBConnection.getDbUrl() 
                    + ". Please ensure MySQL is running and database/shopsphere.sql has been imported.");
        }

        // Store application version and name in application scope
        sce.getServletContext().setAttribute("appName", "ShopSphere");
        sce.getServletContext().setAttribute("appVersion", "1.0.0");
        sce.getServletContext().setAttribute("dbConnected", connected);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("Shutting down ShopSphere application. Cleaning up JDBC drivers...");
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            try {
                DriverManager.deregisterDriver(driver);
                LOGGER.info("Deregistered JDBC driver: " + driver);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error deregistering driver " + driver, e);
            }
        }
    }
}
