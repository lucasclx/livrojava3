-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS livraria;
USE livraria;

-- Tabela de livros
CREATE TABLE livros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    categoria VARCHAR(100) NOT NULL,
    descricao TEXT,
    imagem VARCHAR(500),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_titulo (titulo),
    INDEX idx_autor (autor),
    INDEX idx_categoria (categoria)
);

-- Tabela de usuários
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo ENUM('cliente', 'admin') DEFAULT 'cliente',
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de pedidos
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    total DECIMAL(10,2) NOT NULL,
    status ENUM('pendente', 'confirmado', 'enviado', 'entregue', 'cancelado') DEFAULT 'pendente',
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    endereco_entrega TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabela de itens do pedido
CREATE TABLE itens_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    livro_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (livro_id) REFERENCES livros(id)
);

-- Inserção de dados de exemplo
INSERT INTO livros (titulo, autor, isbn, preco, estoque, categoria, descricao, imagem) VALUES
('Dom Casmurro', 'Machado de Assis', '978-85-00-00001-1', 25.90, 50, 'Romance', 'Clássico da literatura brasileira que narra a história de Bentinho e Capitu.', 'images/dom-casmurro.jpg'),
('1984', 'George Orwell', '978-85-00-00002-2', 32.50, 30, 'Ficção', 'Distopia clássica sobre um futuro totalitário.', 'images/1984.jpg'),
('Clean Code', 'Robert C. Martin', '978-85-00-00003-3', 89.90, 25, 'Técnico', 'Manual sobre como escrever código limpo e sustentável.', 'images/clean-code.jpg'),
('O Pequeno Príncipe', 'Antoine de Saint-Exupéry', '978-85-00-00004-4', 19.90, 100, 'Ficção', 'História atemporal sobre amizade e descobertas.', 'images/pequeno-principe.jpg'),
('Steve Jobs', 'Walter Isaacson', '978-85-00-00005-5', 45.00, 20, 'Biografia', 'A biografia definitiva do fundador da Apple.', 'images/steve-jobs.jpg'),
('O Alquimista', 'Paulo Coelho', '978-85-00-00006-6', 28.90, 80, 'Romance', 'Jornada de autodescoberta de um jovem pastor.', 'images/alquimista.jpg'),
('Design Patterns', 'Gang of Four', '978-85-00-00007-7', 120.00, 15, 'Técnico', 'Padrões de design orientados a objetos reutilizáveis.', 'images/design-patterns.jpg'),
('Harry Potter e a Pedra Filosofal', 'J.K. Rowling', '978-85-00-00008-8', 35.90, 60, 'Ficção', 'O primeiro livro da série mágica mais famosa do mundo.', 'images/harry-potter-1.jpg'),
('Sapiens', 'Yuval Noah Harari', '978-85-00-00009-9', 42.90, 40, 'História', 'Uma breve história da humanidade.', 'images/sapiens.jpg'),
('O Hobbit', 'J.R.R. Tolkien', '978-85-00-00010-0', 39.90, 35, 'Ficção', 'A jornada de Bilbo Bolseiro na Terra Média.', 'images/hobbit.jpg');

-- Inserção de usuário administrador (senha: admin123)
INSERT INTO usuarios (nome, email, senha, tipo) VALUES
('Administrador', 'admin@livraria.com', 'admin123', 'admin'),
('Cliente Teste', 'cliente@teste.com', '123456', 'cliente');

-- Exemplo de pedido
INSERT INTO pedidos (usuario_id, total, endereco_entrega) VALUES
(2, 58.40, 'Rua das Flores, 123 - São Paulo, SP');

INSERT INTO itens_pedido (pedido_id, livro_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 25.90),
(1, 4, 1, 19.90),
(1, 6, 1, 28.90);

-- Views úteis
CREATE VIEW vw_livros_categoria AS
SELECT categoria, COUNT(*) as total_livros, AVG(preco) as preco_medio
FROM livros
GROUP BY categoria;

CREATE VIEW vw_pedidos_detalhados AS
SELECT 
    p.id as pedido_id,
    u.nome as cliente,
    p.total,
    p.status,
    p.data_pedido,
    COUNT(ip.id) as total_itens
FROM pedidos p
JOIN usuarios u ON p.usuario_id = u.id
LEFT JOIN itens_pedido ip ON p.id = ip.pedido_id
GROUP BY p.id, u.nome, p.total, p.status, p.data_pedido;