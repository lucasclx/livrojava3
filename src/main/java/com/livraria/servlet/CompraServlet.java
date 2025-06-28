package com.livraria.servlet;

import com.livraria.dao.LivroDAO;
import com.livraria.dao.PedidoDAO;
import com.livraria.model.Livro;
import com.livraria.model.Pedido;
import com.livraria.model.ItemPedido;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
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

public class CompraServlet extends HttpServlet {
    private LivroDAO livroDAO;
    private PedidoDAO pedidoDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        livroDAO = new LivroDAO();
        pedidoDAO = new PedidoDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        try {
            switch (action != null ? action : "") {
                case "finalizar":
                    finalizarCompra(request, response);
                    break;
                case "simular":
                    simularCompra(request, response);
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
        
        try {
            switch (action != null ? action : "") {
                case "historico":
                    obterHistoricoPedidos(request, response);
                    break;
                case "detalhes":
                    obterDetalhesPedido(request, response);
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
    
    private void finalizarCompra(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"erro\":\"Usuário não autenticado\"}");
            return;
        }
        
        Integer usuarioId = (Integer) session.getAttribute("usuarioId");
        String carrinhoJson = request.getParameter("carrinho");
        String enderecoEntrega = request.getParameter("endereco");
        
        if (carrinhoJson == null || carrinhoJson.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Carrinho vazio\"}");
            return;
        }
        
        if (enderecoEntrega == null || enderecoEntrega.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Endereço de entrega é obrigatório\"}");
            return;
        }
        
        // Converter JSON do carrinho para lista de itens
        List<Map<String, Object>> itensCarrinho = gson.fromJson(carrinhoJson, 
            new TypeToken<List<Map<String, Object>>>(){}.getType());
        
        if (itensCarrinho.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Carrinho vazio\"}");
            return;
        }
        
        // Validar estoque e calcular total
        BigDecimal total = BigDecimal.ZERO;
        List<ItemPedido> itensPedido = new ArrayList<>();
        
        for (Map<String, Object> itemCarrinho : itensCarrinho) {
            int livroId = ((Double) itemCarrinho.get("id")).intValue();
            int quantidade = ((Double) itemCarrinho.get("quantidade")).intValue();
            
            Livro livro = livroDAO.buscarPorId(livroId);
            if (livro == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"erro\":\"Livro não encontrado: ID " + livroId + "\"}");
                return;
            }
            
            if (livro.getEstoque() < quantidade) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"erro\":\"Estoque insuficiente para: " + livro.getTitulo() + "\"}");
                return;
            }
            
            ItemPedido item = new ItemPedido();
            item.setLivroId(livroId);
            item.setQuantidade(quantidade);
            item.setPrecoUnitario(livro.getPreco());
            
            itensPedido.add(item);
            total = total.add(livro.getPreco().multiply(new BigDecimal(quantidade)));
        }
        
        // Criar pedido
        Pedido pedido = new Pedido();
        pedido.setUsuarioId(usuarioId);
        pedido.setTotal(total);
        pedido.setStatus("pendente");
        pedido.setEnderecoEntrega(enderecoEntrega.trim());
        
        // Salvar pedido e itens
        boolean sucesso = pedidoDAO.salvarPedidoCompleto(pedido, itensPedido);
        
        if (sucesso) {
            // Atualizar estoque dos livros
            for (ItemPedido item : itensPedido) {
                Livro livro = livroDAO.buscarPorId(item.getLivroId());
                int novoEstoque = livro.getEstoque() - item.getQuantidade();
                livroDAO.atualizarEstoque(item.getLivroId(), novoEstoque);
            }
            
            // Limpar carrinho da sessão
            session.removeAttribute("carrinho");
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Pedido realizado com sucesso!");
            resultado.put("pedidoId", pedido.getId());
            resultado.put("total", total);
            
            response.getWriter().write(gson.toJson(resultado));
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"erro\":\"Falha ao processar pedido\"}");
        }
    }
    
    private void simularCompra(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        String carrinhoJson = request.getParameter("carrinho");
        
        if (carrinhoJson == null || carrinhoJson.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Carrinho vazio\"}");
            return;
        }
        
        // Converter JSON do carrinho para lista de itens
        List<Map<String, Object>> itensCarrinho = gson.fromJson(carrinhoJson, 
            new TypeToken<List<Map<String, Object>>>(){}.getType());
        
        BigDecimal total = BigDecimal.ZERO;
        List<Map<String, Object>> itensValidados = new ArrayList<>();
        boolean temProblemas = false;
        List<String> problemas = new ArrayList<>();
        
        for (Map<String, Object> itemCarrinho : itensCarrinho) {
            int livroId = ((Double) itemCarrinho.get("id")).intValue();
            int quantidade = ((Double) itemCarrinho.get("quantidade")).intValue();
            
            Livro livro = livroDAO.buscarPorId(livroId);
            if (livro == null) {
                problemas.add("Livro não encontrado: ID " + livroId);
                temProblemas = true;
                continue;
            }
            
            Map<String, Object> itemValidado = new HashMap<>();
            itemValidado.put("livro", livro);
            itemValidado.put("quantidade", quantidade);
            itemValidado.put("subtotal", livro.getPreco().multiply(new BigDecimal(quantidade)));
            
            if (livro.getEstoque() < quantidade) {
                itemValidado.put("problema", "Estoque insuficiente. Disponível: " + livro.getEstoque());
                temProblemas = true;
            } else {
                total = total.add(livro.getPreco().multiply(new BigDecimal(quantidade)));
            }
            
            itensValidados.add(itemValidado);
        }
        
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("itens", itensValidados);
        resultado.put("total", total);
        resultado.put("temProblemas", temProblemas);
        resultado.put("problemas", problemas);
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void obterHistoricoPedidos(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"erro\":\"Usuário não autenticado\"}");
            return;
        }
        
        Integer usuarioId = (Integer) session.getAttribute("usuarioId");
        List<Pedido> pedidos = pedidoDAO.listarPorUsuario(usuarioId);
        
        response.getWriter().write(gson.toJson(pedidos));
    }
    
    private void obterDetalhesPedido(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"erro\":\"Usuário não autenticado\"}");
            return;
        }
        
        String pedidoIdParam = request.getParameter("pedidoId");
        if (pedidoIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do pedido é obrigatório\"}");
            return;
        }
        
        try {
            int pedidoId = Integer.parseInt(pedidoIdParam);
            Integer usuarioId = (Integer) session.getAttribute("usuarioId");
            
            Pedido pedido = pedidoDAO.buscarPorId(pedidoId);
            
            if (pedido == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"erro\":\"Pedido não encontrado\"}");
                return;
            }
            
            // Verificar se o pedido pertence ao usuário logado (ou se é admin)
            String tipoUsuario = (String) session.getAttribute("usuarioTipo");
            if (!pedido.getUsuarioId().equals(usuarioId) && !"admin".equals(tipoUsuario)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"erro\":\"Acesso negado\"}");
                return;
            }
            
            List<ItemPedido> itens = pedidoDAO.listarItensDoPedido(pedidoId);
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("pedido", pedido);
            resultado.put("itens", itens);
            
            response.getWriter().write(gson.toJson(resultado));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do pedido inválido\"}");
        }
    }
}