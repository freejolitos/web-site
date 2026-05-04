---
title: "Cómo exponer tu app local a internet"
description: "Tunnels locales: cloudflared, ngrok, Tailscale Funnel, localhost.run y self-hosted. Guía práctica con troubleshooting incluido."
category: tecnico
date: 2026-05-03
---

Estás desarrollando una aplicación en tu máquina. Corre en `localhost:3000` y funciona bien. Necesitas que un cliente la vea para aprobar un cambio, que un compañero te ayude a depurar un problema, o que un servicio externo —un webhook de Stripe, GitHub o Slack— pueda llamar a un endpoint que solo existe en tu equipo.

Hacer un deploy completo es caro en tiempo: configurar servidor, base de datos, variables de entorno, CI/CD. Para algo que vas a borrar en una hora no vale la pena.

La solución es un tunnel: una conexión que expone tu puerto local a internet a través de un intermediario. Esta guía cubre las herramientas más usadas, cómo configurarlas, los problemas comunes que vas a encontrar, y cuál conviene en cada situación.

## Cómo funciona un tunnel

Tu máquina no es accesible desde internet por dos motivos: el router hace NAT (varias máquinas comparten una IP pública) y el firewall bloquea conexiones entrantes. Abrir puertos en el router es posible pero implica configuración manual, depende del proveedor de internet, y muchas veces no es viable —redes corporativas, IPs dinámicas, CGNAT del operador móvil.

Un tunnel evita ese problema invirtiendo el sentido de la conexión. Tu máquina abre una conexión saliente hacia un servidor en internet. Esa conexión queda abierta. Cuando llega una petición HTTP al servidor intermediario, este la reenvía por el túnel ya abierto hacia tu máquina, recibe la respuesta y la devuelve al cliente original.

Tres consecuencias prácticas:

- **No tocas el router ni el firewall.** La conexión sale desde tu máquina, lo cual está permitido por defecto en cualquier red.
- **Funciona detrás de NAT y de la mayoría de redes corporativas.** Si puedes navegar la web, puedes abrir un tunnel.
- **El servidor intermediario ve todo el tráfico.** Esto importa para cuestiones de privacidad y para entender por qué algunas herramientas son de pago: ese servidor cuesta dinero mantenerlo.

## cloudflared: opción rápida

`cloudflared` es la herramienta oficial de Cloudflare. Tiene dos modos: quick tunnel (sin cuenta) y tunnel persistente (con cuenta y dominio).

El quick tunnel es un comando:

```bash
npx cloudflared --url http://localhost:3000
```

En segundos te genera una URL del tipo `https://random-words-1234.trycloudflare.com`. Cualquiera con ese link entra a tu app. HTTPS incluido, sin configuración.

**Cuándo usarlo:** una demo improvisada, compartir algo durante 20 minutos, probar un webhook externo una sola vez.

**Limitaciones:**

- La URL es aleatoria y cambia cada vez que reinicias el comando.
- No hay panel de inspección de peticiones.
- Cloudflare puede aplicar límites de ancho de banda en quick tunnels (no documentan los valores exactos).

Si estos límites te molestan, la versión persistente resuelve los dos primeros.

## cloudflared: tunnel persistente

Para tener una URL estable necesitas una cuenta gratuita en Cloudflare y un dominio propio con los nameservers apuntados a Cloudflare. Con eso, cuatro comandos:

```bash
# 1. Vincular tu cuenta de Cloudflare
cloudflared login

# 2. Crear el tunnel (genera un ID y un archivo de credenciales)
cloudflared tunnel create mi-tunnel

# 3. Crear el registro DNS en tu zona
cloudflared tunnel route dns mi-tunnel dev.tudominio.com

# 4. Levantar el tunnel
cloudflared tunnel run mi-tunnel
```

`login` abre el navegador y descarga un certificado a `~/.cloudflared/cert.pem`. `tunnel create` guarda las credenciales en un JSON dentro de la misma carpeta. `route dns` crea un registro CNAME en tu zona de Cloudflare apuntando al tunnel —sin tocar el panel manualmente. `run` es el comando que vas a correr cada vez que quieras levantar el tunnel.

Para fijar el puerto local sin tener que pasarlo cada vez, crea `~/.cloudflared/config.yml`:

```yaml
tunnel: mi-tunnel
credentials-file: /home/usuario/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: dev.tudominio.com
    service: http://localhost:3000
  - service: http_status:404
```

Con esto, `dev.tudominio.com` siempre apunta a tu `localhost:3000` mientras el tunnel esté corriendo. Reinicias la máquina, vuelves a correr `cloudflared tunnel run mi-tunnel`, y la URL sigue siendo la misma.

**Cuándo usarlo:** desarrollo continuo donde compartes el link con tu equipo, integraciones con webhooks que necesitan endpoint estable, demos repetidas al mismo cliente.

## ngrok

ngrok fue la herramienta original en este espacio y sigue siendo la más conocida. El uso básico:

```bash
ngrok http 3000
```

Genera una URL aleatoria similar a la del quick tunnel de Cloudflare. La diferencia que justifica usarlo es el inspector web.

ngrok corre un servidor local en `http://localhost:4040`. Ahí ves todas las peticiones que pasan por el tunnel: método, URL, headers de request y response, body, tiempo de respuesta. Puedes repetir cualquier petición con un click, lo cual es muy útil para depurar webhooks: el servicio externo manda una petición, falla, ajustas tu código, y repites la misma petición desde el inspector sin tener que provocar el evento en el servicio externo otra vez.

**Cuándo usarlo:** integraciones con webhooks, depuración de APIs, situaciones donde necesitas ver exactamente qué llega a tu servidor.

**Limitaciones del plan gratuito:**

- Una sola sesión activa a la vez.
- URL aleatoria que cambia con cada reinicio. La URL fija requiere plan de pago, desde 8 dólares al mes.
- Pantalla intermedia de advertencia que el visitante tiene que aceptar la primera vez.

Si necesitas URL fija y no quieres pagar, cloudflared persistente es la alternativa directa, pero pierdes el inspector. Algunos usan las dos herramientas según el caso.

## Tailscale Funnel

Tailscale es una VPN basada en WireGuard pensada para conectar máquinas entre sí de forma privada. Si ya la usas, Funnel añade la capacidad de exponer un puerto al internet público.

```bash
tailscale funnel 3000
```

Te genera una URL del tipo `https://tu-maquina.tu-tailnet.ts.net`. Estable mientras no cambies el nombre de la máquina en Tailscale.

**Cuándo usarlo:** ya usas Tailscale para otras cosas y prefieres no añadir otra herramienta al stack. Si no usas Tailscale, instalarla solo para esto no tiene sentido.

**Limitaciones:** solo expone HTTPS en puertos 443, 8443 y 10000. El subdominio depende del nombre de tu tailnet. En el plan gratuito hay un límite de máquinas con Funnel activo.

## localhost.run

La opción minimalista: no instalas nada, funciona con SSH puro.

```bash
ssh -R 80:localhost:3000 nokey@localhost.run
```

El comando abre una conexión SSH al servidor de `localhost.run` y le pide que reenvíe el puerto 80 remoto al puerto 3000 local. El servidor imprime una URL pública en la terminal.

**Cuándo usarlo:** estás en una máquina ajena, en un servidor donde no tienes permisos para instalar software, o simplemente prefieres no instalar nada. SSH viene en cualquier sistema Unix.

**Limitaciones:** URL aleatoria en el plan gratuito, la conexión SSH puede caerse en redes inestables, sin inspector ni configuración avanzada. Es la opción de emergencia: la usas cuando no tienes otra cosa a mano.

## bore y frp: self-hosted

`bore` (Rust) y `frp` (Go) son herramientas open source para levantar tu propio servidor de tunnels. Necesitas un VPS con IP pública.

En el VPS:

```bash
# bore
bore server --min-port 1024

# frp
./frps -c frps.toml
```

En tu máquina local:

```bash
# bore
bore local 3000 --to <ip-del-vps>

# frp
./frpc -c frpc.toml
```

**Cuándo usarlo:** ya tienes un VPS, te importa que el tráfico no pase por servidores de terceros, necesitas exponer protocolos no-HTTP, o vas a usar tunnels en un sistema interno. Para uso ocasional no compensa. Para uso continuo y crítico, sí.

## Troubleshooting

### "command not found: cloudflared" / "ngrok"

La herramienta no está en el PATH. Si instalaste cloudflared con `brew`, debería estar disponible. Si descargaste el binario, muévelo a `/usr/local/bin`. Para evitar instalarlo globalmente, `npx cloudflared ...` funciona en cualquier máquina con Node.

### El tunnel funciona pero la app responde 502 o "connection refused"

Tu app no está corriendo en el puerto que el tunnel espera. Verifica con `curl http://localhost:3000` desde la misma máquina. Si curl falla, el problema es la app, no el tunnel.

Causa frecuente: la app está bindeada a `127.0.0.1` y el tunnel intenta conectar a `localhost`, que en algunos sistemas resuelve a IPv6 primero. Forzar `127.0.0.1` en la URL del tunnel suele resolverlo.

### Headers `Host` incorrectos

Algunos frameworks validan el header `Host` y rechazan peticiones que no vengan del dominio esperado. El tunnel reenvía el `Host` del dominio público, no `localhost:3000`. En cloudflared se corrige en `config.yml`:

```yaml
ingress:
  - hostname: dev.tudominio.com
    service: http://localhost:3000
    originRequest:
      httpHostHeader: localhost:3000
  - service: http_status:404
```

En Next.js: añadir el dominio del tunnel a `allowedDevOrigins` en `next.config.js`.

### WebSockets no se conectan

cloudflared y ngrok soportan WebSockets sin configuración extra. Si no funcionan, las causas habituales son que el cliente está enviando la petición de upgrade a un endpoint distinto al esperado, o que hay valores de `connectTimeout` o TLS en cloudflared que están interfiriendo. Revisa los logs del tunnel y del servidor de la app.

### El tunnel se desconecta después de un tiempo

Causas comunes: la máquina entra en suspensión (configura el sistema para no suspender mientras el tunnel está activo), conexión de red inestable (cloudflared persistente reintenta solo pero puede tardar en recuperarse), o el plan gratuito de ngrok que cierra sesiones tras varias horas.

### Webhooks llegan duplicados o con delay

No es problema del tunnel: muchos servicios reintentan webhooks si no reciben respuesta `200` rápido. Si tu app tarda en responder o devuelve un error, el servicio reintenta. Devuelve `200` lo antes posible y procesa el webhook de forma asíncrona si hace falta.

## Comparativa

| Herramienta | URL fija gratis | Sin cuenta | Inspector web | Self-hosted |
|---|---|---|---|---|
| cloudflared (quick) | ❌ | ✅ | ❌ | ❌ |
| cloudflared (persistente) | ✅ con dominio | ❌ | ❌ | ❌ |
| ngrok | ❌ (pago) | ✅ | ✅ | ❌ |
| Tailscale Funnel | ✅ | ❌ | ❌ | ❌ |
| localhost.run | ❌ | ✅ | ❌ | ❌ |
| bore / frp | ✅ | ❌ | ❌ | ✅ |

La elección se reduce a tres preguntas: si tienes dominio propio, si necesitas inspeccionar peticiones, y si te importa que el tráfico pase por servidores de terceros.

Para la mayoría de casos la combinación práctica es cloudflared persistente para el día a día y ngrok ocasional cuando hace falta el inspector. Es la configuración con mejor relación coste-beneficio en este momento.

[okami@freejolitos]$ _
