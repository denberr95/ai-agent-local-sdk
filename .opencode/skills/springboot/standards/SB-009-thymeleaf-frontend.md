# SB-009 — Thymeleaf & Server-side Frontend

> Stato: **approvato** il 25 ottobre 2026. Si applica alle interfacce web renderizzate dal server con Spring MVC e Thymeleaf. Completa SB-002, SB-004 e SB-007.

## Architettura

Il codice Java segue Package by Layer (SB-002):

| Elemento | Posizione | Naming |
|---|---|---|
| Controller pagine | `controller` | `<Entity>ViewController` |
| Form object | `dto/form` | `<Action><Entity>Form` |
| Dati per la vista | `dto/response` o `dto/view` | `<Entity>Response`, `<Entity>View` |

- I controller pagine restano sottili: validation, chiamata al Service, scelta della vista; nessuna query e nessuna logica di business.
- Le Entity JPA non vengono mai passate al model né usate come form object.
- Se REST e pagine coesistono, i controller REST restano separati e seguono SB-004.

## Template

```text
src/main/resources/
├── templates/
│   ├── layout/        layout principale
│   ├── fragments/     header, footer, menu, campi form, paginazione, messaggi
│   ├── <feature>/     list.html, detail.html, form.html
│   └── error/         404.html, 4xx.html, 5xx.html
├── static/
│   ├── css/
│   ├── js/
│   └── img/
└── messages*.properties
```

- Nomi file in kebab-case; la vista restituita dal controller corrisponde al percorso (`customer/list`).
- Riutilizzo tramite fragment (`th:replace`, `th:insert`); Layout Dialect soltanto se già adottato.
- Nei template soltanto presentazione, formattazione e condizioni di visualizzazione.
- Thymeleaf 3.1 non espone `#request`, `#session`, `#servletContext` e `#response`: i dati arrivano dal model.

## Form

- `th:object` e `th:field`; validation Jakarta Bean Validation lato server con `@Valid` e `BindingResult`.
- Errori mostrati accanto al campo con `th:errors` e riepilogati in testa al form.
- Pattern Post/Redirect/Get dopo ogni POST riuscito; messaggi di esito tramite flash attribute.
- Mai GET per operazioni che modificano dati.

## Sicurezza

- Output sempre con `th:text` (escaping automatico).
- `th:utext` vietato, salvo contenuto sanificato lato server con libreria approvata e security review.
- Dati verso JavaScript tramite attributi `data-*` o `th:inline="javascript"`; mai dati utente in attributi evento `th:on*`.
- Form con `th:action`, così Spring Security aggiunge il token CSRF; CSRF mai disabilitato per l'interfaccia web.
- Interfaccia web autenticata con OIDC verso l'Identity Provider (SB-007) e sessione server-side; le API `/api/**` restano JWT Resource Server stateless con una `SecurityFilterChain` separata.
- Cookie di sessione `HttpOnly`, `Secure` fuori dagli ambienti locali, `SameSite=Lax` o più restrittivo; logout tramite POST.
- Content Security Policy senza `unsafe-inline`: CSS e JavaScript in file statici; nonce soltanto se inevitabile.
- `sec:authorize` nei template serve solo alla visualizzazione: l'autorizzazione resta su controller e Service.

## Errori

- Pagine `templates/error/` senza stack trace né dettagli interni.
- La pagina di errore mostra il `correlationId` per il supporto (COM-005).
- Problem Details (SB-004) resta il formato delle API, non delle pagine HTML.

## Internazionalizzazione

- Nessun testo visibile hardcoded: chiavi in `messages*.properties`, gerarchiche per feature (`customer.list.title`).
- Date e numeri formattati con `#temporals` e `#numbers` secondo la locale.

## Accessibilità

Baseline WCAG 2.2 livello AA:

- HTML semantico (`header`, `nav`, `main`, `button` per le azioni) e un solo `h1` per pagina;
- ogni campo con `label` associata ed errori collegati al campo;
- `alt` significativo sulle immagini;
- navigazione completa da tastiera e focus visibile;
- contrasto sufficiente; nessuna informazione trasmessa solo dal colore.

## Asset statici e JavaScript

- JavaScript minimo e progressivo; le funzioni principali restano utilizzabili senza script quando possibile.
- Nessuna libreria o framework frontend, CDN esterno o WebJar senza approvazione (SB-001).
- Cache busting con la content version strategy della resource chain di Spring quando necessario.

## Test

- `@WebMvcTest` con MockMvc per ogni controller pagine: status, nome vista, attributi del model, redirect PRG, errori di validation.
- Spring Security Test: accesso negato senza autenticazione, permessi insufficienti, POST senza token CSRF rifiutato.
- Test di rendering per fragment con logica condizionale significativa.
- Test end-to-end nel browser soltanto se lo strumento è approvato dal progetto.
- Coverage secondo SB-006.

## Quality gate

Nessun `th:utext` non approvato, CSRF attivo, form validati lato server, PRG rispettato, testi esternalizzati, controlli di accessibilità documentati, test MVC e di sicurezza superati.
