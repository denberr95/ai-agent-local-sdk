# SB-006 — Testing & Quality

## Tool

- JUnit Jupiter.
- Mockito e AssertJ.
- Spring Boot Test.
- Database e servizi reali in container Podman effimeri, avviati con i comandi della skill `podman` (`references/commands.md`); gli integration test leggono la connessione da `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`. Testcontainers non si usa.
- JaCoCo.
- ArchUnit.
- WireMock quando sono presenti integrazioni HTTP.

## Tipi di test

- Unit test per Service, mapper e logica applicativa.
- Controller test per validation, `API-Version`, HTTP e Problem Details.
- Repository/DAO test su database reale.
- Stored procedure e transazioni.
- Integration test end-to-end pertinenti.
- Architecture test ArchUnit.
- Migration test SQL-007/Liquibase.
- Regression test per bug e contratti esistenti.

## Soglie JaCoCo

| Metrica | Soglia |
|---|---|
| Line coverage complessiva | >= 80% |
| Branch coverage complessiva | >= 70% |
| Line coverage nuovo codice | >= 90% |
| Branch coverage nuovo codice | >= 80% |
| Scenari critici applicabili | 100% |
| Test falliti ammessi | 0 |

Le esclusioni sono limitate al codice realmente generato o non significativo e devono essere documentate.

## Naming

- `*Test`: unit/slice test.
- `*IT`: integration test.
- `*ArchitectureTest`: ArchUnit.
- Maven: Surefire + Failsafe.
- Gradle: task `test` e `integrationTest` equivalenti.

## Quality gate

Politica rigorosa sull'intero repository. Gli agenti non saltano test, non abbassano coverage e non disabilitano regole. Se Podman o un prerequisito manca, stato `NOT_VERIFIED`.
