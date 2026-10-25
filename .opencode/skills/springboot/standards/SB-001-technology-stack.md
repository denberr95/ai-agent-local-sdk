# SB-001 — Technology Stack

## Baseline nuovi progetti

- Spring Boot **4.1.x**.
- Java **25 LTS**.
- Maven e Gradle supportati alla pari.
- Maven Wrapper o Gradle Wrapper obbligatorio e versionato.
- Dependency management tramite BOM Spring Boot.
- Spring MVC predefinito; WebFlux opzionale e giustificato.

## Progetti esistenti

Rilevare e rispettare versioni, build tool, dipendenze e convenzioni. Non eseguire upgrade automatici di Java, Spring Boot, plugin, driver o librerie.

## Dipendenze approvate

| Ambito | Scelta |
|---|---|
| REST | Spring MVC |
| Reactive | Spring WebFlux solo se necessario |
| Validation | Jakarta Bean Validation |
| JSON | Jackson gestito da Spring Boot |
| ORM | Spring Data JPA/Hibernate quando appropriato |
| SQL esplicito | Spring JDBC/JdbcClient |
| Stored procedure | SimpleJdbcCall |
| Connection pool | HikariCP |
| Mapping | MapStruct opzionale |
| Boilerplate | Lombok non predefinito; rispettare progetti che già lo usano |
| API docs | springdoc-openapi compatibile |
| Logging | SLF4J + Logback |
| Monitoring | Spring Boot Actuator |
| Test | JUnit Jupiter, Mockito, AssertJ; database di test in Podman, senza Testcontainers |
| Security | Spring Security quando necessario |

## Regole build

- Nessuna versione dinamica o SNAPSHOT nei nuovi progetti senza approvazione.
- Nessuna versione individuale per dipendenze gestite dal BOM, salvo eccezione documentata.
- Build riproducibile su macOS, Windows e Linux.
- Test unitari e integrazione inclusi nel ciclo di build.
- Driver Oracle/PostgreSQL/MySQL compatibili con il target e con Java 25.
- Dipendenze non necessarie non vanno aggiunte.
