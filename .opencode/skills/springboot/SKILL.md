---
name: Spring Boot Development
description: "Progetta, implementa, revisiona e testa applicazioni Spring Boot secondo SB-001–SB-009: Java 25, Package by Layer, API REST, frontend Thymeleaf, persistence ibrida, Liquibase, quality gate, security, observability e Podman."
---

# Spring Boot Development

## Workflow

1. Rileva versione Spring Boot, Java, Maven/Gradle, architettura, database e strumenti esistenti.
2. Per nuovi progetti applica Spring Boot 4.1.x e Java 25; per progetti esistenti non eseguire upgrade automatici.
3. Leggi soltanto gli standard pertinenti in `standards/` e i reference necessari.
4. Applica Package by Layer, constructor injection e separazione DTO/Entity.
5. Usa Spring MVC come default e WebFlux soltanto quando giustificato.
6. Usa JPA per CRUD, JdbcClient per SQL esplicito e SimpleJdbcCall per stored procedure.
7. Per modifiche database carica anche `plsql` e applica SQL-007/Liquibase.
8. Esegui controlli e test realmente disponibili; usa `NOT_VERIFIED` quando mancano evidenze.
9. Non modificare dipendenze, security, migration o contratti pubblici fuori ambito.
10. Non dichiarare PASS se test, scan, migration o healthcheck non sono stati eseguiti.

## Standard

- `standards/SB-001-technology-stack.md`
- `standards/SB-002-project-architecture.md`
- `standards/SB-003-coding-standards.md`
- `standards/SB-004-rest-api-integration.md`
- `standards/SB-005-persistence-transactions.md`
- `standards/SB-006-testing-quality.md`
- `standards/SB-007-security.md`
- `standards/SB-008-observability-containers.md`
- `standards/SB-009-thymeleaf-frontend.md` (interfacce web server-side con Thymeleaf)

## Output

Usa i template in `templates/` e riporta stack rilevato, file modificati, test, coverage, scan, migration, quality gate, finding aperti e approvazioni necessarie.
