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
REMOTE_TMP="~/deploy-tmp"
WEBROOT="/var/www/html/freejolitos-root"

echo ""
echo "==> 1/3  Build"
npm run build

echo ""
echo "==> 2/3  Subiendo archivos a ${VPS}:${REMOTE_TMP}/"
rsync -avz --delete dist/ "${VPS}:${REMOTE_TMP}/"

echo ""
echo "==> 3/3  Publicando en ${WEBROOT} (requiere sudo en el VPS)"
ssh -t "${VPS}" bash <<REMOTE
  set -euo pipefail
  sudo rsync -a --delete "${REMOTE_TMP}/" "${WEBROOT}/"
  sudo chmod -R 755 "${WEBROOT}"
  sudo chown -R www-data:www-data "${WEBROOT}"
  rm -rf "${REMOTE_TMP}"
  echo "✓ Publicado correctamente"
REMOTE

echo ""
echo "✓ Listo — https://freejolitos.com"
