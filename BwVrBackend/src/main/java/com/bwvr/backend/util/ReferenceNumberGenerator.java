package com.bwvr.backend.util;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Component
public class ReferenceNumberGenerator {

    private final JdbcTemplate jdbcTemplate;

    public ReferenceNumberGenerator(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Generates a unique 5-digit numerical reference number starting at 10000.
     * Uses Propagation.REQUIRES_NEW to ensure sequence fetch doesn't abort the main transaction on failure.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public String generate() {
        try {
            Long nextVal = jdbcTemplate.queryForObject("SELECT nextval('BWVR.REPORT_REF_SEQ')", Long.class);
            return (nextVal != null) ? String.valueOf(nextVal) : "10000";
        } catch (org.springframework.dao.DataAccessException e) {
            // Fallback: Find the max numerical reference number and increment it
            // Only runs if sequence fetch fails (e.g. sequence missing/corrupted)
            try {
                Long maxVal = jdbcTemplate.queryForObject(
                    "SELECT MAX(CAST(reference_number AS BIGINT)) FROM BWVR.BWVR_REPORT WHERE reference_number ~ '^[0-9]+$'", 
                    Long.class
                );
                return String.valueOf((maxVal != null && maxVal >= 10000) ? maxVal + 1 : 10000);
            } catch (org.springframework.dao.DataAccessException ex) {
                throw new com.bwvr.backend.exception.ReportCreationException(
                    "Critical failure: Unable to generate unique reference number. " +
                    "Both DB sequence 'BWVR.REPORT_REF_SEQ' and table fallback failed.", ex);
            }
        }
    }
}
