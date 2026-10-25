# SB-005 — Persistence & Transactions

## Strategia di accesso dati

- Spring Data JPA per CRUD orientato alle Entity.
- JdbcClient per SQL esplicito e query controllate.
- SimpleJdbcCall per stored procedure/function.
- HikariCP come pool predefinito.
- Query parametrizzate obbligatorie.
- `ddl-auto=validate` o `none`; niente update/create automatico dello schema.

## Transazioni

- Confine ordinario nel Service con `@Transactional`.
- `readOnly=true` quando pertinente.
- Controller senza gestione transazionale.
- Verificare rollback delle checked exception quando richiesto.
- Verificare condivisione della transazione fra JPA, JDBC e procedure.
- Nessuna presunzione di propagazione su thread async.
- Stored procedure rispettano SQL-003; batch autonomi soltanto documentati e approvati.

## Migration

Standard: **Liquibase Community eseguito separatamente da Spring Boot in tutti gli ambienti**.

- Script SQL-007 numerati `.up.sql`/`.down.sql`.
- Changelog YAML/XML/JSON associa forward e rollback.
- ID/autore stabili; migration distribuite immutabili.
- Spring Boot non esegue Liquibase allo startup.
- Liquibase si esegue sempre nel container costruito dal Containerfile del progetto, contro il database di prova effimero (SQL-007; comandi in `references/tools.md` della skill `plsql`).
- Privilegi di deployment separati dall'utente applicativo.

## Ciclo di test

Su DB reale effimero Podman:

1. readiness;
2. Liquibase validate/update;
3. test JPA/JDBC/procedure/transazioni;
4. rollback per tag/count previsto;
5. verifica schema/dati;
6. re-apply;
7. retest;
8. cleanup delle sole risorse del task.

`PASS` solo con evidenze complete. Operazioni irreversibili richiedono recovery plan e approvazione.
