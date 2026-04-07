package com.bwvr.backend.dto.request;

import java.util.List;

public class ConfirmPlaceholdersRequest {

    private List<PlaceholderUpdateDto> placeholders;
    private String confirmedBy;

    public ConfirmPlaceholdersRequest() {
    }

    public List<PlaceholderUpdateDto> getPlaceholders() {
        return placeholders;
    }

    public void setPlaceholders(List<PlaceholderUpdateDto> placeholders) {
        this.placeholders = placeholders;
    }

    public String getConfirmedBy() {
        return confirmedBy;
    }

    public void setConfirmedBy(String confirmedBy) {
        this.confirmedBy = confirmedBy;
    }

    public static class PlaceholderUpdateDto {

        private Long placeholderId;
        private String questionText;
        private String displayLabel;
        private String fieldType;
        private Boolean isRequired;

        public PlaceholderUpdateDto() {
        }

        public Long getPlaceholderId() {
            return placeholderId;
        }

        public void setPlaceholderId(Long placeholderId) {
            this.placeholderId = placeholderId;
        }

        public String getQuestionText() {
            return questionText;
        }

        public void setQuestionText(String questionText) {
            this.questionText = questionText;
        }

        public String getDisplayLabel() {
            return displayLabel;
        }

        public void setDisplayLabel(String displayLabel) {
            this.displayLabel = displayLabel;
        }

        public String getFieldType() {
            return fieldType;
        }

        public void setFieldType(String fieldType) {
            this.fieldType = fieldType;
        }

        public Boolean getIsRequired() {
            return isRequired;
        }

        public void setIsRequired(Boolean isRequired) {
            this.isRequired = isRequired;
        }
    }
}
