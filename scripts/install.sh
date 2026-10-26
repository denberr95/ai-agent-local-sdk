#!/usr/bin/env bash
# install.sh - Copia la configurazione OpenCode del team in un repository (Linux e macOS).
#
# Uso:   scripts/install.sh <directory-progetto> [--force] [--profile <nome>]
# Copia: AGENTS.md, opencode.jsonc, .opencode/agents, .opencode/commands, .opencode/skills
#
# Con --profile <nome> legge profiles/<nome>/: i file presenti li' sostituiscono gli omonimi
# del kit e, se profile.conf elenca AGENTS, SKILLS o COMMANDS, vengono installati solo quelli. Senza
# --profile il comportamento e' invariato. Profili disponibili: vedi profiles/*/README.md.
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
PROFILE=""
PROFILE_DIR=""
AGENTS_FILTER=""
SKILLS_FILTER=""
COMMANDS_FILTER=""
CREATED=0
UNCHANGED=0
UPDATED=0
SKIPPED=0

usage() {
    printf 'Uso: scripts/install.sh <directory-progetto> [--force] [--profile <nome>]\n'
}

fail() {
    printf 'ERRORE: %s\n' "$1" >&2
    exit 1
}

# profile_source <percorso-relativo>
# Stampa il file del profilo che sostituisce quello del kit, se esiste. La corrispondenza
# toglie il prefisso .opencode/: AGENTS.md -> <profilo>/AGENTS.md, .opencode/commands/x.md ->
# <profilo>/commands/x.md. Niente in uscita significa "usa il file del kit".
profile_source() {
    local rel="$1" candidate
    [ -n "$PROFILE_DIR" ] || return 0
    candidate="$PROFILE_DIR/${rel#.opencode/}"
    [ -f "$candidate" ] && printf '%s\n' "$candidate"
    return 0
}

# copy_file <percorso-relativo> [sorgente-alternativa]
copy_file() {
    local rel="$1"
    local src="${2:-$KIT_ROOT/$rel}"
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

while [ "$#" -gt 0 ]; do
    case "$1" in
        --force) FORCE=1 ;;
        --profile)
            [ -n "${2:-}" ] || fail "--profile richiede un nome"
            PROFILE="$2"
            shift
            ;;
        --profile=*) PROFILE="${1#--profile=}" ;;
        -h | --help) usage; exit 0 ;;
        -*) usage >&2; fail "opzione non riconosciuta: $1" ;;
        *)
            [ -z "$TARGET" ] || fail "indicare una sola directory"
            TARGET="$1"
            ;;
    esac
    shift
done

if [ -n "$PROFILE" ]; then
    case "$PROFILE" in
        */* | '' | .*) fail "nome di profilo non valido: $PROFILE" ;;
    esac
fi

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

if [ -n "$PROFILE" ]; then
    PROFILE_DIR="$KIT_ROOT/profiles/$PROFILE"
    [ -d "$PROFILE_DIR" ] || fail "profilo non trovato: profiles/$PROFILE"
    if [ -f "$PROFILE_DIR/profile.conf" ]; then
        # Lettura senza eseguire il file: si accettano solo le righe NOME="valori".
        AGENTS_FILTER="$(sed -n 's/^AGENTS="\(.*\)"[[:space:]]*$/\1/p' "$PROFILE_DIR/profile.conf")"
        SKILLS_FILTER="$(sed -n 's/^SKILLS="\(.*\)"[[:space:]]*$/\1/p' "$PROFILE_DIR/profile.conf")"
        COMMANDS_FILTER="$(sed -n 's/^COMMANDS="\(.*\)"[[:space:]]*$/\1/p' "$PROFILE_DIR/profile.conf")"
    fi
fi

STAMP="$(date +%Y%m%d%H%M%S)"
VERSION="$(cat "$KIT_ROOT/VERSION")"

# selected_paths <sottodirectory-di-.opencode> <elenco-nomi> <file|dir>
# Senza elenco restituisce tutti i file della sottodirectory, come il profilo predefinito.
selected_paths() {
    local base=".opencode/$1" names="$2" kind="$3" name
    if [ -z "$names" ]; then
        find "$base" -type f ! -name '.DS_Store'
        return
    fi
    for name in $names; do
        if [ "$kind" = file ]; then
            [ -f "$base/$name.md" ] || fail "non presente nel kit: $base/$name.md"
            printf '%s\n' "$base/$name.md"
        else
            [ -d "$base/$name" ] || fail "non presente nel kit: $base/$name"
            find "$base/$name" -type f ! -name '.DS_Store'
        fi
    done
}

cd "$KIT_ROOT"
while IFS= read -r rel; do
    copy_file "$rel" "$(profile_source "$rel")"
done < <(
    {
        printf '%s\n' AGENTS.md opencode.jsonc
        selected_paths agents "$AGENTS_FILTER" file
        selected_paths commands "$COMMANDS_FILTER" file
        selected_paths skills "$SKILLS_FILTER" dir
    } | LC_ALL=C sort
)

printf 'Kit %s%s in %s: creati=%d invariati=%d aggiornati=%d saltati=%d\n' \
    "$VERSION" "${PROFILE:+ (profilo $PROFILE)}" \
    "$TARGET" "$CREATED" "$UNCHANGED" "$UPDATED" "$SKIPPED"

if [ "$SKIPPED" -gt 0 ]; then
    printf 'File saltati: uniscili a mano oppure rilancia con --force.\n'
    exit 2
fi
