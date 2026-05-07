package com.bwvr.backend.dto.response;

import java.time.LocalDateTime;

public class PlaceholderResponse {

    private Long placeholderId;
    private Long templateId;
    private String placeholderKey;
    private String placeholderPrefix;
    private String displayLabel;
    private String questionText;
    private String fieldType;
    private String sectionName;
    private String isRequired;
    private Integer displayOrder;
    private String tableContext;
    private String col1Header;
    private String col2Header;
    private String isConfirmed;
    private LocalDateTime createdAt;

    // Image slot info (populated for IMG types)
    private Double widthInches;
    private Double heightInches;
    private Long widthEmu;
    private Long heightEmu;
    private String pagePosition;

    public PlaceholderResponse() {
    }

    private PlaceholderResponse(Builder b) {
        this.placeholderId = b.placeholderId;
        this.templateId = b.templateId;
        this.placeholderKey = b.placeholderKey;
        this.placeholderPrefix = b.placeholderPrefix;
        this.displayLabel = b.displayLabel;
        this.questionText = b.questionText;
        this.fieldType = b.fieldType;
        this.sectionName = b.sectionName;
        this.isRequired = b.isRequired;
        this.displayOrder = b.displayOrder;
        this.tableContext = b.tableContext;
        this.col1Header = b.col1Header;
        this.col2Header = b.col2Header;
        this.isConfirmed = b.isConfirmed;
        this.createdAt = b.createdAt;
        this.widthInches = b.widthInches;
        this.heightInches = b.heightInches;
        this.widthEmu = b.widthEmu;
        this.heightEmu = b.heightEmu;
        this.pagePosition = b.pagePosition;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long placeholderId;
        private Long templateId;
        private String placeholderKey;
        private String placeholderPrefix;
        private String displayLabel;
        private String questionText;
        private String fieldType;
        private String sectionName;
        private String isRequired;
        private Integer displayOrder;
        private String tableContext;
        private String col1Header;
        private String col2Header;
        private String isConfirmed;
        private LocalDateTime createdAt;
        private Double widthInches;
        private Double heightInches;
        private Long widthEmu;
        private Long heightEmu;
        private String pagePosition;

        public Builder placeholderId(Long v) {
            this.placeholderId = v;
            return this;
        }

        public Builder templateId(Long v) {
            this.templateId = v;
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

        public Builder sectionName(String v) {
            this.sectionName = v;
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

        public Builder createdAt(LocalDateTime v) {
            this.createdAt = v;
            return this;
        }

        public Builder widthInches(Double v) {
            this.widthInches = v;
            return this;
        }

        public Builder heightInches(Double v) {
            this.heightInches = v;
            return this;
        }

        public Builder widthEmu(Long v) {
            this.widthEmu = v;
            return this;
        }

        public Builder heightEmu(Long v) {
            this.heightEmu = v;
            return this;
        }

        public Builder pagePosition(String v) {
            this.pagePosition = v;
            return this;
        }

        public PlaceholderResponse build() {
            return new PlaceholderResponse(this);
        }
    }

    public Long getPlaceholderId() {
        return placeholderId;
    }

    public void setPlaceholderId(Long placeholderId) {
        this.placeholderId = placeholderId;
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
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

    public String getSectionName() {
        return sectionName;
    }

    public void setSectionName(String sectionName) {
        this.sectionName = sectionName;
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Double getWidthInches() {
        return widthInches;
    }

    public void setWidthInches(Double widthInches) {
        this.widthInches = widthInches;
    }

    public Double getHeightInches() {
        return heightInches;
    }

    public void setHeightInches(Double heightInches) {
        this.heightInches = heightInches;
    }

    public Long getWidthEmu() {
        return widthEmu;
    }

    public void setWidthEmu(Long widthEmu) {
        this.widthEmu = widthEmu;
    }

    public Long getHeightEmu() {
        return heightEmu;
    }

    public void setHeightEmu(Long heightEmu) {
        this.heightEmu = heightEmu;
    }

    public String getPagePosition() {
        return pagePosition;
    }

    public void setPagePosition(String pagePosition) {
        this.pagePosition = pagePosition;
    }
}
