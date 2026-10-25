# COM-006 — Documentazione e ADR

> Stato: **approvato** il 25 ottobre 2026.

## Principi

- Documentare soltanto comportamenti implementati e verificati; niente promesse di compatibilità, benchmark o test non eseguiti.
- Lingua: italiano per documentazione di progetto, salvo diversa convenzione del repository; identificatori e nomi tecnici in inglese.
- La documentazione si aggiorna nella stessa modifica che la rende necessaria; OpenAPI insieme alle API (SB-004).
- Esempi di comandi per Linux/macOS e Windows quando differiscono.

## README del progetto

Sezioni minime:

1. scopo e contesto;
2. prerequisiti con versioni (JDK, build tool, Podman, DBMS);
3. avvio locale passo-passo, incluso l'ambiente Podman;
4. esecuzione dei test, inclusi test di migration su database effimero;
5. configurazione: variabili e profili, senza valori segreti;
6. struttura del repository e riferimenti alla documentazione di dettaglio.

## Architecture Decision Record

- Percorso: `docs/adr/NNNN-titolo-in-kebab-case.md`, numerazione progressiva a 4 cifre.
- Sezioni: Stato (`Proposto`, `Accettato`, `Sostituito da NNNN`, `Ritirato`), Contesto, Decisione, Alternative considerate, Conseguenze.
- Un ADR accettato non si riscrive: si sostituisce con un nuovo ADR.
- Serve un ADR per scelte difficili da invertire: framework, modello dati, strategia di migration, sicurezza, integrazioni, deviazioni dagli standard.

## Altri artefatti

| Artefatto | Riferimento |
|---|---|
| Contratto API | OpenAPI 3.1 versionato (SB-004) |
| Migration e routine | Script auto-descrittivi e documentazione routine (SQL-002, SQL-007) |
| Report di test, sicurezza, performance, deploy | Template delle skill `springboot`, `plsql`, `podman` |
| CHANGELOG | COM-002 |
| Tracciamento delle richieste | `docs/requests/<branch>.md` dal template `templates/request.md` (COM-002) |
| Runbook | Batch, rilascio, recovery e rollback quando previsti |
