package com.bwvr.backend.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "BWVR_REPORT", schema = "BWVR")
public class BwvrReport {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "reportSeq")
    @SequenceGenerator(name = "reportSeq", sequenceName = "BWVR.SEQ_REPORT_ID", allocationSize = 1)
    @Column(name = "REPORT_ID")
    private Long reportId;

    @Column(name = "REFERENCE_NUMBER", nullable = false, unique = true, length = 30)
    private String referenceNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "TEMPLATE_ID", nullable = false)
    private BwvrTemplate template;

    @Column(name = "REPORT_TITLE", nullable = false, length = 500)
    private String reportTitle;

    @Column(name = "VENDOR_NAME", length = 300)
    private String vendorName;

    @Column(name = "LOCATION", length = 300)
    private String location;

    @Column(name = "BANK_NAME", length = 200)
    private String bankName;

    @Column(name = "REPORT_STATUS", length = 30)
    private String reportStatus = "DRAFT";

    @Column(name = "GENERATED_FILE_PATH", length = 1000)
    private String generatedFilePath;

    @Column(name = "GENERATED_AT")
    private LocalDateTime generatedAt;

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

    @Column(name = "IS_DELETED", length = 1)
    private String isDeleted = "N";

    @Column(name = "DELETED_AT")
    private LocalDateTime deletedAt;

    @Column(name = "DELETED_BY", length = 100)
    private String deletedBy;

    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BwvrReportValue> reportValues;

    public BwvrReport() {
    }

    private BwvrReport(Builder b) {
        this.reportId = b.reportId;
        this.referenceNumber = b.referenceNumber;
        this.template = b.template;
        this.reportTitle = b.reportTitle;
        this.vendorName = b.vendorName;
        this.location = b.location;
        this.bankName = b.bankName;
        this.reportStatus = b.reportStatus != null ? b.reportStatus : "DRAFT";
        this.generatedFilePath = b.generatedFilePath;
        this.generatedAt = b.generatedAt;
        this.createdBy = b.createdBy;
        this.createdAt = b.createdAt;
        this.updatedBy = b.updatedBy;
        this.updatedAt = b.updatedAt;
        this.isDeleted = b.isDeleted != null ? b.isDeleted : "N";
        this.deletedAt = b.deletedAt;
        this.deletedBy = b.deletedBy;
        this.reportValues = b.reportValues;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long reportId;
        private String referenceNumber;
        private BwvrTemplate template;
        private String reportTitle;
        private String vendorName;
        private String location;
        private String bankName;
        private String reportStatus = "DRAFT";
        private String generatedFilePath;
        private LocalDateTime generatedAt;
        private String createdBy;
        private LocalDateTime createdAt;
        private String updatedBy;
        private LocalDateTime updatedAt;
        private String isDeleted = "N";
        private LocalDateTime deletedAt;
        private String deletedBy;
        private List<BwvrReportValue> reportValues;

        public Builder reportId(Long v) {
            this.reportId = v;
            return this;
        }

        public Builder referenceNumber(String v) {
            this.referenceNumber = v;
            return this;
        }

        public Builder template(BwvrTemplate v) {
            this.template = v;
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

        public Builder generatedFilePath(String v) {
            this.generatedFilePath = v;
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

        public Builder isDeleted(String v) {
            this.isDeleted = v;
            return this;
        }

        public Builder deletedAt(LocalDateTime v) {
            this.deletedAt = v;
            return this;
        }

        public Builder deletedBy(String v) {
            this.deletedBy = v;
            return this;
        }

        public Builder reportValues(List<BwvrReportValue> v) {
            this.reportValues = v;
            return this;
        }

        public BwvrReport build() {
            return new BwvrReport(this);
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

    public BwvrTemplate getTemplate() {
        return template;
    }

    public void setTemplate(BwvrTemplate template) {
        this.template = template;
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

    public String getGeneratedFilePath() {
        return generatedFilePath;
    }

    public void setGeneratedFilePath(String generatedFilePath) {
        this.generatedFilePath = generatedFilePath;
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

    public String getIsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(String isDeleted) {
        this.isDeleted = isDeleted;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public String getDeletedBy() {
        return deletedBy;
    }

    public void setDeletedBy(String deletedBy) {
        this.deletedBy = deletedBy;
    }

    public List<BwvrReportValue> getReportValues() {
        return reportValues;
    }

    public void setReportValues(List<BwvrReportValue> reportValues) {
        this.reportValues = reportValues;
    }
}
