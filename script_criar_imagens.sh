#!/bin/bash

# Script para corrigir problemas de serialização nos modelos

echo "=== Corrigindo Problemas de Serialização ==="
echo

# Diretório dos modelos
MODEL_DIR="src/main/java/com/livraria/model"

echo "1. Adicionando Serializable aos modelos principais..."

# Lista de arquivos para corrigir
files=(
    "Livro.java"
    "Pedido.java" 
    "ItemPedido.java"
    "Avaliacao.java"
    "Cupom.java"
    "ListaDesejos.java"
)

for file in "${files[@]}"; do
    filepath="$MODEL_DIR/$file"
    if [ -f "$filepath" ]; then
        echo "   ✓ Processando $file..."
        
        # Backup do arquivo original
        cp "$filepath" "$filepath.bak"
        
        # Adicionar import e implementação
        sed -i '1i\import java.io.Serializable;' "$filepath"
        sed -i 's/public class \([^{]*\){/public class \1 implements Serializable {/' "$filepath"
        sed -i '/public class.*implements Serializable {/a\    private static final long serialVersionUID = 1L;' "$filepath"
        
        echo "   ✓ $file atualizado"
    else
        echo "   ⚠️  $file não encontrado em $filepath"
    fi
done

echo
echo "2. Criando versão corrigida do LoginServlet..."

cat > "${MODEL_DIR}/../servlet/LoginServletFixed.java" << 'EOF'
package com.livraria.servlet;

import com.livraria.dao.UsuarioDAO;
import com.livraria.model.Usuario;
import com.google.gson.Gson;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.MultipartConfig;

@MultipartConfig
public class LoginServletFixed extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UsuarioDAO usuarioDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        usuarioDAO = new UsuarioDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        try {
            switch (action != null ? action : "") {
                case "login":
                    fazerLogin(request, response);
                    break;
                case "logout":
                    fazerLogout(request, response);
                    break;
                case "registrar":
                    registrarUsuario(request, response);
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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("status".equals(action)) {
            verificarStatusLogin(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Ação não reconhecida\"}");
        }
    }
    
    private void fazerLogin(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        
        System.out.println("Tentativa de login para o email: " + email);

        if (email == null || email.trim().isEmpty() || senha == null || senha.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Email e senha são obrigatórios\"}");
            return;
        }
        
        Usuario usuario = usuarioDAO.autenticar(email.trim(), senha);
        
        System.out.println("Usuário encontrado: " + (usuario != null ? usuario.getEmail() : "null"));

        Map<String, Object> resultado = new HashMap<>();
        
        if (usuario != null) {
            HttpSession session = request.getSession();
            
            // CORREÇÃO: Armazenar apenas dados essenciais, não o objeto completo
            session.setAttribute("usuarioId", usuario.getId());
            session.setAttribute("usuarioNome", usuario.getNome());
            session.setAttribute("usuarioEmail", usuario.getEmail());
            session.setAttribute("usuarioTipo", usuario.getTipo());
            
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Login realizado com sucesso");
            resultado.put("usuario", Map.of(
                "id", usuario.getId(),
                "nome", usuario.getNome(),
                "email", usuario.getEmail(),
                "tipo", usuario.getTipo()
            ));
            resultado.put("redirecionamento", "admin".equals(usuario.getTipo()) ? "admin/admin.jsp" : "index.jsp");
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resultado.put("erro", "Email ou senha inválidos");
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void fazerLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("sucesso", true);
        resultado.put("mensagem", "Logout realizado com sucesso");
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void registrarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        
        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        String confirmarSenha = request.getParameter("confirmarSenha");
        
        // Validações
        if (nome == null || nome.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Nome é obrigatório\"}");
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Email é obrigatório\"}");
            return;
        }
        
        if (senha == null || senha.length() < 6) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Senha deve ter pelo menos 6 caracteres\"}");
            return;
        }
        
        if (!senha.equals(confirmarSenha)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"erro\":\"Senhas não conferem\"}");
            return;
        }
        
        // Verificar se email já existe
        if (usuarioDAO.buscarPorEmail(email.trim()) != null) {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            response.getWriter().write("{\"erro\":\"Email já cadastrado\"}");
            return;
        }
        
        Usuario usuario = new Usuario();
        usuario.setNome(nome.trim());
        usuario.setEmail(email.trim().toLowerCase());
        usuario.setSenha(senha); // Em produção, fazer hash da senha
        usuario.setTipo("cliente");
        usuario.setAtivo(true);
        
        boolean sucesso = usuarioDAO.salvar(usuario);
        
        Map<String, Object> resultado = new HashMap<>();
        if (sucesso) {
            resultado.put("sucesso", true);
            resultado.put("mensagem", "Usuário cadastrado com sucesso! Faça login para continuar.");
        } else {
            resultado.put("erro", "Falha ao cadastrar usuário");
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
    
    private void verificarStatusLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        Map<String, Object> resultado = new HashMap<>();
        
        if (session != null && session.getAttribute("usuarioId") != null) {
            resultado.put("logado", true);
            resultado.put("usuario", Map.of(
                "id", session.getAttribute("usuarioId"),
                "nome", session.getAttribute("usuarioNome"),
                "email", session.getAttribute("usuarioEmail"),
                "tipo", session.getAttribute("usuarioTipo")
            ));
        } else {
            resultado.put("logado", false);
        }
        
        response.getWriter().write(gson.toJson(resultado));
    }
}
EOF

echo "   ✓ LoginServletFixed.java criado"

echo
echo "3. Adicionando dependências Maven (se usando Maven)..."

cat > "pom-dependencies.xml" << 'EOF'
<!-- Adicionar ao pom.xml dentro da tag <dependencies> -->

<!-- MySQL Connector -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>

<!-- Gson para JSON -->
<dependency>
    <groupId>com.google.code.gson</groupId>
    <artifactId>gson</artifactId>
    <version>2.10.1</version>
</dependency>

<!-- Servlet API -->
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>4.0.1</version>
    <scope>provided</scope>
</dependency>

<!-- JSP API -->
<dependency>
    <groupId>javax.servlet.jsp</groupId>
    <artifactId>javax.servlet.jsp-api</artifactId>
    <version>2.3.3</version>
    <scope>provided</scope>
</dependency>

<!-- JSTL -->
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>jstl</artifactId>
    <version>1.2</version>
</dependency>
EOF

echo "   ✓ pom-dependencies.xml criado"

echo
echo "4. Criando script de configuração do banco..."

cat > "setup-database.sql" << 'EOF'
-- Script para configurar o banco de dados
-- Execute este script no MySQL

-- Criar banco se não existir
CREATE DATABASE IF NOT EXISTS livraria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE livraria;

-- Verificar se as tabelas já existem
SELECT 'Verificando estrutura do banco...' as status;

-- Verificar tabela usuarios
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabela usuarios existe'
        ELSE 'Tabela usuarios não encontrada'
    END as resultado
FROM information_schema.tables 
WHERE table_schema = 'livraria' 
AND table_name = 'usuarios';

-- Verificar tabela livros
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabela livros existe'
        ELSE 'Tabela livros não encontrada'
    END as resultado
FROM information_schema.tables 
WHERE table_schema = 'livraria' 
AND table_name = 'livros';

-- Se as tabelas não existirem, execute o schema.sql completo
EOF

echo "   ✓ setup-database.sql criado"

echo
echo "=== INSTRUÇÕES PARA CORRIGIR O ERRO ==="
echo
echo "1. IMEDIATO - Substitua o LoginServlet atual:"
echo "   cp src/main/java/com/livraria/servlet/LoginServletFixed.java src/main/java/com/livraria/servlet/LoginServlet.java"
echo
echo "2. Adicione Serializable ao Usuario.java:"
echo "   - Implemente 'implements Serializable'"
echo "   - Adicione 'private static final long serialVersionUID = 1L;'"
echo
echo "3. Recompile e redeploy:"
echo "   mvn clean compile war:war"
echo "   cp target/*.war \$TOMCAT_HOME/webapps/"
echo
echo "4. Reinicie o Tomcat:"
echo "   sudo service tomcat9 restart"
echo
echo "5. Teste o login:"
echo "   - Acesse http://localhost:8080/livrojava2.0/login.jsp"
echo "   - Use: admin@livraria.com / admin123"
echo
echo "=== VERIFICAÇÕES ADICIONAIS ==="
echo
echo "✅ Verifique se MySQL está rodando:"
echo "   sudo service mysql status"
echo
echo "✅ Verifique se o banco existe:"
echo "   mysql -u root -p -e 'SHOW DATABASES;'"
echo
echo "✅ Teste conexão com banco:"
echo "   mysql -u root -p livraria -e 'SELECT COUNT(*) FROM usuarios;'"
echo
echo "Correções aplicadas com sucesso!"