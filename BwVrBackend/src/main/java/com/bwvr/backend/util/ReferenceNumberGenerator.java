package com.bwvr.backend.util;

import com.bwvr.backend.exception.ReportCreationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Generates unique 5-digit reference numbers for reports using a PostgreSQL sequence.
 *
 * <p>Design decisions:
 * <ul>
 *   <li>Uses {@code PROPAGATION.REQUIRES_NEW} so that a sequence failure does NOT poison
 *       the outer report-creation transaction. Without this, a failed nextval() inside a
 *       @Transactional method marks the transaction as "aborted", making every subsequent
 *       SQL in that transaction fail with "current transaction is aborted".</li>
 *   <li>Uses lowercase {@code bwvr.report_ref_seq} â€” PostgreSQL folds unquoted identifiers
 *       to lowercase. The previous code used uppercase {@code BWVR.REPORT_REF_SEQ} which
 *       can fail depending on PostgreSQL JDBC driver configuration.</li>
 *   <li>Throws {@link ReportCreationException} on failure so the global exception handler
 *       returns a structured 422 response with a clear message.</li>
 * </ul>
 */
@Component
public class ReferenceNumberGenerator {

    private static final Logger log = LoggerFactory.getLogger(ReferenceNumberGenerator.class);

    private static final String SEQ_QUERY = "SELECT nextval('bwvr.report_ref_seq')";
    private static final String MAX_QUERY =
            "SELECT COALESCE(MAX(CAST(reference_number AS BIGINT)), 9999) " +
            "FROM bwvr.bwvr_report " +
            "WHERE reference_number ~ '^[0-9]+$'";

    private final JdbcTemplate jdbcTemplate;

    public ReferenceNumberGenerator(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Generates the next unique reference number.
     *
     * <p>Primary strategy: fetch next value from {@code bwvr.report_ref_seq}.
     * Fallback strategy: MAX(reference_number) + 1 from the report table.
     * If both fail: throws {@link ReportCreationException} â€” report creation is aborted cleanly.
     *
     * @return a string like "10001", "10002", etc.
     * @throws ReportCreationException if neither strategy succeeds
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public String generate() {
        // Strategy 1: Use the PostgreSQL sequence (primary, preferred)
        try {
            Long nextVal = jdbcTemplate.queryForObject(SEQ_QUERY, Long.class);
            String ref = String.valueOf(nextVal != null ? nextVal : 10000L);
            log.debug("Generated reference number from sequence: {}", ref);
            return ref;
        } catch (DataAccessException e) {
            log.warn("Sequence 'bwvr.report_ref_seq' is unavailable ({}). Attempting table MAX fallback.", e.getMessage());
        }

        // Strategy 2: MAX + 1 from the report table (fallback for recovery)
        try {
            Long maxVal = jdbcTemplate.queryForObject(MAX_QUERY, Long.class);
            long next = (maxVal != null && maxVal >= 10000L) ? maxVal + 1L : 10000L;
            String ref = String.valueOf(next);
            log.warn("Generated reference number via MAX fallback: {}", ref);
            return ref;
        } catch (DataAccessException ex) {
            log.error("Both sequence and table fallback failed for reference number generation. " +
                    "Sequence error: table 'bwvr.bwvr_report' or sequence 'bwvr.report_ref_seq' may be missing.", ex);
            throw new ReportCreationException(
                    "Report creation is currently unavailable: the database reference sequence is missing. " +
                    "This is a configuration issue â€” please contact an administrator. " +
                    "(Technical detail: bwvr.report_ref_seq does not exist)"
            );
        }
    }
}
