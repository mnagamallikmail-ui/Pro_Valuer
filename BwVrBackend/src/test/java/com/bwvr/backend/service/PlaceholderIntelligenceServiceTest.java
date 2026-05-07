package com.bwvr.backend.service;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class PlaceholderIntelligenceServiceTest {

    private final PlaceholderIntelligenceService service = new PlaceholderIntelligenceService();

    @Test
    void generateQuestion_fromMap() {
        assertThat(service.generateQuestion("VENDOR_NAME")).isEqualTo("What is the name of the vendor?");
        assertThat(service.generateQuestion("DATE_REPORT_GEN")).isEqualTo("What is the report generation date?");
        assertThat(service.generateQuestion("IMG_LOGO")).isEqualTo("Upload the bank/organization logo image");
    }

    @Test
    void generateQuestion_fallbackImg() {
        // IMG_UNKNOWN -> "Upload the unknown image"
        String q = service.generateQuestion("IMG_BANNER_NEW");
        assertThat(q).containsIgnoringCase("Upload")
                .containsIgnoringCase("banner new")
                .containsIgnoringCase("image");
    }

    @Test
    void generateQuestion_fallbackDate() {
        // DATE_EXPIRY -> "What is the expiry?"
        String q = service.generateQuestion("DATE_EXPIRY");
        assertThat(q).containsIgnoringCase("What is the")
                .containsIgnoringCase("expiry");
    }

    @Test
    void generateQuestion_fallbackDefault() {
        // TOTAL_TAX -> "What is the total tax?"
        String q = service.generateQuestion("TOTAL_TAX");
        assertThat(q).containsIgnoringCase("What is the")
                .containsIgnoringCase("total tax");
    }

    @Test
    void generateQuestion_caseSensitive() {
        // Map has VENDOR_NAME. vendor_name should hit fallback.
        String q = service.generateQuestion("vendor_name");
        assertThat(q).containsIgnoringCase("What is the")
                .containsIgnoringCase("vendor name");
    }
}
