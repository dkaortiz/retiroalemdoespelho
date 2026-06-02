# 🚀 Checklist de Implementação - Sistema de Pagamento PagBank

## ✨ Status: Pronto para Ativar!

O frontend está **100% pronto** e o backend está **configurado**. Siga os passos abaixo para ativar o sistema.

---

## 📋 Pré-Requisitos

- [ ] Node.js 16+ instalado (`node -v` para verificar)
- [ ] Git (opcional)
- [ ] Uma conta no PagBank
- [ ] Credenciais PagBank obtidas (PUBLIC_KEY e SECRET_KEY)

---

## 🔧 Instalação (10 minutos)

### Passo 1: Instalar Dependências do Backend

```bash
cd backend
npm install
```

**O quê vai instalar:**
- express (servidor web)
- axios (requisições HTTP)
- dotenv (variáveis de ambiente)
- cors (segurança cross-origin)
- uuid (IDs únicos)
- sqlite3 (banco de dados futuro)

**⏱️ Tempo:** 2-3 minutos

---

### Passo 2: Obter Credenciais do PagBank

Acesse: **https://developer.pagbank.com.br**

1. Faça login ou crie conta
2. Vá para "Minha Aplicação" ou "Aplicações"
3. Crie uma nova aplicação
4. Copie sua **PUBLIC_KEY** e **SECRET_KEY**
5. Anote em um lugar seguro

---

### Passo 3: Criar Arquivo `.env`

Dentro da pasta `backend/`, crie um arquivo `.env`:

```bash
# No terminal/PowerShell
cd backend

# macOS/Linux
cp .env.example .env

# Windows PowerShell
Copy-Item .env.example .env
```

Abra o arquivo `.env` e edite com suas credenciais:

```env
# PagBank Configuration
PAGBANK_HOST=https://api.pagbank.com.br
PAGBANK_PUBLIC_KEY=sua_public_key_aqui
PAGBANK_SECRET_KEY=sua_secret_key_aqui

# Server Configuration
PORT=3000
NODE_ENV=development

# Frontend URL
FRONTEND_URL=http://localhost:5500
```

**⚠️ IMPORTANTE:** Não compartilhe este arquivo! Adicione ao `.gitignore`:

```
backend/.env
```

---

### Passo 4: Iniciar o Servidor

```bash
# Ainda dentro de backend/
npm start
```

**Você deve ver:**
```
✅ Servidor iniciado com sucesso
📍 Escutando na porta 3000
🌍 Ambiente: development
```

**⏱️ Tempo:** 30 segundos

---

## ✅ Testar o Sistema (5 minutos)

### Verificar se Servidor Está Online

**No terminal/PowerShell abra outra aba:**

```bash
# Teste 1: Health Check
curl http://localhost:3000/api/health

# Resposta esperada:
# {"success":true,"message":"Servidor funcionando..."}
```

### Criar Inscrição de Teste

```bash
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste",
    "email": "teste@exemplo.com",
    "tipo": "acapante"
  }'
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": {
    "inscricaoId": "uuid-aqui",
    "pagamento": {
      "linkPagamento": "https://pagbank.com.br/pay/...",
      "qrCode": "00020126..."
    }
  }
}
```

✅ Se receber o link de pagamento = **Sistema funcionando!**

---

## 🌐 Testar no Frontend

### 1. Abrir Página de Inscrição

1. Abra `inscricao.html` no navegador
   - Via VS Code: clique direito → "Open with Live Server"
   - Ou: `open inscricao.html` (macOS)
   
2. **Ou** hospede em servidor local:
   ```bash
   # Python 3
   python -m http.server 5500
   
   # Node.js
   npx http-server -p 5500
   ```

3. Acesse: `http://localhost:5500/inscricao.html`

### 2. Fazer Inscrição Teste

1. Selecione tipo: **Acapante** ou **Equipante**
2. Preencha formulário:
   - Nome: seu nome
   - Email: seu email
   - Telefone: seu telefone
   - Idade: sua idade

3. Clique: **"Finalizar Inscrição"**

### 3. Confirmar Link de Pagamento

Você deve ver:
- ✅ Mensagem de sucesso
- 💳 Botão com link de pagamento
- 📋 Resumo de dados
- ⏰ Informação de validade (24h)

---

## 📱 Testes de Pagamento

### Teste 1: Pagamento Real (Após Teste Inicial)

1. Clique no botão "Realizar Pagamento via PagBank"
2. Será redirecionado para PagBank
3. Complete o pagamento com cartão/PIX
4. Retornar ao site (webhook atualizará status)

### Teste 2: Simulação de Webhook

```bash
# Simular pagamento confirmado
curl -X POST http://localhost:3000/api/webhook/pagbank \
  -H "Content-Type: application/json" \
  -d '{
    "id": "chg_123",
    "status": "PAID",
    "reference_id": "uuid-da-inscricao"
  }'
```

---

## 🔄 Fluxo Completo de Teste

```
1. ✅ Servidor rodando (npm start)
   ↓
2. ✅ Frontend acessível (http://localhost:5500)
   ↓
3. ✅ Usuário acessa inscricao.html
   ↓
4. ✅ Seleciona tipo (Acapante/Equipante)
   ↓
5. ✅ Preenche formulário
   ↓
6. ✅ Clica em "Finalizar Inscrição"
   ↓
7. ✅ Backend recebe dados (POST /api/inscricoes)
   ↓
8. ✅ Backend cria inscrição
   ↓
9. ✅ Backend chama API PagBank
   ↓
10. ✅ PagBank retorna link de pagamento
    ↓
11. ✅ Frontend mostra link
    ↓
12. ✅ Usuário clica no link
    ↓
13. ✅ Vai para PagBank
    ↓
14. ✅ Realiza pagamento
    ↓
15. ✅ PagBank envia webhook
    ↓
16. ✅ Backend atualiza status
    ↓
17. ✅ Inscrição confirmada!
```

---

## 📊 Verificar Inscrições

```bash
# Listar todas as inscrições
curl http://localhost:3000/api/inscricoes | jq .

# Obter inscrição específica
curl http://localhost:3000/api/inscricoes/uuid-da-inscricao | jq .

# Listar todos os pagamentos
curl http://localhost:3000/api/pagamentos | jq .
```

---

## 🐛 Troubleshooting

### ❌ Erro: "Conexão recusada localhost:3000"

**Solução:**
```bash
cd backend
npm start
```

Aguarde a mensagem: `✅ Servidor iniciado com sucesso`

---

### ❌ Erro: "MODULE_NOT_FOUND: express"

**Solução:**
```bash
cd backend
npm install
```

---

### ❌ Erro: "Credenciais inválidas"

**Verificar:**
1. PUBLIC_KEY e SECRET_KEY estão corretos?
2. Copie exatamente do PagBank (sem espaços)
3. Reinicie servidor: `npm start`

---

### ❌ Erro: "CORS bloqueado"

**Solução:**
- Verifique se FRONTEND_URL está correto em `.env`
- Port do frontend deve ser 5500
- Reinicie servidor

---

### ❌ Link de pagamento não aparece

**Verificar:**
1. Abra Console do navegador (F12)
2. Veja mensagens de erro
3. Verifique se servidor está rodando
4. Confirme que credenciais PagBank estão corretas

---

## 🚀 Deploy em Produção (Futura)

Quando estiver pronto para produção:

1. Altere `NODE_ENV=production`
2. Configure credenciais reais no `.env`
3. Configure webhook URL real
4. Implemente banco de dados (PostgreSQL/MongoDB)
5. Implemente HTTPS
6. Configure variáveis de produção
7. Deploy em servidor (Heroku, AWS, Azure, DigitalOcean, etc.)

---

## 📚 Documentação Adicional

- [GUIA-PAGBANK.md](./GUIA-PAGBANK.md) - Guia completo de integração
- [EXEMPLOS-CURL.md](./backend/EXEMPLOS-CURL.md) - Exemplos de requisições
- [PagBank API Docs](https://developer.pagbank.com.br)

---

## ✨ Status Checklist

- [ ] Node.js instalado
- [ ] npm install realizado em backend/
- [ ] Credenciais PagBank obtidas
- [ ] Arquivo .env criado
- [ ] Servidor iniciado (npm start)
- [ ] Health check funcionando
- [ ] Inscrição de teste criada
- [ ] Link de pagamento recebido
- [ ] Frontend testado
- [ ] Pagamento teste realizado

---

## 📞 Suporte

Para dúvidas sobre:
- **PagBank**: https://developer.pagbank.com.br/support
- **Express.js**: https://expressjs.com/
- **Node.js**: https://nodejs.org/

---

**🎉 Parabéns! Seu sistema de pagamento está pronto!**

**Próximas sugestões:**
1. Adicionar envio de e-mails
2. Criar dashboard de admin
3. Implementar banco de dados persistente
4. Configurar certificado SSL
5. Deploy em servidor real

