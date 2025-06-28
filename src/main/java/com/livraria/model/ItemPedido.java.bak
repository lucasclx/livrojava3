package com.livraria.model;

import java.math.BigDecimal;

public class ItemPedido {
    private int id;
    private int pedidoId;
    private int livroId;
    private int quantidade;
    private BigDecimal precoUnitario;
    
    // Campos auxiliares para exibição (não mapeados no banco)
    private String tituloLivro;
    private String autorLivro;
    
    public ItemPedido() {}
    
    public ItemPedido(int id, int pedidoId, int livroId, int quantidade, BigDecimal precoUnitario) {
        this.id = id;
        this.pedidoId = pedidoId;
        this.livroId = livroId;
        this.quantidade = quantidade;
        this.precoUnitario = precoUnitario;
    }
    
    // Getters e Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getPedidoId() { return pedidoId; }
    public void setPedidoId(int pedidoId) { this.pedidoId = pedidoId; }
    
    public int getLivroId() { return livroId; }
    public void setLivroId(int livroId) { this.livroId = livroId; }
    
    public int getQuantidade() { return quantidade; }
    public void setQuantidade(int quantidade) { this.quantidade = quantidade; }
    
    public BigDecimal getPrecoUnitario() { return precoUnitario; }
    public void setPrecoUnitario(BigDecimal precoUnitario) { this.precoUnitario = precoUnitario; }
    
    public String getTituloLivro() { return tituloLivro; }
    public void setTituloLivro(String tituloLivro) { this.tituloLivro = tituloLivro; }
    
    public String getAutorLivro() { return autorLivro; }
    public void setAutorLivro(String autorLivro) { this.autorLivro = autorLivro; }
    
    // Método de conveniência para calcular subtotal
    public BigDecimal getSubtotal() {
        return precoUnitario.multiply(new BigDecimal(quantidade));
    }
    
    @Override
    public String toString() {
        return "ItemPedido{" +
                "id=" + id +
                ", pedidoId=" + pedidoId +
                ", livroId=" + livroId +
                ", quantidade=" + quantidade +
                ", precoUnitario=" + precoUnitario +
                '}';
    }
}