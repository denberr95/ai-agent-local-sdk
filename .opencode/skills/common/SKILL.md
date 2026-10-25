---
name: Common Team Standards
description: "Standard comuni a tutti gli stack (COM-001–COM-009): quality gate ed evidenze, Git, secure coding trasversale, code review, logging e correlation ID, documentazione e ADR, script cross-platform, verifica qualità con SonarQube e security review in container Podman."
---

# Common Team Standards

Questa skill raccoglie le regole trasversali a Spring Boot, PL/SQL e Podman. COM-001 contiene le regole dei quality gate, sempre in contesto tramite `instructions`.

## Precedenza

1. Le skill tecniche (`springboot`, `plsql`, `podman`) prevalgono per gli aspetti specifici del proprio stack.
2. In caso di conflitto fra regole applicabili vale la più restrittiva, salvo eccezione approvata e documentata.
3. Le convenzioni del progetto esistente si rispettano se non violano sicurezza, quality gate o tracciabilità.

## Workflow

1. Leggi soltanto gli standard pertinenti al task.
2. Per review e security review leggi COM-003 e COM-004; la verifica di qualità richiede l'analisi SonarQube di COM-008, la security review i controlli in container di COM-009.
3. Riporta sempre stati ed evidenze secondo COM-001.
4. Non inventare output, non esporre segreti e non auto-approvare eccezioni.

## Standard

- `standards/COM-001-quality-gates-evidence.md`
- `standards/COM-002-git-change-management.md`
- `standards/COM-003-secure-coding.md`
- `standards/COM-004-code-review.md`
- `standards/COM-005-logging-correlation.md`
- `standards/COM-006-documentation-adr.md`
- `standards/COM-007-cross-platform-scripts.md`
- `standards/COM-008-sonarqube-podman.md`
- `standards/COM-009-security-review-podman.md`

## Template

- `templates/review-report.md`: review di artefatti non coperti dai template delle skill tecniche (script, YAML, Containerfile, documentazione).
- `templates/Containerfile.security-review`: immagine degli strumenti della security review (COM-009).
- `templates/request.md`: file di tracciamento di ogni feature o correzione in `docs/requests/` (COM-002).
- Per risk acceptance usa il template della skill tecnica pertinente (`springboot` o `plsql`).
