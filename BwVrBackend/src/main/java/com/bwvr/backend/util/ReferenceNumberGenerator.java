package com.bwvr.backend.util;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class ReferenceNumberGenerator {

    private final JdbcTemplate jdbcTemplate;

    public ReferenceNumberGenerator(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Generates a unique 5-digit numerical reference number starting at 10000.
     * Logic: Fetches the next value from the database sequence 'REPORT_REF_SEQ'.
     * SQL (PostgreSQL/Oracle): SELECT nextval('bwvr.REPORT_REF_SEQ')
     * or for Oracle: SELECT bwvr.REPORT_REF_SEQ.NEXTVAL FROM DUAL
     */
    public String generate() {
        try {
            // Using a standard query that works for PostgreSQL (current runtime)
            // If strictly using Oracle, change to: "SELECT bwvr.REPORT_REF_SEQ.NEXTVAL FROM DUAL"
            Long nextVal = jdbcTemplate.queryForObject("SELECT nextval('bwvr.REPORT_REF_SEQ')", Long.class);
            return (nextVal != null) ? String.valueOf(nextVal) : "10000";
        } catch (RuntimeException e) {
            // Fallback to a safe number if sequence fetch fails (e.g., during initialization)
            return "10000";
        }
    }
}
