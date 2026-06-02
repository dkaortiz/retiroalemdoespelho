// ============================================================
// PAGBANK INTEGRATION - Frontend
// ============================================================

const API_BASE_URL = 'http://localhost:3000/api';

/**
 * Enviar inscrição e iniciar processo de pagamento
 */
async function enviarInscricaoComPagamento(formData) {
    try {
        // Mostrar loading
        const submitBtn = document.getElementById('submitBtn');
        const originalText = submitBtn.querySelector('span').textContent;
        submitBtn.disabled = true;
        submitBtn.querySelector('span').textContent = 'Processando...';

        // Enviar para backend
        const response = await fetch(`${API_BASE_URL}/inscricoes`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });

        const resultado = await response.json();

        if (!resultado.success) {
            throw new Error(resultado.message || 'Erro ao processar inscrição');
        }

        // Sucesso! Mostrar link de pagamento
        mostrarTelaConfirmacao(resultado.data);

    } catch (erro) {
        console.error('Erro:', erro);
        alert('❌ Erro ao processar inscrição: ' + erro.message);
        document.getElementById('submitBtn').disabled = false;
        document.getElementById('submitBtn').querySelector('span').textContent = 'Tentar Novamente';
    }
}

/**
 * Mostrar tela de confirmação com link de pagamento
 */
function mostrarTelaConfirmacao(dados) {
    const formulario = document.getElementById('formInscricao');
    const container = formulario.parentElement;

    // Criar HTML da confirmação
    const html = `
        <div class="relative" data-aos="zoom-in">
            <div class="absolute -inset-1 bg-gradient-to-r from-green-600 via-green-500 to-green-600 rounded-2xl blur-2xl opacity-40 animate-pulse"></div>
            
            <div class="relative bg-gradient-to-br from-slate-900 via-black to-slate-950 border-2 border-green-500/50 rounded-2xl p-8 md:p-16 backdrop-blur-xl text-center">
                <div class="text-6xl mb-6">✅</div>
                
                <h2 class="font-playfair text-4xl md:text-5xl font-bold mb-4 leading-tight">
                    <span class="block text-white mb-2">Inscrição Criada!</span>
                    <span class="block bg-gradient-to-r from-green-300 via-green-400 to-green-600 bg-clip-text text-transparent">Proceda com o Pagamento</span>
                </h2>
                
                <p class="text-gray-300 text-lg md:text-xl mb-8 leading-relaxed max-w-2xl mx-auto">
                    Sua inscrição foi registrada com sucesso! Agora finalize o pagamento para confirmar sua participação.
                </p>

                <div class="bg-gradient-to-r from-yellow-950/40 to-black border-l-4 border-yellow-500 p-6 md:p-8 rounded-lg backdrop-blur-sm mb-8 text-left">
                    <p class="text-yellow-100 font-semibold mb-4">📋 Detalhes da Inscrição:</p>
                    <div class="space-y-2 text-gray-300 text-sm">
                        <p>💰 <strong>Valor:</strong> R$ ${dados.pagamento.valor.toFixed(2)}</p>
                        <p>📝 <strong>Tipo:</strong> ${document.getElementById('tipoPart').value === 'acapante' ? 'Acapante (Aprendizado Profundo)' : 'Equipante (Apoio e Suporte)'}</p>
                        <p>🔐 <strong>Ref. Inscrição:</strong> ${dados.inscricaoId.substring(0, 8)}...</p>
                    </div>
                </div>

                <div class="space-y-4">
                    ${dados.pagamento.linkPagamento ? `
                        <a href="${dados.pagamento.linkPagamento}" target="_blank" class="inline-block group relative px-8 py-4 bg-gradient-to-r from-green-500 to-green-600 text-white font-bold rounded-lg overflow-hidden transition-all duration-300 hover:shadow-2xl hover:shadow-green-500/50 transform hover:scale-105 w-full md:w-auto">
                            <span class="relative z-10">💳 Pagar Agora</span>
                            <div class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
                        </a>
                    ` : ''}
                    
                    ${dados.pagamento.qrCode ? `
                        <div class="mt-6 p-4 bg-black/50 rounded-lg border border-yellow-500/30">
                            <p class="text-yellow-200 text-sm mb-3">📱 Ou escaneie o QR Code:</p>
                            <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(dados.pagamento.qrCode)}" alt="QR Code Pagamento" class="w-48 h-48 mx-auto">
                        </div>
                    ` : ''}
                </div>

                <div class="mt-8 p-4 bg-yellow-950/20 border border-yellow-700/30 rounded-lg">
                    <p class="text-gray-300 text-sm">
                        ⏰ <strong>Validade:</strong> O link de pagamento está válido por 24 horas<br>
                        📧 Confirmaremos seu pagamento e enviaremos um e-mail de confirmação
                    </p>
                </div>

                <button onclick="location.href='index.html'" class="mt-6 group relative px-6 py-3 bg-gradient-to-r from-yellow-400 to-yellow-500 text-black font-bold rounded-lg overflow-hidden transition-all duration-300">
                    <span class="relative z-10">← Voltar ao Início</span>
                </button>
            </div>
        </div>
    `;

    // Remover formulário e mostrar confirmação
    formulario.style.display = 'none';
    container.innerHTML = html;
}

/**
 * Verificar status de pagamento
 */
async function verificarStatusPagamento(inscricaoId) {
    try {
        const response = await fetch(`${API_BASE_URL}/inscricoes/${inscricaoId}`);
        const resultado = await response.json();

        if (resultado.success) {
            return resultado.data.status;
        }
        return null;

    } catch (erro) {
        console.error('Erro ao verificar status:', erro);
        return null;
    }
}

/**
 * Inicializar integração de pagamento
 */
export {
    enviarInscricaoComPagamento,
    verificarStatusPagamento,
    mostrarTelaConfirmacao
};
