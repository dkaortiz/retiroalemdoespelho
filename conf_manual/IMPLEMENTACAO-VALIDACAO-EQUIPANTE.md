# ✅ IMPLEMENTAÇÃO: Validação de Acesso Equipante

## 📋 Resumo da Mudança

**Antes**: A página dizia "Você pode escolher qualquer tipo" (incorreto)

**Agora**: 
- Mensagem clara: "Equipante requer ter sido Acampante antes OU ter código de convite"
- Modal com validação automática
- Campo para código de convite (se necessário)
- Backend valida historicamente ou via código

---

## 🚀 Passo 1: Atualizar Banco de Dados

### 1.1 Criar tabela de códigos de convite
Execute em phpMyAdmin:
```sql
-- Arquivo: conf_manual/DB/07-codigos-convite.sql
-- Crie uma nova tabela com os códigos de convite
```

**Colunas principais:**
- `codigo`: Código único (ex: RETIRO2025-ABC123)
- `tipo`: acampante ou equipante
- `ativo`: true/false
- `data_expiracao`: Quando o código expira
- `desconto_percentual`: Desconto se aplicável
- `inscricao_id_usada`: ID de quem usou (NULL até usar)

### 1.2 Dados de exemplo (opcional)
```sql
INSERT INTO codigos_convite (codigo, tipo, desconto_percentual, data_expiracao) 
VALUES 
  ('RETIRO2025-CONVITE001', 'equipante', 0, DATE_ADD(NOW(), INTERVAL 30 DAY)),
  ('RETIRO2025-CONVITE002', 'equipante', 15, DATE_ADD(NOW(), INTERVAL 45 DAY));
```

---

## 🎯 Passo 2: Atualizar Backend Node.js

### 2.1 Adicionar função de validação
Copie do arquivo `conf_manual/backend/validarEquipante.js`:

```javascript
// arquivo: backend/funcoes/validarEquipante.js
async function validarAcessoEquipante(email, codigoConvite = null) {
  // Verifica:
  // 1. Se foi acampante antes (histórico)
  // 2. Se tem código de convite válido
  // Retorna: {permitido, mensagem, desconto}
}
```

### 2.2 Adicionar endpoint Express
No seu `app.js` ou arquivo de rotas:

```javascript
// 1. Importe a função
const { validarAcessoEquipante } = require('./funcoes/validarEquipante');

// 2. Crie a rota
app.post('/api/inscricoes/validar-equipante', async (req, res) => {
    const { email, codigoConvite } = req.body;
    
    if (!email) {
        return res.status(400).json({
            permitido: false,
            mensagem: 'E-mail é obrigatório'
        });
    }

    const resultado = await validarAcessoEquipante(email, codigoConvite);
    res.json(resultado);
});
```

### 2.3 Marcar código como usado (na criação da inscrição)
Quando uma inscrição com código for criada:

```javascript
// Após salvar a inscrição com sucesso
if (dados.tipo === 'equipante' && dados.codigoConvite) {
    await marcarCodigoComoUsado(dados.codigoConvite, inscricaoId);
}
```

---

## 🎨 Passo 3: Frontend (já atualizado!)

### 3.1 Arquivo novo criado
- ✅ `js/inscricao.js` - Toda lógica de modal e validação

### 3.2 Mensagem atualizada
- ✅ Frase antiga removida
- ✅ Nova mensagem: "Equipante requer ter sido Acampante OU código de convite"

### 3.3 Modal com validação
- ✅ Campo "Código de Convite" aparece só para Equipante
- ✅ Função `confirmarInscricaoModal()` valida no backend
- ✅ Mostra mensagem de sucesso ou erro

### 3.4 Fluxo de uso
```
1. Clica em "Equipante"
2. Modal abre com campo de código
3. Clica "Continuar"
4. Frontend chama POST /api/inscricoes/validar-equipante
5. Se OK: vai pro formulário
6. Se NOT OK: mostra erro com orientações
```

---

## 🔍 Fluxos de Uso

### Cenário 1: Acampante (sempre funciona)
```
Usuário → Clica "Acampante" → Modal abre 
→ Clica "Continuar" → Vai direto pro formulário
✅ SEM VALIDAÇÃO (qualquer um pode ser acampante)
```

### Cenário 2: Equipante com histórico de Acampante
```
Usuário → Clica "Equipante" → Modal abre
→ Clica "Continuar" (sem código) → Backend verifica histórico
→ ✅ Encontrou: "você foi acampante em XXXX"
→ Vai pro formulário
```

### Cenário 3: Equipante com código de convite
```
Usuário → Clica "Equipante" → Modal abre
→ Coloca código "RETIRO2025-ABC123" → Clica "Continuar"
→ Backend valida código (ativo? não expirou?)
→ ✅ Código OK → Vai pro formulário
→ Depois que inscrição é criada, código é marcado como usado
```

### Cenário 4: Equipante SEM direito
```
Usuário → Clica "Equipante" → Modal abre
→ Não coloca código → Clica "Continuar"
→ Backend verifica: sem histórico, sem código
→ ❌ "Você não está autorizado. Precisa ter sido acampante antes."
```

---

## 🛠️ Checklist de Implementação

- [ ] Executar `07-codigos-convite.sql` no banco
- [ ] Adicionar `validarEquipante.js` ao backend em `funcoes/`
- [ ] Criar endpoint POST `/api/inscricoes/validar-equipante` no Express
- [ ] Testar validação com email sem histórico + sem código → ❌ erro
- [ ] Testar validação com email sem histórico + código válido → ✅ ok
- [ ] Testar validação com email com histórico → ✅ ok (sem precisar código)
- [ ] Testar fluxo completo: modal → validação → formulário → pagamento
- [ ] Adicionar mensagem de sucesso/erro clara no modal

---

## 📝 Mensagens de Erro/Sucesso

### Erro: Sem autorização
```
❌ Você não está autorizado como equipante. 
É necessário ter participado como acampante antes 
ou ter um código de convite válido.
```

### Sucesso: Verificado por histórico
```
✅ Sua participação anterior como acampante foi verificada!
```

### Sucesso: Verificado por código
```
✅ Código de convite validado com sucesso!
```

### Erro: Código inválido
```
❌ Código de convite inválido ou não encontrado
```

### Erro: Código expirado
```
❌ Código de convite expirado ou inativo
```

---

## 🔐 Notas de Segurança

1. **Validação no Backend**: O frontend valida para UX, mas o backend TAMBÉM deve validar na criação da inscrição
2. **Código de convite não reutilizável**: Após usar, marca como `ativo = FALSE`
3. **Sem exposição de dados**: Não retorna lista de acampantes, só valida se existe
4. **Rate limiting**: Considere adicionar rate limit no endpoint de validação (evita brute force)

---

## 📞 Suporte

**Dúvidas sobre implementação?**
- Verificar se o banco foi atualizado: `SELECT COUNT(*) FROM codigos_convite;`
- Testar endpoint direto: `curl -X POST http://localhost:3000/api/inscricoes/validar-equipante -H "Content-Type: application/json" -d '{"email":"teste@test.com"}'`
- Verificar logs do backend para erros de conexão

---

## 🎉 Pronto!

Após implementar, o sistema garantirá que:
- ✅ Equipantes SÓ podem ser pessoas com histórico OR código
- ✅ Acampantes podem se registrar livremente
- ✅ Mensagens claras explicam os critérios
- ✅ Validação acontece ANTES do formulário (melhor UX)
