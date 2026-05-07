package com.bwvr.backend.util;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.bwvr.backend.exception.ReportCreationException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataRetrievalFailureException;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Unit tests for ReferenceNumberGenerator.
 *
 * These tests guard against the recurring production failure caused by
 * bwvr.report_ref_seq not existing on fresh Railway deployments.
 */
@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class ReferenceNumberGeneratorTest {

    @Mock
    private JdbcTemplate jdbcTemplate;

    @InjectMocks
    private ReferenceNumberGenerator generator;

    @Test
    @DisplayName("Success: Returns sequence value when sequence is available")
    void generate_success_returnsSequenceValue() {
        // Arrange: sequence returns 10005
        org.mockito.Mockito.when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenReturn(10005L);

        // Act
        String ref = generator.generate();

        // Assert
        assertThat(ref).isEqualTo("10005");
    }

    @Test
    @DisplayName("Success: Returns '10000' when sequence returns null (edge case)")
    void generate_success_returnsBase_whenSequenceReturnsNull() {
        // Arrange: sequence returns null
        org.mockito.Mockito.when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenReturn(null);

        // Act
        String ref = generator.generate();

        // Assert: null is treated as 10000
        assertThat(ref).isEqualTo("10000");
    }

    @Test
    @DisplayName("Fallback: Uses MAX+1 from table when sequence fails")
    void generate_fallback_usesMaxPlusOne_whenSequenceFails() {
        // Arrange: first call (sequence) fails, second call (MAX) returns 10050
        org.mockito.Mockito.when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenThrow(new DataRetrievalFailureException("relation bwvr.report_ref_seq does not exist"))
                .thenReturn(10050L);

        // Act
        String ref = generator.generate();

        // Assert: MAX(10050) + 1
        assertThat(ref).isEqualTo("10051");
    }

    @Test
    @DisplayName("Fallback: Returns 10000 when table exists but has no numeric references")
    void generate_fallback_returns10000_whenTableIsEmpty() {
        // Arrange: first call (sequence) fails, second call (MAX) returns null (empty table)
        org.mockito.Mockito.when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenThrow(new DataRetrievalFailureException("sequence missing"))
                .thenReturn(null);

        // Act
        String ref = generator.generate();

        // Assert: null MAX treated as start value
        assertThat(ref).isEqualTo("10000");
    }

    @Test
    @DisplayName("Failure: Throws ReportCreationException when BOTH sequence and table fail")
    void generate_throwsReportCreationException_whenAllStrategiesFail() {
        // Arrange: both calls fail (e.g. schema doesn't exist at all)
        org.mockito.Mockito.when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenThrow(new DataRetrievalFailureException("relation bwvr.report_ref_seq does not exist"));

        // Act + Assert
        assertThatThrownBy(() -> generator.generate())
                .isInstanceOf(ReportCreationException.class)
                .hasMessageContaining("database reference sequence is missing")
                .hasMessageContaining("administrator");
    }

    @Test
    @DisplayName("Failure: ReportCreationException message does not expose raw SQL to end users")
    void generate_exceptionMessage_isUserFriendly() {
        // Arrange
        org.mockito.Mockito.when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenThrow(new DataRetrievalFailureException("some db error"));

        // Act + Assert: message should be user-facing, not a raw SQL error
        assertThatThrownBy(() -> generator.generate())
                .isInstanceOf(ReportCreationException.class)
                .hasMessageContaining("contact an administrator")
                .hasMessageNotContaining("relation")  // no raw PG error
                .hasMessageNotContaining("ERROR:");
    }
}
