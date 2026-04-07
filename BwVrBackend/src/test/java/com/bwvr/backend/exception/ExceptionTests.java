package com.bwvr.backend.exception;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class ExceptionTests {

    @Test
    void testResourceNotFoundException() {
        ResourceNotFoundException ex = new ResourceNotFoundException("Report", 101L);
        assertThat(ex.getMessage()).isEqualTo("Report not found with ID: 101");
    }

    @Test
    void testConflictException() {
        ConflictException ex = new ConflictException("Already exists");
        assertThat(ex.getMessage()).isEqualTo("Already exists");
    }

    @Test
    void testTemplateParseException() {
        TemplateParseException ex1 = new TemplateParseException("Error 1");
        assertThat(ex1.getMessage()).isEqualTo("Error 1");

        TemplateParseException ex2 = new TemplateParseException("Error 2", new RuntimeException());
        assertThat(ex2.getMessage()).isEqualTo("Error 2");
    }
}
