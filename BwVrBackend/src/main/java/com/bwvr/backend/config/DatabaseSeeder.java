package com.bwvr.backend.config;

import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

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
            if (userRepository.findByUsername("admin").isEmpty()) {
                BwvrUser admin = new BwvrUser();
                admin.setUsername("admin");
                admin.setPasswordHash(passwordEncoder.encode("admin123"));
                admin.setRole("ADMIN");
                admin.setStatus("APPROVED");
                admin.setMustChangePassword(true);
                userRepository.save(admin);
                System.out.println("✅ Default admin user created. Username: admin / Password: admin123");
            } else {
                System.out.println("✅ Admin user already exists. Skipping seed.");
            }
        } catch (Exception e) {
            System.err.println("❌ Admin seeding failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
