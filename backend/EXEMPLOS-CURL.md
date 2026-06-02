# Exemplos de Requisições cURL para API de Inscrições

## 1. Health Check - Verificar se servidor está online

```bash
curl http://localhost:3000/api/health
```

**Resposta esperada:**
```json
{
  "success": true,
  "message": "Servidor funcionando normalmente",
  "timestamp": "2026-06-02T13:50:00.000Z"
}
```

---

## 2. Criar Inscrição - Tipo ACAPANTE

```bash
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Maria da Silva",
    "email": "maria.silva@email.com",
    "telefone": "11987654321",
    "idade": "28",
    "mensagem": "Busco uma transformação profunda e espiritual",
    "tipo": "acapante"
  }'
```

**Resposta esperada:**
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
      "qrCode": "00020126580014br.gov.bcb.pix0123...",
      "linkPagamento": "https://pagbank.com.br/pay/chg_1234567890",
      "criacao": "2026-06-02T13:50:00.000Z"
    }
  }
}
```

---

## 3. Criar Inscrição - Tipo EQUIPANTE

```bash
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Santos",
    "email": "joao.santos@email.com",
    "telefone": "11999999999",
    "idade": "35",
    "mensagem": "Quero equipar outras pessoas nessa jornada",
    "tipo": "equipante"
  }'
```

**Resposta esperada:** (Mesmo formato acima, com valor 199.90)

---

## 4. Criar Inscrição - Dados Mínimos

```bash
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Ana Costa",
    "email": "ana@email.com",
    "tipo": "acapante"
  }'
```

---

## 5. Criar Inscrição - Faltando Campo Obrigatório (ERRO)

```bash
curl -X POST http://localhost:3000/api/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@email.com",
    "tipo": "acapante"
  }'
```

**Resposta esperada (400):**
```json
{
  "success": false,
  "message": "Nome, email e tipo de participação são obrigatórios"
}
```

---

## 6. Listar Todas as Inscrições

```bash
curl http://localhost:3000/api/inscricoes
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "nome": "Maria da Silva",
      "email": "maria.silva@email.com",
      "telefone": "11987654321",
      "idade": "28",
      "mensagem": "Busco uma transformação profunda...",
      "tipo": "acapante",
      "status": "pendente_pagamento",
      "dataCriacao": "2026-06-02T13:50:00.000Z",
      "pagamento": {
        "id": "chg_1234567890",
        "status": "WAITING_PAYMENT",
        ...
      }
    }
  ]
}
```

---

## 7. Obter Inscrição Específica

```bash
curl http://localhost:3000/api/inscricoes/550e8400-e29b-41d4-a716-446655440000
```

**Resposta esperada:** (Dados de uma inscrição específica)

---

## 8. Obter Inscrição - ID Inválido (ERRO)

```bash
curl http://localhost:3000/api/inscricoes/id-invalido-123
```

**Resposta esperada (404):**
```json
{
  "success": false,
  "message": "Inscrição não encontrada"
}
```

---

## 9. Listar Todos os Pagamentos

```bash
curl http://localhost:3000/api/pagamentos
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": [
    {
      "id": "payment-uuid",
      "pagbankId": "chg_1234567890",
      "inscricaoId": "550e8400-e29b-41d4-a716-446655440000",
      "status": "WAITING_PAYMENT",
      "dataPagamento": "2026-06-02T13:50:00.000Z"
    }
  ]
}
```

---

## 10. Simular Webhook do PagBank - Pagamento Confirmado

```bash
curl -X POST http://localhost:3000/api/webhook/pagbank \
  -H "Content-Type: application/json" \
  -d '{
    "id": "chg_1234567890",
    "status": "PAID",
    "reference_id": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**Resposta esperada:**
```json
{
  "success": true,
  "message": "Webhook processado"
}
```

**Efeito:** Status da inscrição muda para `pagamento_confirmado`

---

## 11. Simular Webhook do PagBank - Pagamento Recusado

```bash
curl -X POST http://localhost:3000/api/webhook/pagbank \
  -H "Content-Type: application/json" \
  -d '{
    "id": "chg_1234567890",
    "status": "DECLINED",
    "reference_id": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**Efeito:** Status da inscrição muda para `pagamento_recusado`

---

## 12. Simular Webhook do PagBank - Pagamento Cancelado

```bash
curl -X POST http://localhost:3000/api/webhook/pagbank \
  -H "Content-Type: application/json" \
  -d '{
    "id": "chg_1234567890",
    "status": "CANCELED",
    "reference_id": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**Efeito:** Status da inscrição muda para `cancelado`

---

## Códigos de Status HTTP

| Código | Significado | Exemplo |
|--------|-------------|---------|
| 200 | OK - Sucesso | Inscrição criada, dados retornados |
| 400 | Bad Request - Erro na requisição | Campo obrigatório faltando |
| 404 | Not Found - Não encontrado | ID de inscrição inválido |
| 500 | Server Error - Erro no servidor | Erro ao conectar com PagBank |

---

## Como Testar no Postman

1. Abra Postman
2. Crie nova requisição (New → Request)
3. Selecione método HTTP (POST/GET)
4. Cole a URL: `http://localhost:3000/api/...`
5. Vá para aba "Body"
6. Selecione "raw" e "JSON"
7. Cole o JSON da requisição
8. Clique "Send"

---

## Script Bash para Testar Tudo

```bash
#!/bin/bash
bash backend/test-api.sh
```

---

**Dica:** Use `| jq .` no final para formatar JSON pretty

Exemplo:
```bash
curl http://localhost:3000/api/inscricoes | jq .
```

