---
name: PL/SQL and Database Development
description: Progetta, modifica, revisiona e testa SQL e stored routine per Oracle Database, PostgreSQL e MySQL. Applica SQL-001–SQL-003A e SQL-005–SQL-007, Liquibase in container, script numerati con rollback e verifiche su database reali in Podman.
---

# SQL e programmazione procedurale

## Perimetro

Usa questa skill per schema SQL, migration, procedure, function, package, trigger, query, troubleshooting e review su Oracle, PostgreSQL e MySQL. Non chiamare genericamente PL/SQL i linguaggi procedurali PostgreSQL e MySQL.

## Workflow obbligatorio

1. Rileva DBMS, versione, schema, convenzioni, changelog Liquibase e comandi di test disponibili.
2. Leggi lo standard pertinente in `standards/`; per modifiche persistenti leggi sempre SQL-007.
3. Leggi una sola reference specifica: `references/oracle.md`, `references/postgresql.md` oppure `references/mysql.md`.
4. Prepara migration numerata `.up.sql` e `.down.sql`; per modifiche non reversibili documenta recovery e approvazione.
5. Non modificare migration già distribuite: crea una nuova change correttiva.
6. Esegui Liquibase soltanto nel container costruito dal Containerfile del progetto e contro il database di prova effimero; usa i client SQL del container del database (`references/tools.md`).
7. Per il quality gate database usa un'istanza reale effimera Podman: forward, test, rollback, verifica, re-apply e retest.
8. Se manca un prerequisito, usa `NOT_VERIFIED`; non simulare il risultato.
9. Non eseguire DDL/DML o rollback distruttivi su ambienti condivisi senza approvazione esplicita.
10. Non esporre segreti, non inventare output e non accettare rischi per conto dell'utente.

## Standard

- `standards/SQL-001-naming-formatting.md`
- `standards/SQL-002-procedural-development.md`
- `standards/SQL-003-error-logging-transactions.md`
- `standards/SQL-003A-audit-logging.md`
- `standards/SQL-005-testing-quality.md`
- `standards/SQL-006-database-security.md`
- `standards/SQL-007-migrations-rollbacks-container-tests.md`

## Output

Usa i template in `templates/` e riporta sempre DBMS/versione, file modificati, comandi realmente eseguiti, test, evidenze, stato dei quality gate e approvazioni necessarie.
