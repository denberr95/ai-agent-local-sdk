# Observability

Log JSON, correlation ID applicativo, traceId/spanId OpenTelemetry, metriche Micrometer e OTLP. Collector/backend configurabili. Actuator health/liveness/readiness protetti. Nessun identificativo ad alta cardinalità nelle metriche.

Correlation ID (COM-005): un `OncePerRequestFilter` legge `X-Correlation-Id` (solo UUID, altrimenti ne genera uno), lo mette nell'MDC come `correlationId`, lo restituisce nell'header della risposta e pulisce l'MDC a fine richiesta; un interceptor dei client HTTP (es. `ClientHttpRequestInterceptor` per `RestClient`) lo invia nelle chiamate in uscita.
