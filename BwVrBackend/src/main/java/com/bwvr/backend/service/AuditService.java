package com.bwvr.backend.service;

import com.bwvr.backend.entity.BwvrAuditLog;
import com.bwvr.backend.repository.AuditLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
@SuppressWarnings("null")
public class AuditService {

    private final AuditLogRepository auditLogRepository;

    public AuditService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void log(String entityType, Long entityId, String action,
                    String performedBy, String oldJson, String newJson,
                    String ipAddress, String remarks) {
        try {
            BwvrAuditLog log = BwvrAuditLog.builder()
                .entityType(entityType)
                .entityId(entityId)
                .action(action)
                .performedBy(performedBy != null ? performedBy : "SYSTEM")
                .oldValueJson(oldJson)
                .newValueJson(newJson)
                .ipAddress(ipAddress)
                .remarks(remarks)
                .build();
            auditLogRepository.save(log);
        } catch (Exception e) {
            // Audit log failure must never crash the main business operation
            org.slf4j.LoggerFactory.getLogger(AuditService.class)
                .warn("Audit log failed (non-fatal): {}", e.getMessage());
        }
    }
}
