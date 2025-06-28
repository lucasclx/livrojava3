-- Script para configurar o banco de dados
-- Execute este script no MySQL

-- Criar banco se não existir
CREATE DATABASE IF NOT EXISTS livraria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE livraria;

-- Verificar se as tabelas já existem
SELECT 'Verificando estrutura do banco...' as status;

-- Verificar tabela usuarios
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabela usuarios existe'
        ELSE 'Tabela usuarios não encontrada'
    END as resultado
FROM information_schema.tables 
WHERE table_schema = 'livraria' 
AND table_name = 'usuarios';

-- Verificar tabela livros
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabela livros existe'
        ELSE 'Tabela livros não encontrada'
    END as resultado
FROM information_schema.tables 
WHERE table_schema = 'livraria' 
AND table_name = 'livros';

-- Se as tabelas não existirem, execute o schema.sql completo
