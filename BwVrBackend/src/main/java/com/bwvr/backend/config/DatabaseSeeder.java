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
                // Admin already exists — do NOT overwrite password or flags.
                // Changing passwords and resetting mustChangePassword is the user's job.
                System.out.println("Admin user already exists. Skipping seed.");
                return;
            }

            // First-time setup: create default admin account
            BwvrUser admin = new BwvrUser();
            admin.setUsername("admin");
            admin.setPasswordHash(passwordEncoder.encode("admin123"));
            admin.setRole("ADMIN");
            admin.setStatus("APPROVED");
            admin.setMustChangePassword(true); // Force change on first-ever login only
            userRepository.save(admin);
            System.out.println("Default admin user created successfully.");

        } catch (Exception e) {
            System.err.println("Warning: Admin seed failed — table may not be initialized yet. " + e.getMessage());
        }
    }
}
