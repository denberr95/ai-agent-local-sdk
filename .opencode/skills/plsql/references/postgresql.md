# PostgreSQL / PL/pgSQL

- Verificare versione DB, schema/search_path e livello privilegi.
- Routine `CREATE FUNCTION/PROCEDURE`, linguaggio PL/pgSQL; transazioni nella procedura solo secondo vincoli di CALL e contesti supportati.
- Error handling: `EXCEPTION`, `SQLSTATE`, `GET STACKED DIAGNOSTICS`, `RAISE`.
- Performance: `EXPLAIN`, `EXPLAIN (ANALYZE, BUFFERS)`, `pg_stat_statements` se disponibile; attenzione: ANALYZE esegue realmente la query.
- Test: pgTAP o test SQL nativi; per coverage procedurale usare tool validati se presenti, altrimenti report funzionale.
- Sicurezza: SQL dinamico `EXECUTE ... USING` per valori; `format('%I', ...)` con allow-list per identificatori; `SECURITY DEFINER` richiede hardening search_path e grant.
- Migration: eseguire nel DB effimero Podman e verificare il rollback compensativo e il ri-apply; molte DDL sono transazionali, ma non assumere atomicita' universale.
