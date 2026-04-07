alter session set container=FREEPDB1;
@00_schema_setup.sql
conn BWVR/bwvr_pass@localhost:1521/FREEPDB1
@01_sequences.sql
@02_tables_core.sql
@03_tables_report.sql
@04_tables_audit.sql
@05_views.sql
@06_tables_auth.sql
exit
