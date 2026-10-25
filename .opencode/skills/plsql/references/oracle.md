# Oracle Database / PL/SQL

- Confermare VERSION, schema, privilegi, charset e supporto dell'immagine container per CPU host.
- Routine: package specification/body, procedure, function, trigger; `CREATE OR REPLACE` compatibile con versione. Mantenere in rollback la **precedente definizione** dell'oggetto.
- Errori: `EXCEPTION`, `RAISE`, `RAISE_APPLICATION_ERROR`, `SQLCODE`, `DBMS_UTILITY`. Transazioni ordinarie controllate dal chiamante.
- Performance: `DBMS_XPLAN.DISPLAY_CURSOR`, `EXPLAIN PLAN`; `BULK COLLECT`/`FORALL` e `MERGE` se appropriati. Tool avanzati soltanto con licenze e privilegi validi.
- Test: utPLSQL; line coverage >=80% quando misurabile; SQLFluff solo se sintassi supportata.
- Sicurezza: `AUTHID`, grant minimi, bind in `EXECUTE IMMEDIATE`, `DBMS_ASSERT` per alcuni identificatori.
- **DDL Oracle implica COMMIT**: testare undo compensativo su database effimero, non affidarsi a transazione ROLLBACK.
- Container possibile: Oracle Database Free dal registry Oracle; verificare accettazione termini, piattaforma, risorse e versione prima dell'uso (ARM64 non va presunto).
