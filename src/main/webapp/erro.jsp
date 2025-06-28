<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Erro - Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6 text-center">
                <h1 class="display-1 text-danger">Ops!</h1>
                <h2>Algo deu errado</h2>
                <p class="text-muted">Desculpe, ocorreu um erro inesperado.</p>
                <a href="index.jsp" class="btn btn-primary">Voltar ao início</a>
                
                <% if (request.getAttribute("javax.servlet.error.message") != null) { %>
                    <div class="mt-4">
                        <details>
                            <summary>Detalhes do erro</summary>
                            <p class="text-danger small"><%= request.getAttribute("javax.servlet.error.message") %></p>
                        </details>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>