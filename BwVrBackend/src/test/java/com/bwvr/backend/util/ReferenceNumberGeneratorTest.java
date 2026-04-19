package com.bwvr.backend.util;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.mockito.ArgumentMatchers.anyString;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;

@ExtendWith(MockitoExtension.class)
class ReferenceNumberGeneratorTest {

    @Mock
    private EntityManager entityManager;

    @InjectMocks
    private ReferenceNumberGenerator generator;

    @Test
    void generate_success_withNumber() {
        Query mockQuery = mock(Query.class);
        when(entityManager.createNativeQuery(anyString())).thenReturn(mockQuery);
        when(mockQuery.getSingleResult()).thenReturn(123L);

        String ref = generator.generate();

        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        assertThat(ref).isEqualTo("REF-" + date + "-000123");
    }

    @Test
    void generate_success_withStringValue() {
        Query mockQuery = mock(Query.class);
        when(entityManager.createNativeQuery(anyString())).thenReturn(mockQuery);
        when(mockQuery.getSingleResult()).thenReturn("456");

        String ref = generator.generate();

        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        assertThat(ref).isEqualTo("REF-" + date + "-000456");
    }

    @Test
    void generate_throws_whenNull() {
        Query mockQuery = mock(Query.class);
        when(entityManager.createNativeQuery(anyString())).thenReturn(mockQuery);
        when(mockQuery.getSingleResult()).thenReturn(null);

        assertThatThrownBy(() -> generator.generate())
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Sequence value is null");
    }
}
