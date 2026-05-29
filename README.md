# 🙏 Além do Espelho - Edição Gênesis: O Confronto

Um site elegante, moderno e responsivo para divulgar e gerenciar inscrições para o retiro **"Além do Espelho - 1ª Edição: O Confronto"**.

## 📋 Visão Geral

Este é um site de apresentação para um retiro transformador destinado a todas as idades. O site convida visitantes a uma jornada de auto-descoberta, cura espiritual e alinhamento com o propósito de Deus.

### ✨ Características

- 🎨 **Design Elegante e Moderno** - UI/UX sofisticada com paleta de cores em âmbar e preto
- 🎬 **Animações Fluidas** - Animações ao scroll (AOS), efeitos paralaxe e transições suaves
- 📱 **Totalmente Responsivo** - Adaptado para mobile, tablet e desktop
- 🚀 **Performance Otimizada** - Carregamento rápido e lazy loading de imagens
- 🎯 **SEO Amigável** - Estrutura semântica e meta tags otimizadas
- ♿ **Acessibilidade** - Navegação por teclado e suporte a leitores de tela
- 📧 **Formulário de Inscrição** - Sistema de captação de leads

## 🏗️ Estrutura do Projeto

```
RETIRO-SITE/
├── index.html          # Página principal (HTML5)
├── css/
│   └── style.css       # Estilos customizados
├── js/
│   └── main.js         # JavaScript interativo
├── assets/             # Imagens, vídeos e mídia
│   ├── images/
│   ├── videos/
│   └── icons/
├── README.md           # Este arquivo
└── .gitignore          # Arquivos ignorados pelo Git
```

## 🎯 Seções do Site

### 1. **Navegação**
- Menu fixo com navegação suave
- Menu mobile responsivo com toggle

### 2. **Hero Section**
- Título principal com efeito de gradiente
- Animações de fundo (blobs)
- Call-to-action principal
- Indicador de scroll

### 3. **Sobre o Retiro**
- Descrição do retiro
- Pilares da experiência
- Visual atrativo

### 4. **O Confronto (Pilares)**
- 4 cards com os pilares do retiro
- Ícones e descrições
- Hover effects interativos

### 5. **Inscrição**
- Formulário de captação
- Campos: Nome, E-mail, Mensagem
- Validação de dados
- Feedback ao usuário

### 6. **Footer**
- Links rápidos
- Informações de contato
- Créditos

## 🛠️ Tecnologias Utilizadas

- **HTML5** - Estrutura semântica
- **CSS3** - Estilos, animações e responsive design
- **JavaScript Vanilla** - Interatividade e validações
- **Tailwind CSS** - Framework CSS via CDN
- **AOS (Animate On Scroll)** - Animações ao scroll
- **Google Fonts** - Tipografia (Playfair Display, Raleway)

## 🚀 Como Usar

### 1. **Instalação Local**

```bash
# Clone ou baixe este repositório
cd RETIRO-SITE

# Abra o arquivo index.html no navegador
# (Não requer servidor para versão estática)
```

### 2. **Com Servidor Local (recomendado)**

**Python 3:**
```bash
python -m http.server 8000
```

**Node.js (http-server):**
```bash
npm install -g http-server
http-server
```

Então acesse: `http://localhost:8000`

### 3. **Deploy**

#### Opções de Hosting:
- **Netlify** - Gratuito, suporte a formulários
- **Vercel** - Gratuito, deploy automático
- **GitHub Pages** - Gratuito
- **Hostinger** - Pago, suporte PHP
- **Bluehost** - Pago, suporte WordPress

## 📝 Customização

### Mudar Cores

Edite em `css/style.css` os valores:
- Cor primária: `#fbbf24` (âmbar)
- Cor secundária: `#b45309` (âmbar escuro)

### Adicionar Seções

1. Adicione uma nova `<section>` em `index.html`
2. Use classes Tailwind para styling
3. Adicione `data-aos="fade-up"` para animações

### Atualizar Textos

Todos os textos estão em `index.html` - fácil de editar.

### Adicionar Imagens

1. Coloque arquivos em `assets/images/`
2. Referencie com `<img src="assets/images/seu-arquivo.jpg" alt="Descrição">`

## 📧 Integração com Backend

### Próximos Passos (com backend):

1. **Node.js + Express**
   ```bash
   npm init -y
   npm install express nodemailer cors
   ```

2. **PHP** (se preferir)
   ```php
   // backend/process-form.php
   $_POST['nome'], $_POST['email'] ...
   ```

3. **Banco de Dados**
   - MongoDB para flexibilidade
   - MySQL para relações complexas
   - Firebase para realtime

## 🎨 Paleta de Cores

- **Preto**: `#000000`
- **Âmbar Primário**: `#fbbf24`
- **Âmbar Escuro**: `#b45309`
- **Cinza**: `#d1d5db`, `#6b7280`, `#374151`

## 🔤 Tipografia

- **Títulos**: Playfair Display (serif, elegante)
- **Corpo**: Raleway (sans-serif, moderna)

## 📱 Breakpoints Responsivos

- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px

## ⚡ Performance

- Lazy loading de imagens
- CSS otimizado (Tailwind)
- JS minificado possível
- Animações com GPU acceleration

## 🔒 Segurança

- Validação de formulário no frontend
- Escape de inputs (quando usar backend)
- Headers CORS seguros (quando usar backend)
- Sem dados sensíveis em frontend

## 📊 Analytics (Futuro)

Adicione Google Analytics ou Plausible Analytics:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_ID');
</script>
```

## 🐛 Troubleshooting

### Animações não funcionando
- Verifique se AOS.js está carregado
- Verifique o console do navegador para erros

### Formulário não funciona
- Verifique a validação em `js/main.js`
- Adicione um backend para processar dados

### Estilos não aplicando
- Limpe o cache do navegador (Ctrl+Shift+Del)
- Verifique se Tailwind CDN está carregando

## 📚 Recursos Úteis

- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [AOS Documentation](https://michalsnik.github.io/aos/)
- [Google Fonts](https://fonts.google.com)
- [MDN Web Docs](https://developer.mozilla.org)

## 🤝 Contribuições

Para adicionar melhorias:
1. Crie um novo branch
2. Faça suas alterações
3. Envie um pull request

## 📄 Licença

Este projeto está disponível para uso pessoal e comercial.

---

## 🙏 Mensagem Final

> "Sonda-me, ó Deus, e conhece o meu coração." — Salmos 139:23

Este site é um convite para transformação. Que cada visitante encontre sua identidade verdadeira em Cristo e caminhe em direção ao propósito que Deus preparou para sua vida.

✨ **Além do Espelho - 1ª Edição: O Confronto**

*Uma jornada de cura, identidade e propósito.*

---

**Criado com ❤️ e 💻 para transformar vidas** 🙏✨
