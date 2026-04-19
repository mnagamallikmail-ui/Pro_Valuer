package com.bwvr.backend.controller;

import com.bwvr.backend.dto.response.ApiResponse;
import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/admin")
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Admin", description = "Admin user management and approval endpoints")
@SuppressWarnings("null")
public class AdminController {

    private final BwvrUserRepository userRepository;
    private final PasswordEncoder encoder;

    public AdminController(BwvrUserRepository userRepository, PasswordEncoder encoder) {
        this.userRepository = userRepository;
        this.encoder = encoder;
    }

    // ── User Listing ──────────────────────────────────────────────────────────

    @GetMapping("/users")
    @Operation(summary = "Get all users")
    public ResponseEntity<ApiResponse<List<UserDto>>> getAllUsers() {
        List<UserDto> users = userRepository.findAll()
                .stream().map(UserDto::new).collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(users));
    }

    @GetMapping("/users/pending")
    @Operation(summary = "Get list of pending users")
    public ResponseEntity<ApiResponse<List<UserDto>>> getPendingUsers() {
        List<UserDto> response = userRepository.findByStatus("PENDING")
                .stream().map(UserDto::new).collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/users/pending/count")
    @Operation(summary = "Get count of pending users")
    public ResponseEntity<ApiResponse<Long>> getPendingCount() {
        long count = userRepository.findByStatus("PENDING").size();
        return ResponseEntity.ok(ApiResponse.success(count));
    }

    // ── User Approval ─────────────────────────────────────────────────────────

    @PostMapping("/users/{userId}/approve")
    @Operation(summary = "Approve a pending user")
    public ResponseEntity<ApiResponse<String>> approveUser(@PathVariable Long userId) {
        BwvrUser user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found!"));
        }
        user.setStatus("APPROVED");
        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(null, "User '" + user.getUsername() + "' approved successfully."));
    }

    @PostMapping("/users/{userId}/reject")
    @Operation(summary = "Reject a pending user")
    public ResponseEntity<ApiResponse<String>> rejectUser(@PathVariable Long userId) {
        BwvrUser user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found!"));
        }
        user.setStatus("REJECTED");
        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(null, "User '" + user.getUsername() + "' rejected."));
    }

    // ── User Management (Create/Delete) ───────────────────────────────────────

    @PostMapping("/users")
    @Operation(summary = "Create a new user directly (Admin only)")
    public ResponseEntity<ApiResponse<UserDto>> createUser(@RequestBody CreateUserRequest request) {
        if (userRepository.findByUsername(request.username).isPresent()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("USERNAME_TAKEN", "Username already exists."));
        }

        BwvrUser user = new BwvrUser();
        user.setUsername(request.username);
        user.setFullName(request.fullName);
        user.setRole(request.role != null ? request.role : "USER");
        user.setStatus("APPROVED");
        user.setPasswordHash(encoder.encode(request.password));
        user.setMustChangePassword(true);

        BwvrUser saved = userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(new UserDto(saved), "User created successfully."));
    }

    @DeleteMapping("/users/{userId}")
    @Operation(summary = "Delete a user")
    public ResponseEntity<ApiResponse<String>> deleteUser(@PathVariable Long userId) {
        if (!userRepository.existsById(userId)) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found."));
        }
        userRepository.deleteById(userId);
        return ResponseEntity.ok(ApiResponse.success(null, "User deleted successfully."));
    }

    @PostMapping("/users/{userId}/reset-password")
    @Operation(summary = "Reset user password")
    public ResponseEntity<ApiResponse<String>> resetPassword(@PathVariable Long userId, @RequestBody String newPassword) {
        BwvrUser user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found."));
        }
        user.setPasswordHash(encoder.encode(newPassword));
        user.setMustChangePassword(true);
        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(null, "Password reset successfully."));
    }

    // ── DTO ───────────────────────────────────────────────────────────────────

    public static class UserDto {
        public Long id;
        public String username;
        public String fullName;
        public String role;
        public String status;
        public String createdAt;

        public UserDto(BwvrUser user) {
            this.id = user.getId();
            this.username = user.getUsername();
            this.fullName = user.getFullName();
            this.role = user.getRole();
            this.status = user.getStatus();
            if (user.getCreatedAt() != null) {
                this.createdAt = user.getCreatedAt().toString();
            }
        }
    }

    public static class CreateUserRequest {
        public String username;
        public String password;
        public String fullName;
        public String role;
    }
}
