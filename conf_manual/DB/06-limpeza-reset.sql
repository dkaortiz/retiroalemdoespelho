-- ============================================================
-- 🧹 LIMPEZA E RESET DO BANCO DE DADOS
-- Execute em phpMyAdmin se precisa começar do zero
-- ============================================================

-- ============================================================
-- OPÇÃO 1: DELETAR SÓ OS DADOS (Manter Estrutura)
-- ============================================================

-- Remover relacionamentos (tabelas filhas primeiro)
DELETE FROM inscricoes_edicoes;
DELETE FROM auditoria;
DELETE FROM pagamentos;
DELETE FROM historico_tipo_participante;

-- Depois remover dados principais
DELETE FROM inscricoes;
DELETE FROM edicoes;

-- Resetar auto_increment
ALTER TABLE inscricoes AUTO_INCREMENT = 1;
ALTER TABLE edicoes AUTO_INCREMENT = 1;
ALTER TABLE historico_tipo_participante AUTO_INCREMENT = 1;
ALTER TABLE pagamentos AUTO_INCREMENT = 1;
ALTER TABLE auditoria AUTO_INCREMENT = 1;
ALTER TABLE inscricoes_edicoes AUTO_INCREMENT = 1;

-- Verificar se limpou
SELECT 'Dados deletados!' as resultado;
SELECT COUNT(*) as total_inscricoes FROM inscricoes;
SELECT COUNT(*) as total_edicoes FROM edicoes;

-- ============================================================
-- OPÇÃO 2: DELETAR TUDO (Resetar Completamente)
-- ============================================================

-- Desabilitar constraint temporariamente
SET FOREIGN_KEY_CHECKS = 0;

-- Droppar todas as tabelas
DROP TABLE IF EXISTS inscricoes_edicoes;
DROP TABLE IF EXISTS pagamentos;
DROP TABLE IF EXISTS auditoria;
DROP TABLE IF EXISTS historico_tipo_participante;
DROP TABLE IF EXISTS inscricoes;
DROP TABLE IF EXISTS edicoes;

-- Reabilitar constraints
SET FOREIGN_KEY_CHECKS = 1;

-- Verificar se deletou
SHOW TABLES;  -- Deve estar vazio

-- ============================================================
-- DEPOIS DE LIMPAR:
-- Execute em ordem:
-- 1. 01-schema-infinity-free.sql (cria tabelas)
-- 2. 02-seeds.sql (insere dados)
-- ============================================================
