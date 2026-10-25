# PD-003 — Ambienti di test

- Database e servizi di test devono essere effimeri e isolati.
- Fissare versione e, quando richiesto, digest dell'immagine.
- Attendere readiness prima di eseguire test.
- Usare dataset sintetici e ripetibili.
- Raccogliere log, exit code, durata e image ID/digest.
- Per migration applicare forward, rollback e re-apply.
- Cleanup limitato alle risorse del task, anche in caso di errore.
- Se l'immagine non supporta l'architettura host, usare `NOT_VERIFIED`.
