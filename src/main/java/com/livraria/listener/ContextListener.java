package com.livraria.listener;

import com.livraria.database.DatabaseConnection;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

// Remover @WebListener e configurar no web.xml
public class ContextListener implements ServletContextListener {
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Inicializar conexão com banco de dados
        DatabaseConnection.initialize(sce.getServletContext());
        
        System.out.println("Aplicação Livraria Online inicializada com sucesso!");
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Aplicação Livraria Online finalizada!");
    }
}