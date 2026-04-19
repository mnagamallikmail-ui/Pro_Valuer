package com.bwvr.backend.dto.request;

import jakarta.validation.constraints.NotNull;

public class CreateReportRequest {

    @NotNull(message = "Template ID is required")
    private Long templateId;

    @NotNull(message = "Report title is required")
    private String reportTitle;

    private String vendorName;
    private String location;
    private String createdBy;

    public CreateReportRequest() {
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
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

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }
}
