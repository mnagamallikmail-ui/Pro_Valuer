package com.bwvr.backend.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "BWVR_REPORT_VALUE", schema = "bwvr",
        uniqueConstraints = @UniqueConstraint(columnNames = {"REPORT_ID", "PLACEHOLDER_ID"}))
public class BwvrReportValue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VALUE_ID")
    private Long valueId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "REPORT_ID", nullable = false)
    private BwvrReport report;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "PLACEHOLDER_ID", nullable = false)
    private BwvrTemplatePlaceholder placeholder;

    @Column(name = "PLACEHOLDER_KEY", nullable = false, length = 300)
    private String placeholderKey;

    @Column(name = "TEXT_VALUE", length = 4000)
    private String textValue;

    @Column(name = "IMAGE_FILE_PATH", length = 1000)
    private String imageFilePath;

    @Column(name = "IMAGE_ORIGINAL_NAME", length = 500)
    private String imageOriginalName;

    @Column(name = "IMAGE_DATA", columnDefinition = "bytea")
    private byte[] imageData;

    @CreationTimestamp
    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "UPDATED_AT")
    private LocalDateTime updatedAt;

    public BwvrReportValue() {
    }

    private BwvrReportValue(Builder b) {
        this.valueId = b.valueId;
        this.report = b.report;
        this.placeholder = b.placeholder;
        this.placeholderKey = b.placeholderKey;
        this.textValue = b.textValue;
        this.imageFilePath = b.imageFilePath;
        this.imageOriginalName = b.imageOriginalName;
        this.imageData = b.imageData;
        this.createdAt = b.createdAt;
        this.updatedAt = b.updatedAt;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long valueId;
        private BwvrReport report;
        private BwvrTemplatePlaceholder placeholder;
        private String placeholderKey;
        private String textValue;
        private String imageFilePath;
        private String imageOriginalName;
        private byte[] imageData;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public Builder valueId(Long v) {
            this.valueId = v;
            return this;
        }

        public Builder report(BwvrReport v) {
            this.report = v;
            return this;
        }

        public Builder placeholder(BwvrTemplatePlaceholder v) {
            this.placeholder = v;
            return this;
        }

        public Builder placeholderKey(String v) {
            this.placeholderKey = v;
            return this;
        }

        public Builder textValue(String v) {
            this.textValue = v;
            return this;
        }

        public Builder imageFilePath(String v) {
            this.imageFilePath = v;
            return this;
        }

        public Builder imageOriginalName(String v) {
            this.imageOriginalName = v;
            return this;
        }

        public Builder imageData(byte[] v) {
            this.imageData = v;
            return this;
        }

        public Builder createdAt(LocalDateTime v) {
            this.createdAt = v;
            return this;
        }

        public Builder updatedAt(LocalDateTime v) {
            this.updatedAt = v;
            return this;
        }

        public BwvrReportValue build() {
            return new BwvrReportValue(this);
        }
    }

    public Long getValueId() {
        return valueId;
    }

    public void setValueId(Long valueId) {
        this.valueId = valueId;
    }

    public BwvrReport getReport() {
        return report;
    }

    public void setReport(BwvrReport report) {
        this.report = report;
    }

    public BwvrTemplatePlaceholder getPlaceholder() {
        return placeholder;
    }

    public void setPlaceholder(BwvrTemplatePlaceholder placeholder) {
        this.placeholder = placeholder;
    }

    public String getPlaceholderKey() {
        return placeholderKey;
    }

    public void setPlaceholderKey(String placeholderKey) {
        this.placeholderKey = placeholderKey;
    }

    public String getTextValue() {
        return textValue;
    }

    public void setTextValue(String textValue) {
        this.textValue = textValue;
    }

    public String getImageFilePath() {
        return imageFilePath;
    }

    public void setImageFilePath(String imageFilePath) {
        this.imageFilePath = imageFilePath;
    }

    public String getImageOriginalName() {
        return imageOriginalName;
    }

    public void setImageOriginalName(String imageOriginalName) {
        this.imageOriginalName = imageOriginalName;
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

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
