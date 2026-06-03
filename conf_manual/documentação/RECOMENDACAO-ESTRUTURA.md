# 📊 Recomendação: Estrutura de Banco de Dados

## ❌ NÃO Fazer: Tabelas Separadas

```
❌ inscricoes_acampantes
❌ inscricoes_equipantes
```

**Problemas:**
- Duplicação de dados
- Difícil manter histórico
- Impossível rastrear transição de tipo
- Queries complexas

---

## ✅ FAZER: Uma Tabela + Histórico (RECOMENDADO)

```
📊 Estrutura Normalizada:

inscricoes
├── id (PK)
├── nome
├── email
├── tipo_atual (acampante/equipante)
├── status_pagamento
├── data_criacao
└── data_atualizacao

historico_tipo_participante
├── id (PK)
├── inscricao_id (FK)
├── tipo_anterior
├── tipo_novo
├── data_mudanca
├── motivo
└── autorizado_por

auditoria
├── id
├── inscricao_id
├── acao
├── dados_anterior
├── dados_novo
├── data
└── usuario
```

---

## 💡 Por Que Esta Estrutura?

### ✅ Vantagens

1. **Rastreabilidade Total**
   - Saber quando foi acampante
   - Saber quando virou equipante
   - Histórico completo de mudanças

2. **Validação de Regra**
   - "Ser equipante só após ser acampante"
   - Query simples: `SELECT * FROM historico WHERE tipo_novo = 'equipante' AND tipo_anterior = 'acampante'`

3. **Normalizado**
   - Evita duplicação
   - Mantém integridade dos dados
   - Performance melhorada

4. **Segurança**
   - Auditoria de quem mudou o quê
   - Quando foi mudado
   - Por que foi mudado

5. **Relatórios Futuros**
   - Quantas pessoas viraram equipantes?
   - Tempo médio de permanência como acampante?
   - Taxa de conversão?

---

## 🔄 Fluxo de Mudança de Tipo

```
1. Usuário registra como ACAMPANTE
   ↓
   inscricoes: tipo_atual = 'acampante'
   historico: tipo_anterior = NULL, tipo_novo = 'acampante'

2. Após X tempo, quer virar EQUIPANTE
   ↓
   VALIDAÇÃO: Existiu registro anterior como acampante?
   ↓
   SIM → Permitir mudança
   NÃO → Rejeitar (erro)

3. Mudança Autorizada
   ↓
   inscricoes: tipo_atual = 'equipante'
   historico: tipo_anterior = 'acampante', tipo_novo = 'equipante'
   auditoria: acao = 'MUDANCA_TIPO'
```

---

## 🎯 Implementação no Backend

### Node.js Express Example

```javascript
// 1. Validar se pode virar equipante
async function podeSerEquipante(inscricaoId) {
  const resultado = await db.query(`
    SELECT COUNT(*) as count FROM historico_tipo_participante
    WHERE inscricao_id = ? AND tipo_anterior = 'acampante' OR tipo_novo = 'acampante'
  `, [inscricaoId]);
  
  return resultado[0].count > 0;
}

// 2. Fazer mudança de tipo
async function mudarParaEquipante(inscricaoId, autorizado_por) {
  // Verificar se pode
  if (!await podeSerEquipante(inscricaoId)) {
    throw new Error('Usuário precisa ter sido acampante antes');
  }
  
  // Buscar tipo atual
  const inscricao = await db.query('SELECT tipo_atual FROM inscricoes WHERE id = ?', [inscricaoId]);
  const tipoAnterior = inscricao[0].tipo_atual;
  
  // Atualizar inscrição
  await db.query('UPDATE inscricoes SET tipo_atual = ?, data_atualizacao = NOW() WHERE id = ?', 
    ['equipante', inscricaoId]);
  
  // Registrar no histórico
  await db.query(`
    INSERT INTO historico_tipo_participante 
    (inscricao_id, tipo_anterior, tipo_novo, data_mudanca, autorizado_por)
    VALUES (?, ?, ?, NOW(), ?)
  `, [inscricaoId, tipoAnterior, 'equipante', autorizado_por]);
  
  // Registrar na auditoria
  await db.query(`
    INSERT INTO auditoria 
    (inscricao_id, acao, dados_anterior, dados_novo, data, usuario)
    VALUES (?, 'MUDANCA_TIPO', ?, ?, NOW(), ?)
  `, [inscricaoId, tipoAnterior, 'equipante', autorizado_por]);
}
```

---

## 📈 Queries Úteis

```sql
-- Contar acampantes
SELECT COUNT(*) FROM inscricoes WHERE tipo_atual = 'acampante';

-- Contar equipantes
SELECT COUNT(*) FROM inscricoes WHERE tipo_atual = 'equipante';

-- Ver histórico de um participante
SELECT * FROM historico_tipo_participante WHERE inscricao_id = 123 ORDER BY data_mudanca DESC;

-- Equipantes que foram acampantes
SELECT * FROM inscricoes i
WHERE i.tipo_atual = 'equipante'
AND EXISTS (
  SELECT 1 FROM historico_tipo_participante h
  WHERE h.inscricao_id = i.id AND h.tipo_novo = 'equipante'
);

-- Tempo como acampante antes de virar equipante
SELECT 
  i.nome,
  h1.data_mudanca as data_vira_acampante,
  h2.data_mudanca as data_vira_equipante,
  DATEDIFF(h2.data_mudanca, h1.data_mudanca) as dias_como_acampante
FROM inscricoes i
JOIN historico_tipo_participante h1 ON i.id = h1.inscricao_id AND h1.tipo_novo = 'acampante'
JOIN historico_tipo_participante h2 ON i.id = h2.inscricao_id AND h2.tipo_novo = 'equipante'
ORDER BY dias_como_acampante DESC;
```

---

## 🎓 Conclusão

**Use uma única tabela com histórico!**

✅ Melhor para:
- Rastreabilidade
- Validação de regras
- Relatórios futuros
- Integridade de dados
- Auditoria e compliance

