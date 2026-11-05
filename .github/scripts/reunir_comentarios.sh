#!/usr/bin/env bash
# Junta en un solo JSON los comentarios del Issue N y de sus Pull Requests del agente
# (ramas aider/issue-N-*). Sirve para calcular el coste acumulado del Issue.
# Uso: reunir_comentarios.sh N > /tmp/comentarios.json   (necesita GH_TOKEN)
N="$1"
PRS=$(gh pr list --state all --limit 100 --json number,headRefName 2>/dev/null \
  | jq -r --arg p "aider/issue-$N-" '.[] | select(.headRefName | startswith($p)) | .number')
for n in $N $PRS; do
  gh api "repos/$GITHUB_REPOSITORY/issues/$n/comments" --paginate 2>/dev/null | jq -c '.[]'
done | jq -s '.'
