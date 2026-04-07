package com.bwvr.backend.dto.response;

import java.time.LocalDateTime;

public class TemplateResponse {

    private Long templateId;
    private String bankName;
    private String templateName;
    private String templateFileName;
    private String templateVersion;
    private String parsedStatus;
    private String isActive;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long placeholderCount;
    private Long imageCount;
    private Long dateCount;
    private Long textCount;

    public TemplateResponse() {
    }

    private TemplateResponse(Builder b) {
        this.templateId = b.templateId;
        this.bankName = b.bankName;
        this.templateName = b.templateName;
        this.templateFileName = b.templateFileName;
        this.templateVersion = b.templateVersion;
        this.parsedStatus = b.parsedStatus;
        this.isActive = b.isActive;
        this.createdBy = b.createdBy;
        this.createdAt = b.createdAt;
        this.updatedAt = b.updatedAt;
        this.placeholderCount = b.placeholderCount;
        this.imageCount = b.imageCount;
        this.dateCount = b.dateCount;
        this.textCount = b.textCount;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long templateId;
        private String bankName;
        private String templateName;
        private String templateFileName;
        private String templateVersion;
        private String parsedStatus;
        private String isActive;
        private String createdBy;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        private Long placeholderCount;
        private Long imageCount;
        private Long dateCount;
        private Long textCount;

        public Builder templateId(Long v) {
            this.templateId = v;
            return this;
        }

        public Builder bankName(String v) {
            this.bankName = v;
            return this;
        }

        public Builder templateName(String v) {
            this.templateName = v;
            return this;
        }

        public Builder templateFileName(String v) {
            this.templateFileName = v;
            return this;
        }

        public Builder templateVersion(String v) {
            this.templateVersion = v;
            return this;
        }

        public Builder parsedStatus(String v) {
            this.parsedStatus = v;
            return this;
        }

        public Builder isActive(String v) {
            this.isActive = v;
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

        public Builder placeholderCount(Long v) {
            this.placeholderCount = v;
            return this;
        }

        public Builder imageCount(Long v) {
            this.imageCount = v;
            return this;
        }

        public Builder dateCount(Long v) {
            this.dateCount = v;
            return this;
        }

        public Builder textCount(Long v) {
            this.textCount = v;
            return this;
        }

        public TemplateResponse build() {
            return new TemplateResponse(this);
        }
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getTemplateName() {
        return templateName;
    }

    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }

    public String getTemplateFileName() {
        return templateFileName;
    }

    public void setTemplateFileName(String templateFileName) {
        this.templateFileName = templateFileName;
    }

    public String getTemplateVersion() {
        return templateVersion;
    }

    public void setTemplateVersion(String templateVersion) {
        this.templateVersion = templateVersion;
    }

    public String getParsedStatus() {
        return parsedStatus;
    }

    public void setParsedStatus(String parsedStatus) {
        this.parsedStatus = parsedStatus;
    }

    public String getIsActive() {
        return isActive;
    }

    public void setIsActive(String isActive) {
        this.isActive = isActive;
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

    public Long getPlaceholderCount() {
        return placeholderCount;
    }

    public void setPlaceholderCount(Long placeholderCount) {
        this.placeholderCount = placeholderCount;
    }

    public Long getImageCount() {
        return imageCount;
    }

    public void setImageCount(Long imageCount) {
        this.imageCount = imageCount;
    }

    public Long getDateCount() {
        return dateCount;
    }

    public void setDateCount(Long dateCount) {
        this.dateCount = dateCount;
    }

    public Long getTextCount() {
        return textCount;
    }

    public void setTextCount(Long textCount) {
        this.textCount = textCount;
    }
}
