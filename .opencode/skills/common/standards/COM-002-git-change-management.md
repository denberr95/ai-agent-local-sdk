# COM-002 — Git e change management

> Stato: **approvato** il 25 ottobre 2026.

## Strategia trunk-based

- `main` (o `master`, secondo il repository) è il trunk e rappresenta la **produzione**: sempre rilasciabile e protetto, nessun push diretto, solo merge da pull request approvata.
- Ogni feature o correzione si sviluppa su un branch di breve durata, che torna sul trunk con una pull request appena il lavoro è completo.
- Il branch si riallinea spesso con quello di partenza per ridurre i conflitti, in particolare sulla numerazione delle migration SQL-007.

## Branch

| Tipo | Formato | Esempio |
| --- | --- | --- |
| Funzionalità | `feature/<nome>` | `feature/customer-search` |
| Correzione | `fix/<issue>` | `fix/142` |

- `<nome>` in kebab-case minuscolo, breve e descrittivo; `<issue>` è il numero della issue del difetto.
- **All'avvio del workflow** di ogni feature o correzione si chiede all'utente da quale branch partire (proposta predefinita: il trunk) e si conferma il nome del nuovo branch. Solo dopo la conferma, con working tree pulito, si crea il branch: `git switch -c <branch> <branch-di-partenza>`.

## Tracciamento delle richieste

- Piattaforma Git: GitHub. Il numero in `fix/<issue>` è quello della issue GitHub; le issue non vengono create in automatico dagli agenti.
- Ogni feature o correzione ha un file di tracciamento versionato `docs/requests/<branch>.md`, con `/` del branch sostituito da `-` (es. `docs/requests/feature-ricerca-clienti.md`, `docs/requests/fix-142.md`), creato dal template `templates/request.md`.
- Il file si crea sul branch di lavoro subito dopo l'approvazione del piano: richiesta originale, comportamento atteso, criteri di accettazione, branch e issue.
- A fine lavoro si aggiornano stato ed esito (quality gate, evidenze, finding aperti, commit); il file entra nello stesso commit della modifica e fa da base per la descrizione della pull request.

## Commit

- Formato Conventional Commits su una riga: `git commit -m "<type>(<scope>): <description>"`.
- `type` ammessi: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `revert`.
- `scope` in kebab-case minuscolo; `description` all'imperativo, senza punto finale; intestazione entro 72 caratteri.
- Procedura e regole di dettaglio: comando `/git-commit-conventional`.
- Un commit contiene un cambiamento logico coerente e compilabile.
- Vietati nei commit: segreti, dump di database, log, artefatti di build e report generati.

## Pull request

- Piccole e focalizzate su un solo obiettivo.
- Descrizione: scopo, modifiche, impatti (API, database, configurazione, container), test eseguiti con stati COM-001, rischi e rollback.
- Almeno una review umana; per database, sicurezza o infrastruttura serve un referente del dominio.
- Merge solo con quality gate rispettati (COM-001) e finding Critical chiusi.

## Versioni

- Semantic Versioning `MAJOR.MINOR.PATCH`.
- Tag `vX.Y.Z` creati soltanto dal processo di rilascio.
- `CHANGELOG.md` aggiornato nella stessa PR delle modifiche rilevanti, sezione `Unreleased`.

## Agenti

- Letture consentite senza approvazione: `git status`, `git diff`, `git log`, `git show`, `git branch --show-current`, `git branch --list`.
- Gli agenti creano il branch di lavoro solo all'avvio del workflow, dopo la conferma dell'utente sul branch di partenza e sul nome.
- Gli agenti eseguono commit soltanto con `/git-commit-conventional`, dopo conferma esplicita dell'utente e mai sul trunk (`main`/`master`); mai `--amend` o `--no-verify`.
- Push, merge, tag, reset, clean e rebase restano azioni umane.
- Rispettare `.gitattributes`: LF per i sorgenti, CRLF soltanto per script Windows.
