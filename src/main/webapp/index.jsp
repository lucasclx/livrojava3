<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="css/livraria-enhanced.css" rel="stylesheet">
    <style>
.skip-link {
    position: absolute;
    top: -40px;
    left: 6px;
    background: #000;
    color: #fff;
    padding: 8px;
    text-decoration: none;
    z-index: 1000;
}
.skip-link:focus {
    top: 6px;
}
    </style>
</head>
<body>
    <a href="#conteudo-principal" class="skip-link">Pular para o conteúdo principal</a>
    <div id="toast-container"></div>

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
                
                <button class="btn btn-outline-light position-relative me-2" onclick="abrirCarrinhoLateral()">
                    <i class="fas fa-shopping-cart"></i>
                    <span id="carrinho-contador" class="carrinho-contador" style="display: none;">0</span>
                </button>
                
<<<<<<< HEAD
                <a href="login.jsp" class="btn btn-outline-light me-2">
                    <i class="fas fa-user"></i> Login
                </a>
                <a href="minha-conta.jsp" class="btn btn-outline-light">
                    <i class="fas fa-user-circle"></i> Minha Conta
                </a>
=======
                <a href="login.jsp" class="btn btn-outline-light">
                    <i class="fas fa-user"></i> Login
                </a>
>>>>>>> 2fa591a (favorzinho2)
            </div>
        </div>
    </nav>

    <!-- Header com busca -->
    <div class="bg-light py-4">
        <div class="container">
            <div class="row">
                <div class="col-md-8 mx-auto">
                    <div class="search-container position-relative">
                        <label for="busca-input" class="visually-hidden">Buscar livros</label>
                        <input type="search" id="busca-input" class="form-control" 
                               placeholder="Buscar livros, autores..." 
                               autocomplete="off"
                               role="searchbox"
                               aria-label="Buscar livros"
                               aria-describedby="busca-ajuda">
                        <small id="busca-ajuda" class="form-text text-muted">Digite o nome do livro, autor ou ISBN</small>
                        <div id="sugestoes-busca" class="sugestoes-container position-absolute w-100"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Conteúdo principal -->
    <div class="container my-4">
        <div class="filtros-container mb-4">
            <div class="row">
                <div class="col-md-3">
                    <h6>Faixa de Preço</h6>
                    <div class="range-slider">
                        <input type="range" id="preco-min" min="0" max="500" value="0" class="form-range">
                        <input type="range" id="preco-max" min="0" max="500" value="500" class="form-range">
                        <div class="d-flex justify-content-between">
                            <span>R$ <span id="valor-min">0</span></span>
                            <span>R$ <span id="valor-max">500</span></span>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3">
                    <h6>Categorias</h6>
                    <div class="form-check">
                        <input class="form-check-input filtro-categoria" type="checkbox" value="Romance" id="cat-romance">
                        <label class="form-check-label" for="cat-romance">Romance</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input filtro-categoria" type="checkbox" value="Ficção" id="cat-ficcao">
                        <label class="form-check-label" for="cat-ficcao">Ficção</label>
                    </div>
                    <!-- Mais categorias... -->
                </div>
                
                <div class="col-md-3">
                    <h6>Disponibilidade</h6>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="em-estoque" checked>
                        <label class="form-check-label" for="em-estoque">Apenas em estoque</label>
                    </div>
                </div>
                
                <div class="col-md-3">
                    <h6>Ordenar por</h6>
                    <select class="form-select" id="ordenacao">
                        <option value="relevancia">Mais relevantes</option>
                        <option value="preco-asc">Menor preço</option>
                        <option value="preco-desc">Maior preço</option>
                        <option value="nome-asc">A-Z</option>
                        <option value="vendidos">Mais vendidos</option>
                    </select>
                </div>
            </div>
        </div>
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

    <div class="container my-4">
        <div class="recomendacoes-widget">
            <h4><i class="fas fa-magic"></i> Recomendado para você</h4>
            <div class="recomendacoes-carousel">
                <div class="d-flex overflow-auto">
                    <div id="recomendacoes-container">
                        <!-- Carregadas via AJAX -->
                    </div>
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
                    <!-- Componente de avaliação -->
                    <div class="avaliacoes-container mt-4">
                        <h5>Avaliações dos Clientes</h5>
                        
                        <div class="resumo-avaliacoes mb-4">
                            <div class="row align-items-center">
                                <div class="col-md-3 text-center">
                                    <div class="nota-grande">4.5</div>
                                    <div class="estrelas-grandes">
                                        ⭐⭐⭐⭐⭐
                                    </div>
                                    <small class="text-muted">Baseado em 127 avaliações</small>
                                </div>
                                <div class="col-md-9">
                                    <!-- Gráfico de barras das estrelas -->
                                    <div class="grafico-estrelas">
                                        <div class="linha-estrela">
                                            <span>5 ⭐</span>
                                            <div class="barra-progresso">
                                                <div class="barra-preenchida" style="width: 60%;"></div>
                                            </div>
                                            <span>60%</span>
                                        </div>
                                        <!-- Repetir para 4, 3, 2, 1 estrelas -->
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <button class="btn btn-primary mb-3" onclick="abrirFormAvaliacao()">
                            Escrever uma avaliação
                        </button>
                        
                        <div id="form-avaliacao" style="display: none;">
                            <form onsubmit="enviarAvaliacao(event)">
                                <div class="mb-3">
                                    <label>Sua nota:</label>
                                    <div class="estrelas-selecao">
                                        <span class="estrela" data-nota="1">☆</span>
                                        <span class="estrela" data-nota="2">☆</span>
                                        <span class="estrela" data-nota="3">☆</span>
                                        <span class="estrela" data-nota="4">☆</span>
                                        <span class="estrela" data-nota="5">☆</span>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <textarea class="form-control" placeholder="Conte sua experiência..." rows="3"></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary">Enviar Avaliação</button>
                            </form>
                        </div>
                        
                        <div class="lista-avaliacoes">
                            <!-- Avaliações serão carregadas aqui -->
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

<!-- Correções para erros JavaScript -->
<script>
// Correção 1: Service Worker - Remover ou comentar
if ('serviceWorker' in navigator) {
    // COMENTADO para evitar erro 404
    // navigator.serviceWorker.register('/sw.js');
    console.log('Service Worker desabilitado temporariamente');
}

// Correção 2: Função mostrarPreviewRapido ausente
if (typeof mostrarPreviewRapido === 'undefined') {
    window.mostrarPreviewRapido = function(livroId, event) {
        // Preview simples - pode ser expandido depois
        console.log('Preview do livro ID:', livroId);
        
        // Implementação básica do preview
        if (typeof todosLivros !== 'undefined') {
            const livro = todosLivros.find(l => l.id === livroId);
            if (livro) {
                // Criar tooltip simples
                let tooltip = document.getElementById('preview-tooltip');
                if (!tooltip) {
                    tooltip = document.createElement('div');
                    tooltip.id = 'preview-tooltip';
                    tooltip.className = 'position-absolute bg-white border rounded p-2 shadow';
                    tooltip.style.zIndex = '1000';
                    tooltip.style.display = 'none';
                    document.body.appendChild(tooltip);
                }
                
                tooltip.innerHTML = `
                    <strong>${livro.titulo}</strong><br>
                    <small>por ${livro.autor}</small><br>
                    <span class="text-primary">R$ ${formatarPreco ? formatarPreco(livro.preco) : livro.preco}</span>
                `;
                
                // Posicionar próximo ao mouse
                const rect = event.target.getBoundingClientRect();
                tooltip.style.left = (rect.right + 10) + 'px';
                tooltip.style.top = rect.top + 'px';
                tooltip.style.display = 'block';
                
                // Esconder após sair com mouse
                event.target.addEventListener('mouseleave', function() {
                    tooltip.style.display = 'none';
                }, { once: true });
            }
        }
    };
    console.log('✅ Função mostrarPreviewRapido criada');
}

// Correção 3: Verificar se funções essenciais existem
document.addEventListener('DOMContentLoaded', function() {
    // Lista de funções essenciais que devem existir
    const funcoesEssenciais = [
        'carregarTodosLivros',
        'adicionarAoCarrinho', 
        'verDetalhes',
        'formatarPreco',
        'mostrarNotificacao'
    ];
    
    funcoesEssenciais.forEach(func => {
        if (typeof window[func] === 'undefined') {
            console.warn(`⚠️ Função ${func} não encontrada`);
            
            // Criar stub básico para evitar erros
            window[func] = function() {
                console.log(`Stub chamado para: ${func}`, arguments);
                if (func === 'formatarPreco' && arguments[0]) {
                    return parseFloat(arguments[0]).toFixed(2).replace('.', ',');
                }
            };
        }
    });
    
    console.log('✅ Verificação de funções concluída');
});

// Correção 4: Interceptar erros de imagem globalmente
document.addEventListener('error', function(e) {
    if (e.target.tagName === 'IMG') {
        console.log('️ Corrigindo imagem quebrada:', e.target.src);
        if (!e.target.src.includes('no-image.svg')) {
            e.target.src = 'images/no-image.svg';
        }
        e.target.onerror = null; // Evitar loop
    }
}, true);

// Debugging: Log do estado atual
console.log(' Estado da aplicação:');
console.log('- URL atual:', window.location.href);
console.log('- Elementos na página:', document.querySelectorAll('*').length);
console.log('- Scripts carregados:', document.querySelectorAll('script').length);
</script>

<!-- Se quiser usar Service Worker, crie este arquivo básico em src/main/webapp/sw.js -->
<!--
// Conteúdo para sw.js (arquivo separado):
self.addEventListener('install', function(event) {
    console.log('Service Worker instalado');
});

self.addEventListener('fetch', function(event) {
    // Cache básico para recursos estáticos
    if (event.request.url.includes('.css') || event.request.url.includes('.js') || event.request.url.includes('images/')) {
        event.respondWith(
            caches.match(event.request).then(function(response) {
                return response || fetch(event.request);
            })
        );
    }
});
-->
</body>
</html>