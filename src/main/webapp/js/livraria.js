// Variáveis globais
let carrinho = [];
let livroSelecionado = null;
let usuarioLogado = null;
let todosLivros = []; // Cache para os livros
let timeoutBusca;
let notaSelecionada = 0;

// Inicialização da página
document.addEventListener('DOMContentLoaded', function() {
    criarCarrinhoLateral();
    carregarTodosLivros();
    carregarCarrinhoDoStorage();
    atualizarContadorCarrinho();
    verificarStatusLogin();
    
    // Event listeners dos filtros
    document.getElementById('busca-input').addEventListener('input', function(e) {
        clearTimeout(timeoutBusca);
        const termo = e.target.value.trim();
        
        if (termo.length < 2) {
            document.getElementById('sugestoes-busca').style.display = 'none';
            return;
        }
        
        timeoutBusca = setTimeout(() => {
            fetch(`livros?action=buscar&termo=${encodeURIComponent(termo)}&limite=5`)
                .then(response => response.json())
                .then(livros => {
                    mostrarSugestoes(livros);
                });
        }, 300); // Debounce de 300ms
    });
    
    document.getElementById('preco-min').addEventListener('input', atualizarValorRange);
    document.getElementById('preco-max').addEventListener('input', atualizarValorRange);
    
    document.querySelectorAll('.filtro-categoria').forEach(el => el.addEventListener('change', aplicarFiltros));
    document.getElementById('em-estoque').addEventListener('change', aplicarFiltros);
    document.getElementById('ordenacao').addEventListener('change', aplicarFiltros);

    // Event listeners para as estrelas de avaliação
    document.querySelectorAll('.estrelas-selecao .estrela').forEach(estrela => {
        estrela.addEventListener('click', function() {
            notaSelecionada = parseInt(this.dataset.nota);
            atualizarEstrelasSelecao();
        });
        estrela.addEventListener('mouseover', function() {
            preencherEstrelas(parseInt(this.dataset.nota));
        });
        estrela.addEventListener('mouseout', function() {
            preencherEstrelas(notaSelecionada);
        });
    });
    carregarRecomendacoes();
});

function atualizarValorRange() {
    const min = document.getElementById('preco-min').value;
    const max = document.getElementById('preco-max').value;
    document.getElementById('valor-min').textContent = min;
    document.getElementById('valor-max').textContent = max;
    aplicarFiltros();
}

// ===== FUNÇÕES DE LIVROS =====

function aplicarFiltros() {
    const termoBusca = document.getElementById('busca-input').value.toLowerCase();
    const precoMin = parseFloat(document.getElementById('preco-min').value);
    const precoMax = parseFloat(document.getElementById('preco-max').value);
    
    const categoriasSelecionadas = [...document.querySelectorAll('.filtro-categoria:checked')].map(el => el.value);
    const apenasEmEstoque = document.getElementById('em-estoque').checked;
    const ordenacao = document.getElementById('ordenacao').value;

    let livrosFiltrados = todosLivros.filter(livro => {
        const atendeBusca = !termoBusca || livro.titulo.toLowerCase().includes(termoBusca) || livro.autor.toLowerCase().includes(termoBusca);
        const atendePreco = livro.preco >= precoMin && livro.preco <= precoMax;
        const atendeCategoria = categoriasSelecionadas.length === 0 || categoriasSelecionadas.includes(livro.categoria);
        const atendeEstoque = !apenasEmEstoque || livro.estoque > 0;
        
        return atendeBusca && atendePreco && atendeCategoria && atendeEstoque;
    });

    // Ordenação
    switch (ordenacao) {
        case 'preco-asc':
            livrosFiltrados.sort((a, b) => a.preco - b.preco);
            break;
        case 'preco-desc':
            livrosFiltrados.sort((a, b) => b.preco - a.preco);
            break;
        case 'nome-asc':
            livrosFiltrados.sort((a, b) => a.titulo.localeCompare(b.titulo));
            break;
        // 'relevancia' e 'vendidos' precisariam de lógica de backend
    }

    exibirLivros(livrosFiltrados);
}

// Função para carregar todos os livros
function carregarTodosLivros() {
    mostrarLoading(true);
    
    fetch('livros?action=listar')
        .then(response => response.json())
        .then(data => {
            if (data.erro) {
                throw new Error(data.erro);
            }
            todosLivros = data; // Armazena no cache
            aplicarFiltros(); // Exibe os livros com os filtros padrão
        })
        .catch(error => {
            console.error('Erro ao carregar livros:', error);
            mostrarErro('Erro ao carregar livros: ' + error.message);
        })
        .finally(() => {
            mostrarLoading(false);
        });
}

// Função para buscar livros (agora integrada com filtros)
function buscarLivros() {
    aplicarFiltros();
}

// Função para filtrar por categoria (agora integrada com filtros)
function filtrarPorCategoria(categoria) {
    // Marcar a checkbox correspondente e aplicar filtros
    const checkbox = document.querySelector(`.filtro-categoria[value="${categoria}"]`);
    if (checkbox) {
        checkbox.checked = true;
    }
    aplicarFiltros();
}

// Função para exibir livros na tela
function exibirLivros(livros) {
    const container = document.getElementById('livros-container');
    const semResultados = document.getElementById('sem-resultados');
    
    if (!livros || livros.length === 0) {
        container.innerHTML = '';
        semResultados.style.display = 'block';
        return;
    }
    
    semResultados.style.display = 'none';
    
    const html = livros.map(livro => `
        <div class="col-md-3 col-sm-6 mb-4">
            <div class="card livro-card h-100">
                <img src="${livro.imagem || 'images/no-image.jpg'}" 
                     class="card-img-top livro-imagem" 
                     alt="${livro.titulo}"
                     onerror="this.src='images/no-image.jpg'"
                     onmouseover="mostrarPreviewRapido(${livro.id}, event)">
                <div class="card-body d-flex flex-column">
                    <h6 class="card-title">${livro.titulo}</h6>
                    <p class="card-text text-muted small">por ${livro.autor}</p>
                    <p class="card-text"><small class="text-muted">${livro.categoria}</small></p>
                    <div class="mt-auto">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="h5 text-primary mb-0">R$ ${formatarPreco(livro.preco)}</span>
                            <small class="text-muted">${livro.estoque} em estoque</small>
                        </div>
                        <div class="mt-2">
                            <button class="btn btn-sm btn-outline-primary me-1" 
                                    onclick="verDetalhes(${livro.id})"
                                    aria-label="Ver detalhes do livro ${livro.titulo}">
                                <i class="fas fa-eye" aria-hidden="true"></i> Ver
                            </button>
                            <button class="btn btn-sm btn-outline-danger me-1" 
                                    onclick="toggleFavorito(${livro.id}, this)"
                                    aria-label="Adicionar ${livro.titulo} à lista de desejos">
                                <i class="far fa-heart" aria-hidden="true"></i>
                            </button>
                            <button class="btn btn-sm btn-primary" 
                                    onclick="adicionarAoCarrinho(${livro.id})"
                                    ${livro.estoque === 0 ? 'disabled' : ''}
                                    aria-label="Adicionar ${livro.titulo} ao carrinho">
                                <i class="fas fa-cart-plus" aria-hidden="true"></i> 
                                ${livro.estoque === 0 ? 'Indisponível' : 'Comprar'}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

// Função para ver detalhes do livro
function verDetalhes(livroId) {
    const livro = todosLivros.find(l => l.id === livroId);
    if (!livro) {
        mostrarErro('Livro não encontrado');
        return;
    }
    
    livroSelecionado = livro;
    
    document.getElementById('detalhes-titulo').textContent = livro.titulo;
    document.getElementById('detalhes-autor').textContent = livro.autor;
    document.getElementById('detalhes-isbn').textContent = livro.isbn || 'Não informado';
    document.getElementById('detalhes-categoria').textContent = livro.categoria;
    document.getElementById('detalhes-preco').textContent = formatarPreco(livro.preco);
    document.getElementById('detalhes-estoque').textContent = livro.estoque;
    document.getElementById('detalhes-descricao').textContent = livro.descricao || 'Sem descrição disponível';
    document.getElementById('detalhes-imagem').src = livro.imagem || 'images/no-image.jpg';
    
    // Carregar avaliações para o livro selecionado
    carregarAvaliacoes(livroId);

    new bootstrap.Modal(document.getElementById('detalhesModal')).show();
}

// ===== FUNÇÕES DE AVALIAÇÃO =====

function abrirFormAvaliacao() {
    const form = document.getElementById('form-avaliacao');
    if (form.style.display === 'none') {
        form.style.display = 'block';
    } else {
        form.style.display = 'none';
    }
}

function preencherEstrelas(nota) {
    document.querySelectorAll('.estrelas-selecao .estrela').forEach((estrela, index) => {
        if (index < nota) {
            estrela.textContent = '★'; // Estrela preenchida
        } else {
            estrela.textContent = '☆'; // Estrela vazia
        }
    });
}

function atualizarEstrelasSelecao() {
    preencherEstrelas(notaSelecionada);
}

function enviarAvaliacao(event) {
    event.preventDefault();
    
    if (!usuarioLogado) {
        mostrarErro('Você precisa estar logado para enviar uma avaliação.');
        return;
    }

    if (livroSelecionado === null) {
        mostrarErro('Nenhum livro selecionado para avaliação.');
        return;
    }

    const comentario = document.querySelector('#form-avaliacao textarea').value;

    if (notaSelecionada === 0) {
        mostrarErro('Por favor, selecione uma nota.');
        return;
    }

    fetch('avaliacoes?action=criar', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            livroId: livroSelecionado.id,
            nota: notaSelecionada,
            comentario: comentario
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.sucesso) {
            mostrarNotificacao('Avaliação enviada com sucesso!', 'success');
            document.querySelector('#form-avaliacao textarea').value = '';
            notaSelecionada = 0;
            atualizarEstrelasSelecao();
            abrirFormAvaliacao(); // Esconder formulário
            carregarAvaliacoes(livroSelecionado.id); // Recarregar avaliações
        } else {
            mostrarErro(data.erro || 'Erro ao enviar avaliação.');
        }
    })
    .catch(error => {
        console.error('Erro ao enviar avaliação:', error);
        mostrarErro('Erro ao enviar avaliação. Tente novamente.');
    });
}

function carregarAvaliacoes(livroId) {
    fetch(`avaliacoes?livroId=${livroId}`)
        .then(response => response.json())
        .then(data => {
            const resumoAvaliacoes = document.querySelector('.resumo-avaliacoes');
            const listaAvaliacoes = document.querySelector('.lista-avaliacoes');

            // Atualizar resumo
            if (data.estatisticas) {
                const stats = data.estatisticas;
                resumoAvaliacoes.querySelector('.nota-grande').textContent = stats.media_nota ? stats.media_nota.toFixed(1) : '0.0';
                resumoAvaliacoes.querySelector('.estrelas-grandes').innerHTML = gerarEstrelasHTML(stats.media_nota);
                resumoAvaliacoes.querySelector('small').textContent = `Baseado em ${stats.total_avaliacoes} avaliações`;

                // Gráfico de barras
                const total = stats.total_avaliacoes > 0 ? stats.total_avaliacoes : 1;
                resumoAvaliacoes.querySelector('.grafico-estrelas').innerHTML = `
                    <div class="linha-estrela">
                        <span>5 ⭐</span>
                        <div class="barra-progresso">
                            <div class="barra-preenchida" style="width: ${((stats.cinco_estrelas || 0) / total * 100).toFixed(0)}%;"></div>
                        </div>
                        <span>${((stats.cinco_estrelas || 0) / total * 100).toFixed(0)}%</span>
                    </div>
                    <div class="linha-estrela">
                        <span>4 ⭐</span>
                        <div class="barra-progresso">
                            <div class="barra-preenchida" style="width: ${((stats.quatro_estrelas || 0) / total * 100).toFixed(0)}%;"></div>
                        </div>
                        <span>${((stats.quatro_estrelas || 0) / total * 100).toFixed(0)}%</span>
                    </div>
                    <div class="linha-estrela">
                        <span>3 ⭐</span>
                        <div class="barra-progresso">
                            <div class="barra-preenchida" style="width: ${((stats.tres_estrelas || 0) / total * 100).toFixed(0)}%;"></div>
                        </div>
                        <span>${((stats.tres_estrelas || 0) / total * 100).toFixed(0)}%</span>
                    </div>
                    <div class="linha-estrela">
                        <span>2 ⭐</span>
                        <div class="barra-progresso">
                            <div class="barra-preenchida" style="width: ${((stats.duas_estrelas || 0) / total * 100).toFixed(0)}%;"></div>
                        </div>
                        <span>${((stats.duas_estrelas || 0) / total * 100).toFixed(0)}%</span>
                    </div>
                    <div class="linha-estrela">
                        <span>1 ⭐</span>
                        <div class="barra-progresso">
                            <div class="barra-preenchida" style="width: ${((stats.uma_estrela || 0) / total * 100).toFixed(0)}%;"></div>
                        </div>
                        <span>${((stats.uma_estrela || 0) / total * 100).toFixed(0)}%</span>
                    </div>
                `;
            } else {
                resumoAvaliacoes.querySelector('.nota-grande').textContent = '0.0';
                resumoAvaliacoes.querySelector('.estrelas-grandes').innerHTML = '☆☆☆☆☆';
                resumoAvaliacoes.querySelector('small').textContent = 'Baseado em 0 avaliações';
                resumoAvaliacoes.querySelector('.grafico-estrelas').innerHTML = '';
            }

            // Listar avaliações
            if (data.avaliacoes && data.avaliacoes.length > 0) {
                listaAvaliacoes.innerHTML = data.avaliacoes.map(avaliacao => `
                    <div class="card mb-3">
                        <div class="card-body">
                            <h6 class="card-title">${gerarEstrelasHTML(avaliacao.nota)}</h6>
                            <p class="card-text">${avaliacao.comentario}</p>
                            <small class="text-muted">Por Usuário ${avaliacao.usuarioId} em ${new Date(avaliacao.dataAvaliacao).toLocaleDateString()}</small>
                        </div>
                    </div>
                `).join('');
            } else {
                listaAvaliacoes.innerHTML = '<p class="text-muted">Nenhuma avaliação para este livro ainda.</p>';
            }
        })
        .catch(error => {
            console.error('Erro ao carregar avaliações:', error);
            mostrarErro('Erro ao carregar avaliações.');
        });
}

function gerarEstrelasHTML(nota) {
    let html = '';
    for (let i = 0; i < 5; i++) {
        html += (i < Math.round(nota)) ? '★' : '☆';
    }
    return html;
}

// ===== FUNÇÕES DE CARRINHO =====

// Função para adicionar ao carrinho
function adicionarAoCarrinho(livroId) {
    const livro = todosLivros.find(l => l.id === livroId);
    if (!livro) {
        mostrarErro('Livro não encontrado');
        return;
    }
    
    if (livro.estoque === 0) {
        mostrarErro('Livro indisponível no estoque');
        return;
    }
    
    const itemExistente = carrinho.find(item => item.id === livroId);
    
    if (itemExistente) {
        if (itemExistente.quantidade < livro.estoque) {
            itemExistente.quantidade++;
            mostrarNotificacao('Quantidade atualizada no carrinho!', 'success');
        } else {
            mostrarErro('Quantidade máxima disponível no estoque');
            return;
        }
    } else {
        carrinho.push({
            id: livro.id,
            titulo: livro.titulo,
            autor: livro.autor,
            preco: livro.preco,
            quantidade: 1,
            estoque: livro.estoque
        });
        mostrarNotificacao('Livro adicionado ao carrinho!', 'success');
    }
    
    salvarCarrinhoNoStorage();
    atualizarContadorCarrinho();
    abrirCarrinhoLateral();
}

// Função para adicionar ao carrinho via modal
function adicionarAoCarrinhoModal() {
    if (livroSelecionado) {
        adicionarAoCarrinho(livroSelecionado.id);
        bootstrap.Modal.getInstance(document.getElementById('detalhesModal')).hide();
    }
}

// Função para abrir carrinho
function abrirCarrinhoLateral() {
    const sidebar = document.getElementById('carrinho-sidebar');
    const carrinhoItens = document.getElementById('carrinho-itens-lateral');
    
    if (carrinho.length === 0) {
        carrinhoItens.innerHTML = `
            <div class="text-center py-4">
                <i class="fas fa-shopping-cart fa-3x text-muted"></i>
                <h5 class="text-muted mt-3">Seu carrinho está vazio</h5>
                <p class="text-muted">Adicione alguns livros para continuar</p>
            </div>
        `;
    } else {
        const html = carrinho.map(item => `
            <div class="row align-items-center border-bottom py-3">
                <div class="col-md-6">
                    <h6 class="mb-1">${item.titulo}</h6>
                    <small class="text-muted">por ${item.autor}</small>
                </div>
                <div class="col-md-2">
                    <span class="fw-bold">R$ ${formatarPreco(item.preco)}</span>
                </div>
                <div class="col-md-3">
                    <div class="input-group input-group-sm">
                        <button class="btn btn-outline-secondary" 
                                onclick="alterarQuantidade(${item.id}, -1)">-</button>
                        <input type="text" class="form-control text-center" 
                               value="${item.quantidade}" readonly>
                        <button class="btn btn-outline-secondary" 
                                onclick="alterarQuantidade(${item.id}, 1)">+</button>
                    </div>
                </div>
                <div class="col-md-1">
                    <button class="btn btn-sm btn-outline-danger" 
                            onclick="removerDoCarrinho(${item.id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        `).join('');
        
        carrinhoItens.innerHTML = html;
    }
    
    atualizarTotalCarrinho();
    sidebar.classList.add('aberto');
}

function fecharCarrinhoLateral() {
    document.getElementById('carrinho-sidebar').classList.remove('aberto');
}

// Função para alterar quantidade no carrinho
function alterarQuantidade(livroId, incremento) {
    const item = carrinho.find(item => item.id === livroId);
    if (!item) return;
    
    const novaQuantidade = item.quantidade + incremento;
    
    if (novaQuantidade <= 0) {
        removerDoCarrinho(livroId);
        return;
    }
    
    if (novaQuantidade > item.estoque) {
        mostrarErro('Quantidade máxima disponível no estoque');
        return;
    }
    
    item.quantidade = novaQuantidade;
    salvarCarrinhoNoStorage();
    atualizarContadorCarrinho();
    abrirCarrinhoLateral(); // Recarregar o modal
}

// Função para remover do carrinho
function removerDoCarrinho(livroId) {
    carrinho = carrinho.filter(item => item.id !== livroId);
    salvarCarrinhoNoStorage();
    atualizarContadorCarrinho();
    abrirCarrinhoLateral(); // Recarregar o modal
    mostrarNotificacao('Item removido do carrinho', 'info');
}

// Função para finalizar compra
function finalizarCompra() {
    if (carrinho.length === 0) {
        mostrarErro('Carrinho vazio');
        return;
    }
    
    if (!usuarioLogado) {
        if (confirm('Você precisa estar logado para finalizar a compra. Deseja fazer login agora?')) {
            window.location.href = 'login.jsp';
        }
        return;
    }
    
    window.location.href = 'checkout.jsp';
}

// ===== FUNÇÕES DE AUTENTICAÇÃO =====

// Verificar status de login
function verificarStatusLogin() {
    fetch('login?action=status')
        .then(response => response.json())
        .then(data => {
            if (data.logado) {
                usuarioLogado = data.usuario;
                // Atualizar UI se necessário
            } else {
                usuarioLogado = null;
            }
        })
        .catch(error => {
            console.error('Erro ao verificar status:', error);
            usuarioLogado = null;
        });
}

// Fazer logout
function fazerLogout() {
    fetch('login', {
        method: 'POST',
        body: new URLSearchParams('action=logout')
    })
    .then(response => response.json())
    .then(data => {
        if (data.sucesso) {
            usuarioLogado = null;
            mostrarNotificacao('Logout realizado com sucesso', 'success');
            window.location.reload();
        }
    })
    .catch(error => {
        console.error('Erro ao fazer logout:', error);
        mostrarErro('Erro ao fazer logout');
    });
}

// ===== FUNÇÕES AUXILIARES =====

// Mostrar/ocultar loading
function mostrarLoading(mostrar) {
    const loading = document.getElementById('loading');
    if (loading) {
        loading.style.display = mostrar ? 'block' : 'none';
    }
}

// Atualizar contador do carrinho
function atualizarContadorCarrinho() {
    const contador = document.getElementById('carrinho-contador');
    const totalItens = carrinho.reduce((sum, item) => sum + item.quantidade, 0);
    
    if (contador) {
        if (totalItens > 0) {
            contador.textContent = totalItens;
            contador.style.display = 'flex';
        } else {
            contador.style.display = 'none';
        }
    }
}

// Atualizar total do carrinho
function atualizarTotalCarrinho() {
    const totalElement = document.getElementById('carrinho-total-lateral');
    if (totalElement) {
        const total = carrinho.reduce((sum, item) => sum + (item.preco * item.quantidade), 0);
        totalElement.textContent = 'R$ ' + formatarPreco(total);
    }
}

// Formatar preço para exibição
function formatarPreco(preco) {
    if (typeof preco === 'string') {
        preco = parseFloat(preco);
    }
    return preco.toFixed(2).replace('.', ',');
}

// Salvar carrinho no localStorage
function salvarCarrinhoNoStorage() {
    try {
        localStorage.setItem('carrinho', JSON.stringify(carrinho));
    } catch (error) {
        console.error('Erro ao salvar carrinho:', error);
    }
}

// Carregar carrinho do localStorage
function carregarCarrinhoDoStorage() {
    try {
        const carrinhoSalvo = localStorage.getItem('carrinho');
        if (carrinhoSalvo) {
            carrinho = JSON.parse(carrinhoSalvo);
        }
    } catch (error) {
        console.error('Erro ao carregar carrinho:', error);
        carrinho = [];
    }
}

// Funções de notificação (usando alert como fallback)
function mostrarNotificacao(mensagem, tipo = 'info', duracao = 3000) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast-notificacao toast-${tipo}`;
    toast.innerHTML = `
        <div class="toast-conteudo">
            <i class="fas ${obterIconeNotificacao(tipo)}"></i>
            <span>${mensagem}</span>
        </div>
        <button class="toast-fechar" onclick="this.parentElement.remove()">×</button>
    `;
    
    container.appendChild(toast);
    
    // Animação de entrada
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Auto remover
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, duracao);
}

function obterIconeNotificacao(tipo) {
    const icones = {
        'success': 'fa-check-circle',
        'error': 'fa-exclamation-circle',
        'warning': 'fa-exclamation-triangle',
        'info': 'fa-info-circle'
    };
    return icones[tipo] || icones.info;
}

function mostrarErro(mensagem) {
    mostrarNotificacao(mensagem, 'error');
}

function mostrarSugestoes(livros) {
    const container = document.getElementById('sugestoes-busca');
    
    if (livros.length === 0) {
        container.innerHTML = '<div class="p-3 text-muted">Nenhum resultado encontrado</div>';
    } else {
        container.innerHTML = livros.map(livro => `
            <div class="sugestao-item p-2" onclick="selecionarLivro(${livro.id})">
                <div class="d-flex align-items-center">
                    <img src="${livro.imagem || 'images/no-image.jpg'}" width="40" height="60" class="me-2" 
                    onerror="this.src='images/no-image.jpg'">
                    <div>
                        <div class="fw-bold">${livro.titulo}</div>
                        <small class="text-muted">${livro.autor} - R$ ${formatarPreco(livro.preco)}</small>
                    </div>
                </div>
            </div>
        `).join('');
    }
    
    container.style.display = 'block';
}

function selecionarLivro(livroId) {
    verDetalhes(livroId);
    document.getElementById('sugestoes-busca').style.display = 'none';
}

function criarCarrinhoLateral() {
    const sidebar = document.createElement('div');
    sidebar.id = 'carrinho-sidebar';
    sidebar.className = 'carrinho-sidebar';
    sidebar.innerHTML = `
        <div class="carrinho-header">
            <h5><i class="fas fa-shopping-cart"></i> Meu Carrinho</h5>
            <button class="btn-close" onclick="fecharCarrinhoLateral()"></button>
        </div>
        <div class="carrinho-body">
            <div id="carrinho-itens-lateral"></div>
        </div>
        <div class="carrinho-footer">
            <div class="d-flex justify-content-between mb-3">
                <span class="fw-bold">Total:</span>
                <span class="fw-bold" id="carrinho-total-lateral">R$ 0,00</span>
            </div>
            <button class="btn btn-primary w-100" onclick="finalizarCompra()">
                Finalizar Compra
            </button>
            <button class="btn btn-outline-secondary w-100 mt-2" onclick="fecharCarrinhoLateral()">
                Continuar Comprando
            </button>
        </div>
    `;
    document.body.appendChild(sidebar);
}

function carregarRecomendacoes() {
    fetch('livros?action=recomendacoes')
        .then(response => response.json())
        .then(livros => {
            const container = document.getElementById('recomendacoes-container');
            container.innerHTML = livros.map(livro => `
                <div class="card me-3" style="min-width: 200px;">
                    <img src="${livro.imagem}" class="card-img-top" style="height: 250px;">
                    <div class="card-body">
                        <h6 class="card-title text-truncate">${livro.titulo}</h6>
                        <p class="text-primary fw-bold">R$ ${formatarPreco(livro.preco)}</p>
                        <button class="btn btn-sm btn-primary w-100" 
                                onclick="adicionarAoCarrinho(${livro.id})">
                            Comprar
                        </button>
                    </div>
                </div>
            `).join('');
        });
}

function toggleFavorito(livroId, elemento) {
    const isFavorito = elemento.classList.contains('favorito');
    
    fetch('favoritos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            action: isFavorito ? 'remover' : 'adicionar',
            livroId: livroId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.sucesso) {
            elemento.classList.toggle('favorito');
            elemento.innerHTML = isFavorito ? '<i class="far fa-heart"></i>' : '<i class="fas fa-heart"></i>';
            mostrarNotificacao(isFavorito ? 'Removido dos favoritos' : 'Adicionado aos favoritos', 'info');
        } else {
            mostrarErro(data.erro || 'Erro ao atualizar favoritos');
        }
    })
    .catch(error => {
        console.error('Erro ao atualizar favoritos:', error);
        mostrarErro('Erro ao atualizar favoritos. Tente novamente.');
    });
}

// Debounce para eventos frequentes
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Cache de requisições
const cache = new Map();

function fetchComCache(url, opcoes = {}) {
    const chaveCache = url + JSON.stringify(opcoes);
    
    if (cache.has(chaveCache)) {
        const { data, timestamp } = cache.get(chaveCache);
        const idadeCache = Date.now() - timestamp;
        
        // Cache válido por 5 minutos
        if (idadeCache < 5 * 60 * 1000) {
            return Promise.resolve(data);
        }
    }
    
    return fetch(url, opcoes)
        .then(response => response.json())
        .then(data => {
            cache.set(chaveCache, { data, timestamp: Date.now() });
            return data;
        });
}

// Preload de imagens
function preloadImagens(urls) {
    urls.forEach(url => {
        const img = new Image();
        img.src = url;
    });
}

// Service Worker para cache offline
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js');
}

console.log('📚 Livraria Online carregada com sucesso!');
