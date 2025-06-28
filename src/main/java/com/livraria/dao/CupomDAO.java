package com.livraria.dao;

import com.livraria.database.DatabaseConnection;
import com.livraria.model.Cupom;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.math.BigDecimal;

public class CupomDAO {

    public Cupom validarCupom(String codigo) throws SQLException {
        String sql = """
            SELECT * FROM cupons 
            WHERE codigo = ? 
            AND valido_ate >= CURDATE() 
            AND (uso_maximo IS NULL OR uso_atual < uso_maximo)
            AND ativo = true
        """;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, codigo.toUpperCase());
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return criarCupomDoResultSet(rs);
                }
            }
        }
        
        return null;
    }
    
    public boolean aplicarCupom(int cupomId) throws SQLException {
        String sql = "UPDATE cupons SET uso_atual = uso_atual + 1 WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, cupomId);
            return stmt.executeUpdate() > 0;
        }
    }

    private Cupom criarCupomDoResultSet(ResultSet rs) throws SQLException {
        Cupom cupom = new Cupom();
        cupom.setId(rs.getInt("id"));
        cupom.setCodigo(rs.getString("codigo"));
        cupom.setTipo(rs.getString("tipo"));
        cupom.setValor(rs.getBigDecimal("valor"));
        cupom.setValidoAte(rs.getDate("valido_ate"));
        cupom.setUsoMaximo(rs.getObject("uso_maximo", Integer.class)); // Pode ser NULL
        cupom.setUsoAtual(rs.getInt("uso_atual"));
        cupom.setAtivo(rs.getBoolean("ativo"));
        return cupom;
    }
}