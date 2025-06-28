package com.livraria.dao;

import com.livraria.database.DatabaseConnection;
import com.livraria.model.Livro;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class LivroDAO {
    
    public List<Livro> listarTodos() throws SQLException {
        List<Livro> livros = new ArrayList<>();
        String sql = "SELECT * FROM livros ORDER BY titulo";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                livros.add(criarLivroDoResultSet(rs));
            }
        }
        
        return livros;
    }
    
    public List<Livro> buscarPorTitulo(String titulo) throws SQLException {
        List<Livro> livros = new ArrayList<>();
        String sql = "SELECT * FROM livros WHERE titulo LIKE ? ORDER BY titulo";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, "%" + titulo + "%");
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    livros.add(criarLivroDoResultSet(rs));
                }
            }
        }
        
        return livros;
    }
    
    public List<Livro> buscarPorCategoria(String categoria) throws SQLException {
        List<Livro> livros = new ArrayList<>();
        String sql = "SELECT * FROM livros WHERE categoria = ? ORDER BY titulo";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, categoria);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    livros.add(criarLivroDoResultSet(rs));
                }
            }
        }
        
        return livros;
    }
    
    public Livro buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM livros WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return criarLivroDoResultSet(rs);
                }
            }
        }
        
        return null;
    }
    
    public boolean salvar(Livro livro) throws SQLException {
        String sql = "INSERT INTO livros (titulo, autor, isbn, preco, estoque, categoria, descricao, imagem) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, livro.getTitulo());
            stmt.setString(2, livro.getAutor());
            stmt.setString(3, livro.getIsbn());
            stmt.setBigDecimal(4, livro.getPreco());
            stmt.setInt(5, livro.getEstoque());
            stmt.setString(6, livro.getCategoria());
            stmt.setString(7, livro.getDescricao());
            stmt.setString(8, livro.getImagem());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean atualizar(Livro livro) throws SQLException {
        String sql = "UPDATE livros SET titulo = ?, autor = ?, isbn = ?, preco = ?, estoque = ?, categoria = ?, descricao = ?, imagem = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, livro.getTitulo());
            stmt.setString(2, livro.getAutor());
            stmt.setString(3, livro.getIsbn());
            stmt.setBigDecimal(4, livro.getPreco());
            stmt.setInt(5, livro.getEstoque());
            stmt.setString(6, livro.getCategoria());
            stmt.setString(7, livro.getDescricao());
            stmt.setString(8, livro.getImagem());
            stmt.setInt(9, livro.getId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean deletar(int id) throws SQLException {
        String sql = "DELETE FROM livros WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean atualizarEstoque(int id, int novoEstoque) throws SQLException {
        String sql = "UPDATE livros SET estoque = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, novoEstoque);
            stmt.setInt(2, id);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    private Livro criarLivroDoResultSet(ResultSet rs) throws SQLException {
        Livro livro = new Livro();
        livro.setId(rs.getInt("id"));
        livro.setTitulo(rs.getString("titulo"));
        livro.setAutor(rs.getString("autor"));
        livro.setIsbn(rs.getString("isbn"));
        livro.setPreco(rs.getBigDecimal("preco"));
        livro.setEstoque(rs.getInt("estoque"));
        livro.setCategoria(rs.getString("categoria"));
        livro.setDescricao(rs.getString("descricao"));
        livro.setImagem(rs.getString("imagem"));
        return livro;
    }
}