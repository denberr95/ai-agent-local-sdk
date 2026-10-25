---
description: Crea un commit Conventional Commits (git commit -m "<type>(<scope>): <description>") solo dopo conferma esplicita dell'utente
agent: build
---

Prepara il commit del lavoro corrente. Indicazioni dell'utente (opzionali): $ARGUMENTS

## Formato

Un solo comando, con intestazione su una riga:

```text
git commit -m "<type>(<scope>): <description>"
```

| Elemento | Regola |
| --- | --- |
| `type` | `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `revert` |
| `scope` | Componente o modulo interessato, minuscolo in kebab-case (es. `customer-api`, `db`, `ui`) |
| `description` | All'imperativo, iniziale minuscola, senza punto finale, nella lingua usata in `git log`; senza `"`, `` ` ``, `$` o `\` |
| Lunghezza | Intestazione completa entro 72 caratteri |

Esempio: `git commit -m "feat(customer-api): add customer search endpoint"`

## Procedura

1. Verifica il branch corrente con `git branch --show-current`: se è il trunk (`main`/`master`, la produzione) fermati e chiedi all'utente di scegliere o creare un branch `feature/<nome>` o `fix/<issue>` (COM-002).
2. Esegui `git status` e `git diff` per individuare le modifiche del lavoro corrente.
3. Seleziona soltanto i file modificati dal lavoro corrente; escludi segreti (`.env`, chiavi), file `.bak-*`, report e artefatti di build.
4. Un commit per cambiamento logico: se le modifiche sono eterogenee, proponi più commit.
5. Mostra all'utente branch, file da includere, comando esatto e stato dei quality gate (`FAIL` o `NOT_VERIFIED` vanno segnalati). Chiedi conferma esplicita: senza conferma non eseguire nulla.
6. Dopo la conferma esegui `git add` sui soli file elencati e poi il `git commit -m` confermato, senza modificarlo.
7. Mostra l'esito con `git log -1 --oneline`.

Vietati: `git add -A`, `git add .`, `--amend`, `--no-verify`, `git push`.
