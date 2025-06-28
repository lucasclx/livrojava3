<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Minha Conta - Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="css/livraria-enhanced.css" rel="stylesheet">
    <style>
        .menu-lateral {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
        }
        .menu-lateral .menu-item {
            display: block;
            padding: 10px 15px;
            margin-bottom: 5px;
            border-radius: 5px;
            color: #333;
            text-decoration: none;
        }
        .menu-lateral .menu-item:hover,
        .menu-lateral .menu-item.active {
            background-color: #007bff;
            color: white;
        }
        #conteudo-dashboard {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div id="toast-container"></div>

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-book"></i> Livraria Online
            </a>
            <div class="navbar-nav ms-auto">
                <a class="nav-link" href="index.jsp">
                    <i class="fas fa-arrow-left"></i> Voltar à Loja
                </a>
            </div>
        </div>
    </nav>

    <div class="container my-4">
        <h2><i class="fas fa-user-circle"></i> Minha Conta</h2>
        <hr>

        <div class="row">
            <div class="col-md-3">
                <div class="menu-lateral">
                    <a href="#dados" class="menu-item active" onclick="carregarConteudo('dados')">
                        <i class="fas fa-user"></i> Meus Dados
                    </a>
                    <a href="#pedidos" class="menu-item" onclick="carregarConteudo('pedidos')">
                        <i class="fas fa-shopping-bag"></i> Meus Pedidos
                    </a>
                    <a href="#favoritos" class="menu-item" onclick="carregarConteudo('favoritos')">
                        <i class="fas fa-heart"></i> Lista de Desejos
                    </a>
                    <a href="#avaliacoes" class="menu-item" onclick="carregarConteudo('avaliacoes')">
                        <i class="fas fa-star"></i> Minhas Avaliações
                    </a>
                    <a href="#enderecos" class="menu-item" onclick="carregarConteudo('enderecos')">
                        <i class="fas fa-map-marker"></i> Endereços
                    </a>
                </div>
            </div>
            <div class="col-md-9">
                <div id="conteudo-dashboard">
                    <!-- Conteúdo dinâmico será carregado aqui -->
                    <h4>Meus Dados</h4>
                    <p>Informações do usuário serão exibidas aqui.</p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="js/livraria.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Lógica para carregar o conteúdo inicial ou de acordo com a URL
            const hash = window.location.hash.substring(1);
            if (hash) {
                carregarConteudo(hash);
            } else {
                carregarConteudo('dados'); // Conteúdo padrão
            }

            // Adicionar event listeners para os itens do menu lateral
            document.querySelectorAll('.menu-item').forEach(item => {
                item.addEventListener('click', function(e) {
                    e.preventDefault();
                    document.querySelectorAll('.menu-item').forEach(el => el.classList.remove('active'));
                    this.classList.add('active');
                    const target = this.getAttribute('href').substring(1);
                    carregarConteudo(target);
                });
            });
        });

        function carregarConteudo(secao) {
            const conteudoDashboard = document.getElementById('conteudo-dashboard');
            conteudoDashboard.innerHTML = `<h4>Carregando ${secao}...</h4>`;

            // Simulação de carregamento de conteúdo
            setTimeout(() => {
                let html = '';
                switch (secao) {
                    case 'dados':
                        html = `
                            <h4>Meus Dados</h4>
                            <p>Nome: Usuário Teste</p>
                            <p>Email: usuario@teste.com</p>
                            <button class="btn btn-primary">Editar Dados</button>
                        `;
                        break;
                    case 'pedidos':
                        html = `
                            <h4>Meus Pedidos</h4>
                            <p>Lista de pedidos do usuário.</p>
                            <ul>
                                <li>Pedido #12345 - R$ 150,00 - Entregue</li>
                                <li>Pedido #12346 - R$ 80,00 - Em processamento</li>
                            </ul>
                        `;
                        break;
                    case 'favoritos':
                        html = `
                            <h4>Lista de Desejos</h4>
                            <p>Livros favoritados pelo usuário.</p>
                            <ul>
                                <li>Livro Favorito 1</li>
                                <li>Livro Favorito 2</li>
                            </ul>
                        `;
                        break;
                    case 'avaliacoes':
                        html = `
                            <h4>Minhas Avaliações</h4>
                            <p>Avaliações feitas pelo usuário.</p>
                            <ul>
                                <li>Livro X - ⭐⭐⭐⭐</li>
                                <li>Livro Y - ⭐⭐⭐</li>
                            </ul>
                        `;
                        break;
                    case 'enderecos':
                        html = `
                            <h4>Meus Endereços</h4>
                            <p>Endereços cadastrados para entrega.</p>
                            <p>Endereço Principal: Rua Exemplo, 123</p>
                            <button class="btn btn-primary">Adicionar Endereço</button>
                        `;
                        break;
                    default:
                        html = `<h4>Página não encontrada</h4>`;
                }
                conteudoDashboard.innerHTML = html;
            }, 500);
        }
    </script>
</body>
</html>