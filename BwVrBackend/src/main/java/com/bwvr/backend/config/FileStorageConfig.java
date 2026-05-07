package com.bwvr.backend.config;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

@Configuration
public class FileStorageConfig {

    @Value("${bwvr.upload.dir}")
    private String uploadDir;

    @Value("${bwvr.template.dir}")
    private String templateDir;

    @Value("${bwvr.report.output.dir}")
    private String reportOutputDir;

    @PostConstruct
    public void initDirectories() throws IOException {
        Files.createDirectories(Paths.get(uploadDir));
        Files.createDirectories(Paths.get(templateDir));
        Files.createDirectories(Paths.get(reportOutputDir));
    }

    public String getUploadDir() {
        return uploadDir;
    }

    public String getTemplateDir() {
        return templateDir;
    }

    public String getReportOutputDir() {
        return reportOutputDir;
    }
}
