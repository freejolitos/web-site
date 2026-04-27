---
title: "Blog"
description: "Publicaciones de la comunidad. Contenido técnico y cultural en español."
status: activo
order: 3
---

El blog es donde el conocimiento se deposita. Artículos técnicos, análisis, opiniones fundamentadas, notas de eventos. Sin fechas prominentes porque el contenido no debería envejecer por diseño.

## Categorías

- [`/blog/cultura`](/blog/cultura/) — cultura hacker, reflexiones, historia
- [`/blog/tecnico`](/blog/tecnico/) — tutoriales, análisis, documentación
- [`/blog/opinion`](/blog/opinion/) — puntos de vista, crítica, debate
- [`/blog/eventos`](/blog/eventos/) — hackerspaces, conferencias, encuentros

## ¿Puedo publicar?

Sí, con criterio. El proceso:

1. Pasa al [Matrix](/servicios/matrix/) y propón el tema. La conversación primero.
2. Si encaja, descarga la plantilla, escribe el post y abre un [pull request](https://github.com/freejolitos/web-site) con el archivo en `src/content/blog/`.
3. Se revisa, se comenta si hace falta, y se fusiona.

**[Descargar plantilla](/post-template.md)**

## Formato del archivo

El nombre del archivo determina la URL del post:

```
src/content/blog/nombre-del-post.md
→ /blog/<categoria>/nombre-del-post/
```

El frontmatter obligatorio:

```
---
title: "Título"
category: cultura   # cultura | tecnico | opinion | eventos
date: 2025-01-01
---
```

`description` es opcional pero recomendado — aparece en el listado y en el RSS.
