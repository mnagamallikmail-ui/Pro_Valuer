package com.bwvr.backend.dto.request;

import java.util.List;

public class SaveReportValuesRequest {

    private List<PlaceholderValueDto> values;
    private String updatedBy;

    public SaveReportValuesRequest() {
    }

    public List<PlaceholderValueDto> getValues() {
        return values;
    }

    public void setValues(List<PlaceholderValueDto> values) {
        this.values = values;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }
}
