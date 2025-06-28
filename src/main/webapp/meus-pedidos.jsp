<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Meus Pedidos - Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .pedido-card {
            transition: transform 0.2s;
        }
        .pedido-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .status-badge {
            font-size: 0.8em;
        }
        .status-pendente { background-color: #ffc107; }
        .status-confirmado { background-color: #17a2b8; }
        .status-enviado { background-color: #007bff; }
        .status-entregue { background-color: #28a745; }
        .status-cancelado { background-color: #dc3545; }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-book"></i> Livraria Online
            </a>
            <div class="navbar-nav ms-auto">
                <a class="nav-link" href="index.jsp">
                    <i class="fas fa-store"></i> Loja
                </a>
                <a class="nav-link" href="#" onclick="fazerLogout()">
                    <i class="fas fa-sign-out-alt"></i> Sair
                </a>
            </div>
        </div>
    </nav>

    <div class="container my-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-shopping-bag"></i> Meus Pedidos</h2>
                    <a href="index.jsp" class="btn btn-outline-primary">
                        <i class="fas fa-plus"></i> Fazer Novo Pedido
                    </a>
                </div>

                <!-- Alertas -->
                <div id="alert-container"></div>

                <!-- Loading -->
                <div id="loading" class="text-center py-5" style="display: none;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Carregando...</span>
                    </div>
                    <p class="mt-2">Carregando seus pedidos...</p>
                </div>

                <!-- Lista de Pedidos -->
                <div id="pedidos-container">
                    <!-- Pedidos serão carregados aqui -->
                </div>

                <!-- Sem Pedidos -->
                <div id="sem-pedidos" class="text-center py-5" style="display: none;">
                    <i class="fas fa-shopping-bag fa-4x text-muted"></i>
                    <h4 class="text-muted mt-3">Nenhum pedido encontrado</h4>
                    <p class="text-muted">Você ainda não fez nenhum pedido em nossa loja.</p>
                    <a href="index.jsp" class="btn btn-primary">
                        <i class="fas fa-shopping-cart"></i> Começar a Comprar
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Detalhes do Pedido -->
    <div class="modal fade" id="detalhesPedidoModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-receipt"></i> Detalhes do Pedido #<span id="modal-pedido-id"></span>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h6><i class="fas fa-info-circle"></i> Informações do Pedido</h6>
                            <table class="table table-sm">
                                <tr>
                                    <td><strong>Data:</strong></td>
                                    <td id="modal-data"></td>
                                </tr>
                                <tr>
                                    <td><strong>Status:</strong></td>
                                    <td><span id="modal-status" class="badge"></span></td>
                                </tr>
                                <tr>
                                    <td><strong>Total:</strong></td>
                                    <td><span id="modal-total" class="fw-bold text-success"></span></td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6">
                            <h6><i class="fas fa-truck"></i> Endereço de Entrega</h6>
                            <div id="modal-endereco" class="p-2 bg-light rounded">
                                <!-- Endereço será carregado aqui -->
                            </div>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <h6><i class="fas fa-list"></i> Itens do Pedido</h6>
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Livro</th>
                                    <th>Autor</th>
                                    <th>Quantidade</th>
                                    <th>Preço Unit.</th>
                                    <th>Subtotal</th>
                                </tr>
                            </thead>
                            <tbody id="modal-itens">
                                <!-- Itens serão carregados aqui -->
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Fechar</button>
                    <button type="button" class="btn btn-primary" onclick="imprimirPedido()">
                        <i class="fas fa-print"></i> Imprimir
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Inicialização
        document.addEventListener('DOMContentLoaded', function() {
            verificarLogin();
            carregarPedidos();
        });

        // Verificar se usuário está logado
        function verificarLogin() {
            fetch('login?action=status')
                .then(response => response.json())
                .then(data => {
                    if (!data.logado) {
                        mostrarAlerta('warning', 'Você precisa estar logado para ver seus pedidos.');
                        setTimeout(() => {
                            window.location.href = 'login.jsp';
                        }, 2000);
                    }
                })
                .catch(error => {
                    console.error('Erro ao verificar login:', error);
                    window.location.href = 'login.jsp';
                });
        }

        // Carregar pedidos do usuário
        function carregarPedidos() {
            mostrarLoading(true);
            
            fetch('compra?action=historico')
                .then(response => response.json())
                .then(data => {
                    if (data.erro) {
                        throw new Error(data.erro);
                    }
                    exibirPedidos(data);
                })
                .catch(error => {
                    console.error('Erro ao carregar pedidos:', error);
                    mostrarAlerta('danger', 'Erro ao carregar pedidos: ' + error.message);
                    document.getElementById('sem-pedidos').style.display = 'block';
                })
                .finally(() => {
                    mostrarLoading(false);
                });
        }

        // Exibir pedidos na tela
        function exibirPedidos(pedidos) {
            const container = document.getElementById('pedidos-container');
            const semPedidos = document.getElementById('sem-pedidos');
            
            if (!pedidos || pedidos.length === 0) {
                container.innerHTML = '';
                semPedidos.style.display = 'block';
                return;
            }
            
            semPedidos.style.display = 'none';
            
            const html = pedidos.map(pedido => {
                const data = new Date(pedido.dataPedido).toLocaleDateString('pt-BR');
                const statusClass = `status-${pedido.status}`;
                const statusText = formatarStatus(pedido.status);
                
                return `
                    <div class="card pedido-card mb-3">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-md-2">
                                    <h6 class="mb-1">Pedido #${pedido.id}</h6>
                                    <small class="text-muted">${data}</small>
                                </div>
                                <div class="col-md-2">
                                    <span class="badge ${statusClass} status-badge">${statusText}</span>
                                </div>
                                <div class="col-md-3">
                                    <div class="text-truncate" style="max-width: 200px;" title="${pedido.enderecoEntrega}">
                                        <i class="fas fa-map-marker-alt text-muted"></i>
                                        ${pedido.enderecoEntrega}
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <strong class="text-success">R$ ${formatarPreco(pedido.total)}</strong>
                                </div>
                                <div class="col-md-3 text-end">
                                    <button class="btn btn-sm btn-outline-primary" onclick="verDetalhes(${pedido.id})">
                                        <i class="fas fa-eye"></i> Ver Detalhes
                                    </button>
                                    ${pedido.status === 'pendente' ? `
                                    <button class="btn btn-sm btn-outline-danger ms-1" onclick="cancelarPedido(${pedido.id})">
                                        <i class="fas fa-times"></i> Cancelar
                                    </button>
                                    ` : ''}
                                </div>
                            </div>
                        </div>
                    </div>
                `;
            }).join('');
            
            container.innerHTML = html;
        }

        // Ver detalhes do pedido
        function verDetalhes(pedidoId) {
            fetch(`compra?action=detalhes&pedidoId=${pedidoId}`)
                .then(response => response.json())
                .then(data => {
                    if (data.erro) {
                        throw new Error(data.erro);
                    }
                    
                    preencherModalDetalhes(data.pedido, data.itens);
                    new bootstrap.Modal(document.getElementById('detalhesPedidoModal')).show();
                })
                .catch(error => {
                    console.error('Erro ao carregar detalhes:', error);
                    mostrarAlerta('danger', 'Erro ao carregar detalhes do pedido');
                });
        }

        // Preencher modal com detalhes
        function preencherModalDetalhes(pedido, itens) {
            document.getElementById('modal-pedido-id').textContent = pedido.id;
            document.getElementById('modal-data').textContent = new Date(pedido.dataPedido).toLocaleString('pt-BR');
            
            const statusBadge = document.getElementById('modal-status');
            statusBadge.textContent = formatarStatus(pedido.status);
            statusBadge.className = `badge status-${pedido.status}`;
            
            document.getElementById('modal-total').textContent = 'R$ ' + formatarPreco(pedido.total);
            document.getElementById('modal-endereco').textContent = pedido.enderecoEntrega;
            
            // Preencher itens
            const itensHtml = itens.map(item => `
                <tr>
                    <td>${item.tituloLivro}</td>
                    <td>${item.autorLivro}</td>
                    <td>${item.quantidade}</td>
                    <td>R$ ${formatarPreco(item.precoUnitario)}</td>
                    <td><strong>R$ ${formatarPreco(item.precoUnitario * item.quantidade)}</strong></td>
                </tr>
            `).join('');
            
            document.getElementById('modal-itens').innerHTML = itensHtml;
        }

        // Cancelar pedido
        function cancelarPedido(pedidoId) {
            if (!confirm('Tem certeza que deseja cancelar este pedido?')) {
                return;
            }
            
            // Implementar cancelamento (seria necessário criar endpoint no servlet)
            mostrarAlerta('info', 'Funcionalidade de cancelamento será implementada');
        }

        // Imprimir pedido
        function imprimirPedido() {
            window.print();
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
                    window.location.href = 'index.jsp';
                }
            })
            .catch(error => {
                console.error('Erro ao fazer logout:', error);
            });
        }

        // Funções auxiliares
        function mostrarLoading(mostrar) {
            document.getElementById('loading').style.display = mostrar ? 'block' : 'none';
        }

        function formatarStatus(status) {
            const statusMap = {
                'pendente': 'Pendente',
                'confirmado': 'Confirmado',
                'enviado': 'Enviado',
                'entregue': 'Entregue',
                'cancelado': 'Cancelado'
            };
            return statusMap[status] || status;
        }

        function formatarPreco(preco) {
            return parseFloat(preco).toFixed(2).replace('.', ',');
        }

        function mostrarAlerta(tipo, mensagem) {
            const container = document.getElementById('alert-container');
            const icone = tipo === 'success' ? 'fas fa-check-circle' : 
                         tipo === 'warning' ? 'fas fa-exclamation-triangle' : 
                         tipo === 'info' ? 'fas fa-info-circle' : 'fas fa-exclamation-circle';
            
            container.innerHTML = `
                <div class="alert alert-${tipo} alert-dismissible fade show">
                    <i class="${icone}"></i> ${mensagem}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
        }
    </script>
</body>
</html>