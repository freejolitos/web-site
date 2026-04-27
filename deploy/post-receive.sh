#!/bin/bash
# Hook post-receive para repo bare en el VPS
# Ruta del repo bare: /srv/git/freejolitos.git
# Uso: git push deploy main

set -e

WORKDIR=/srv/sites/freejolitos
WEBROOT=/var/www/freejolitos.com
GIT_DIR=/srv/git/freejolitos.git

echo "→ Actualizando worktree..."
git --work-tree="$WORKDIR" --git-dir="$GIT_DIR" checkout -f main

echo "→ Instalando dependencias..."
cd "$WORKDIR"
npm ci --omit=dev

echo "→ Construyendo sitio..."
npm run build

echo "→ Publicando en $WEBROOT..."
rsync -a --delete dist/ "$WEBROOT/"

echo "✓ Deploy completo: $(date)"
