#!/bin/bash
# Script de teste para API de Inscrições e Pagamentos

API_URL="http://localhost:3000/api"

echo "🧪 Testando API de Inscrições"
echo "=============================="
echo ""

# 1. Health Check
echo "1️⃣ Verificando se servidor está online..."
curl -s ${API_URL}/health | jq .
echo ""
echo ""

# 2. Listar inscrições
echo "2️⃣ Listando inscrições (vazio no começo)..."
curl -s ${API_URL}/inscricoes | jq .
echo ""
echo ""

# 3. Criar inscrição com tipo Acapante
echo "3️⃣ Criando inscrição tipo ACAPANTE..."
RESPONSE_ACAPANTE=$(curl -s -X POST ${API_URL}/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Maria Silva",
    "email": "maria@exemplo.com",
    "telefone": "11987654321",
    "idade": "28",
    "mensagem": "Busco transformação profunda e espiritual",
    "tipo": "acapante"
  }')

echo $RESPONSE_ACAPANTE | jq .
INSCRICAO_ID=$(echo $RESPONSE_ACAPANTE | jq -r '.data.inscricaoId')
echo ""
echo "✅ ID da Inscrição Acapante: $INSCRICAO_ID"
echo ""
echo ""

# 4. Criar inscrição com tipo Equipante
echo "4️⃣ Criando inscrição tipo EQUIPANTE..."
RESPONSE_EQUIPANTE=$(curl -s -X POST ${API_URL}/inscricoes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Santos",
    "email": "joao@exemplo.com",
    "telefone": "11999999999",
    "idade": "35",
    "mensagem": "Desejo equipar outras pessoas nesta jornada",
    "tipo": "equipante"
  }')

echo $RESPONSE_EQUIPANTE | jq .
echo ""
echo ""

# 5. Listar inscrições novamente
echo "5️⃣ Listando inscrições após criação..."
curl -s ${API_URL}/inscricoes | jq .
echo ""
echo ""

# 6. Obter detalhes de uma inscrição específica
echo "6️⃣ Obtendo detalhes da inscrição: $INSCRICAO_ID"
curl -s ${API_URL}/inscricoes/${INSCRICAO_ID} | jq .
echo ""
echo ""

# 7. Listar pagamentos
echo "7️⃣ Listando pagamentos..."
curl -s ${API_URL}/pagamentos | jq .
echo ""
echo ""

echo "✅ Testes concluídos!"
echo ""
echo "📝 Próximas etapas:"
echo "  1. Abra o link de pagamento do PagBank"
echo "  2. Complete o pagamento"
echo "  3. O webhook notificará o servidor"
echo "  4. Status da inscrição será atualizado"
