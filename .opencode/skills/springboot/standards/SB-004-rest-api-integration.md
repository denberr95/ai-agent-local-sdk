# SB-004 — REST API & Integration

## REST design

- Risorse con sostantivi plurali, lowercase e kebab-case.
- JSON con proprietà camelCase.
- Semantica corretta di GET, POST, PUT, PATCH, DELETE.
- Paginazione per collezioni potenzialmente grandi.
- Sorting tramite allow-list.
- Timestamp ISO 8601 con offset/timezone.
- Breaking change solo con nuova versione o piano approvato.

## Versioning

Standard: header HTTP **`API-Version`**.

- Documentare l'header in OpenAPI.
- Rifiutare versioni non supportate con errore coerente.
- Includere l'header nelle regole di cache/gateway dove applicabile.
- Non aggiungere la versione nel path salvo progetto esistente.

## OpenAPI

- OpenAPI 3.1 come baseline.
- Specifica versionata nel repository.
- Documentare request, response, errori, header `API-Version` e sicurezza.
- Verificare coerenza fra contratto e comportamento reale.
- Analizzare breaking change.

## Validation

- Jakarta Bean Validation sui request DTO.
- Gestire sia errori di body sia di parametri/metodi.
- Le regole di business restano nel Service.

## Errori

- RFC 9457 Problem Details.
- `@RestControllerAdvice` centralizzato.
- Campi consigliati: type, title, status, detail sicuro, instance, errorCode, correlationId.
- Vietati stack trace, query SQL, token o dettagli interni nelle risposte.

## Client HTTP

- RestClient predefinito per MVC.
- WebClient soltanto per esigenze reactive coerenti.
- Timeout di connessione/lettura obbligatori.
- Retry solo per operazioni idempotenti o rese tali.
- Backoff limitato e documentato.
- Correlation ID propagato nell'header `X-Correlation-Id` (COM-005) e W3C Trace Context propagati.
- WireMock o equivalente per test dei client esterni.

## Quality gate

OpenAPI valido, contratti e validation testati, error handling standard, nessuna breaking change non approvata, timeout configurati e test di integrazione pertinenti.
