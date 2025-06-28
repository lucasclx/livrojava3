package com.livraria.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet de teste simplificado para verificar se a aplicação está funcionando
 */
public class TestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Configurar encoding
        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        try {
            out.println("<!DOCTYPE html>");
            out.println("<html lang='pt-BR'>");
            out.println("<head>");
            out.println("    <meta charset='UTF-8'>");
            out.println("    <meta name='viewport' content='width=device-width, initial-scale=1.0'>");
            out.println("    <title>Teste - Livraria Online</title>");
            out.println("    <style>");
            out.println("        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }");
            out.println("        .container { max-width: 800px; margin: 0 auto; background: rgba(255,255,255,0.1); padding: 30px; border-radius: 15px; backdrop-filter: blur(10px); }");
            out.println("        .success { color: #4CAF50; font-size: 2em; margin-bottom: 20px; }");
            out.println("        .info { background: rgba(255,255,255,0.2); padding: 15px; border-radius: 8px; margin: 15px 0; }");
            out.println("        .btn { background: #4CAF50; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 10px 5px; }");
            out.println("        .btn:hover { background: #45a049; }");
            out.println("        .status { color: #90EE90; }");
            out.println("        .warning { color: #FFE135; }");
            out.println("    </style>");
            out.println("</head>");
            out.println("<body>");
            out.println("    <div class='container'>");
            out.println("        <h1 class='success'>✅ Servlet Funcionando!</h1>");
            out.println("        <p>Parabéns! O Tomcat está rodando corretamente e o servlet foi compilado com sucesso.</p>");
            
            out.println("        <div class='info'>");
            out.println("            <h3>📋 Informações do Sistema:</h3>");
            out.println("            <p><strong>Data/Hora:</strong> " + new java.util.Date() + "</p>");
            out.println("            <p><strong>Context Path:</strong> " + request.getContextPath() + "</p>");
            out.println("            <p><strong>Server Info:</strong> " + getServletContext().getServerInfo() + "</p>");
            out.println("            <p><strong>Session ID:</strong> " + request.getSession().getId() + "</p>");
            out.println("            <p><strong>Remote Address:</strong> " + request.getRemoteAddr() + "</p>");
            out.println("        </div>");
            
            out.println("        <div class='info'>");
            out.println("            <h3>🔗 Próximos Testes:</h3>");
            out.println("            <a href='" + request.getContextPath() + "/' class='btn'>Página Principal (JSP)</a>");
            out.println("            <a href='" + request.getContextPath() + "/teste-simples.jsp' class='btn'>Teste JSP Simples</a>");
            out.println("            <a href='" + request.getContextPath() + "/livros?action=listar' class='btn warning'>API Livros (pode falhar)</a>");
            out.println("        </div>");
            
            out.println("        <div class='info'>");
            out.println("            <h3>✅ Status da Aplicação:</h3>");
            out.println("            <p class='status'>• Tomcat: Funcionando</p>");
            out.println("            <p class='status'>• Servlet: Compilado e funcionando</p>");
            out.println("            <p class='status'>• Encoding UTF-8: OK</p>");
            out.println("            <p class='status'>• Sessões: Funcionando</p>");
            
            // Verificar se MySQL está disponível
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                out.println("            <p class='status'>• MySQL Driver: Disponível</p>");
            } catch (ClassNotFoundException e) {
                out.println("            <p class='warning'>• MySQL Driver: Não encontrado</p>");
            }
            
            // Verificar se Gson está disponível
            try {
                Class.forName("com.google.gson.Gson");
                out.println("            <p class='status'>• Gson: Disponível</p>");
            } catch (ClassNotFoundException e) {
                out.println("            <p class='warning'>• Gson: Não encontrado</p>");
            }
            
            out.println("        </div>");
            
            out.println("        <div class='info'>");
            out.println("            <h3>🎯 Próximos Passos:</h3>");
            out.println("            <ol style='text-align: left;'>");
            out.println("                <li>Se você vê esta página, o básico está funcionando ✅</li>");
            out.println("                <li>Adicione as dependências MySQL e Gson em WEB-INF/lib</li>");
            out.println("                <li>Descomente os outros servlets no web.xml gradualmente</li>");
            out.println("                <li>Teste cada funcionalidade uma por vez</li>");
            out.println("            </ol>");
            out.println("        </div>");
            
            out.println("    </div>");
            out.println("</body>");
            out.println("</html>");
            
        } finally {
            if (out != null) {
                out.close();
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}