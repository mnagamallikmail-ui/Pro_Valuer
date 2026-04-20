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

        // Check current security context (normal API call case)
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName())) {
            currentUsername = auth.getName();
            isAdmin = auth.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        } 
        // Fallback to token parameter (browser download case)
        else if (token != null && jwtUtil.validateJwtToken(token)) {
            currentUsername = jwtUtil.getUserNameFromJwtToken(token);
            // Note: In an ideal world, we'd also load the user details to check roles
            // but for simplicity and safety, we'll check ownership next.
        }

        if (currentUsername == null) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
        }

        ReportDetailResponse detail = reportService.getReportDetail(reportId);

        // Security Check: Users can only download their own reports, Admins can download all
        if (!isAdmin && (detail.getCreatedBy() == null || !detail.getCreatedBy().equals(currentUsername))) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
        }

        if (!detail.isHasGeneratedFile()) {
            return ResponseEntity.notFound().build();
        }

        // Get the file path from service
        String filePath = reportService.getReportFilePath(reportId);
        File file = new File(filePath);
        if (!file.exists()) {
            return ResponseEntity.notFound().build();
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
