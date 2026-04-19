package com.bwvr.backend.dto.response;

import java.time.LocalDateTime;
import java.util.List;

public class ReportDetailResponse {

    private Long reportId;
    private String referenceNumber;
    private Long templateId;
    private String templateName;
    private String templateFileName;
    private String reportTitle;
    private String vendorName;
    private String location;
    private String bankName;
    private String reportStatus;
    private LocalDateTime generatedAt;
    private String createdBy;
    private LocalDateTime createdAt;
    private String updatedBy;
    private LocalDateTime updatedAt;
    private boolean hasGeneratedFile;
    private List<ReportValueResponse> values;
    private List<PlaceholderResponse> allPlaceholders;

    public ReportDetailResponse() {
    }

    private ReportDetailResponse(Builder b) {
        this.reportId = b.reportId;
        this.referenceNumber = b.referenceNumber;
        this.templateId = b.templateId;
        this.templateName = b.templateName;
        this.templateFileName = b.templateFileName;
        this.reportTitle = b.reportTitle;
        this.vendorName = b.vendorName;
        this.location = b.location;
        this.bankName = b.bankName;
        this.reportStatus = b.reportStatus;
        this.generatedAt = b.generatedAt;
        this.createdBy = b.createdBy;
        this.createdAt = b.createdAt;
        this.updatedBy = b.updatedBy;
        this.updatedAt = b.updatedAt;
        this.hasGeneratedFile = b.hasGeneratedFile;
        this.values = b.values;
        this.allPlaceholders = b.allPlaceholders;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long reportId;
        private String referenceNumber;
        private Long templateId;
        private String templateName;
        private String templateFileName;
        private String reportTitle;
        private String vendorName;
        private String location;
        private String bankName;
        private String reportStatus;
        private LocalDateTime generatedAt;
        private String createdBy;
        private LocalDateTime createdAt;
        private String updatedBy;
        private LocalDateTime updatedAt;
        private boolean hasGeneratedFile;
        private List<ReportValueResponse> values;
        private List<PlaceholderResponse> allPlaceholders;

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

        public Builder templateFileName(String v) {
            this.templateFileName = v;
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

        public Builder updatedBy(String v) {
            this.updatedBy = v;
            return this;
        }

        public Builder updatedAt(LocalDateTime v) {
            this.updatedAt = v;
            return this;
        }

        public Builder hasGeneratedFile(boolean v) {
            this.hasGeneratedFile = v;
            return this;
        }

        public Builder values(List<ReportValueResponse> v) {
            this.values = v;
            return this;
        }

        public Builder allPlaceholders(List<PlaceholderResponse> v) {
            this.allPlaceholders = v;
            return this;
        }

        public ReportDetailResponse build() {
            return new ReportDetailResponse(this);
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

    public String getTemplateFileName() {
        return templateFileName;
    }

    public void setTemplateFileName(String templateFileName) {
        this.templateFileName = templateFileName;
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

    public boolean isHasGeneratedFile() {
        return hasGeneratedFile;
    }

    public void setHasGeneratedFile(boolean hasGeneratedFile) {
        this.hasGeneratedFile = hasGeneratedFile;
    }

    public List<ReportValueResponse> getValues() {
        return values;
    }

    public void setValues(List<ReportValueResponse> values) {
        this.values = values;
    }

    public List<PlaceholderResponse> getAllPlaceholders() {
        return allPlaceholders;
    }

    public void setAllPlaceholders(List<PlaceholderResponse> allPlaceholders) {
        this.allPlaceholders = allPlaceholders;
    }

    public static class ReportValueResponse {

        private Long valueId;
        private Long placeholderId;
        private String placeholderKey;
        private String placeholderPrefix;
        private String displayLabel;
        private String questionText;
        private String fieldType;
        private String textValue;
        private String imageFilePath;
        private String imageOriginalName;
        private Integer displayOrder;
        private String tableContext;
        private String col1Header;
        private String col2Header;
        private boolean hasImageData;

        public ReportValueResponse() {
        }

        private ReportValueResponse(Builder b) {
            this.valueId = b.valueId;
            this.placeholderId = b.placeholderId;
            this.placeholderKey = b.placeholderKey;
            this.placeholderPrefix = b.placeholderPrefix;
            this.displayLabel = b.displayLabel;
            this.questionText = b.questionText;
            this.fieldType = b.fieldType;
            this.textValue = b.textValue;
            this.imageFilePath = b.imageFilePath;
            this.imageOriginalName = b.imageOriginalName;
            this.displayOrder = b.displayOrder;
            this.tableContext = b.tableContext;
            this.col1Header = b.col1Header;
            this.col2Header = b.col2Header;
            this.hasImageData = b.hasImageData;
        }

        public static Builder builder() {
            return new Builder();
        }

        public static class Builder {

            private Long valueId;
            private Long placeholderId;
            private String placeholderKey;
            private String placeholderPrefix;
            private String displayLabel;
            private String questionText;
            private String fieldType;
            private String textValue;
            private String imageFilePath;
            private String imageOriginalName;
            private Integer displayOrder;
            private String tableContext;
            private String col1Header;
            private String col2Header;
            private boolean hasImageData;

            public Builder valueId(Long v) {
                this.valueId = v;
                return this;
            }

            public Builder placeholderId(Long v) {
                this.placeholderId = v;
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

            public Builder hasImageData(boolean v) {
                this.hasImageData = v;
                return this;
            }

            public ReportValueResponse build() {
                return new ReportValueResponse(this);
            }
        }

        public Long getValueId() {
            return valueId;
        }

        public void setValueId(Long valueId) {
            this.valueId = valueId;
        }

        public Long getPlaceholderId() {
            return placeholderId;
        }

        public void setPlaceholderId(Long placeholderId) {
            this.placeholderId = placeholderId;
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

        public boolean isHasImageData() {
            return hasImageData;
        }

        public void setHasImageData(boolean hasImageData) {
            this.hasImageData = hasImageData;
        }
    }
}
