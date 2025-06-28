package com.livraria.dao;

import com.livraria.database.DatabaseConnection;
import com.livraria.model.Pedido;
import com.livraria.model.ItemPedido;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PedidoDAO {
    
    public boolean salvarPedidoCompleto(Pedido pedido, List<ItemPedido> itens) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Iniciar transação
            
            // Inserir pedido
            String sqlPedido = "INSERT INTO pedidos (usuario_id, total, status, endereco_entrega) VALUES (?, ?, ?, ?)";
            PreparedStatement stmtPedido = conn.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS);
            
            stmtPedido.setInt(1, pedido.getUsuarioId());
            stmtPedido.setBigDecimal(2, pedido.getTotal());
            stmtPedido.setString(3, pedido.getStatus());
            stmtPedido.setString(4, pedido.getEnderecoEntrega());
            
            int rowsAffected = stmtPedido.executeUpdate();
            if (rowsAffected == 0) {
                conn.rollback();
                return false;
            }
            
            // Obter ID do pedido criado
            ResultSet generatedKeys = stmtPedido.getGeneratedKeys();
            if (generatedKeys.next()) {
                pedido.setId(generatedKeys.getInt(1));
            } else {
                conn.rollback();
                return false;
            }
            
            // Inserir itens do pedido
            String sqlItem = "INSERT INTO itens_pedido (pedido_id, livro_id, quantidade, preco_unitario) VALUES (?, ?, ?, ?)";
            PreparedStatement stmtItem = conn.prepareStatement(sqlItem);
            
            for (ItemPedido item : itens) {
                item.setPedidoId(pedido.getId());
                
                stmtItem.setInt(1, item.getPedidoId());
                stmtItem.setInt(2, item.getLivroId());
                stmtItem.setInt(3, item.getQuantidade());
                stmtItem.setBigDecimal(4, item.getPrecoUnitario());
                
                stmtItem.addBatch();
            }
            
            int[] batchResults = stmtItem.executeBatch();
            
            // Verificar se todos os itens foram inseridos
            for (int result : batchResults) {
                if (result == Statement.EXECUTE_FAILED) {
                    conn.rollback();
                    return false;
                }
            }
            
            conn.commit(); // Confirmar transação
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
    
    public Pedido buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM pedidos WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return criarPedidoDoResultSet(rs);
                }
            }
        }
        
        return null;
    }
    
    public List<Pedido> listarTodos() throws SQLException {
        List<Pedido> pedidos = new ArrayList<>();
        String sql = "SELECT * FROM pedidos ORDER BY data_pedido DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                pedidos.add(criarPedidoDoResultSet(rs));
            }
        }
        
        return pedidos;
    }
    
    public List<Pedido> listarPorUsuario(int usuarioId) throws SQLException {
        List<Pedido> pedidos = new ArrayList<>();
        String sql = "SELECT * FROM pedidos WHERE usuario_id = ? ORDER BY data_pedido DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuarioId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    pedidos.add(criarPedidoDoResultSet(rs));
                }
            }
        }
        
        return pedidos;
    }
    
    public List<Pedido> listarPorStatus(String status) throws SQLException {
        List<Pedido> pedidos = new ArrayList<>();
        String sql = "SELECT * FROM pedidos WHERE status = ? ORDER BY data_pedido DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    pedidos.add(criarPedidoDoResultSet(rs));
                }
            }
        }
        
        return pedidos;
    }
    
    public List<ItemPedido> listarItensDoPedido(int pedidoId) throws SQLException {
        List<ItemPedido> itens = new ArrayList<>();
        String sql = """
            SELECT ip.*, l.titulo, l.autor 
            FROM itens_pedido ip 
            JOIN livros l ON ip.livro_id = l.id 
            WHERE ip.pedido_id = ?
            """;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, pedidoId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ItemPedido item = new ItemPedido();
                    item.setId(rs.getInt("id"));
                    item.setPedidoId(rs.getInt("pedido_id"));
                    item.setLivroId(rs.getInt("livro_id"));
                    item.setQuantidade(rs.getInt("quantidade"));
                    item.setPrecoUnitario(rs.getBigDecimal("preco_unitario"));
                    item.setTituloLivro(rs.getString("titulo"));
                    item.setAutorLivro(rs.getString("autor"));
                    
                    itens.add(item);
                }
            }
        }
        
        return itens;
    }
    
    public boolean atualizarStatus(int pedidoId, String novoStatus) throws SQLException {
        String sql = "UPDATE pedidos SET status = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, novoStatus);
            stmt.setInt(2, pedidoId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean deletar(int id) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Deletar itens do pedido primeiro (por causa da foreign key)
            String sqlItens = "DELETE FROM itens_pedido WHERE pedido_id = ?";
            PreparedStatement stmtItens = conn.prepareStatement(sqlItens);
            stmtItens.setInt(1, id);
            stmtItens.executeUpdate();
            
            // Deletar pedido
            String sqlPedido = "DELETE FROM pedidos WHERE id = ?";
            PreparedStatement stmtPedido = conn.prepareStatement(sqlPedido);
            stmtPedido.setInt(1, id);
            
            boolean sucesso = stmtPedido.executeUpdate() > 0;
            
            if (sucesso) {
                conn.commit();
            } else {
                conn.rollback();
            }
            
            return sucesso;
            
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
    
    private Pedido criarPedidoDoResultSet(ResultSet rs) throws SQLException {
        Pedido pedido = new Pedido();
        pedido.setId(rs.getInt("id"));
        pedido.setUsuarioId(rs.getInt("usuario_id"));
        pedido.setTotal(rs.getBigDecimal("total"));
        pedido.setStatus(rs.getString("status"));
        pedido.setDataPedido(rs.getTimestamp("data_pedido"));
        pedido.setEnderecoEntrega(rs.getString("endereco_entrega"));
        return pedido;
    }
}