# Toolchain e comandi operativi

| Ambito | Strumenti |
| --- | --- |
| Migration | Liquibase in container, costruito dal Containerfile del progetto (`docker.io/liquibase/liquibase`, driver JDBC aggiunti con `lpm`) |
| Container | Podman e, se disponibile, `podman compose` con provider configurato |
| Oracle | Immagine autorizzata, SQLcl/SQL*Plus, utPLSQL, DBMS_XPLAN |
| PostgreSQL | Immagine versionata, `psql`, pgTAP, `EXPLAIN`, `pg_stat_statements` |
| MySQL | Immagine versionata, MySQL CLI, `EXPLAIN ANALYZE`, Performance Schema |
| Lint | SQLFluff per dialetto e sintassi supportata |
| Security | Gitleaks, Semgrep compatibile, ispezione dei privilegi e test negativi |

## Liquibase in container

Liquibase si esegue **soltanto** nel container costruito dal Containerfile del progetto e **soltanto** contro il database di prova effimero. Mai una CLI installata sulla workstation, mai database condivisi.

Comandi verificati con Liquibase 5.0.4 e PostgreSQL 18 su Podman 6.1.4 (macOS); MySQL, Oracle e le varianti PowerShell sono da verificare.

### Struttura nel progetto

```text
db/
├── changelog/
│   ├── db.changelog-master.yaml        da templates/db.changelog-master.yaml
│   └── migrations/
│       ├── 0001__create_customers.up.sql
│       └── 0001__create_customers.down.sql
└── liquibase/
    └── Containerfile                   da templates/Containerfile.liquibase
```

Nel Containerfile impostare il driver del DBMS di destinazione: `postgresql`, `mysql` oppure `oracle-ojdbc11`.

### Comandi

Segnaposto e label come in `references/commands.md` della skill `podman`; `<nome>` è il container del database.

1. Rete del task, poi database di prova avviato con i comandi della skill `podman` aggiungendo `--network <progetto>-<task>-net`:

   ```text
   podman network create --label team.ephemeral=true --label team.task=<task> <progetto>-<task>-net
   ```

2. Immagine Liquibase con changelog e driver, dalla root del progetto:

   ```text
   podman build -t <progetto>-liquibase:<task> --label team.ephemeral=true --label team.task=<task> -f db/liquibase/Containerfile .
   ```

3. Esecuzione di un comando Liquibase (`<comando>`: `validate`, `update`, `rollback-count --count=<n>`, `status`, `history`); la password arriva dal Podman secret del database:

   ```text
   podman run --rm --network <progetto>-<task>-net --label team.ephemeral=true --label team.task=<task> --secret <nome>-pwd,type=env,target=LIQUIBASE_COMMAND_PASSWORD -e LIQUIBASE_COMMAND_URL=jdbc:postgresql://<nome>:5432/app -e LIQUIBASE_COMMAND_USERNAME=app -e LIQUIBASE_COMMAND_CHANGELOG_FILE=db.changelog-master.yaml -e LIQUIBASE_SEARCH_PATH=/liquibase/changelog <progetto>-liquibase:<task> <comando>
   ```

   | DBMS | `LIQUIBASE_COMMAND_URL` | Utente |
   | --- | --- | --- |
   | PostgreSQL | `jdbc:postgresql://<nome>:5432/app` | `app` |
   | MySQL | `jdbc:mysql://<nome>:3306/app` | `app` |
   | Oracle | `jdbc:oracle:thin:@//<nome>:1521/FREEPDB1` | `system` |

4. Pulizia, oltre a quella della skill `podman`:

   ```text
   podman network rm <progetto>-<task>-net
   podman rmi <progetto>-liquibase:<task>
   ```

### Ciclo SQL-007

1. `validate`;
2. `update` (forward);
3. compilazione delle routine e test;
4. `rollback-count --count=<n>` con `<n>` pari ai changeset del ciclo;
5. verifica di schema e dati con il client nel container del database (es. `podman exec <nome> psql -U app -d app -c '\dt'`);
6. `update` (re-apply) e nuova esecuzione dei test;
7. pulizia delle sole risorse del task.

Liquibase esce con codice diverso da zero se un comando fallisce: in quel caso il controllo è `FAIL`. Ricostruire l'immagine a ogni modifica del changelog o delle migration.

## Convenzione migration

- `0001__descrizione.up.sql`
- `0001__descrizione.down.sql`
- `0001__descrizione.rollback.md` quando il rollback SQL non è tecnicamente sicuro.

Il changelog Liquibase associa ogni changeset ai file forward e rollback. Non usare `runAlways` o `runOnChange` per migration versionate senza motivazione e approvazione.
