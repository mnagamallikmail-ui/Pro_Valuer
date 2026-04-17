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
            BwvrUser admin;
            if (adminOpt.isEmpty()) {
                admin = new BwvrUser();
                admin.setUsername("admin");
                System.out.println("Default admin user not found. Creating it now...");
            } else {
                admin = adminOpt.get();
                System.out.println("Admin user exists. Forcing password reset and status to APPROVED to ensure access.");
            }
            
            // Force reset credentials and status
            admin.setPasswordHash(passwordEncoder.encode("admin123"));
            admin.setRole("ADMIN");
            admin.setStatus("APPROVED");
            admin.setMustChangePassword(true);
            
            userRepository.save(admin);
            System.out.println("Admin user seed/reset successful.");
            
        } catch (Exception e) {
            System.err.println("Warning: Admin seed failed, table might not be initialized yet. " + e.getMessage());
        }
    }
}
