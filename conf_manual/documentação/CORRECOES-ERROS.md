# ❌ NÃO APAGUE 01-schema.sql!

## 🔴 IMPORTANTE

**NÃO delete `01-schema.sql`** - Este arquivo é ESSENCIAL!

```
01-schema.sql = Arquivo que CRIA as tabelas ← NUNCA DELETE
02-seeds.sql = Dados de exemplo
03-queries-uteis.sql = Queries prontas (AGORA CORRIGIDO)
04-integracao-backend.sql = Template para Node.js
05-testes-integridade.sql = Testes (AGORA CORRIGIDO)
```

---

## 🔧 Para Começar do Zero

Se quer **limpar tudo e começar de novo**:

### Opção 1: Deletar Dados (Manter Tabelas)

Em phpMyAdmin → SQL:

```sql
-- Deletar tudo mas manter estrutura
DELETE FROM auditoria;
DELETE FROM pagamentos;
DELETE FROM inscricoes_edicoes;
DELETE FROM historico_tipo_participante;
DELETE FROM inscricoes;
DELETE FROM edicoes;

-- Depois execute:
02-seeds.sql
```

### Opção 2: Resetar Completamente (Deletar Tudo)

Em phpMyAdmin → SQL:

```sql
-- Opção 2A: Delete CASCADE (mais simples)
DELETE FROM edicoes;
DELETE FROM inscricoes;

-- Ou Opção 2B: DROP (deleta estrutura também)
DROP TABLE IF EXISTS inscricoes_edicoes;
DROP TABLE IF EXISTS pagamentos;
DROP TABLE IF EXISTS auditoria;
DROP TABLE IF EXISTS historico_tipo_participante;
DROP TABLE IF EXISTS inscricoes;
DROP TABLE IF EXISTS edicoes;

-- Depois execute:
01-schema.sql  (recria as tabelas)
02-seeds.sql   (insere dados novos)
```

---

## ✅ Arquivos AGORA CORRIGIDOS

### 03-queries-uteis.sql ✅
- **ANTES:** Erro de privilégio FILE (OUTFILE não funciona no Infinity Free)
- **DEPOIS:** Removido OUTFILE, query segura para Infinity Free

### 04-integracao-backend.sql ✅
- **ANTES:** Erro de placeholders `?` (SQL puro não aceita)
- **DEPOIS:** Adicionado aviso explicando que é TEMPLATE para Node.js, não para phpMyAdmin

### 05-testes-integridade.sql ✅
- **ANTES:** Erro de sintaxe com comentários `---`
- **DEPOIS:** Convertido em `SELECT '---' as separador;`

---

## 🚀 Próximas Ações

### Se quer começar do zero:
```
1. Executar Opção 2B acima (DROP tudo)
2. Executar: 01-schema-infinity-free.sql
3. Executar: 02-seeds.sql
4. ✅ Novo banco limpo!
```

### Se quer só limpar dados:
```
1. Executar Opção 1 acima (DELETE dados)
2. Executar: 02-seeds.sql
3. ✅ Dados limpos, estrutura intacta!
```

### Se quer só usar:
```
1. 01-schema-infinity-free.sql (se não criou ainda)
2. 02-seeds.sql
3. Usar queries do 03-queries-uteis.sql
4. Backend usa templates do 04-integracao-backend.sql
5. Testes do 05-testes-integridade.sql
```

---

## 📋 Qual Arquivo Usar?

| Arquivo | Para Quê | Execute em phpMyAdmin? |
|---------|----------|----------------------|
| `01-schema-infinity-free.sql` | Criar tabelas | ✅ SIM (1º) |
| `02-seeds.sql` | Dados de exemplo | ✅ SIM (2º) |
| `03-queries-uteis.sql` | Análises/relatórios | ✅ SIM (selecionar queries) |
| `04-integracao-backend.sql` | Template Node.js | ❌ NÃO (copiar código) |
| `05-testes-integridade.sql` | Validar banco | ✅ SIM (selecionar queries) |

---

## 🎯 RESUMO

✅ **NÃO delete `01-schema.sql`** (ou qualquer arquivo SQL)
✅ **Use `01-schema-infinity-free.sql`** em vez do `01-schema.sql` (sem VIEWs)
✅ **Erros já corrigidos** em 03, 04 e 05
✅ **Para começar do zero**, execute DROP + schema + seeds

**Seu banco está pronto para usar! 🎉**

