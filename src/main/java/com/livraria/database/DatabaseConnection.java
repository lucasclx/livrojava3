package com.livraria.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.servlet.ServletContext;

public class DatabaseConnection {
    private static String driver;
    private static String url;
    private static String username;
    private static String password;
    
    public static void initialize(ServletContext context) {
        driver = context.getInitParameter("db.driver");
        url = context.getInitParameter("db.url");
        username = context.getInitParameter("db.username");
        password = context.getInitParameter("db.password");
        
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver do banco de dados não encontrado", e);
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
    
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}