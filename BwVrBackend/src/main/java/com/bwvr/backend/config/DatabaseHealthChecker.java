package com.bwvr.backend.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class DatabaseHealthChecker implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DatabaseHealthChecker.class);
    private final JdbcTemplate jdbcTemplate;

    public DatabaseHealthChecker(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {
        log.info("Performing database health check...");
        try {
            // Check if schema BWVR exists
            Integer schemaCount = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM information_schema.schemata WHERE schema_name = 'bwvr'", Integer.class);
            
            if (schemaCount == null || schemaCount == 0) {
                log.error("CRITICAL: Schema 'BWVR' is missing from the database.");
            } else {
                log.info("Schema 'BWVR' confirmed.");
            }

            // Check if sequence REPORT_REF_SEQ exists
            Integer seqCount = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM information_schema.sequences WHERE sequence_schema = 'bwvr' AND sequence_name = 'report_ref_seq'", Integer.class);
            
            if (seqCount == null || seqCount == 0) {
                log.error("CRITICAL: Sequence 'REPORT_REF_SEQ' is missing from schema 'BWVR'.");
            } else {
                log.info("Sequence 'REPORT_REF_SEQ' confirmed.");
            }
            
        } catch (org.springframework.dao.DataAccessException e) {
            log.warn("Database health check failed (DB objects might be missing or DB not ready): {}", e.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error during database health check: {}", e.getMessage(), e);
        }
    }
}
