---
description: Sviluppa una feature o una correzione coordinando branch, piano, implementazione, test, review e documentazione
agent: build
---

Sviluppa la feature o la correzione descritta di seguito:

$ARGUMENTS

Segui il workflow in ordine. Delega soltanto agli agenti necessari, uno alla volta, assegnando a ciascuno obiettivo, file autorizzati e output atteso.

1. **Branch** — prima di ogni altra attività ricava dalla descrizione se si tratta di una funzionalità o di una correzione e fattelo confermare dall'utente, insieme al branch da cui partire (proposta predefinita: il trunk `main`/`master`, che rappresenta la produzione). Proponi il nome secondo COM-002: `feature/<nome>`, con un nome breve in kebab-case ricavato dalla descrizione, oppure `fix/<issue>`, chiedendo il numero della issue se la descrizione non lo riporta. Dopo la conferma, con working tree pulito (`git status`), crea il branch con `git switch -c <branch> <branch-di-partenza>`. Senza conferma non procedere.
2. **Piano** — `architect-planner` ricava requisiti e contesto dalla richiesta e dal repository e produce scope, comportamento atteso, criteri di accettazione, file per agente, skill, test, quality gate e rischi. Se i requisiti non sono ricavabili, fai domande all'utente. Mostra il piano e attendi conferma prima di modificare file.
3. **Tracciamento** — subito dopo l'approvazione del piano, senza altre domande, `docs-writer` crea `docs/requests/<branch>.md` (con `/` sostituito da `-`) dal template `templates/request.md` della skill `common`, riportando richiesta originale, comportamento atteso, criteri di accettazione, branch e issue (COM-002).
4. **Implementazione** — in quest'ordine, solo se pertinenti:
   - `database-developer`: SQL, stored routine, migration;
   - `backend-developer`: Java e Spring Boot (API, Service, persistence);
   - `frontend-developer`: interfaccia Thymeleaf;
   - `infra-developer`: Podman, Containerfile, Compose.
5. **Test** — `feature-tester` esegue i test pertinenti; per il database applica forward, rollback e re-apply su database effimero.
6. **Review** — `code-quality-reviewer` (con analisi SonarQube in Podman, COM-008) e `code-security-reviewer` (con i controlli di sicurezza in container, COM-009), in sola lettura.
7. **Correzioni** — rimanda ogni `FAIL` al developer competente; al massimo due cicli per la stessa causa, poi chiedi all'utente.
8. **Documentazione** — `docs-writer` aggiorna sempre stato ed esito in `docs/requests/<branch>.md`; aggiorna API, configurazione o README solo se cambiano.
9. **Report** — restituisci il risultato finale previsto da AGENTS.md, indicando il branch di lavoro, quello di partenza e il file di tracciamento.
10. **Commit** — chiedi all'utente se vuole committare. Solo dopo conferma esplicita leggi ed esegui la procedura di `.opencode/commands/git-commit-conventional.md`, sul branch di lavoro e includendo il file di tracciamento.
