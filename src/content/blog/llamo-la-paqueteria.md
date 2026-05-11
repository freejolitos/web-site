---
title: "Llamó la paquetería"
description: "Un ataque de ingeniería social paso a paso, por qué el factor humano no es el problema, y qué medidas concretas haberlo evitado."
category: opinion
date: 2026-05-09
---

Ella esperaba un paquete. Eso es lo primero que conviene decir, porque es la pieza que hace funcionar todo lo que sigue.

El teléfono sonó a media tarde. Una voz cordial, profesional, identificándose como personal de la paquetería. Había un problema menor con la entrega y necesitaban verificar su identidad. Le iban a enviar un código por SMS, y solo tenía que leerlo en voz alta para completar la verificación. Tres segundos después el código llegó, y ella lo leyó.

Lo que acababa de autorizar no era una entrega. Era el cambio de número asociado a su cuenta de WhatsApp.

En los siguientes diez minutos, alguien usó ese acceso para entrar a su WhatsApp Web y leer mensajes. Encontró el correo electrónico que usaba para todo. Inició recuperación de contraseña en el correo y, como en muchos servicios, el segundo factor estaba puesto en "recibir código por SMS al número que ahora controla otra persona". Cambió la contraseña del correo. Con el correo controlado, fue desbloqueando, una por una, sus redes sociales, su cuenta del banco —ahí los frenó una llamada de seguridad del banco, por suerte—, sus suscripciones, sus respaldos en la nube.

Recuperarlo todo nos tomó semanas y muchas conversaciones por chat con soporte de varias empresas. Lo recuperamos. La pregunta que quedó dando vueltas no fue qué hicimos para arreglarlo, sino qué pudo haberlo evitado desde antes.

## Anatomía de un ataque que no es sofisticado

El ataque que sufrió mi amiga no requiere recursos técnicos avanzados. Funciona porque ensambla bien cinco piezas:

**Un pretexto plausible.** Una llamada de una paquetería cuando estás esperando un paquete no levanta sospecha; encaja perfectamente con tus expectativas. El atacante apostó al contexto correcto y ganó.

**Una voz con guion profesional.** No hubo gritos ni amenazas ni urgencia exagerada. Hubo cordialidad, vocabulario técnico moderado y la actitud de quien está haciendo trámites todo el día. Eso desarma cualquier alarma intuitiva.

**Una instrucción específica y simple.** Leer un código que llega por SMS, en voz alta. Lo haces cada vez que entras a una página que pide verificación. El sistema te entrenó para ese gesto exacto.

**Un sistema que confía en lo que oye.** WhatsApp, como la mayoría de servicios, asume que el código enviado por SMS solo lo conoce quien recibió el SMS. La premisa es razonable si nadie más está en línea preguntando. Cuando alguien sí lo está, el servicio no tiene cómo notarlo.

**Una arquitectura de cuentas en cascada.** Si WhatsApp fuera una isla, perderlo dolería pero quedaría contenido. Como WhatsApp suele estar conectado al correo y el correo a todo lo demás, perder WhatsApp se traduce en perder todo.

El último punto es el que más importa. El ataque inicial fue chico: una cuenta de mensajería. La cascada vino después, y la habilitó la forma en que estaban organizadas las recuperaciones.

## El factor humano no es debilidad: es superficie

Existe una tradición incómoda en seguridad que culpa a los usuarios por caer en estos ataques. Esa lectura es cómoda porque no exige cambiar el diseño de nada. También es falsa.

Las personas no son ingenuas; están operando en condiciones diseñadas para que actúen rápido. Reciben decenas de notificaciones al día, llamadas reales de servicios reales que les piden códigos reales por SMS, y aprenden, correctamente, que ese flujo es normal. El atacante explota esa normalidad. La responsabilidad no se reparte por igual entre quien diseñó el flujo, quien lo opera y quien lo sufre.

El eslabón humano se ataca en condiciones de poco contexto, mucha presión y entrenamiento previo en hacer exactamente lo que el atacante pide. La defensa no puede ser "ser más listo". Tiene que ser estructural: que las defensas técnicas estén ahí para sostenerte cuando tu atención falla. No evitan todos los errores, pero sí impiden que un error pequeño se convierta en pérdida total.

## Las tres capas

El control de accesos serio descansa en tres capas. La fortaleza real no depende de la más fuerte, sino de la más débil de las tres.

### Capa 1: contraseñas únicas, gestionadas

Una contraseña no te protege en abstracto. Te protege de que alguien acceda a un servicio específico sin tu autorización. Si reutilizas la misma contraseña en quince sitios, cuando uno se filtra (y todos los meses se filtran sitios), el atacante tiene quince accesos, no uno.

La única forma sostenible de tener contraseñas únicas y largas en cada sitio es un gestor de contraseñas. No el navegador, que ata la base completa a tu cuenta de Google o Apple. Un gestor dedicado: Bitwarden, Proton Pass, KeePassXC, 1Password. Las diferencias entre ellos importan menos que la decisión de usar uno.

Para alguien en tu entorno cercano que no es técnico, la recomendación práctica es la que tenga la mejor experiencia móvil. Bitwarden o Proton Pass cumplen bien. Lo importante es que la persona pueda guardar y autocompletar contraseñas sin fricción. Si la herramienta es fricción, la abandonan en una semana.

La contraseña maestra del gestor sí tiene que ser fuerte y única. Esa es la única que la persona tiene que recordar. El resto las inventa el gestor.

### Capa 2: segundo factor, con honestidad sobre cuál

El segundo factor existe para que tener tu contraseña no alcance. No todos los segundos factores defienden contra los mismos ataques.

**SMS** es el más débil. Defiende contra credenciales filtradas en una base de datos. Cae frente a llamadas como la que recibió mi amiga, porque el código se puede transmitir por voz. También cae frente a SIM swapping[^1].

**TOTP**, los códigos rotativos de seis dígitos que dan apps como Aegis, 2FAS o Authy, defiende contra todo lo anterior. El código cambia cada treinta segundos y vive en tu teléfono, no llega como mensaje. Sigue siendo vulnerable a phishing en tiempo real, donde un atacante presenta una página falsa que reenvía tus datos al sitio real mientras escribes. Es un ataque más sofisticado y mucho menos común.

**WebAuthn con llave de hardware** (YubiKey, Nitrokey, SoloKey) es el único método que resiste phishing por diseño, porque la llave verifica criptográficamente el dominio antes de responder. Si la página es falsa, la llave no responde.

La recomendación honesta para la mayoría es TOTP. Resuelve el caso que afectó a mi amiga y casi todo lo demás. La diferencia importante es dejar SMS atrás siempre que se pueda. Para alguien menos técnico, instalar 2FAS o Aegis y migrar el correo principal es un paso enorme. No hace falta migrar todo de golpe. El correo es el que abre la cascada; el correo es donde empieza el blindaje.

### Capa 3: recuperación, donde casi todo se rompe

Es la capa más descuidada, y es la que el atacante usa cuando no puede entrar de frente. Si tu correo se recupera con un SMS al número que el atacante acaba de robar, tu segundo factor TOTP no sirve de nada.

Lo que conviene hacer, en orden:

Imprimir los códigos de recuperación que cada servicio te da cuando activas 2FA, y guardarlos en un lugar físico confiable. En papel, no en una nota del teléfono. Si el teléfono se pierde, el papel sigue ahí.

Revisar qué métodos de recuperación tiene cada servicio importante y desactivar los que dependen de SMS al mismo número que estás protegiendo. Si Google te deja recuperar la cuenta con un código a tu número y ese número está comprometido, el 2FA no te salva.

Para alguien en tu entorno cercano, esto se simplifica así: imprime los códigos de recuperación del correo principal, guárdalos donde guardas documentos importantes, y revisa que el correo no se pueda recuperar con un SMS al teléfono. Ese gesto único cierra el agujero más grande.

## La regla que cubre el ochenta por ciento

Si tuvieras que enseñarle a alguien una sola cosa, sería esta:

> Ningún código que recibas por SMS o por app de autenticación se dice en voz alta a nadie, jamás, bajo ninguna circunstancia. Si alguien al teléfono lo necesita para hacer algo, no es legítimo.

Es simple. Es accionable. La puede aplicar cualquiera sin entender criptografía. Cubre el ataque que sufrió mi amiga y el noventa por ciento de las variantes telefónicas del mismo ataque.

Conviene también enseñar la pausa de tres segundos: cuando alguien llama y te pide actuar rápido, cuelga y vuelve a llamar tú a la empresa al número oficial. Una empresa legítima nunca se molesta si haces eso.

## Llevarlo al entorno cercano sin paranoia

La cultura hacker, en su sentido original, es curiosidad por entender cómo funcionan los sistemas, incluyendo el sistema "alguien me está llamando ahora mismo". Compartir esa curiosidad con quien tienes cerca es trabajo cultural concreto.

Lo que funciona es la conversación tranquila, en una tarde sin urgencia, mostrándole a la persona cómo instalar un gestor, cómo activar TOTP en su correo, cómo imprimir los códigos. Sentarse a hacerlo, no mandar un enlace. La diferencia entre una persona protegida y una no protegida no es lo que sabe, es si alguien se sentó con ella a configurarlo.

Lo que no funciona es asustar. Las narrativas de miedo paralizan o se descartan. Las narrativas de soberanía —tú decides, tú controlas, tú eliges— invitan a actuar.

---

A mi amiga le recuperamos las cuentas. Hoy tiene un gestor de contraseñas, TOTP en su correo y un sobre con códigos de recuperación en su cajón. Me dijo algo que vale la pena cerrar parafraseando: ella siempre había pensado que ese tipo de cosas le pasaba a gente descuidada. Cuando vio el ataque descompuesto, paso a paso, entendió que el descuido no era el problema. El problema era no haber tenido nunca, antes, las herramientas para que un descuido normal no terminara en desastre.

Ese es el trabajo. Compartir las herramientas, una conversación a la vez.

[okami@freejolitos]$ _

[^1]: SIM swapping es un ataque en el que el atacante convence a la operadora telefónica de transferir tu número a una SIM que él controla. Una vez que tiene el número, recibe todos tus SMS, incluidos los códigos de 2FA. Refuerza la misma conclusión: SMS no es un canal confiable para autenticación crítica.
