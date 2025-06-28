<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teste Simples - Livraria Online</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        .success {
            color: #4CAF50;
            font-size: 2em;
        }
        .info {
            background: rgba(255,255,255,0.2);
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
        }
        .btn {
            background: #4CAF50;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            display: inline-block;
            margin: 10px 5px;
        }
        .btn:hover {
            background: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="success">✅ Servidor Funcionando!</h1>
        
        <div class="info">
            <h3>📋 Informações do Sistema:</h3>
            <p><strong>Data/Hora:</strong> <%= new java.util.Date() %></p>
            <p><strong>Context Path:</strong> <%= request.getContextPath() %></p>
            <p><strong>Server Info:</strong> <%= application.getServerInfo() %></p>
            <p><strong>Session ID:</strong> <%= session.getId() %></p>
        </div>
        
        <div class="info">
            <h3>🔗 Links para Testar:</h3>
            <a href="<%= request.getContextPath() %>/" class="btn">Página Principal</a>
            <a href="<%= request.getContextPath() %>/teste" class="btn">Servlet Teste</a>
            <a href="<%= request.getContextPath() %>/livros?action=listar" class="btn">API Livros</a>
        </div>
        
        <div class="info">
            <h3>⚙️ Próximos Passos:</h3>
            <ol style="text-align: left;">
                <li>Se esta página apareceu, o JSP está funcionando ✅</li>
                <li>Teste os links acima para verificar os servlets</li>
                <li>Se der erro 404 nos servlets, verifique a compilação</li>
                <li>Verifique se as dependências (MySQL, Gson) estão na pasta WEB-INF/lib</li>
            </ol>
        </div>
    </div>
</body>
</html>