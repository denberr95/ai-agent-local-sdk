# COM-009 — Security review con container Podman

> Stato: **approvato** il 25 ottobre 2026. Comandi verificati su Podman 6.1.4 (macOS arm64) con un progetto Maven; Gradle e varianti PowerShell da verificare.
>
> Alternative gratuite e senza chiave API valutate per le dipendenze: Trivy e OSV-Scanner. Scelto Grype perché analizza direttamente lo SBOM CycloneDX e ha una soglia di gravità (`--fail-on`) allineata al quality gate.

## Regole

- A ogni review `code-security-reviewer` esegue Gitleaks (segreti), Semgrep (SAST), CycloneDX (SBOM) e Grype (vulnerabilità delle dipendenze, dallo SBOM) con l'immagine costruita da `templates/Containerfile.security-review`. Nessuno strumento richiede chiavi API.
- Nessuno strumento installato sulla workstation: il progetto si monta nel container in `/src`.
- Versioni fissate: Gitleaks 8.30.1, Semgrep 1.182.1 con le regole `p/owasp-top-ten` e `p/java` incluse in build (analisi senza rete), Grype 0.116.0, Maven 3.9.16, JDK 25, plugin CycloneDX 2.9.3.
- Nel container gli strumenti girano come root: con Podman rootless corrisponde all'utente della workstation e serve a Maven per scrivere in `target/`. Eccezione a PD-001 approvata dal team il 25 ottobre 2026, ammessa solo per questa immagine di strumenti.
- Report in `reports/security/` del progetto, da non versionare; Gitleaks oscura i segreti (`--redact`).
- Cache condivise fra i progetti, da non rimuovere nella pulizia del task: volume `team-security-m2` (cache Maven) e volume `team-security-grype` (database delle vulnerabilità di Grype, circa 3,4 GB, scaricato al primo avvio e aggiornato automaticamente).
- CycloneDX è un comando Maven: per i progetti Gradle serve il plugin nel build, la cui aggiunta richiede approvazione (SB-001); senza SBOM, anche Grype è `NOT_VERIFIED`.

## Esito e gravità

| Controllo | `PASS` | `WARNING` | `FAIL` | Gravità (COM-001) |
| --- | --- | --- | --- | --- |
| Gitleaks | Nessun segreto | — | Almeno un segreto | Critical |
| Semgrep | Nessun finding | Solo finding `WARNING`/`INFO` | Almeno un finding `ERROR` | `ERROR` → High, `WARNING` → Medium, `INFO` → Low |
| CycloneDX | `bom.json` prodotto | — | Errore di generazione | — |
| Grype | Nessuna vulnerabilità | Solo `Medium`/`Low`/`Negligible` | Almeno una `High` o `Critical` (exit code 2) | `Critical` → Critical, `High` → High, `Medium` → Medium, `Low`/`Negligible` → Low |

- Un errore dello strumento (non un finding) è `NOT_VERIFIED`.
- Eccezioni solo motivate e approvate (SB-007): `.gitleaksignore` con il fingerprint del finding, `// nosemgrep: <regola>` sulla riga, file `.grype.yaml` con la vulnerabilità ignorata e la motivazione. Un'eccezione non cambia lo stato tecnico (COM-001).

## Comandi

Dalla root del progetto. In PowerShell sostituire `$PWD` con `${PWD}`.

**1. Immagine**, una volta per versione del kit (anche per aggiornare le regole Semgrep):

```text
podman build -t team-security-review:0.0.1 -f .opencode/skills/common/templates/Containerfile.security-review .opencode/skills/common/templates
```

**2. Gitleaks**:

```bash
podman run --rm -v "$PWD:/src:Z" -w /src team-security-review:0.0.1 gitleaks dir . --redact --report-format json --report-path reports/security/gitleaks.json
```

**3. Semgrep**:

```bash
podman run --rm -v "$PWD:/src:Z" -w /src team-security-review:0.0.1 semgrep scan --config /opt/semgrep-rules --metrics=off --error --json --output reports/security/semgrep.json
```

**4. CycloneDX**, SBOM in `reports/security/bom.json`:

```bash
podman run --rm -v "$PWD:/src:Z" -v team-security-m2:/root/.m2 -w /src team-security-review:0.0.1 mvn -B -q org.cyclonedx:cyclonedx-maven-plugin:2.9.3:makeAggregateBom -DoutputFormat=json -DoutputDirectory=reports/security
```

**5. Grype**, sulle dipendenze elencate nello SBOM del passo 4; esce con codice 2 se trova vulnerabilità `High` o `Critical`. Il primo avvio scarica il database (circa 90 secondi), i successivi durano pochi secondi:

```bash
podman run --rm -v "$PWD:/src:Z" -v team-security-grype:/root/.cache/grype -w /src team-security-review:0.0.1 grype sbom:reports/security/bom.json --fail-on high -o json --file reports/security/grype.json
```

Riportare nel review report, per ogni controllo: comando, exit code, numero di finding per gravità e percorso del report.
