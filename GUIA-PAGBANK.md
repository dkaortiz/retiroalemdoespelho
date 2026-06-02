# 💳 Guia de Integração PagBank - Retiro Além do Espelho

## 📋 Sumário

Este guia detalha como implementar o sistema de pagamento integrado com PagBank para inscrições no retiro.

---

## ⚙️ Pré-requisitos

- Node.js 16+ instalado
- Conta no PagBank
- Credenciais de API do PagBank (PUBLIC_KEY e SECRET_KEY)
- Terminal/Command Line

---

## 🚀 Instalação Rápida

### 1. Instalar Dependências do Backend

```bash
cd backend
npm install
```

### 2. Configurar Variáveis de Ambiente

Copie o arquivo `.env.example` para `.env`:

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais do PagBank:

```env
# PagBank Configuration
PAGBANK_HOST=https://api.pagbank.com.br
PAGBANK_PUBLIC_KEY=seu_public_key_aqui
PAGBANK_SECRET_KEY=seu_secret_key_aqui

# Server Configuration
PORT=3000
NODE_ENV=development

# Frontend URL
FRONTEND_URL=http://localhost:5500
```

### 3. Obter Credenciais do PagBank

1. Acesse: https://developer.pagbank.com.br
2. Faça login ou crie uma conta
3. Vá para "Minhas Aplicações"
4. Crie uma nova aplicação
5. Copie suas chaves (PUBLIC_KEY e SECRET_KEY)
6. Cole no arquivo `.env`

### 4. Iniciar o Servidor Backend

```bash
npm start
# ou modo desenvolvimento com auto-reload
npm run dev
```

O servidor iniciará em: `http://localhost:3000`

---

## 📁 Estrutura de Arquivos

```
RETIRO-SITE/
├── backend/
│   ├── server.js              # Servidor Express principal
│   ├── package.json           # Dependências
│   ├── .env.example           # Exemplo de configuração
│   └── .env                   # ⚠️ Credenciais (não fazer commit!)
├── js/
│   ├── main.js               # JS principal
│   └── pagamento.js          # Integração PagBank Frontend
├── inscricao.html            # Página de inscrição (ATUALIZADA)
└── ...outros arquivos
```

---

## 🔄 Fluxo de Funcionamento

```
1. Usuário acessa página de inscrição
   ↓
2. Seleciona tipo (Acapante ou Equipante)
   ↓
3. Preenche formulário
   ↓
4. Clica em "Finalizar Inscrição"
   ↓
5. Frontend envia dados para backend
   ↓
6. Backend cria inscrição no banco
   ↓
7. Backend chama API PagBank para gerar cobrança
   ↓
8. PagBank retorna link de pagamento
   ↓
9. Frontend mostra link para usuário
   ↓
10. Usuário clica e vai para PagBank
   ↓
11. Usuário realiza pagamento
   ↓
12. PagBank envia webhook confirmando pagamento
   ↓
13. Backend atualiza status da inscrição
   ↓
14. ✅ Inscrição confirmada!
```

---

## 💰 Valores de Inscrição

Configure no `backend/server.js` na função `definirValorPorTipo()`:

```javascript
function definirValorPorTipo(tipo) {
    const valores = {
        'acapante': 299.90,    // Valor em Reais
        'equipante': 199.90
    };
    return valores[tipo] || 299.90;
}
```

---

## 🔐 Dados Enviados ao PagBank

```json
{
    "reference_id": "uuid-da-inscricao",
    "description": "Inscrição Retiro Além do Espelho - Acapante",
    "amount": {
        "value": 29990
    },
    "customer": {
        "name": "Nome do Participante",
        "email": "email@exemplo.com",
        "phone": {
            "country": "55",
            "area": "11",
            "number": "999999999"
        }
    },
    "notification_urls": [
        "https://seu-dominio.com/api/webhook/pagbank"
    ]
}
```

---

## 📊 Respostas do Backend

### Criar Inscrição com Sucesso

**Request:**
```bash
POST http://localhost:3000/api/inscricoes
Content-Type: application/json

{
    "nome": "João Silva",
    "email": "joao@email.com",
    "telefone": "11999999999",
    "idade": "30",
    "mensagem": "Desejo transformação profunda",
    "tipo": "acapante"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Inscrição criada e cobrança gerada com sucesso!",
    "data": {
        "inscricaoId": "550e8400-e29b-41d4-a716-446655440000",
        "pagamento": {
            "id": "chg_1234567890",
            "status": "WAITING_PAYMENT",
            "referencia": "550e8400-e29b-41d4-a716-446655440000",
            "valor": 299.90,
            "qrCode": "00020126580014br.gov.bcb.pix...",
            "linkPagamento": "https://pagbank.com.br/pay/...",
            "criacao": "2026-06-02T13:50:00.000Z"
        }
    }
}
```

### Erro na Inscrição

**Response (400/500):**
```json
{
    "success": false,
    "message": "Erro ao gerar cobrança. Tente novamente.",
    "erro": "Detalhes do erro..."
}
```

---

## 🔗 Endpoints Disponíveis

### POST `/api/inscricoes`
Criar inscrição e gerar cobrança

**Corpo esperado:**
- `nome` (obrigatório)
- `email` (obrigatório)
- `telefone` (opcional)
- `idade` (opcional)
- `mensagem` (opcional)
- `tipo` (obrigatório: 'acapante' ou 'equipante')

### GET `/api/inscricoes/:id`
Obter dados de uma inscrição específica

### GET `/api/inscricoes`
Listar todas as inscrições (use com cuidado em produção)

### POST `/api/webhook/pagbank`
Webhook para receber notificações do PagBank

### GET `/api/pagamentos`
Listar todos os pagamentos

### GET `/api/health`
Verificar se servidor está online

---

## ⚠️ Configuração de Webhook

1. No painel do PagBank, vá para **Webhooks**
2. Adicione URL do webhook:
   ```
   https://seu-dominio.com/api/webhook/pagbank
   ```
3. Selecione eventos: `charge.completed`, `charge.failed`, `charge.canceled`
4. Salve as alterações

---

## 🧪 Testando Localmente

### Iniciar Servidor

```bash
cd backend
npm run dev
```

### Fazer Requisição Teste

```bash
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste User",
    "email": "teste@email.com",
    "telefone": "11999999999",
    "tipo": "acapante"
  }'
```

### Verificar Inscrições

```bash
curl http://localhost:3000/api/inscricoes
```

---

## 📱 Resposta no Frontend

Após enviar a inscrição, o usuário vê:

1. ✅ Mensagem de sucesso
2. 📋 Resumo da inscrição
3. 💳 Botão "Pagar Agora" (link para PagBank)
4. 📱 QR Code para pagamento (se disponível)
5. ⏰ Informação de validade do link (24h)

---

## 🚨 Tratamento de Erros

### Erro: "Conexão recusada em localhost:3000"
- Verifique se o servidor backend está rodando
- Execute `npm run dev` na pasta `backend/`

### Erro: "Credenciais inválidas"
- Verifique sua PUBLIC_KEY e SECRET_KEY no `.env`
- Confirme se estão corretas no PagBank

### Erro: "CORS bloqueado"
- Verifique se `FRONTEND_URL` no `.env` está correto
- Certifique-se de que o frontend está na porta correta

### Erro: "Email já cadastrado"
- Valide emails duplicados no banco
- Implemente verificação antes de criar

---

## 📈 Próximos Passos

- [ ] Implementar banco de dados (PostgreSQL/MongoDB)
- [ ] Sistema de autenticação para admin
- [ ] Dashboard para gerenciar inscrições
- [ ] Envio automático de e-mails
- [ ] Certificado digital pós-pagamento
- [ ] Integração com Whatsapp
- [ ] Relatórios de inscrições e pagamentos
- [ ] Sistema de reembolso automatizado

---

## 📧 Integração de E-mail (Próximo)

```javascript
// Enviar e-mail após pagamento confirmado
const nodemailer = require('nodemailer');
const transporter = nodemailer.createTransport({...});

await transporter.sendMail({
    to: inscricao.email,
    subject: '✅ Pagamento confirmado - Retiro Além do Espelho',
    html: `<h1>Bem-vindo!</h1>...`
});
```

---

## 🔗 Recursos Úteis

- **Documentação PagBank**: https://developer.pagbank.com.br
- **API Reference**: https://developer.pagbank.com.br/reference/introducao
- **Status Codes**: https://developer.pagbank.com.br/docs/status-codes
- **Webhook Events**: https://developer.pagbank.com.br/docs/webhooks

---

## ✅ Checklist de Implementação

- [ ] Backend instalado e dependências instaladas
- [ ] Arquivo `.env` criado com credenciais PagBank
- [ ] Servidor rodando na porta 3000
- [ ] Frontend testando requisições POST
- [ ] Webhook configurado no PagBank
- [ ] Testes de inscrição e pagamento realizados
- [ ] Banco de dados conectado
- [ ] E-mails configurados
- [ ] Deploy em produção

---

**Versão**: 1.0 | **Data**: Junho 2026 | **Status**: 🚀 Pronto para Implementação

