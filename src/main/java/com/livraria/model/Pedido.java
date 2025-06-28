package com.livraria.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Pedido {

    private int id;
    private Integer usuarioId;
    private BigDecimal total;
    private String status; // 'pendente', 'confirmado', 'enviado', 'entregue', 'cancelado'
    private Timestamp dataPedido;
    private String enderecoEntrega;
    
    public Pedido() {}
    
    public Pedido(int id, Integer usuarioId, BigDecimal total, String status, 
                  Timestamp dataPedido, String enderecoEntrega) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.total = total;
        this.status = status;
        this.dataPedido = dataPedido;
        this.enderecoEntrega = enderecoEntrega;
    }
    
    // Getters e Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public Integer getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Integer usuarioId) { this.usuarioId = usuarioId; }
    
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getDataPedido() { return dataPedido; }
    public void setDataPedido(Timestamp dataPedido) { this.dataPedido = dataPedido; }
    
    public String getEnderecoEntrega() { return enderecoEntrega; }
    public void setEnderecoEntrega(String enderecoEntrega) { this.enderecoEntrega = enderecoEntrega; }
    
    @Override
    public String toString() {
        return "Pedido{" +
                "id=" + id +
                ", usuarioId=" + usuarioId +
                ", total=" + total +
                ", status='" + status + '\'' +
                ", dataPedido=" + dataPedido +
                '}';
    }
}