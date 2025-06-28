-- Script para atualizar imagens dos livros
UPDATE livros SET imagem = 'images/dom-casmurro.svg' WHERE titulo = 'Dom Casmurro';
UPDATE livros SET imagem = 'images/1984.svg' WHERE titulo = '1984';
UPDATE livros SET imagem = 'images/clean-code.svg' WHERE titulo = 'Clean Code';
UPDATE livros SET imagem = 'images/pequeno-principe.svg' WHERE titulo = 'O Pequeno Príncipe';

-- Para todos os outros livros sem imagem, usar a imagem padrão
UPDATE livros SET imagem = 'images/no-image.svg' 
WHERE imagem IS NULL OR imagem = '' OR imagem LIKE '%/no-image.jpg%';
