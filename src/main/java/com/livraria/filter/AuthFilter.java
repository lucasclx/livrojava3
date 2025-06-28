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
        
        String loginPath = httpRequest.getContextPath() + "/login.jsp";
        boolean isLoggedIn = (session != null && session.getAttribute("usuarioId") != null);
        boolean isLoginRequest = httpRequest.getRequestURI().equals(loginPath) || httpRequest.getRequestURI().equals(httpRequest.getContextPath() + "/login");
        boolean isRegisterRequest = httpRequest.getRequestURI().equals(httpRequest.getContextPath() + "/login") && "registrar".equals(httpRequest.getParameter("action"));
        boolean isLoginPage = httpRequest.getRequestURI().endsWith("login.jsp");
        boolean isPublicResource = httpRequest.getRequestURI().contains("/css/") ||
                                   httpRequest.getRequestURI().contains("/js/") ||
                                   httpRequest.getRequestURI().contains("/images/") ||
                                   httpRequest.getRequestURI().endsWith(".html") ||
                                   httpRequest.getRequestURI().equals(httpRequest.getContextPath() + "/") ||
                                   httpRequest.getRequestURI().equals(httpRequest.getContextPath() + "/index.jsp");

        // Permitir acesso a recursos públicos, página de login e registro, ou se já logado
        if (isPublicResource || isLoggedIn || isLoginRequest || isRegisterRequest) {
            chain.doFilter(request, response);
        } else {
            // Redireciona para a página de login se não estiver logado e tentar acessar uma área protegida
            httpResponse.sendRedirect(loginPath);
        }
    }
    
    @Override
    public void destroy() {
        // Limpeza do filtro
    }
}