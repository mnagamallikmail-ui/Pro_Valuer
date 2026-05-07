package com.bwvr.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bwvr.backend.entity.BwvrAuditLog;

@Repository
public interface AuditLogRepository extends JpaRepository<BwvrAuditLog, Long> {

    List<BwvrAuditLog> findByEntityTypeAndEntityIdOrderByPerformedAtDesc(String entityType, Long entityId);
}
