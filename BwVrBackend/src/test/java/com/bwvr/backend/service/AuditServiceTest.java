package com.bwvr.backend.service;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.verify;
import org.mockito.junit.jupiter.MockitoExtension;

import com.bwvr.backend.entity.BwvrAuditLog;
import com.bwvr.backend.repository.AuditLogRepository;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class AuditServiceTest {

    @Mock
    private AuditLogRepository auditLogRepository;

    @InjectMocks
    private AuditService auditService;

    @Test
    void log_savesCorrectFields() {
        auditService.log("REPORT", 42L, "CREATE", "user1",
                "{\"old\":1}", "{\"new\":2}", "127.0.0.1", "Test remark");

        ArgumentCaptor<BwvrAuditLog> captor = ArgumentCaptor.forClass(BwvrAuditLog.class);
        verify(auditLogRepository).save(captor.capture());

        BwvrAuditLog saved = captor.getValue();
        assertThat(saved.getEntityType()).isEqualTo("REPORT");
        assertThat(saved.getEntityId()).isEqualTo(42L);
        assertThat(saved.getAction()).isEqualTo("CREATE");
        assertThat(saved.getPerformedBy()).isEqualTo("user1");
        assertThat(saved.getOldValueJson()).isEqualTo("{\"old\":1}");
        assertThat(saved.getNewValueJson()).isEqualTo("{\"new\":2}");
        assertThat(saved.getIpAddress()).isEqualTo("127.0.0.1");
        assertThat(saved.getRemarks()).isEqualTo("Test remark");
    }

    @Test
    void log_nullPerformedBy_defaultsToSYSTEM() {
        auditService.log("TEMPLATE", 1L, "DELETE", null, null, null, null, "Deleted");

        ArgumentCaptor<BwvrAuditLog> captor = ArgumentCaptor.forClass(BwvrAuditLog.class);
        verify(auditLogRepository).save(captor.capture());

        assertThat(captor.getValue().getPerformedBy()).isEqualTo("SYSTEM");
    }

    @Test
    void log_allNullOptionalFields_doesNotThrow() {
        auditService.log("REPORT", 99L, "UPDATE", "admin", null, null, null, null);
        ArgumentCaptor<BwvrAuditLog> captor = ArgumentCaptor.forClass(BwvrAuditLog.class);
        verify(auditLogRepository).save(captor.capture());
        assertThat(captor.getValue().getOldValueJson()).isNull();
        assertThat(captor.getValue().getNewValueJson()).isNull();
    }
}
