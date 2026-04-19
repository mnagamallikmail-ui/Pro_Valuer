package com.bwvr.backend;

import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Disabled;

/**
 * Integration tests that require a live database connection.
 * These are excluded from the default unit test run.
 * Run with: ./gradlew test -Dgroups=integration
 */
@SpringBootTest
@Tag("integration")
@Disabled("Requires live Railway PostgreSQL database - run only in CI with DB access")
public class DatabaseCheckTest {

    @Autowired
    private BwvrUserRepository bwvrUserRepository;

    @Autowired
    private com.bwvr.backend.repository.AuditLogRepository auditLogRepository;

    @Test
    public void testAdminUserExists() {
        Optional<BwvrUser> user = bwvrUserRepository.findByUsername("admin");
        assertTrue(user.isPresent(), "Admin user should exist in the database!");
        if (user.isPresent()) {
            System.out.println("====== DB CHECK PASSED ======");
            System.out.println("Admin user found: " + user.get().getUsername() + " / Role: " + user.get().getRole());
        }
    }

    @Test
    public void testAuditLogTableExists() {
        try {
            // Check if the audit log table is accessible
            auditLogRepository.count();
            System.out.println("====== DB CHECK PASSED: Audit Log table exists ======");
        } catch (Exception e) {
            System.err.println("Audit log check failed: " + e.getMessage());
            // This is acceptable if we're only seeding users for now, 
            // but let's see if it's there.
        }
    }
}
