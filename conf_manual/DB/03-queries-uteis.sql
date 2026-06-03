-- ============================================================
-- 🔍 QUERIES ÚTEIS - Consultas Comuns e Validações
-- ============================================================

-- ============================================================
-- 📊 ESTATÍSTICAS GERAIS
-- ============================================================

-- Resumo de Inscrições
SELECT 
  'TOTAL INSCRITOS' as metrica,
  COUNT(*) as valor
FROM inscricoes
WHERE ativo = TRUE
UNION ALL
SELECT 
  'ACAMPANTES',
  COUNT(*)
FROM inscricoes
WHERE tipo_atual = 'acampante' AND ativo = TRUE
UNION ALL
SELECT 
  'EQUIPANTES',
  COUNT(*)
FROM inscricoes
WHERE tipo_atual = 'equipante' AND ativo = TRUE
UNION ALL
SELECT 
  'PAGAMENTOS CONFIRMADOS',
  COUNT(*)
FROM inscricoes
WHERE status_pagamento = 'pago' AND ativo = TRUE
UNION ALL
SELECT 
  'PENDENTES DE PAGAMENTO',
  COUNT(*)
FROM inscricoes
WHERE status_pagamento = 'pendente' AND ativo = TRUE;

-- ============================================================
-- 💰 RECEITA E PAGAMENTOS
-- ============================================================

-- Receita Total
SELECT 
  'Receita Total' as descricao,
  CONCAT('R$ ', FORMAT(COALESCE(SUM(valor), 0), 2, 'pt_BR')) as valor
FROM pagamentos
WHERE status = 'PAID';

-- Receita por Tipo
SELECT 
  ie.tipo_participacao,
  COUNT(*) as quantidade,
  CONCAT('R$ ', FORMAT(SUM(p.valor), 2, 'pt_BR')) as receita_total
FROM pagamentos p
JOIN inscricoes i ON p.inscricao_id = i.id
JOIN inscricoes_edicoes ie ON i.id = ie.inscricao_id
WHERE p.status = 'PAID'
GROUP BY ie.tipo_participacao;

-- Status de Pagamentos
SELECT 
  status,
  COUNT(*) as quantidade,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM pagamentos), 1) as percentual
FROM pagamentos
GROUP BY status
ORDER BY quantidade DESC;

-- ============================================================
-- 🔄 VALIDAÇÕES: REGRA "EQUIPANTE APÓS ACAMPANTE"
-- ============================================================

-- ✅ Verificar: Este usuário pode virar equipante?
-- (Usar: REPLACE 'usuario@email.com' com o email real)
SELECT 
  i.id,
  i.nome,
  i.email,
  i.tipo_atual,
  COUNT(h.id) as mudancas_registradas,
  MAX(h.data_mudanca) as ultima_mudanca,
  CASE 
    WHEN COUNT(h.id) > 0 THEN 'SIM - Pode virar Equipante'
    ELSE 'NÃO - Deve ser Acampante antes'
  END as pode_ser_equipante
FROM inscricoes i
LEFT JOIN historico_tipo_participante h ON i.id = h.inscricao_id 
  AND (h.tipo_novo = 'acampante' OR h.tipo_anterior = 'acampante')
WHERE i.email = 'usuario@email.com'
GROUP BY i.id;

-- Equipantes INVÁLIDOS (viraram equipante sem ter sido acampante antes)
-- ESTA QUERY DEVERIA RETORNAR 0 RESULTADOS SE VALIDAÇÃO ESTÁ FUNCIONANDO
SELECT 
  i.id,
  i.nome,
  i.email,
  i.tipo_atual,
  'EQUIPANTE SEM SER ACAMPANTE' as status_alerta
FROM inscricoes i
WHERE i.tipo_atual = 'equipante'
AND NOT EXISTS (
  SELECT 1 FROM historico_tipo_participante h
  WHERE h.inscricao_id = i.id 
  AND (h.tipo_novo = 'acampante' OR h.tipo_anterior = 'acampante')
);

-- ============================================================
-- 🕐 HISTÓRICO: Rastreamento de Mudanças
-- ============================================================

-- Histórico Completo de Um Participante
-- (USAR: REPLACE '1' com o ID da inscrição)
SELECT 
  h.id,
  CONCAT(h.tipo_anterior, ' → ', h.tipo_novo) as transicao,
  h.data_mudanca,
  DATE_FORMAT(h.data_mudanca, '%d/%m/%Y %H:%i') as data_formatada,
  DATEDIFF(NOW(), h.data_mudanca) as dias_atras,
  h.motivo,
  h.autorizado_por
FROM historico_tipo_participante h
WHERE h.inscricao_id = 1
ORDER BY h.data_mudanca DESC;

-- Todos os Equipantes com Histórico
SELECT 
  i.id,
  i.nome,
  i.email,
  MIN(CASE WHEN h.tipo_novo = 'acampante' THEN h.data_mudanca END) as data_foi_acampante,
  MAX(CASE WHEN h.tipo_novo = 'equipante' THEN h.data_mudanca END) as data_virou_equipante,
  DATEDIFF(
    MAX(CASE WHEN h.tipo_novo = 'equipante' THEN h.data_mudanca END),
    MIN(CASE WHEN h.tipo_novo = 'acampante' THEN h.data_mudanca END)
  ) as dias_entre_mudancas
FROM inscricoes i
JOIN historico_tipo_participante h ON i.id = h.inscricao_id
WHERE i.tipo_atual = 'equipante'
GROUP BY i.id
ORDER BY data_virou_equipante DESC;

-- Timeline Completa (Quem mudou o quê e quando)
SELECT 
  i.nome,
  'Inscrição' as evento,
  i.data_criacao as data,
  CONCAT('Tipo: ', i.tipo_atual) as detalhes
FROM inscricoes i
UNION ALL
SELECT 
  i.nome,
  'Mudança de Tipo',
  h.data_mudanca,
  CONCAT(COALESCE(h.tipo_anterior, 'Novo'), ' → ', h.tipo_novo)
FROM historico_tipo_participante h
JOIN inscricoes i ON h.inscricao_id = i.id
UNION ALL
SELECT 
  i.nome,
  'Pagamento Confirmado',
  p.data_pagamento,
  CONCAT('R$ ', FORMAT(p.valor, 2, 'pt_BR'))
FROM pagamentos p
JOIN inscricoes i ON p.inscricao_id = i.id
WHERE p.status = 'PAID'
ORDER BY nome, data DESC;

-- ============================================================
-- 👥 ANÁLISES: Tempo e Conversão
-- ============================================================

-- Tempo Médio Como Acampante Antes de Virar Equipante
SELECT 
  'Tempo Médio' as metrica,
  CONCAT(
    ROUND(AVG(DATEDIFF(h2.data_mudanca, h1.data_mudanca))),
    ' dias'
  ) as valor
FROM historico_tipo_participante h1
JOIN historico_tipo_participante h2 ON h1.inscricao_id = h2.inscricao_id
WHERE h1.tipo_novo = 'acampante' 
AND h2.tipo_novo = 'equipante'
UNION ALL
SELECT 
  'Mínimo',
  CONCAT(MIN(DATEDIFF(h2.data_mudanca, h1.data_mudanca)), ' dias')
FROM historico_tipo_participante h1
JOIN historico_tipo_participante h2 ON h1.inscricao_id = h2.inscricao_id
WHERE h1.tipo_novo = 'acampante' 
AND h2.tipo_novo = 'equipante'
UNION ALL
SELECT 
  'Máximo',
  CONCAT(MAX(DATEDIFF(h2.data_mudanca, h1.data_mudanca)), ' dias')
FROM historico_tipo_participante h1
JOIN historico_tipo_participante h2 ON h1.inscricao_id = h2.inscricao_id
WHERE h1.tipo_novo = 'acampante' 
AND h2.tipo_novo = 'equipante';

-- Taxa de Conversão: Acampantes que Viraram Equipantes
SELECT 
  COUNT(DISTINCT CASE WHEN i.tipo_atual = 'acampante' THEN i.id END) as total_acampantes_ativos,
  COUNT(DISTINCT CASE WHEN i.tipo_atual = 'equipante' THEN i.id END) as total_equipantes_ativos,
  COUNT(DISTINCT CASE WHEN i.tipo_atual = 'equipante' THEN i.id END) / 
    COUNT(DISTINCT CASE WHEN i.tipo_atual IN ('acampante', 'equipante') THEN i.id END) * 100 
    as percentual_equipantes
FROM inscricoes i;

-- ============================================================
-- 📋 RELATÓRIOS: Detalhes de Inscrições
-- ============================================================

-- Todas as Inscrições com Detalhes Completos
SELECT 
  i.id,
  i.nome,
  i.email,
  i.tipo_atual,
  i.status_pagamento,
  p.valor as valor_inscricao,
  DATE_FORMAT(i.data_criacao, '%d/%m/%Y') as data_inscricao,
  DATEDIFF(NOW(), i.data_criacao) as dias_inscrito,
  CASE WHEN i.status_pagamento = 'pago' THEN 'CONFIRMADA' ELSE 'PENDENTE' END as status_final
FROM inscricoes i
LEFT JOIN pagamentos p ON i.id = p.inscricao_id AND p.status = 'PAID'
WHERE i.ativo = TRUE
ORDER BY i.data_criacao DESC;

-- Inscrições por Edição com Breakdown
SELECT 
  e.titulo,
  e.numero_edicao,
  ie.tipo_participacao,
  COUNT(*) as quantidade,
  COUNT(CASE WHEN ie.status = 'confirmada' THEN 1 END) as confirmadas,
  COUNT(CASE WHEN ie.status = 'cancelada' THEN 1 END) as canceladas,
  COUNT(CASE WHEN ie.data_presente IS NOT NULL THEN 1 END) as presentes
FROM inscricoes_edicoes ie
JOIN edicoes e ON ie.edicao_id = e.id
GROUP BY e.numero_edicao, ie.tipo_participacao
ORDER BY e.numero_edicao DESC, ie.tipo_participacao;

-- ============================================================
-- 🔐 AUDITORIA: Rastreamento de Ações
-- ============================================================

-- Log de Auditoria Completo
SELECT 
  a.id,
  i.nome as participante,
  a.acao,
  DATE_FORMAT(a.data_acao, '%d/%m/%Y %H:%i:%s') as data,
  a.usuario,
  a.dados_novo
FROM auditoria a
JOIN inscricoes i ON a.inscricao_id = i.id
ORDER BY a.data_acao DESC
LIMIT 50;

-- Últimas 10 Mudanças de Tipo
SELECT 
  i.nome,
  CONCAT(h.tipo_anterior, ' → ', h.tipo_novo) as mudanca,
  DATE_FORMAT(h.data_mudanca, '%d/%m/%Y %H:%i') as quando,
  h.autorizado_por as quem
FROM historico_tipo_participante h
JOIN inscricoes i ON h.inscricao_id = i.id
ORDER BY h.data_mudanca DESC
LIMIT 10;

-- ============================================================
-- 🎯 ALERTAS: Ações Necessárias
-- ============================================================

-- Pagamentos Pendentes (Vencendo em 24h)
SELECT 
  i.id,
  i.nome,
  i.email,
  p.referencia_pagbank,
  CONCAT('R$ ', FORMAT(p.valor, 2, 'pt_BR')) as valor,
  DATE_FORMAT(DATE_ADD(p.data_criacao, INTERVAL 24 HOUR), '%d/%m/%Y %H:%i') as expira_em,
  CASE 
    WHEN TIMEDIFF(DATE_ADD(p.data_criacao, INTERVAL 24 HOUR), NOW()) < '01:00:00' THEN '🔴 EXPIRANDO HOJE'
    ELSE '🟡 ATENÇÃO'
  END as status_alerta
FROM pagamentos p
JOIN inscricoes i ON p.inscricao_id = i.id
WHERE p.status = 'WAITING_PAYMENT'
AND p.data_criacao > DATE_SUB(NOW(), INTERVAL 23 HOUR);

-- Inscrições sem Pagamento há mais de 7 dias
SELECT 
  i.id,
  i.nome,
  i.email,
  DATEDIFF(NOW(), i.data_criacao) as dias_sem_pagar,
  'Enviar Lembrete' as acao_sugerida
FROM inscricoes i
WHERE i.status_pagamento IN ('pendente', 'aguardando_confirmacao')
AND i.data_criacao < DATE_SUB(NOW(), INTERVAL 7 DAY);

-- ============================================================
-- 🔧 MANUTENÇÃO: Integridade dos Dados
-- ============================================================

-- Verificar Integridade: Inscrições Órfãs
SELECT 
  'Inscrições sem histórico' as validacao,
  COUNT(*) as total
FROM inscricoes i
WHERE NOT EXISTS (
  SELECT 1 FROM historico_tipo_participante h WHERE h.inscricao_id = i.id
);

-- Verificar Integridade: Pagamentos Órfãos
SELECT 
  'Pagamentos sem inscrição' as validacao,
  COUNT(*) as total
FROM pagamentos p
WHERE NOT EXISTS (
  SELECT 1 FROM inscricoes i WHERE i.id = p.inscricao_id
);

-- Verificar Duplicação: Emails Duplicados
SELECT 
  email,
  COUNT(*) as quantidade
FROM inscricoes
WHERE ativo = TRUE
GROUP BY email
HAVING COUNT(*) > 1;

-- ============================================================
-- 💾 BACKUPS E EXPORTAÇÃO
-- ============================================================

-- ⚠️ NOTA: Infinity Free não permite OUTFILE
-- Use phpMyAdmin Export em vez disso
-- Ou use esta query para ver dados (copiar manualmente):

-- Ver Todas as Inscrições (Para Exportar)
SELECT 
  i.id,
  i.uuid,
  i.nome,
  i.email,
  i.telefone,
  i.tipo_atual,
  i.status_pagamento,
  DATE_FORMAT(i.data_criacao, '%d/%m/%Y') as data_inscricao
FROM inscricoes i
WHERE i.ativo = TRUE;

-- ============================================================
-- ✅ QUERIES ÚTEIS CARREGADAS COM SUCESSO!
-- Use-as para análises, relatórios e validações
-- ============================================================
