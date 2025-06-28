<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.livraria.dao.LivroDAO" %>
<%@ page import="com.livraria.model.Livro" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Painel Administrativo - Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar Admin -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-cogs"></i> Painel Administrativo
            </a>
            
            <div class="navbar-nav ms-auto">
                <a class="nav-link" href="../index.jsp">
                    <i class="fas fa-store"></i> Ver Loja
                </a>
                <a class="nav-link" href="#" onclick="logout()">
                    <i class="fas fa-sign-out-alt"></i> Sair
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 bg-light min-vh-100 p-3">
                <ul class="nav nav-pills flex-column">
                    <li class="nav-item">
                        <a class="nav-link active" data-bs-toggle="pill" href="#livros">
                            <i class="fas fa-book"></i> Gerenciar Livros
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="pill" href="#pedidos">
                            <i class="fas fa-shopping-bag"></i> Pedidos
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="pill" href="#usuarios">
                            <i class="fas fa-users"></i> Usuários
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="pill" href="#relatorios">
                            <i class="fas fa-chart-bar"></i> Relatórios
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Conteúdo Principal -->
            <div class="col-md-10 p-4">
                <div class="tab-content">
                    <!-- Tab Livros -->
                    <div class="tab-pane fade show active" id="livros">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2><i class="fas fa-book"></i> Gerenciar Livros</h2>
                            <button class="btn btn-primary" onclick="abrirModalLivro()">
                                <i class="fas fa-plus"></i> Novo Livro
                            </button>
                        </div>

                        <div class="card">
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped" id="tabelaLivros">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Título</th>
                                                <th>Autor</th>
                                                <th>Categoria</th>
                                                <th>Preço</th>
                                                <th>Estoque</th>
                                                <th>Ações</th>
                                            </tr>
                                        </thead>
                                        <tbody id="livrosTableBody">
                                            <!-- Livros serão carregados via AJAX -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Pedidos -->
                    <div class="tab-pane fade" id="pedidos">
                        <h2><i class="fas fa-shopping-bag"></i> Pedidos</h2>
                        <div class="card">
                            <div class="card-body">
                                <p class="text-muted">Funcionalidade de gerenciamento de pedidos em desenvolvimento...</p>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Usuários -->
                    <div class="tab-pane fade" id="usuarios">
                        <h2><i class="fas fa-users"></i> Usuários</h2>
                        <div class="card">
                            <div class="card-body">
                                <p class="text-muted">Funcionalidade de gerenciamento de usuários em desenvolvimento...</p>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Relatórios -->
                    <div class="tab-pane fade" id="relatorios">
                        <h2><i class="fas fa-chart-bar"></i> Relatórios</h2>
                        <div class="card">
                            <div class="card-body">
                                <p class="text-muted">Funcionalidade de relatórios em desenvolvimento...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal para Cadastro/Edição de Livro -->
    <div class="modal fade" id="livroModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="livroModalTitle">Novo Livro</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="formLivro">
                    <div class="modal-body">
                        <input type="hidden" id="livroId" name="id">
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="titulo" class="form-label">Título *</label>
                                    <input type="text" class="form-control" id="titulo" name="titulo" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="autor" class="form-label">Autor *</label>
                                    <input type="text" class="form-control" id="autor" name="autor" required>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label for="isbn" class="form-label">ISBN</label>
                                    <input type="text" class="form-control" id="isbn" name="isbn">
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label for="preco" class="form-label">Preço *</label>
                                    <input type="number" class="form-control" id="preco" name="preco" step="0.01" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label for="estoque" class="form-label">Estoque *</label>
                                    <input type="number" class="form-control" id="estoque" name="estoque" required>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="categoria" class="form-label">Categoria *</label>
                                    <select class="form-control" id="categoria" name="categoria" required>
                                        <option value="">Selecione...</option>
                                        <option value="Romance">Romance</option>
                                        <option value="Ficção">Ficção</option>
                                        <option value="Técnico">Técnico</option>
                                        <option value="Biografia">Biografia</option>
                                        <option value="História">História</option>
                                        <option value="Infantil">Infantil</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="imagem" class="form-label">URL da Imagem</label>
                                    <input type="url" class="form-control" id="imagem" name="imagem">
                                </div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="descricao" class="form-label">Descrição</label>
                            <textarea class="form-control" id="descricao" name="descricao" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary">Salvar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="../js/admin.js"></script>
</body>
</html>