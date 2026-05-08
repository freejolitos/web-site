#!/usr/bin/env bash
# Publicar freejolitos.com en el VPS
# Uso: bash deploy/publish.sh
#
# Requisitos locales:
#   - Node >= 18 con npm
#   - rsync
#   - Alias SSH "freejolitos" configurado (~/.ssh/config) con clave ya registrada
#
# Requisitos en el VPS:
#   - okami en el grupo sudo
#   - rsync instalado

set -euo pipefail

VPS="freejolitos"
REMOTE_TMP="deploy-tmp"          # relativo al home del VPS, sin ~
WEBROOT="/var/www/html/freejolitos-root"
DOOM_DIR="public/games/doom"
JSDOS_BASE="https://v8.js-dos.com/latest"

echo ""
echo "==> 0/3  Assets de DOOM"
if [ ! -f "${DOOM_DIR}/js-dos.js" ] || [ ! -f "${DOOM_DIR}/js-dos.wasm" ]; then
  echo "    Descargando js-dos v8..."
  curl -fsSL -o "${DOOM_DIR}/js-dos.js"   "${JSDOS_BASE}/js-dos.js"
  curl -fsSL -o "${DOOM_DIR}/js-dos.wasm" "${JSDOS_BASE}/js-dos.wasm"
  echo "    ✓ js-dos.js + js-dos.wasm"
else
  echo "    js-dos.js y js-dos.wasm ya presentes, omitiendo descarga"
fi

if [ ! -f "${DOOM_DIR}/freedoom.jsdos" ]; then
  echo "    ⚠  ${DOOM_DIR}/freedoom.jsdos no encontrado"
  echo "       El easter egg de DOOM no funcionará hasta que lo agregues."
  echo "       Ver ${DOOM_DIR}/README.txt para instrucciones."
fi

echo ""
echo "==> 1/3  Build"
npm run build

echo ""
echo "==> 2/3  Subiendo archivos a ${VPS}:~/${REMOTE_TMP}/"
rsync -avz --delete dist/ "${VPS}:${REMOTE_TMP}/"

echo ""
echo "==> 3/3  Publicando en ${WEBROOT} (requiere sudo en el VPS)"
# -tt fuerza TTY aunque stdin no sea una terminal (necesario para sudo)
ssh -tt "${VPS}" "
  set -euo pipefail
  sudo rsync -a --delete \$HOME/${REMOTE_TMP}/ ${WEBROOT}/
  sudo chmod -R 755 ${WEBROOT}
  sudo chown -R www-data:www-data ${WEBROOT}
  rm -rf \$HOME/${REMOTE_TMP}
  echo '✓ Publicado correctamente'
"

echo ""
echo "✓ Listo — https://freejolitos.com"
