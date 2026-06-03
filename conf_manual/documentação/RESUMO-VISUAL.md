# 📊 RESUMO: Estrutura de Banco de Dados

## 🎯 O QUE FOI CRIADO

Você agora tem um **sistema profissional de gestão de inscrições** com rastreamento completo, histórico de mudanças, auditoria, e validações automáticas.

---

## 📈 ESTRUTURA VISUAL

```
┌─────────────────────────────────────────────────────────────────┐
│                      RETIRO ALÉM DO ESPELHO                     │
│                   Sistema de Inscrições & Pagamentos            │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                  CAMADA 1: INSCRIÇÕES (Principal)                │
├──────────────────────────────────────────────────────────────────┤
│  📋 inscricoes                                                    │
│  ├─ id: INT PRIMARY KEY                                          │
│  ├─ uuid: VARCHAR (para referências externas)                   │
│  ├─ nome, email, telefone, idade, mensagem                      │
│  ├─ tipo_atual: acampante | equipante                           │
│  ├─ status_pagamento: pendente | pago | recusado                │
│  ├─ data_criacao, data_atualizacao                              │
│  └─ ativo: TRUE | FALSE (soft delete)                           │
└──────────────────────────────────────────────────────────────────┘

        ↓ Uma inscrição pode ter múltiplas mudanças ↓

┌──────────────────────────────────────────────────────────────────┐
│         CAMADA 2: HISTÓRICO (Rastreamento de Mudanças)          │
├──────────────────────────────────────────────────────────────────┤
│  📜 historico_tipo_participante                                  │
│  ├─ id: INT PRIMARY KEY                                          │
│  ├─ inscricao_id: FK → inscricoes.id                            │
│  ├─ tipo_anterior: NULL | acampante | equipante                │
│  ├─ tipo_novo: acampante | equipante                            │
│  ├─ data_mudanca: TIMESTAMP                                      │
│  ├─ motivo: TEXT                                                 │
│  └─ autorizado_por: VARCHAR                                      │
│                                                                   │
│  Exemplo:                                                        │
│  ┌────────────────────────────────────────────────┐             │
│  │ Inscrição ID 1 (Maria)                         │             │
│  ├────────────────────────────────────────────────┤             │
│  │ data_mudanca      │ tipo_anterior │ tipo_novo │             │
│  │ 2026-06-01 10:00  │ NULL          │ acampante │ (Inscrição) │
│  │ 2026-12-01 14:30  │ acampante     │ equipante │ (Promoção)  │
│  └────────────────────────────────────────────────┘             │
└──────────────────────────────────────────────────────────────────┘

        ↓ Toda mudança é auditada ↓

┌──────────────────────────────────────────────────────────────────┐
│            CAMADA 3: AUDITORIA (Compliance & Logs)               │
├──────────────────────────────────────────────────────────────────┤
│  🔐 auditoria                                                    │
│  ├─ id: INT PRIMARY KEY                                          │
│  ├─ inscricao_id: FK                                             │
│  ├─ acao: CRIACAO | MUDANCA_TIPO | PAGAMENTO | etc             │
│  ├─ dados_anterior: JSON                                         │
│  ├─ dados_novo: JSON                                             │
│  ├─ data_acao: TIMESTAMP                                         │
│  ├─ usuario: VARCHAR (quem fez)                                  │
│  └─ ip_address: VARCHAR (segurança)                              │
│                                                                   │
│  Exemplo:                                                        │
│  ┌────────────────────────────────────────────────┐             │
│  │ Ação: MUDANCA_TIPO                             │             │
│  │ Usuário: admin@retiro.com.br                   │             │
│  │ Data: 2026-12-01 14:30:00                      │             │
│  │ Anterior: {"tipo": "acampante"}                │             │
│  │ Novo: {"tipo": "equipante"}                    │             │
│  └────────────────────────────────────────────────┘             │
└──────────────────────────────────────────────────────────────────┘

        ↓ Pagamentos relacionados ↓

┌──────────────────────────────────────────────────────────────────┐
│             CAMADA 4: PAGAMENTOS (PagBank Integration)           │
├──────────────────────────────────────────────────────────────────┤
│  💳 pagamentos                                                   │
│  ├─ id: INT PRIMARY KEY                                          │
│  ├─ inscricao_id: FK → inscricoes.id                            │
│  ├─ pagbank_id: VARCHAR (ID do PagBank)                         │
│  ├─ valor: DECIMAL (R$ 299.90)                                  │
│  ├─ status: WAITING_PAYMENT | PAID | DECLINED | CANCELED      │
│  ├─ data_criacao, data_pagamento, data_webhook                 │
│  └─ webhook_payload: JSON (dados recebidos)                     │
└──────────────────────────────────────────────────────────────────┘

        ↓ Múltiplas edições do retiro ↓

┌──────────────────────────────────────────────────────────────────┐
│          CAMADA 5: EDIÇÕES (Múltiplos Retiros)                   │
├──────────────────────────────────────────────────────────────────┤
│  📅 edicoes                                                       │
│  ├─ id, titulo, numero_edicao (1, 2, 3...)                      │
│  ├─ datas (início, fim, inscrições abertas/fechadas)           │
│  ├─ preços (acampante: R$ 299.90, equipante: R$ 199.90)        │
│  ├─ vagas (50 acampantes, 20 equipantes)                        │
│  └─ status (planejamento, inscricoes_abertas, em_andamento)    │
│                                                                   │
│  📍 inscricoes_edicoes (Junction Table)                         │
│  ├─ Relaciona inscrição com edição específica                   │
│  ├─ tipo_participacao (acampante/equipante na edição)          │
│  └─ Permite rastreamento por edição                             │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔑 PONTOS-CHAVE

### 1️⃣ Uma Tabela Principal (Sem Duplicação)

```
❌ ERRADO:
  inscricoes_acampantes
  inscricoes_equipantes
  (dados duplicados, difícil manter histórico)

✅ CERTO:
  inscricoes (tipo_atual: acampante | equipante)
  (normalizado, sem duplicação)
```

### 2️⃣ Histórico de Mudanças

```
inscricoes.tipo_atual = 'equipante'

Mas QUANDO isso aconteceu?
historico_tipo_participante.data_mudanca = 2026-12-01 14:30:00

E QUANTO TEMPO foi acampante?
DATEDIFF(2026-12-01, 2026-06-01) = 183 dias
```

### 3️⃣ Validação Automática: Equipante Após Acampante

```sql
-- Essa query retorna 1 (pode) ou 0 (não pode)
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN 1 ELSE 0 
  END as pode_ser_equipante
FROM historico_tipo_participante
WHERE inscricao_id = ? AND tipo_novo = 'acampante';

-- No backend:
const pode = await podeSerEquipante(inscricaoId);
if (!pode) throw new Error('Precisa ter sido acampante antes');
```

### 4️⃣ Auditoria Completa

```
Quem mudou?  → usuario
O quê mudou? → acao + dados_anterior + dados_novo
Quando?      → data_acao
De onde?     → ip_address
```

---

## 📊 EXEMPLOS DE DADOS

### Exemplo 1: Acampante Normal (Não Pagou)

```
Inscrição:
  id: 1
  nome: João Silva
  email: joao@email.com
  tipo_atual: acampante
  status_pagamento: pendente
  data_criacao: 2026-06-01 10:00

Histórico:
  → 2026-06-01: NULL → acampante (Inscrição inicial)

Pagamento:
  pagbank_id: chg_001
  status: WAITING_PAYMENT (aguardando)
  valor: R$ 299.90
```

### Exemplo 2: Acampante → Equipante (Trajetória Completa)

```
Inscrição:
  id: 2
  nome: Ana Paula Oliveira
  email: ana@email.com
  tipo_atual: equipante
  status_pagamento: pago
  data_criacao: 2026-01-01 10:00
  data_pagamento: 2026-01-05 14:30

Histórico:
  → 2026-01-01: NULL → acampante (Inscrição inicial)
  → 2026-06-15: acampante → equipante (Promovida!)

Auditoria:
  CRIACAO (2026-01-01): Inscrição inicial
  PAGAMENTO_CONFIRMADO (2026-01-05): Pagamento recebido
  MUDANCA_TIPO (2026-06-15): Promovida a equipante

Tempo como Acampante:
  De 2026-01-01 até 2026-06-15 = 165 dias
```

---

## 🎯 FUNCIONALIDADES DESBLOQUEADAS

### ✅ Criar Inscrição
```
POST /api/inscricoes
{
  "nome": "Maria",
  "email": "maria@email.com",
  "tipo": "acampante"
}
↓
Insere em: inscricoes + historico + auditoria
Retorna: UUID para rastrear
```

### ✅ Processar Pagamento
```
WEBHOOK do PagBank
{
  "id": "chg_123",
  "status": "PAID"
}
↓
Atualiza: pagamentos + inscricoes + auditoria
Status muda para: "pago"
```

### ✅ Promover para Equipante
```
POST /api/admin/mudar-equipante/2
{
  "motivo": "Desejo participar como equipe"
}
↓
VALIDAÇÃO: Foi acampante? SIM ✅
↓
Atualiza: inscricoes + historico + auditoria
Tipo muda para: "equipante"
```

### ✅ Ver Histórico Completo
```
GET /api/inscricoes/uuid-123

Retorna:
{
  "id": 2,
  "nome": "Ana Paula",
  "tipo_atual": "equipante",
  "historico": [
    { "data": "2026-01-01", "mudanca": "NULL → acampante" },
    { "data": "2026-06-15", "mudanca": "acampante → equipante" }
  ],
  "pagamentos": [...]
}
```

### ✅ Relatórios & Análises
```
Quantas pessoas viraram equipantes?
SELECT COUNT(*) FROM vw_equipantes_ex_acampantes;

Tempo médio como acampante?
SELECT AVG(DATEDIFF(data_equipante, data_acampante))

Receita total?
SELECT SUM(valor) FROM pagamentos WHERE status = 'PAID';
```

---

## 🔄 FLUXO DO USUÁRIO

```
NOVO USUÁRIO
    ↓
Acessa formulário de inscrição
    ↓
Seleciona: Acampante (R$ 299.90)
    ↓
Preenche dados
    ↓
Clica "Finalizar Inscrição"
    ↓
Backend: criarInscricao()
    ├─ INSERT inscricoes (tipo = 'acampante')
    ├─ INSERT historico (NULL → 'acampante')
    ├─ INSERT auditoria (CRIACAO)
    └─ Retorna UUID
    ↓
Frontend exibe link de pagamento
    ↓
Usuário clica no link PagBank
    ↓
Realiza o pagamento (PIX, cartão, etc)
    ↓
PagBank envia webhook: status = 'PAID'
    ↓
Backend: processarWebhookPagBank()
    ├─ UPDATE pagamentos (status = 'PAID')
    ├─ UPDATE inscricoes (status_pagamento = 'pago')
    ├─ INSERT auditoria (WEBHOOK_PAGAMENTO)
    └─ ✅ Inscrição confirmada!
    ↓
[6 MESES DEPOIS]
    ↓
Admin vê que Ana quer virar equipante
    ↓
Clica botão de admin: "Promover para Equipante"
    ↓
Backend: mudarParaEquipante()
    ├─ VALIDAÇÃO: Foi acampante? SIM ✅
    ├─ UPDATE inscricoes (tipo = 'equipante')
    ├─ INSERT historico ('acampante' → 'equipante')
    ├─ INSERT auditoria (MUDANCA_TIPO)
    └─ ✅ Promovida com histórico completo!
```

---

## 📚 ARQUIVOS FORNECIDOS

| Arquivo | Propósito | Execute |
|---------|-----------|---------|
| `RECOMENDACAO-ESTRUTURA.md` | Por que esta estrutura | Ler |
| `01-schema.sql` | Criar tabelas | phpMyAdmin (1️⃣) |
| `02-seeds.sql` | Dados de exemplo | phpMyAdmin (2️⃣) |
| `03-queries-uteis.sql` | Queries para análises | Referência |
| `04-integracao-backend.sql` | Queries para backend | Referência |
| `GUIA-NODEJS-MYSQL.md` | Implementação Node.js | Implementação |
| `PASSO-A-PASSO.md` | Tutorial completo | Fazer setup |

---

## 🚀 PRÓXIMOS PASSOS

1. **Setup Banco**
   - [ ] Executar 01-schema.sql em phpMyAdmin
   - [ ] Executar 02-seeds.sql em phpMyAdmin
   - [ ] Verificar dados em phpMyAdmin

2. **Setup Backend**
   - [ ] npm install mysql2
   - [ ] Criar config/database.js
   - [ ] Testar conexão

3. **Implementação**
   - [ ] Integrar funções do GUIA-NODEJS-MYSQL.md
   - [ ] Testar cada endpoint
   - [ ] Configurar webhooks

4. **Testes**
   - [ ] Criar inscrição teste
   - [ ] Simular pagamento
   - [ ] Promover para equipante
   - [ ] Ver histórico completo

---

## ✨ CARACTERÍSTICAS FINAIS

✅ **Normalizado** - Sem duplicação de dados
✅ **Rastreável** - Histórico completo de mudanças
✅ **Auditável** - Log de quem fez o quê
✅ **Validado** - Equipante só após Acampante
✅ **Seguro** - Soft delete, transações, integridade
✅ **Escalável** - Suporta múltiplos retiros
✅ **Pronto para Produção** - Índices, views, constraints

---

**🎉 Parabéns! Seu banco de dados está pronto para usar!**

