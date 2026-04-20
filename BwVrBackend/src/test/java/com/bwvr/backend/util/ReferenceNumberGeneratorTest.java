package com.bwvr.backend.util;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class ReferenceNumberGeneratorTest {

    @Mock
    private JdbcTemplate jdbcTemplate;

    @InjectMocks
    private ReferenceNumberGenerator generator;

    @Test
    void generate_success_returnsSequenceValue() {
        when(jdbcTemplate.queryForObject(anyString(), eq(Long.class))).thenReturn(10005L);
        String ref = generator.generate();
        assertThat(ref).isEqualTo("10005");
    }

    @Test
    void generate_fallbackToMax_whenSequenceFails() {
        // First call fails, second call (MAX) succeeds
        when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenThrow(new RuntimeException("Sequence error"))
                .thenReturn(10123L);

        String ref = generator.generate();

        assertThat(ref).isEqualTo("10124"); // 10123 + 1
    }

    @Test
    void generate_throwsException_whenAllFail() {
        // Both calls fail
        when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenThrow(new RuntimeException("Total database failure"));

        org.junit.jupiter.api.Assertions.assertThrows(
            com.bwvr.backend.exception.ReportCreationException.class,
            () -> generator.generate()
        );
    }
}

