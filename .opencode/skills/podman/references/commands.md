# Comandi Podman

Comandi da eseguire per ambienti locali e test. Verificati su Podman 6.1.4 (macOS, `podman machine` libkrun, arm64) con PostgreSQL 18, MySQL 8.4 e Oracle Database Free 23.26.3.0; le varianti PowerShell sono da verificare su Windows.

## Convenzioni

| Segnaposto | Significato | Esempio |
| --- | --- | --- |
| `<progetto>` | Nome del repository in kebab-case | `shop` |
| `<task>` | Feature o ticket in kebab-case | `customer-search` |
| `<nome>` | `<progetto>-<task>-<servizio>` | `shop-customer-search-db` |
| `<versione>` | Tag fissato dell'immagine, mai `latest` | `18` |
| `<porta-host>` | Porta restituita da `podman port` | `44943` |

- Ogni risorsa creata ha le label `team.ephemeral=true` e `team.task=<task>`: la pulizia agisce solo su quelle.
- I comandi su una riga valgono sia in Bash (Linux, macOS) sia in PowerShell (Windows); dove la sintassi cambia sono riportate entrambe le versioni.
- Le porte sono pubblicate solo su `127.0.0.1` e con porta host scelta da Podman, per evitare collisioni.

## 1. Ambiente

```text
podman --version
podman info --format '{{.Host.OS}}/{{.Host.Arch}} rootless={{.Host.Security.Rootless}}'
podman machine list
podman compose version
```

- `podman machine list` serve solo su macOS e Windows: la macchina deve risultare `Currently running`.
- Su macOS e Windows `podman info` descrive la VM: l'architettura mostrata è quella che le immagini devono supportare.

## 2. Immagine

```text
podman pull <immagine>:<versione>
podman image inspect --format '{{.Os}}/{{.Architecture}} {{.Digest}}' <immagine>:<versione>
```

Se l'architettura dell'immagine è diversa da quella di `podman info`, lo stato è `NOT_VERIFIED` (PD-003). Il digest va riportato nelle evidenze.

## 3. Password di test

La password viene generata per ogni ciclo, passata al container come Podman secret (anche a Liquibase) e lasciata nella shell per collegare i test. Non va scritta in file versionati né nei log.

```bash
export DB_PASSWORD="$(openssl rand -hex 16)"
podman secret create --env <nome>-pwd DB_PASSWORD
```

```powershell
$env:DB_PASSWORD = [guid]::NewGuid().ToString('N')
podman secret create --env <nome>-pwd DB_PASSWORD
```

## 4. Database effimero

**PostgreSQL** (porta 5432, utente e database `app`):

```text
podman run -d --name <nome> --label team.ephemeral=true --label team.task=<task> --secret <nome>-pwd,type=env,target=POSTGRES_PASSWORD -e POSTGRES_USER=app -e POSTGRES_DB=app -p 127.0.0.1::5432 --health-cmd 'pg_isready -h 127.0.0.1 -U app -d app' --health-interval 5s --health-retries 24 docker.io/library/postgres:<versione>
```

**MySQL** (porta 3306, utente e database `app`; la stessa password vale per `root` e `app`):

```text
podman run -d --name <nome> --label team.ephemeral=true --label team.task=<task> --secret <nome>-pwd,type=env,target=MYSQL_ROOT_PASSWORD --secret <nome>-pwd,type=env,target=MYSQL_PASSWORD -e MYSQL_USER=app -e MYSQL_DATABASE=app -p 127.0.0.1::3306 --health-cmd 'mysqladmin ping -h 127.0.0.1 --silent' --health-interval 5s --health-retries 36 docker.io/library/mysql:<versione>
```

**Oracle Database Free** (porta 1521, servizio `FREEPDB1`, utente `system` solo nel database effimero; versione d'esempio `23.26.3.0`, immagine di circa 9,5 GB, disponibile per amd64 e arm64). Prima dell'uso verificare termini di licenza e architettura (references/oracle.md della skill `plsql`):

```text
podman run -d --name <nome> --label team.ephemeral=true --label team.task=<task> --secret <nome>-pwd,type=env,target=ORACLE_PWD -p 127.0.0.1::1521 container-registry.oracle.com/database/free:<versione>
```

Quando il database serve anche a Liquibase, aggiungere `--network <progetto>-<task>-net` al `podman run`: Liquibase gira in container sulla rete del task e raggiunge il database per nome (`references/tools.md` della skill `plsql`).

## 5. Readiness

**PostgreSQL e MySQL**: esegue l'healthcheck finché risulta superato (massimo 5 minuti). `podman healthcheck run` funziona anche dove Podman non pianifica gli healthcheck in automatico.

```bash
for i in $(seq 1 60); do podman healthcheck run <nome> >/dev/null 2>&1 && break; sleep 5; done; podman healthcheck run <nome>
```

```powershell
for ($i = 0; $i -lt 60; $i++) { podman healthcheck run <nome> *> $null; if ($LASTEXITCODE -eq 0) { break }; Start-Sleep -Seconds 5 }; podman healthcheck run <nome>
```

**Oracle**: attende il messaggio dell'immagine ufficiale (massimo 10 minuti).

```bash
for i in $(seq 1 120); do podman logs <nome> 2>&1 | grep -q 'DATABASE IS READY TO USE' && break; sleep 5; done; podman logs <nome> 2>&1 | grep 'DATABASE IS READY TO USE'
```

```powershell
for ($i = 0; $i -lt 120; $i++) { if ((podman logs <nome> 2>&1) -match 'DATABASE IS READY TO USE') { break }; Start-Sleep -Seconds 5 }; (podman logs <nome> 2>&1) -match 'DATABASE IS READY TO USE'
```

Se la readiness non arriva entro il limite: salvare i log (punto 8), pulire (punto 9) e riportare `FAIL` o `NOT_VERIFIED`.

## 6. Connessione

```text
podman port <nome> 5432/tcp
```

Usare la porta del DBMS (5432, 3306 o 1521); il comando restituisce `127.0.0.1:<porta-host>`.

| DBMS | JDBC URL | Utente |
| --- | --- | --- |
| PostgreSQL | `jdbc:postgresql://127.0.0.1:<porta-host>/app` | `app` |
| MySQL | `jdbc:mysql://127.0.0.1:<porta-host>/app` | `app` |
| Oracle | `jdbc:oracle:thin:@//127.0.0.1:<porta-host>/FREEPDB1` | `system` |

**Integration test Spring Boot** (SB-006): la connessione arriva dalle variabili d'ambiente, senza profili o file con credenziali.

```bash
export SPRING_DATASOURCE_URL='jdbc:postgresql://127.0.0.1:<porta-host>/app' SPRING_DATASOURCE_USERNAME=app SPRING_DATASOURCE_PASSWORD="$DB_PASSWORD"
./mvnw verify
```

```powershell
$env:SPRING_DATASOURCE_URL = 'jdbc:postgresql://127.0.0.1:<porta-host>/app'; $env:SPRING_DATASOURCE_USERNAME = 'app'; $env:SPRING_DATASOURCE_PASSWORD = $env:DB_PASSWORD
.\mvnw.cmd verify
```

Con Gradle: `./gradlew check` (`.\gradlew.bat check`). **Liquibase** non si collega dalla workstation: gira in container sulla rete del task (`references/tools.md` della skill `plsql`).

## 7. Client SQL nel container

Nessun client da installare sulla workstation: si usa quello dell'immagine.

```text
podman exec <nome> psql -U app -d app -v ON_ERROR_STOP=1 -c 'select 1'
podman exec <nome> sh -c 'echo select 1 | mysql -uapp -p$MYSQL_PASSWORD app'
podman exec <nome> sh -c 'echo select 1 from dual\; | sqlplus -s system/$ORACLE_PWD@localhost/FREEPDB1'
```

Le righe sono, nell'ordine, PostgreSQL, MySQL e Oracle. La password è letta dentro il container dalla variabile del secret, quindi non compare sulla riga di comando della workstation. I comandi non contengono doppi apici, che Windows PowerShell 5.1 non passa correttamente ai programmi esterni. Il client MySQL stampa l'avviso `Using a password on the command line interface can be insecure`: è atteso, perché la password resta comunque dentro il container.

Per eseguire uno script SQL della workstation (esempio PostgreSQL):

```bash
podman exec -i <nome> psql -U app -d app -v ON_ERROR_STOP=1 < db/tests/test_customers.sql
```

```powershell
Get-Content -Raw db\tests\test_customers.sql | podman exec -i <nome> psql -U app -d app -v ON_ERROR_STOP=1
```

## 8. Evidenze

```text
podman ps -a --filter label=team.task=<task> --format '{{.Names}} {{.Image}} {{.Status}}'
podman image inspect --format '{{.Digest}}' <immagine>:<versione>
```

```bash
podman logs <nome> > reports/<nome>.log 2>&1
```

```powershell
podman logs <nome> 2>&1 | Out-File -Encoding utf8 reports\<nome>.log
```

Riportare i risultati nel template `templates/container-test-report.md`.

## 9. Pulizia

Sempre, anche quando test o readiness falliscono:

```text
podman rm -f -v --filter label=team.task=<task>
podman secret rm <nome>-pwd
```

Mai `podman system prune`, né rimozioni di container, volumi o immagini senza la label del task.

## 10. Immagine applicativa

```text
podman build --format docker -t <progetto>:<versione> -f Containerfile .
podman run -d --name <progetto>-<task>-app --label team.ephemeral=true --label team.task=<task> -p 127.0.0.1::8080 --read-only --tmpfs /tmp --cap-drop=ALL --security-opt no-new-privileges <progetto>:<versione>
podman port <progetto>-<task>-app 8080/tcp
curl -fsS http://127.0.0.1:<porta-host>/actuator/health/readiness
```

- `--format docker` conserva l'istruzione `HEALTHCHECK` del Containerfile, che il formato OCI predefinito ignora.
- Su Windows usare `curl.exe`: in Windows PowerShell 5.1 `curl` è un alias di `Invoke-WebRequest`.

## 11. Compose

```text
podman compose -p <progetto>-<task> -f compose.yaml up -d --wait
podman compose -p <progetto>-<task> ps
podman compose -p <progetto>-<task> logs
podman compose -p <progetto>-<task> down -v
```

- `--wait` attende gli healthcheck dei servizi; è supportato dal provider `docker-compose`, non da tutti i provider.
- `down -v` elimina anche i volumi del progetto Compose: usarlo solo per progetti di test e con conferma (PD-004).

## 12. Analisi statica dei Containerfile

Hadolint con l'immagine fissata `docker.io/hadolint/hadolint:v2.15.1`, senza installazione locale (PD-001). Dalla root del repository, indicando i file da analizzare:

```bash
podman run --rm -v "$PWD:/mnt:ro,Z" -w /mnt docker.io/hadolint/hadolint:v2.15.1 hadolint -f gnu Containerfile
```

```powershell
podman run --rm -v "${PWD}:/mnt:ro,Z" -w /mnt docker.io/hadolint/hadolint:v2.15.1 hadolint -f gnu Containerfile
```

Tutti i Containerfile e Dockerfile del repository:

```bash
podman run --rm -v "$PWD:/mnt:ro,Z" -w /mnt docker.io/hadolint/hadolint:v2.15.1 hadolint -f gnu $(find . \( -name 'Containerfile*' -o -name 'Dockerfile*' \) -not -path './.git/*')
```

```powershell
podman run --rm -v "${PWD}:/mnt:ro,Z" -w /mnt docker.io/hadolint/hadolint:v2.15.1 hadolint -f gnu ((Get-ChildItem -Recurse -File -Include Containerfile*, Dockerfile* | Resolve-Path -Relative) -replace '\\', '/')
```

- Gate: exit code `0` → `PASS`; qualsiasi finding → `FAIL` finché non è corretto; Podman o immagine non disponibili → `NOT_VERIFIED`.
- Eccezioni solo con commento `# hadolint ignore=DLxxxx` sulla riga precedente l'istruzione e motivazione nello stesso commento; mai `--ignore` globali.
- Gravità per il report (COM-001): `error` → High, `warning` → Medium, `info` e `style` → Low.
- L'output `-f gnu` riporta `hadolint:file:riga: codice livello: messaggio`, da trascrivere nei finding secondo COM-004.
