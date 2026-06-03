// ============================================================
// INSCRIÇÃO COM MODAL - Validação de Equipante
// ============================================================

const API_BASE_URL = 'http://localhost:3000/api';
let tipoSelecionado = null;

// Dados dos tipos com estilos diferentes
const tiposInfo = {
    'acampante': {
        icon: '🎓',
        title: 'Acampante',
        subtitle: 'Aprendizado Profundo',
        desc: 'Mergulhe completamente na experiência transformadora. Você participará de todas as atividades e sessões.',
        valor: 'R$ 299,90',
        features: [
            '🎯 Acesso a todas as sessões',
            '👥 Participação em dinâmicas em grupo',
            '💬 Acompanhamento personalizado',
            '📜 Certificado de participação',
            '🌍 Comunidade exclusiva pós-retiro'
        ],
        info1: '💰 Investimento: R$ 299,90',
        info2: '✓ Ideal para: Quem quer transformação completa',
        info3: '🎯 Duração: 5 dias intensivos',
        glowColor: 'from-blue-600 to-cyan-500',
        btnColor: 'from-blue-600 to-cyan-500'
    },
    'equipante': {
        icon: '⚡',
        title: 'Equipante',
        subtitle: 'Apoio e Suporte',
        desc: 'Apoie e equipe outros participantes. Você será mentor e facilitador da transformação alheia.',
        valor: 'R$ 199,90',
        features: [
            '🎓 Treinamento prévio especializado',
            '👫 Acompanhamento de pequenos grupos',
            '❤️ Suporte emocional qualificado',
            '✨ Experiência transformadora compartilhada',
            '⭐ Reconhecimento especial'
        ],
        info1: '💰 Investimento: R$ 199,90',
        info2: '✓ Ideal para: Quem quer impactar outras vidas',
        info3: '🎯 Duração: 5 dias + treinamento',
        glowColor: 'from-purple-600 to-pink-500',
        btnColor: 'from-purple-600 to-pink-500'
    }
};

// Abrir Modal de Inscrição
function abrirModalInscricao(tipo) {
    tipoSelecionado = tipo;
    const info = tiposInfo[tipo];
    const modal = document.getElementById('modalInscricao');
    const glowBg = document.getElementById('glowBg');
    
    // Atualizar cores do modal
    glowBg.className = `absolute -inset-1 rounded-3xl blur-2xl opacity-60 animate-pulse bg-gradient-to-r ${info.glowColor}`;
    
    // Atualizar conteúdo
    document.getElementById('modalIcon').textContent = info.icon;
    document.getElementById('modalTitle').textContent = info.title;
    document.getElementById('modalSubtitle').textContent = info.subtitle;
    document.getElementById('modalDesc').textContent = info.desc;
    document.getElementById('info1').textContent = info.info1;
    document.getElementById('info2').textContent = info.info2;
    document.getElementById('info3').textContent = info.info3;
    
    // Atualizar features
    const featuresContainer = document.getElementById('modalFeatures');
    featuresContainer.innerHTML = info.features.map(feature => `
        <div class="flex items-start gap-3 p-2">
            <span class="text-lg flex-shrink-0">${feature.split(' ')[0]}</span>
            <span class="text-gray-300 text-sm">${feature.substring(feature.indexOf(' ') + 1)}</span>
        </div>
    `).join('');
    
    // Atualizar botão
    const btnConfirmar = document.getElementById('btnConfirmarModal');
    btnConfirmar.className = `flex-1 px-6 py-3 bg-gradient-to-r ${info.btnColor} text-white font-semibold rounded-xl transition duration-300 transform hover:scale-105`;
    btnConfirmar.textContent = `Continuar como ${info.title} →`;
    
    // Mostrar campo de código apenas para Equipante
    const codigoContainer = document.getElementById('codigoConviteContainer');
    if (tipo === 'equipante') {
        codigoContainer.classList.remove('hidden');
    } else {
        codigoContainer.classList.add('hidden');
        document.getElementById('codigoConvite').value = '';
    }
    
    // Abrir modal
    modal.classList.remove('hidden');
}

// Fechar Modal
function fecharModalInscricao() {
    document.getElementById('modalInscricao').classList.add('hidden');
    tipoSelecionado = null;
    document.getElementById('codigoConvite').value = '';
}

// Confirmar inscrição (com validação para Equipante)
async function confirmarInscricaoModal() {
    if (!tipoSelecionado) {
        alert('Tipo não selecionado');
        return;
    }

    // Validação para Equipante
    if (tipoSelecionado === 'equipante') {
        const email = document.querySelector('input[type="email"]').value;
        const codigoConvite = document.getElementById('codigoConvite').value;
        
        if (!email) {
            alert('❌ Por favor, preencha seu e-mail para validarmos seu acesso como equipante');
            return;
        }

        // Tentar validar se pode ser equipante
        const btnConfirmar = document.getElementById('btnConfirmarModal');
        const originalText = btnConfirmar.textContent;
        btnConfirmar.disabled = true;
        btnConfirmar.textContent = '⏳ Validando acesso...';

        try {
            const validacao = await fetch(`${API_BASE_URL}/inscricoes/validar-equipante`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, codigoConvite })
            }).then(r => r.json());

            if (!validacao.permitido) {
                alert('❌ ' + validacao.mensagem + '\n\n💡 Você pode:\n1. Ter sido Acampante em edição anterior\n2. Ter um código de convite válido\n\nEntre em contato conosco para mais informações.');
                btnConfirmar.disabled = false;
                btnConfirmar.textContent = originalText;
                return;
            }

            // Validação passou!
            btnConfirmar.textContent = '✅ Acesso confirmado!';
            setTimeout(() => {
                fecharModalInscricao();
                document.getElementById('formulario').scrollIntoView({ behavior: 'smooth' });
            }, 1000);

        } catch (erro) {
            console.error('Erro na validação:', erro);
            alert('⚠️ Erro ao validar. Verifique sua conexão e tente novamente.');
            btnConfirmar.disabled = false;
            btnConfirmar.textContent = originalText;
        }
        return;
    }

    // Acampante não precisa validação
    fecharModalInscricao();
    document.getElementById('formulario').scrollIntoView({ behavior: 'smooth' });
}

// Função legado (compatibilidade)
function selectType(type) {
    abrirModalInscricao(type);
}

// ============================================================
// FORMULÁRIO DE INSCRIÇÃO
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
    const formInscricao = document.getElementById('formInscricao');
    
    if (formInscricao) {
        formInscricao.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            if (!tipoSelecionado) {
                alert('❌ Por favor, selecione um tipo de participação');
                return;
            }

            // Coletar dados
            const formElements = formInscricao.elements;
            const dados = {
                nome: formElements[1].value,
                email: formElements[2].value,
                telefone: formElements[3].value || null,
                idade: formElements[4].value || null,
                mensagem: formElements[5].value || null,
                tipo: tipoSelecionado
            };

            // Validar obrigatórios
            if (!dados.nome || !dados.email) {
                alert('❌ Nome e e-mail são obrigatórios!');
                return;
            }

            // Mostrar loading
            const submitBtn = document.getElementById('submitBtn');
            const originalText = submitBtn.querySelector('span').textContent;
            submitBtn.disabled = true;
            submitBtn.querySelector('span').textContent = '⏳ Processando inscrição...';

            try {
                const response = await fetch(`${API_BASE_URL}/inscricoes`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(dados)
                });

                const resultado = await response.json();

                if (!resultado.success) {
                    throw new Error(resultado.message || 'Erro ao processar inscrição');
                }

                mostrarTelaConfirmacao(resultado.data, dados);

            } catch (erro) {
                console.error('Erro:', erro);
                alert('❌ Erro: ' + erro.message + '\n\nTente novamente em alguns momentos.');
                submitBtn.disabled = false;
                submitBtn.querySelector('span').textContent = originalText;
            }
        });
    }
});

// Tela de Confirmação
function mostrarTelaConfirmacao(dados, dadosForm) {
    const formulario = document.getElementById('formInscricao');
    const container = formulario.parentElement;
    const valor = tipoSelecionado === 'acampante' ? '299,90' : '199,90';
    const tipoLabel = tipoSelecionado === 'acampante' ? '🎓 Acampante' : '⚡ Equipante';

    const html = `
        <div class="relative" data-aos="zoom-in">
            <div class="absolute -inset-1 bg-gradient-to-r from-green-600 via-green-500 to-green-600 rounded-2xl blur-2xl opacity-40 animate-pulse"></div>
            
            <div class="relative bg-gradient-to-br from-slate-900 via-black to-slate-950 border-2 border-green-500/50 rounded-2xl p-8 md:p-16 backdrop-blur-xl text-center">
                <div class="text-6xl mb-6 animate-bounce">✅</div>
                
                <h2 class="font-playfair text-4xl md:text-5xl font-bold mb-4 leading-tight">
                    <span class="block text-white mb-2">Inscrição Criada!</span>
                    <span class="block bg-gradient-to-r from-green-300 via-green-400 to-green-600 bg-clip-text text-transparent">Proceda com o Pagamento</span>
                </h2>
                
                <p class="text-gray-300 text-lg md:text-xl mb-8 leading-relaxed max-w-2xl mx-auto">
                    Sua inscrição foi registrada com sucesso! Agora finalize o pagamento para confirmar sua participação no retiro.
                </p>

                <div class="bg-gradient-to-r from-yellow-950/40 to-black border-l-4 border-yellow-500 p-6 md:p-8 rounded-lg backdrop-blur-sm mb-8 text-left">
                    <p class="text-yellow-100 font-semibold mb-4">📋 Detalhes da Inscrição:</p>
                    <div class="space-y-2 text-gray-300 text-sm">
                        <p>👤 <strong>Nome:</strong> ${dadosForm.nome}</p>
                        <p>📧 <strong>E-mail:</strong> ${dadosForm.email}</p>
                        <p>💰 <strong>Valor:</strong> <span class="text-yellow-400 font-bold">R$ ${valor}</span></p>
                        <p>📝 <strong>Tipo:</strong> ${tipoLabel}</p>
                        <p>🔐 <strong>ID:</strong> ${dados.inscricaoId.substring(0, 12)}...</p>
                    </div>
                </div>

                <div class="space-y-4 mb-8">
                    ${dados.pagamento?.linkPagamento ? `
                        <a href="${dados.pagamento.linkPagamento}" target="_blank" rel="noopener noreferrer" class="inline-block group relative px-8 py-4 bg-gradient-to-r from-green-500 to-green-600 text-white font-bold rounded-lg overflow-hidden transition-all duration-300 hover:shadow-2xl hover:shadow-green-500/50 transform hover:scale-105">
                            <span class="relative z-10">💳 Realizar Pagamento via PagBank</span>
                            <div class="absolute inset-0 bg-white/20 transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
                        </a>
                    ` : `
                        <div class="p-4 bg-red-950/40 border border-red-700/50 rounded-lg">
                            <p class="text-red-200">⚠️ Link de pagamento indisponível. Tente novamente em alguns momentos.</p>
                        </div>
                    `}
                </div>

                <div class="mt-8 p-4 bg-yellow-950/20 border border-yellow-700/30 rounded-lg text-left">
                    <p class="text-gray-300 text-sm">
                        <strong>⏰ Validade:</strong> O link está válido por 24 horas<br>
                        <strong>📧 Confirmação:</strong> Enviaremos e-mail com os detalhes do pagamento<br>
                        <strong>🎯 Próximos passos:</strong> Após confirmação, receberá material do retiro
                    </p>
                </div>
            </div>
        </div>
    `;

    formulario.style.display = 'none';
    container.innerHTML = html;
}

// Fechar modal ao clicar fora
document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('modalInscricao');
    if (modal) {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                fecharModalInscricao();
            }
        });
    }
});
