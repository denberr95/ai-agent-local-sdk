# SB-008 — Observability & Containers

## Logging

- SLF4J + Logback.
- JSON su stdout/stderr.
- Campi minimi: timestamp UTC, level, service, environment, logger, message, correlationId, traceId, spanId, errorCode quando pertinente.
- Nessun JWT, password, secret o payload sensibile.
- Audit separato dal logging diagnostico.

## Tracing e metriche

- Micrometer Tracing + OpenTelemetry.
- Propagazione W3C Trace Context.
- Export OTLP; collector e backend configurabili.
- Micrometer per HTTP, JVM, pool DB, integrazioni e metriche business.
- Evitare tag ad alta cardinalità come userId o correlationId.

## Actuator

- Health, liveness e readiness obbligatori nei servizi containerizzati.
- Liveness non dipende da servizi esterni condivisi.
- Endpoint sensibili non pubblici.
- Prometheus opzionale; vendor-neutral come standard.

## Container Podman

- Containerfile OCI, immagine base approvata e versionata.
- Build multi-stage o artefatto verificato.
- Utente non-root e privilegi minimi.
- Niente `--privileged`.
- Filesystem read-only quando compatibile.
- Secret esterni all'immagine.
- Solo porte necessarie.
- Healthcheck e graceful shutdown.
- Compatibilità amd64/arm64 quando richiesta.

## Deploy

1. quality gate;
2. build JAR e immagine;
3. scan e SBOM;
4. Liquibase esterno;
5. deploy applicazione;
6. readiness, smoke test, security e metriche;
7. report.

Per evoluzioni schema valutare expand-and-contract. Il rollback applicativo non implica rollback automatico del database.
