package com.livraria.model;


import java.sql.Timestamp;

public class Usuario {

    private int id;
    private String nome;
    private String email;
    private String senha;
    private String tipo; // 'cliente' ou 'admin'
    private boolean ativo;
    private Timestamp dataCadastro;
    
    public Usuario() {}
    
    public Usuario(int id, String nome, String email, String senha, String tipo, boolean ativo, Timestamp dataCadastro) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.senha = senha;
        this.tipo = tipo;
        this.ativo = ativo;
        this.dataCadastro = dataCadastro;
    }
    
    // Getters e Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }
    
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
    
    public Timestamp getDataCadastro() { return dataCadastro; }
    public void setDataCadastro(Timestamp dataCadastro) { this.dataCadastro = dataCadastro; }
    
    @Override
    public String toString() {
        return "Usuario{" +
                "id=" + id +
                ", nome='" + nome + '\'' +
                ", email='" + email + '\'' +
                ", tipo='" + tipo + '\'' +
                ", ativo=" + ativo +
                '}';
    }
}