import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import { v4 as uuidv4 } from 'uuid';
import axios from 'axios';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:5500',
    credentials: true
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Database (em memória para desenvolvimento - usar SQLite ou PostgreSQL em produção)
let inscricoes = [];
let pagamentos = [];

// ============================================================
// ROTAS DE INSCRIÇÃO
// ============================================================

// GET - Listar todas as inscrições (apenas admin)
app.get('/api/inscricoes', (req, res) => {
    res.json({ success: true, data: inscricoes });
});

// POST - Criar inscrição e gerar cobrança
app.post('/api/inscricoes', async (req, res) => {
    try {
        const { nome, email, telefone, idade, mensagem, tipo } = req.body;

        // Validações
        if (!nome || !email || !tipo) {
            return res.status(400).json({
                success: false,
                message: 'Nome, email e tipo de participação são obrigatórios'
            });
        }

        // Criar registro de inscrição
        const inscricaoId = uuidv4();
        const novaInscricao = {
            id: inscricaoId,
            nome,
            email,
            telefone: telefone || null,
            idade: idade || null,
            mensagem: mensagem || null,
            tipo,
            status: 'pendente_pagamento',
            dataCriacao: new Date().toISOString(),
            pagamento: null
        };

        // Gerar cobrança no PagBank
        const cobranca = await gerarCobrancaPagBank({
            id: inscricaoId,
            nome,
            email,
            telefone,
            tipo,
            valor: definirValorPorTipo(tipo)
        });

        if (!cobranca.success) {
            return res.status(500).json({
                success: false,
                message: 'Erro ao gerar cobrança. Tente novamente.',
                erro: cobranca.erro
            });
        }

        // Vincular pagamento à inscrição
        novaInscricao.pagamento = cobranca.dados;

        // Salvar inscrição
        inscricoes.push(novaInscricao);

        res.json({
            success: true,
            message: 'Inscrição criada e cobrança gerada com sucesso!',
            data: {
                inscricaoId,
                pagamento: cobranca.dados
            }
        });

    } catch (erro) {
        console.error('Erro ao criar inscrição:', erro);
        res.status(500).json({
            success: false,
            message: 'Erro ao processar inscrição',
            erro: erro.message
        });
    }
});

// ============================================================
// PAGBANK INTEGRATION
// ============================================================

/**
 * Gerar cobrança via PagBank
 */
async function gerarCobrancaPagBank(dados) {
    try {
        const pagbankUrl = `${process.env.PAGBANK_HOST}/charges`;

        const payload = {
            reference_id: dados.id,
            description: `Inscrição Retiro Além do Espelho - ${dados.tipo}`,
            amount: {
                value: dados.valor * 100 // PagBank usa centavos
            },
            customer: {
                name: dados.nome,
                email: dados.email,
                phone: {
                    country: '55',
                    area: dados.telefone ? dados.telefone.substring(0, 2) : '11',
                    number: dados.telefone ? dados.telefone.substring(2) : '999999999'
                }
            },
            notification_urls: [
                `${process.env.FRONTEND_URL || 'http://localhost:3000'}/api/webhook/pagbank`
            ]
        };

        const config = {
            headers: {
                'Authorization': `Bearer ${process.env.PAGBANK_SECRET_KEY}`,
                'Content-Type': 'application/json'
            }
        };

        const response = await axios.post(pagbankUrl, payload, config);

        return {
            success: true,
            dados: {
                id: response.data.id,
                status: response.data.status,
                referencia: response.data.reference_id,
                valor: dados.valor,
                qrCode: response.data.qr_codes?.[0]?.id_qr_code || null,
                linkPagamento: response.data.links?.find(l => l.rel === 'PAYMENT')?.href || null,
                criacao: new Date().toISOString()
            }
        };

    } catch (erro) {
        console.error('Erro ao gerar cobrança PagBank:', erro.response?.data || erro.message);
        return {
            success: false,
            erro: erro.response?.data?.message || erro.message
        };
    }
}

/**
 * Definir valor da inscrição conforme tipo
 */
function definirValorPorTipo(tipo) {
    const valores = {
        'acapante': 299.90, // Valor de exemplo em reais
        'equipante': 199.90
    };
    return valores[tipo] || 299.90;
}

// ============================================================
// WEBHOOK - Receber notificações do PagBank
// ============================================================

app.post('/api/webhook/pagbank', async (req, res) => {
    try {
        const { id, status, reference_id } = req.body;

        console.log('Webhook recebido:', { id, status, reference_id });

        // Buscar inscrição correspondente
        const inscricao = inscricoes.find(i => i.id === reference_id);

        if (!inscricao) {
            return res.status(404).json({ success: false, message: 'Inscrição não encontrada' });
        }

        // Atualizar status baseado no status do PagBank
        if (status === 'PAID') {
            inscricao.status = 'pagamento_confirmado';
            inscricao.pagamento.status = 'PAGO';
            
            // Aqui você pode:
            // - Enviar e-mail de confirmação
            // - Gerar certificado
            // - Adicionar à lista de participantes
            console.log(`✅ Pagamento confirmado para: ${inscricao.email}`);
        } else if (status === 'DECLINED') {
            inscricao.status = 'pagamento_recusado';
            inscricao.pagamento.status = 'RECUSADO';
            console.log(`❌ Pagamento recusado para: ${inscricao.email}`);
        } else if (status === 'CANCELED') {
            inscricao.status = 'cancelado';
            inscricao.pagamento.status = 'CANCELADO';
            console.log(`⚠️ Pagamento cancelado para: ${inscricao.email}`);
        }

        // Registrar pagamento
        pagamentos.push({
            id: uuidv4(),
            pagbankId: id,
            inscricaoId: reference_id,
            status: status,
            dataPagamento: new Date().toISOString()
        });

        res.json({ success: true, message: 'Webhook processado' });

    } catch (erro) {
        console.error('Erro ao processar webhook:', erro);
        res.status(500).json({ success: false, erro: erro.message });
    }
});

// ============================================================
// ROTAS DE VERIFICAÇÃO
// ============================================================

// GET - Verificar status de inscrição
app.get('/api/inscricoes/:id', (req, res) => {
    const inscricao = inscricoes.find(i => i.id === req.params.id);
    
    if (!inscricao) {
        return res.status(404).json({ success: false, message: 'Inscrição não encontrada' });
    }

    res.json({ success: true, data: inscricao });
});

// GET - Listar pagamentos
app.get('/api/pagamentos', (req, res) => {
    res.json({ success: true, data: pagamentos });
});

// ============================================================
// HEALTH CHECK
// ============================================================

app.get('/api/health', (req, res) => {
    res.json({ 
        success: true, 
        message: 'Servidor funcionando normalmente',
        timestamp: new Date().toISOString()
    });
});

// ============================================================
// ERROR HANDLING
// ============================================================

app.use((err, req, res, next) => {
    console.error('Erro:', err);
    res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
        erro: process.env.NODE_ENV === 'development' ? err.message : 'Erro desconhecido'
    });
});

// ============================================================
// START SERVER
// ============================================================

app.listen(PORT, () => {
    console.log(`\n🚀 Servidor rodando em http://localhost:${PORT}`);
    console.log(`📝 Inscrições: http://localhost:${PORT}/api/inscricoes`);
    console.log(`💳 Pagamentos: http://localhost:${PORT}/api/pagamentos`);
    console.log(`\n⚙️ Ambiente: ${process.env.NODE_ENV}\n`);
});

export default app;
