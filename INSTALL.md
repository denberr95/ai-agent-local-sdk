# Requisiti e dipendenze

## Requisiti della workstation

| Requisito | Valore |
| --- | --- |
| Sistema operativo | macOS, Windows 10/11, Linux |
| CPU | 8 core consigliati, 4 minimi; su macOS e Windows assegnare 4 vCPU alla `podman machine` |
| Memoria | 32 GB minimi: il modello caricato ne occupa circa 23 (misurato su M1 Max 32 GB con il 10% di memoria libera residua) |
| Disco | Almeno 256 GB: modello (circa 23 GB), disco della `podman machine` (100 GB nella configurazione verificata), immagini (Oracle Free circa 9,5 GB, SonarQube circa 1,5 GB, security review circa 1 GB), database delle vulnerabilità di Grype (circa 3,4 GB), build e repository |
| Permessi | grant amministrativi o `sudo` per installare Ollama; nessun grant per OpenCode |
| Rete | solo per scaricare software e modello; a regime nessun provider cloud |

## Dipendenze

| Software | Uso | Note | Fonte |
| --- | --- | --- | --- |
| Git | Versionamento | | <https://git-scm.com/downloads> |
| Visual Studio Code | IDE | `opencode` dal terminale integrato | <https://code.visualstudio.com/download> |
| Ollama | Esecuzione locale dell'LLM su `127.0.0.1:11434` | Nativo sulla workstation, mai in container | <https://ollama.com/download> |
| Modello `flint:40b-a2b-qat-int4` | LLM del team | Alias `team-flint` creato da `ollama/Modelfile`; su Apple Silicon usa il runner MLX (misurati circa 58 token/s su M1 Max). La variante `40b-a2b-gguf-nvfp4` su Apple Silicon è circa 10 volte più lenta | <https://ollama.com/library/flint> |
| OpenCode **V2** | Agenti, skill e comandi | Non compatibile con OpenCode 1 | <https://opencode.ai/v2/docs> |
| Podman | Database, servizi e test effimeri | `podman machine` su macOS e Windows | <https://podman.io/docs/installation> |
| Immagine `docker.io/koalaman/shellcheck:v0.11.0` | Analisi statica degli script `.sh` (COM-007) | Eseguita con Podman, nessuna installazione locale | <https://github.com/koalaman/shellcheck> |
| Immagine `docker.io/hadolint/hadolint:v2.15.1` | Analisi statica dei Containerfile (PD-001) | Eseguita con Podman, nessuna installazione locale | <https://github.com/hadolint/hadolint> |
| Immagine `team-security-review:0.0.1` | Security review: Gitleaks, Semgrep, CycloneDX, Grype (COM-009); nessuna chiave API | Costruita da `Containerfile.security-review` della skill `common` su `maven:3.9.16-eclipse-temurin-25`, `zricethezav/gitleaks:v8.30.1` e `anchore/grype:v0.116.0`; circa 1 GB | Template nel kit |
| Immagine `docker.io/library/sonarqube:community` | Verifica qualità del codice (COM-008) | Sempre l'ultima Community Build, aggiornata con `podman pull` prima di ogni analisi | <https://hub.docker.com/_/sonarqube> |
| JDK e Maven/Gradle Wrapper | Build e test dei progetti Spring Boot, analisi SonarQube | Wrapper versionato nel progetto (SB-001); distribuzione JDK a scelta del team | <https://openjdk.org> |
| Immagine `docker.io/liquibase/liquibase:5.0.4` | Migration database (SQL-007, SB-005) | Solo in container costruito dal Containerfile del progetto, contro il database di prova; mai installato sulla workstation. Licenza FSL-1.1-ALv2, accettata dal team il 25 ottobre 2026 (consentiti uso interno e servizi professionali; vietato offrire un prodotto concorrente) | <https://hub.docker.com/r/liquibase/liquibase> |
| Immagini PostgreSQL, MySQL, Oracle Database Free | Database effimeri di test | Comandi in `references/commands.md` della skill `podman` | <https://hub.docker.com/_/postgres>, <https://hub.docker.com/_/mysql>, <https://container-registry.oracle.com> |
| Bash 3.2+ / PowerShell 5.1 o 7+ | Esecuzione degli script | Già presenti sui sistemi supportati | |

## Versioni

Versioni verificate il 25 ottobre 2026 sulla workstation di riferimento: macOS 26.7.1, Apple M1 Max, 32 GB. "Non verificata" indica un componente non ancora provato con il kit.

| Componente | Versione richiesta | Versione verificata |
| --- | --- | --- |
| macOS | Apple Silicon | 26.7.1 (arm64) |
| Windows 10/11 | — | 11 26100, con il profilo `lowmem` (vedi "Note per Windows") |
| Linux | — | Non verificata |
| Git | 2.x | 2.54.0 |
| Visual Studio Code | — | 1.142.0 |
| Ollama | 0.40.8 o successiva (requisito del modello) | 0.40.10 |
| Modello `flint:40b-a2b-qat-int4` | Tag fissato nel Modelfile | ID `9891844f06a2` |
| OpenCode | 2.x (V2) | 2.1.4 |
| Podman | — | 6.1.4, `podman machine` libkrun (6 CPU, 24 GB, 100 GB) |
| Provider Compose | Con supporto `--wait` | Docker Compose 5.6.1 |
| JDK | 25 LTS (SB-001) | OpenJDK 25.0.4.1 |
| Maven | Wrapper del progetto | 3.9.16 |
| Gradle | Wrapper del progetto | Non verificata |
| Immagine Liquibase | `5.0.4` (fissata nel Containerfile) | 5.0.4 (Java 21.0.11), driver PostgreSQL 42.7.13 via `lpm` |
| Bash | 3.2 o successiva | 3.2.57 |
| PowerShell | 5.1 o 7+ | Non verificata |
| curl | — | 8.7.1 |
| OpenSSL / LibreSSL | — | LibreSSL 3.3.6 |
| Immagine ShellCheck | `v0.11.0` (fissata) | 0.11.0 |
| Immagine Hadolint | `v2.15.1` (fissata) | 2.15.1 |
| Base immagine security review | `maven:3.9.16-eclipse-temurin-25` (fissata) | Maven 3.9.16, JDK 25.0.4.1, Ubuntu 24.04 |
| Gitleaks | `v8.30.1` (fissata) | 8.30.1 |
| Grype | `v0.116.0` (fissata), database delle vulnerabilità aggiornato automaticamente | 0.116.0 |
| Semgrep | `1.182.1` (fissata), regole `p/owasp-top-ten` e `p/java` alla data di build | 1.182.1 |
| CycloneDX Maven plugin | `2.9.3` (fissata in COM-009) | 2.9.3 |
| Immagine SonarQube Community Build | Ultima disponibile (tag `community`) | 26.10.0.133078 |
| SonarScanner per Maven | `5.8.0.7211` (fissato in COM-008) | 5.8.0.7211 |
| Immagine PostgreSQL | Versione del progetto | 18.6 |
| Immagine MySQL | Versione del progetto | 8.4.13 |
| Immagine Oracle Database Free | Versione del progetto | 23.26.3.0 |

## File di configurazione

| File | Destinazione | Scopo |
| --- | --- | --- |
| `ollama/Modelfile` | Ollama (`ollama create team-flint`) | Alias `team-flint`, contesto 16384 token |
| `ollama/Modelfile.lowmem` | Ollama (`ollama create team-flint`) | Alias `team-flint` del profilo `lowmem`: modello piu' piccolo, stesso contesto |
| `profiles/<nome>/` | Repository applicativo, tramite gli script con `--profile` | File che sostituiscono gli omonimi del kit (`AGENTS.md`, `opencode.jsonc`, `commands/*.md`), piu' `profile.conf` con gli agenti, le skill e i comandi da installare |
| `ollama/ollama.env` | Ambiente del server Ollama, tramite `scripts/ollama-env.sh` o `.ps1` | Valori delle variabili della sezione seguente |
| `config/opencode-user.example.jsonc` | `opencode.jsonc` nella directory `config` indicata da `opencode debug paths` | Modello predefinito `ollama/team-flint:latest`, aggiornamenti automatici disattivati |
| `AGENTS.md`, `opencode.jsonc`, `.opencode/` | Repository applicativo, tramite gli script | Regole, permessi, agenti, comandi e skill del team; solo skill del team visibili; modelli cloud di OpenCode disattivati |

## Configurazione del server Ollama

Valori in `ollama/ollama.env`, impostati da `scripts/ollama-env.sh` (macOS con `launchctl`, fino al riavvio del Mac; Linux con un drop-in systemd) o da `scripts/ollama-env.ps1` (Windows, variabili utente); poi riavviare Ollama.

| Variabile | Valore | Motivo |
| --- | --- | --- |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Un solo modello da circa 22 GB in memoria (predefinito 3) |
| `OLLAMA_NUM_PARALLEL` | `1` | Gli agenti lavorano in sequenza; la memoria cresce con richieste parallele × contesto (già il predefinito) |
| `OLLAMA_KEEP_ALIVE` | `30m` | Evita di ricaricare il modello fra un agente e l'altro (predefinito 5 minuti) |
| `OLLAMA_FLASH_ATTENTION` | `1` | Necessario per quantizzare la cache del contesto (runner llama.cpp, modelli GGUF) |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Circa metà della memoria del contesto rispetto a `f16` (runner llama.cpp; effetto sul runner MLX da verificare) |

## Note per Windows

Verificate su Windows 11 26100 con Ollama 0.40.11 e OpenCode 2.1.4.

- **Il tag del modello predefinito non si scarica.** `flint:40b-a2b-qat-int4` e' in formato MLX
  e `ollama pull` termina con `this model requires MLX support, but the MLX runtime is not
  available`. Su Windows e Linux serve un tag GGUF, oppure il profilo
  [`lowmem`](profiles/lowmem/README.md).
- **Le variabili di `ollama/ollama.env` valgono solo dal riavvio del server.** *Quit Ollama*
  dall'area di notifica chiude `ollama app.exe` ma lascia vivo il processo `ollama.exe`, che
  non si termina ne' con `Stop-Process` ne' con `taskkill /F` (*Access is denied*). Per
  verificare che il riavvio sia avvenuto: in Gestione attivita' deve sparire la voce
  `ollama.exe`, e `ollama ps` deve riportare un `UNTIL` coerente con `OLLAMA_KEEP_ALIVE`
  invece dei 5 minuti predefiniti.
- **Il log del server ruota a ogni riavvio**: le righe nuove vanno in
  `%LOCALAPPDATA%\Ollama\server.log` e le precedenti in `server-1.log`. Un `server.log` da
  0 byte non significa che non arrivino richieste.
- **`opencode models` puo' restare muto per minuti** senza errori a schermo: scarica il
  catalogo da `models.dev` (circa 5,8 MB) con un timeout di 10 secondi. Su una connessione
  lenta, o mentre un `ollama pull` e' in corso, fallisce e il log riporta
  `Failed to fetch models.dev`.
- **Non lanciare `ollama app.exe` da una sessione non interattiva**: parte ma non avvia il
  server. Da script usare `ollama.exe serve`.

## Script

| Script | Piattaforma | Uso |
| --- | --- | --- |
| `scripts/install.sh` | Linux, macOS | `scripts/install.sh <directory-progetto> [--force] [--profile <nome>]` |
| `scripts/install.ps1` | Windows | `scripts\install.ps1 <directory-progetto> [-Force] [-Profile <nome>]` |
| `scripts/ollama-env.sh` | Linux, macOS | `scripts/ollama-env.sh [--check]` |
| `scripts/ollama-env.ps1` | Windows | `scripts\ollama-env.ps1 [-Check]` |

`install` copia la configurazione del team nel repository applicativo senza sovrascrivere i file modificati, salvo `--force` (`-Force`) con backup; exit code `0` completato, `1` errore, `2` alcuni file saltati. Con `--profile <nome>` (`-Profile <nome>`) installa la variante descritta in `profiles/<nome>/README.md` invece del profilo predefinito: i file presenti nella directory del profilo sostituiscono gli omonimi del kit, e `profile.conf` limita gli agenti, le skill e i comandi copiati. Senza l'opzione il comportamento non cambia. Profilo disponibile: [`lowmem`](profiles/lowmem/README.md), per workstation che non possono dedicare al modello circa 23 GB. `ollama-env` imposta le variabili del server Ollama da `ollama/ollama.env` o, con `--check` (`-Check`), le confronta senza modificarle; exit code `0` ok, `1` errore, `2` argomenti non validi, `3` valori diversi. Procedura di adozione nel [README](README.md).
