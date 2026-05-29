# 🚀 Guia para Integração com Backend

Este arquivo contém instruções para integrar um backend com banco de dados quando estiver pronto para adicionar funcionalidades de cadastro, pagamentos e gerenciamento.

## 📋 Opções de Stack Recomendadas

### Opção 1: Node.js + Express (Recomendado para JavaScript)

**Vantagens:**
- Mesmo language (JavaScript) no frontend e backend
- Ecossistema npm muito rico
- Fácil integração com APIs
- Suporte a WebSockets para realtime

**Setup inicial:**
```bash
mkdir backend
cd backend
npm init -y
npm install express cors nodemailer dotenv
npm install -D nodemon
```

**Estrutura:**
```
backend/
├── server.js
├── routes/
├── controllers/
├── models/
├── middleware/
└── config/
```

---

### Opção 2: PHP (Se hospedagem compartilhada)

**Vantagens:**
- Funciona em hospedagem compartilhada
- Suporte universal
- Integração fácil com MySQL

**Setup:**
```bash
mkdir backend
cd backend
touch index.php router.php
```

---

### Opção 3: Python + Django/Flask

**Vantagens:**
- Framework robusto
- Excelente ORM
- Admin panel automático

---

## 🗄️ Banco de Dados

### MongoDB (NoSQL - Flexível)
```bash
npm install mongoose
```

**Schema de Exemplo:**
```javascript
const InscricaoSchema = new mongoose.Schema({
  nome: String,
  email: String,
  telefone: String,
  mensagem: String,
  dataInscricao: { type: Date, default: Date.now },
  status: { type: String, enum: ['pendente', 'confirmado', 'cancelado'] }
});
```

### MySQL (Relacional - Estruturado)
```bash
npm install mysql2 sequelize
```

---

## 💳 Integração com Pagamentos

### Stripe
```bash
npm install stripe
```

### PayPal
```bash
npm install @paypal/sdk-js
```

### Mercado Pago (Brasil)
```bash
npm install mercadopago
```

---

## 📧 Email

### Nodemailer (Node.js)
```javascript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});
```

### SendGrid
```bash
npm install @sendgrid/mail
```

---

## 🔐 Autenticação

### JWT (JSON Web Tokens)
```bash
npm install jsonwebtoken bcryptjs
```

### OAuth com Google
```bash
npm install passport passport-google-oauth20
```

---

## 🌍 Deployment

### Opção 1: Heroku (Simplificado)
```bash
npm install -g heroku
heroku create seu-app
git push heroku main
```

### Opção 2: Railway
- Integração automática com Git
- Variáveis de ambiente fáceis
- Banco de dados incluído

### Opção 3: Render
- Free tier generoso
- Deploy automático
- Suporte a WebSockets

### Opção 4: AWS/Digital Ocean
- Mais controle
- Escalabilidade
- Mais caro

---

## 📝 Exemplo: API com Express

```javascript
// backend/server.js
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Rota para inscrições
app.post('/api/inscricoes', (req, res) => {
  const { nome, email, mensagem } = req.body;
  
  // Validar dados
  if (!nome || !email) {
    return res.status(400).json({ erro: 'Nome e email requeridos' });
  }
  
  // Salvar no banco de dados
  // await Inscricao.create({ nome, email, mensagem });
  
  // Enviar email de confirmação
  // await enviarEmail(email, `Olá ${nome}...`);
  
  res.json({ sucesso: true, mensagem: 'Inscrição recebida!' });
});

app.listen(3000, () => console.log('Servidor rodando na porta 3000'));
```

```javascript
// frontend/js/api.js
const API_URL = 'http://localhost:3000/api';

async function enviarInscricao(nome, email, mensagem) {
  try {
    const response = await fetch(`${API_URL}/inscricoes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nome, email, mensagem })
    });
    
    const data = await response.json();
    return data;
  } catch (erro) {
    console.error('Erro:', erro);
  }
}
```

---

## ⚙️ Variáveis de Ambiente

Crie um arquivo `.env`:
```
PORT=3000
DATABASE_URL=mongodb+srv://user:pass@cluster.mongodb.net/retiro
JWT_SECRET=sua_chave_secreta_aqui
EMAIL_USER=seu_email@gmail.com
EMAIL_PASS=sua_senha_app
STRIPE_KEY=sk_test_xxxxx
```

---

## 🔄 Fluxo de Integração

1. **Criar arquivo `.env.local` no frontend**
```javascript
VITE_API_URL=http://localhost:3000/api
```

2. **Atualizar `js/main.js` para usar API**
```javascript
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const dados = {
    nome: form.querySelector('[name="nome"]').value,
    email: form.querySelector('[name="email"]').value,
    mensagem: form.querySelector('[name="mensagem"]').value
  };
  
  const response = await fetch(`${import.meta.env.VITE_API_URL}/inscricoes`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dados)
  });
  
  const result = await response.json();
  alert('Inscrição enviada com sucesso!');
});
```

---

## 📚 Recursos Úteis

- [Express.js](https://expressjs.com/)
- [Mongoose](https://mongoosejs.com/)
- [Stripe Docs](https://stripe.com/docs)
- [JWT.io](https://jwt.io/)
- [Heroku Deploy](https://devcenter.heroku.com/)

---

## ✅ Checklist para Produção

- [ ] Variáveis de ambiente configuradas
- [ ] Validação de inputs no backend
- [ ] Rate limiting ativado
- [ ] CORS configurado corretamente
- [ ] HTTPS/SSL ativado
- [ ] Logs configurados
- [ ] Backup automático de BD
- [ ] Monitoramento ativo
- [ ] Testes automatizados
- [ ] Documentação de API (Swagger)

---

**Quando estiver pronto, avise! Podemos começar a integração step by step.** 🚀

