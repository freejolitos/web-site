# Deploy

El flujo de publicación usa `deploy/publish.sh`: build local → rsync al VPS → publicación con sudo remoto.

## Requisitos

- Node.js >= 18.17 con npm
- rsync disponible en la terminal desde la que se ejecuta el script
- Alias SSH `freejolitos` configurado en `~/.ssh/config` con clave registrada en el VPS

## Publicar

```bash
bash deploy/publish.sh
```

El script hace tres cosas:
1. `npm run build` — genera `dist/` localmente
2. `rsync` — sube `dist/` al directorio temporal `~/deploy-tmp/` en el VPS
3. SSH — mueve los archivos al webroot, ajusta permisos, limpia el temporal

## Plataforma

El script está pensado para correr desde Linux o WSL. Si el entorno es Windows puro (PowerShell/CMD), rsync no está disponible — usar WSL.

**Nota sobre node_modules en Windows + WSL:** los binarios nativos de rollup son específicos por plataforma. Si instalaste dependencias en Windows (`npm install` desde PowerShell), el build desde WSL fallará y viceversa. Solución: reinstalar desde la plataforma desde donde vayas a buildear.

```bash
# En WSL antes de deployar si venías de Windows:
rm -rf node_modules package-lock.json && npm install
```

## VPS

- **Host SSH:** alias `freejolitos`
- **Usuario:** `okami`
- **Directorio temporal:** `~/deploy-tmp/` (se crea y elimina en cada deploy)
- **Webroot:** `/var/www/html/freejolitos-root/`
- **Servidor:** Nginx, mismo VPS que `matrix.freejolitos.com`

## Nginx

Ver `deploy/nginx.conf.example` para la configuración de referencia del vhost.
