package com.livraria.servlet;

import com.livraria.dao.LivroDAO;
import com.livraria.model.Livro;
import com.google.gson.Gson;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class CarrinhoServlet extends HttpServlet {
    private LivroDAO livroDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        livroDAO = new LivroDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
        try {
            switch (action != null ? action : "") {
                case "adicionar":
                    adicionarItem(request, response, session);
                    break;
                case "remover":
                    removerItem(request, response, session);
                    break;
                case "atualizar":
                    atualizarQuantidade(request, response, session);
                    break;
                case "limpar":
                    limparCarrinho(request, response, session);
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
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
        if ("listar".equals(action)) {
            listarItensCarrinho(request, response, session);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Ação não reconhecida\"}");
        }
    }
    
    private void adicionarItem(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws SQLException, IOException {
        
        String livroIdParam = request.getParameter("livroId");
        String quantidadeParam = request.getParameter("quantidade");
        
        if (livroIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do livro é obrigatório\"}");
            return;
        }
        
        try {
            int livroId = Integer.parseInt(livroIdParam);
            int quantidade = quantidadeParam != null ? Integer.parseInt(quantidadeParam) : 1;
            
            Livro livro = livroDAO.buscarPorId(livroId);
            if (livro == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"erro\":\"Livro não encontrado\"}");
                return;
            }
            
            if (livro.getEstoque() < quantidade) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"erro\":\"Estoque insuficiente\"}");
                return;
            }
            
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> carrinho = (Map<Integer, Integer>) session.getAttribute("carrinho");
            if (carrinho == null) {
                carrinho = new HashMap<>();
            }
            
            int quantidadeAtual = carrinho.getOrDefault(livroId, 0);
            int novaQuantidade = quantidadeAtual + quantidade;
            
            if (novaQuantidade > livro.getEstoque()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"erro\":\"Quantidade total excede o estoque disponível\"}");
                return;
            }
            
            carrinho.put(livroId, novaQuantidade);
            session.setAttribute("carrinho", carrinho);
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Item adicionado ao carrinho");
            resultado.put("totalItens", calcularTotalItens(carrinho));
            
            response.getWriter().write(gson.toJson(resultado));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Parâmetros inválidos\"}");
        }
    }
    
    private void removerItem(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        
        String livroIdParam = request.getParameter("livroId");
        
        if (livroIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do livro é obrigatório\"}");
            return;
        }
        
        try {
            int livroId = Integer.parseInt(livroIdParam);
            
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> carrinho = (Map<Integer, Integer>) session.getAttribute("carrinho");
            if (carrinho != null) {
                carrinho.remove(livroId);
                session.setAttribute("carrinho", carrinho);
            }
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Item removido do carrinho");
            resultado.put("totalItens", carrinho != null ? calcularTotalItens(carrinho) : 0);
            
            response.getWriter().write(gson.toJson(resultado));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID inválido\"}");
        }
    }
    
    private void atualizarQuantidade(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws SQLException, IOException {
        
        String livroIdParam = request.getParameter("livroId");
        String quantidadeParam = request.getParameter("quantidade");
        
        if (livroIdParam == null || quantidadeParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do livro e quantidade são obrigatórios\"}");
            return;
        }
        
        try {
            int livroId = Integer.parseInt(livroIdParam);
            int quantidade = Integer.parseInt(quantidadeParam);
            
            if (quantidade <= 0) {
                removerItem(request, response, session);
                return;
            }
            
            Livro livro = livroDAO.buscarPorId(livroId);
            if (livro == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"erro\":\"Livro não encontrado\"}");
                return;
            }
            
            if (quantidade > livro.getEstoque()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"erro\":\"Quantidade excede o estoque disponível\"}");
                return;
            }
            
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> carrinho = (Map<Integer, Integer>) session.getAttribute("carrinho");
            if (carrinho == null) {
                carrinho = new HashMap<>();
            }
            
            carrinho.put(livroId, quantidade);
            session.setAttribute("carrinho", carrinho);
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Quantidade atualizada");
            resultado.put("totalItens", calcularTotalItens(carrinho));
            
            response.getWriter().write(gson.toJson(resultado));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Parâmetros inválidos\"}");
        }
    }
    
    private void limparCarrinho(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        
        session.removeAttribute("carrinho");
        
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("sucesso", true);
        resultado.put("mensagem", "Carrinho limpo");
        resultado.put("totalItens", 0);
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void listarItensCarrinho(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        
        @SuppressWarnings("unchecked")
        Map<Integer, Integer> carrinho = (Map<Integer, Integer>) session.getAttribute("carrinho");
        
        List<Map<String, Object>> itens = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;
        
        if (carrinho != null && !carrinho.isEmpty()) {
            try {
                for (Map.Entry<Integer, Integer> entry : carrinho.entrySet()) {
                    Livro livro = livroDAO.buscarPorId(entry.getKey());
                    if (livro != null) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("id", livro.getId());
                        item.put("titulo", livro.getTitulo());
                        item.put("autor", livro.getAutor());
                        item.put("preco", livro.getPreco());
                        item.put("quantidade", entry.getValue());
                        item.put("subtotal", livro.getPreco().multiply(new BigDecimal(entry.getValue())));
                        
                        itens.add(item);
                        total = total.add(livro.getPreco().multiply(new BigDecimal(entry.getValue())));
                    }
                }
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"erro\":\"Erro ao carregar itens do carrinho\"}");
                return;
            }
        }
        
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("itens", itens);
        resultado.put("total", total);
        resultado.put("totalItens", calcularTotalItens(carrinho));
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private int calcularTotalItens(Map<Integer, Integer> carrinho) {
        if (carrinho == null) return 0;
        return carrinho.values().stream().mapToInt(Integer::intValue).sum();
    }
}