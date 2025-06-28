package com.livraria.servlet;

import com.livraria.dao.LivroDAO;
import com.livraria.model.Livro;
import com.google.gson.Gson;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LivroServlet extends HttpServlet {
    private LivroDAO livroDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        livroDAO = new LivroDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        try {
            switch (action != null ? action : "listar") {
                case "listar":
                    listarLivros(request, response);
                    break;
                case "buscar":
                    buscarLivros(request, response);
                    break;
                case "detalhes":
                    obterDetalhesLivro(request, response);
                    break;
                case "categoria":
                    buscarPorCategoria(request, response);
                    break;
                case "recomendacoes":
                    obterRecomendacoes(request, response);
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
    
    private void obterRecomendacoes(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        Integer usuarioId = (Integer) request.getSession().getAttribute("usuarioId");
        List<Livro> recomendacoes;

        if (usuarioId != null) {
            recomendacoes = livroDAO.obterRecomendacoes(usuarioId);
        } else {
            // Se não houver usuário logado, retorna livros aleatórios ou mais vendidos
            recomendacoes = livroDAO.listarTodos(); // Ou um método para livros populares
        }
        response.getWriter().write(gson.toJson(recomendacoes));
    }

    private void listarLivros(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        List<Livro> livros = livroDAO.listarTodos();
        response.getWriter().write(gson.toJson(livros));
    }
    
    private void buscarLivros(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String termo = request.getParameter("termo");
        if (termo == null || termo.trim().isEmpty()) {
            listarLivros(request, response);
            return;
        }
        
        List<Livro> livros = livroDAO.buscarPorTitulo(termo);
        response.getWriter().write(gson.toJson(livros));
    }
    
    private void obterDetalhesLivro(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do livro é obrigatório\"}");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            if (id <= 0) {
                throw new NumberFormatException("ID deve ser positivo");
            }
            Livro livro = livroDAO.buscarPorId(id);
            
            if (livro != null) {
                response.getWriter().write(gson.toJson(livro));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"erro\":\"Livro não encontrado\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID inválido\"}");
        }
    }
    
    private void buscarPorCategoria(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String categoria = request.getParameter("nome");
        if (categoria == null || categoria.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Nome da categoria é obrigatório\"}");
            return;
        }
        
        List<Livro> livros = livroDAO.buscarPorCategoria(categoria);
        response.getWriter().write(gson.toJson(livros));
    }
}