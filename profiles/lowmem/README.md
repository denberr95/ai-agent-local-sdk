# Profilo `lowmem`

Variante del kit per workstation che **non possono dedicare al modello la memoria che il
profilo predefinito richiede**: tipicamente Windows o Linux con 32 GB condivisi fra modello,
browser, posta e strumenti di collaborazione.

Il profilo predefinito resta invariato: `lowmem` non sostituisce nulla, si sceglie
all'installazione.

```bash
scripts/install.sh ../mio-progetto --profile lowmem
```

```powershell
.\scripts\install.ps1 ..\mio-progetto -Profile lowmem
```

## Che cosa cambia

| | profilo predefinito | `lowmem` |
| --- | --- | --- |
| Modello | `flint:40b-a2b-qat-int4`, circa 23 GB | `granite4:micro`, circa 2,1 GB (`ollama/Modelfile.lowmem`) |
| Subagent installati | 9 | 3: `architect-planner`, `backend-developer`, `code-quality-reviewer` |
| Skill installate | 4 | 1 per progetto: `springboot` **oppure** `plsql` |
| `instructions` | COM-001 sempre in contesto | vuoto; COM-001 resta disponibile tramite la skill `common` |

Le regole del team su quality gate, evidenze, Git, shell e contenuto del report finale **non
cambiano**: `profiles/lowmem/AGENTS.md` differisce dal file predefinito solo nella tabella
degli agenti e nell'elenco delle skill, allineati a quelli realmente installati.

## Perche' serve

Due vincoli distinti, entrambi verificati.

**Memoria.** Il profilo predefinito e' tarato su una workstation che dedica al modello circa
23 GB dei 32 disponibili. Se browser, posta e strumenti di collaborazione ne occupano gia' 25,
il modello non viene caricato affatto.

**Formato del modello.** Il tag `flint:40b-a2b-qat-int4` e' in formato MLX: il suo manifest
contiene 779 layer `application/vnd.ollama.image.tensor` invece del singolo layer
`application/vnd.ollama.image.model` dei tag GGUF. Su Windows e Linux `ollama pull` termina
subito con:

```
Error: this model requires MLX support, but the MLX runtime is not available
```

Per verificare il formato di un tag senza scaricarlo:

```bash
curl -fsS https://registry.ollama.ai/v2/library/flint/manifests/<tag> | grep -o 'image\.[a-z]*'
```

## Il requisito decisivo: nessun `thinking`

Il modello sostitutivo deve avere `tools` fra le Capabilities di `ollama show` e **non** deve
avere `thinking`. Non e' una preferenza: un modello con il ragionamento attivo consuma
centinaia di token per turno e, sotto il prompt di sistema del kit, non converge.

Misurato sulla stessa macchina, stessa domanda, stesso contesto di 16384 token:

| Modello | `thinking` | Token per una domanda da una riga | Esito di `opencode run` |
| --- | --- | --- | --- |
| `qwen3:4b` | si', non disattivabile | circa 12.000 | nessuna risposta in 9 minuti, 3 tentativi |
| `granite4:micro` | no | 28 | risposta in circa 18 secondi |

Su `qwen3` il parametro `think: false` di `/api/chat` non risolve: il template non lo onora e
il ragionamento finisce dentro `content` invece che nel campo `thinking`.

## La sandbox `execute` va negata

Il profilo predefinito non ha una regola catch-all: elenca i permessi per lettura, modifica,
shell, rete, skill e subagent, quindi **ogni tool non elencato risulta consentito**. Fra questi
c'e' la sandbox JavaScript `execute`, e un modello piccolo la preferisce alla lettura dei file:
scrive codice con valori segnaposto e poi riporta quei segnaposto come dati reali.

Stessa domanda, "quali subagent sono disponibili in questo progetto?", stesso modello:

| | tool usato | risposta |
| --- | --- | --- |
| senza la regola | `execute` con `const availableSubagents = ['general', 'explore']` | inventata |
| con `execute` negato | `Glob "**/*.md"` | corretta: i tre subagent del profilo |

Per questo `profiles/lowmem/opencode.jsonc` contiene `{ "action": "execute", "resource": "*",
"effect": "deny" }`. Vale la pena valutare la stessa regola anche nel profilo predefinito.

## Prestazioni misurate

Windows 11, Core Ultra 7 165H, 32 GB in **single channel**, RTX 500 Ada 4 GB, Ollama 0.40.11,
contesto 16384, con le variabili di `ollama/ollama.env` applicate.

| | residenti | CPU/GPU | token/s |
| --- | --- | --- | --- |
| `qwen3:4b`, KV cache `f16` | 5,4 GB | 58%/42% | 9,4 |
| `qwen3:4b`, KV cache `q8_0` | 4,3 GB | 46%/54% | 19,5 |
| `granite4:micro`, KV cache `q8_0` | 3,2 GB | 29%/71% | 31,1 |

`OLLAMA_KV_CACHE_TYPE=q8_0` dimezza la cache del contesto, da 2304 a 1152 MiB: il modello
scende sotto la soglia oltre la quale i layer non entrano piu' in VRAM, e la velocita'
raddoppia. **Le variabili valgono solo dal riavvio del server**: vedi le trappole in
[INSTALL.md](../../INSTALL.md).

## Limiti

Il profilo rende il kit utilizzabile per interventi circoscritti, non equivalente al profilo
predefinito. Un modello da 3 miliardi di parametri ha meno capacita' di pianificazione di uno
da 40: su `/feature` conviene confermare i passi uno alla volta invece di lasciare correre
l'intero workflow, e le review vanno lette come un primo filtro, non come un esito definitivo.
Vale soprattutto la regola generale del kit: non fidarsi di un output senza evidenze, perche'
un modello piccolo, quando non sa, tende a riempire il vuoto.

Se la workstation ha uno slot di memoria libero, aggiungere un banco e usare il profilo
predefinito resta la soluzione migliore: raddoppia la capacita' e, uscendo dal single channel,
anche la banda di memoria, che e' il vero limite dell'inferenza in CPU.
