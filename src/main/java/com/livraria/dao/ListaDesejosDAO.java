package com.livraria.dao;

import com.livraria.database.DatabaseConnection;
import com.livraria.model.ListaDesejos;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ListaDesejosDAO {

    public boolean adicionar(int usuarioId, int livroId) throws SQLException {
        String sql = "INSERT INTO lista_desejos (usuario_id, livro_id) VALUES (?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, usuarioId);
            stmt.setInt(2, livroId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean remover(int usuarioId, int livroId) throws SQLException {
        String sql = "DELETE FROM lista_desejos WHERE usuario_id = ? AND livro_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, usuarioId);
            stmt.setInt(2, livroId);
            return stmt.executeUpdate() > 0;
        }
    }

    public List<ListaDesejos> listarPorUsuario(int usuarioId) throws SQLException {
        List<ListaDesejos> listaDesejos = new ArrayList<>();
        String sql = "SELECT * FROM lista_desejos WHERE usuario_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, usuarioId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    listaDesejos.add(criarListaDesejosDoResultSet(rs));
                }
            }
        }
        return listaDesejos;
    }

    private ListaDesejos criarListaDesejosDoResultSet(ResultSet rs) throws SQLException {
        ListaDesejos item = new ListaDesejos();
        item.setId(rs.getInt("id"));
        item.setUsuarioId(rs.getInt("usuario_id"));
        item.setLivroId(rs.getInt("livro_id"));
        item.setDataAdicao(rs.getTimestamp("data_adicao"));
        return item;
    }
}