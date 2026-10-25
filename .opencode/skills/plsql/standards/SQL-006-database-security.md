# SQL-006 — Database Security

**Stato: approvato; politica bilanciata.**

- Vietata concatenazione di input non attendibili in SQL dinamico; usare bind per valori. Per identificatori dinamici usare allow-list (oltre a escaping/validazione sintattica).
- Separare ruoli di deployment, runtime applicativo e batch; minimo privilegio; evitare account amministrativi in applicazione.
- Analizzare esplicitamente il contesto di esecuzione: Oracle `AUTHID`, PostgreSQL `SECURITY DEFINER` / `search_path`, MySQL `SQL SECURITY` / definer.
- Segreti vietati nei sorgenti, nei log e negli artefatti; usare gestione protetta dei secret. Dati sensibili ridotti, mascherati e cifrati in base alla policy.
- In test usare dati sintetici o approvati, account con privilegi minimi e autorizzazioni per risorsa/tenant.
- Controlli: review SQL injection/dynamic SQL, segreti (es. Gitleaks), pattern per dialetto verificati (es. Semgrep), privilegi nativi e test negativi.
- Finding `Critical`: bloccante, nessun bypass agentico. `High`: correzione o approvazione formale del responsabile autorizzato. `Medium`/`Low`: risk acceptance documentata. L'approvazione non trasforma `FAIL` in `PASS`.
