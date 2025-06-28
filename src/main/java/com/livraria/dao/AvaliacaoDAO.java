package com.livraria.dao;

import com.livraria.database.DatabaseConnection;
import com.livraria.model.Avaliacao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class AvaliacaoDAO {

    public boolean criar(Avaliacao avaliacao) throws SQLException {
        String sql = "INSERT INTO avaliacoes (livro_id, usuario_id, nota, comentario) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, avaliacao.getLivroId());
            stmt.setInt(2, avaliacao.getUsuarioId());
            stmt.setInt(3, avaliacao.getNota());
            stmt.setString(4, avaliacao.getComentario());
            return stmt.executeUpdate() > 0;
        }
    }

    public List<Avaliacao> listarPorLivro(int livroId) throws SQLException {
        List<Avaliacao> avaliacoes = new ArrayList<>();
        String sql = "SELECT * FROM avaliacoes WHERE livro_id = ? ORDER BY data_avaliacao DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, livroId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    avaliacoes.add(criarAvaliacaoDoResultSet(rs));
                }
            }
        }
        return avaliacoes;
    }

    public Map<String, Object> obterEstatisticas(int livroId) throws SQLException {
        String sql = "SELECT * FROM vw_avaliacoes_livros WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, livroId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Map.of(
                        "total_avaliacoes", rs.getInt("total_avaliacoes"),
                        "media_nota", rs.getDouble("media_nota"),
                        "cinco_estrelas", rs.getInt("cinco_estrelas"),
                        "quatro_estrelas", rs.getInt("quatro_estrelas"),
                        "tres_estrelas", rs.getInt("tres_estrelas"),
                        "duas_estrelas", rs.getInt("duas_estrelas"),
                        "uma_estrela", rs.getInt("uma_estrela")
                    );
                }
            }
        }
        return null;
    }

    private Avaliacao criarAvaliacaoDoResultSet(ResultSet rs) throws SQLException {
        Avaliacao avaliacao = new Avaliacao();
        avaliacao.setId(rs.getInt("id"));
        avaliacao.setLivroId(rs.getInt("livro_id"));
        avaliacao.setUsuarioId(rs.getInt("usuario_id"));
        avaliacao.setNota(rs.getInt("nota"));
        avaliacao.setComentario(rs.getString("comentario"));
        avaliacao.setDataAvaliacao(rs.getTimestamp("data_avaliacao"));
        avaliacao.setUtil(rs.getInt("util"));
        return avaliacao;
    }
}