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
    void generate_fallback_whenExceptionOccurs() {
        when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenThrow(new RuntimeException("Database error"));

        String ref = generator.generate();

        assertThat(ref).isEqualTo("10000");
    }

    @Test
    void generate_fallback_whenNullReturned() {
        when(jdbcTemplate.queryForObject(anyString(), eq(Long.class))).thenReturn(null);

        // Since queryForObject might return null if not careful, or throw EmptyResultDataAccessException
        // In our current implementation, String.valueOf(null) would be "null".
        // Wait, JdbcTemplate.queryForObject(sql, Long.class) with null return might throw or return null.
        // If it returns null, String.valueOf(null) is "null".
        // Let's check how ReferenceNumberGenerator handles it.
        // It returns String.valueOf(nextVal).
        
        String ref = generator.generate();
        
        assertThat(ref).isEqualTo("10000");
    }
}

