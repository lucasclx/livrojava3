// Variáveis globais
let carrinho = [];
let livroSelecionado = null;
let usuarioLogado = null;

// Inicialização da página
document.addEventListener('DOMContentLoaded', function() {
    carregarTodosLivros();
    carregarCarrinhoDoStorage();
    atualizarContadorCarrinho();
    verificarStatusLogin();
    
    // Busca ao pressionar Enter
    document.getElementById('busca-input').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            buscarLivros();
        }
    });
});

// ===== FUNÇÕES DE LIVROS =====

// Função para carregar todos os livros
function carregarTodosLivros() {
    mostrarLoading(true);
    
    fetch('livros?action=listar')
        .then(response => response.json())
        .then(data => {
            if (data.erro) {
                throw new Error(data.erro);
            }
            exibirLivros(data);
        })
        .catch(error => {
            console.error('Erro ao carregar livros:', error);
            mostrarErro('Erro ao carregar livros: ' + error.message);
        })
        .finally(() => {
            mostrarLoading(false);
        });
}

// Função para buscar livros
function buscarLivros() {
    const termo = document.getElementById('busca-input').value.trim();
    mostrarLoading(true);
    
    const url = termo ? `livros?action=buscar&termo=${encodeURIComponent(termo)}` : 'livros?action=listar';
    
    fetch(url)
        .then(response => response.json())
        .then(data => {
            if (data.erro) {
                throw new Error(data.erro);
            }
            exibirLivros(data);
        })
        .catch(error => {
            console.error('Erro ao buscar livros:', error);
            mostrarErro('Erro ao buscar livros: ' + error.message);
        })
        .finally(() => {
            mostrarLoading(false);
        });
}

// Função para filtrar por categoria
function filtrarPorCategoria(categoria) {
    mostrarLoading(true);
    
    fetch(`livros?action=categoria&nome=${encodeURIComponent(categoria)}`)
        .then(response => response.json())
        .then(data => {
            if (data.erro) {
                throw new Error(data.erro);
            }
            exibirLivros(data);
        })
        .catch(error => {
            console.error('Erro ao filtrar por categoria:', error);
            mostrarErro('Erro ao filtrar livros: ' + error.message);
        })
        .finally(() => {
            mostrarLoading(false);
        });
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
                     onerror="this.src='images/no-image.jpg'">
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
                                    onclick="verDetalhes(${livro.id})">
                                <i class="fas fa-eye"></i> Ver
                            </button>
                            <button class="btn btn-sm btn-primary" 
                                    onclick="adicionarAoCarrinho(${livro.id})"
                                    ${livro.estoque === 0 ? 'disabled' : ''}>
                                <i class="fas fa-cart-plus"></i> 
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
    fetch(`livros?action=detalhes&id=${livroId}`)
        .then(response => response.json())
        .then(livro => {
            if (livro.erro) {
                throw new Error(livro.erro);
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
            
            new bootstrap.Modal(document.getElementById('detalhesModal')).show();
        })
        .catch(error => {
            console.error('Erro ao carregar detalhes:', error);
            mostrarErro('Erro ao carregar detalhes do livro');
        });
}

// ===== FUNÇÕES DE CARRINHO =====

// Função para adicionar ao carrinho
function adicionarAoCarrinho(livroId) {
    fetch(`livros?action=detalhes&id=${livroId}`)
        .then(response => response.json())
        .then(livro => {
            if (livro.erro) {
                throw new Error(livro.erro);
            }
            
            if (livro.estoque === 0) {
                mostrarErro('Livro indisponível no estoque');
                return;
            }
            
            const itemExistente = carrinho.find(item => item.id === livroId);
            
            if (itemExistente) {
                if (itemExistente.quantidade < livro.estoque) {
                    itemExistente.quantidade++;
                    mostrarSucesso('Quantidade atualizada no carrinho!');
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
                mostrarSucesso('Livro adicionado ao carrinho!');
            }
            
            salvarCarrinhoNoStorage();
            atualizarContadorCarrinho();
        })
        .catch(error => {
            console.error('Erro ao adicionar ao carrinho:', error);
            mostrarErro('Erro ao adicionar livro ao carrinho');
        });
}

// Função para adicionar ao carrinho via modal
function adicionarAoCarrinhoModal() {
    if (livroSelecionado) {
        adicionarAoCarrinho(livroSelecionado.id);
        bootstrap.Modal.getInstance(document.getElementById('detalhesModal')).hide();
    }
}

// Função para abrir carrinho
function abrirCarrinho() {
    const carrinhoItens = document.getElementById('carrinho-itens');
    
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
    new bootstrap.Modal(document.getElementById('carrinhoModal')).show();
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
    abrirCarrinho(); // Recarregar o modal
}

// Função para remover do carrinho
function removerDoCarrinho(livroId) {
    carrinho = carrinho.filter(item => item.id !== livroId);
    salvarCarrinhoNoStorage();
    atualizarContadorCarrinho();
    abrirCarrinho(); // Recarregar o modal
    mostrarSucesso('Item removido do carrinho');
}

// Função para finalizar compra
function finalizarCompra() {
    if (carrinho.length === 0) {
        mostrarErro('Carrinho vazio');
        return;
    }
    
    // Verificar se está logado
    fetch('login?action=status')
        .then(response => response.json())
        .then(data => {
            if (!data.logado) {
                if (confirm('Você precisa estar logado para finalizar a compra. Deseja fazer login agora?')) {
                    window.location.href = 'login.jsp';
                }
                return;
            }
            
            // Redirecionar para página de checkout
            window.location.href = 'checkout.jsp';
        })
        .catch(error => {
            console.error('Erro ao verificar login:', error);
            // Se não conseguir verificar, redirecionar para checkout mesmo assim
            window.location.href = 'checkout.jsp';
        });
}

// ===== FUNÇÕES DE AUTENTICAÇÃO =====

// Verificar status de login
function verificarStatusLogin() {
    fetch('login?action=status')
        .then(response => response.json())
        .then(data => {
            if (data.logado) {
                usuarioLogado = data.usuario;
                document.getElementById('login-text').textContent = data.usuario.nome;
                // Pode adicionar mais elementos da UI aqui se necessário
            } else {
                usuarioLogado = null;
                document.getElementById('login-text').textContent = 'Login';
            }
        })
        .catch(error => {
            console.error('Erro ao verificar status:', error);
            usuarioLogado = null;
        });
}

// Função para verificar login (quando clica no botão)
function verificarLogin() {
    if (usuarioLogado) {
        // Usuário já está logado - mostrar menu
        mostrarMenuUsuario(usuarioLogado);
    } else {
        // Verificar status atual e redirecionar
        fetch('login?action=status')
            .then(response => response.json())
            .then(data => {
                if (data.logado) {
                    usuarioLogado = data.usuario;
                    mostrarMenuUsuario(data.usuario);
                } else {
                    window.location.href = 'login.jsp';
                }
            })
            .catch(error => {
                console.error('Erro ao verificar login:', error);
                window.location.href = 'login.jsp';
            });
    }
}

// Mostrar menu do usuário logado
function mostrarMenuUsuario(usuario) {
    const opcoes = [
        { texto: 'Meus Pedidos', acao: () => window.location.href = 'meus-pedidos.jsp' },
        { texto: 'Painel Admin', acao: () => window.location.href = 'admin/admin.jsp', admin: true },
        { texto: 'Sair', acao: () => fazerLogout() }
    ];
    
    // Criar menu simples com confirm (pode ser melhorado com modal)
    let menu = `Olá, ${usuario.nome}!\n\nEscolha uma opção:\n`;
    let contador = 1;
    const opcoesVisiveis = opcoes.filter(opcao => !opcao.admin || usuario.tipo === 'admin');
    
    opcoesVisiveis.forEach((opcao, index) => {
        menu += `${contador} - ${opcao.texto}\n`;
        contador++;
    });
    
    const escolha = prompt(menu + '\nDigite o número da opção:');
    
    if (escolha) {
        const opcaoEscolhida = parseInt(escolha) - 1;
        
        if (opcoesVisiveis[opcaoEscolhida]) {
            opcoesVisiveis[opcaoEscolhida].acao();
        }
    }
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
            document.getElementById('login-text').textContent = 'Login';
            mostrarSucesso('Logout realizado com sucesso');
            // Limpar carrinho se desejar
            // carrinho = [];
            // salvarCarrinhoNoStorage();
            // atualizarContadorCarrinho();
        }
    })
    .catch(error => {
        console.error('Erro ao fazer logout:', error);
        mostrarErro('Erro ao fazer logout');
    });
}

// Função de login (compatibilidade com código antigo)
function fazerLogin() {
    window.location.href = 'login.jsp';
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
    const totalElement = document.getElementById('carrinho-total');
    if (totalElement) {
        const total = carrinho.reduce((sum, item) => sum + (item.preco * item.quantidade), 0);
        totalElement.textContent = formatarPreco(total);
    }
}

// Formatar preço para exibição
function formatarPreco(preco) {
    return parseFloat(preco).toFixed(2).replace('.', ',');
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

// Mostrar mensagem de sucesso
function mostrarSucesso(mensagem) {
    // Implementação com toast ou alert melhorado
    if (typeof Swal !== 'undefined') {
        // Se tiver SweetAlert2 carregado
        Swal.fire({
            icon: 'success',
            title: 'Sucesso!',
            text: mensagem,
            timer: 3000,
            showConfirmButton: false
        });
    } else {
        // Fallback para alert simples
        alert('✓ ' + mensagem);
    }
}

// Mostrar mensagem de erro
function mostrarErro(mensagem) {
    // Implementação com toast ou alert melhorado
    if (typeof Swal !== 'undefined') {
        // Se tiver SweetAlert2 carregado
        Swal.fire({
            icon: 'error',
            title: 'Erro!',
            text: mensagem,
            confirmButtonText: 'OK'
        });
    } else {
        // Fallback para alert simples
        alert('✗ ' + mensagem);
    }
}

// Mostrar informação
function mostrarInfo(mensagem) {
    if (typeof Swal !== 'undefined') {
        Swal.fire({
            icon: 'info',
            title: 'Informação',
            text: mensagem,
            confirmButtonText: 'OK'
        });
    } else {
        alert('ℹ ' + mensagem);
    }
}

// ===== UTILITÁRIOS =====

// Limpar formulário de busca
function limparBusca() {
    document.getElementById('busca-input').value = '';
    carregarTodosLivros();
}

// Rolar para o topo
function rolarParaTopo() {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
}

// Validar email
function validarEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}

// Formatar CPF (para uso futuro)
function formatarCPF(cpf) {
    return cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
}

// Remover formatação de CPF
function limparCPF(cpf) {
    return cpf.replace(/\D/g, '');
}

// Debug do carrinho (função auxiliar para desenvolvimento)
function debugCarrinho() {
    console.log('=== DEBUG CARRINHO ===');
    console.log('Itens no carrinho:', carrinho.length);
    console.log('Carrinho:', carrinho);
    console.log('Total:', carrinho.reduce((sum, item) => sum + (item.preco * item.quantidade), 0));
    console.log('======================');
}

// Event listeners adicionais (para funcionalidades futuras)
document.addEventListener('keydown', function(e) {
    // ESC para fechar modals
    if (e.key === 'Escape') {
        const modals = document.querySelectorAll('.modal.show');
        modals.forEach(modal => {
            const modalInstance = bootstrap.Modal.getInstance(modal);
            if (modalInstance) {
                modalInstance.hide();
            }
        });
    }
});

// Interceptar erros JavaScript globais
window.addEventListener('error', function(e) {
    console.error('Erro JavaScript capturado:', e.error);
    // Não mostrar erro para o usuário em produção
    if (window.location.hostname === 'localhost') {
        mostrarErro('Erro JavaScript: ' + e.message);
    }
});

// Notificar quando a página perde o foco (para salvar dados)
document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
        // Página perdeu o foco - salvar dados importantes
        salvarCarrinhoNoStorage();
    }
});

console.log('📚 Livraria Online carregada com sucesso!');