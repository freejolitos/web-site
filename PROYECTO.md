# Proyecto

Referencia para continuar el desarrollo de freejolitos.com desde cualquier punto.

## Stack

- **Astro 5** — generador estático, `output: 'static'`, `trailingSlash: 'always'`
- **HTML estático puro** — sin JavaScript en producción salvo excepciones justificadas
- **Markdown** para todo el contenido (posts, servicios, manifiesto)
- **CSS propio** — sin frameworks, sin Tailwind, sin utilidades externas

## Diseño

### Paleta

```css
--bg:        #000000
--bg-soft:   #0a0a0a
--fg:        #b2df82   /* verde-pistache — color de marca */
--fg-bright: #d6f5b3   /* highlight */
--fg-dim:    #6e8c52   /* texto secundario */
--stroke:    #1f1f1f   /* divisores */
--warn:      #ff6b6b   /* errores */
--glow:      0 0 18px #b2df82aa
--glow-sm:   0 0 8px #b2df8288
```

### Tipografía

JetBrains Mono self-hosted (archivos WOFF2 en `public/fonts/`). Monoespaciada pura en todo el sitio, sin excepciones. No mezclar con fuentes proporcionales.

### Principios visuales

- Fondo negro permanente, sin toggle de modo claro
- Halo neon sutil en logo y h1 (`text-shadow: var(--glow)`)
- Cursor parpadeante `_` al final del manifiesto y en el prompt del footer — CSS puro, sin JS
- Hover en links: subrayado animado + glow suave
- Sin animaciones agresivas (matrix-rain, glitch full, parallax)
- Sin imágenes decorativas. Imágenes técnicas (diagramas, capturas) solo cuando aportan información
- Bean.svg (`public/logos/bean.svg`) reservado para 404 y footer — no saturar

### Identidad

- Símbolo principal: `#_` (logo en `public/logos/prompt.svg` y `public/favicon.svg`)
- Prompt de firma: `[okami@freejolitos]$ _` al pie de posts y manifiesto
- Navegación con rutas tipo sistema: `/blog`, `/srv`, `/etc/acerca`, `/usr/src/faq`

## Estructura de contenido

```
src/content/
├── blog/           # Posts del blog — un .md por post, plano (sin subdirectorios)
├── servicios/      # Fichas de servicios — un .md por servicio
└── pages/          # Páginas especiales (manifiesto)
```

### Colecciones y schema

Definidas en `src/content/config.ts`:

**blog:**
- `title` — string, obligatorio
- `description` — string, opcional (aparece en listado y RSS)
- `date` — date (YYYY-MM-DD), opcional (sin fecha = al fondo del listado)
- `category` — enum: `cultura | tecnico | opinion | eventos`

**servicios:**
- `title`, `description`, `status` (activo/futuro), `order` (número para ordenar)

## Publicar un post

1. Crear `src/content/blog/nombre-del-post.md`

```markdown
---
title: "Título"
description: "Una línea que resume el contenido."
category: cultura   # cultura | tecnico | opinion | eventos
date: 2026-01-01
---

Contenido en Markdown.

[okami@freejolitos]$ _
```

2. El slug de la URL sale del nombre del archivo: `nombre-del-post` → `/blog/categoria/nombre-del-post/`
3. Aparece automáticamente en el listado de la categoría, en `/blog/`, en el RSS y en el StatusBlock del home (si es el más reciente por fecha)
4. Sin fecha: el post aparece pero cae al fondo del listado

### Tono editorial

- Directo y sin adornos. Sin emojis.
- Primera persona del plural cuando habla la comunidad, primera del singular si es una voz individual
- Sin headings innecesarios dentro de posts cortos
- Cierres con `[okami@freejolitos]$ _`
- Las referencias culturales (Cyberia, Systemspace, cultura hacker clásica) se mencionan, no se explican

## Componentes principales

| Componente | Uso |
|---|---|
| `StatusBlock.astro` | Home — estado de servicios + último post. Build-time, sin JS |
| `MatrixComments.astro` | Pie de cada post — link a sala Matrix `#blog-{slug}:freejolitos.com` |
| `Header.astro` | Navegación principal |
| `Footer.astro` | `:wq!` + links + Bean |
| `BaseLayout.astro` | Shell HTML, OG meta, canonical, RSS link |
| `PostLayout.astro` | Layout de post — breadcrumb, título, fecha opcional, MatrixComments |

## Agregar o modificar servicios

Cada servicio es un archivo en `src/servicios/<slug>.md` con frontmatter `status: activo` y un `order` numérico. El índice en `/servicios/` solo muestra los `activo`. Los futuros están hardcodeados en `src/pages/servicios/index.astro`.

## Lo que no hacer

- No agregar JavaScript al bundle salvo necesidad real e irreemplazable
- No usar frameworks CSS externos
- No agregar Google Analytics, pixels de seguimiento ni cualquier script de terceros
- No hacer prominentes las fechas en los posts — el contenido no debería envejecer por diseño
- No cambiar la paleta sin razón sólida — el verde-pistache es herencia de la comunidad desde 2018
