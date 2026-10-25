# COM-005 — Logging, errori e correlation ID

> Stato: **approvato** il 25 ottobre 2026. Dettagli di stack: SB-008 (Spring Boot), SQL-003 e SQL-003A (database).

## Livelli di log

| Livello | Uso |
|---|---|
| ERROR | Operazione fallita che richiede attenzione; una sola volta per errore |
| WARN | Anomalia gestita o degrado del servizio |
| INFO | Eventi di business e ciclo di vita significativi, a basso volume |
| DEBUG | Diagnostica, disattivata di default fuori dagli ambienti locali |
| TRACE | Solo locale e temporaneo |

## Regole

- Log strutturati JSON negli ambienti condivisi; campi e formato Spring Boot secondo SB-008.
- Vietati nei log: password, token, JWT, chiavi, cookie di sessione, dati personali non mascherati, payload sensibili.
- Un errore viene loggato una sola volta, nel punto in cui viene gestito; altrove si propaga con contesto.
- Audit separato dal logging diagnostico (SQL-003A, SB-008).

## Correlation ID

| Contesto | Nome |
|---|---|
| Header HTTP in ingresso, in uscita e nella risposta | `X-Correlation-Id` |
| Campo log JSON e Problem Details | `correlationId` (SB-004, SB-008) |
| Parametro stored procedure | `p_correlation_id` (SQL-003) |

- **Ingresso**: ogni richiesta HTTP legge `X-Correlation-Id`; se manca o non è un UUID valido viene generato un nuovo UUID. Valori non UUID non si accettano né si scrivono nei log, per evitare log injection (COM-003).
- **Esecuzione**: il valore resta nel contesto della richiesta (MDC in Spring Boot) e compare in ogni log come `correlationId`.
- **Uscita**: ogni chiamata HTTP verso altri servizi invia `X-Correlation-Id` con lo stesso valore; ogni chiamata al database lo passa come `p_correlation_id`.
- **Risposta**: ogni risposta HTTP restituisce l'header `X-Correlation-Id`; le risposte di errore lo riportano anche nel campo `correlationId` del Problem Details.
- **Batch**: ogni esecuzione genera il proprio correlation ID.
- Il correlation ID convive con W3C Trace Context (`traceId`, `spanId`) e non lo sostituisce.
- Il correlation ID non è mai usato come tag di metrica (alta cardinalità, SB-008).

## Errori

- Distinguere errori attesi (validazione, regole di business, risorsa assente) da errori imprevisti (bug, infrastruttura).
- Codici di errore applicativi stabili e documentati, formato proposto `<DOMINIO>-<NNNN>` (es. `ORD-0001`), esposti come `errorCode`.
- Messaggi verso l'utente comprensibili e senza dettagli interni; i dettagli tecnici restano nei log, collegati dal correlation ID.
- Nessun blocco catch vuoto; le eccezioni tecniche conservano la causa.
