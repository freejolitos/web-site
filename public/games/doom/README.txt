Easter egg — DOOM en /dev/tty0/
================================

Para que el comando "bash doom/play.sh" funcione en la terminal oculta
del sitio, se necesitan tres archivos en este directorio:

  js-dos.js         Emulador DOSBox compilado a JavaScript (js-dos v8)
  js-dos.wasm       Binario WebAssembly cargado automáticamente por js-dos.js
  freedoom.jsdos    Bundle con FreeDOOM + dosbox.conf


Obtener js-dos v8
-----------------
Descargar desde https://github.com/caiiiycuk/js-dos/releases (v8.x)
o usar la CDN para obtener la versión actual:

  curl -O https://v8.js-dos.com/latest/js-dos.js
  curl -O https://v8.js-dos.com/latest/js-dos.wasm

Verificar que ambos archivos queden en public/games/doom/.


Crear el bundle freedoom.jsdos
------------------------------
Un .jsdos es un archivo ZIP renombrado. Estructura interna:

  dosbox.conf
  FREEDOOM1.WAD
  chocolate-doom.exe   (o cualquier sourceport DOS-compatible)

1. Descargar FreeDOOM desde https://freedoom.github.io/
   Usar FREEDOOM1.WAD (fase 1, compatible con DOOM episode 1)

2. Obtener un sourceport DOS. Chocolate DOOM 2.x para DOS funciona.
   Alternativa: usar DOOM.EXE + DOOM1.WAD shareware (también redistribuible).

3. Crear dosbox.conf mínimo:
   ---
   [autoexec]
   mount c .
   c:
   chocolate-doom.exe -iwad FREEDOOM1.WAD
   ---

4. Empaquetar:
   zip freedoom.jsdos dosbox.conf FREEDOOM1.WAD chocolate-doom.exe

5. Copiar freedoom.jsdos a este directorio.


Licencias
---------
js-dos: GPL-2.0 — https://github.com/caiiiycuk/js-dos
FreeDOOM: BSD modificada — https://freedoom.github.io/
DOOM shareware: redistribuible sin modificaciones — id Software
