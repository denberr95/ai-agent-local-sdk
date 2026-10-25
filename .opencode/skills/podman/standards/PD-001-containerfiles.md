# PD-001 — Containerfile

- Sintassi OCI/Containerfile.
- Immagine base versionata e approvata.
- Multi-stage build quando utile.
- Utente finale non-root.
- Copiare soltanto artefatti necessari.
- Niente segreti nell'immagine o nei layer.
- `.containerignore` obbligatorio per sorgenti, build e secret non necessari.
- Configurazione tramite environment/secret a runtime.
- Entry point compatibile con segnali e graceful shutdown.
- Healthcheck applicativo verificato.
- Ogni Containerfile nuovo o modificato passa Hadolint, eseguito con Podman tramite l'immagine `docker.io/hadolint/hadolint:v2.15.1`; nessun finding ammesso salvo `# hadolint ignore=DLxxxx` motivato. Comandi in `references/commands.md`, sezione 12.
