package com.bwvr.backend.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;

@Entity
@Table(name = "BWVR_REPORT_IMAGE", schema = "BWVR")
public class BwvrReportImage {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "reportImageSeq")
    @SequenceGenerator(name = "reportImageSeq", sequenceName = "BWVR.SEQ_REPORT_IMAGE_ID", allocationSize = 1)
    @Column(name = "IMAGE_ID")
    private Long imageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "REPORT_ID", nullable = false)
    private BwvrReport report;

    @Column(name = "PLACEHOLDER_KEY", nullable = false, length = 300)
    private String placeholderKey;

    @Column(name = "FILE_NAME", length = 500)
    private String fileName;

    @Column(name = "CONTENT_TYPE", length = 100)
    private String contentType;

    @Lob
    @Column(name = "IMAGE_DATA")
    private byte[] imageData;

    @CreationTimestamp
    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    public BwvrReportImage() {
    }

    // Getters and Setters
    public Long getImageId() {
        return imageId;
    }

    public void setImageId(Long imageId) {
        this.imageId = imageId;
    }

    public BwvrReport getReport() {
        return report;
    }

    public void setReport(BwvrReport report) {
        this.report = report;
    }

    public String getPlaceholderKey() {
        return placeholderKey;
    }

    public void setPlaceholderKey(String placeholderKey) {
        this.placeholderKey = placeholderKey;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public byte[] getImageData() {
        return imageData;
    }

    public void setImageData(byte[] imageData) {
        this.imageData = imageData;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
