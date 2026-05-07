package com.bwvr.backend.controller;

import com.bwvr.backend.dto.request.CreateReportRequest;
import com.bwvr.backend.dto.request.SaveReportValuesRequest;
import com.bwvr.backend.dto.request.UpdateReportRequest;
import com.bwvr.backend.dto.response.ApiResponse;
import com.bwvr.backend.dto.response.DashboardStatsResponse;
import com.bwvr.backend.dto.response.ReportDetailResponse;
import com.bwvr.backend.dto.response.ReportResponse;
import com.bwvr.backend.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.IOException;

@RestController
@RequestMapping("/api/v1/reports")
@Tag(name = "Reports", description = "Report management endpoints")
public class ReportController {

    private static final Logger log = LoggerFactory.getLogger(ReportController.class);

    private final ReportService reportService;
    private final com.bwvr.backend.security.JwtUtil jwtUtil;

    public ReportController(ReportService reportService, com.bwvr.backend.security.JwtUtil jwtUtil) {
        this.reportService = reportService;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping
    @Operation(summary = "Create a new report with a unique reference number")
    public ResponseEntity<ApiResponse<ReportResponse>> createReport(
            @RequestBody CreateReportRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                reportService.createReport(request), "Report created successfully"));
    }

    @GetMapping
    @Operation(summary = "Search and list reports. Admins see all; users see only theirs.")
    public ResponseEntity<ApiResponse<Page<ReportResponse>>> getReports(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String vendorName,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) String bankName,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        String username = isAdmin ? null : auth.getName(); // null = no filter for admin

        return ResponseEntity.ok(ApiResponse.success(
                reportService.searchReports(search, vendorName, location, bankName, status, page, size, username)));
    }

    @GetMapping("/mine")
    @Operation(summary = "Get only reports created by the currently logged-in user")
    public ResponseEntity<ApiResponse<Page<ReportResponse>>> getMyReports(
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        return ResponseEntity.ok(ApiResponse.success(
                reportService.searchReports(search, null, null, null, null, page, size, username)));
    }

    @GetMapping("/{reportId}")
    @Operation(summary = "Get full report detail by ID")
    public ResponseEntity<ApiResponse<ReportDetailResponse>> getReport(@PathVariable Long reportId) {
        return ResponseEntity.ok(ApiResponse.success(reportService.getReportDetail(reportId)));
    }

    @GetMapping("/ref/{referenceNumber}")
    @Operation(summary = "Get report by unique reference number")
    public ResponseEntity<ApiResponse<ReportDetailResponse>> getReportByRef(
            @PathVariable String referenceNumber) {
        return ResponseEntity.ok(ApiResponse.success(reportService.getReportByRefNumber(referenceNumber)));
    }

    @PutMapping("/{reportId}")
    @Operation(summary = "Update report metadata")
    public ResponseEntity<ApiResponse<ReportResponse>> updateReport(
            @PathVariable Long reportId,
            @RequestBody UpdateReportRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                reportService.updateReport(reportId, request), "Report updated successfully"));
    }

    @PostMapping("/{reportId}/values")
    @Operation(summary = "Save or update placeholder values for a report")
    public ResponseEntity<ApiResponse<Void>> saveValues(
            @PathVariable Long reportId,
            @RequestBody SaveReportValuesRequest request) {
        reportService.saveReportValues(reportId, request);
        return ResponseEntity.ok(ApiResponse.success(null, "Values saved successfully"));
    }

    @PostMapping("/{reportId}/submit")
    @Operation(summary = "Submit a DRAFT report for review")
    public ResponseEntity<ApiResponse<ReportResponse>> submitReport(@PathVariable Long reportId) {
        return ResponseEntity.ok(ApiResponse.success(
                reportService.submitReport(reportId), "Report submitted successfully"));
    }

    @PostMapping("/{reportId}/review")
    @Operation(summary = "Set a report to UNDER_REVIEW")
    public ResponseEntity<ApiResponse<ReportResponse>> reviewReport(@PathVariable Long reportId) {
        return ResponseEntity.ok(ApiResponse.success(
                reportService.reviewReport(reportId), "Report marked as under review"));
    }

    @PostMapping("/{reportId}/approve")
    @Operation(summary = "Approve a SUBMITTED or UNDER_REVIEW report")
    public ResponseEntity<ApiResponse<ReportResponse>> approveReport(@PathVariable Long reportId) {
        return ResponseEntity.ok(ApiResponse.success(
                reportService.approveReport(reportId), "Report approved successfully"));
    }
    @PostMapping("/{reportId}/generate")
    @Operation(summary = "Generate the final .docx report document")
    public ResponseEntity<ApiResponse<String>> generateReport(@PathVariable Long reportId) {
        String path = reportService.generateDocument(reportId);
        return ResponseEntity.ok(ApiResponse.success(path, "Document generated successfully"));
    }

    @GetMapping("/{reportId}/download")
    @Operation(summary = "Download the generated .docx report file")
    public ResponseEntity<Resource> downloadReport(
            @PathVariable Long reportId,
            @RequestParam(required = false) String token) throws IOException {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUsername = null;
        boolean isAdmin = false;

        // Diagnostic logging for production debugging
        log.info("Download request for report {} | Query token present: {} | Auth present: {}", 
                 reportId, token != null, auth != null && auth.isAuthenticated());

        // Check current security context (normal API call case)
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName())) {
            currentUsername = auth.getName();
            isAdmin = auth.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
            log.debug("User identified via SecurityContext: {}", currentUsername);
        } 
        // Fallback to token parameter (browser download case)
        else if (token != null) {
            try {
                if (jwtUtil.validateJwtToken(token)) {
                    currentUsername = jwtUtil.getUserNameFromJwtToken(token);
                    log.debug("User identified via Query Token: {}", currentUsername);
                    // Note: We don't have roles in a simple query token check without reloading user.
                    // We'll trust the ownership check below.
                } else {
                    log.warn("Invalid JWT token provided in query parameter for report {}", reportId);
                }
            } catch (Exception e) {
                log.error("Error validating JWT token from query: {}", e.getMessage());
            }
        }

        if (currentUsername == null) {
            log.warn("Download denied for report {}: No valid user identification (auth or token missing/invalid)", reportId);
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
        }

        ReportDetailResponse detail = reportService.getReportDetail(reportId);

        // Security Check: Users can only download their own reports, Admins can download all.
        // Fallback: Allow 'SYSTEM' created reports for all authenticated users (handles legacy data).
        boolean isOwner = detail.getCreatedBy() == null || 
                          "SYSTEM".equalsIgnoreCase(detail.getCreatedBy()) || 
                          detail.getCreatedBy().equals(currentUsername);

        if (!isAdmin && !isOwner) {
            log.warn("Download denied for report {}: User {} is not the owner (Creator: {})", 
                     reportId, currentUsername, detail.getCreatedBy());
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
        }

        if (!detail.isHasGeneratedFile()) {
            throw new com.bwvr.backend.exception.ResourceNotFoundException(
                "Document has not been generated yet or is no longer available on disk. " +
                "This usually happens when the server restarts without a persistent volume. " +
                "Please click 'Generate Document' to recreate it.");
        }

        // Get the file path from service
        String filePath = reportService.getReportFilePath(reportId);
        if (filePath == null) {
             throw new com.bwvr.backend.exception.ResourceNotFoundException(
                "The report does not have a generated file path assigned.");
        }
        
        File file = new File(filePath);
        if (!file.exists()) {
             throw new com.bwvr.backend.exception.ResourceNotFoundException(
                "The generated document file could not be found on the server's filesystem. " +
                "This usually happens after a container deployment. Please recreate it by clicking 'Generate Document'.");
        }

        Resource resource = new FileSystemResource(file);
        String filename = "report_" + detail.getReferenceNumber() + ".docx";

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.parseMediaType(
                        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"))
                .contentLength(file.length())
                .body(resource);
    }

    @DeleteMapping("/{reportId}")
    @Operation(summary = "Soft-delete a report")
    public ResponseEntity<ApiResponse<Void>> deleteReport(
            @PathVariable Long reportId,
            @RequestParam(defaultValue = "SYSTEM") String deletedBy) {
        reportService.deleteReport(reportId, deletedBy);
        return ResponseEntity.ok(ApiResponse.success(null, "Report deleted successfully"));
    }

    @GetMapping("/dashboard/stats")
    @Operation(summary = "Get dashboard statistics (scoped by role)")
    public ResponseEntity<ApiResponse<DashboardStatsResponse>> getDashboardStats() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        String username = isAdmin ? null : auth.getName();
        return ResponseEntity.ok(ApiResponse.success(reportService.getDashboardStats(username, isAdmin)));
    }
}
