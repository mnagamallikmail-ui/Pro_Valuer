package com.bwvr.backend.dto.request;

public class PlaceholderValueDto {

    private Long placeholderId;
    private String placeholderKey;
    private String textValue;
    private String imageFilePath;
    private String imageOriginalName;

    public PlaceholderValueDto() {
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
}
