package com.livraria.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AuthFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Inicialização do filtro
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        // Por enquanto, vamos apenas permitir acesso sem autenticação
        // Você pode implementar a lógica de autenticação aqui posteriormente
        
        /*
        // Exemplo de implementação de autenticação:
        String loginPath = httpRequest.getContextPath() + "/login.jsp";
        boolean isLoggedIn = (session != null && session.getAttribute("usuario") != null);
        boolean isLoginRequest = httpRequest.getRequestURI().equals(loginPath);
        boolean isLoginPage = httpRequest.getRequestURI().endsWith("login.jsp");
        
        if (isLoggedIn || isLoginRequest || isLoginPage) {
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(loginPath);
        }
        */
        
        // Por enquanto, apenas continuar sem autenticação
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Limpeza do filtro
    }
}