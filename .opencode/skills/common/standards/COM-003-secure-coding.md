# COM-003 — Secure coding trasversale

> Stato: **approvato** il 25 ottobre 2026. Regole specifiche: SB-007 (Spring Boot), SQL-006 (database), PD-004 (Podman).

## Riferimenti

- OWASP Top 10 e OWASP ASVS livello 2 come baseline.
- CWE Top 25 per la classificazione dei finding.

## Analisi

- Prima di classificare i finding definire asset, superfici di attacco, attori e confini di fiducia.
- Distinguere finding osservati con scenario riproducibile, ipotesi da verificare e scanner non eseguiti (`NOT_VERIFIED`).

## Regole

- **Input**: validazione lato server di ogni input esterno con tipo, lunghezza, formato e allow-list; la validazione client è solo usabilità.
- **Injection**: mai concatenare input in SQL, JPQL, comandi shell, espressioni SpEL o template; usare parametri e bind variable.
- **Output**: encoding contestuale per HTML, attributi, JavaScript e URL; in Thymeleaf vedi SB-009.
- **Autorizzazione**: deny by default, verifica per risorsa e tenant, minimo privilegio per utenti, servizi e account database.
- **Segreti**: mai in sorgenti, configurazioni versionate, immagini, log, ticket, report o prompt; usare secret manager o Podman secrets.
- **File `.env`**: soltanto locali e ignorati da Git; versionare `.env.example` con valori fittizi.
- **Crittografia**: algoritmi e librerie standard; password con hash adattivo; niente crittografia custom.
- **Errori**: nessuno stack trace o dettaglio interno verso l'utente (COM-005).
- **Supply chain**: dipendenze e immagini da sorgenti approvate, versioni fissate, SBOM e scanner secondo SB-007, eseguiti in container con i comandi di COM-009.
- **Script**: nessun `curl | sh` non ispezionato, nessuna disattivazione di verifiche TLS o firme (COM-007).

## Limiti per gli agenti

- Nessun test invasivo, fuzzing, scansione di rete o exploit senza autorizzazione esplicita e ambiente dedicato.
- Non leggere segreti per verificarli: segnalarne presenza, percorso e tipo, mai il valore.
- Non abbassare severità e non aggiungere soppressioni senza motivazione e approvazione.

## Gate

Applicare le regole di COM-001: Critical bloccante, High con correzione o approvazione formale, Medium/Low con correzione o risk acceptance documentata.
