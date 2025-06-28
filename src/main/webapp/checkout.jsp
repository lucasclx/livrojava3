<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Finalizar Compra - Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .checkout-step {
            border-left: 3px solid #dee2e6;
            padding-left: 20px;
            margin-bottom: 30px;
        }
        .checkout-step.active {
            border-left-color: #007bff;
        }
        .checkout-step.completed {
            border-left-color: #28a745;
        }
        .item-resumo {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
        }
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
                    <i class="fas fa-arrow-left"></i> Voltar à Loja
                </a>
            </div>
        </div>
    </nav>

    <div class="container my-4">
        <div class="row">
            <div class="col-md-8">
                <h2><i class="fas fa-shopping-cart"></i> Finalizar Compra</h2>
                
                <!-- Alertas -->
                <div id="alert-container"></div>
                
                <!-- Etapa 1: Revisão do Pedido -->
                <div class="checkout-step active" id="step-1">
                    <h4><i class="fas fa-list"></i> 1. Revisão do Pedido</h4>
                    <div id="itens-container">
                        <!-- Itens serão carregados aqui -->
                    </div>
                    <button class="btn btn-primary" onclick="proximaEtapa(1)">
                        Continuar <i class="fas fa-arrow-right"></i>
                    </button>
                </div>

                <!-- Etapa 2: Dados de Entrega -->
                <div class="checkout-step" id="step-2" style="display: none;">
                    <h4><i class="fas fa-truck"></i> 2. Dados de Entrega</h4>
                    <form id="formEntrega">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="mb-3">
                                    <label for="nomeCompleto" class="form-label">Nome Completo</label>
                                    <input type="text" class="form-control" id="nomeCompleto" required>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-8">
                                <div class="mb-3">
                                    <label for="endereco" class="form-label">Endereço</label>
                                    <input type="text" class="form-control" id="endereco" placeholder="Rua, número" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label for="cep" class="form-label">CEP</label>
                                    <input type="text" class="form-control" id="cep" placeholder="00000-000" required>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label for="cidade" class="form-label">Cidade</label>
                                    <input type="text" class="form-control" id="cidade" required>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="mb-3">
                                    <label for="estado" class="form-label">Estado</label>
                                    <select class="form-control" id="estado" required>
                                        <option value="">Selecione...</option>
                                        <option value="AC">Acre</option>
                                        <option value="AL">Alagoas</option>
                                        <option value="AP">Amapá</option>
                                        <option value="AM">Amazonas</option>
                                        <option value="BA">Bahia</option>
                                        <option value="CE">Ceará</option>
                                        <option value="DF">Distrito Federal</option>
                                        <option value="ES">Espírito Santo</option>
                                        <option value="GO">Goiás</option>
                                        <option value="MA">Maranhão</option>
                                        <option value="MT">Mato Grosso</option>
                                        <option value="MS">Mato Grosso do Sul</option>
                                        <option value="MG">Minas Gerais</option>
                                        <option value="PA">Pará</option>
                                        <option value="PB">Paraíba</option>
                                        <option value="PR">Paraná</option>
                                        <option value="PE">Pernambuco</option>
                                        <option value="PI">Piauí</option>
                                        <option value="RJ">Rio de Janeiro</option>
                                        <option value="RN">Rio Grande do Norte</option>
                                        <option value="RS">Rio Grande do Sul</option>
                                        <option value="RO">Rondônia</option>
                                        <option value="RR">Roraima</option>
                                        <option value="SC">Santa Catarina</option>
                                        <option value="SP">São Paulo</option>
                                        <option value="SE">Sergipe</option>
                                        <option value="TO">Tocantins</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="mb-3">
                                    <label for="complemento" class="form-label">Complemento</label>
                                    <input type="text" class="form-control" id="complemento" placeholder="Apto, bloco...">
                                </div>
                            </div>
                        </div>
                    </form>
                    <div class="d-flex justify-content-between">
                        <button class="btn btn-secondary" onclick="etapaAnterior(2)">
                            <i class="fas fa-arrow-left"></i> Voltar
                        </button>
                        <button class="btn btn-primary" onclick="proximaEtapa(2)">
                            Continuar <i class="fas fa-arrow-right"></i>
                        </button>
                    </div>
                </div>

                <!-- Etapa 3: Confirmação e Pagamento -->
                <div class="checkout-step" id="step-3" style="display: none;">
                    <h4><i class="fas fa-credit-card"></i> 3. Confirmação e Pagamento</h4>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <h6>Dados de Entrega:</h6>
                            <div id="resumo-entrega" class="p-3 bg-light rounded">
                                <!-- Dados de entrega serão exibidos aqui -->
                            </div>
                        </div>
                        <div class="col-md-6">
                            <h6>Método de Pagamento:</h6>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="pagamento" id="pix" value="pix" checked>
                                <label class="form-check-label" for="pix">
                                    <i class="fas fa-qrcode"></i> PIX (Desconto de 5%)
                                </label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="pagamento" id="cartao" value="cartao">
                                <label class="form-check-label" for="cartao">
                                    <i class="fas fa-credit-card"></i> Cartão de Crédito
                                </label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="pagamento" id="boleto" value="boleto">
                                <label class="form-check-label" for="boleto">
                                    <i class="fas fa-barcode"></i> Boleto Bancário
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between mt-4">
                        <button class="btn btn-secondary" onclick="etapaAnterior(3)">
                            <i class="fas fa-arrow-left"></i> Voltar
                        </button>
                        <button class="btn btn-success btn-lg" onclick="finalizarPedido()">
                            <i class="fas fa-check"></i> Finalizar Pedido
                        </button>
                    </div>
                </div>
            </div>

            <!-- Resumo do Pedido -->
            <div class="col-md-4">
                <div class="card sticky-top">
                    <div class="card-header">
                        <h5><i class="fas fa-receipt"></i> Resumo do Pedido</h5>
                    </div>
                    <div class="card-body">
                        <div id="resumo-itens">
                            <!-- Resumo dos itens -->
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between">
                            <span>Subtotal:</span>
                            <span id="subtotal">R$ 0,00</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span>Frete:</span>
                            <span id="frete">Grátis</span>
                        </div>
                        <div class="d-flex justify-content-between" id="desconto-pix" style="display: none;">
                            <span class="text-success">Desconto PIX (5%):</span>
                            <span class="text-success" id="valor-desconto">- R$ 0,00</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold">
                            <span>Total:</span>
                            <span id="total-final">R$ 0,00</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Sucesso -->
    <div class="modal fade" id="sucessoModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-check-circle"></i> Pedido Realizado com Sucesso!
                    </h5>
                </div>
                <div class="modal-body text-center">
                    <i class="fas fa-check-circle fa-4x text-success mb-3"></i>
                    <h4>Obrigado pela sua compra!</h4>
                    <p>Seu pedido #<span id="numero-pedido"></span> foi realizado com sucesso.</p>
                    <p>Você receberá um email com os detalhes da compra e informações de entrega.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="voltarLoja()">
                        Continuar Comprando
                    </button>
                    <button type="button" class="btn btn-primary" onclick="verPedidos()">
                        Ver Meus Pedidos
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let carrinho = [];
        let etapaAtual = 1;
        let dadosEntrega = {};

        // Inicialização
        document.addEventListener('DOMContentLoaded', function() {
            verificarLogin();
            carregarCarrinho();
            
            // Event listeners para pagamento
            document.querySelectorAll('input[name="pagamento"]').forEach(radio => {
                radio.addEventListener('change', calcularTotal);
            });
        });

        // Verificar se usuário está logado
        function verificarLogin() {
            fetch('login?action=status')
                .then(response => response.json())
                .then(data => {
                    if (!data.logado) {
                        mostrarAlerta('warning', 'Você precisa estar logado para finalizar a compra.');
                        setTimeout(() => {
                            window.location.href = 'login.jsp';
                        }, 2000);
                        return;
                    }
                    
                    // Preencher nome se disponível
                    if (data.usuario && data.usuario.nome) {
                        document.getElementById('nomeCompleto').value = data.usuario.nome;
                    }
                })
                .catch(error => {
                    console.error('Erro ao verificar login:', error);
                });
        }

        // Carregar carrinho do localStorage
        function carregarCarrinho() {
            const carrinhoSalvo = localStorage.getItem('carrinho');
            if (carrinhoSalvo) {
                carrinho = JSON.parse(carrinhoSalvo);
            }
            
            if (carrinho.length === 0) {
                mostrarAlerta('warning', 'Seu carrinho está vazio.');
                setTimeout(() => {
                    window.location.href = 'index.jsp';
                }, 2000);
                return;
            }
            
            exibirItens();
            calcularTotal();
        }

        // Exibir itens do carrinho
        function exibirItens() {
            const container = document.getElementById('itens-container');
            const resumoContainer = document.getElementById('resumo-itens');
            
            let htmlItens = '';
            let htmlResumo = '';
            
            carrinho.forEach(item => {
                const subtotal = item.preco * item.quantidade;
                
                htmlItens += `
                    <div class="item-resumo">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <h6 class="mb-1">${item.titulo}</h6>
                                <small class="text-muted">por ${item.autor}</small>
                            </div>
                            <div class="col-md-2 text-center">
                                <span class="badge bg-secondary">${item.quantidade}x</span>
                            </div>
                            <div class="col-md-2 text-end">
                                <strong>R$ ${formatarPreco(subtotal)}</strong>
                            </div>
                        </div>
                    </div>
                `;
                
                htmlResumo += `
                    <div class="d-flex justify-content-between mb-1">
                        <small>${item.titulo} (${item.quantidade}x)</small>
                        <small>R$ ${formatarPreco(subtotal)}</small>
                    </div>
                `;
            });
            
            container.innerHTML = htmlItens;
            resumoContainer.innerHTML = htmlResumo;
        }

        // Calcular total
        function calcularTotal() {
            const subtotal = carrinho.reduce((sum, item) => sum + (item.preco * item.quantidade), 0);
            const metodoPagamento = document.querySelector('input[name="pagamento"]:checked')?.value;
            
            let total = subtotal;
            let desconto = 0;
            
            if (metodoPagamento === 'pix') {
                desconto = subtotal * 0.05; // 5% de desconto
                total = subtotal - desconto;
                document.getElementById('desconto-pix').style.display = 'flex';
                document.getElementById('valor-desconto').textContent = '- R$ ' + formatarPreco(desconto);
            } else {
                document.getElementById('desconto-pix').style.display = 'none';
            }
            
            document.getElementById('subtotal').textContent = 'R$ ' + formatarPreco(subtotal);
            document.getElementById('total-final').textContent = 'R$ ' + formatarPreco(total);
        }

        // Navegar entre etapas
        function proximaEtapa(etapa) {
            if (etapa === 1) {
                mostrarEtapa(2);
            } else if (etapa === 2) {
                if (validarDadosEntrega()) {
                    salvarDadosEntrega();
                    exibirResumoEntrega();
                    mostrarEtapa(3);
                }
            }
        }

        function etapaAnterior(etapa) {
            if (etapa === 2) {
                mostrarEtapa(1);
            } else if (etapa === 3) {
                mostrarEtapa(2);
            }
        }

        function mostrarEtapa(numero) {
            // Ocultar todas as etapas
            for (let i = 1; i <= 3; i++) {
                const step = document.getElementById(`step-${i}`);
                step.style.display = 'none';
                step.classList.remove('active');
                
                if (i < numero) {
                    step.classList.add('completed');
                }
            }
            
            // Mostrar etapa atual
            const stepAtual = document.getElementById(`step-${numero}`);
            stepAtual.style.display = 'block';
            stepAtual.classList.add('active');
            
            etapaAtual = numero;
        }

        // Validar dados de entrega
        function validarDadosEntrega() {
            const campos = ['nomeCompleto', 'endereco', 'cep', 'cidade', 'estado'];
            
            for (let campo of campos) {
                const elemento = document.getElementById(campo);
                if (!elemento.value.trim()) {
                    mostrarAlerta('danger', `O campo ${elemento.previousElementSibling.textContent} é obrigatório.`);
                    elemento.focus();
                    return false;
                }
            }
            
            return true;
        }

        // Salvar dados de entrega
        function salvarDadosEntrega() {
            dadosEntrega = {
                nomeCompleto: document.getElementById('nomeCompleto').value.trim(),
                endereco: document.getElementById('endereco').value.trim(),
                cep: document.getElementById('cep').value.trim(),
                cidade: document.getElementById('cidade').value.trim(),
                estado: document.getElementById('estado').value,
                complemento: document.getElementById('complemento').value.trim()
            };
        }

        // Exibir resumo de entrega
        function exibirResumoEntrega() {
            const enderecoCompleto = `
                ${dadosEntrega.endereco}${dadosEntrega.complemento ? ', ' + dadosEntrega.complemento : ''}<br>
                ${dadosEntrega.cidade} - ${dadosEntrega.estado}<br>
                CEP: ${dadosEntrega.cep}
            `;
            
            document.getElementById('resumo-entrega').innerHTML = `
                <strong>${dadosEntrega.nomeCompleto}</strong><br>
                ${enderecoCompleto}
            `;
        }

        // Finalizar pedido
        function finalizarPedido() {
            const enderecoCompleto = `${dadosEntrega.nomeCompleto}, ${dadosEntrega.endereco}${dadosEntrega.complemento ? ', ' + dadosEntrega.complemento : ''}, ${dadosEntrega.cidade} - ${dadosEntrega.estado}, CEP: ${dadosEntrega.cep}`;
            
            const formData = new FormData();
            formData.append('action', 'finalizar');
            formData.append('carrinho', JSON.stringify(carrinho));
            formData.append('endereco', enderecoCompleto);

            fetch('compra', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.erro) {
                    mostrarAlerta('danger', data.erro);
                } else {
                    document.getElementById('numero-pedido').textContent = data.pedidoId;
                    localStorage.removeItem('carrinho'); // Limpar carrinho
                    new bootstrap.Modal(document.getElementById('sucessoModal')).show();
                }
            })
            .catch(error => {
                console.error('Erro:', error);
                mostrarAlerta('danger', 'Erro ao processar pedido. Tente novamente.');
            });
        }

        // Funções auxiliares
        function formatarPreco(preco) {
            return parseFloat(preco).toFixed(2).replace('.', ',');
        }

        function mostrarAlerta(tipo, mensagem) {
            const container = document.getElementById('alert-container');
            const icone = tipo === 'success' ? 'fas fa-check-circle' : 
                         tipo === 'warning' ? 'fas fa-exclamation-triangle' : 'fas fa-exclamation-circle';
            
            container.innerHTML = `
                <div class="alert alert-${tipo} alert-dismissible fade show">
                    <i class="${icone}"></i> ${mensagem}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
            
            // Scroll para o topo
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        function voltarLoja() {
            window.location.href = 'index.jsp';
        }

        function verPedidos() {
            // Implementar página de pedidos do usuário
            alert('Página de pedidos será implementada');
        }
    </script>
</body>
</html>