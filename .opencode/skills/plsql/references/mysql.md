# MySQL / Stored Programs

- Verificare versione, engine tabelle, `sql_mode`, charset e privilegio account.
- Routine procedure, function, trigger. Error handling: `DECLARE HANDLER`, `SIGNAL`, `RESIGNAL`, `GET DIAGNOSTICS`.
- Performance: `EXPLAIN`, `EXPLAIN ANALYZE` quando supportato, Performance Schema, metriche tempi e lock.
- Testing: SQL integration test su DB MySQL effimero in Podman, oppure integration test JUnit di Spring Boot sullo stesso database, con scenari funzionali completi. Comandi nella skill `podman` (`references/commands.md`).
- SQL dinamico: `PREPARE`/`EXECUTE` con valori bind dove supportati, allow-list identificatori; account `SQL SECURITY` e `DEFINER` controllati.
- Molte istruzioni DDL causano COMMIT implicito e non sono annullate da `ROLLBACK`; trattare `.down.sql` come migration compensativa testata.
- I client SQL devono interrompersi al primo errore; test sempre su DB Podman isolato.
