package com.livraria.servlet;

import com.livraria.dao.UsuarioDAO;
import com.livraria.model.Usuario;
import com.google.gson.Gson;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.MultipartConfig;

@MultipartConfig

public class LoginServlet extends HttpServlet {
    private UsuarioDAO usuarioDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        usuarioDAO = new UsuarioDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        try {
            switch (action != null ? action : "") {
                case "login":
                    fazerLogin(request, response);
                    break;
                case "logout":
                    fazerLogout(request, response);
                    break;
                case "registrar":
                    registrarUsuario(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"erro\":\"Ação não reconhecida\"}");
            }
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"erro\":\"Erro no banco de dados: " + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("status".equals(action)) {
            verificarStatusLogin(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Ação não reconhecida\"}");
        }
    }
    
    private void fazerLogin(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        
        System.out.println("Tentativa de login para o email: " + email);

        if (email == null || email.trim().isEmpty() || senha == null || senha.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Email e senha são obrigatórios\"}");
            return;
        }
        
        Usuario usuario = usuarioDAO.autenticar(email.trim(), senha);
        
        System.out.println("Usuário encontrado: " + (usuario != null ? usuario.getEmail() : "null"));

        Map<String, Object> resultado = new HashMap<>();
        
        if (usuario != null) {
            HttpSession session = request.getSession();
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioId", usuario.getId());
            session.setAttribute("usuarioTipo", usuario.getTipo());
            
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Login realizado com sucesso");
            resultado.put("usuario", Map.of(
                "id", usuario.getId(),
                "nome", usuario.getNome(),
                "email", usuario.getEmail(),
                "tipo", usuario.getTipo()
            ));
            resultado.put("redirecionamento", "admin".equals(usuario.getTipo()) ? "admin/admin.jsp" : "index.jsp");
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resultado.put("erro", "Email ou senha inválidos");
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void fazerLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("sucesso", true);
        resultado.put("mensagem", "Logout realizado com sucesso");
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void registrarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        String confirmarSenha = request.getParameter("confirmarSenha");
        
        // Validações
        if (nome == null || nome.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Nome é obrigatório\"}");
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Email é obrigatório\"}");
            return;
        }
        
        if (senha == null || senha.length() < 6) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Senha deve ter pelo menos 6 caracteres\"}");
            return;
        }
        
        if (!senha.equals(confirmarSenha)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Senhas não conferem\"}");
            return;
        }
        
        // Verificar se email já existe
        if (usuarioDAO.buscarPorEmail(email.trim()) != null) {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            response.getWriter().write("{\"erro\":\"Email já cadastrado\"}");
            return;
        }
        
        Usuario usuario = new Usuario();
        usuario.setNome(nome.trim());
        usuario.setEmail(email.trim().toLowerCase());
        usuario.setSenha(senha); // Em produção, fazer hash da senha
        usuario.setTipo("cliente");
        usuario.setAtivo(true);
        
        boolean sucesso = usuarioDAO.salvar(usuario);
        
        Map<String, Object> resultado = new HashMap<>();
        if (sucesso) {
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Usuário cadastrado com sucesso! Faça login para continuar.");
        } else {
            resultado.put("erro", "Falha ao cadastrar usuário");
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void verificarStatusLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        Map<String, Object> resultado = new HashMap<>();
        
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            resultado.put("logado", true);
            resultado.put("usuario", Map.of(
                "id", usuario.getId(),
                "nome", usuario.getNome(),
                "email", usuario.getEmail(),
                "tipo", usuario.getTipo()
            ));
        } else {
            resultado.put("logado", false);
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
}