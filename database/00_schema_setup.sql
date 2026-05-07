-- ============================================================
-- BwVr Report Management System
-- FILE 0: 00_schema_setup.sql
-- Run as DBA (SYS or SYSTEM) BEFORE any other scripts
-- ============================================================

-- Create BWVR schema user
CREATE USER BWVR IDENTIFIED BY bwvr_pass
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;

-- Grant necessary privileges
GRANT CONNECT, RESOURCE, CREATE VIEW TO BWVR;
GRANT UNLIMITED TABLESPACE TO BWVR;
GRANT CREATE SEQUENCE TO BWVR;
GRANT CREATE TABLE TO BWVR;
GRANT CREATE VIEW TO BWVR;
GRANT CREATE SESSION TO BWVR;

COMMIT;

-- ============================================================
-- Execute order after this file:
-- 1. 01_sequences.sql
-- 2. 02_tables_core.sql
-- 3. 03_tables_report.sql
-- 4. 04_tables_audit.sql
-- 5. 05_views.sql
-- 6. 06_grants.sql (optional)
-- ============================================================
