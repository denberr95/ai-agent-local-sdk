# SQL-005 — Testing & Static Analysis

**Stato: approvato; politica bilanciata.**

- Test obbligatori per routine nuove o modificate.
- Copertura funzionale: happy path, input invalidi, record assenti, valori limite, errori, rollback, idempotenza, batch, concorrenza e audit quando applicabili.
- Oracle: utPLSQL e coverage linee almeno 80% quando misurabile.
- PostgreSQL: pgTAP; MySQL: integration test SQL o JUnit su database Podman effimero (senza Testcontainers).
- SQLFluff verifica stile e SQL supportato, ma non sostituisce compilazione ed esecuzione nativa.
- Ogni modifica persistente applica il ciclo SQL-007 su DB reale effimero Podman.
- Liquibase deve fallire su migration mancanti, checksum incoerenti, ordine errato, SQL fallito o rollback non conforme.
- Nessun dato di produzione non autorizzato nei test.
- Reportare versione DB, immagine, comandi, exit code, test, coverage, forward, rollback e re-apply.
- `FAIL` e `NOT_VERIFIED` richiedono correzione o decisione esplicita; nessun risultato inventato.
