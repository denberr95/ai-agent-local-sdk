# PD-002 — Compose locale

- Usare `compose.yaml` compatibile con il provider Podman configurato.
- Nomi, network e volumi scoped al progetto.
- Porte host configurabili per evitare collisioni.
- Dipendenze governate da health/readiness, non soltanto dall'ordine di avvio.
- Secret e credenziali di test fuori da Git.
- Nessun container privileged.
- Non assumere che macOS/Windows e Linux abbiano lo stesso networking.
