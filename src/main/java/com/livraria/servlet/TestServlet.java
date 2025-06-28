package com.livraria.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class TestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Teste - Livraria Online</title>");
        out.println("<meta charset='UTF-8'>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>🎉 Aplicação funcionando!</h1>");
        out.println("<p>Se você está vendo esta página, o servlet está funcionando corretamente.</p>");
        out.println("<p><a href='index.jsp'>Ir para a página principal</a></p>");
        out.println("</body>");
        out.println("</html>");
    }
}