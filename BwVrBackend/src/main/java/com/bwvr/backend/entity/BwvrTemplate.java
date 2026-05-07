package com.bwvr.backend.entity;

import java.time.LocalDateTime;
import java.util.List;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "BWVR_TEMPLATE", schema = "bwvr",
        uniqueConstraints = @UniqueConstraint(columnNames = {"BANK_NAME", "TEMPLATE_NAME"}))
public class BwvrTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "TEMPLATE_ID")
    private Long templateId;

    @Column(name = "BANK_NAME", nullable = false, length = 200)
    private String bankName;

    @Column(name = "TEMPLATE_NAME", nullable = false, length = 300)
    private String templateName;

    @Column(name = "TEMPLATE_FILE_NAME", nullable = false, length = 500)
    private String templateFileName;

    @Column(name = "TEMPLATE_FILE_PATH", nullable = false, length = 1000)
    private String templateFilePath;

    @Column(name = "TEMPLATE_VERSION", length = 20)
    private String templateVersion = "1.0";

    @Column(name = "IS_ACTIVE", length = 1)
    private String isActive = "Y";

    @Column(name = "PARSED_STATUS", length = 20)
    private String parsedStatus = "PENDING";

    @Column(name = "CREATED_BY", nullable = false, length = 100)
    private String createdBy;

    @CreationTimestamp
    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "UPDATED_BY", length = 100)
    private String updatedBy;

    @UpdateTimestamp
    @Column(name = "UPDATED_AT")
    private LocalDateTime updatedAt;

    @Column(name = "TEMPLATE_CONTENT", columnDefinition = "bytea")
    private byte[] templateContent;

    @OneToMany(mappedBy = "template", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BwvrTemplatePlaceholder> placeholders;

    @OneToMany(mappedBy = "template", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BwvrTemplateImageSlot> imageSlots;

    public BwvrTemplate() {
    }

    private BwvrTemplate(Builder b) {
        this.templateId = b.templateId;
        this.bankName = b.bankName;
        this.templateName = b.templateName;
        this.templateFileName = b.templateFileName;
        this.templateFilePath = b.templateFilePath;
        this.templateVersion = b.templateVersion != null ? b.templateVersion : "1.0";
        this.isActive = b.isActive != null ? b.isActive : "Y";
        this.parsedStatus = b.parsedStatus != null ? b.parsedStatus : "PENDING";
        this.createdBy = b.createdBy;
        this.createdAt = b.createdAt;
        this.updatedBy = b.updatedBy;
        this.updatedAt = b.updatedAt;
        this.templateContent = b.templateContent;
        this.placeholders = b.placeholders;
        this.imageSlots = b.imageSlots;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long templateId;
        private String bankName;
        private String templateName;
        private String templateFileName;
        private String templateFilePath;
        private String templateVersion = "1.0";
        private String isActive = "Y";
        private String parsedStatus = "PENDING";
        private String createdBy;
        private LocalDateTime createdAt;
        private String updatedBy;
        private LocalDateTime updatedAt;
        private byte[] templateContent;
        private List<BwvrTemplatePlaceholder> placeholders;
        private List<BwvrTemplateImageSlot> imageSlots;

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

        public Builder templateFilePath(String v) {
            this.templateFilePath = v;
            return this;
        }

        public Builder templateVersion(String v) {
            this.templateVersion = v;
            return this;
        }

        public Builder isActive(String v) {
            this.isActive = v;
            return this;
        }

        public Builder parsedStatus(String v) {
            this.parsedStatus = v;
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

        public Builder updatedBy(String v) {
            this.updatedBy = v;
            return this;
        }

        public Builder updatedAt(LocalDateTime v) {
            this.updatedAt = v;
            return this;
        }

        public Builder templateContent(byte[] v) {
            this.templateContent = v;
            return this;
        }

        public Builder placeholders(List<BwvrTemplatePlaceholder> v) {
            this.placeholders = v;
            return this;
        }

        public Builder imageSlots(List<BwvrTemplateImageSlot> v) {
            this.imageSlots = v;
            return this;
        }

        public BwvrTemplate build() {
            return new BwvrTemplate(this);
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

    public String getTemplateFilePath() {
        return templateFilePath;
    }

    public void setTemplateFilePath(String templateFilePath) {
        this.templateFilePath = templateFilePath;
    }

    public String getTemplateVersion() {
        return templateVersion;
    }

    public void setTemplateVersion(String templateVersion) {
        this.templateVersion = templateVersion;
    }

    public String getIsActive() {
        return isActive;
    }

    public void setIsActive(String isActive) {
        this.isActive = isActive;
    }

    public String getParsedStatus() {
        return parsedStatus;
    }

    public void setParsedStatus(String parsedStatus) {
        this.parsedStatus = parsedStatus;
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

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public byte[] getTemplateContent() {
        return templateContent;
    }

    public void setTemplateContent(byte[] templateContent) {
        this.templateContent = templateContent;
    }

    public List<BwvrTemplatePlaceholder> getPlaceholders() {
        return placeholders;
    }

    public void setPlaceholders(List<BwvrTemplatePlaceholder> placeholders) {
        this.placeholders = placeholders;
    }

    public List<BwvrTemplateImageSlot> getImageSlots() {
        return imageSlots;
    }

    public void setImageSlots(List<BwvrTemplateImageSlot> imageSlots) {
        this.imageSlots = imageSlots;
    }
}
