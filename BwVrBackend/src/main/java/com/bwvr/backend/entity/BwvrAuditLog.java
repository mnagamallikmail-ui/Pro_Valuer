package com.bwvr.backend.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "BWVR_AUDIT_LOG", schema = "BWVR")
public class BwvrAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AUDIT_ID")
    private Long auditId;

    @Column(name = "ENTITY_TYPE", nullable = false, length = 50)
    private String entityType;

    @Column(name = "ENTITY_ID", nullable = false)
    private Long entityId;

    @Column(name = "ACTION", nullable = false, length = 50)
    private String action;

    @Column(name = "PERFORMED_BY", nullable = false, length = 100)
    private String performedBy;

    @CreationTimestamp
    @Column(name = "PERFORMED_AT", updatable = false)
    private LocalDateTime performedAt;

    @Lob
    @Column(name = "OLD_VALUE_JSON", columnDefinition = "TEXT")
    private String oldValueJson;

    @Lob
    @Column(name = "NEW_VALUE_JSON", columnDefinition = "TEXT")
    private String newValueJson;

    @Column(name = "IP_ADDRESS", length = 50)
    private String ipAddress;

    @Column(name = "REMARKS", length = 1000)
    private String remarks;

    public BwvrAuditLog() {
    }

    private BwvrAuditLog(Builder b) {
        this.auditId = b.auditId;
        this.entityType = b.entityType;
        this.entityId = b.entityId;
        this.action = b.action;
        this.performedBy = b.performedBy;
        this.performedAt = b.performedAt;
        this.oldValueJson = b.oldValueJson;
        this.newValueJson = b.newValueJson;
        this.ipAddress = b.ipAddress;
        this.remarks = b.remarks;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long auditId;
        private String entityType;
        private Long entityId;
        private String action;
        private String performedBy;
        private LocalDateTime performedAt;
        private String oldValueJson;
        private String newValueJson;
        private String ipAddress;
        private String remarks;

        public Builder auditId(Long v) {
            this.auditId = v;
            return this;
        }

        public Builder entityType(String v) {
            this.entityType = v;
            return this;
        }

        public Builder entityId(Long v) {
            this.entityId = v;
            return this;
        }

        public Builder action(String v) {
            this.action = v;
            return this;
        }

        public Builder performedBy(String v) {
            this.performedBy = v;
            return this;
        }

        public Builder performedAt(LocalDateTime v) {
            this.performedAt = v;
            return this;
        }

        public Builder oldValueJson(String v) {
            this.oldValueJson = v;
            return this;
        }

        public Builder newValueJson(String v) {
            this.newValueJson = v;
            return this;
        }

        public Builder ipAddress(String v) {
            this.ipAddress = v;
            return this;
        }

        public Builder remarks(String v) {
            this.remarks = v;
            return this;
        }

        public BwvrAuditLog build() {
            return new BwvrAuditLog(this);
        }
    }

    public Long getAuditId() {
        return auditId;
    }

    public void setAuditId(Long auditId) {
        this.auditId = auditId;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public Long getEntityId() {
        return entityId;
    }

    public void setEntityId(Long entityId) {
        this.entityId = entityId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getPerformedBy() {
        return performedBy;
    }

    public void setPerformedBy(String performedBy) {
        this.performedBy = performedBy;
    }

    public LocalDateTime getPerformedAt() {
        return performedAt;
    }

    public void setPerformedAt(LocalDateTime performedAt) {
        this.performedAt = performedAt;
    }

    public String getOldValueJson() {
        return oldValueJson;
    }

    public void setOldValueJson(String oldValueJson) {
        this.oldValueJson = oldValueJson;
    }

    public String getNewValueJson() {
        return newValueJson;
    }

    public void setNewValueJson(String newValueJson) {
        this.newValueJson = newValueJson;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
}
