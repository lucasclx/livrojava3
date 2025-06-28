package com.livraria.servlet;

import com.livraria.dao.AvaliacaoDAO;
import com.livraria.model.Avaliacao;
import com.google.gson.Gson;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AvaliacaoServlet extends HttpServlet {
    private AvaliacaoDAO avaliacaoDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        avaliacaoDAO = new AvaliacaoDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Integer usuarioId = (Integer) session.getAttribute("usuarioId");
        
        if (usuarioId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"erro\":\"Usuário não autenticado\"}");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "criar":
                    criarAvaliacao(request, response, usuarioId);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"erro\":\"Ação não reconhecida\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"erro\":\"" + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String livroId = request.getParameter("livroId");
        
        if (livroId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do livro é obrigatório\"}");
            return;
        }
        
        try {
            List<Avaliacao> avaliacoes = avaliacaoDAO.listarPorLivro(Integer.parseInt(livroId));
            Map<String, Object> estatisticas = avaliacaoDAO.obterEstatisticas(Integer.parseInt(livroId));
            
            Map<String, Object> resultado = Map.of(
                "avaliacoes", avaliacoes,
                "estatisticas", estatisticas
            );
            
            response.getWriter().write(gson.toJson(resultado));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"erro\":\"" + e.getMessage() + "\"}");
        }
    }

    private void criarAvaliacao(HttpServletRequest request, HttpServletResponse response, int usuarioId) throws IOException {
        try {
            Avaliacao avaliacao = gson.fromJson(request.getReader(), Avaliacao.class);
            avaliacao.setUsuarioId(usuarioId);

            if (avaliacaoDAO.criar(avaliacao)) {
                response.getWriter().write("{\"sucesso\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"erro\":\"Não foi possível criar a avaliação\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Dados inválidos\"}");
        }
    }
}