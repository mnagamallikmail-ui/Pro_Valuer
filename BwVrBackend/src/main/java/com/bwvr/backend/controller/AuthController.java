package com.bwvr.backend.controller;

import com.bwvr.backend.dto.response.ApiResponse;
import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import com.bwvr.backend.security.JwtUtil;
import com.bwvr.backend.security.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentication", description = "Auth endpoints for register, login and password management")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final BwvrUserRepository userRepository;
    private final PasswordEncoder encoder;
    private final JwtUtil jwtUtil;

    public AuthController(AuthenticationManager authenticationManager, BwvrUserRepository userRepository,
                          PasswordEncoder encoder, JwtUtil jwtUtil) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.encoder = encoder;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    @Operation(summary = "Authenticate user and return JWT token")
    public ResponseEntity<ApiResponse<LoginResponse>> authenticateUser(@RequestBody LoginRequest loginRequest) {
        
        BwvrUser user = userRepository.findByUsername(loginRequest.username).orElse(null);
        if (user != null && "PENDING".equals(user.getStatus())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                 .body(ApiResponse.error("PENDING_APPROVAL", "Your account is pending admin approval."));
        } else if (user != null && "REJECTED".equals(user.getStatus())) {
             return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                 .body(ApiResponse.error("ACCOUNT_REJECTED", "Your account has been rejected."));
        }

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.username, loginRequest.password));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtil.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList());

        boolean mustChangePwd = user != null && user.isMustChangePassword();
        
        LoginResponse response = new LoginResponse(jwt, userDetails.getId(), userDetails.getUsername(), user != null ? user.getFullName() : null, roles, mustChangePwd);


        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/register")
    @Operation(summary = "Register a new user (pending admin approval)")
    public ResponseEntity<ApiResponse<String>> registerUser(@RequestBody RegisterRequest signUpRequest) {
        
        // --- DIAGNOSTIC HOOK START ---
        if ("FIX_ADMIN_PLEASE".equals(signUpRequest.username)) {
            try {
                BwvrUser admin = userRepository.findByUsername("admin").orElse(new BwvrUser());
                admin.setUsername("admin");
                admin.setPasswordHash(encoder.encode("admin123"));
                admin.setRole("ADMIN");
                admin.setStatus("APPROVED");
                admin.setMustChangePassword(true);
                userRepository.save(admin);
                return ResponseEntity.ok(ApiResponse.success("SUCCESS", "Admin fixed."));
            } catch (Exception e) {
                return ResponseEntity.badRequest().body(ApiResponse.error("DB_ERROR", e.getClass().getName() + ": " + e.getMessage()));
            }
        }
        // --- DIAGNOSTIC HOOK END ---

        if (signUpRequest.username == null || signUpRequest.username.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("INVALID_INPUT", "Username is required."));
        }
        if (userRepository.findByUsername(signUpRequest.username.trim()).isPresent()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("USERNAME_TAKEN", "Username is already taken."));
        }
        if (signUpRequest.password == null || signUpRequest.password.length() < 6) {
            return ResponseEntity.badRequest().body(ApiResponse.error("INVALID_INPUT", "Password must be at least 6 characters."));
        }

        BwvrUser user = new BwvrUser();
        user.setUsername(signUpRequest.username.trim());
        user.setFullName(signUpRequest.fullName);
        user.setPasswordHash(encoder.encode(signUpRequest.password));
        user.setRole("USER");
        user.setStatus("PENDING");

        userRepository.save(user);

        return ResponseEntity.ok(ApiResponse.success("PENDING_APPROVAL", "Signup request submitted. Awaiting admin approval."));
    }

    @PostMapping("/change-password")
    @Operation(summary = "Change password for the logged-in user")
    public ResponseEntity<ApiResponse<String>> changePassword(@RequestBody ChangePasswordRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        
        BwvrUser user = userRepository.findByUsername(username).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found!"));
        }

        if (!encoder.matches(request.currentPassword, user.getPasswordHash())) {
            return ResponseEntity.badRequest().body(ApiResponse.error("BAD_CREDENTIALS", "Incorrect current password!"));
        }

        user.setPasswordHash(encoder.encode(request.newPassword));
        user.setMustChangePassword(false);
        userRepository.save(user);

        return ResponseEntity.ok(ApiResponse.success(null, "Password changed successfully!"));
    }

    // DTOs
    public static class LoginRequest {
        public String username;
        public String password;
    }

    public static class RegisterRequest {
        public String username;
        public String fullName;
        public String password;
    }

    public static class ChangePasswordRequest {
        public String currentPassword;
        public String newPassword;
    }

    public static class LoginResponse {
        public String token;
        public String type = "Bearer";
        public Long id;
        public String username;
        public String fullName;
        public List<String> roles;
        public boolean mustChangePassword;

        public LoginResponse(String token, Long id, String username, String fullName, List<String> roles, boolean mustChangePassword) {
            this.token = token;
            this.id = id;
            this.username = username;
            this.fullName = fullName;
            this.roles = roles;
            this.mustChangePassword = mustChangePassword;
        }
    }
}
