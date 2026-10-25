# COM-008 — Verifica qualità con SonarQube in Podman

> Stato: **approvato** il 25 ottobre 2026. Comandi verificati con SonarQube Community Build 26.10 su Podman 6.1.4 (macOS arm64), Maven 3.9 e Java 25; Gradle e varianti PowerShell da verificare.

## Regole

- La verifica della qualità del codice è assegnata a `code-quality-reviewer` ed è eseguita a ogni review con un'analisi SonarQube su un'istanza **effimera avviata con Podman**.
- Nessun server SonarQube condiviso: l'istanza è locale, pubblicata solo su `127.0.0.1`, ha le label del task e viene rimossa al termine, anche in caso di errore (PD-004).
- Immagine `docker.io/library/sonarqube:community`: sempre l'**ultima Community Build disponibile**, aggiornata con `podman pull` prima di ogni analisi. È un'eccezione voluta alla regola delle versioni fissate: versione (da `/api/system/status`) e digest effettivi vanno nelle evidenze.
- Esito del quality gate: `OK` → `PASS`, `ERROR` → `FAIL`; analisi non eseguibile (Podman, immagine o build non disponibili) → `NOT_VERIFIED` (COM-001).
- Alla prima analisi il quality gate predefinito valuta solo il nuovo codice e può risultare `OK` senza condizioni: riportare **sempre** anche tutte le issue aperte, per la politica rigorosa sull'intero repository (SB-003).
- Gravità delle issue (campo `impacts`) mappata su COM-001: `BLOCKER` → Critical, `HIGH` → High, `MEDIUM` → Medium, `LOW` → Low, `INFO` → Info.
- SonarQube si aggiunge a Spotless, Checkstyle, SpotBugs, ArchUnit e JaCoCo (SB-003, SB-006), non li sostituisce. La coverage compare solo se la build produce il report JaCoCo XML.
- SonarQube Community Build non analizza PL/SQL: per il codice SQL restano SQLFluff e i controlli di SQL-005.
- L'analisi scrive soltanto in `target/` o `build/`: il reviewer non modifica sorgenti, configurazioni o test.
- Il token resta in una variabile d'ambiente della shell e non va scritto in file, log o report.

## Comandi

Segnaposto e label come in `references/commands.md` della skill `podman`; `<progetto>` è anche la `projectKey` SonarQube.

### 1. Avvio

```text
podman pull docker.io/library/sonarqube:community
podman image inspect --format '{{.Digest}}' docker.io/library/sonarqube:community
podman run -d --name <progetto>-<task>-sonar --label team.ephemeral=true --label team.task=<task> -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 127.0.0.1::9000 docker.io/library/sonarqube:community
podman port <progetto>-<task>-sonar 9000/tcp
```

`SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true` disattiva i controlli di sistema di Elasticsearch: ammesso solo per istanze locali di test.

### 2. Readiness e token

Le credenziali iniziali `admin/admin` si usano solo per generare il token su questa istanza locale ed effimera.

```bash
export SONAR_HOST_URL='http://127.0.0.1:<porta-host>'
for i in $(seq 1 60); do curl -fs "$SONAR_HOST_URL/api/system/status" | grep -q '"status":"UP"' && break; sleep 5; done; curl -fsS "$SONAR_HOST_URL/api/system/status"
export SONAR_TOKEN="$(curl -fsS -u admin:admin -X POST "$SONAR_HOST_URL/api/user_tokens/generate?name=<task>" | sed -E 's/.*"token":"([^"]+)".*/\1/')"
```

```powershell
$env:SONAR_HOST_URL = 'http://127.0.0.1:<porta-host>'
for ($i = 0; $i -lt 60; $i++) { try { if ((Invoke-RestMethod "$env:SONAR_HOST_URL/api/system/status").status -eq 'UP') { break } } catch { }; Start-Sleep -Seconds 5 }; Invoke-RestMethod "$env:SONAR_HOST_URL/api/system/status"
$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('admin:admin'))
$env:SONAR_TOKEN = (Invoke-RestMethod -Method Post -Uri "$env:SONAR_HOST_URL/api/user_tokens/generate?name=<task>" -Headers @{ Authorization = "Basic $basic" }).token
```

### 3. Analisi

Lo scanner legge `SONAR_HOST_URL` e `SONAR_TOKEN` dall'ambiente; con `sonar.qualitygate.wait=true` attende il quality gate ed esce con errore se non è superato.

Maven, senza modifiche al `pom.xml`:

```bash
./mvnw -B verify org.sonarsource.scanner.maven:sonar-maven-plugin:5.8.0.7211:sonar -Dsonar.projectKey=<progetto> -Dsonar.qualitygate.wait=true
```

```powershell
.\mvnw.cmd -B verify org.sonarsource.scanner.maven:sonar-maven-plugin:5.8.0.7211:sonar "-Dsonar.projectKey=<progetto>" "-Dsonar.qualitygate.wait=true"
```

In PowerShell gli argomenti `-D...` vanno tra virgolette, altrimenti vengono spezzati al punto.

Gradle: richiede il plugin `org.sonarqube` nel build; se assente, aggiungerlo è una modifica del build che richiede approvazione (SB-001). Con il plugin presente:

```bash
./gradlew sonar -Dsonar.projectKey=<progetto> -Dsonar.qualitygate.wait=true
```

### 4. Evidenze

```bash
curl -fsS -H "Authorization: Bearer $SONAR_TOKEN" "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=<progetto>"
curl -fsS -H "Authorization: Bearer $SONAR_TOKEN" "$SONAR_HOST_URL/api/measures/component?component=<progetto>&metricKeys=bugs,vulnerabilities,code_smells,security_hotspots,coverage,duplicated_lines_density"
curl -fsS -H "Authorization: Bearer $SONAR_TOKEN" "$SONAR_HOST_URL/api/issues/search?componentKeys=<progetto>&resolved=false&ps=500" > reports/sonar-issues.json
```

```powershell
$auth = @{ Authorization = "Bearer $env:SONAR_TOKEN" }
Invoke-RestMethod -Uri "$env:SONAR_HOST_URL/api/qualitygates/project_status?projectKey=<progetto>" -Headers $auth
Invoke-RestMethod -Uri "$env:SONAR_HOST_URL/api/measures/component?component=<progetto>&metricKeys=bugs,vulnerabilities,code_smells,security_hotspots,coverage,duplicated_lines_density" -Headers $auth
Invoke-RestMethod -Uri "$env:SONAR_HOST_URL/api/issues/search?componentKeys=<progetto>&resolved=false&ps=500" -Headers $auth | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 reports\sonar-issues.json
```

Riportare nel review report: versione e digest dell'immagine, comando ed exit code dello scanner, stato del quality gate, misure e issue aperte con gravità mappata.

### 5. Pulizia

Rimuove solo l'istanza SonarQube, non gli altri container del task (per esempio il database del tester):

```text
podman rm -f -v <progetto>-<task>-sonar
```

```bash
unset SONAR_TOKEN SONAR_HOST_URL
```

```powershell
Remove-Item Env:SONAR_TOKEN, Env:SONAR_HOST_URL
```
