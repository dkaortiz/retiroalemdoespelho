-- ============================================================
-- 🌱 DADOS DE EXEMPLO - Seeders do Banco
-- Execute após 01-schema.sql
-- ============================================================

-- ============================================================
-- 1️⃣ INSERIR EDIÇÕES
-- ============================================================

INSERT INTO edicoes (
  titulo, descricao, numero_edicao, 
  data_inicio, data_fim, 
  data_inscricao_inicio, data_inscricao_fim,
  status, preco_acampante, preco_equipante,
  vagas_acampantes, vagas_equipantes,
  cor_tema
) VALUES (
  'O Confronto - Edição Gênesis',
  'A primeira edição do Retiro Além do Espelho. Um confronto consigo mesmo para descobrir quem você realmente é.',
  1,
  '2026-07-01', '2026-07-05',
  '2026-06-01', '2026-06-25',
  'inscricoes_abertas',
  299.90, 199.90,
  50, 20,
  '#ffd700'
);

INSERT INTO edicoes (
  titulo, descricao, numero_edicao, 
  data_inicio, data_fim, 
  data_inscricao_inicio, data_inscricao_fim,
  status, preco_acampante, preco_equipante,
  vagas_acampantes, vagas_equipantes,
  cor_tema
) VALUES (
  'A Quebra - Edição II',
  'Segunda edição focada em quebrar paradigmas e limitações pessoais.',
  2,
  '2026-09-01', '2026-09-05',
  '2026-08-01', '2026-08-25',
  'planejamento',
  299.90, 199.90,
  50, 20,
  '#ffd700'
);

-- ============================================================
-- 2️⃣ INSERIR INSCRIÇÕES (EXEMPLOS)
-- ============================================================

-- Exemplo 1: Acampante Pago
INSERT INTO inscricoes (
  uuid, nome, email, telefone, idade, mensagem,
  tipo_atual, status_pagamento,
  pagbank_id, referencia_pagbank,
  data_pagamento
) VALUES (
  'uuid-acampante-001', 
  'Maria Silva Santos',
  'maria.silva@email.com',
  '11987654321',
  28,
  'Busco uma transformação profunda e espiritual neste retiro.',
  'acampante',
  'pago',
  'chg_001',
  'REF-001-2026',
  NOW()
);

-- Exemplo 2: Acampante Pendente
INSERT INTO inscricoes (
  uuid, nome, email, telefone, idade, mensagem,
  tipo_atual, status_pagamento,
  pagbank_id, referencia_pagbank
) VALUES (
  'uuid-acampante-002',
  'João Pedro Costa',
  'joao.costa@email.com',
  '11999999999',
  35,
  'Desejo descobrir meu verdadeiro propósito.',
  'acampante',
  'pendente',
  'chg_002',
  'REF-002-2026'
);

-- Exemplo 3: Equipante (que foi acampante)
INSERT INTO inscricoes (
  uuid, nome, email, telefone, idade, mensagem,
  tipo_atual, status_pagamento,
  pagbank_id, referencia_pagbank,
  data_pagamento
) VALUES (
  'uuid-equipante-001',
  'Ana Paula Oliveira',
  'ana.oliveira@email.com',
  '11988888888',
  42,
  'Quero equipar outras pessoas nesta jornada de transformação.',
  'equipante',
  'pago',
  'chg_003',
  'REF-003-2026',
  NOW()
);

-- Exemplo 4: Acampante (Novo)
INSERT INTO inscricoes (
  uuid, nome, email, telefone, idade, mensagem,
  tipo_atual, status_pagamento,
  pagbank_id, referencia_pagbank
) VALUES (
  'uuid-acampante-003',
  'Carlos Mendes',
  'carlos.mendes@email.com',
  '11977777777',
  30,
  'Estou pronto para essa transformação.',
  'acampante',
  'aguardando_confirmacao',
  'chg_004',
  'REF-004-2026'
);

-- ============================================================
-- 3️⃣ INSERIR HISTÓRICO DE TIPOS
-- ============================================================

-- Maria Silva: Primeiro acampante
INSERT INTO historico_tipo_participante (
  inscricao_id, tipo_anterior, tipo_novo, 
  data_mudanca, motivo, autorizado_por
) VALUES (
  1, NULL, 'acampante',
  DATE_SUB(NOW(), INTERVAL 15 DAY),
  'Inscrição inicial',
  'SISTEMA'
);

-- João Pedro: Primeiro acampante
INSERT INTO historico_tipo_participante (
  inscricao_id, tipo_anterior, tipo_novo, 
  data_mudanca, motivo, autorizado_por
) VALUES (
  2, NULL, 'acampante',
  DATE_SUB(NOW(), INTERVAL 10 DAY),
  'Inscrição inicial',
  'SISTEMA'
);

-- Ana Paula: Primeiro acampante (há um ano)
INSERT INTO historico_tipo_participante (
  inscricao_id, tipo_anterior, tipo_novo, 
  data_mudanca, motivo, autorizado_por
) VALUES (
  3, NULL, 'acampante',
  DATE_SUB(NOW(), INTERVAL 365 DAY),
  'Inscrição inicial - Edição 1',
  'SISTEMA'
);

-- Ana Paula: Virou equipante (6 meses depois)
INSERT INTO historico_tipo_participante (
  inscricao_id, tipo_anterior, tipo_novo, 
  data_mudanca, motivo, autorizado_por
) VALUES (
  3, 'acampante', 'equipante',
  DATE_SUB(NOW(), INTERVAL 180 DAY),
  'Promoção para equipante',
  'admin@retiro.com.br'
);

-- Carlos Mendes: Primeiro acampante (hoje)
INSERT INTO historico_tipo_participante (
  inscricao_id, tipo_anterior, tipo_novo, 
  data_mudanca, motivo, autorizado_por
) VALUES (
  4, NULL, 'acampante',
  NOW(),
  'Inscrição inicial',
  'SISTEMA'
);

-- ============================================================
-- 4️⃣ INSERIR PAGAMENTOS
-- ============================================================

-- Pagamento Maria (confirmado)
INSERT INTO pagamentos (
  inscricao_id, pagbank_id, referencia_pagbank,
  valor, status,
  data_pagamento, data_webhook
) VALUES (
  1, 'chg_001', 'REF-001-2026',
  299.90, 'PAID',
  DATE_SUB(NOW(), INTERVAL 5 DAY),
  DATE_SUB(NOW(), INTERVAL 5 DAY)
);

-- Pagamento João (aguardando)
INSERT INTO pagamentos (
  inscricao_id, pagbank_id, referencia_pagbank,
  valor, status
) VALUES (
  2, 'chg_002', 'REF-002-2026',
  299.90, 'WAITING_PAYMENT'
);

-- Pagamento Ana (confirmado)
INSERT INTO pagamentos (
  inscricao_id, pagbank_id, referencia_pagbank,
  valor, status,
  data_pagamento, data_webhook
) VALUES (
  3, 'chg_003', 'REF-003-2026',
  199.90, 'PAID',
  DATE_SUB(NOW(), INTERVAL 2 DAY),
  DATE_SUB(NOW(), INTERVAL 2 DAY)
);

-- Pagamento Carlos (aguardando)
INSERT INTO pagamentos (
  inscricao_id, pagbank_id, referencia_pagbank,
  valor, status
) VALUES (
  4, 'chg_004', 'REF-004-2026',
  299.90, 'WAITING_PAYMENT'
);

-- ============================================================
-- 5️⃣ INSERIR AUDITORIA
-- ============================================================

-- Auditoria: Criação Maria
INSERT INTO auditoria (
  inscricao_id, acao, 
  dados_novo,
  usuario
) VALUES (
  1, 'CRIACAO',
  JSON_OBJECT(
    'nome', 'Maria Silva Santos',
    'email', 'maria.silva@email.com',
    'tipo', 'acampante'
  ),
  'SISTEMA'
);

-- Auditoria: Pagamento Maria confirmado
INSERT INTO auditoria (
  inscricao_id, acao,
  dados_anterior, dados_novo,
  usuario
) VALUES (
  1, 'PAGAMENTO_CONFIRMADO',
  JSON_OBJECT('status', 'pendente'),
  JSON_OBJECT('status', 'pago'),
  'PAGBANK_WEBHOOK'
);

-- Auditoria: Mudança Ana para Equipante
INSERT INTO auditoria (
  inscricao_id, acao,
  dados_anterior, dados_novo,
  usuario
) VALUES (
  3, 'MUDANCA_TIPO',
  JSON_OBJECT('tipo', 'acampante'),
  JSON_OBJECT('tipo', 'equipante'),
  'admin@retiro.com.br'
);

-- ============================================================
-- 6️⃣ INSERIR INSCRIÇÕES EM EDIÇÕES
-- ============================================================

-- Maria inscrita na Edição 1
INSERT INTO inscricoes_edicoes (
  inscricao_id, edicao_id,
  tipo_participacao, status,
  data_presente
) VALUES (
  1, 1,
  'acampante', 'confirmada',
  DATE_ADD(NOW(), INTERVAL 7 DAY)
);

-- João inscrito na Edição 1
INSERT INTO inscricoes_edicoes (
  inscricao_id, edicao_id,
  tipo_participacao, status
) VALUES (
  2, 1,
  'acampante', 'confirmada'
);

-- Ana inscrita na Edição 1 como Equipante
INSERT INTO inscricoes_edicoes (
  inscricao_id, edicao_id,
  tipo_participacao, status,
  avaliacao, comentario, data_avaliacao
) VALUES (
  3, 1,
  'equipante', 'confirmada',
  5, 'Experiência transformadora! Recomendo muito.', NOW()
);

-- ============================================================
-- 📊 VERIFICAR DADOS INSERIDOS
-- ============================================================

SELECT '📊 TOTAL DE INSCRITOS' as info;
SELECT COUNT(*) as total FROM inscricoes;

SELECT '📊 BREAKDOWN POR TIPO' as info;
SELECT tipo_atual, COUNT(*) as total FROM inscricoes GROUP BY tipo_atual;

SELECT '📊 BREAKDOWN POR STATUS DE PAGAMENTO' as info;
SELECT status_pagamento, COUNT(*) as total FROM inscricoes GROUP BY status_pagamento;

SELECT '📊 HISTÓRICO DE MUDANÇAS' as info;
SELECT 
  i.nome,
  h.tipo_anterior,
  '→' as seta,
  h.tipo_novo,
  h.data_mudanca
FROM historico_tipo_participante h
JOIN inscricoes i ON h.inscricao_id = i.id
ORDER BY h.data_mudanca DESC;

-- ⚠️ VIEWs não funcionam no Infinity Free
-- Para ver estatísticas, use as queries de 03-queries-uteis.sql em vez disso

-- ============================================================
-- ✅ DADOS DE EXEMPLO INSERIDOS COM SUCESSO!
-- ============================================================
