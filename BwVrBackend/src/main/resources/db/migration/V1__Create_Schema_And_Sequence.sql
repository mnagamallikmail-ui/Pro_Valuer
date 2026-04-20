-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS BWVR;

-- Create sequence for report reference numbers starting at 10000
CREATE SEQUENCE IF NOT EXISTS BWVR.REPORT_REF_SEQ
    START WITH 10000
    INCREMENT BY 1
    MINVALUE 10000
    NO MAXVALUE
    CACHE 1;

-- Ensure tables are in the correct schema if hibernate didn't do it right
-- This is a baseline migration for the essential objects
