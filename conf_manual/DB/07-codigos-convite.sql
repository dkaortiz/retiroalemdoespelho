-- ============================================================
-- TABELA DE CÓDIGOS DE CONVITE (PARA EQUIPANTES)
-- Execute após 01-schema-infinity-free.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS `codigos_convite` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `codigo` VARCHAR(32) NOT NULL UNIQUE COMMENT 'Código único para convite (ex: RETIRO2025-ABC123)',
  `tipo` ENUM('acampante', 'equipante') NOT NULL DEFAULT 'equipante' COMMENT 'Tipo de acesso que o código libera',
  `descricao` VARCHAR(255) COMMENT 'Motivo ou destinação do código (ex: "Referência de fulano")',
  `ativo` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Se o código ainda pode ser usado',
  `desconto_percentual` DECIMAL(5,2) UNSIGNED DEFAULT 0 COMMENT 'Desconto aplicado ao usar o código (0-100%)',
  `data_criacao` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `data_expiracao` TIMESTAMP NULL COMMENT 'Data até quando o código é válido. NULL = sem expiração',
  `data_uso` TIMESTAMP NULL COMMENT 'Data em que o código foi usado',
  `inscricao_id_usada` VARCHAR(36) UNIQUE COMMENT 'ID da inscrição que usou o código (referência)',
  
  INDEX `idx_codigo_ativo` (`codigo`, `ativo`),
  INDEX `idx_ativo_expiracao` (`ativo`, `data_expiracao`),
  INDEX `idx_tipo_ativo` (`tipo`, `ativo`),
  UNIQUE INDEX `uniq_codigo` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- COMENTÁRIOS DA TABELA
-- ============================================================

ALTER TABLE `codigos_convite` 
COMMENT='Gerencia códigos de convite para novos equipantes. Um código pode ser enviado a uma pessoa convidada para liberar cadastro como equipante.';

-- ============================================================
-- DADOS DE EXEMPLO (OPCIONAL - comentado)
-- ============================================================

/*
INSERT INTO `codigos_convite` (codigo, tipo, descricao, ativo, desconto_percentual, data_expiracao) 
VALUES 
  ('RETIRO2025-CONVITE001', 'equipante', 'Convite especial para coordenador', TRUE, 0, DATE_ADD(NOW(), INTERVAL 30 DAY)),
  ('RETIRO2025-CONVITE002', 'equipante', 'Convite para facilitador voluntário', TRUE, 15, DATE_ADD(NOW(), INTERVAL 45 DAY)),
  ('RETIRO2025-ACAMPANTE001', 'acampante', 'Bolsa integral para participante selecionado', TRUE, 100, DATE_ADD(NOW(), INTERVAL 60 DAY));
*/

-- ============================================================
-- QUERY: Validar se código é válido
-- Use no backend para validação
-- ============================================================

/*
SELECT 
  codigo,
  tipo,
  desconto_percentual,
  (ativo = TRUE AND (data_expiracao IS NULL OR data_expiracao > NOW())) as codigo_valido
FROM codigos_convite
WHERE codigo = 'RETIRO2025-CONVITE001';
*/

-- ============================================================
-- QUERY: Marcar código como usado
-- Execute após inscrição bem-sucedida
-- ============================================================

/*
UPDATE codigos_convite
SET 
  data_uso = NOW(),
  ativo = FALSE,
  inscricao_id_usada = 'UUID-DA-INSCRICAO'
WHERE codigo = 'RETIRO2025-CONVITE001';
*/
