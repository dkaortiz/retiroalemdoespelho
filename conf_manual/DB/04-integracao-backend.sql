-- ============================================================
-- 🔄 INTEGRAÇÃO COM BACKEND - Queries para Node.js
-- ============================================================
-- ⚠️ ⚠️ ⚠️ ATENÇÃO ⚠️ ⚠️ ⚠️
-- 
-- ESTE ARQUIVO NÃO DEVE SER EXECUTADO EM phpMyAdmin
-- 
-- Este é um TEMPLATE para desenvolvedores Node.js
-- As queries usam ? como placeholders (não são SQL puro)
-- Os ? serão substituídos por valores do Node.js via mysql2
-- 
-- Use este arquivo COMO REFERÊNCIA ao programar backend/server.js
-- NÃO copie direto para phpMyAdmin
-- 
-- ============================================================

-- ============================================================
-- 1️⃣ CRIAR INSCRIÇÃO + REGISTRAR NO HISTÓRICO
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTAS QUERIES DIRETO
-- Use como template no Node.js
-- 
/*
-- Step 1: Inserir Inscrição
INSERT INTO inscricoes (
  uuid, nome, email, telefone, idade, mensagem,
  tipo_atual, status_pagamento,
  pagbank_id, referencia_pagbank, ativo
) VALUES (
  ?, ?, ?, ?, ?, ?,
  'acampante', 'pendente',
  NULL, NULL, TRUE
);

-- Step 2: Obter ID da inscrição (usar LAST_INSERT_ID())
SELECT LAST_INSERT_ID() as inscricao_id;

-- Step 3: Registrar no Histórico
INSERT INTO historico_tipo_participante (
  inscricao_id, tipo_anterior, tipo_novo,
  data_mudanca, motivo, autorizado_por
) VALUES (
  ?, NULL, 'acampante',
  NOW(), 'Inscrição inicial via website', 'SISTEMA'
);

-- Step 4: Registrar na Auditoria
INSERT INTO auditoria (
  inscricao_id, acao, dados_novo, data_acao, usuario
) VALUES (
  ?, 'CRIACAO', 
  JSON_OBJECT(
    'nome', ?,
    'email', ?,
    'tipo', 'acampante'
  ),
  NOW(), 'WEBSITE'
);
*/

-- ============================================================
-- 2️⃣ CRIAR PAGAMENTO APÓS INSCRIÇÃO
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTAS QUERIES DIRETO
-- Use como template no Node.js
-- 
/*
-- Inserir registro de pagamento
INSERT INTO pagamentos (
  inscricao_id, pagbank_id, referencia_pagbank,
  valor, status, data_criacao
) VALUES (
  ?, ?, ?,
  ?, 'WAITING_PAYMENT', NOW()
);

-- Registrar em auditoria
INSERT INTO auditoria (
  inscricao_id, acao, dados_novo, data_acao, usuario
) VALUES (
  ?, 'CRIACAO_COBRANCA',
  JSON_OBJECT(
    'pagbank_id', ?,
    'valor', ?,
    'referencia', ?
  ),
  NOW(), 'PAGBANK_API'
);
*/

-- ============================================================
-- 3️⃣ PROCESSAR WEBHOOK DO PAGBANK
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTAS QUERIES DIRETO
-- Use como template no Node.js
-- 
/*
-- Step 1: Atualizar Status do Pagamento
UPDATE pagamentos
SET 
  status = ?,
  data_pagamento = CASE WHEN ? = 'PAID' THEN NOW() ELSE NULL END,
  data_webhook = NOW()
WHERE pagbank_id = ?;

-- Step 2: Atualizar Status da Inscrição
UPDATE inscricoes
SET 
  status_pagamento = CASE 
    WHEN ? = 'PAID' THEN 'pago'
    WHEN ? = 'DECLINED' THEN 'recusado'
    WHEN ? = 'CANCELED' THEN 'cancelado'
    ELSE 'pendente'
  END,
  data_pagamento = CASE WHEN ? = 'PAID' THEN NOW() ELSE NULL END
WHERE id = (
  SELECT inscricao_id FROM pagamentos WHERE pagbank_id = ? LIMIT 1
);

-- Step 3: Registrar na Auditoria
INSERT INTO auditoria (
  inscricao_id, acao, dados_novo, data_acao, usuario
) VALUES (
  (SELECT inscricao_id FROM pagamentos WHERE pagbank_id = ? LIMIT 1),
  'WEBHOOK_PAGAMENTO',
  JSON_OBJECT(
    'status_anterior', ?,
    'status_novo', ?,
    'pagbank_id', ?
  ),
  NOW(), 'PAGBANK_WEBHOOK'
);
*/

-- ============================================================
-- 4️⃣ OBTER DADOS DE INSCRIÇÃO COM HISTÓRIA
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTA QUERY DIRETO
-- Use como template no Node.js
-- 
/*
-- Buscar Inscrição Completa com Histórico
SELECT 
  i.id,
  i.uuid,
  i.nome,
  i.email,
  i.telefone,
  i.idade,
  i.tipo_atual,
  i.status_pagamento,
  i.data_criacao,
  GROUP_CONCAT(
    JSON_OBJECT(
      'data', h.data_mudanca,
      'tipo_anterior', h.tipo_anterior,
      'tipo_novo', h.tipo_novo,
      'motivo', h.motivo
    )
  ) as historico
FROM inscricoes i
LEFT JOIN historico_tipo_participante h ON i.id = h.inscricao_id
WHERE i.uuid = ?
GROUP BY i.id;
*/

-- ============================================================
-- 5️⃣ VALIDAR: PODE SER EQUIPANTE?
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTA QUERY DIRETO
-- Use como template no Node.js
-- 
/*
-- Query para validação (retorna 1 se pode, 0 se não)
SELECT 
  CASE 
    WHEN COUNT(h.id) > 0 THEN 1
    ELSE 0
  END as pode_ser_equipante
FROM inscricoes i
LEFT JOIN historico_tipo_participante h ON i.id = h.inscricao_id
  AND (h.tipo_novo = 'acampante' OR h.tipo_anterior = 'acampante')
WHERE i.uuid = ?;
*/

-- ============================================================
-- 6️⃣ MUDANÇA DE TIPO: ACAMPANTE → EQUIPANTE
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTAS QUERIES DIRETO
-- Use como template no Node.js
-- 
/*
-- Step 1: Obter tipo atual
SELECT tipo_atual FROM inscricoes WHERE id = ?;

-- Step 2: Validar se pode virar equipante (usar query acima)

-- Step 3: Atualizar tipo
UPDATE inscricoes
SET tipo_atual = 'equipante', data_atualizacao = NOW()
WHERE id = ?;

-- Step 4: Registrar no histórico
INSERT INTO historico_tipo_participante (
  inscricao_id, tipo_anterior, tipo_novo,
  data_mudanca, motivo, autorizado_por
) VALUES (
  ?, 'acampante', 'equipante',
  NOW(), ?, ?
);

-- Step 5: Registrar na auditoria
INSERT INTO auditoria (
  inscricao_id, acao, dados_anterior, dados_novo, data_acao, usuario
) VALUES (
  ?, 'MUDANCA_TIPO',
  JSON_OBJECT('tipo', 'acampante'),
  JSON_OBJECT('tipo', 'equipante'),
  NOW(), ?
);
*/

-- ============================================================
-- 7️⃣ LISTAR INSCRIÇÕES COM FILTROS
-- ============================================================
-- 
-- ⚠️ ALGUMAS DESTAS QUERIES USAM ? DIRETO
-- Use como template no Node.js
-- 
/*
-- Listar todas as ativas (com paginação)
SELECT 
  i.id,
  i.uuid,
  i.nome,
  i.email,
  i.tipo_atual,
  i.status_pagamento,
  i.data_criacao
FROM inscricoes i
WHERE i.ativo = TRUE
ORDER BY i.data_criacao DESC
LIMIT ? OFFSET ?;

-- Listar apenas acampantes
SELECT * FROM inscricoes WHERE tipo_atual = 'acampante' AND ativo = TRUE;

-- Listar apenas equipantes
SELECT * FROM inscricoes WHERE tipo_atual = 'equipante' AND ativo = TRUE;

-- Listar não pagos
SELECT * FROM inscricoes 
WHERE status_pagamento IN ('pendente', 'aguardando_confirmacao') 
AND ativo = TRUE;
*/

-- ============================================================
-- 8️⃣ CONTAR PARA DASHBOARD
-- ============================================================

-- Dashboard - Todos os números (SEM placeholders - execute direto)
SELECT 
  (SELECT COUNT(*) FROM inscricoes WHERE ativo = TRUE) as total_inscritos,
  (SELECT COUNT(*) FROM inscricoes WHERE tipo_atual = 'acampante' AND ativo = TRUE) as total_acampantes,
  (SELECT COUNT(*) FROM inscricoes WHERE tipo_atual = 'equipante' AND ativo = TRUE) as total_equipantes,
  (SELECT COUNT(*) FROM pagamentos WHERE status = 'PAID') as total_pagos,
  (SELECT COALESCE(SUM(valor), 0) FROM pagamentos WHERE status = 'PAID') as receita_total,
  (SELECT COUNT(*) FROM inscricoes WHERE status_pagamento = 'pendente' AND ativo = TRUE) as pendentes;

-- ============================================================
-- 9️⃣ BUSCAR EMAIL (PARA VALIDAR DUPLICAÇÃO)
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTAS QUERIES DIRETO
-- Use como template no Node.js
-- 
/*
-- Verificar se email já existe
SELECT COUNT(*) as existe
FROM inscricoes
WHERE email = ? AND ativo = TRUE;

-- Obter ID pelo email
SELECT id, uuid FROM inscricoes WHERE email = ? AND ativo = TRUE LIMIT 1;
*/

-- ============================================================
-- 🔟 CANCELAR INSCRIÇÃO
-- ============================================================
-- 
-- ⚠️ NÃO EXECUTE ESTAS QUERIES DIRETO
-- Use como template no Node.js
-- 
/*
-- Soft Delete (marcar como inativo)
UPDATE inscricoes
SET ativo = FALSE, data_atualizacao = NOW()
WHERE id = ?;

-- Registrar cancelamento na auditoria
INSERT INTO auditoria (
  inscricao_id, acao, dados_novo, data_acao, usuario
) VALUES (
  ?, 'CANCELAMENTO_INSCRICAO',
  JSON_OBJECT('motivo', ?),
  NOW(), ?
);
*/

-- ============================================================
-- ✅ TEMPLATE PRONTO PARA NODE.JS
-- ============================================================
-- 
-- COMO USAR ESTE ARQUIVO:
-- 
-- 1. Copie as queries comentadas para seu arquivo backend/server.js
-- 2. Remova os comentários /* e */
-- 3. Substitua ? por valores usando prepared statements
-- 4. Exemplo:
--    const [resultado] = await db.execute(query, [valor1, valor2, ...])
-- 
-- NUNCA execute este arquivo direto em phpMyAdmin
-- Os ? são placeholders do Node.js/mysql2, não SQL puro
-- 
-- ============================================================
