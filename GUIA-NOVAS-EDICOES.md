# 🎯 Guia de Customização - Adicionar Novas Edições

## Como Adicionar uma Nova Edição

### Passo 1: Atualizar edicoes.html

Após a seção da edição atual, adicione:

```html
<!-- 2ª Edition Example -->
<div class="mb-24" data-aos="fade-up">
    <div class="inline-block mb-6">
        <span class="px-4 py-2 bg-gradient-to-r from-green-600/20 to-emerald-700/20 border border-green-500/30 rounded-full text-green-300 text-xs font-semibold tracking-widest uppercase backdrop-blur-sm">
            🟢 PRÓXIMA EDIÇÃO
        </span>
    </div>
    
    <h2 class="font-playfair text-5xl md:text-6xl font-bold mb-8 leading-tight">
        <span class="block text-white mb-3">2ª Edição:</span>
        <span class="block bg-gradient-to-r from-green-300 via-emerald-300 to-teal-600 bg-clip-text text-transparent">NOME DA EDIÇÃO</span>
    </h2>

    <div class="grid md:grid-cols-2 gap-12 items-center">
        <!-- Left - Content -->
        <div data-aos="fade-right">
            <p class="text-gray-300 text-lg leading-relaxed mb-6">
                Descrição da edição...
            </p>
            <!-- ... resto do conteúdo ... -->
        </div>
        <!-- Right - Visual -->
        <div data-aos="fade-left" class="relative h-96">
            <!-- ... visual da edição ... -->
        </div>
    </div>
</div>
```

### Passo 2: Cores para Cada Edição

Use cores diferentes para cada edição:

- **1ª Edição - O Confronto**: Vermelho/Âmbar (red/amber)
- **2ª Edição - Sugestão**: Verde/Esmeralda (green/emerald)
- **3ª Edição - Sugestão**: Azul/Ciano (blue/cyan)
- **4ª Edição - Sugestão**: Roxo/Violeta (purple/violet)

### Passo 3: Atualizar o Menu

Se criar uma nova edição "oficial", considere adicionar um menu dropdown:

```html
<li class="relative group">
    <button class="hover:text-amber-300 transition">Edições ▼</button>
    <div class="hidden group-hover:block absolute top-full left-0 bg-black/95 border border-amber-500/30 rounded-lg p-2 min-w-max">
        <a href="edicoes.html#confronto" class="block px-4 py-2 hover:text-amber-300">1ª - O Confronto</a>
        <a href="edicoes.html#proxima" class="block px-4 py-2 hover:text-amber-300">2ª - Nova Edição</a>
    </div>
</li>
```

## Estrutura de Temas Sugeridos

### Tema 1: O Confronto ✅ (Implementado)
- **Foco**: Enfrentamento de verdades
- **Cor**: Vermelho/Âmbar
- **Ícone**: 💔
- **Pilares**: Confronto, Quebra, Encontro, Cura, Identidade

### Tema 2: A Reconstrução (Sugerido)
- **Foco**: Cura e reconstrução
- **Cor**: Verde/Esmeralda
- **Ícone**: 🌱
- **Pilares**: Aceitação, Forgiveness, Estrutura, Força, Renovação

### Tema 3: A Libertação (Sugerido)
- **Foco**: Liberdade e propósito
- **Cor**: Dourado/Âmbar claro
- **Ícone**: 🦅
- **Pilares**: Libertação, Propósito, Visão, Ação, Legado

### Tema 4: O Retorno (Sugerido)
- **Foco**: Reencontro com Deus
- **Cor**: Azul Celeste
- **Ícone**: ✨
- **Pilares**: Fé, Comunhão, Paz, Alegria, Eternidade

## Variações de Design

### Cards dos Pilares
Para mudar a aparência dos cards dos pilares:

```html
<div class="group relative card-hover" data-aos="zoom-in">
    <div class="absolute -inset-0.5 bg-gradient-to-r from-[NOVA-COR-1] to-[NOVA-COR-2] rounded-2xl blur opacity-0 group-hover:opacity-100 transition duration-500"></div>
    <div class="relative bg-black p-6 rounded-2xl border border-[NOVA-COR]/50 h-full flex flex-col items-center justify-center text-center transform group-hover:scale-105 transition-all duration-300">
        <div class="text-5xl mb-3 transform group-hover:scale-125 transition duration-300">ÍCONE</div>
        <h4 class="font-playfair font-bold text-lg mb-2 text-[NOVA-COR]">TÍTULO</h4>
        <p class="text-xs text-gray-400">SUBTÍTULO</p>
    </div>
</div>
```

### Cores do Tailwind CSS Recomendadas

```
- Red: from-red-600 to-rose-500
- Blue: from-blue-600 to-cyan-500
- Green: from-green-600 to-emerald-500
- Purple: from-purple-600 to-pink-500
- Gold: from-amber-400 to-yellow-500
- Teal: from-teal-600 to-cyan-500
```

## Formulário de Inscrição para Novas Edições

Quando criar uma nova edição, atualize `inscricao.html`:

```html
<input type="hidden" id="edicao" value="confronto">

<!-- Mudar para -->

<input type="hidden" id="edicao" value="proxima-edicao">
```

E no JavaScript:

```javascript
// Adicionar validação para edição
const edicaoAtual = document.getElementById('edicao').value;
```

## Checklist para Nova Edição

- [ ] Definir nome e tema da edição
- [ ] Escolher paleta de cores
- [ ] Escolher 6 pilares temáticos
- [ ] Criar descrição e benefícios
- [ ] Atualizar `edicoes.html`
- [ ] Criar página dedicada (opcional)
- [ ] Atualizar `inscricao.html`
- [ ] Testar responsividade
- [ ] Testar formulário
- [ ] Atualizar links de navegação

## Dicas de Design

1. **Coerência**: Mantenha o mesmo estilo visual das outras edições
2. **Contraste**: Use cores que contrastem bem com o fundo preto
3. **Animações**: Use `data-aos` para animações de scroll
4. **Mobile**: Sempre teste em dispositivos móveis
5. **Acessibilidade**: Verifique contraste de cores
6. **Performance**: Não exagere em efeitos de blur ou animações

## Exemplos de Gradientes Bonitos

```css
/* Azul vibrante */
bg-gradient-to-r from-blue-600 to-cyan-500

/* Verde natural */
bg-gradient-to-r from-green-600 to-emerald-500

/* Roxo místico */
bg-gradient-to-r from-purple-600 to-pink-500

/* Ouro luxuoso */
bg-gradient-to-r from-amber-400 to-yellow-500

/* Teal moderno */
bg-gradient-to-r from-teal-600 to-cyan-500

/* Rosa elegante */
bg-gradient-to-r from-rose-600 to-pink-500
```

---

**Dúvidas?** Consulte a documentação de Tailwind CSS em: https://tailwindcss.com/

