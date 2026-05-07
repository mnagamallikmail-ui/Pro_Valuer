package com.bwvr.backend.controller;

import com.bwvr.backend.dto.response.ApiResponse;
import com.bwvr.backend.entity.BwvrUser;
import com.bwvr.backend.repository.BwvrUserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import org.springframework.security.crypto.password.PasswordEncoder;
import java.util.List;
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

    // â”€â”€ User Listing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

    // â”€â”€ User Approval â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

    // â”€â”€ User Management (Add/Delete) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    @PostMapping("/users")
    @Operation(summary = "Add a new user manually (Pre-Approved)")
    public ResponseEntity<ApiResponse<String>> addUser(@RequestBody AddUserRequest request) {
        if (request.username == null || request.username.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("INVALID_INPUT", "Username/Email is required."));
        }
        String normalizedUsername = request.username.trim().toLowerCase();
        
        if (userRepository.findByUsername(normalizedUsername).isPresent()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("TAKEN", "User already exists."));
        }

        BwvrUser user = new BwvrUser();
        user.setUsername(normalizedUsername);
        user.setFullName(request.fullName);
        user.setPasswordHash(encoder.encode(request.password));
        user.setRole(request.role != null ? request.role : "USER");
        user.setStatus("APPROVED"); // Admins add pre-approved users
        user.setValidatorUsername(request.validatorUsername);

        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(null, "User created successfully."));
    }

    @DeleteMapping("/users/{id}")
    @Operation(summary = "Delete a user by ID")
    public ResponseEntity<ApiResponse<String>> deleteUser(@PathVariable Long id) {
        if (!userRepository.existsById(id)) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found."));
        }
        userRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(null, "User deleted successfully."));
    }

    @PatchMapping("/users/{id}/role")
    @Operation(summary = "Update user role")
    public ResponseEntity<ApiResponse<String>> updateRole(@PathVariable Long id, @RequestParam String role) {
        BwvrUser user = userRepository.findById(id).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found."));
        }
        user.setRole(role);
        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(null, "User role updated to " + role));
    }

    @PatchMapping("/users/{id}/password")
    @Operation(summary = "Reset or change user password")
    public ResponseEntity<ApiResponse<String>> updatePassword(@PathVariable Long id, @RequestParam String newPassword) {
        BwvrUser user = userRepository.findById(id).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found."));
        }
        user.setPasswordHash(encoder.encode(newPassword));
        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(null, "Password updated successfully."));
    }

    @PatchMapping("/users/{id}/validator")
    @Operation(summary = "Update user's assigned validator")
    public ResponseEntity<ApiResponse<String>> updateValidator(@PathVariable Long id, @RequestParam(required = false) String validatorUsername) {
        BwvrUser user = userRepository.findById(id).orElse(null);
        if (user == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("NOT_FOUND", "User not found."));
        }
        user.setValidatorUsername(validatorUsername);
        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(null, "Validator assigned successfully."));
    }
    // â”€â”€ DTO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    public static class UserDto {
        public Long id;
        public String username;
        public String fullName;
        public String role;
        public String status;
        public String createdAt;
        public String validatorUsername;

        public UserDto(BwvrUser user) {
            this.id = user.getId();
            this.username = user.getUsername();
            this.fullName = user.getFullName();
            this.role = user.getRole();
            this.status = user.getStatus();
            this.validatorUsername = user.getValidatorUsername();
            if (user.getCreatedAt() != null) {
                this.createdAt = user.getCreatedAt().toString();
            }
        }
    }

    public static class AddUserRequest {
        public String username;
        public String fullName;
        public String password;
        public String role;
        public String validatorUsername;
    }
}
