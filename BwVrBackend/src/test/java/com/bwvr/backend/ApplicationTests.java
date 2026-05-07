package com.bwvr.backend;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class ApplicationTests {

    @Test
    void applicationStarts() {
        BwVrBackendApplication app = new BwVrBackendApplication();
        assertThat(app).isNotNull();
    }
}
