# freejolitos.com

Sitio web de [Freejolitos](https://freejolitos.com) — nodo de cultura hacker en español.

Construido con [Astro](https://astro.build). Genera HTML estático puro, sin JavaScript innecesario.

## Requisitos

- Node.js >= 18.17
- npm

## Desarrollo local

```bash
npm install
npm run dev
# → http://localhost:4321
```

## Build

```bash
npm run build
# Salida en dist/
```

## Estructura

```
src/
├── content/
│   ├── blog/          # Posts en Markdown
│   ├── servicios/     # Fichas de servicios
│   └── pages/         # Contenido de páginas especiales (manifiesto)
├── components/        # Componentes Astro reutilizables
├── layouts/           # BaseLayout y PostLayout
├── pages/             # Rutas del sitio
└── styles/            # CSS global y efectos neon
public/
├── fonts/             # JetBrains Mono self-hosted
├── logos/             # SVG del logo y bean
└── post-template.md   # Plantilla para nuevos posts
deploy/
├── post-receive.sh    # Hook git para deploy en VPS
└── nginx.conf.example # Config Nginx de referencia
```

## Agregar un post

1. Crear `src/content/blog/nombre-del-post.md` con el frontmatter:

```markdown
---
title: "Título"
description: "Una línea descriptiva."
category: cultura   # cultura | tecnico | opinion | eventos
date: 2025-01-01
---

Contenido en Markdown.

[okami@freejolitos]$ _
```

2. El post aparece automáticamente en `/blog/<categoria>/<slug>/` y en el RSS.

Para publicar como colaborador externo: abre un pull request con el archivo.

## Deploy

Ver `deploy/post-receive.sh` y `deploy/nginx.conf.example`.

El flujo básico: push al repo bare del VPS → hook corre `npm run build` → `rsync` a `/var/www/freejolitos.com`.

## Fuentes

JetBrains Mono 2.304 — archivos WOFF2 en `public/fonts/`. Ver `public/fonts/README.txt`.
