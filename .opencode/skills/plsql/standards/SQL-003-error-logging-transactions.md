# SQL-003 — Error Handling, Logging & Transactions

**Stato: approvato; politica transazionale e logging ibridi.**

- Validare input e distinguere errori attesi da imprevisti; non sopprimere eccezioni. Mantenere codice e diagnostica originali ove possibile; errori strutturati, senza segreti.
- Oracle: `EXCEPTION`, `RAISE`, `RAISE_APPLICATION_ERROR`, `SQLCODE`, `DBMS_UTILITY`; PostgreSQL: `RAISE`, `SQLSTATE`, `GET STACKED DIAGNOSTICS`; MySQL: `SIGNAL`, `RESIGNAL`, `GET DIAGNOSTICS`.
- Spring Boot o il chiamante controllano normalmente COMMIT e ROLLBACK. Solo batch autonomi approvati e documentati possono gestire proprie transazioni.
- I batch documentano confini della transazione, checkpoint, lock, compensazioni e ripartenza; nessun commit nascosto in routine ordinarie.
- Logging: Spring Boot governa i log applicativi; i batch DB producono log di esecuzione; audit separato (SQL-003A). Evitare doppio logging della stessa eccezione.
- Propagare `correlation_id` esplicito tramite `p_correlation_id` nelle nuove routine pubbliche e nei log; generare un ID per esecuzione batch.
- Controllare i commit impliciti delle DDL Oracle e MySQL; un rollback di transazione NON e' un rollback di migration (SQL-007).
