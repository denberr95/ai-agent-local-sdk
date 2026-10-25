# SB-007 — Security

## Autenticazione

- Identity Provider esterno OAuth2/OIDC.
- Nuove API protette come JWT Resource Server Spring Security.
- Verificare firma, issuer, audience, exp, nbf e algoritmi consentiti.
- JWKS e rotazione chiavi quando supportati.
- Non usare ID token per autorizzare API.

## Autorizzazione

- Deny by default.
- Sicurezza HTTP e method security.
- Scope/permessi specifici, non ruoli eccessivamente generici.
- Verifica per risorsa e tenant.
- Non fidarsi di userId/tenantId ricevuti nel body senza confronto con l'identità autenticata.
- Distinguere 401 e 403.

## Segreti e dati

- Nessun secret, token, chiave o password nel repository, nei log o nelle immagini.
- Configurazione tramite secret manager, Podman secrets o meccanismo approvato.
- TLS quando richiesto.
- Actuator e CORS minimizzati e protetti.
- Dati sintetici nei test.

## SAST, SCA e supply chain

| Tool | Obbligo |
|---|---|
| Semgrep | SAST con ruleset validato |
| Gitleaks | Secret scanning |
| CycloneDX | SBOM JSON |
| Grype | Vulnerabilità delle dipendenze, dallo SBOM |
| SpotBugs | Difetti tecnici complementari |

Scanner o regole non disponibili => `NOT_VERIFIED`.

Esecuzione: Semgrep, Gitleaks, CycloneDX e Grype girano nel container costruito da `templates/Containerfile.security-review` della skill `common`, con i comandi di COM-009.

## Test

Token mancante/scaduto/non valido, issuer/audience errati, scope insufficiente, accesso a risorse altrui, cross-tenant, input malevoli, CORS/CSRF pertinente e nessuna esposizione di segreti.

## Gate

- Critical: blocco e correzione obbligatoria.
- High: correzione o approvazione formale.
- Medium/Low: correzione o risk acceptance documentata.
- L'approvazione non trasforma `FAIL` in `PASS`.
