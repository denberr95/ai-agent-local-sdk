# COM-004 — Code review e analisi statica

> Stato: **approvato** il 25 ottobre 2026. Per Java valgono SB-003 e SB-006; per SQL SQL-001 e SQL-005.

## Perimetro

- Politica rigorosa sull'intero repository, come SB-003: le violazioni preesistenti non correlate al task vanno segnalate e si chiede come estendere l'ambito.
- La review copre codice, test, configurazioni, migration, Containerfile, Compose, script e documentazione modificati.

## Formato dei finding

Ogni finding riporta:

- severità secondo COM-001;
- file e posizione;
- regola o standard violato (es. `SB-002`, `SQL-006`, `COM-007`);
- fonte: `tool` (con nome) oppure `review AI`;
- impatto;
- correzione suggerita.

Ordinare i finding per severità. Separare i finding di qualità da quelli di sicurezza evitando duplicati.

## Analisi statica per tecnologia

| Ambito | Strumento | Standard |
|---|---|---|
| Qualità del codice (tutti gli stack supportati) | SonarQube effimero in Podman, obbligatorio | COM-008 |
| Java | Spotless, Checkstyle, SpotBugs, ArchUnit, JaCoCo | SB-003, SB-006 |
| SQL | SQLFluff, compilazione nativa | SQL-005 |
| Containerfile | Hadolint in Podman (`docker.io/hadolint/hadolint:v2.15.1`), obbligatorio | PD-001 |
| Compose | `podman compose config` o validazione del provider | PD-002 |
| Shell | ShellCheck in Podman (`docker.io/koalaman/shellcheck:v0.11.0`), obbligatorio | COM-007 |
| PowerShell | PSScriptAnalyzer | COM-007 |
| YAML / Markdown | yamllint, markdownlint se configurati | COM-006 |

- Usare soltanto gli analyzer già configurati o approvati; non installarne di nuovi senza autorizzazione.
- Non modificare soglie, regole o suppression per far passare il gate.
- Analyzer non eseguito: `NOT_VERIFIED` con la causa.

## Clean code trasversale

- Una responsabilità per unità di codice; nomi espliciti in inglese per gli identificatori.
- Nessun codice morto, commentato o duplicato senza motivo; nessun TODO senza ticket.
- Commenti per decisioni e vincoli, non per ripetere il codice.
- Errori gestiti esplicitamente, mai ignorati (COM-005).
- Refactoring non richiesto separato dalla modifica funzionale.

## Template

- Java/Spring Boot: template della skill `springboot`.
- Database: template della skill `plsql`.
- Altri artefatti: `templates/review-report.md`.
