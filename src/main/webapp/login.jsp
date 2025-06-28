<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Livraria Online</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .login-container {
            max-width: 400px;
            margin: 50px auto;
        }
        .card {
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .btn-toggle {
            background: none;
            border: none;
            color: #007bff;
            text-decoration: underline;
        }
    </style>
</head>
<body class="bg-light">
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-book"></i> Livraria Online
            </a>
        </div>
    </nav>

    <div class="container">
        <div class="login-container">
            <div class="card">
                <div class="card-header text-center">
                    <h4 id="form-title"><i class="fas fa-sign-in-alt"></i> Entrar</h4>
                </div>
                <div class="card-body">
                    <!-- Alertas -->
                    <div id="alert-container"></div>
                    
                    <!-- Formulário de Login -->
                    <form id="loginForm" style="display: block;">
                        <div class="mb-3">
                            <label for="loginEmail" class="form-label">Email</label>
                            <input type="email" class="form-control" id="loginEmail" required>
                        </div>
                        <div class="mb-3">
                            <label for="loginSenha" class="form-label">Senha</label>
                            <input type="password" class="form-control" id="loginSenha" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-sign-in-alt"></i> Entrar
                        </button>
                    </form>

                    <!-- Formulário de Registro -->
                    <form id="registroForm" style="display: none;">
                        <div class="mb-3">
                            <label for="registroNome" class="form-label">Nome Completo</label>
                            <input type="text" class="form-control" id="registroNome" required>
                        </div>
                        <div class="mb-3">
                            <label for="registroEmail" class="form-label">Email</label>
                            <input type="email" class="form-control" id="registroEmail" required>
                        </div>
                        <div class="mb-3">
                            <label for="registroSenha" class="form-label">Senha</label>
                            <input type="password" class="form-control" id="registroSenha" minlength="6" required>
                            <div class="form-text">Mínimo 6 caracteres</div>
                        </div>
                        <div class="mb-3">
                            <label for="confirmarSenha" class="form-label">Confirmar Senha</label>
                            <input type="password" class="form-control" id="confirmarSenha" required>
                        </div>
                        <button type="submit" class="btn btn-success w-100">
                            <i class="fas fa-user-plus"></i> Cadastrar
                        </button>
                    </form>
                </div>
                <div class="card-footer text-center">
                    <p id="toggle-text">
                        Não tem conta? 
                        <button type="button" class="btn-toggle" onclick="toggleForm()">
                            Cadastre-se aqui
                        </button>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let isLoginMode = true;

        // Event listeners
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            fazerLogin();
        });

        document.getElementById('registroForm').addEventListener('submit', function(e) {
            e.preventDefault();
            registrarUsuario();
        });

        // Alternar entre login e registro
        function toggleForm() {
            const loginForm = document.getElementById('loginForm');
            const registroForm = document.getElementById('registroForm');
            const formTitle = document.getElementById('form-title');
            const toggleText = document.getElementById('toggle-text');

            if (isLoginMode) {
                // Mostrar formulário de registro
                loginForm.style.display = 'none';
                registroForm.style.display = 'block';
                formTitle.innerHTML = '<i class="fas fa-user-plus"></i> Cadastrar';
                toggleText.innerHTML = `
                    Já tem conta? 
                    <button type="button" class="btn-toggle" onclick="toggleForm()">
                        Fazer login
                    </button>
                `;
                isLoginMode = false;
            } else {
                // Mostrar formulário de login
                loginForm.style.display = 'block';
                registroForm.style.display = 'none';
                formTitle.innerHTML = '<i class="fas fa-sign-in-alt"></i> Entrar';
                toggleText.innerHTML = `
                    Não tem conta? 
                    <button type="button" class="btn-toggle" onclick="toggleForm()">
                        Cadastre-se aqui
                    </button>
                `;
                isLoginMode = true;
            }
            
            limparAlertas();
        }

        // Fazer login
        function fazerLogin() {
            const email = document.getElementById('loginEmail').value;
            const senha = document.getElementById('loginSenha').value;

            const formData = new FormData();
            formData.append('action', 'login');
            formData.append('email', email);
            formData.append('senha', senha);

            fetch('login', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.erro) {
                    mostrarAlerta('danger', data.erro);
                } else {
                    mostrarAlerta('success', data.mensagem);
                    setTimeout(() => {
                        window.location.href = data.redirecionamento || 'index.jsp';
                    }, 1500);
                }
            })
            .catch(error => {
                console.error('Erro:', error);
                mostrarAlerta('danger', 'Erro ao fazer login. Tente novamente.');
            });
        }

        // Registrar usuário
        function registrarUsuario() {
            const nome = document.getElementById('registroNome').value;
            const email = document.getElementById('registroEmail').value;
            const senha = document.getElementById('registroSenha').value;
            const confirmarSenha = document.getElementById('confirmarSenha').value;

            if (senha !== confirmarSenha) {
                mostrarAlerta('danger', 'As senhas não conferem');
                return;
            }

            const formData = new FormData();
            formData.append('action', 'registrar');
            formData.append('nome', nome);
            formData.append('email', email);
            formData.append('senha', senha);
            formData.append('confirmarSenha', confirmarSenha);

            fetch('login', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.erro) {
                    mostrarAlerta('danger', data.erro);
                } else {
                    mostrarAlerta('success', data.mensagem);
                    setTimeout(() => {
                        toggleForm(); // Voltar para o formulário de login
                    }, 2000);
                }
            })
            .catch(error => {
                console.error('Erro:', error);
                mostrarAlerta('danger', 'Erro ao cadastrar usuário. Tente novamente.');
            });
        }

        // Mostrar alerta
        function mostrarAlerta(tipo, mensagem) {
            const container = document.getElementById('alert-container');
            const icone = tipo === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle';
            
            container.innerHTML = `
                <div class="alert alert-${tipo} alert-dismissible fade show">
                    <i class="${icone}"></i> ${mensagem}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
        }

        // Limpar alertas
        function limparAlertas() {
            document.getElementById('alert-container').innerHTML = '';
        }

        // Verificar se já está logado
        fetch('login?action=status')
            .then(response => response.json())
            .then(data => {
                if (data.logado) {
                    const redirecionamento = data.usuario.tipo === 'admin' ? 'admin/admin.jsp' : 'index.jsp';
                    window.location.href = redirecionamento;
                }
            })
            .catch(error => {
                console.error('Erro ao verificar status:', error);
            });
    </script>
</body>
</html>