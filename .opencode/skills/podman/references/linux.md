# Linux

Preferire Podman rootless. Verificare storage driver, cgroup, networking e mapping UID/GID. Non assumere che immagini o volumi creati rootful siano accessibili in rootless. Usare `podman info` come evidenza dell'ambiente.
