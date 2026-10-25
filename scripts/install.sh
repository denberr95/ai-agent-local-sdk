#!/usr/bin/env bash
# install.sh - Copia la configurazione OpenCode del team in un repository (Linux e macOS).
#
# Uso:   scripts/install.sh <directory-progetto> [--force]
# Copia: AGENTS.md, opencode.jsonc, .opencode/agents, .opencode/commands, .opencode/skills
#
# I file gia' presenti e diversi vengono saltati. Con --force vengono sostituiti
# dopo averne salvato una copia <file>.bak-<timestamp>. Nessun file viene cancellato.
#
# Exit code: 0 ok, 1 errore, 2 alcuni file saltati.
# Versione Windows: scripts/install.ps1

set -euo pipefail

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=""
FORCE=0
CREATED=0
UNCHANGED=0
UPDATED=0
SKIPPED=0

usage() {
    printf 'Uso: scripts/install.sh <directory-progetto> [--force]\n'
}

fail() {
    printf 'ERRORE: %s\n' "$1" >&2
    exit 1
}

copy_file() {
    local rel="$1"
    local src="$KIT_ROOT/$rel"
    local dest="$TARGET/$rel"

    if [ ! -e "$dest" ]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        printf '[CREATO]      %s\n' "$rel"
        CREATED=$((CREATED + 1))
    elif [ ! -f "$dest" ]; then
        fail "esiste ma non e' un file: $rel"
    elif cmp -s "$src" "$dest"; then
        UNCHANGED=$((UNCHANGED + 1))
    elif [ "$FORCE" -eq 1 ]; then
        cp "$dest" "$dest.bak-$STAMP"
        cp "$src" "$dest"
        printf '[AGGIORNATO]  %s (copia precedente: .bak-%s)\n' "$rel" "$STAMP"
        UPDATED=$((UPDATED + 1))
    else
        printf '[SALTATO]     %s (diverso dal kit)\n' "$rel"
        SKIPPED=$((SKIPPED + 1))
    fi
}

for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        -h | --help) usage; exit 0 ;;
        -*) usage >&2; fail "opzione non riconosciuta: $arg" ;;
        *)
            [ -z "$TARGET" ] || fail "indicare una sola directory"
            TARGET="$arg"
            ;;
    esac
done

if [ -z "$TARGET" ]; then
    usage >&2
    fail "directory del progetto mancante"
fi

for cmd in cmp cp date find mkdir sort; do
    command -v "$cmd" >/dev/null 2>&1 || fail "comando non trovato: $cmd"
done

[ -d "$TARGET" ] || fail "directory non trovata: $TARGET"
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" != "$KIT_ROOT" ] || fail "la destinazione coincide con il repository del kit"

STAMP="$(date +%Y%m%d%H%M%S)"
VERSION="$(cat "$KIT_ROOT/VERSION")"

cd "$KIT_ROOT"
while IFS= read -r rel; do
    copy_file "$rel"
done < <(
    printf '%s\n' AGENTS.md opencode.jsonc
    find .opencode/agents .opencode/commands .opencode/skills -type f ! -name '.DS_Store' | LC_ALL=C sort
)

printf 'Kit %s in %s: creati=%d invariati=%d aggiornati=%d saltati=%d\n' \
    "$VERSION" "$TARGET" "$CREATED" "$UNCHANGED" "$UPDATED" "$SKIPPED"

if [ "$SKIPPED" -gt 0 ]; then
    printf 'File saltati: uniscili a mano oppure rilancia con --force.\n'
    exit 2
fi
