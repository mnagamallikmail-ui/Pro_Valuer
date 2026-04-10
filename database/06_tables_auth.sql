-- ==============================================================================
-- 06_tables_auth.sql
-- Description: Creates the BWVR_USER table for authentication and RBAC.
-- ==============================================================================

-- User table for PostgreSQL

CREATE TABLE BWVR.BWVR_USER (
    USER_ID SERIAL PRIMARY KEY,
    USERNAME VARCHAR(100) NOT NULL UNIQUE,
    PASSWORD_HASH VARCHAR(255) NOT NULL,
    ROLE VARCHAR(20) NOT NULL,
    STATUS VARCHAR(20) NOT NULL,
    MUST_CHANGE_PASSWORD INTEGER DEFAULT 0 NOT NULL,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP
);

-- Seed default admin user (password is BCrypt hash for 'admin123')
INSERT INTO BWVR.BWVR_USER (USERNAME, PASSWORD_HASH, ROLE, STATUS, MUST_CHANGE_PASSWORD) 
VALUES ('admin', '$2a$10$tZ2yY/P8.1wAEx1fK/.aO.oQ/vJd7nS/v8Jz2Vq1GqXy.O4qX.pZ.', 'ADMIN', 'APPROVED', 1);

COMMIT;
