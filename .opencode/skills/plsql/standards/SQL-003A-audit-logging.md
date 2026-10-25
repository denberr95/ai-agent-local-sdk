# SQL-003A — Audit Logging

**Stato: approvato.** Audit separato da logging diagnostico.

- Eventi prioritari: autenticazioni e accessi negati (nei componenti competenti); ruoli e privilegi; modifiche a dati critici; accesso a dati sensibili per classificazione; batch critici; DDL e modifiche di sicurezza.
- Non registrare ogni SELECT/CRUD ordinaria senza requisito esplicito.
- Schema comune logico: `event_id`, timestamp UTC, `event_type`, `actor_type`, `source_system`, `operation_name`, `outcome`, `correlation_id`; quando pertinenti `actor_id`, `resource_type`, `resource_id`, `trace_id`, `error_code`, metadata validati.
- Audit append-only, accessi separati, deduplicazione, accesso ristretto, integrita' verificabile, niente password o payload sensibili.
- Modifiche confermate: audit coerente con il commit, ad esempio transactional outbox; tentativi falliti: canale indipendente capace di sopravvivere al rollback. La sola outbox non copre gli errori annullati.
- Retention **configurabile e documentata per progetto**; baseline indicativa 30 giorni log applicativi, 90 giorni log batch, 365 giorni audit; regole legali e organizzative prevalgono.
- Automatizzare scadenza, conservazione, eccezioni e controllo accessi; registrare il `correlation_id` e la sorgente dell'evento.
