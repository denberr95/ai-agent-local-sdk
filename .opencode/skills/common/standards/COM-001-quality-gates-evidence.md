# COM-001 — Quality gate ed evidenze

> Stato: **approvato**; Severità ed Evidenze minime approvate il 25 ottobre 2026. Questo file è caricato sempre tramite `instructions` in `opencode.jsonc`.

## Stati

| Stato | Significato |
|---|---|
| PASS | Controllo eseguito e superato |
| WARNING | Rischio non bloccante documentato |
| FAIL | Controllo eseguito e non superato |
| NOT_VERIFIED | Controllo richiesto senza evidenze sufficienti |
| NOT_APPLICABLE | Controllo non pertinente con motivazione |

## Regole

- Nessun test fallito può essere dichiarato superato.
- Una vulnerabilità Critical è bloccante.
- Una vulnerabilità High richiede correzione o approvazione formale.
- Medium e Low richiedono correzione o risk acceptance documentata.
- Le eccezioni non cambiano lo stato tecnico del controllo.
- Per il codice Spring Boot applicare le soglie JaCoCo definite in SB-006.
- Per migration SQL applicare forward, rollback e re-apply definiti in SQL-007.
- Se l'ambiente necessario non è disponibile, usare `NOT_VERIFIED`.

## Severità

| Livello | Significato |
|---|---|
| Critical | Vulnerabilità sfruttabile, perdita o corruzione dati, rottura in produzione |
| High | Bug funzionale probabile, regressione, violazione di uno standard obbligatorio |
| Medium | Robustezza o manutenibilità compromesse |
| Low | Stile, naming, miglioramenti minori |
| Info | Osservazione senza azione richiesta |

La stessa scala vale per finding di qualità e di sicurezza; il gate per livello è quello delle **Regole**.

## Evidenze minime

Per ogni controllo eseguito riportare:

- comando esatto e directory di esecuzione;
- exit code e durata;
- versioni rilevanti: JDK, Maven/Gradle, DBMS, immagine con tag e digest, versione dello scanner e delle sue regole;
- conteggi: test eseguiti, falliti, saltati; coverage misurata;
- percorso dei report completi ed estratto significativo del log.

Regole aggiuntive:

- Un esito ottenuto su una versione precedente del codice non vale per la nuova iterazione: rieseguire.
- Le evidenze non contengono segreti, token o dati personali.
- Una valutazione dell'LLM non sostituisce l'esecuzione di test, scanner o analyzer: senza esecuzione lo stato è `NOT_VERIFIED`.
