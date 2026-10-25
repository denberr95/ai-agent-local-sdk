# OpenCode Team Configuration

Agenti, comandi, skill e standard del team per sviluppare progetti **Spring Boot, PL/SQL e Podman** con **OpenCode V2** e un LLM locale (**Ollama**). Nessun provider cloud, nessun runner o server custom.

## Avvio rapido

1. Prepara la workstation seguendo [Avviare l'ambiente di sviluppo](#avviare-lambiente-di-sviluppo): requisiti in [INSTALL.md](INSTALL.md), server Ollama, modello del team, profilo utente OpenCode e Podman.
2. Installa il kit nel repository applicativo:

   ```bash
   scripts/install.sh ../mio-progetto
   ```

   ```powershell
   .\scripts\install.ps1 ..\mio-progetto
   ```

3. Dal repository applicativo avvia `opencode` e lancia `/feature <descrizione della feature>`.

## Avviare l'ambiente di sviluppo

Guida completa partendo dalla copia del kit. Le fasi 1–5 si eseguono una volta per workstation, le fasi 6–7 per ogni repository applicativo. Comandi verificati su macOS (Apple Silicon); le varianti Windows e Linux seguono la documentazione ufficiale di Ollama e non sono ancora state provate con il kit.

### 1. Copia del kit

```bash
git clone <url-del-kit> opencode-kit
cd opencode-kit
```

Installa prima requisiti e dipendenze elencati in [INSTALL.md](INSTALL.md).

### 2. Server Ollama

Imposta le variabili del server con lo script del kit, che legge i valori da `ollama/ollama.env` (motivazioni in [INSTALL.md](INSTALL.md)):

```bash
scripts/ollama-env.sh
```

```powershell
.\scripts\ollama-env.ps1
```

- **macOS**: imposta le variabili con `launchctl`; poi chiudi Ollama dalla barra dei menu (*Quit Ollama*) e riaprilo con `open -a Ollama`. I valori valgono fino al riavvio del Mac: dopo un riavvio rilancia lo script.
- **Linux**: scrive il drop-in systemd `/etc/systemd/system/ollama.service.d/opencode-kit.conf` e riavvia il servizio `ollama` (chiede la password di `sudo`).
- **Windows**: imposta variabili utente permanenti; poi chiudi Ollama dall'area di notifica e riaprilo dal menu Start.

Per controllare i valori senza modificarli: `scripts/ollama-env.sh --check` (`.\scripts\ollama-env.ps1 -Check`), che esce con codice 3 se qualcosa è diverso.

Verifica che il server risponda (su Windows usa `curl.exe`):

```bash
curl -fsS http://127.0.0.1:11434/api/version
```

### 3. Modello del team

Dalla root del kit:

```bash
ollama pull flint:40b-a2b-qat-int4
ollama create team-flint -f ollama/Modelfile
ollama show team-flint
```

`ollama show` deve riportare `tools` tra le *Capabilities* e `num_ctx 16384` tra i parametri.

### 4. Profilo utente OpenCode

Copia `config/opencode-user.example.jsonc` come `opencode.jsonc` nella directory indicata dalla riga `config` di `opencode debug paths`. Su macOS e Linux:

```bash
mkdir -p ~/.config/opencode
cp -n config/opencode-user.example.jsonc ~/.config/opencode/opencode.jsonc
```

Se il file esiste già, aggiungi soltanto `"model": "ollama/team-flint:latest"` e `"update": "disable"`.

### 5. Podman e immagini di analisi

Su macOS e Windows avvia la macchina Podman (`podman machine init` soltanto se non esiste ancora):

```bash
podman machine start
podman info
```

Costruisci l'immagine della security review (COM-009), dalla root del kit:

```bash
podman build -t team-security-review:0.0.1 -f .opencode/skills/common/templates/Containerfile.security-review .opencode/skills/common/templates
```

Le immagini di SonarQube, ShellCheck, Hadolint e dei database di prova vengono scaricate al primo utilizzo; l'immagine Liquibase si costruisce in ogni progetto dal suo Containerfile (SQL-007).

### 6. Kit nel repository applicativo

```bash
scripts/install.sh ../mio-progetto
```

```powershell
.\scripts\install.ps1 ..\mio-progetto
```

Per i file già presenti nel progetto vedi [Installare il kit in un progetto](#installare-il-kit-in-un-progetto).

### 7. Avvio di OpenCode

Dal repository applicativo:

```bash
opencode models
opencode debug agents
opencode
```

- `opencode models` deve mostrare soltanto `ollama/team-flint:latest`.
- `opencode debug agents` deve mostrare `build` e i 9 subagent; alla prima esecuzione in una directory nuova può restituire `[]`: rilancialo.
- In OpenCode avvia il lavoro con `/feature <descrizione della feature>`: il primo passo chiede da quale branch partire.

## Contenuto

| Percorso | Contenuto | Installato nei progetti |
| --- | --- | --- |
| `AGENTS.md` | Regole del team | Sì |
| `opencode.jsonc` | Permessi e coordinatore `build` | Sì |
| `.opencode/agents/` | 9 subagent | Sì |
| `.opencode/commands/` | Comandi `/feature` e `/git-commit-conventional` | Sì |
| `.opencode/skills/` | Skill e standard | Sì |
| `config/`, `ollama/` | Profilo utente OpenCode, Modelfile e variabili del server Ollama | No |
| `scripts/` | Installazione del kit nei progetti e variabili del server Ollama | No |

### Agenti

Il primary agent `build` coordina e non modifica file: delega agli specialisti necessari.

| Agente | Ruolo |
| --- | --- |
| `architect-planner` | Piano, scope e rischi, in sola lettura |
| `backend-developer` | Java e Spring Boot: API, Service, persistence |
| `frontend-developer` | Interfaccia web Spring MVC + Thymeleaf |
| `database-developer` | SQL, stored routine, Liquibase e migration |
| `feature-tester` | Test ed evidenze |
| `code-quality-reviewer` | Review qualità, read-only |
| `code-security-reviewer` | Review sicurezza, read-only |
| `infra-developer` | Podman, Containerfile, Compose |
| `docs-writer` | README, OpenAPI, runbook, report |

### Comandi

`/feature <descrizione della feature>` avvia il workflow coordinato da `build`, per una funzionalità o una correzione. La descrizione dice che cosa realizzare o correggere, per esempio `/feature ricerca clienti per nome e codice fiscale` oppure `/feature correggi l'errore 500 sul salvataggio ordini, issue 142`:

1. **Branch**: chiede da quale branch partire (proposta: il trunk) e crea, dopo la tua conferma, `feature/<nome>` (nome ricavato dalla descrizione) oppure `fix/<issue>`.
2. **Piano** con `architect-planner` (comportamento atteso e criteri di accettazione), poi attende la tua conferma.
3. **Tracciamento**: dopo l'ok al piano crea il file `docs/requests/<branch>.md` con richiesta, comportamento, criteri, branch e issue.
4. **Implementazione** con i soli developer necessari: database, backend, frontend, infra.
5. **Test** con `feature-tester`.
6. **Review** di qualità (con SonarQube effimero in Podman) e sicurezza (Gitleaks, Semgrep, CycloneDX e Grype in container).
7. **Correzioni** dei `FAIL`, al massimo due cicli.
8. **Documentazione**: aggiorna stato ed esito del file di tracciamento e, se necessario, il resto della documentazione.
9. **Report** finale.
10. **Commit** sul branch di lavoro, file di tracciamento incluso, solo se lo confermi.

### Git

Strategia **trunk-based** (COM-002): `main`/`master` è il trunk e rappresenta la produzione; ogni funzionalità (`feature/<nome>`) o correzione (`fix/<issue>`) si sviluppa su un branch di breve durata che torna sul trunk con una pull request. Gli agenti non committano mai sul trunk e non eseguono push, merge o rebase.

`/git-commit-conventional [indicazioni]` crea un commit nel formato `git commit -m "<type>(<scope>): <description>"`: propone file e messaggio ed esegue soltanto dopo la tua conferma. È lo stesso passo usato da `/feature` al termine del lavoro. `--amend`, `--no-verify` e `git push` restano vietati.

### Skill

| Skill | Standard | Stato |
| --- | --- | --- |
| `springboot` | SB-001–SB-009 | Approvata |
| `plsql` | SQL-001–SQL-003A, SQL-005–SQL-007 | Approvata |
| `podman` | PD-001–PD-004 | Approvata |
| `common` | COM-001–COM-009 | Approvata |

COM-001 (quality gate) è sempre in contesto tramite `instructions` di `opencode.jsonc`.

## Installare il kit in un progetto

1. Esegui lo script indicando la directory del progetto. Copia i file assenti e lascia invariati quelli identici; i file già presenti nel progetto con contenuto diverso (per esempio un suo `AGENTS.md`) vengono segnalati come `[SALTATO]`.
2. Per ogni file saltato unisci a mano le differenze, oppure rilancia con `--force` (`-Force` su Windows): il file viene sostituito e la versione precedente salvata come `.bak-<data>`.
3. Verifica come nella fase 7 di [Avviare l'ambiente di sviluppo](#avviare-lambiente-di-sviluppo). Se `opencode models` è vuoto, l'alias `team-flint` non è stato creato; se compaiono modelli `opencode/...`, sono modelli cloud non ancora disattivati in `opencode.jsonc`.

Se il progetto ha già un `opencode.json`, unisci a mano i permessi.

Exit code dello script: `0` completato, `1` errore, `2` alcuni file saltati.

## Riferimenti

- OpenCode V2: <https://opencode.ai/v2/docs>
- Ollama Flint: <https://ollama.com/library/flint>
