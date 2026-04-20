-- ============================================================
-- V1: Baseline Schema and Sequence
-- 
-- This migration is the FIRST to run and establishes all
-- foundational database objects required by the application.
--
-- It is fully idempotent: safe to run on fresh or existing DBs.
-- Railway/Flyway will execute this before any app traffic.
-- ============================================================

-- Step 1: Create the bwvr schema if it doesn't exist.
-- This MUST be first. All other objects live in this schema.
CREATE SCHEMA IF NOT EXISTS bwvr;

-- Step 2: Grant usage on schema to the connected user.
-- The CURRENT_USER function resolves to the DB user Railway provides.
GRANT USAGE ON SCHEMA bwvr TO CURRENT_USER;
GRANT CREATE ON SCHEMA bwvr TO CURRENT_USER;

-- Step 3: Set the search_path so subsequent statements in this
-- migration can reference objects without schema prefix.
SET search_path TO bwvr, public;

-- Step 4: Create the report reference number sequence.
-- START WITH 10000 guarantees 5-digit reference numbers (10000–99999).
CREATE SEQUENCE IF NOT EXISTS bwvr.report_ref_seq
    START WITH 10000
    INCREMENT BY 1
    MINVALUE 10000
    NO MAXVALUE
    CACHE 1;

-- Step 5: Grant usage on the sequence explicitly.
GRANT USAGE, SELECT ON SEQUENCE bwvr.report_ref_seq TO CURRENT_USER;
