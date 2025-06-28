package com.livraria.servlet.admin;

import com.livraria.dao.LivroDAO;
import com.livraria.model.Livro;
import com.google.gson.Gson;
import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

 @WebServlet("/admin/livros")
public class AdminLivroServlet extends HttpServlet {
    private LivroDAO livroDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        livroDAO = new LivroDAO();
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
                case "criar":
                    criarLivro(request, response);
                    break;
                case "atualizar":
                    atualizarLivro(request, response);
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
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if ("excluir".equals(action)) {
            try {
                excluirLivro(request, response);
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"erro\":\"Erro no banco de dados: " + e.getMessage() + "\"}");
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID inválido\"}");
        }
    }
    
    private Livro obterLivroDoRequest(HttpServletRequest request) throws IOException {
        StringBuilder buffer = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
        }

        try {
            Map<String, Object> dados = gson.fromJson(buffer.toString(), Map.class);
            Livro livro = new Livro();

            // ID (para atualização)
            if (dados.get("id") != null) {
                String idStr = dados.get("id").toString();
                if (!idStr.isEmpty()) {
                    livro.setId((int) Double.parseDouble(idStr));
                }
            }

            // Campos obrigatórios
            String titulo = (String) dados.get("titulo");
            if (titulo == null || titulo.trim().isEmpty()) return null;
            livro.setTitulo(titulo.trim());

            String autor = (String) dados.get("autor");
            if (autor == null || autor.trim().isEmpty()) return null;
            livro.setAutor(autor.trim());

            Object precoObj = dados.get("preco");
            if (precoObj == null) return null;
            livro.setPreco(new BigDecimal(precoObj.toString()));

            Object estoqueObj = dados.get("estoque");
            if (estoqueObj == null) return null;
            livro.setEstoque((int) Double.parseDouble(estoqueObj.toString()));

            String categoria = (String) dados.get("categoria");
            if (categoria == null || categoria.trim().isEmpty()) return null;
            livro.setCategoria(categoria.trim());

            // Campos opcionais
            livro.setIsbn(dados.get("isbn") != null ? dados.get("isbn").toString().trim() : null);
            livro.setDescricao(dados.get("descricao") != null ? dados.get("descricao").toString().trim() : null);
            livro.setImagem(dados.get("imagem") != null ? dados.get("imagem").toString().trim() : null);

            return livro;

        } catch (Exception e) {
            System.err.println("Erro ao processar dados do livro: " + e.getClass().getName() + " - " + e.getMessage());
            // Imprimir o stack trace para depuração detalhada
            e.printStackTrace();
            return null;
        }
    }

    private void criarLivro(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        Livro livro = obterLivroDoRequest(request);
        if (livro == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Dados inválidos\"}");
            return;
        }
        
        boolean sucesso = livroDAO.salvar(livro);
        
        Map<String, Object> resultado = new HashMap<>();
        if (sucesso) {
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Livro cadastrado com sucesso");
        } else {
            resultado.put("erro", "Falha ao cadastrar livro");
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void atualizarLivro(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        Livro livro = obterLivroDoRequest(request);
        if (livro == null || livro.getId() <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Dados inválidos\"}");
            return;
        }
        
        boolean sucesso = livroDAO.atualizar(livro);
        
        Map<String, Object> resultado = new HashMap<>();
        if (sucesso) {
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Livro atualizado com sucesso");
        } else {
            resultado.put("erro", "Falha ao atualizar livro");
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void excluirLivro(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID do livro é obrigatório\"}");
            return;
        }
        
        try {
            int id = Integer.parseInt(idParam);
            boolean sucesso = livroDAO.deletar(id);
            
            Map<String, Object> resultado = new HashMap<>();
            if (sucesso) {
                resultado.put("sucesso", true);
                resultado.put("mensagem", "Livro excluído com sucesso");
            } else {
                resultado.put("erro", "Falha ao excluir livro");
            }
            
            response.getWriter().write(gson.toJson(resultado));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"ID inválido\"}");
        }
    }
}