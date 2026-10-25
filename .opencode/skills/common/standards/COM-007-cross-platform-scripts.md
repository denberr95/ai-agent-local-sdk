# COM-007 — Script cross-platform

> Stato: **approvato** il 25 ottobre 2026. Vale per script di build, test, setup e supporto allo sviluppo.

## Coppia obbligatoria

- Ogni script viene fornito in due versioni con lo stesso nome base: `nome.sh` (Linux e macOS) e `nome.ps1` (Windows).
- Vietati `.bat` e `.cmd`.
- Le due versioni hanno stessi argomenti (nella forma idiomatica di ciascuna shell), stessi exit code e stessi messaggi.
- Le differenze di comportamento inevitabili sono documentate nell'header dello script e nel README.

## Bash (Linux e macOS)

- Shebang `#!/usr/bin/env bash` e `set -euo pipefail`.
- Compatibilità con Bash 3.2 (macOS): vietati array associativi, `mapfile`/`readarray`, `${var,,}`, `${var^^}`, `|&`, `coproc`.
- Evitare opzioni che differiscono fra GNU e BSD: `sed -i`, `readlink -f`, `date -d`, `grep -P`, `xargs -r`, `stat -c`, `sort -V`, `mktemp` senza template. Se inevitabili, distinguere con `uname -s`.
- Variabili sempre quotate; verificare i comandi richiesti con `command -v`.
- Fine riga LF; bit eseguibile impostato (`chmod +x`).

## PowerShell (Windows)

- Compatibile con Windows PowerShell 5.1 e PowerShell 7+.
- `Set-StrictMode -Version Latest` e `$ErrorActionPreference = 'Stop'`.
- File di testo scritti in UTF-8 senza BOM quando devono essere letti da altri tool.
- Sorgente ASCII per evitare problemi di encoding su PowerShell 5.1.
- Fine riga CRLF (`.gitattributes`).

## Regole comuni

- Exit code documentati: `0` successo, diverso da zero per errore; nessun errore silenzioso.
- Nessun segreto negli argomenti, nell'output o nei file temporanei.
- Nessuna operazione distruttiva senza conferma esplicita o opzione dedicata (es. `--force`) con backup.
- Opzione `--dry-run` (`-DryRun`) per gli script con operazioni distruttive o non reversibili.
- Nessun download ed esecuzione diretta (`curl | sh`, `iex (iwr ...)`).
- File temporanei in directory create con template e rimossi alla fine.

## Analisi statica

- Ogni script `.sh` nuovo o modificato passa **ShellCheck**, eseguito con Podman tramite l'immagine `docker.io/koalaman/shellcheck:v0.11.0`; nessuna installazione locale.
- Gate: exit code `0` → `PASS`; qualsiasi finding → `FAIL` finché non è corretto. Podman o immagine non disponibili → `NOT_VERIFIED`.
- Eccezioni solo con direttiva `# shellcheck disable=SCxxxx` sulla riga interessata e commento che ne spiega il motivo; mai disabilitazioni globali.
- Gravità per il report (COM-001): `error` → High, `warning` → Medium, `note`/`info` e `style` → Low.
- Script PowerShell: PSScriptAnalyzer quando disponibile, altrimenti `NOT_VERIFIED`.

Comandi verificati con Podman 6.1.4 su macOS; la variante PowerShell è da verificare su Windows. Dalla root del repository, indicando gli script da analizzare:

```bash
podman run --rm -v "$PWD:/mnt:ro,Z" -w /mnt docker.io/koalaman/shellcheck:v0.11.0 -f gcc scripts/install.sh
```

```powershell
podman run --rm -v "${PWD}:/mnt:ro,Z" -w /mnt docker.io/koalaman/shellcheck:v0.11.0 -f gcc scripts/install.sh
```

Tutti gli script del repository:

```bash
podman run --rm -v "$PWD:/mnt:ro,Z" -w /mnt docker.io/koalaman/shellcheck:v0.11.0 -f gcc $(find . -name '*.sh' -not -path './.git/*')
```

```powershell
podman run --rm -v "${PWD}:/mnt:ro,Z" -w /mnt docker.io/koalaman/shellcheck:v0.11.0 -f gcc ((Get-ChildItem -Recurse -Filter *.sh | Resolve-Path -Relative) -replace '\\', '/')
```

- Il repository è montato in sola lettura (`ro`); `Z` serve sui sistemi Linux con SELinux ed è ignorato altrove.
- L'output `-f gcc` riporta `file:riga:colonna: gravità: messaggio [SCxxxx]`, da trascrivere nei finding secondo COM-004.
