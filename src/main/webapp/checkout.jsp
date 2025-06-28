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
                
                <div class="checkout-page">
                    <!-- 1. Revisão do Pedido -->
                    <div class="checkout-section">
                        <h5>1. Revisão do Pedido</h5>
                        <div id="itens-container">
                            <!-- Itens serão carregados aqui -->
                        </div>
                    </div>
                    
                    <!-- 2. Informações de Entrega -->
                    <div class="checkout-section mt-4">
                        <h5>2. Informações de Entrega</h5>
                        <form id="form-entrega">
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
                            
                            <hr>
                            <h5>Opções de Frete</h5>
                            <div class="mb-3">
                                <label for="cep-frete" class="form-label">Calcular Frete para CEP</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" id="cep-frete" placeholder="00000-000">
                                    <button class="btn btn-outline-secondary" type="button" onclick="calcularFrete()">Calcular</button>
                                </div>
                                <div id="opcoes-frete" class="mt-2">
                                    <!-- Opções de frete serão carregadas aqui -->
                                </div>
                            </div>
                        </form>
                    </div>

                    <!-- 3. Método de Pagamento -->
                    <div class="checkout-section mt-4">
                        <h5>3. Método de Pagamento</h5>
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

                    <!-- 4. Revisar e Finalizar Pedido -->
                    <div class="checkout-section mt-4">
                        <h5>4. Revisar e Finalizar Pedido</h5>
                        <h6>Dados de Entrega:</h6>
                        <div id="resumo-entrega" class="p-3 bg-light rounded mb-3">
                            <!-- Dados de entrega serão exibidos aqui -->
                        </div>
                        <button class="btn btn-success btn-lg w-100" onclick="finalizarPedido()">
                            <i class="fas fa-check"></i> Finalizar Pedido
                        </button>
                    </div>
                </div>
            </div>

            <!-- Resumo Fixo Lateral -->
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
                        <div class="mb-3">
                            <label for="codigo-cupom" class="form-label">Cupom de Desconto</label>
                            <div class="input-group">
                                <input type="text" class="form-control" id="codigo-cupom" placeholder="Insira seu cupom">
                                <button class="btn btn-outline-secondary" type="button" onclick="aplicarCupom()">Aplicar</button>
                            </div>
                            <div id="desconto-cupom" class="d-flex justify-content-between mt-2" style="display: none;">
                                <!-- Desconto do cupom será exibido aqui -->
                            </div>
                        </div>
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
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let carrinho = [];
        let dadosEntrega = {};
        let cupomAplicado = null;
        let freteSelecionado = 0;

        // Inicialização
        document.addEventListener('DOMContentLoaded', function() {
            verificarLogin();
            carregarCarrinho();
            
            // Event listeners para pagamento
            document.querySelectorAll('input[name="pagamento"]').forEach(radio => {
                radio.addEventListener('change', calcularTotal);
            });

            // Event listener para o botão de finalizar pedido
            document.querySelector('#form-entrega').addEventListener('submit', function(e) {
                e.preventDefault(); // Impede o envio padrão do formulário
                if (validarDadosEntrega()) {
                    salvarDadosEntrega();
                    exibirResumoEntrega();
                    // A chamada para finalizarPedido() será feita pelo botão final
                }
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
            let subtotal = carrinho.reduce((sum, item) => sum + (item.preco * item.quantidade), 0);
            const metodoPagamento = document.querySelector('input[name="pagamento"]:checked')?.value;
            
            let total = subtotal;
            let descontoPix = 0;
            let descontoCupom = 0;

            // Desconto PIX
            if (metodoPagamento === 'pix') {
                descontoPix = subtotal * 0.05; // 5% de desconto
                total -= descontoPix;
                document.getElementById('desconto-pix').style.display = 'flex';
                document.getElementById('valor-desconto').textContent = '- R$ ' + formatarPreco(descontoPix);
            } else {
                document.getElementById('desconto-pix').style.display = 'none';
            }

            // Desconto Cupom
            if (cupomAplicado) {
                descontoCupom = calcularDesconto(cupomAplicado);
                total -= descontoCupom;
                document.getElementById('desconto-cupom').style.display = 'flex';
                document.getElementById('valor-desconto-cupom').textContent = '- R$ ' + formatarPreco(descontoCupom);
            } else {
                document.getElementById('desconto-cupom').style.display = 'none';
            }
            
            document.getElementById('subtotal').textContent = 'R$ ' + formatarPreco(subtotal);
            document.getElementById('frete').textContent = 'R$ ' + formatarPreco(freteSelecionado); // Atualiza o frete
            document.getElementById('total-final').textContent = 'R$ ' + formatarPreco(total + freteSelecionado); // Adiciona o frete ao total
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
            if (!validarDadosEntrega()) {
                return; // Impede a finalização se os dados de entrega não forem válidos
            }
            salvarDadosEntrega(); // Garante que os dados mais recentes estejam salvos
            exibirResumoEntrega(); // Atualiza o resumo de entrega

            const enderecoCompleto = `${dadosEntrega.nomeCompleto}, ${dadosEntrega.endereco}${dadosEntrega.complemento ? ', ' + dadosEntrega.complemento : ''}, ${dadosEntrega.cidade} - ${dadosEntrega.estado}, CEP: ${dadosEntrega.cep}`;
            
            const formData = new FormData();
            formData.append('action', 'finalizar');
            formData.append('carrinho', JSON.stringify(carrinho));
            formData.append('endereco', enderecoCompleto);
            if (cupomAplicado) {
                formData.append('cupomId', cupomAplicado.id);
            }

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

        // Validação de cupom em tempo real
        function aplicarCupom() {
            const codigo = document.getElementById('codigo-cupom').value.trim();
            
            if (!codigo) {
                mostrarAlerta('warning', 'Digite um código de cupom');
                return;
            }
            
            // mostrarLoading(true, 'validando-cupom'); // Se tiver função de loading
            
            fetch('cupom?action=validar&codigo=' + encodeURIComponent(codigo), {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.valido) {
                    cupomAplicado = data.cupom;
                    
                    // Mostrar desconto
                    const descontoElement = document.getElementById('desconto-cupom');
                    descontoElement.style.display = 'flex';
                    
                    if (data.cupom.tipo === 'percentual') {
                        descontoElement.innerHTML = `
                            <span class="text-success">
                                Desconto (${data.cupom.valor}%):
                            </span>
                            <span class="text-success" id="valor-desconto-cupom">
                                -R$ ${formatarPreco(calcularDesconto(data.cupom))}
                            </span>
                        `;
                    } else {
                        descontoElement.innerHTML = `
                            <span class="text-success">
                                Desconto:
                            </span>
                            <span class="text-success" id="valor-desconto-cupom">
                                -R$ ${formatarPreco(data.cupom.valor)}
                            </span>
                        `;
                    }
                    
                    // Atualizar total
                    calcularTotal();
                    
                    // Feedback visual
                    document.getElementById('codigo-cupom').classList.remove('is-invalid');
                    document.getElementById('codigo-cupom').classList.add('is-valid');
                    mostrarAlerta('success', 'Cupom aplicado com sucesso!');
                    
                } else {
                    cupomAplicado = null;
                    document.getElementById('desconto-cupom').style.display = 'none';
                    document.getElementById('codigo-cupom').classList.remove('is-valid');
                    document.getElementById('codigo-cupom').classList.add('is-invalid');
                    mostrarAlerta('danger', data.mensagem || 'Cupom inválido');
                    calcularTotal(); // Recalcular total sem cupom
                }
            })
            .catch(error => {
                console.error('Erro ao validar cupom:', error);
                mostrarAlerta('danger', 'Erro ao validar cupom. Tente novamente.');
            })
            .finally(() => {
                // mostrarLoading(false, 'validando-cupom'); // Se tiver função de loading
            });
        }

        function calcularDesconto(cupom) {
            const subtotal = carrinho.reduce((sum, item) => sum + (item.preco * item.quantidade), 0);
            if (cupom.tipo === 'percentual') {
                return subtotal * (cupom.valor / 100);
            } else {
                return cupom.valor;
            }
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

        let freteSelecionado = 0; // Variável para armazenar o valor do frete

        // Função para calcular frete (simulada)
        function calcularFrete() {
            const cep = document.getElementById('cep-frete').value.trim();
            if (cep.length < 8) {
                mostrarAlerta('warning', 'CEP inválido. Digite pelo menos 8 dígitos.');
                return;
            }

            // Simular cálculo de frete
            const opcoesFrete = [
                { tipo: 'Econômico', prazo: '7-10 dias', valor: 12.90 },
                { tipo: 'Expresso', prazo: '3-5 dias', valor: 24.90 },
                { tipo: 'Premium', prazo: '1-2 dias', valor: 39.90 }
            ];

            const opcoesContainer = document.getElementById('opcoes-frete');
            opcoesContainer.innerHTML = ''; // Limpar opções anteriores

            opcoesFrete.forEach((opcao, index) => {
                const radioHtml = `
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="opcaoFrete" id="frete-${index}" value="${opcao.valor}" 
                               onclick="selecionarFrete(${opcao.valor})">
                        <label class="form-check-label" for="frete-${index}">
                            ${opcao.tipo} (${opcao.prazo}) - R$ ${formatarPreco(opcao.valor)}
                        </label>
                    </div>
                `;
                opcoesContainer.innerHTML += radioHtml;
            });
            mostrarAlerta('info', 'Opções de frete carregadas.');
        }

        function selecionarFrete(valor) {
            freteSelecionado = valor;
            document.getElementById('frete').textContent = 'R$ ' + formatarPreco(freteSelecionado);
            calcularTotal();
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