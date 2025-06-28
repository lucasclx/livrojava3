// Variáveis globais
let livroEditando = null;

// Inicialização
document.addEventListener('DOMContentLoaded', function() {
    carregarLivros();
    
    // Event listener para o formulário de livro
    document.getElementById('formLivro').addEventListener('submit', function(e) {
        e.preventDefault();
        salvarLivro();
    });
});

// Função para carregar livros
function carregarLivros() {
    fetch('../livros?action=listar')
        .then(response => response.json())
        .then(livros => {
            if (livros.erro) {
                throw new Error(livros.erro);
            }
            exibirLivrosTabela(livros);
        })
        .catch(error => {
            console.error('Erro ao carregar livros:', error);
            mostrarAlerta('erro', 'Erro ao carregar livros: ' + error.message);
        });
}

// Função para exibir livros na tabela
function exibirLivrosTabela(livros) {
    const tbody = document.getElementById('livrosTableBody');
    
    if (!livros || livros.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center">Nenhum livro cadastrado</td></tr>';
        return;
    }
    
    const html = livros.map(livro => `
        <tr>
            <td>${livro.id}</td>
            <td>${livro.titulo}</td>
            <td>${livro.autor}</td>
            <td><span class="badge bg-secondary">${livro.categoria}</span></td>
            <td>R$ ${formatarPreco(livro.preco)}</td>
            <td>
                <span class="badge ${livro.estoque > 10 ? 'bg-success' : livro.estoque > 0 ? 'bg-warning' : 'bg-danger'}">
                    ${livro.estoque} unidades
                </span>
            </td>
            <td>
                <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" onclick="editarLivro(${livro.id})" title="Editar">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-outline-danger" onclick="excluirLivro(${livro.id})" title="Excluir">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
    
    tbody.innerHTML = html;
}

// Função para abrir modal de novo livro
function abrirModalLivro() {
    livroEditando = null;
    document.getElementById('livroModalTitle').textContent = 'Novo Livro';
    document.getElementById('formLivro').reset();
    document.getElementById('livroId').value = '';
    
    new bootstrap.Modal(document.getElementById('livroModal')).show();
}

// Função para editar livro
function editarLivro(livroId) {
    fetch(`../livros?action=detalhes&id=${livroId}`)
        .then(response => response.json())
        .then(livro => {
            if (livro.erro) {
                throw new Error(livro.erro);
            }
            
            livroEditando = livro;
            document.getElementById('livroModalTitle').textContent = 'Editar Livro';
            
            // Preencher o formulário
            document.getElementById('livroId').value = livro.id;
            document.getElementById('titulo').value = livro.titulo;
            document.getElementById('autor').value = livro.autor;
            document.getElementById('isbn').value = livro.isbn || '';
            document.getElementById('preco').value = livro.preco;
            document.getElementById('estoque').value = livro.estoque;
            document.getElementById('categoria').value = livro.categoria;
            document.getElementById('imagem').value = livro.imagem || '';
            document.getElementById('descricao').value = livro.descricao || '';
            
            new bootstrap.Modal(document.getElementById('livroModal')).show();
        })
        .catch(error => {
            console.error('Erro ao carregar livro:', error);
            mostrarAlerta('erro', 'Erro ao carregar dados do livro');
        });
}

// Função para salvar livro (criar ou atualizar)
function salvarLivro() {
    const formData = new FormData(document.getElementById('formLivro'));
    const livroId = document.getElementById('livroId').value;
    
    // Converter FormData para objeto
    const livro = {};
    for (let [key, value] of formData.entries()) {
        livro[key] = value;
    }
    
    // Determinar se é criação ou atualização
    const isEdicao = livroId && livroId !== '';
    const url = isEdicao ? '../admin/livros?action=atualizar' : '../admin/livros?action=criar';
    const method = 'POST';
    
    fetch(url, {
        method: method,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(livro)
    })
    .then(response => response.json())
    .then(data => {
        if (data.erro) {
            throw new Error(data.erro);
        }
        
        mostrarAlerta('sucesso', isEdicao ? 'Livro atualizado com sucesso!' : 'Livro cadastrado com sucesso!');
        bootstrap.Modal.getInstance(document.getElementById('livroModal')).hide();
        carregarLivros(); // Recarregar a lista
    })
    .catch(error => {
        console.error('Erro ao salvar livro:', error);
        mostrarAlerta('erro', 'Erro ao salvar livro: ' + error.message);
    });
}

// Função para excluir livro
function excluirLivro(livroId) {
    if (!confirm('Tem certeza que deseja excluir este livro?')) {
        return;
    }
    
    fetch(`../admin/livros?action=excluir&id=${livroId}`, {
        method: 'DELETE'
    })
    .then(response => response.json())
    .then(data => {
        if (data.erro) {
            throw new Error(data.erro);
        }
        
        mostrarAlerta('sucesso', 'Livro excluído com sucesso!');
        carregarLivros(); // Recarregar a lista
    })
    .catch(error => {
        console.error('Erro ao excluir livro:', error);
        mostrarAlerta('erro', 'Erro ao excluir livro: ' + error.message);
    });
}

// Função para formatar preço
function formatarPreco(preco) {
    return parseFloat(preco).toFixed(2).replace('.', ',');
}

// Função para mostrar alertas
function mostrarAlerta(tipo, mensagem) {
    // Remove alertas existentes
    const alertasExistentes = document.querySelectorAll('.alert-custom');
    alertasExistentes.forEach(alerta => alerta.remove());
    
    const tipoClass = tipo === 'sucesso' ? 'alert-success' : 'alert-danger';
    const icone = tipo === 'sucesso' ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle';
    
    const alerta = document.createElement('div');
    alerta.className = `alert ${tipoClass} alert-dismissible fade show alert-custom`;
    alerta.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    alerta.innerHTML = `
        <i class="${icone}"></i> ${mensagem}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alerta);
    
    // Auto-remover após 5 segundos
    setTimeout(() => {
        if (alerta.parentNode) {
            alerta.remove();
        }
    }, 5000);
}

// Função para logout
function logout() {
    if (confirm('Deseja realmente sair do painel administrativo?')) {
        window.location.href = '../index.jsp';
    }
}

// Função para buscar livros (pode ser implementada posteriormente)
function buscarLivros() {
    // Implementar busca no painel admin se necessário
}