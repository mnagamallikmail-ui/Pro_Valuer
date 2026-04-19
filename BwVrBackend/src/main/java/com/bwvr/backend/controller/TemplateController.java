package com.bwvr.backend.controller;

import com.bwvr.backend.dto.request.ConfirmPlaceholdersRequest;
import com.bwvr.backend.dto.response.ApiResponse;
import com.bwvr.backend.dto.response.ParsedTemplateResponse;
import com.bwvr.backend.dto.response.PlaceholderResponse;
import com.bwvr.backend.dto.response.TemplateResponse;
import com.bwvr.backend.service.TemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/v1/templates")
@Tag(name = "Templates", description = "Template management endpoints")
public class TemplateController {

    private final TemplateService templateService;

    public TemplateController(TemplateService templateService) {
        this.templateService = templateService;
    }

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload a .docx template and parse placeholders")
    public ResponseEntity<ApiResponse<ParsedTemplateResponse>> uploadTemplate(
        @RequestPart("file") MultipartFile file,
        @RequestParam("bankName") String bankName,
        @RequestParam("templateName") String templateName,
        @RequestParam(value = "uploadedBy", defaultValue = "SYSTEM") String uploadedBy) throws IOException {

        ParsedTemplateResponse response = templateService.uploadTemplate(file, bankName, templateName, uploadedBy);
        return ResponseEntity.ok(ApiResponse.success(response, "Template uploaded and parsed successfully"));
    }

    @GetMapping
    @Operation(summary = "List all active templates with optional bank name filter")
    public ResponseEntity<ApiResponse<Page<TemplateResponse>>> getTemplates(
        @RequestParam(required = false) String bankName,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size) {

        return ResponseEntity.ok(ApiResponse.success(templateService.getTemplates(bankName, page, size)));
    }

    @GetMapping("/{templateId}")
    @Operation(summary = "Get template metadata by ID")
    public ResponseEntity<ApiResponse<TemplateResponse>> getTemplate(@PathVariable Long templateId) {
        return ResponseEntity.ok(ApiResponse.success(templateService.getTemplate(templateId)));
    }

    @GetMapping("/{templateId}/placeholders")
    @Operation(summary = "Get all parsed placeholders for a template")
    public ResponseEntity<ApiResponse<List<PlaceholderResponse>>> getPlaceholders(@PathVariable Long templateId) {
        return ResponseEntity.ok(ApiResponse.success(templateService.getPlaceholders(templateId)));
    }

    @PostMapping("/{templateId}/confirm-placeholders")
    @Operation(summary = "Confirm and finalize placeholder question mappings")
    public ResponseEntity<ApiResponse<Void>> confirmPlaceholders(
        @PathVariable Long templateId,
        @RequestBody ConfirmPlaceholdersRequest request) {

        templateService.confirmPlaceholders(templateId, request);
        return ResponseEntity.ok(ApiResponse.success(null, "Placeholders confirmed successfully"));
    }

    @DeleteMapping("/{templateId}")
    @Operation(summary = "Soft-delete a template")
    public ResponseEntity<ApiResponse<Void>> deleteTemplate(
        @PathVariable Long templateId,
        @RequestParam(defaultValue = "SYSTEM") String deletedBy) {

        templateService.deleteTemplate(templateId, deletedBy);
        return ResponseEntity.ok(ApiResponse.success(null, "Template deleted successfully"));
    }

    @GetMapping("/banks")
    @Operation(summary = "Get distinct list of bank names from all active templates")
    public ResponseEntity<ApiResponse<List<String>>> getBankNames() {
        return ResponseEntity.ok(ApiResponse.success(templateService.getBankNames()));
    }
}
