// ============================================================
// INITIALIZATION
// ============================================================

// Initialize AOS (Animate On Scroll)
document.addEventListener('DOMContentLoaded', function() {
    // Initialize AOS library with enhanced settings
    if (typeof AOS !== 'undefined') {
        AOS.init({
            duration: 1000,
            easing: 'ease-in-out-cubic',
            once: false,
            mirror: true,
            offset: 120,
            disable: false,
            startEvent: 'DOMContentLoaded',
            throttleDelay: 99,
            debounceDelay: 50,
        });
        
        // Refresh AOS after a short delay to ensure proper initialization
        setTimeout(() => {
            AOS.refresh();
        }, 100);
    }
});

// ============================================================
// MOBILE MENU HANDLER
// ============================================================

const menuToggle = document.getElementById('menuToggle');
const mobileMenu = document.getElementById('mobileMenu');

menuToggle?.addEventListener('click', () => {
    mobileMenu?.classList.toggle('hidden');
});

// Close mobile menu when a link is clicked
const mobileMenuLinks = mobileMenu?.querySelectorAll('a') || [];
mobileMenuLinks.forEach(link => {
    link.addEventListener('click', () => {
        mobileMenu?.classList.add('hidden');
    });
});

// Close mobile menu when scrolling
window.addEventListener('scroll', () => {
    if (mobileMenu && !mobileMenu.classList.contains('hidden')) {
        mobileMenu.classList.add('hidden');
    }
});

// ============================================================
// SMOOTH SCROLL NAVIGATION
// ============================================================

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href !== '#' && href !== '#0') {
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        }
    });
});

// ============================================================
// NAVBAR SCROLL EFFECTS
// ============================================================

const navbar = document.querySelector('nav');
let lastScrollY = 0;

window.addEventListener('scroll', () => {
    const scrollY = window.scrollY;
    
    // Navbar shadow effect
    if (scrollY > 50) {
        navbar?.classList.add('shadow-lg', 'shadow-amber-500/10');
    } else {
        navbar?.classList.remove('shadow-lg', 'shadow-amber-500/10');
    }

    // Navbar hide/show on scroll
    if (scrollY > lastScrollY && scrollY > 300) {
        // Scrolling down - hide navbar
        navbar?.classList.add('-translate-y-full');
    } else {
        // Scrolling up - show navbar
        navbar?.classList.remove('-translate-y-full');
    }
    lastScrollY = scrollY;
}, { passive: true });

// Add transition to navbar
navbar?.classList.add('transition-transform', 'duration-300');

// ============================================================
// FORM HANDLING
// ============================================================

const form = document.querySelector('form');

if (form) {
    form.addEventListener('submit', (e) => {
        e.preventDefault();
        
        const nameInput = form.querySelector('input[placeholder="Seu Nome"]');
        const emailInput = form.querySelector('input[placeholder="Seu E-mail"]');
        const messageInput = form.querySelector('textarea');
        
        const name = nameInput?.value?.trim();
        const email = emailInput?.value?.trim();
        const message = messageInput?.value?.trim();
        
        // Validation
        if (!name || !email) {
            showNotification('Por favor, preencha Nome e E-mail', 'error');
            return;
        }
        
        // Email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            showNotification('Por favor, insira um e-mail válido', 'error');
            return;
        }
        
        // Simulate form submission
        const button = form.querySelector('button[type="submit"]');
        const originalText = button.innerText;
        button.innerText = 'Processando...';
        button.disabled = true;
        
        setTimeout(() => {
            // Success feedback
            showNotification(`Obrigado pela sua inscrição, ${name}! 🙏\n\nEntraremos em contato em breve em ${email}`, 'success');
            
            // Reset form
            form.reset();
            
            // Reset button
            button.innerText = originalText;
            button.disabled = false;
            
            // Add success animation
            form.classList.add('animate-pulse');
            setTimeout(() => form.classList.remove('animate-pulse'), 2000);
        }, 1500);
    });
}

// ============================================================
// NOTIFICATION SYSTEM
// ============================================================

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 z-50 px-6 py-4 rounded-lg backdrop-blur-md border flex items-center gap-3 animate-fade-in-up max-w-sm`;
    
    const typeClasses = {
        success: 'bg-green-950/50 border-green-500/50 text-green-200',
        error: 'bg-red-950/50 border-red-500/50 text-red-200',
        info: 'bg-blue-950/50 border-blue-500/50 text-blue-200'
    };
    
    const typeIcons = {
        success: '✓',
        error: '✕',
        info: 'ℹ'
    };
    
    notification.classList.add(typeClasses[type] || typeClasses.info);
    notification.innerHTML = `
        <span class="text-xl">${typeIcons[type]}</span>
        <span>${message}</span>
        <button class="ml-auto text-xl hover:opacity-70">×</button>
    `;
    
    document.body.appendChild(notification);
    
    notification.querySelector('button').addEventListener('click', () => {
        notification.remove();
    });
    
    setTimeout(() => {
        notification.remove();
    }, 5000);
}

// ============================================================
// PARALLAX EFFECT
// ============================================================

window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const parallaxElements = document.querySelectorAll('[data-parallax]');
    
    parallaxElements.forEach(element => {
        const speed = parseFloat(element.dataset.parallax) || 0.5;
        element.style.transform = `translateY(${scrolled * speed}px)`;
    });
}, { passive: true });

// ============================================================
// COUNTER ANIMATION
// ============================================================

const animateCounters = () => {
    const counters = document.querySelectorAll('[data-target]');
    
    counters.forEach(counter => {
        const target = parseInt(counter.dataset.target);
        const speed = parseInt(counter.dataset.speed) || 200;
        
        const updateCount = () => {
            const count = parseInt(counter.innerText);
            const increment = target / speed;
            
            if (count < target) {
                counter.innerText = Math.ceil(count + increment);
                setTimeout(updateCount, 10);
            } else {
                counter.innerText = target;
            }
        };
        
        // Trigger when visible
        const observer = new IntersectionObserver((entries) => {
            if (entries[0].isIntersecting) {
                updateCount();
                observer.unobserve(counter);
            }
        }, { threshold: 0.5 });
        
        observer.observe(counter);
    });
};

animateCounters();

// ============================================================
// INTERSECTION OBSERVER FOR ANIMATIONS
// ============================================================

const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('aos-animate');
        }
    });
}, observerOptions);

// Observe all AOS elements
document.querySelectorAll('[data-aos]').forEach(element => {
    observer.observe(element);
});

// ============================================================
// BUTTON RIPPLE EFFECT
// ============================================================

const createRipple = (e) => {
    const button = e.currentTarget;
    const ripple = document.createElement('span');
    const rect = button.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = e.clientX - rect.left - size / 2;
    const y = e.clientY - rect.top - size / 2;
    
    ripple.style.width = ripple.style.height = size + 'px';
    ripple.style.left = x + 'px';
    ripple.style.top = y + 'px';
    ripple.classList.add('ripple');
    
    button.appendChild(ripple);
    
    setTimeout(() => ripple.remove(), 600);
};

// Add ripple effect CSS dynamically
const rippleStyle = document.createElement('style');
rippleStyle.textContent = `
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.6);
        transform: scale(0);
        animation: ripple-animation 0.6s ease-out;
        pointer-events: none;
    }
    
    @keyframes ripple-animation {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(rippleStyle);

// Add ripple effect to all buttons
document.querySelectorAll('button').forEach(button => {
    button.addEventListener('click', createRipple);
});

// ============================================================
// LAZY LOAD IMAGES
// ============================================================

if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    imageObserver.unobserve(img);
                }
            }
        });
    });
    
    document.querySelectorAll('img.lazy').forEach(img => {
        imageObserver.observe(img);
    });
}

// ============================================================
// KEYBOARD NAVIGATION
// ============================================================

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        // Close mobile menu on Escape
        if (mobileMenu && !mobileMenu.classList.contains('hidden')) {
            mobileMenu.classList.add('hidden');
        }
    }
    
    // Scroll to sections with keyboard shortcuts
    if (e.altKey) {
        switch(e.key) {
            case '1':
                document.querySelector('#inicio')?.scrollIntoView({ behavior: 'smooth' });
                break;
            case '2':
                document.querySelector('#sobre')?.scrollIntoView({ behavior: 'smooth' });
                break;
            case '3':
                document.querySelector('#confronto')?.scrollIntoView({ behavior: 'smooth' });
                break;
            case '4':
                document.querySelector('#inscricao')?.scrollIntoView({ behavior: 'smooth' });
                break;
        }
    }
});

// ============================================================
// ENHANCED FOCUS MANAGEMENT
// ============================================================

const inputs = document.querySelectorAll('input, textarea');
inputs.forEach(input => {
    input.addEventListener('focus', function() {
        this.parentElement?.classList.add('focus-visible');
    });
    
    input.addEventListener('blur', function() {
        this.parentElement?.classList.remove('focus-visible');
    });
});

// ============================================================
// PAGE LOAD ANIMATIONS
// ============================================================

window.addEventListener('load', () => {
    // Add loaded state to body
    document.body.classList.add('page-loaded');
    
    // Animate elements on page load
    const elements = document.querySelectorAll('[data-aos]');
    elements.forEach((el, index) => {
        setTimeout(() => {
            el.style.opacity = '0';
            el.style.animation = 'none';
        }, 0);
    });
});

// ============================================================
// PERFORMANCE MONITORING
// ============================================================

if ('performance' in window && 'PerformanceObserver' in window) {
    try {
        const observer = new PerformanceObserver((list) => {
            for (const entry of list.getEntries()) {
                if (entry.duration > 3000) {
                    console.warn(`Long task detected: ${entry.duration.toFixed(2)}ms`);
                }
            }
        });
        observer.observe({ entryTypes: ['longtask'] });
    } catch (e) {
        // Performance observer not supported
    }
}

// ============================================================
// UTILITY FUNCTION: Add animation to element
// ============================================================

function animateElement(element, animation, duration = 600) {
    return new Promise((resolve) => {
        element.style.animation = `${animation} ${duration}ms ease-in-out forwards`;
        setTimeout(() => {
            element.style.animation = 'none';
            resolve();
        }, duration);
    });
}

// ============================================================
// CONSOLE MESSAGE
// ============================================================

console.clear();
console.log('%c🙏 Bem-vindo ao Além do Espelho', 'font-size: 20px; color: #fbbf24; font-weight: bold;');
console.log('%c✨ Edição Gênesis: O Confronto', 'font-size: 16px; color: #d97706;');
console.log('%cUma jornada de cura, identidade e propósito.', 'font-size: 12px; color: #9ca3af; font-style: italic;');
console.log('%c\n"Sonda-me, ó Deus, e conhece o meu coração." — Salmos 139:23', 'font-size: 12px; color: #fbbf24; font-style: italic;');
