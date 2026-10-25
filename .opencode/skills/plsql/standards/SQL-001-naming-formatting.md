# SQL-001 — Naming & Code Formatting

**Stato: approvato.** Oracle, PostgreSQL e MySQL condividono il medesimo stile; verificare limiti degli identificatori sulla versione effettiva.

| Oggetto | Convenzione |
| --- | --- |
| Tabelle, colonne | nomi inglesi, plurali per tabelle, `snake_case` (`order_items`, `created_at`) |
| Colonna PK | `<entity>_id` |
| Vincoli | `pk_<table>`, `fk_<table>_<reference>`, `uq_<table>_<column>`, `ck_<table>_<column>` |
| Indici | `idx_<table>_<columns>` |
| Vista / sequence / trigger | `vw_<entity>`, `seq_<table>`, `tr_<table>_<event>` |
| Procedure / function | `pr_<action>_<entity>`, `fn_<action>_<entity>` |
| Package Oracle | `pkg_<domain>` |
| Parametri / variabili / costanti / cursori | `p_`, `v_`, `c_`, `cur_` |

- Vietati spazi, accenti, nomi generici e parole riservate negli identificatori nuovi; evitare identificatori quotati per forzare case.
- Keyword SQL **MAIUSCOLE**, identificatori **minuscoli**, indentazione **4 spazi**, nessuna tabulazione. Limite di riga preferenziale **100 caratteri**.
- Clausole (`SELECT`, `FROM`, `JOIN`, `WHERE`, `GROUP BY`, `ORDER BY`) su righe distinte nelle query multilinea; `AND`/`OR` a inizio riga, virgole in fondo alla riga.
- Commenti spiegano il motivo della logica, non ripetono la sintassi.
- Identificatori: preferire <=30 byte per progetti cross-version Oracle finche' le versioni non siano definite; verificare i limiti del target.
- Su database esistente: non rinominare oggetti senza approvazione e migration/rollback numerati.
- Lint con SQLFluff per le parti di sintassi supportate; non interpretare parser error di PL/SQL complesso come prova di difetto.
