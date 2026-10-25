#!/usr/bin/env bash
# ollama-env.sh - Configura le variabili d'ambiente del server Ollama per il kit (macOS e Linux).
#
# Uso:    scripts/ollama-env.sh [--check]
# Valori: ollama/ollama.env (lo stesso file letto da scripts/ollama-env.ps1).
#
# macOS:  launchctl setenv per l'app Ollama; i valori valgono fino al riavvio del Mac,
#         dopo un riavvio rilanciare lo script.
# Linux:  drop-in systemd /etc/systemd/system/ollama.service.d/opencode-kit.conf e riavvio
#         del servizio ollama (richiede sudo).
# --check mostra i valori attuali e li confronta con quelli del kit, senza modificarli.
#
# Exit code: 0 ok, 1 errore, 2 argomenti non validi, 3 (--check) valori diversi da quelli del kit.
# Versione Windows: scripts/ollama-env.ps1

set -euo pipefail

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$KIT_ROOT/ollama/ollama.env"
DROPIN_DIR="/etc/systemd/system/ollama.service.d"
DROPIN_FILE="$DROPIN_DIR/opencode-kit.conf"
CHECK=0
NAMES=()
VALUES=()
TMP_FILE=""

usage() {
    printf 'Uso: scripts/ollama-env.sh [--check]\n'
}

fail() {
    printf 'ERRORE: %s\n' "$1" >&2
    exit 1
}

cleanup() {
    if [ -n "$TMP_FILE" ]; then
        rm -f "$TMP_FILE"
    fi
}
trap cleanup EXIT

as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

read_env_file() {
    local line name value
    [ -f "$ENV_FILE" ] || fail "file non trovato: $ENV_FILE"
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            '' | '#'*) continue ;;
        esac
        name="${line%%=*}"
        value="${line#*=}"
        case "$name" in
            OLLAMA_*) ;;
            *) fail "riga non valida in ollama/ollama.env: $line" ;;
        esac
        NAMES+=("$name")
        VALUES+=("$value")
    done < "$ENV_FILE"
    [ "${#NAMES[@]}" -gt 0 ] || fail "nessuna variabile in ollama/ollama.env"
}

# report_check <nome> <valore-atteso> <valore-attuale>; ritorna 1 se diverso
report_check() {
    if [ "$3" = "$2" ]; then
        printf '[OK]          %s=%s\n' "$1" "$2"
        return 0
    fi
    printf "[DIVERSA]     %s: attuale='%s' atteso='%s'\n" "$1" "$3" "$2"
    return 1
}

macos_check() {
    local i current differences=0
    for i in "${!NAMES[@]}"; do
        current="$(launchctl getenv "${NAMES[$i]}" || true)"
        report_check "${NAMES[$i]}" "${VALUES[$i]}" "$current" || differences=1
    done
    return "$differences"
}

macos_apply() {
    local i
    for i in "${!NAMES[@]}"; do
        launchctl setenv "${NAMES[$i]}" "${VALUES[$i]}"
        printf '[IMPOSTATA]   %s=%s\n' "${NAMES[$i]}" "${VALUES[$i]}"
    done
    printf 'Riavvia Ollama: icona nella barra dei menu > Quit Ollama, poi riaprilo con: open -a Ollama\n'
    printf 'I valori valgono fino al riavvio del Mac: dopo un riavvio rilancia questo script.\n'
}

linux_require_service() {
    command -v systemctl >/dev/null 2>&1 \
        || fail "systemd non disponibile: imposta le variabili di ollama/ollama.env nell'ambiente in cui avvii 'ollama serve'"
    systemctl cat ollama.service >/dev/null 2>&1 \
        || fail "servizio ollama.service non trovato: installa Ollama con l'installer ufficiale oppure imposta le variabili nell'ambiente di 'ollama serve'"
}

linux_check() {
    local i current environment differences=0
    environment="$(systemctl show ollama.service --property=Environment --value)"
    for i in "${!NAMES[@]}"; do
        current="$(printf '%s\n' "$environment" | tr ' ' '\n' | sed -n "s/^${NAMES[$i]}=//p" | sed -n '1p')"
        report_check "${NAMES[$i]}" "${VALUES[$i]}" "$current" || differences=1
    done
    return "$differences"
}

linux_apply() {
    local i
    command -v sudo >/dev/null 2>&1 || [ "$(id -u)" -eq 0 ] || fail "servono i privilegi di root o sudo"
    TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/ollama-env.XXXXXX")"
    {
        printf '# Generato da scripts/ollama-env.sh del kit OpenCode: non modificare a mano.\n'
        printf '[Service]\n'
        for i in "${!NAMES[@]}"; do
            printf 'Environment="%s=%s"\n' "${NAMES[$i]}" "${VALUES[$i]}"
        done
    } > "$TMP_FILE"
    as_root mkdir -p "$DROPIN_DIR"
    as_root cp "$TMP_FILE" "$DROPIN_FILE"
    as_root chmod 644 "$DROPIN_FILE"
    as_root systemctl daemon-reload
    as_root systemctl restart ollama.service
    for i in "${!NAMES[@]}"; do
        printf '[IMPOSTATA]   %s=%s\n' "${NAMES[$i]}" "${VALUES[$i]}"
    done
    printf 'Servizio ollama riavviato con la configurazione %s\n' "$DROPIN_FILE"
}

for arg in "$@"; do
    case "$arg" in
        --check) CHECK=1 ;;
        -h | --help) usage; exit 0 ;;
        *)
            printf 'ERRORE: argomento non riconosciuto: %s\n' "$arg" >&2
            usage >&2
            exit 2
            ;;
    esac
done

read_env_file

case "$(uname -s)" in
    Darwin)
        command -v launchctl >/dev/null 2>&1 || fail "comando non trovato: launchctl"
        if [ "$CHECK" -eq 1 ]; then
            macos_check || { printf 'Valori diversi da quelli del kit: lancia scripts/ollama-env.sh senza --check.\n'; exit 3; }
        else
            macos_apply
        fi
        ;;
    Linux)
        linux_require_service
        if [ "$CHECK" -eq 1 ]; then
            linux_check || { printf 'Valori diversi da quelli del kit: lancia scripts/ollama-env.sh senza --check.\n'; exit 3; }
        else
            linux_apply
        fi
        ;;
    *)
        fail "sistema operativo non supportato: $(uname -s) (su Windows usa scripts/ollama-env.ps1)"
        ;;
esac
