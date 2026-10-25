# SB-002 — Project Architecture

## Architettura

Standard: **Package by Layer**.

```text
com.company.application
├── controller
├── service
├── repository
│   ├── jpa
│   ├── jdbc
│   └── procedure
├── entity
├── dto
│   ├── request
│   └── response
├── mapper
├── model
├── integration
├── config
└── exception
```

Creare soltanto i package necessari.

## Responsabilità

| Layer | Responsabilità |
|---|---|
| Controller | HTTP, validation, request/response mapping |
| Service | Business logic, orchestrazione, transazioni |
| Repository/DAO | Accesso JPA/JDBC |
| Procedure Gateway | SimpleJdbcCall e contratto stored procedure |
| Entity | Persistenza JPA; suffisso `Entity` |
| DTO | Contratti API; separati dalle Entity |
| Mapper | Trasformazione, non business logic né query |
| Integration | Client e adapter esterni |
| Config | Configurazione infrastrutturale senza segreti |

## Naming

- Package: lowercase senza underscore.
- Classi/interfacce: PascalCase; niente prefisso `I`.
- Metodi/variabili: camelCase.
- Costanti: UPPER_SNAKE_CASE.
- Entity: `<Entity>Entity`, es. `CustomerEntity`.
- Request: `<Action><Entity>Request`.
- Response: `<Entity>Response`.
- Service: `<Entity>Service`.
- JPA repository: `<Entity>Repository`.
- JDBC: `<Entity>JdbcRepository`.
- Stored procedure: `<Entity>ProcedureGateway`.
- Test unitari: `*Test`; integrazione: `*IT`.

## DTO ed Entity

- Preferire Java Record per DTO immutabili.
- Request e response distinti.
- Bean Validation sui request DTO.
- Entity JPA non esposte nelle API e non usate come input HTTP.
- Non usare Record per Entity JPA.
- Evitare Lombok `@Data` sulle Entity.
- Gestire consapevolmente lazy loading, equals/hashCode e N+1.

## Dipendenze

- Controller → Service: consentita.
- Controller → Repository/Entity: vietata.
- Service → Repository/Gateway/Integration: consentita.
- Repository → Service/Controller: vietata.
- Mapper → Repository: vietata.
- Dipendenze circolari: vietate.
- Constructor injection e campi `final` per le dipendenze.
- Vietati field injection e service locator ordinario.

ArchUnit verifica le regole sull'intero repository.
