# PD-004 — Sicurezza e cleanup

- Vietati `--privileged`, capability non necessarie e mount host ampi.
- Non montare socket Podman/Docker dentro codice non attendibile.
- Preferire filesystem read-only con mount espliciti quando compatibile.
- Usare Podman secrets o meccanismi equivalenti.
- Non stampare secret nei log.
- Vietato `podman system prune` tramite agenti.
- `podman volume rm` e rimozioni distruttive richiedono conferma e scope verificato.
- Non intervenire su container non creati dal workflow corrente.
