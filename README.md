# Huecos

App Android mínima: se abre y muestra el texto **Huecos**. Se programa hablando con el agente **Aider** (DeepSeek vía OpenRouter), igual que [lector-prueba](https://github.com/jwad70007000-bit/lector-prueba).

## Descargar la APK

- **Versión principal** (lo que hay en `main`): https://github.com/jwad70007000-bit/huecos-a56/releases/download/ultima/huecos-a56.apk
- **Versión de prueba** (la del último encargo del agente, antes de aceptarlo): https://github.com/jwad70007000-bit/huecos-a56/releases/download/prueba/huecos-a56.apk

Cada cambio compila la APK automáticamente. La llave de firma `debug.keystore` es solo de **pruebas** (contraseña pública `android`): sirve para que cada versión se instale encima de la anterior. No usar para publicar en Google Play.

## Cómo hablar con tu agente

1. **Pedir algo nuevo:** abre un Issue cuyo título empiece por **Agente** (por ejemplo: "Agente, pon el texto en rojo") o usa el formulario: https://github.com/jwad70007000-bit/huecos-a56/issues/new?template=encargo.yml
2. **Esperar:** en unos minutos el agente comenta con el enlace al Pull Request, la APK de prueba y un parte (modelos, tokens y coste). Antes compila la app y, si no compila, corrige el error solo.
3. **Corregir o preguntar:** comenta en el Issue o en el Pull Request. Si acaba en `?` o empieza por "pregunta", te contesta sin tocar nada; si no, cambia el código.
4. **Aceptar:** en el Pull Request pulsa **Merge pull request** → **Confirm merge**.

Solo hace caso al dueño del repositorio, nunca ejecuta comandos ni abre enlaces, y sus reglas están en `CLAUDE.md`. Necesita el secreto `OPENROUTER_API_KEY` (Settings → Secrets and variables → Actions). Pon un límite de gasto a esa clave en OpenRouter.
