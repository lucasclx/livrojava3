package com.livraria.model;

import java.io.Serializable;

import java.sql.Timestamp;

public class ListaDesejos  implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private int usuarioId;
    private int livroId;
    private Timestamp dataAdicao;

    // Getters e Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public int getLivroId() {
        return livroId;
    }

    public void setLivroId(int livroId) {
        this.livroId = livroId;
    }

    public Timestamp getDataAdicao() {
        return dataAdicao;
    }

    public void setDataAdicao(Timestamp dataAdicao) {
        this.dataAdicao = dataAdicao;
    }
}