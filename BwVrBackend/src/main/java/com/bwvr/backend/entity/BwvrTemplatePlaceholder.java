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
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "BWVR_TEMPLATE_PLACEHOLDER", schema = "BWVR")
public class BwvrTemplatePlaceholder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PLACEHOLDER_ID")
    private Long placeholderId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "TEMPLATE_ID", nullable = false)
    private BwvrTemplate template;

    @Column(name = "PLACEHOLDER_KEY", nullable = false, length = 300)
    private String placeholderKey;

    @Column(name = "PLACEHOLDER_PREFIX", nullable = false, length = 20)
    private String placeholderPrefix;

    @Column(name = "DISPLAY_LABEL", nullable = false, length = 500)
    private String displayLabel;

    @Column(name = "QUESTION_TEXT", nullable = false, length = 1000)
    private String questionText;

    @Column(name = "FIELD_TYPE", nullable = false, length = 50)
    private String fieldType;

    @Column(name = "IS_REQUIRED", length = 1)
    private String isRequired = "Y";

    @Column(name = "DISPLAY_ORDER")
    private Integer displayOrder;

    @Column(name = "TABLE_CONTEXT", length = 500)
    private String tableContext;

    @Column(name = "COL1_HEADER", length = 500)
    private String col1Header;

    @Column(name = "COL2_HEADER", length = 500)
    private String col2Header;

    @Column(name = "IS_CONFIRMED", length = 1)
    private String isConfirmed = "N";

    @Column(name = "SECTION_NAME", length = 500)
    private String sectionName;

    @CreationTimestamp
    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    public BwvrTemplatePlaceholder() {
    }

    private BwvrTemplatePlaceholder(Builder b) {
        this.placeholderId = b.placeholderId;
        this.template = b.template;
        this.placeholderKey = b.placeholderKey;
        this.placeholderPrefix = b.placeholderPrefix;
        this.displayLabel = b.displayLabel;
        this.questionText = b.questionText;
        this.fieldType = b.fieldType;
        this.isRequired = b.isRequired != null ? b.isRequired : "Y";
        this.displayOrder = b.displayOrder;
        this.tableContext = b.tableContext;
        this.col1Header = b.col1Header;
        this.col2Header = b.col2Header;
        this.isConfirmed = b.isConfirmed != null ? b.isConfirmed : "N";
        this.sectionName = b.sectionName;
        this.createdAt = b.createdAt;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long placeholderId;
        private BwvrTemplate template;
        private String placeholderKey;
        private String placeholderPrefix;
        private String displayLabel;
        private String questionText;
        private String fieldType;
        private String isRequired = "Y";
        private Integer displayOrder;
        private String tableContext;
        private String col1Header;
        private String col2Header;
        private String isConfirmed = "N";
        private String sectionName;
        private LocalDateTime createdAt;

        public Builder placeholderId(Long v) {
            this.placeholderId = v;
            return this;
        }

        public Builder template(BwvrTemplate v) {
            this.template = v;
            return this;
        }

        public Builder placeholderKey(String v) {
            this.placeholderKey = v;
            return this;
        }

        public Builder placeholderPrefix(String v) {
            this.placeholderPrefix = v;
            return this;
        }

        public Builder displayLabel(String v) {
            this.displayLabel = v;
            return this;
        }

        public Builder questionText(String v) {
            this.questionText = v;
            return this;
        }

        public Builder fieldType(String v) {
            this.fieldType = v;
            return this;
        }

        public Builder isRequired(String v) {
            this.isRequired = v;
            return this;
        }

        public Builder displayOrder(Integer v) {
            this.displayOrder = v;
            return this;
        }

        public Builder tableContext(String v) {
            this.tableContext = v;
            return this;
        }

        public Builder col1Header(String v) {
            this.col1Header = v;
            return this;
        }

        public Builder col2Header(String v) {
            this.col2Header = v;
            return this;
        }

        public Builder isConfirmed(String v) {
            this.isConfirmed = v;
            return this;
        }

        public Builder sectionName(String v) {
            this.sectionName = v;
            return this;
        }

        public Builder createdAt(LocalDateTime v) {
            this.createdAt = v;
            return this;
        }

        public BwvrTemplatePlaceholder build() {
            return new BwvrTemplatePlaceholder(this);
        }
    }

    public Long getPlaceholderId() {
        return placeholderId;
    }

    public void setPlaceholderId(Long placeholderId) {
        this.placeholderId = placeholderId;
    }

    public BwvrTemplate getTemplate() {
        return template;
    }

    public void setTemplate(BwvrTemplate template) {
        this.template = template;
    }

    public String getPlaceholderKey() {
        return placeholderKey;
    }

    public void setPlaceholderKey(String placeholderKey) {
        this.placeholderKey = placeholderKey;
    }

    public String getPlaceholderPrefix() {
        return placeholderPrefix;
    }

    public void setPlaceholderPrefix(String placeholderPrefix) {
        this.placeholderPrefix = placeholderPrefix;
    }

    public String getDisplayLabel() {
        return displayLabel;
    }

    public void setDisplayLabel(String displayLabel) {
        this.displayLabel = displayLabel;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public String getFieldType() {
        return fieldType;
    }

    public void setFieldType(String fieldType) {
        this.fieldType = fieldType;
    }

    public String getIsRequired() {
        return isRequired;
    }

    public void setIsRequired(String isRequired) {
        this.isRequired = isRequired;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    public String getTableContext() {
        return tableContext;
    }

    public void setTableContext(String tableContext) {
        this.tableContext = tableContext;
    }

    public String getCol1Header() {
        return col1Header;
    }

    public void setCol1Header(String col1Header) {
        this.col1Header = col1Header;
    }

    public String getCol2Header() {
        return col2Header;
    }

    public void setCol2Header(String col2Header) {
        this.col2Header = col2Header;
    }

    public String getIsConfirmed() {
        return isConfirmed;
    }

    public void setIsConfirmed(String isConfirmed) {
        this.isConfirmed = isConfirmed;
    }

    public String getSectionName() {
        return sectionName;
    }

    public void setSectionName(String sectionName) {
        this.sectionName = sectionName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
