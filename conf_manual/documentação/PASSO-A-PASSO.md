# 🚀 IMPLEMENTAÇÃO DO BANCO DE DADOS - PASSO A PASSO

## 📋 Resumo Executivo

Você agora tem uma **estrutura profissional de banco de dados** com:

✅ **Uma tabela principal** (`inscricoes`) - normalizada e sem duplicação
✅ **Histórico de mudanças** (`historico_tipo_participante`) - rastreia todas as transições
✅ **Auditoria completa** (`auditoria`) - log de quem fez o quê e quando
✅ **Pagamentos** (`pagamentos`) - integração com PagBank
✅ **Edições** (`edicoes`) - múltiplos retiros
✅ **Validação automática** - Equipante só após Acampante

---

## 📁 Arquivos Criados em `conf_manual/DB/`

```
DB/
├── RECOMENDACAO-ESTRUTURA.md      # Por que esta estrutura?
├── 01-schema.sql                  # 🔵 Criar tabelas (execute PRIMEIRO)
├── 02-seeds.sql                   # 🟢 Inserir dados de exemplo
├── 03-queries-uteis.sql           # 🟡 Queries para análises e relatórios
├── 04-integracao-backend.sql      # 🟣 Queries para o backend usar
├── GUIA-NODEJS-MYSQL.md           # 📚 Como usar no Node.js/Express
└── PASSO-A-PASSO.md               # Este arquivo
```

---

## 🎯 PASSOS DE IMPLEMENTAÇÃO

### PASSO 1️⃣: Criar o Banco de Dados

**Acesse:** https://panel.infinityfree.com/

1. Vá para "MySQL Databases"
2. Copie as credenciais:
   - Hostname: `sql300.infinityfree.com`
   - Username: `if0_42031737`
   - Password: `01062021M`
   - Database: `if0_42031737_XXX`

3. Acesse phpMyAdmin (link em "Manage")

---

### PASSO 2️⃣: Executar Schema

**Em phpMyAdmin:**

1. Clique em **SQL** (no topo)
2. Copie todo o conteúdo de `01-schema.sql`
3. Cole em phpMyAdmin
4. Clique **Execute** (Ctrl+Enter)

**Você deve ver:** ✅ "Query successful" 7 vezes

**Tabelas criadas:**
- inscricoes
- historico_tipo_participante
- auditoria
- pagamentos
- edicoes
- inscricoes_edicoes
- Views (vw_inscricoes_ativas, vw_equipantes_ex_acampantes, vw_estatisticas)

---

### PASSO 3️⃣: Inserir Dados de Exemplo

**Em phpMyAdmin:**

1. Clique em **SQL** novamente
2. Copie todo o conteúdo de `02-seeds.sql`
3. Cole
4. Clique **Execute**

**Dados inseridos:**
- 2 Edições
- 4 Inscrições de exemplo
- 5 Registros de histórico
- 4 Pagamentos
- 3 Registros de auditoria

**Você verá no final:**
```
📊 TOTAL DE INSCRITOS: 4
📊 ACAMPANTES: 3
📊 EQUIPANTES: 1
```

---

### PASSO 4️⃣: Verificar Dados

**No phpMyAdmin, execute esta query:**

```sql
SELECT * FROM vw_estatisticas;
```

**Resultado esperado:**
```
total_inscritos: 4
total_acampantes: 3
total_equipantes: 1
total_pagos: 2
total_pendentes: 2
receita_total: 499.80
```

---

### PASSO 5️⃣: Configurar Backend

1. **Instalar dependências:**
```bash
cd backend
npm install mysql2
```

2. **Atualizar `.env`:**
```env
# MySQL
MYSQL_HOST=sql300.infinityfree.com
MYSQL_USER=if0_42031737
MYSQL_PASSWORD=01062021M
MYSQL_DATABASE=if0_42031737_XXX
MYSQL_PORT=3306
```

3. **Criar `backend/config/database.js`:**
```javascript
const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE,
  port: process.env.MYSQL_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;
```

4. **Testar conexão:**
```bash
node -e "require('./config/database').getConnection().then(c => { console.log('✅ Conexão OK'); c.release(); }).catch(e => console.log('❌ Erro:', e.message))"
```

---

### PASSO 6️⃣: Implementar Funções no Backend

Use o arquivo `04-integracao-backend.sql` e `GUIA-NODEJS-MYSQL.md` para implementar:

- ✅ `criarInscricao()` - Cria inscrição + histórico
- ✅ `criarPagamento()` - Registra pagamento
- ✅ `processarWebhookPagBank()` - Recebe notificações
- ✅ `podeSerEquipante()` - Valida regra
- ✅ `mudarParaEquipante()` - Muda tipo com validação

---

### PASSO 7️⃣: Testar Backend

**Teste 1: Verificar conexão**
```bash
curl http://localhost:3000/api/health
```

**Teste 2: Criar inscrição**
```bash
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste DB",
    "email": "teste-db@email.com",
    "tipo": "acampante"
  }'
```

**Teste 3: Listar inscrições**
```bash
curl http://localhost:3000/api/inscricoes
```

---

## 🔍 VERIFICAÇÕES IMPORTANTES

### ✅ Validação 1: Equipante Precisa Ter Sido Acampante

```sql
-- Deve retornar VAZIO (0 resultados)
SELECT * FROM inscricoes 
WHERE tipo_atual = 'equipante'
AND NOT EXISTS (
  SELECT 1 FROM historico_tipo_participante h
  WHERE h.inscricao_id = inscricoes.id 
  AND (h.tipo_novo = 'acampante' OR h.tipo_anterior = 'acampante')
);
```

Se retornar qualquer coisa = ERRO na validação!

### ✅ Validação 2: Histórico Completo

```sql
-- Ver timeline de uma pessoa
SELECT 
  i.nome,
  'Inscrição' as evento,
  i.data_criacao as quando
FROM inscricoes i
WHERE i.id = 1
UNION ALL
SELECT 
  i.nome,
  'Mudança de Tipo' as evento,
  h.data_mudanca as quando
FROM historico_tipo_participante h
JOIN inscricoes i ON h.inscricao_id = i.id
WHERE i.id = 1
ORDER BY quando;
```

### ✅ Validação 3: Auditoria

```sql
-- Ver tudo que foi feito
SELECT * FROM auditoria WHERE inscricao_id = 1;
```

---

## 📊 QUERIES ÚTEIS (EM PRODUÇÃO)

### Contar Inscritos

```sql
SELECT * FROM vw_estatisticas;
```

### Ver Quem Mudou de Tipo

```sql
SELECT * FROM vw_equipantes_ex_acampantes;
```

### Receita Total

```sql
SELECT CONCAT('R$ ', FORMAT(SUM(valor), 2, 'pt_BR')) as receita
FROM pagamentos WHERE status = 'PAID';
```

### Pagamentos Pendentes

```sql
SELECT 
  i.nome, 
  i.email,
  CONCAT('R$ ', FORMAT(p.valor, 2, 'pt_BR')) as valor
FROM pagamentos p
JOIN inscricoes i ON p.inscricao_id = i.id
WHERE p.status = 'WAITING_PAYMENT';
```

---

## ⚠️ TROUBLESHOOTING

### ❌ Erro: "Conexão recusada"

```
Solução:
1. Verificar credenciais no .env
2. Confirmar que banco foi criado no Infinity Free
3. Testar de novo: node test-db.js
```

### ❌ Erro: "Tabelas não encontradas"

```
Solução:
1. Executar 01-schema.sql em phpMyAdmin
2. Verificar se banco correto está selecionado
3. Recarregar página
```

### ❌ Erro: "Email já existe"

```
Solução:
1. Validar antes de inserir:
   SELECT COUNT(*) FROM inscricoes WHERE email = ?
2. Retornar erro amigável ao usuário
```

### ❌ Erro: "Não pode virar Equipante"

```
Isso é CORRETO! Significa:
- Usuário foi criado como Acampante
- Ainda não foi promovido a Equipante
- Validação está funcionando
```

---

## 🎓 ENTENDENDO A ESTRUTURA

### O Fluxo Completo

```
1. Usuário acessa formulário
   ↓
2. Clica em "Finalizar Inscrição"
   ↓
3. Backend chama criarInscricao()
   ↓
4. Insere em: inscricoes + historico_tipo_participante + auditoria
   ↓
5. Retorna UUID e chama PagBank
   ↓
6. Usuário vê link de pagamento
   ↓
7. Clica no link e paga
   ↓
8. PagBank envia webhook
   ↓
9. Backend chama processarWebhookPagBank()
   ↓
10. Atualiza: pagamentos + inscricoes + auditoria
    ↓
11. ✅ Inscrição com pagamento confirmado!

Depois:

12. Futuramente, admin quer promover para Equipante
    ↓
13. Clica em botão de admin
    ↓
14. Backend chama mudarParaEquipante()
    ↓
15. VALIDAÇÃO: Já foi acampante? SIM ✅
    ↓
16. Atualiza: inscricoes + historico_tipo_participante + auditoria
    ↓
17. ✅ Equipante criado com histórico completo!
```

### As Tabelas Trabalham Juntas

```
inscricoes (Principal)
  ├─ Dados pessoais (nome, email, etc)
  ├─ Tipo atual (acampante/equipante)
  ├─ Status pagamento
  └─ Datas

historico_tipo_participante (Histórico)
  ├─ Rastreia TODAS as mudanças de tipo
  ├─ Quem autorizou
  ├─ Quando foi
  └─ Por quê

auditoria (Compliance)
  ├─ Cada ação registrada
  ├─ Dados anteriores vs novos
  ├─ Quem fez (user/sistema)
  └─ Quando (timestamp)

pagamentos (Pagamento)
  ├─ Integração com PagBank
  ├─ Status de cada transação
  ├─ Valor e referência
  └─ Webhooks recebidos
```

---

## ✅ CHECKLIST FINAL

- [ ] Banco criado em Infinity Free
- [ ] Schema executado (01-schema.sql)
- [ ] Seeds inseridos (02-seeds.sql)
- [ ] Dados verificados em phpMyAdmin
- [ ] Backend configurado com mysql2
- [ ] .env atualizado com credenciais
- [ ] Conexão testada (node test-db.js)
- [ ] Funções implementadas
- [ ] API endpoints testados
- [ ] Webhooks configurados
- [ ] Em produção! 🚀

---

## 📞 PRÓXIMOS PASSOS

1. **Implementar Dashboard Admin**
   - Ver todas inscrições
   - Mudar tipos
   - Ver histórico

2. **Integrar E-mails**
   - Confirmação de inscrição
   - Pagamento confirmado
   - Promovido a Equipante

3. **Melhorias**
   - Cache de dados frequentes
   - Relatórios exportáveis
   - Gráficos de conversão

4. **Segurança**
   - Validação de webhook PagBank
   - Rate limiting
   - Verificação de emails duplicados

---

**Parabéns! Seu banco de dados está pronto! 🎉**

