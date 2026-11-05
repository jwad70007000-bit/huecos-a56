#!/usr/bin/env bash
# Lanza Aider con las protecciones de seguridad de este repo. Lo usan los dos
# trabajos del flujo (encargo nuevo y chat), así las protecciones están en un solo sitio.
#
# Uso:  lanzar_aider.sh FICHERO_MENSAJE [FICHERO_HISTORIAL]
# Entorno: MODO (simple|arquitecto), PIENSA, ESCRIBE, BARATO, y ASK=1 para modo pregunta.
# Opcional: AIDER_LOG (registro, por defecto /tmp/aider.log) y COSTE_VAR (nombre de la
# variable donde se guarda el coste, por defecto COSTE).
#
# Seguridad: con --yes-always Aider aceptaría solo cualquier comando de terminal o
# URL que proponga el modelo, y aquí tiene a mano la clave de OpenRouter y el token
# del repo. Por eso se le prohíben ambas cosas (--no-suggest-shell-commands y
# --no-detect-urls).
MENSAJE="$1"
HISTORIAL="${2:-/tmp/aider.chat.history.md}"
LOG="${AIDER_LOG:-/tmp/aider.log}"

# Archivos de texto del proyecto que Aider puede editar.
# CLAUDE.md va aparte (--read): Aider lo lee como reglas, pero no lo edita.
ARCHIVOS=$(git ls-files | grep -E '\.(kt|kts|xml|md|properties)$' | grep -v '^CLAUDE\.md$')

if [ "$MODO" = simple ]; then
  if [ "$ASK" = 1 ]; then
    MODELOS=(--model "openrouter/$PIENSA" --chat-mode ask)
  else
    MODELOS=(--model "openrouter/$PIENSA" --edit-format diff)
  fi
else
  MODELOS=(--architect --model "openrouter/$PIENSA" \
    --editor-model "openrouter/$ESCRIBE" --editor-edit-format diff \
    --weak-model "openrouter/$BARATO")
fi

# Las reglas de CLAUDE.md solo si existe en esta rama (una rama antigua puede no tenerlo).
LEER=()
[ -f CLAUDE.md ] && LEER=(--read CLAUDE.md)

# Compilar tras cada cambio (función de serie de Aider: --auto-test). Si no compila,
# Aider ve el error y lo corrige solo. En todos los encargos y órdenes (una prueba
# real demostró que también los fáciles pueden romper la app); nunca en preguntas.
COMPILAR="gradle compileDebugKotlin --no-daemon -q"
PRUEBA=()
rm -f /tmp/compila.md
COMPILA_AQUI=no
if [ "$ASK" != 1 ] && command -v gradle > /dev/null; then
  COMPILA_AQUI=si
  PRUEBA=(--test-cmd "$COMPILAR" --auto-test)
fi

# Sin "set -e" a propósito: si Aider falla, el flujo lo cuenta como "sin cambios".
aider \
  "${MODELOS[@]}" \
  "${LEER[@]}" \
  "${PRUEBA[@]}" \
  --message-file "$MENSAJE" \
  --chat-history-file "$HISTORIAL" \
  --yes-always \
  --no-suggest-shell-commands \
  --no-detect-urls \
  --auto-commits \
  --no-gitignore \
  --no-check-update \
  --no-show-model-warnings \
  --no-pretty --no-stream \
  $ARCHIVOS 2>&1 | tee "$LOG"

# Coste aproximado: última cifra "session" que escribe Aider en el registro.
COSTE=$(grep -oE 'Cost: \$[0-9.]+ message, \$[0-9.]+ session' "$LOG" | tail -1 | grep -oE '\$[0-9.]+ session' | sed 's/ session//')
echo "${COSTE_VAR:-COSTE}=${COSTE:-no disponible}" >> "$GITHUB_ENV"

# Comprobación final para el comentario: ¿compila lo que ha quedado?
if [ "$COMPILA_AQUI" = si ]; then
  if $COMPILAR > /tmp/compila.log 2>&1; then
    echo "🛠️ **Compilación:** la app compila." > /tmp/compila.md
  else
    printf '🛠️ **Compilación:** ⚠️ la app NO compila. Pídele al agente que lo arregle o mira el [registro](%s/%s/actions/runs/%s).\n' \
      "$GITHUB_SERVER_URL" "$GITHUB_REPOSITORY" "$GITHUB_RUN_ID" > /tmp/compila.md
  fi
fi
