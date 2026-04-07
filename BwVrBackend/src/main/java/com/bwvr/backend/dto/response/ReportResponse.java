package com.bwvr.backend.dto.response;

import java.time.LocalDateTime;

public class ReportResponse {

    private Long reportId;
    private String referenceNumber;
    private Long templateId;
    private String templateName;
    private String reportTitle;
    private String vendorName;
    private String location;
    private String bankName;
    private String reportStatus;
    private LocalDateTime generatedAt;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long valuesCount;
    private Long totalPlaceholders;
    private boolean hasGeneratedFile;

    public ReportResponse() {
    }

    private ReportResponse(Builder b) {
        this.reportId = b.reportId;
        this.referenceNumber = b.referenceNumber;
        this.templateId = b.templateId;
        this.templateName = b.templateName;
        this.reportTitle = b.reportTitle;
        this.vendorName = b.vendorName;
        this.location = b.location;
        this.bankName = b.bankName;
        this.reportStatus = b.reportStatus;
        this.generatedAt = b.generatedAt;
        this.createdBy = b.createdBy;
        this.createdAt = b.createdAt;
        this.updatedAt = b.updatedAt;
        this.valuesCount = b.valuesCount;
        this.totalPlaceholders = b.totalPlaceholders;
        this.hasGeneratedFile = b.hasGeneratedFile;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long reportId;
        private String referenceNumber;
        private Long templateId;
        private String templateName;
        private String reportTitle;
        private String vendorName;
        private String location;
        private String bankName;
        private String reportStatus;
        private LocalDateTime generatedAt;
        private String createdBy;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        private Long valuesCount;
        private Long totalPlaceholders;
        private boolean hasGeneratedFile;

        public Builder reportId(Long v) {
            this.reportId = v;
            return this;
        }

        public Builder referenceNumber(String v) {
            this.referenceNumber = v;
            return this;
        }

        public Builder templateId(Long v) {
            this.templateId = v;
            return this;
        }

        public Builder templateName(String v) {
            this.templateName = v;
            return this;
        }

        public Builder reportTitle(String v) {
            this.reportTitle = v;
            return this;
        }

        public Builder vendorName(String v) {
            this.vendorName = v;
            return this;
        }

        public Builder location(String v) {
            this.location = v;
            return this;
        }

        public Builder bankName(String v) {
            this.bankName = v;
            return this;
        }

        public Builder reportStatus(String v) {
            this.reportStatus = v;
            return this;
        }

        public Builder generatedAt(LocalDateTime v) {
            this.generatedAt = v;
            return this;
        }

        public Builder createdBy(String v) {
            this.createdBy = v;
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

        public Builder valuesCount(Long v) {
            this.valuesCount = v;
            return this;
        }

        public Builder totalPlaceholders(Long v) {
            this.totalPlaceholders = v;
            return this;
        }

        public Builder hasGeneratedFile(boolean v) {
            this.hasGeneratedFile = v;
            return this;
        }

        public ReportResponse build() {
            return new ReportResponse(this);
        }
    }

    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public String getReferenceNumber() {
        return referenceNumber;
    }

    public void setReferenceNumber(String referenceNumber) {
        this.referenceNumber = referenceNumber;
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
    }

    public String getTemplateName() {
        return templateName;
    }

    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }

    public String getReportTitle() {
        return reportTitle;
    }

    public void setReportTitle(String reportTitle) {
        this.reportTitle = reportTitle;
    }

    public String getVendorName() {
        return vendorName;
    }

    public void setVendorName(String vendorName) {
        this.vendorName = vendorName;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getReportStatus() {
        return reportStatus;
    }

    public void setReportStatus(String reportStatus) {
        this.reportStatus = reportStatus;
    }

    public LocalDateTime getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(LocalDateTime generatedAt) {
        this.generatedAt = generatedAt;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
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

    public Long getValuesCount() {
        return valuesCount;
    }

    public void setValuesCount(Long valuesCount) {
        this.valuesCount = valuesCount;
    }

    public Long getTotalPlaceholders() {
        return totalPlaceholders;
    }

    public void setTotalPlaceholders(Long totalPlaceholders) {
        this.totalPlaceholders = totalPlaceholders;
    }

    public boolean isHasGeneratedFile() {
        return hasGeneratedFile;
    }

    public void setHasGeneratedFile(boolean hasGeneratedFile) {
        this.hasGeneratedFile = hasGeneratedFile;
    }
}
