# 📚 ÍNDICE DE ARQUIVOS - Sistema de Banco de Dados

## 🎯 Você Tem Um Sistema Profissional Completo!

Aqui está o guia para usar cada arquivo:

---

## 📁 ESTRUTURA DE ARQUIVOS

```
conf_manual/
├── DB/
│   ├── RECOMENDACAO-ESTRUTURA.md      ← Comece aqui!
│   ├── RESUMO-VISUAL.md               ← Entenda a arquitetura
│   ├── PASSO-A-PASSO.md               ← Tutorial prático
│   ├── 01-schema.sql                  ← Executar PRIMEIRO
│   ├── 02-seeds.sql                   ← Executar SEGUNDO
│   ├── 03-queries-uteis.sql           ← Referência de queries
│   ├── 04-integracao-backend.sql      ← Para Node.js
│   ├── 05-testes-integridade.sql      ← Validar dados
│   ├── GUIA-NODEJS-MYSQL.md           ← Implementar backend
│   └── README.md                      ← Este arquivo
```

---

## 🚀 INÍCIO RÁPIDO (5 MINUTOS)

### 1️⃣ Ler (2 min)
1. Leia: `RECOMENDACAO-ESTRUTURA.md` - Por que dessa forma?
2. Leia: `RESUMO-VISUAL.md` - Entenda a estrutura visual

### 2️⃣ Executar (2 min)
1. phpMyAdmin → SQL
2. Copie `01-schema.sql` → Execute
3. Copie `02-seeds.sql` → Execute

### 3️⃣ Validar (1 min)
Copie em phpMyAdmin:
```sql
SELECT * FROM vw_estatisticas;
```

---

## 📖 GUIA COMPLETO DE ARQUIVOS

### 1. **RECOMENDACAO-ESTRUTURA.md**

**O quê?**
- Por que usar uma tabela principal + histórico?
- Por que NÃO usar tabelas separadas?
- Vantagens da estrutura escolhida

**Quando ler?**
- PRIMEIRO (entender conceitos)

**Duração:** 5 minutos

---

### 2. **RESUMO-VISUAL.md**

**O quê?**
- Diagrama visual da arquitetura
- Exemplos de dados reais
- Fluxo completo do usuário
- Funcionalidades desbloqueadas

**Quando ler?**
- Depois de RECOMENDACAO-ESTRUTURA.md
- ANTES de executar SQL

**Duração:** 10 minutos

---

### 3. **PASSO-A-PASSO.md**

**O quê?**
- Tutorial passo-a-passo prático
- Como acessar phpMyAdmin
- Como executar scripts SQL
- Como configurar backend
- Troubleshooting comum

**Quando ler?**
- DURANTE a implementação
- Consulte conforme necessário

**Duração:** 30 minutos (full setup)

---

### 4. **01-schema.sql** 🔵

**O quê?**
- Script para CRIAR todas as tabelas
- Define índices, constraints, foreign keys
- Cria views (vw_inscricoes_ativas, etc)

**Quando executar?**
- PRIMEIRO script a executar
- Em phpMyAdmin → SQL
- Deve retornar: ✅ "Queries successful" 7x

**Resultado:**
- 6 tabelas criadas
- 3 views criadas
- Pronto para dados

---

### 5. **02-seeds.sql** 🟢

**O quê?**
- Insere dados de EXEMPLO
- 2 edições de retiro
- 4 participantes teste
- Histórico de mudanças
- Pagamentos teste
- Registros de auditoria

**Quando executar?**
- DEPOIS de 01-schema.sql
- Em phpMyAdmin → SQL

**Resultado:**
```
4 inscrições
3 acampantes, 1 equipante
2 pagos, 2 pendentes
Receita: R$ 499.80
```

**Importante:**
- Dados de TESTE apenas
- Pode deletar depois
- Use para aprender

---

### 6. **03-queries-uteis.sql** 🟡

**O quê?**
- 20+ queries prontas para usar
- Análises e relatórios
- Validações de dados
- Alertas para admin

**Exemplos:**
- Contar acampantes/equipantes
- Ver receita total
- Histórico de uma pessoa
- Verificar integridade
- Listar pagamentos pendentes

**Quando usar?**
- Para análises rápidas
- Para criar dashboards
- Para manutenção

**Como usar?**
- Copie a query que precisa
- Cole em phpMyAdmin
- Customize conforme necessário

---

### 7. **04-integracao-backend.sql** 🟣

**O quê?**
- Queries SQL prontas para Node.js
- Cada query com comentários explicativos
- Exemplos de implementação em JavaScript

**Queries principais:**
- Criar inscrição com histórico
- Criar pagamento
- Processar webhook PagBank
- Validar se pode ser equipante
- Mudar para equipante
- Listar com filtros

**Quando usar?**
- DURANTE desenvolvimento do backend
- Para entender lógica SQL
- Como template de implementação

**Exemplo:**
```sql
-- Validar: pode ser equipante?
SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
FROM historico_tipo_participante
WHERE inscricao_id = ? AND tipo_novo = 'acampante';
```

---

### 8. **05-testes-integridade.sql** 🔴

**O quê?**
- Testes para verificar integridade
- Valida constraints
- Checa anomalias
- Performance dos índices

**Testes inclusos:**
- Integridade referencial
- Integridade de dados
- Validação de regra (equipante após acampante)
- Históricos e cronologia
- Auditoria funcionando
- Pagamentos sincronizados

**Quando executar?**
- Após 01-schema.sql + 02-seeds.sql
- Antes de usar em produção
- Após mudanças grandes

**Resultado esperado:**
```
ANOMALIA: 0 (nenhuma)
VIOLAÇÃO: 0 (nenhuma)
TESTE: PASSOU
INTEGRIDADE: OK ✅
```

---

### 9. **GUIA-NODEJS-MYSQL.md** 📚

**O quê?**
- Guia completo de integração MySQL ↔ Node.js
- Funções prontas de exemplo
- Como usar transactions
- Como implementar cada feature

**Funcionalidades:**
```javascript
criarInscricao()          // Inscrição + histórico
criarPagamento()          // Registrar pagamento
processarWebhookPagBank() // Receber notificações
podeSerEquipante()        // Validar regra
mudarParaEquipante()      // Promover participante
obterInscricao()          // Buscar dados completos
listarInscricoes()        // Com filtros e paginação
```

**Como usar?**
1. Instalar: `npm install mysql2`
2. Criar: `config/database.js`
3. Copiar funções do guia
4. Adaptar para seu projeto
5. Testar cada função

---

## 🎯 ROTEIROS DE USO

### Roteiro 1: Setup Inicial

```
1. Ler: RECOMENDACAO-ESTRUTURA.md (5 min)
   ↓
2. Ler: RESUMO-VISUAL.md (10 min)
   ↓
3. Executar: 01-schema.sql (1 min)
   ↓
4. Executar: 02-seeds.sql (1 min)
   ↓
5. Rodar: 05-testes-integridade.sql (2 min)
   ↓
6. ✅ Banco pronto!
```

**Total: ~20 minutos**

---

### Roteiro 2: Implementação Backend

```
1. Ler: PASSO-A-PASSO.md (10 min)
   ↓
2. Ler: GUIA-NODEJS-MYSQL.md (20 min)
   ↓
3. npm install mysql2 (2 min)
   ↓
4. Criar config/database.js (5 min)
   ↓
5. Copiar funções do guia (30 min)
   ↓
6. Testar cada função (30 min)
   ↓
7. ✅ Backend integrado!
```

**Total: ~2 horas**

---

### Roteiro 3: Análises & Relatórios

```
1. Abrir: 03-queries-uteis.sql
   ↓
2. Encontrar query que precisa
   ↓
3. Copiar e adaptar
   ↓
4. Executar em phpMyAdmin
   ↓
5. Usar resultado para relatório
```

---

### Roteiro 4: Validação & Testes

```
1. Executar: 05-testes-integridade.sql
   ↓
2. Ler cada resultado
   ↓
3. Se algo falhar → Verificar dados
   ↓
4. Se tudo OK → Banco está ótimo!
```

---

## 📋 CHECKLIST

- [ ] Leu RECOMENDACAO-ESTRUTURA.md
- [ ] Leu RESUMO-VISUAL.md
- [ ] Executou 01-schema.sql
- [ ] Executou 02-seeds.sql
- [ ] Rodou 05-testes-integridade.sql
- [ ] Leu PASSO-A-PASSO.md
- [ ] Instalou mysql2 no backend
- [ ] Criou config/database.js
- [ ] Implementou funções do GUIA-NODEJS-MYSQL.md
- [ ] Testou cada função
- [ ] Em produção! 🚀

---

## 🔍 QUANDO USAR CADA ARQUIVO

| Situação | Arquivo |
|----------|---------|
| "Como funciona?" | RECOMENDACAO-ESTRUTURA.md |
| "Mostre visual" | RESUMO-VISUAL.md |
| "Quero começar" | PASSO-A-PASSO.md |
| "Criar tabelas" | 01-schema.sql |
| "Adicionar dados" | 02-seeds.sql |
| "Fazer análise" | 03-queries-uteis.sql |
| "Programar backend" | 04-integracao-backend.sql |
| "Validar dados" | 05-testes-integridade.sql |
| "Como usar MySQL" | GUIA-NODEJS-MYSQL.md |

---

## 💡 DICAS IMPORTANTES

### ✅ DO:
- Execute 01-schema.sql PRIMEIRO
- Execute 02-seeds.sql DEPOIS
- Rode 05-testes-integridade.sql para validar
- Leia os comentários nos arquivos SQL
- Use transactions para testes (ROLLBACK)

### ❌ DON'T:
- NÃO execute seeds sem schema
- NÃO delete tabelas sem backup
- NÃO ignore mensagens de erro
- NÃO mude nomes de tabelas sem atualizar backend
- NÃO coloque credenciais no GitHub

---

## 🆘 PROBLEMAS COMUNS

### "Query error: Unknown column"
- Verificar se executou 01-schema.sql primeiro

### "Duplicate entry for key"
- Email ou UUID já existe
- Use email diferente para testes

### "Foreign key constraint fails"
- Inscrição não existe
- Verificar IDs de inscrição_id

### "No results"
- Dados de teste deletados?
- Executar 02-seeds.sql novamente

---

## 📞 SUPORTE

### Documentação
- `RECOMENDACAO-ESTRUTURA.md` - Conceitos
- `GUIA-NODEJS-MYSQL.md` - Implementação
- `PASSO-A-PASSO.md` - Tutorial

### Recursos
- MySQL Docs: https://dev.mysql.com
- Node.js MySQL2: https://github.com/sidorares/node-mysql2

### Contato
- Para bugs: Verificar testes-integridade.sql
- Para features: Adicionar queries em 03-queries-uteis.sql

---

## 🎉 PARABÉNS!

Você tem um **sistema profissional de banco de dados** com:

✅ Normalização total
✅ Histórico completo
✅ Auditoria total
✅ Validações automáticas
✅ Pronto para produção

**Próximo passo:** Implementar backend conforme GUIA-NODEJS-MYSQL.md

---

**Criado em:** Junho 2026
**Status:** ✅ Pronto para Uso
**Versão:** 1.0

