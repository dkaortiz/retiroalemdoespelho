# 📚 Guia de Integração MySQL com Node.js (Backend)

## 🎯 Objetivo

Integrar o banco de dados MySQL (Infinity Free) com o backend Node.js Express, mantendo a validação: **"Equipante só após ser Acampante"**

---

## 📦 Dependências Necessárias

```bash
cd backend
npm install mysql2 dotenv
```

**Pacotes:**
- `mysql2` - Driver MySQL para Node.js
- `dotenv` - Variáveis de ambiente

---

## ⚙️ Configuração

### 1. Atualizar `.env`

Adicione ao arquivo `backend/.env`:

```env
# MySQL Configuration
MYSQL_HOST=sql300.infinityfree.com
MYSQL_USER=if0_42031737
MYSQL_PASSWORD=01062021M
MYSQL_DATABASE=if0_42031737_XXX
MYSQL_PORT=3306

# PagBank Configuration
PAGBANK_HOST=https://api.pagbank.com.br
PAGBANK_PUBLIC_KEY=seu_public_key
PAGBANK_SECRET_KEY=seu_secret_key

# Server
PORT=3000
NODE_ENV=development
```

### 2. Criar Arquivo de Conexão

Crie `backend/config/database.js`:

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
  queueLimit: 0,
  timezone: '+00:00'
});

module.exports = pool;
```

### 3. Executar Scripts SQL

1. Acesse phpMyAdmin em Infinity Free
2. Vá para SQL
3. Execute na ordem:
   - `01-schema.sql` (criar tabelas)
   - `02-seeds.sql` (inserir dados de exemplo)

---

## 🔧 Funções Principais no Backend

### A. Criar Inscrição com Histórico

```javascript
const db = require('../config/database');
const { v4: uuidv4 } = require('uuid');

async function criarInscricao(dados) {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    const uuid = uuidv4();
    
    // 1. Inserir inscrição
    const [resultadoInsercao] = await connection.execute(
      `INSERT INTO inscricoes (
        uuid, nome, email, telefone, idade, mensagem,
        tipo_atual, status_pagamento, ativo
      ) VALUES (?, ?, ?, ?, ?, ?, 'acampante', 'pendente', TRUE)`,
      [
        uuid,
        dados.nome,
        dados.email,
        dados.telefone || null,
        dados.idade || null,
        dados.mensagem || null
      ]
    );
    
    const inscricaoId = resultadoInsercao.insertId;
    
    // 2. Registrar no histórico
    await connection.execute(
      `INSERT INTO historico_tipo_participante 
       (inscricao_id, tipo_anterior, tipo_novo, motivo, autorizado_por)
       VALUES (?, NULL, 'acampante', 'Inscrição inicial via website', 'SISTEMA')`,
      [inscricaoId]
    );
    
    // 3. Registrar na auditoria
    await connection.execute(
      `INSERT INTO auditoria 
       (inscricao_id, acao, dados_novo, usuario)
       VALUES (?, 'CRIACAO', ?, 'WEBSITE')`,
      [
        inscricaoId,
        JSON.stringify({
          nome: dados.nome,
          email: dados.email,
          tipo: 'acampante'
        })
      ]
    );
    
    await connection.commit();
    
    return { inscricaoId, uuid };
    
  } catch (erro) {
    await connection.rollback();
    console.error('Erro ao criar inscrição:', erro);
    throw erro;
  } finally {
    connection.release();
  }
}
```

### B. Criar Pagamento

```javascript
async function criarPagamento(inscricaoId, pagbankId, valor) {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    // 1. Inserir pagamento
    await connection.execute(
      `INSERT INTO pagamentos 
       (inscricao_id, pagbank_id, valor, status)
       VALUES (?, ?, ?, 'WAITING_PAYMENT')`,
      [inscricaoId, pagbankId, valor]
    );
    
    // 2. Registrar na auditoria
    await connection.execute(
      `INSERT INTO auditoria 
       (inscricao_id, acao, dados_novo, usuario)
       VALUES (?, 'CRIACAO_COBRANCA', ?, 'PAGBANK_API')`,
      [
        inscricaoId,
        JSON.stringify({
          pagbank_id: pagbankId,
          valor: valor
        })
      ]
    );
    
    await connection.commit();
    return true;
    
  } catch (erro) {
    await connection.rollback();
    throw erro;
  } finally {
    connection.release();
  }
}
```

### C. Processar Webhook do PagBank

```javascript
async function processarWebhookPagBank(dadosWebhook) {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    const { id: pagbankId, status, reference_id } = dadosWebhook;
    
    // 1. Obter inscrição
    const [inscricoes] = await connection.execute(
      `SELECT i.id, i.status_pagamento FROM inscricoes i
       JOIN pagamentos p ON i.id = p.inscricao_id
       WHERE p.pagbank_id = ?`,
      [pagbankId]
    );
    
    if (inscricoes.length === 0) {
      throw new Error('Inscrição não encontrada para este pagamento');
    }
    
    const inscricaoId = inscricoes[0].id;
    const statusAtual = inscricoes[0].status_pagamento;
    
    // 2. Mapear status
    const statusMapeado = {
      'PAID': 'pago',
      'DECLINED': 'recusado',
      'CANCELED': 'cancelado'
    }[status] || 'pendente';
    
    // 3. Atualizar pagamento
    await connection.execute(
      `UPDATE pagamentos 
       SET status = ?, data_pagamento = CASE 
         WHEN ? = 'PAID' THEN NOW() ELSE NULL 
       END,
       data_webhook = NOW()
       WHERE pagbank_id = ?`,
      [status, status, pagbankId]
    );
    
    // 4. Atualizar inscrição
    await connection.execute(
      `UPDATE inscricoes 
       SET status_pagamento = ?,
           data_pagamento = CASE 
             WHEN ? = 'PAID' THEN NOW() ELSE NULL 
           END
       WHERE id = ?`,
      [statusMapeado, status, inscricaoId]
    );
    
    // 5. Registrar na auditoria
    await connection.execute(
      `INSERT INTO auditoria 
       (inscricao_id, acao, dados_anterior, dados_novo, usuario)
       VALUES (?, 'WEBHOOK_PAGAMENTO', ?, ?, 'PAGBANK_WEBHOOK')`,
      [
        inscricaoId,
        JSON.stringify({ status: statusAtual }),
        JSON.stringify({ status: statusMapeado })
      ]
    );
    
    await connection.commit();
    return { inscricaoId, statusMapeado };
    
  } catch (erro) {
    await connection.rollback();
    throw erro;
  } finally {
    connection.release();
  }
}
```

### D. Validar Pode Ser Equipante

```javascript
async function podeSerEquipante(inscricaoId) {
  const connection = await db.getConnection();
  
  try {
    const [resultado] = await connection.execute(
      `SELECT 
        CASE 
          WHEN COUNT(h.id) > 0 THEN 1
          ELSE 0
        END as pode
       FROM inscricoes i
       LEFT JOIN historico_tipo_participante h ON i.id = h.inscricao_id
         AND (h.tipo_novo = 'acampante' OR h.tipo_anterior = 'acampante')
       WHERE i.id = ?`,
      [inscricaoId]
    );
    
    return resultado[0].pode === 1;
    
  } finally {
    connection.release();
  }
}
```

### E. Mudar para Equipante

```javascript
async function mudarParaEquipante(inscricaoId, motivo = '', autorizado_por = 'ADMIN') {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    // 1. Validar se pode virar equipante
    const pode = await podeSerEquipante(inscricaoId);
    if (!pode) {
      throw new Error('Usuário precisa ter sido acampante antes de virar equipante');
    }
    
    // 2. Obter tipo atual
    const [inscricoes] = await connection.execute(
      'SELECT tipo_atual FROM inscricoes WHERE id = ?',
      [inscricaoId]
    );
    
    if (inscricoes.length === 0) {
      throw new Error('Inscrição não encontrada');
    }
    
    const tipoAnterior = inscricoes[0].tipo_atual;
    
    // 3. Atualizar tipo
    await connection.execute(
      'UPDATE inscricoes SET tipo_atual = ? WHERE id = ?',
      ['equipante', inscricaoId]
    );
    
    // 4. Registrar no histórico
    await connection.execute(
      `INSERT INTO historico_tipo_participante 
       (inscricao_id, tipo_anterior, tipo_novo, motivo, autorizado_por)
       VALUES (?, ?, 'equipante', ?, ?)`,
      [inscricaoId, tipoAnterior, motivo, autorizado_por]
    );
    
    // 5. Registrar na auditoria
    await connection.execute(
      `INSERT INTO auditoria 
       (inscricao_id, acao, dados_anterior, dados_novo, usuario)
       VALUES (?, 'MUDANCA_TIPO', ?, ?, ?)`,
      [
        inscricaoId,
        JSON.stringify({ tipo: tipoAnterior }),
        JSON.stringify({ tipo: 'equipante' }),
        autorizado_por
      ]
    );
    
    await connection.commit();
    return true;
    
  } catch (erro) {
    await connection.rollback();
    throw erro;
  } finally {
    connection.release();
  }
}
```

### F. Obter Inscrição Completa

```javascript
async function obterInscricao(inscricaoId) {
  const connection = await db.getConnection();
  
  try {
    // 1. Obter dados principais
    const [inscricoes] = await connection.execute(
      `SELECT 
        id, uuid, nome, email, telefone, idade, tipo_atual,
        status_pagamento, data_criacao, data_pagamento
       FROM inscricoes WHERE id = ?`,
      [inscricaoId]
    );
    
    if (inscricoes.length === 0) {
      return null;
    }
    
    const inscricao = inscricoes[0];
    
    // 2. Obter histórico
    const [historico] = await connection.execute(
      `SELECT tipo_anterior, tipo_novo, data_mudanca, motivo
       FROM historico_tipo_participante
       WHERE inscricao_id = ?
       ORDER BY data_mudanca DESC`,
      [inscricaoId]
    );
    
    // 3. Obter pagamentos
    const [pagamentos] = await connection.execute(
      `SELECT id, pagbank_id, valor, status, data_criacao, data_pagamento
       FROM pagamentos
       WHERE inscricao_id = ?
       ORDER BY data_criacao DESC`,
      [inscricaoId]
    );
    
    return {
      ...inscricao,
      historico,
      pagamentos
    };
    
  } finally {
    connection.release();
  }
}
```

### G. Listar Inscrições com Filtros

```javascript
async function listarInscricoes(filtros = {}, pagina = 1, limite = 20) {
  const connection = await db.getConnection();
  
  try {
    let query = 'SELECT * FROM inscricoes WHERE ativo = TRUE';
    const params = [];
    
    // Filtros
    if (filtros.tipo) {
      query += ' AND tipo_atual = ?';
      params.push(filtros.tipo);
    }
    
    if (filtros.status_pagamento) {
      query += ' AND status_pagamento = ?';
      params.push(filtros.status_pagamento);
    }
    
    if (filtros.email) {
      query += ' AND email LIKE ?';
      params.push(`%${filtros.email}%`);
    }
    
    // Ordenação
    query += ' ORDER BY data_criacao DESC';
    
    // Paginação
    const offset = (pagina - 1) * limite;
    query += ' LIMIT ? OFFSET ?';
    params.push(limite, offset);
    
    const [inscricoes] = await connection.execute(query, params);
    
    // Contar total
    let countQuery = 'SELECT COUNT(*) as total FROM inscricoes WHERE ativo = TRUE';
    const countParams = [];
    
    if (filtros.tipo) {
      countQuery += ' AND tipo_atual = ?';
      countParams.push(filtros.tipo);
    }
    
    if (filtros.status_pagamento) {
      countQuery += ' AND status_pagamento = ?';
      countParams.push(filtros.status_pagamento);
    }
    
    const [countResult] = await connection.execute(countQuery, countParams);
    const total = countResult[0].total;
    
    return {
      dados: inscricoes,
      paginacao: {
        total,
        pagina,
        limite,
        totalPaginas: Math.ceil(total / limite)
      }
    };
    
  } finally {
    connection.release();
  }
}
```

---

## 🔌 Integração no Backend Express

### Atualizar `backend/server.js`

```javascript
const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/database');
const { criarInscricao, mudarParaEquipante, obterInscricao } = require('./controllers/inscricoes');

const app = express();

app.use(express.json());
app.use(cors());

// ============================================================
// ROTAS DE INSCRIÇÃO
// ============================================================

// POST /api/inscricoes - Criar inscrição
app.post('/api/inscricoes', async (req, res) => {
  try {
    const { nome, email, tipo, ...dados } = req.body;
    
    // Validar
    if (!nome || !email || !tipo) {
      return res.status(400).json({
        success: false,
        message: 'Nome, email e tipo são obrigatórios'
      });
    }
    
    // Validar tipo
    if (!['acampante', 'equipante'].includes(tipo)) {
      return res.status(400).json({
        success: false,
        message: 'Tipo inválido'
      });
    }
    
    // Criar inscrição
    const { inscricaoId, uuid } = await criarInscricao({
      nome, email, tipo, ...dados
    });
    
    // Gerar cobrança no PagBank
    const valor = tipo === 'acampante' ? 299.90 : 199.90;
    const pagbankData = await gerarCobrancaPagBank(inscricaoId, valor);
    
    res.json({
      success: true,
      data: {
        inscricaoId: uuid,
        pagamento: pagbankData
      }
    });
    
  } catch (erro) {
    console.error(erro);
    res.status(500).json({
      success: false,
      message: erro.message
    });
  }
});

// GET /api/inscricoes/:id - Obter inscrição
app.get('/api/inscricoes/:uuid', async (req, res) => {
  try {
    // Aqui você buscaria pelo UUID
    const inscricao = await obterInscricao(req.params.uuid);
    
    if (!inscricao) {
      return res.status(404).json({
        success: false,
        message: 'Inscrição não encontrada'
      });
    }
    
    res.json({ success: true, data: inscricao });
    
  } catch (erro) {
    res.status(500).json({ success: false, message: erro.message });
  }
});

// ============================================================
// WEBHOOK PAGBANK
// ============================================================

app.post('/api/webhook/pagbank', async (req, res) => {
  try {
    const { id, status, reference_id } = req.body;
    
    const resultado = await processarWebhookPagBank({
      id, status, reference_id
    });
    
    res.json({ success: true, data: resultado });
    
  } catch (erro) {
    res.status(500).json({ success: false, message: erro.message });
  }
});

// ============================================================
// ADMIN: Mudar para Equipante
// ============================================================

app.post('/api/admin/mudar-equipante/:inscricaoId', async (req, res) => {
  try {
    const { inscricaoId } = req.params;
    const { motivo } = req.body;
    
    // TODO: Validar autenticação
    
    await mudarParaEquipante(
      parseInt(inscricaoId),
      motivo,
      'admin@retiro.com.br'
    );
    
    res.json({
      success: true,
      message: 'Tipo mudado com sucesso para Equipante'
    });
    
  } catch (erro) {
    res.status(400).json({
      success: false,
      message: erro.message
    });
  }
});

// ============================================================
// INICIAR SERVIDOR
// ============================================================

app.listen(process.env.PORT || 3000, () => {
  console.log(`✅ Servidor rodando na porta ${process.env.PORT || 3000}`);
});
```

---

## ✅ Checklist de Implementação

- [ ] Pacotes instalados: `npm install mysql2`
- [ ] `.env` configurado com credenciais MySQL
- [ ] Scripts SQL executados (01-schema, 02-seeds)
- [ ] `config/database.js` criado
- [ ] Funções de inscrição implementadas
- [ ] Webhook implementado
- [ ] Testes realizados
- [ ] Deploy em produção

---

## 🧪 Testes

```bash
# Test 1: Criar Inscrição
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste DB",
    "email": "teste@db.com",
    "tipo": "acampante"
  }'

# Test 2: Obter Inscrição
curl http://localhost:3000/api/inscricoes/{uuid}

# Test 3: Webhook
curl -X POST http://localhost:3000/api/webhook/pagbank \
  -H "Content-Type: application/json" \
  -d '{
    "id": "chg_123",
    "status": "PAID",
    "reference_id": "{uuid}"
  }'
```

