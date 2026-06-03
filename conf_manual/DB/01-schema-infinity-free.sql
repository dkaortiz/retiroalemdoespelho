-- ============================================================
-- 🎯 SCHEMA DO BANCO DE DADOS - Retiro Além do Espelho
-- ⚡ VERSÃO INFINITY FREE (SEM VIEWS)
-- Estrutura Normalizada com Histórico e Auditoria
-- ============================================================

-- ============================================================
-- 1️⃣ TABELA PRINCIPAL: INSCRIÇÕES
-- ============================================================

CREATE TABLE IF NOT EXISTS inscricoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid VARCHAR(36) UNIQUE NOT NULL,
  
  -- Dados Pessoais
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  telefone VARCHAR(20),
  idade INT,
  mensagem TEXT,
  
  -- Tipo e Status
  tipo_atual ENUM('acampante', 'equipante') NOT NULL DEFAULT 'acampante',
  status_pagamento ENUM('pendente', 'aguardando_confirmacao', 'pago', 'recusado', 'cancelado') NOT NULL DEFAULT 'pendente',
  
  -- Rastreamento
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  data_pagamento TIMESTAMP NULL,
  
  -- Dados PagBank
  pagbank_id VARCHAR(255) UNIQUE NULL,
  referencia_pagbank VARCHAR(255) NULL,
  
  -- Status Geral
  ativo BOOLEAN DEFAULT TRUE,
  
  -- Índices
  INDEX idx_email (email),
  INDEX idx_tipo_atual (tipo_atual),
  INDEX idx_status_pagamento (status_pagamento),
  INDEX idx_data_criacao (data_criacao),
  INDEX idx_uuid (uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2️⃣ TABELA DE HISTÓRICO: Mudanças de Tipo
-- ============================================================

CREATE TABLE IF NOT EXISTS historico_tipo_participante (
  id INT AUTO_INCREMENT PRIMARY KEY,
  inscricao_id INT NOT NULL,
  
  -- Tipos
  tipo_anterior ENUM('acampante', 'equipante') NULL,
  tipo_novo ENUM('acampante', 'equipante') NOT NULL,
  
  -- Timing
  data_mudanca TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Contexto
  motivo VARCHAR(255) NULL,
  autorizado_por VARCHAR(255) NULL,
  
  -- Chave Estrangeira
  FOREIGN KEY (inscricao_id) REFERENCES inscricoes(id) ON DELETE CASCADE,
  
  -- Índices
  INDEX idx_inscricao_id (inscricao_id),
  INDEX idx_data_mudanca (data_mudanca),
  INDEX idx_tipo_novo (tipo_novo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3️⃣ TABELA DE AUDITORIA: Log de Mudanças
-- ============================================================

CREATE TABLE IF NOT EXISTS auditoria (
  id INT AUTO_INCREMENT PRIMARY KEY,
  inscricao_id INT NOT NULL,
  
  -- Ação
  acao VARCHAR(50) NOT NULL,
  
  -- Dados
  dados_anterior JSON NULL,
  dados_novo JSON NULL,
  
  -- Quem e Quando
  data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usuario VARCHAR(255) NULL,
  
  -- IP (opcional, para segurança)
  ip_address VARCHAR(45) NULL,
  
  -- Chave Estrangeira
  FOREIGN KEY (inscricao_id) REFERENCES inscricoes(id) ON DELETE CASCADE,
  
  -- Índices
  INDEX idx_inscricao_id (inscricao_id),
  INDEX idx_acao (acao),
  INDEX idx_data_acao (data_acao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4️⃣ TABELA DE PAGAMENTOS: Rastreamento Detalhado
-- ============================================================

CREATE TABLE IF NOT EXISTS pagamentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  inscricao_id INT NOT NULL,
  
  -- Dados PagBank
  pagbank_id VARCHAR(255) UNIQUE NOT NULL,
  referencia_pagbank VARCHAR(255),
  
  -- Valores
  valor DECIMAL(10, 2) NOT NULL,
  moeda VARCHAR(3) DEFAULT 'BRL',
  
  -- Status
  status ENUM('WAITING_PAYMENT', 'PAID', 'DECLINED', 'CANCELED', 'PENDING_REVIEW') NOT NULL DEFAULT 'WAITING_PAYMENT',
  
  -- Timing
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_pagamento TIMESTAMP NULL,
  data_webhook TIMESTAMP NULL,
  
  -- Dados Webhook
  webhook_payload JSON NULL,
  
  -- Chave Estrangeira
  FOREIGN KEY (inscricao_id) REFERENCES inscricoes(id) ON DELETE CASCADE,
  
  -- Índices
  INDEX idx_inscricao_id (inscricao_id),
  INDEX idx_pagbank_id (pagbank_id),
  INDEX idx_status (status),
  INDEX idx_data_criacao (data_criacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5️⃣ TABELA DE EDIÇÕES: Rastreamento de Retiros
-- ============================================================

CREATE TABLE IF NOT EXISTS edicoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  descricao TEXT,
  numero_edicao INT UNIQUE NOT NULL,
  
  -- Timing
  data_inicio DATE NOT NULL,
  data_fim DATE NOT NULL,
  data_inscricao_inicio DATE NOT NULL,
  data_inscricao_fim DATE NOT NULL,
  
  -- Status
  status ENUM('planejamento', 'inscricoes_abertas', 'em_andamento', 'finalizado', 'cancelado') NOT NULL,
  
  -- Configuração
  preco_acampante DECIMAL(10, 2),
  preco_equipante DECIMAL(10, 2),
  vagas_acampantes INT,
  vagas_equipantes INT,
  
  -- Metadata
  cor_tema VARCHAR(7),
  imagem_capa VARCHAR(255),
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Índices
  INDEX idx_numero_edicao (numero_edicao),
  INDEX idx_status (status),
  INDEX idx_data_inicio (data_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6️⃣ TABELA DE INSCRIÇÕES POR EDIÇÃO
-- ============================================================

CREATE TABLE IF NOT EXISTS inscricoes_edicoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  inscricao_id INT NOT NULL,
  edicao_id INT NOT NULL,
  
  -- Tipo na edição
  tipo_participacao ENUM('acampante', 'equipante') NOT NULL,
  
  -- Status
  status ENUM('confirmada', 'cancelada', 'no_show') NOT NULL DEFAULT 'confirmada',
  
  -- Avaliação (pós-retiro)
  avaliacao INT NULL CHECK (avaliacao >= 1 AND avaliacao <= 5),
  comentario TEXT NULL,
  data_avaliacao TIMESTAMP NULL,
  
  -- Timing
  data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_presente TIMESTAMP NULL,
  
  -- Índices
  UNIQUE KEY unique_inscricao_edicao (inscricao_id, edicao_id),
  FOREIGN KEY (inscricao_id) REFERENCES inscricoes(id) ON DELETE CASCADE,
  FOREIGN KEY (edicao_id) REFERENCES edicoes(id) ON DELETE CASCADE,
  INDEX idx_edicao_id (edicao_id),
  INDEX idx_tipo_participacao (tipo_participacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ⚠️ VIEWS NÃO SUPORTADAS NO INFINITY FREE
-- ============================================================
-- Infinity Free não permite criar VIEWs
-- Use as queries no backend (Node.js) em vez disso
-- Veja: SOLUCAO-INFINITY-FREE.md
-- ============================================================

-- ============================================================
-- ✅ SCHEMA CRIADO COM SUCESSO!
-- ============================================================
-- Próximo passo: Execute 02-seeds.sql para dados de exemplo
-- ============================================================
