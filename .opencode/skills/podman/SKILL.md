---
name: Podman Local Environments
description: "Crea e verifica Containerfile, compose.yaml, database effimeri, healthcheck e ambienti locali con Podman."
---

# Podman Local Environments

## Regole minime

1. Rileva sistema operativo, architettura, `podman machine`, provider Compose e versione Podman.
2. Usa immagini versionate e approvate; evita `latest` nei workflow riproducibili.
3. Crea container e volumi con nomi/label riconducibili al progetto e al task.
4. Usa utente non-root, privilegi minimi, healthcheck e secret esterni.
5. Non usare `--privileged`, socket host indiscriminato o `podman system prune`.
6. Elimina soltanto le risorse create dal task corrente.
7. Per database test usa dati sintetici, readiness e volumi effimeri.
8. Per Spring Boot applica anche SB-008; per migration applica SQL-007/SB-005.
9. Se l'ambiente non è verificabile, usa `NOT_VERIFIED`.
10. Non usare Testcontainers: database e servizi di test si avviano con i comandi Podman espliciti.

Leggi i documenti in `standards/` e la reference specifica del sistema operativo. I comandi da eseguire (ambiente, database effimeri PostgreSQL/MySQL/Oracle, readiness, connessione, evidenze, pulizia, immagini, Compose) sono in `references/commands.md`.
