# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev       # Dev server → http://localhost:4321
npm run build     # Static build → dist/
npm run preview   # Preview the last build locally
```

Deploy (requires Linux/WSL — rsync and SSH alias `freejolitos` must be available):

```bash
bash deploy/publish.sh
```

No linter, no test suite. Correctness is verified by `npm run build` succeeding and manual browser review.

## Platform note

`node_modules` native binaries (rollup) are platform-specific. If dependencies were installed on Windows, builds from WSL will fail and vice versa. Reinstall from the platform you're building from:

```bash
rm -rf node_modules package-lock.json && npm install
```

## Architecture

Astro 5 static site (`output: 'static'`, `trailingSlash: 'always'`). No JavaScript in the browser — the cursor blink animation is CSS-only. No frameworks, no Tailwind.

**Content** lives in `src/content/` as Markdown with Zod-validated frontmatter (schema in `src/content/config.ts`):

- `blog/` — flat directory, one `.md` per post. Slug = filename. URL = `/blog/<category>/<slug>/`
- `servicios/` — one `.md` per service. Rendered at `/servicios/<slug>/`
- `pages/` — special pages (manifiesto). Rendered inline in `src/pages/index.astro`

**Blog frontmatter:**
```
title, description (optional), date (optional YYYY-MM-DD), category (cultura|tecnico|opinion|eventos)
```
Posts without `date` sort to the bottom of listings. The `StatusBlock` component shows the latest post at build time by sorting all posts by date.

**Routing** mirrors filesystem under `src/pages/`. Dynamic routes:
- `src/pages/blog/[categoria]/[slug].astro` — individual posts
- `src/pages/blog/[categoria]/index.astro` — category listings
- `src/pages/servicios/[slug].astro` — service pages

**Design system** is in `src/styles/global.css` (variables, reset, `@font-face`) and `src/styles/neon.css` (glow classes, animations, component styles). Core variable: `--fg: #b2df82` (green-pistachio, brand color). Font: JetBrains Mono self-hosted from `public/fonts/`, monospaced throughout with no exceptions.

**Layouts:** `BaseLayout.astro` is the HTML shell with OG meta and RSS link. `PostLayout.astro` wraps blog posts with breadcrumb, title, optional date, and `MatrixComments`.

## Deploy flow

`deploy/publish.sh` builds locally, rsyncs `dist/` to `~/deploy-tmp/` on the VPS, then SSH-executes `sudo rsync` to the webroot `/var/www/html/freejolitos-root/`. The VPS user is `okami`. SSH alias `freejolitos` must be configured in `~/.ssh/config`.
