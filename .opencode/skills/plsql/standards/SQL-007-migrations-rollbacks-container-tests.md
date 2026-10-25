# SQL-007 — Migration, rollback e test DB containerizzati

**Stato: approvato.** Applicazione obbligatoria per ogni modifica persistente a schema, routine o dati di riferimento.

## Numerazione

- ID progressivo univoco a quattro cifre e descrizione `snake_case`.
- Forward: `0001__create_customers.up.sql`.
- Rollback: `0001__create_customers.down.sql`.
- Ordine forward crescente, rollback decrescente.
- Non rinumerare o modificare migration già distribuite; creare una nuova migration correttiva.
- Ogni changeset Liquibase mantiene ID e autore stabili; i checksum devono restare coerenti.

## Liquibase Community

- Il changelog associa ogni `.up.sql` al relativo `.down.sql`.
- Liquibase viene eseguito separatamente dall'avvio Spring Boot.
- Liquibase si esegue **sempre** nel container costruito dal Containerfile del progetto (`db/liquibase/Containerfile`, template `templates/Containerfile.liquibase`) e **sempre** contro il database di prova effimero; mai CLI installata sulla workstation, mai database condivisi. Comandi in `references/tools.md`.
- Usare `validate`, `update`, `rollback-sql`, rollback per tag/count e nuova `update` secondo il workflow del progetto.
- Il rollback selettivo di un singolo changeset non va dato per scontato in Community: progettare baseline, tag e gruppi consecutivi.
- Per procedure/package Oracle configurare correttamente `splitStatements` ed eventuale delimitatore.

## Rollback

- Ogni modifica reversibile deve avere un rollback reale che ripristini lo stato precedente.
- La modifica di una routine deve ripristinare la definizione precedente.
- Per DROP, perdita di colonne o trasformazioni irreversibili creare `.rollback.md` con backup/snapshot, recovery, verifiche e approvazione; non creare un finto rollback.
- In Oracle e MySQL molte DDL producono commit impliciti: un rollback di transazione non annulla la migration.

## Ciclo obbligatorio con Podman

1. Avviare il DBMS/versione di destinazione in un container effimero e isolato.
2. Fissare immagine/tag o digest; usare dati sintetici e credenziali non versionate.
3. Applicare la baseline e tutte le migration forward in ordine.
4. Compilare oggetti ed eseguire test funzionali, unitari e di integrazione.
5. Eseguire il rollback delle modifiche del ciclo su ambiente effimero autorizzato.
6. Confrontare schema e dati con lo stato atteso.
7. Riapplicare le migration e ripetere i test.
8. Rimuovere soltanto le risorse create per il task.

## Quality gate

`PASS` richiede forward, test, rollback, verifica e re-apply superati. Usare `FAIL` per errore verificato e `NOT_VERIFIED` quando mancano Podman, immagine compatibile, client DB, permessi o evidenze. L'approvazione di un'eccezione non cambia lo stato tecnico.
