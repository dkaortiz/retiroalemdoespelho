# 🎨 Guia de Customização e Melhorias

Neste arquivo você encontra dicas para customizar e melhorar o site conforme suas necessidades.

## 🎨 Personalizações Visuais

### 1. Trocar Paleta de Cores

Edite em `index.html` dentro das classes Tailwind:

**Opção 1: Tons de Roxo**
```html
<!-- Substitua -->
from-amber-300 to-amber-600   <!-- Atual -->
<!-- Por -->
from-purple-300 to-purple-600  <!-- Novo -->
```

**Opção 2: Tons de Azul**
```html
from-blue-300 to-blue-600
```

### 2. Mudar Tipografia

Em `index.html`, edite a seção `<head>`:

```html
<!-- Google Fonts atualizadas -->
<link href="https://fonts.googleapis.com/css2?family=Lora:wght@700;900&family=Rubik:wght@400;500;600;700&display=swap" rel="stylesheet">
```

E após:
```html
<style>
.font-playfair { font-family: 'Lora', serif; }
.font-raleway { font-family: 'Rubik', sans-serif; }
</style>
```

---

## 🖼️ Adicionar Imagens

### 1. Hero Section com Background

Edite `index.html` seção hero:

```html
<section id="inicio" class="relative h-screen flex items-center justify-center overflow-hidden pt-16" style="background-image: url('assets/images/hero-bg.jpg'); background-size: cover; background-position: center;">
  <!-- Overlay escuro para legibilidade -->
  <div class="absolute inset-0 bg-black/50 z-0"></div>
  <!-- Resto do conteúdo com z-10 -->
</section>
```

### 2. Imagens em Cards

```html
<div class="relative overflow-hidden rounded-xl">
  <img src="assets/images/card-image.jpg" alt="Descrição" class="w-full h-64 object-cover hover:scale-110 transition duration-300">
</div>
```

---

## 🎬 Adicionar Vídeos

### 1. Vídeo Hero com Fundo

```html
<video autoplay muted loop class="absolute inset-0 w-full h-full object-cover">
  <source src="assets/videos/hero.mp4" type="video/mp4">
</video>
```

### 2. Iframe de YouTube

```html
<div class="aspect-video mb-8">
  <iframe class="w-full h-full rounded-lg" src="https://www.youtube.com/embed/VIDEO_ID" frameborder="0" allowfullscreen></iframe>
</div>
```

---

## 📝 Adicionar Novas Seções

### 1. Testemunhas/Depoimentos

```html
<!-- Adicione antes do footer -->
<section id="testemunhas" class="py-20 md:py-32 bg-black">
  <div class="max-w-6xl mx-auto px-4">
    <h2 class="font-playfair text-4xl font-bold text-center mb-12">
      Histórias de Transformação
    </h2>
    
    <div class="grid md:grid-cols-3 gap-6">
      <!-- Card de Depoimento -->
      <div class="bg-amber-900/20 border border-amber-700/30 rounded-xl p-6" data-aos="fade-up">
        <p class="text-gray-300 mb-4">"Este retiro mudou completamente minha perspectiva..."</p>
        <p class="font-bold text-amber-300">- João Silva</p>
        <p class="text-sm text-gray-500">Particante 2024</p>
      </div>
    </div>
  </div>
</section>
```

### 2. FAQ (Perguntas Frequentes)

```html
<section id="faq" class="py-20 md:py-32">
  <div class="max-w-3xl mx-auto px-4">
    <h2 class="font-playfair text-4xl font-bold mb-12 text-center">
      Perguntas Frequentes
    </h2>
    
    <details class="mb-4 bg-amber-900/20 border border-amber-700/30 p-6 rounded-lg cursor-pointer group">
      <summary class="font-bold text-amber-300 flex justify-between items-center">
        Qual é a idade mínima? 
        <span class="group-open:rotate-180 transition">▼</span>
      </summary>
      <p class="text-gray-300 mt-4">O retiro é para todas as idades a partir de 14 anos...</p>
    </details>
  </div>
</section>
```

---

## 🔍 SEO - Otimizações

### 1. Meta Tags Importantes

Adicione ao `<head>` em `index.html`:

```html
<!-- Meta básicas -->
<meta name="description" content="Descubra sua verdadeira identidade em Cristo no retiro Além do Espelho - Edição Gênesis: O Confronto">
<meta name="keywords" content="retiro, espiritualidade, transformação, identidade, propósito, Cristo">
<meta name="author" content="Seu Nome">

<!-- Open Graph (para compartilhamento em redes sociais) -->
<meta property="og:title" content="Além do Espelho - O Confronto">
<meta property="og:description" content="Uma jornada de cura, identidade e propósito">
<meta property="og:image" content="https://seu-dominio.com/assets/images/og-image.jpg">
<meta property="og:url" content="https://seu-dominio.com">
<meta property="og:type" content="website">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Além do Espelho - O Confronto">
<meta name="twitter:description" content="Uma jornada de cura, identidade e propósito">
<meta name="twitter:image" content="https://seu-dominio.com/assets/images/twitter-image.jpg">

<!-- Canonical URL -->
<link rel="canonical" href="https://seu-dominio.com">

<!-- Favicon -->
<link rel="icon" type="image/png" href="assets/icons/favicon.png">
```

### 2. Sitemap XML

Crie `sitemap.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://seu-dominio.com/</loc>
    <priority>1.0</priority>
    <changefreq>weekly</changefreq>
  </url>
  <url>
    <loc>https://seu-dominio.com/#sobre</loc>
    <priority>0.8</priority>
    <changefreq>weekly</changefreq>
  </url>
</urlset>
```

### 3. robots.txt

Crie `robots.txt`:

```
User-agent: *
Allow: /
Disallow: /admin/

Sitemap: https://seu-dominio.com/sitemap.xml
```

---

## ⚡ Otimizações de Performance

### 1. Lazy Loading de Imagens

```html
<img src="assets/images/imagem.jpg" loading="lazy" alt="Descrição">
```

### 2. Compressão de Imagens

Recomendações:
- Converter JPEG para WebP
- Redimensionar imagens
- Usar TinyPNG ou similar

### 3. Minificação de CSS/JS

Ferramenta: UglifyJS, CleanCSS

---

## 🎯 Analytics e Rastreamento

### Google Analytics 4

```html
<!-- Adicione ao <head> -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Eventos Customizados

```javascript
// js/main.js
gtag('event', 'inscricao', {
  'nome': nome,
  'fonte': 'form_principal'
});
```

---

## 🔔 Notificações e Popups

### 1. Popup de Newsletter

```html
<div id="newsletter-popup" class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center">
  <div class="bg-black border-2 border-amber-600 rounded-lg p-8 max-w-md">
    <h3 class="text-2xl font-bold text-amber-300 mb-4">Receba Notícias</h3>
    <input type="email" placeholder="Seu e-mail" class="w-full px-4 py-2 bg-black/50 border border-amber-600 rounded mb-4">
    <button class="w-full bg-amber-500 text-black font-bold py-2 rounded">Inscrever</button>
  </div>
</div>
```

---

## 🌐 Internacionalização (i18n)

Para adicionar múltiplos idiomas:

```javascript
const translations = {
  pt: { titulo: "Além do Espelho", ... },
  en: { titulo: "Beyond the Mirror", ... },
  es: { titulo: "Más Allá del Espejo", ... }
};
```

---

## 💬 Chat/Suporte

### Adicionar Chatbot

```html
<!-- Drift ou Intercom -->
<script>
  !function() {
    var t=window.driftt=window.drift||{};
    // ... código aqui
  }();
</script>
```

---

## 📱 Progressive Web App (PWA)

Crie `manifest.json`:

```json
{
  "name": "Além do Espelho",
  "short_name": "RetiroWEB",
  "icons": [
    {"src": "assets/icons/icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "assets/icons/icon-512.png", "sizes": "512x512", "type": "image/png"}
  ],
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#fbbf24"
}
```

E em `index.html`:

```html
<link rel="manifest" href="manifest.json">
```

---

## 📧 Integração com Email Marketing

### MailChimp

```html
<form action="https://seu-email.us14.list-manage.com/subscribe/post" method="POST">
  <input type="email" name="EMAIL" required>
  <input type="hidden" name="u" value="id_aqui">
  <input type="hidden" name="id" value="id_da_lista">
  <button type="submit">Inscrever</button>
</form>
```

---

## 🎯 Redes Sociais

### Meta Pixel (Facebook)

```html
<script>
  !function(f){if(!f.fbq)f.fbq=function(){f.fbq.callMethod?
    f.fbq.callMethod.apply(f.fbq,arguments):f.fbq.queue.push(arguments)}
  // ... código
</script>
```

### WhatsApp Integration

```html
<a href="https://wa.me/5521987654321?text=Olá%20gostaria%20de%20informações" target="_blank">
  Fale conosco no WhatsApp
</a>
```

---

## 💾 Backup e Versionamento

### Git

```bash
git init
git add .
git commit -m "Versão inicial do site"
git remote add origin https://github.com/seu-usuario/retiro-site.git
git push -u origin main
```

---

## 🚀 Deploy Checklist

- [ ] Todos os links testados
- [ ] Formulários funcionando
- [ ] Imagens otimizadas
- [ ] Mobile responsivo testado
- [ ] Performance verificada
- [ ] SEO implementado
- [ ] Certificado SSL/HTTPS
- [ ] Email de contato configurado
- [ ] Analytics ativo
- [ ] Backup configurado

---

Qualquer dúvida, consulte a documentação das bibliotecas usadas! 🚀✨

