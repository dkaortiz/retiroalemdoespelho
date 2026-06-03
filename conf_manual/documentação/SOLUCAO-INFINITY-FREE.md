# ⚠️ SOLUÇÃO: Infinity Free Não Suporta VIEWs

## 🔴 O Problema

```
Erro: #1142 - Comando 'CREATE VIEW' negado
```

Planos gratuitos (Infinity Free) não permitem criar VIEWs por segurança.

---

## ✅ Solução 1: Remover VIEWs do Schema

Use o arquivo `01-schema-sem-views.sql` que criei (sem as CREATE VIEW).

---

## ✅ Solução 2: Usar Queries no Backend

Em vez de views, use estas queries prontas no Node.js:

### 1. Inscrições Ativas (Em vez de vw_inscricoes_ativas)

```javascript
// Backend - Node.js
const obterInscricoesAtivas = async (db) => {
  const query = `
    SELECT 
      i.id,
      i.uuid,
      i.nome,
      i.email,
      i.tipo_atual,
      i.status_pagamento,
      i.data_criacao,
      DATEDIFF(NOW(), i.data_criacao) as dias_inscrito
    FROM inscricoes i
    WHERE i.ativo = TRUE
    ORDER BY i.data_criacao DESC
  `;
  
  return await db.execute(query);
};

// Usar em rota
app.get('/api/inscricoes-ativas', async (req, res) => {
  const [inscricoes] = await obterInscricoesAtivas(db);
  res.json({ success: true, data: inscricoes });
});
```

### 2. Equipantes Ex-Acampantes (Em vez de vw_equipantes_ex_acampantes)

```javascript
const obterEquipantesExAcampantes = async (db) => {
  const query = `
    SELECT 
      i.id,
      i.uuid,
      i.nome,
      i.email,
      h1.data_mudanca as data_primeira_inscricao,
      h2.data_mudanca as data_virou_equipante,
      DATEDIFF(h2.data_mudanca, h1.data_mudanca) as dias_como_acampante
    FROM inscricoes i
    JOIN historico_tipo_participante h1 ON i.id = h1.inscricao_id 
      AND h1.tipo_novo = 'acampante'
    JOIN historico_tipo_participante h2 ON i.id = h2.inscricao_id 
      AND h2.tipo_novo = 'equipante'
    WHERE i.tipo_atual = 'equipante'
    ORDER BY h2.data_mudanca DESC
  `;
  
  return await db.execute(query);
};
```

### 3. Estatísticas (Em vez de vw_estatisticas)

```javascript
const obterEstatisticas = async (db) => {
  const query = `
    SELECT 
      (SELECT COUNT(*) FROM inscricoes WHERE ativo = TRUE) as total_inscritos,
      (SELECT COUNT(*) FROM inscricoes WHERE tipo_atual = 'acampante' AND ativo = TRUE) as total_acampantes,
      (SELECT COUNT(*) FROM inscricoes WHERE tipo_atual = 'equipante' AND ativo = TRUE) as total_equipantes,
      (SELECT COUNT(*) FROM inscricoes WHERE status_pagamento = 'pago' AND ativo = TRUE) as total_pagos,
      (SELECT COUNT(*) FROM inscricoes WHERE status_pagamento = 'pendente' AND ativo = TRUE) as total_pendentes,
      (SELECT SUM(valor) FROM pagamentos WHERE status = 'PAID') as receita_total
  `;
  
  const [resultado] = await db.execute(query);
  return resultado[0];
};
```

---

## 📋 Consultas Diretas (Sem Views)

Use estas direto em phpMyAdmin ou no backend:

```sql
-- Inscrições Ativas
SELECT 
  id, uuid, nome, email, tipo_atual, status_pagamento,
  data_criacao, DATEDIFF(NOW(), data_criacao) as dias_inscrito
FROM inscricoes
WHERE ativo = TRUE
ORDER BY data_criacao DESC;

-- Equipantes Ex-Acampantes
SELECT 
  i.id, i.nome, i.email,
  h1.data_mudanca as data_inscricao,
  h2.data_mudanca as data_equipante,
  DATEDIFF(h2.data_mudanca, h1.data_mudanca) as dias_como_acampante
FROM inscricoes i
JOIN historico_tipo_participante h1 ON i.id = h1.inscricao_id AND h1.tipo_novo = 'acampante'
JOIN historico_tipo_participante h2 ON i.id = h2.inscricao_id AND h2.tipo_novo = 'equipante'
WHERE i.tipo_atual = 'equipante'
ORDER BY h2.data_mudanca DESC;

-- Estatísticas Completas
SELECT 
  COUNT(*) as total_inscritos,
  SUM(CASE WHEN tipo_atual = 'acampante' THEN 1 ELSE 0 END) as total_acampantes,
  SUM(CASE WHEN tipo_atual = 'equipante' THEN 1 ELSE 0 END) as total_equipantes,
  SUM(CASE WHEN status_pagamento = 'pago' THEN 1 ELSE 0 END) as total_pagos
FROM inscricoes
WHERE ativo = TRUE;
```

---

## 🎯 RECOMENDAÇÃO

✅ **Melhor opção:** Usar queries no backend (Node.js)

**Por quê?**
- Controle total
- Cache possível
- Cálculos rápidos
- Sem permissão necessária

**Implementação:**
1. Remova VIEWs de `01-schema.sql`
2. Implemente as funções no backend
3. Crie endpoints para cada "view"

---

## 🚀 Próximas Ações

### 1. Use este schema (sem views):
```bash
# Executar em phpMyAdmin com o arquivo 01-schema-sem-views.sql
# (Vou criar para você)
```

### 2. No Backend, implemente as funções JavaScript

### 3. Endpoints para dashboard:
```
GET /api/stats/inscricoes-ativas
GET /api/stats/equipantes
GET /api/stats/geral
```

---

**Solução:** VIEWs no backend ao invés do banco 💪

