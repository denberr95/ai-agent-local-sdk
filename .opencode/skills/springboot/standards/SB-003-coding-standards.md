# SB-003 — Coding Standards

## Formattazione

- Spotless con Google Java Format stile **AOSP**, 4 spazi.
- UTF-8, LF, import espliciti, niente wildcard.
- Le parentesi graffe sono obbligatorie.
- Spotless è l'autorità sulla formattazione; Checkstyle non deve confliggere.

## Clean Code

- Una responsabilità chiara per metodo e classe.
- Preferire early return a nesting eccessivo.
- Evitare magic numbers, classi generiche `Manager`, `Helper`, `Utils` senza dominio.
- Non introdurre interfacce o pattern senza bisogno concreto.
- Commenti per decisioni e vincoli, non per ripetere il codice.
- `Optional` soprattutto come return type; collezioni vuote invece di `null` quando corretto.
- DTO e dipendenze immutabili quando possibile.
- Bean singleton senza stato mutabile per richiesta.

## Eccezioni

- Eccezioni business specifiche.
- Preservare la causa delle eccezioni tecniche.
- Evitare `catch (Exception)` salvo confine con comportamento definito.
- Vietato ignorare eccezioni.
- Un solo punto di logging per lo stesso errore.
- Traduzione HTTP centralizzata con `@RestControllerAdvice` e Problem Details.

## Spring best practice

- Constructor injection.
- `@ConfigurationProperties` per configurazioni strutturate.
- `@Transactional` nel Service quando appropriato.
- Controller senza SQL o logica transazionale.
- Timeout obbligatori per integrazioni esterne.
- Async e parallelismo solo se richiesti e testati.
- Verificare self-invocation e rollback delle checked exception.

## Analisi statica

| Tool | Gate |
|---|---|
| Spotless | Nessuna violazione |
| Checkstyle | Naming, import, struttura; nessuna violazione bloccante |
| SpotBugs | Nessun finding confermato rank 1–9 non risolto/approvato |
| ArchUnit | Nessuna violazione architetturale |

Soglie iniziali Checkstyle:

- complessità ciclomatica >10: warning/review;
- parametri >6: warning/review;
- metodo >80 righe: warning/review;
- import wildcard: fail;
- nuove violazioni naming: fail.

Politica rigorosa sull'intero repository, inclusi problemi preesistenti. Gli agenti non abbassano soglie né aggiungono suppression per far passare il build.
