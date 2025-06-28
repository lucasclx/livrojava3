<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .livro-card {
            transition: transform 0.2s;
            height: 100%;
        }
        .livro-card:hover {
            transform: translateY(-5px);
        }
        .livro-imagem {
            height: 200px;
            object-fit: cover;
        }
        .carrinho-contador {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #dc3545;
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            font-size: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .loading {
            display: none;
            text-align: center;
            padding: 20px;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="#"><i class="fas fa-book"></i> Livraria Online</a>
            
            <div class="navbar-nav ms-auto">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                        Categorias
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="filtrarPorCategoria('Romance')">Romance</a></li>
                        <li><a class="dropdown-item" href="#" onclick="filtrarPorCategoria('Ficção')">Ficção</a></li>
                        <li><a class="dropdown-item" href="#" onclick="filtrarPorCategoria('Técnico')">Técnico</a></li>
                        <li><a class="dropdown-item" href="#" onclick="filtrarPorCategoria('Biografia')">Biografia</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="#" onclick="carregarTodosLivros()">Todos os Livros</a></li>
                    </ul>
                </div>
                
                <button class="btn btn-outline-light position-relative me-2" onclick="abrirCarrinho()">
                    <i class="fas fa-shopping-cart"></i>
                    <span id="carrinho-contador" class="carrinho-contador" style="display: none;">0</span>
                </button>
                
                <button class="btn btn-outline-light" onclick="fazerLogin()">
                    <i class="fas fa-user"></i> Login
                </button>
            </div>
        </div>
    </nav>

    <!-- Header com busca -->
    <div class="bg-light py-4">
        <div class="container">
            <div class="row">
                <div class="col-md-8 mx-auto">
                    <div class="input-group">
                        <input type="text" id="busca-input" class="form-control" placeholder="Buscar livros por título...">
                        <button class="btn btn-primary" onclick="buscarLivros()">
                            <i class="fas fa-search"></i> Buscar
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Conteúdo principal -->
    <div class="container my-4">
        <div id="loading" class="loading">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Carregando...</span>
            </div>
            <p>Carregando livros...</p>
        </div>
        
        <div id="livros-container" class="row">
            <!-- Livros serão carregados aqui via AJAX -->
        </div>
        
        <div id="sem-resultados" style="display: none;" class="text-center py-5">
            <i class="fas fa-book-open fa-3x text-muted"></i>
            <h3 class="text-muted mt-3">Nenhum livro encontrado</h3>
            <p class="text-muted">Tente uma busca diferente ou explore nossas categorias.</p>
        </div>
    </div>

    <!-- Modal do Carrinho -->
    <div class="modal fade" id="carrinhoModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Meu Carrinho</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="carrinho-itens">
                        <!-- Itens do carrinho serão carregados aqui -->
                    </div>
                </div>
                <div class="modal-footer">
                    <div class="me-auto">
                        <strong>Total: R$ <span id="carrinho-total">0,00</span></strong>
                    </div>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Continuar Comprando</button>
                    <button type="button" class="btn btn-primary" onclick="finalizarCompra()">Finalizar Compra</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Detalhes do Livro -->
    <div class="modal fade" id="detalhesModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="detalhes-titulo"></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-4">
                            <img id="detalhes-imagem" class="img-fluid" alt="Capa do livro">
                        </div>
                        <div class="col-md-8">
                            <p><strong>Autor:</strong> <span id="detalhes-autor"></span></p>
                            <p><strong>ISBN:</strong> <span id="detalhes-isbn"></span></p>
                            <p><strong>Categoria:</strong> <span id="detalhes-categoria"></span></p>
                            <p><strong>Preço:</strong> R$ <span id="detalhes-preco"></span></p>
                            <p><strong>Estoque:</strong> <span id="detalhes-estoque"></span> unidades</p>
                            <div>
                                <strong>Descrição:</strong>
                                <p id="detalhes-descricao"></p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Fechar</button>
                    <button type="button" class="btn btn-primary" onclick="adicionarAoCarrinhoModal()">
                        <i class="fas fa-cart-plus"></i> Adicionar ao Carrinho
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="js/livraria.js"></script>
</body>
</html>