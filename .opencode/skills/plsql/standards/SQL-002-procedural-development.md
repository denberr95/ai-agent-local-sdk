# SQL-002 — Procedural Development

**Stato: approvato, politica bilanciata.**

- Procedure: una responsabilita' principale, validazione degli input, parametri tipizzati, modularita', preferenza per operazioni set-based. Naming `pr_<action>_<entity>`.
- Function: principalmente calcolo/lettura; evitare side effect e scritture, con eccezioni documentate, lecite sul DB e testate. Naming `fn_<action>_<entity>`.
- Package Oracle: approccio package-first per API di dominio; specification minimale, body con implementazione e routine private. Routine standalone ammesse quando appropriate.
- PostgreSQL e MySQL: niente package Oracle; organizzazione con schema e routine coerenti.
- Trigger: preferire vincoli nativi; usare trigger per audit o necessita' tecniche; business logic complessa soltanto se motivata, testata e osservabile.
- Evitare codice duplicato, loop riga-per-riga senza motivo, commit nascosti e handler che sopprimono errori.
- Documentare precondizioni, parametri, output, side effect, performance, sicurezza e interfaccia transazionale.
- Ogni nuova routine o modifica a routine esistente e' distribuita tramite migration SQL-007 numerata con strategia di ripristino della definizione precedente.
