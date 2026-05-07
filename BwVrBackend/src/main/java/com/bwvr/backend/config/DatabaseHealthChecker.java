package com.bwvr.backend.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Validates that critical database objects exist after startup.
 *
 * <p>Unlike a {@code CommandLineRunner}, this listens for {@link ApplicationReadyEvent},
 * which fires after all beans are initialized (including Flyway migrations).
 * This ensures we verify the post-migration state, not just pre-migration.
 *
 * <p>On failure: logs a CRITICAL error with remediation instructions.
 * Does NOT prevent startup — the app still starts, but report creation will fail
 * with a clear error message (from ReferenceNumberGenerator) rather than a
 * confusing "transaction aborted" cascade.
 */
@Component
public class DatabaseHealthChecker {

    private static final Logger log = LoggerFactory.getLogger(DatabaseHealthChecker.class);

    private final JdbcTemplate jdbcTemplate;

    public DatabaseHealthChecker(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void validateDatabaseSchema() {
        log.info("=== Database Schema Validation ===");
        boolean healthy = true;

        try {
            // 1. Check schema existence
            Integer schemaCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'bwvr'",
                Integer.class);

            if (schemaCount == null || schemaCount == 0) {
                log.error("CRITICAL [DB-1]: Schema 'bwvr' does not exist. " +
                        "Flyway migration V1 may not have run. " +
                        "Check that spring.flyway.enabled=true and the migration file exists.");
                healthy = false;
            } else {
                log.info("  [OK] Schema 'bwvr' exists.");
            }

            // 2. Check sequence existence (the primary root cause of the recurring failure)
            Integer seqCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.sequences " +
                "WHERE sequence_schema = 'bwvr' AND sequence_name = 'report_ref_seq'",
                Integer.class);

            if (seqCount == null || seqCount == 0) {
                log.error("CRITICAL [DB-2]: Sequence 'bwvr.report_ref_seq' does not exist. " +
                        "Report creation will fail. " +
                        "Run the V1 Flyway migration manually or redeploy with Flyway enabled.");
                healthy = false;
            } else {
                log.info("  [OK] Sequence 'bwvr.report_ref_seq' exists.");
            }

            // 3. Test sequence is callable
            if (healthy) {
                try {
                    // Use currval would fail if not called yet; use nextval in a sub-transaction
                    // but we don't want to consume a value — just verify it responds
                    Long seqVal = jdbcTemplate.queryForObject(
                        "SELECT last_value FROM bwvr.report_ref_seq", Long.class);
                    log.info("  [OK] Sequence 'bwvr.report_ref_seq' is accessible. Last value: {}", seqVal);
                } catch (DataAccessException e) {
                    log.error("CRITICAL [DB-3]: Sequence 'bwvr.report_ref_seq' exists but is not accessible: {}", e.getMessage());
                }
            }

        } catch (DataAccessException e) {
            log.error("CRITICAL [DB-0]: Database health check failed with a data access error. " +
                    "DB may not be ready or the user lacks SELECT permission on information_schema: {}", e.getMessage());
        } catch (Exception e) {
            log.error("CRITICAL [DB-0]: Unexpected error during database health check: {}", e.getMessage(), e);
        }

        if (healthy) {
            log.info("=== Database Schema Validation: PASSED ===");
        } else {
            log.error("=== Database Schema Validation: FAILED — report creation will be impaired ===");
        }
    }
}
