# macOS e Windows

Podman usa normalmente una VM gestita da `podman machine`.

```bash
podman machine list
podman machine start
podman info
```

Verificare port forwarding, volumi, architettura immagini e provider Compose. Ollama resta nativo sull'host e non va eseguito nella VM Podman per il workflow standard del team.
