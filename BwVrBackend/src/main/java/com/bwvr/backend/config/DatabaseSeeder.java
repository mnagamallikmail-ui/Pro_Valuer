package com.bwvr.backend.config;

import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    private final BwvrUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbcTemplate;

    public DatabaseSeeder(BwvrUserRepository userRepository, PasswordEncoder passwordEncoder, JdbcTemplate jdbcTemplate) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {
        try {
            // First ensure the table is available!
            ensureUserTableExists();

            if (userRepository.findByUsername("admin").isEmpty()) {
                BwvrUser admin = new BwvrUser();
                admin.setUsername("admin");
                admin.setPasswordHash(passwordEncoder.encode("admin123"));
                admin.setRole("ADMIN");
                admin.setStatus("APPROVED");
                admin.setMustChangePassword(true);
                userRepository.save(admin);
                System.out.println("Default admin user created.");
            }
        } catch (Exception e) {
            System.err.println("Warning: Admin seed failed, table might not be initialized yet. " + e.getMessage());
        }
    }

    private void ensureUserTableExists() {
        try {
            jdbcTemplate.execute("SELECT 1 FROM BWVR.BWVR_USER WHERE 1=0");
        } catch (Exception e) {
            try {
                // Oracle syntax for creating sequence and table if they do not exist
                jdbcTemplate.execute("BEGIN\n" +
                        "  EXECUTE IMMEDIATE 'CREATE SEQUENCE BWVR.SEQ_USER_ID START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';\n" +
                        "EXCEPTION\n" +
                        "  WHEN OTHERS THEN\n" +
                        "    IF SQLCODE != -955 THEN RAISE; END IF;\n" +
                        "END;");
                
                jdbcTemplate.execute("BEGIN\n" +
                        "  EXECUTE IMMEDIATE 'CREATE TABLE BWVR.BWVR_USER (" +
                        "USER_ID NUMBER DEFAULT BWVR.SEQ_USER_ID.NEXTVAL PRIMARY KEY, " +
                        "USERNAME VARCHAR2(100) NOT NULL UNIQUE, " +
                        "PASSWORD_HASH VARCHAR2(255) NOT NULL, " +
                        "ROLE VARCHAR2(20) NOT NULL, " +
                        "STATUS VARCHAR2(20) NOT NULL, " +
                        "MUST_CHANGE_PASSWORD NUMBER(1) DEFAULT 0 NOT NULL, " +
                        "CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                        "UPDATED_AT TIMESTAMP)';\n" +
                        "EXCEPTION\n" +
                        "  WHEN OTHERS THEN\n" +
                        "    IF SQLCODE != -955 THEN RAISE; END IF;\n" +
                        "END;");
            } catch (Exception ex) {
               // Table might already exist via other sql scripts.
               System.err.println("Fallback creation also failed: " + ex.getMessage());
            }
        }
    }
}
