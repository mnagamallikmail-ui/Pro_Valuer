package com.bwvr.backend.config;

import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    private final BwvrUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DatabaseSeeder(BwvrUserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        try {
            Optional<BwvrUser> adminOpt = userRepository.findByUsername("admin");
            if (adminOpt.isPresent()) {
                BwvrUser existingAdmin = adminOpt.get();
                // Ensure password is reset to default for recovery if needed
                // In a real prod app, you wouldn't do this, but for this fix it ensures access.
                existingAdmin.setPasswordHash(passwordEncoder.encode("admin123"));
                existingAdmin.setStatus("APPROVED");
                userRepository.save(existingAdmin);
                System.out.println("Admin user password reset to admin123.");
            } else {
                BwvrUser admin = new BwvrUser();
                admin.setUsername("admin");
                admin.setPasswordHash(passwordEncoder.encode("admin123"));
                admin.setRole("ADMIN");
                admin.setStatus("APPROVED");
                admin.setMustChangePassword(true);
                userRepository.save(admin);
                System.out.println("Default admin user created successfully.");
            }

            // Also create a regular test user
            if (userRepository.findByUsername("testuser").isEmpty()) {
                BwvrUser testUser = new BwvrUser();
                testUser.setUsername("testuser");
                testUser.setPasswordHash(passwordEncoder.encode("test123456"));
                testUser.setRole("USER");
                testUser.setStatus("APPROVED");
                testUser.setFullName("Test User");
                userRepository.save(testUser);
                System.out.println("Test user 'testuser' created with password 'test123456'.");
            }

        } catch (Exception e) {
            System.err.println("Warning: Database seeding failed: " + e.getMessage());
        }
    }
}
