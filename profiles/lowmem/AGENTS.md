# Regole del team per OpenCode

## Lingua e comunicazione

- Rispondi in italiano, salvo codice, nomi tecnici o documentazione che richiedano inglese.
- Spiega ipotesi, limiti ed evidenze in modo esplicito.
- Non inventare output di comandi, test, scan, migration o deployment.

## Orchestrazione

Questo progetto usa il profilo `lowmem` e **non installa il comando `/feature`**: il modello di
questo profilo non e' in grado di condurre quel workflow senza fabbricarne l'esito (vedi
`profiles/lowmem/README.md`). Si lavora **un passo alla volta**, con richieste esplicite e
circoscritte, e l'utente verifica ogni modifica prima di passare alla successiva. Il primary
agent `build` coordina e non modifica direttamente il codice.

Prima di dichiarare completato un intervento esegui `git status --short` e verifica
l'esistenza e il contenuto dei file che dichiari di aver toccato. Se non risulta alcuna
modifica, lo stato e' `FAIL`, non successo: vale la prima regola di questo documento, non
inventare output. Non riportare mai test, scan o approvazioni che non hai eseguito.

Gli agenti disponibili sono:

| Agente | Ambito |
| --- | --- |
| `architect-planner` | Piano, requisiti, rischi; sola lettura |
| `backend-developer` | Java e Spring Boot, incluso il frontend Thymeleaf (SB-009) |
| `code-quality-reviewer` | Review di qualita' e sicurezza; sola lettura |

Questo progetto usa il profilo `lowmem` e installa soltanto questi tre subagent: non delegare
ad altri nomi. Test, infrastruttura e documentazione restano in carico all'agente che svolge
il lavoro, con le stesse regole di evidenza della sezione "Verifiche e quality gate".

## Scrittura per ambito

- Ogni file ha un solo agente scrittore per volta.
- Prima della delega specifica obiettivo, file o directory autorizzati, vincoli e output atteso.
- I developer modificano soltanto i file assegnati.
- I reviewer non modificano sorgenti, configurazioni o test; restituiscono finding.
- Se una correzione richiede file fuori ambito, chiedi l'estensione dell'ambito prima di procedere.
- Evita modifiche concorrenti agli stessi file e non sovrascrivere modifiche non comprese.

## Skill

- Il profilo `lowmem` installa una sola skill per progetto: `springboot` per Java e Spring
  Boot, oppure `plsql` per Oracle, PostgreSQL, MySQL, routine e migration.
- Leggi soltanto gli standard e i reference pertinenti al task.

## Verifiche e quality gate

Usa questi stati tecnici:

- `PASS`: controllo eseguito e superato.
- `WARNING`: rischio non bloccante documentato.
- `FAIL`: controllo eseguito e non superato.
- `NOT_VERIFIED`: controllo necessario ma non eseguito o senza evidenze sufficienti.
- `NOT_APPLICABLE`: controllo non pertinente, con motivazione.

Un task può essere completato dal subagente ma avere un quality gate `FAIL`.

### FAIL

- Correggi automaticamente solo problemi entro l'ambito assegnato.
- Esegui al massimo due cicli automatici di correzione per la stessa causa.
- Se il problema è fuori ambito o preesistente, chiedi autorizzazione ad ampliare l'intervento.
- Una vulnerabilità Critical è bloccante e non può essere accettata dall'agente.

### NOT_VERIFIED

- Non trasformarlo in `PASS`.
- Diagnostica la causa e ripeti il controllo solo quando sicuro e autorizzato.
- Se Podman, il database o uno scanner non sono disponibili, documenta esattamente ciò che manca.

### Approvazioni

- L'approvazione di un comando non equivale ad accettazione del rischio.
- Un'eccezione approvata non cambia lo stato tecnico del finding.
- Riporta approvatore, motivazione, ambito e scadenza quando l'utente fornisce tali dati.
- Non auto-approvare eccezioni, vulnerabilità o verifiche mancanti.

## Git

- Strategia **trunk-based**: `main`/`master` è il trunk e rappresenta la produzione; ogni feature o correzione si sviluppa su un branch di breve durata che torna sul trunk con una pull request (COM-002).
- Nomi dei branch: `feature/<nome>` per le funzionalità, `fix/<issue>` per le correzioni.
- All'avvio di ogni feature o correzione chiedi all'utente da quale branch partire (proposta: il trunk) e conferma il nome del nuovo branch; crealo solo dopo la conferma, con `git switch -c <branch> <branch-di-partenza>`.
- Sono consentite letture come `git status`, `git diff`, `git log`, `git show`, `git branch --show-current` e `git branch --list`.
- Esegui `git commit` soltanto con la procedura `/git-commit-conventional` (`.opencode/commands/git-commit-conventional.md`), dopo conferma esplicita dell'utente e mai sul trunk; mai `--amend` o `--no-verify`.
- Non eseguire `git push`, `git reset`, `git clean`, rebase distruttivi o force push senza un percorso umano esplicito.
- Non modificare la cronologia per nascondere errori.

## Shell e Podman

- I comandi non esplicitamente consentiti richiedono approvazione OpenCode.
- Non usare `sudo` tramite agenti.
- Non eseguire comandi distruttivi su database o ambienti condivisi.
- Con Podman elimina soltanto container e volumi creati per il task corrente.
- Vietati `podman system prune`, accesso indiscriminato al socket e container `--privileged`.

## Progetti esistenti

- Rileva versioni, build tool, architettura e convenzioni prima di modificare.
- Non eseguire upgrade automatici di Java, Spring Boot, dipendenze o database.
- I quality gate definiti dal team valgono sull'intero repository; se emergono violazioni preesistenti non correlate, segnalale e chiedi come estendere l'ambito.

## Risultato finale

Restituisci sempre:

1. riepilogo del lavoro;
2. agenti e skill utilizzati;
3. file modificati;
4. comandi realmente eseguiti;
5. test e scan con esito ed evidenze;
6. finding ancora aperti;
7. stato dei quality gate;
8. approvazioni o decisioni necessarie.
