package com.bwvr.backend.controller;

import java.io.IOException;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.bwvr.backend.dto.response.ApiResponse;
import com.bwvr.backend.entity.BwvrReportImage;
import com.bwvr.backend.service.ReportImageService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/v1/report-images")
@Tag(name = "Report Images", description = "BLOB-based image storage for reports")
public class ReportImageController {

    private final ReportImageService reportImageService;

    public ReportImageController(ReportImageService reportImageService) {
        this.reportImageService = reportImageService;
    }

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload image for a report placeholder (Stored as BLOB)")
    public ResponseEntity<ApiResponse<Long>> uploadImage(
            @RequestParam("reportId") Long reportId,
            @RequestParam("placeholderKey") String placeholderKey,
            @RequestPart("file") MultipartFile file) throws IOException {

        BwvrReportImage savedImage = reportImageService.saveImage(reportId, placeholderKey, file);
        return ResponseEntity.ok(ApiResponse.success(savedImage.getImageId(), "Image uploaded successfully into database"));
    }

    @GetMapping("/{reportId}/{placeholderKey}")
    @Operation(summary = "Retrieve image from BLOB storage")
    public ResponseEntity<byte[]> getImageByPlaceholder(
            @PathVariable Long reportId,
            @PathVariable String placeholderKey) {

        BwvrReportImage image = reportImageService.getImage(reportId, placeholderKey);

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(image.getContentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + image.getFileName() + "\"")
                .body(image.getImageData());
    }
}
