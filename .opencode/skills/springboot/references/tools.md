# Comandi di riferimento

## Maven

```bash
./mvnw spotless:check
./mvnw checkstyle:check
./mvnw spotbugs:check
./mvnw verify
```

## Gradle

```bash
./gradlew spotlessCheck
./gradlew checkstyleMain
./gradlew spotbugsMain
./gradlew check
```

## Liquibase

Sempre nel container costruito dal Containerfile del progetto, contro il database di prova effimero: comandi e ciclo in `references/tools.md` della skill `plsql` (SQL-007, SB-005).

I comandi di build possono variare per progetto; rilevarli prima di eseguire.
