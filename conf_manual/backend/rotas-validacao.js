// ============================================================
// ROTA: POST /api/inscricoes/validar-equipante
// Valida se pessoa pode se registrar como equipante
// ============================================================

const express = require('express');
const router = express.Router();
const { validarAcessoEquipante, marcarCodigoComoUsado } = require('../funcoes/validarEquipante');

/**
 * POST /api/inscricoes/validar-equipante
 * 
 * Body:
 * {
 *   "email": "pessoa@email.com",
 *   "codigoConvite": "RETIRO2025-ABC123" (opcional)
 * }
 * 
 * Response:
 * {
 *   "permitido": true/false,
 *   "mensagem": "descrição do resultado",
 *   "motivo": "HISTORICO_ACAMPANTE" | "CODIGO_CONVITE_VALIDO",
 *   "desconto": 0-100 (se aplicável)
 * }
 */
router.post('/validar-equipante', async (req, res) => {
    try {
        const { email, codigoConvite } = req.body;

        if (!email) {
            return res.status(400).json({
                permitido: false,
                mensagem: 'E-mail é obrigatório'
            });
        }

        // Validar formato de email básico
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                permitido: false,
                mensagem: 'E-mail inválido'
            });
        }

        // Chamar função de validação
        const resultado = await validarAcessoEquipante(email, codigoConvite);

        // Se foi aprovado com código, marcar como usado (será feito na criação da inscrição também)
        if (resultado.permitido && codigoConvite && resultado.motivo === 'CODIGO_CONVITE_VALIDO') {
            // Não marca aqui, vai marcar quando a inscrição for de fato criada
            console.log(`✅ Código ${codigoConvite} validado para ${email}`);
        }

        return res.json(resultado);

    } catch (erro) {
        console.error('Erro em /validar-equipante:', erro);
        res.status(500).json({
            permitido: false,
            mensagem: 'Erro ao validar. Tente novamente.',
            erro: processo.env.NODE_ENV === 'development' ? erro.message : undefined
        });
    }
});

// ============================================================
// ROTA: GET /api/inscricoes/codigos (ADMINISTRATIVO)
// Lista códigos de convite disponíveis
// ============================================================

router.get('/codigos', async (req, res) => {
    try {
        // Aqui você deve adicionar autenticação/autorização
        // Por enquanto é exemplo apenas
        const { listarCodigosConvite } = require('../funcoes/validarEquipante');
        const codigos = await listarCodigosConvite(false);

        return res.json({
            total: codigos.length,
            codigos: codigos
        });

    } catch (erro) {
        console.error('Erro ao listar códigos:', erro);
        res.status(500).json({
            erro: 'Erro ao listar códigos'
        });
    }
});

module.exports = router;
