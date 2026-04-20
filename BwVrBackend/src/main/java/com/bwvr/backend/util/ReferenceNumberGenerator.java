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
            // Using uppercase schema 'BWVR' to match the entity definition
            Long nextVal = jdbcTemplate.queryForObject("SELECT nextval('BWVR.REPORT_REF_SEQ')", Long.class);
            return (nextVal != null) ? String.valueOf(nextVal) : "10000";
        } catch (RuntimeException e) {
            // Fallback: Find the max numerical reference number and increment it
            try {
                Long maxVal = jdbcTemplate.queryForObject(
                    "SELECT MAX(CAST(reference_number AS BIGINT)) FROM BWVR.BWVR_REPORT WHERE reference_number ~ '^[0-9]+$'", 
                    Long.class
                );
                return String.valueOf((maxVal != null && maxVal >= 10000) ? maxVal + 1 : 10000);
            } catch (Exception ex) {
                return "10000";
            }
        }
    }
}
