// ============================================================
// VALIDAÇÃO DE ACESSO AO TIPO EQUIPANTE
// Arquivo: backend/funcoes/validarEquipante.js
// ============================================================

const db = require('../config/database'); // Ajuste o caminho conforme seu projeto

/**
 * Valida se uma pessoa pode se registrar como Equipante
 * Critérios:
 * 1. OU tem um código de convite válido
 * 2. OU foi acampante em edição anterior
 * 
 * @param {string} email - E-mail da pessoa
 * @param {string} codigoConvite - Código de convite (opcional)
 * @returns {Promise<{permitido: boolean, mensagem: string, desconto?: number}>}
 */
async function validarAcessoEquipante(email, codigoConvite = null) {
    try {
        // 1️⃣ VERIFICAR SE JÁ FOI ACAMPANTE
        const [historico] = await db.execute(`
            SELECT 
                h.id,
                h.data_mudanca,
                i.nome,
                i.tipo_atual
            FROM historico_tipo_participante h
            JOIN inscricoes i ON h.inscricao_id = i.id
            WHERE i.email = ? 
            AND (h.tipo_novo = 'acampante' OR h.tipo_anterior = 'acampante')
            LIMIT 1
        `, [email]);

        if (historico && historico.length > 0) {
            return {
                permitido: true,
                mensagem: '✅ Sua participação anterior como acampante foi verificada!',
                motivo: 'HISTORICO_ACAMPANTE',
                dataParticipacao: historico[0].data_mudanca
            };
        }

        // 2️⃣ VERIFICAR SE TEM CÓDIGO DE CONVITE VÁLIDO
        if (codigoConvite) {
            const [codigo] = await db.execute(`
                SELECT 
                    id,
                    codigo,
                    tipo,
                    desconto_percentual,
                    data_expiracao,
                    (ativo = TRUE AND (data_expiracao IS NULL OR data_expiracao > NOW())) as valido
                FROM codigos_convite
                WHERE UPPER(codigo) = UPPER(?)
            `, [codigoConvite]);

            if (codigo && codigo.length > 0) {
                const c = codigo[0];
                
                if (!c.valido) {
                    return {
                        permitido: false,
                        mensagem: '❌ Código de convite expirado ou inativo'
                    };
                }

                // Código válido!
                return {
                    permitido: true,
                    mensagem: '✅ Código de convite validado com sucesso!',
                    motivo: 'CODIGO_CONVITE_VALIDO',
                    desconto: c.desconto_percentual,
                    codigo: c.codigo
                };
            }

            // Código foi fornecido mas não existe
            return {
                permitido: false,
                mensagem: '❌ Código de convite inválido ou não encontrado'
            };
        }

        // 3️⃣ NÃO TEM HISTÓRICO E NÃO TEM CÓDIGO
        return {
            permitido: false,
            mensagem: '❌ Você não está autorizado como equipante. É necessário ter participado como acampante antes ou ter um código de convite válido.'
        };

    } catch (erro) {
        console.error('Erro ao validar acesso de equipante:', erro);
        return {
            permitido: false,
            mensagem: '⚠️ Erro ao validar acesso. Tente novamente em alguns momentos.',
            erro: erro.message
        };
    }
}

/**
 * Marca um código de convite como usado
 * @param {string} codigoConvite - Código a ser marcado
 * @param {string} inscricaoId - ID da inscrição que usou o código
 */
async function marcarCodigoComoUsado(codigoConvite, inscricaoId) {
    try {
        const [resultado] = await db.execute(`
            UPDATE codigos_convite
            SET 
                data_uso = NOW(),
                ativo = FALSE,
                inscricao_id_usada = ?
            WHERE UPPER(codigo) = UPPER(?)
            AND ativo = TRUE
        `, [inscricaoId, codigoConvite]);

        return resultado.affectedRows > 0;
    } catch (erro) {
        console.error('Erro ao marcar código como usado:', erro);
        return false;
    }
}

/**
 * Lista códigos de convite válidos (para administrativo)
 * @param {boolean} apenasAtivos - Se true, mostra só os ainda disponíveis
 */
async function listarCodigosConvite(apenasAtivos = true) {
    try {
        let query = `
            SELECT 
                id,
                codigo,
                tipo,
                desconto_percentual,
                ativo,
                data_criacao,
                data_expiracao,
                data_uso,
                CASE 
                    WHEN data_uso IS NOT NULL THEN 'USADO'
                    WHEN data_expiracao < NOW() THEN 'EXPIRADO'
                    WHEN ativo = FALSE THEN 'INATIVO'
                    WHEN ativo = TRUE THEN 'DISPONÍVEL'
                END as status
            FROM codigos_convite
        `;

        if (apenasAtivos) {
            query += ` WHERE ativo = TRUE AND (data_expiracao IS NULL OR data_expiracao > NOW())`;
        }

        query += ` ORDER BY data_criacao DESC`;

        const [codigos] = await db.execute(query);
        return codigos;
    } catch (erro) {
        console.error('Erro ao listar códigos:', erro);
        return [];
    }
}

module.exports = {
    validarAcessoEquipante,
    marcarCodigoComoUsado,
    listarCodigosConvite
};
