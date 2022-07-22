# Postgres Tips/Tricks

## Query Plan Visualizer

https://explain.dalibo.com/plan

## Finding Dead Tables

```sql
SELECT * FROM pg_stat_user_tables
WHERE (idx_tup_fetch + seq_tup_read + seq_scan + n_tup_ins + n_tup_upd + n_tup_del) = 0;
```

Searches for tables where stats on Reads, Inserts, Updates, Deletes, etc are 0. Be _very careful_
about this one.
