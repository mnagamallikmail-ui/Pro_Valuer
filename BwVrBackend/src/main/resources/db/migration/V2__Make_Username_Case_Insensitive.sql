-- V2__Make_Username_Case_Insensitive.sql

-- Lowercase existing usernames to enforce case-insensitivity
UPDATE BWVR_USER SET USERNAME = LOWER(USERNAME);

-- Add a unique index on the lowercase username (if the database supports it, else rely on the updated data and application logic)
-- For PostgreSQL, we can add an index:
CREATE UNIQUE INDEX IF NOT EXISTS idx_bwvr_user_username_lower ON BWVR_USER (LOWER(USERNAME));
