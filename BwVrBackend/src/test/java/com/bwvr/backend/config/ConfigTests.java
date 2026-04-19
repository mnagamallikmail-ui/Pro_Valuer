package com.bwvr.backend.config;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

class ConfigTests {

    @Test
    void testFileStorageConfig() throws IOException {
        FileStorageConfig config = new FileStorageConfig();
        Path tempBase = Files.createTempDirectory("config_test");
        ReflectionTestUtils.setField(config, "uploadDir", tempBase.resolve("upload").toString());
        ReflectionTestUtils.setField(config, "templateDir", tempBase.resolve("template").toString());
        ReflectionTestUtils.setField(config, "reportOutputDir", tempBase.resolve("output").toString());

        config.initDirectories();

        assertThat(config.getUploadDir()).contains("upload");
        assertThat(config.getTemplateDir()).contains("template");
        assertThat(config.getReportOutputDir()).contains("output");
    }

    @Test
    void testCorsConfig() {
        CorsConfig config = new CorsConfig();
        assertThat(config).isNotNull();
    }

    @Test
    void testOpenApiConfig() {
        OpenApiConfig config = new OpenApiConfig();
        assertThat(config.bwvrOpenAPI()).isNotNull();
    }
}
