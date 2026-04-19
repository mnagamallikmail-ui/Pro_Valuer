package com.bwvr.backend.controller;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;
import java.util.Map;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/v1/files")
@Tag(name = "Files", description = "File upload and retrieval endpoints")
public class FileController {

    private static final Logger log = LoggerFactory.getLogger(FileController.class);

    private final com.bwvr.backend.repository.ReportValueRepository reportValueRepository;
    private final com.bwvr.backend.repository.ReportRepository reportRepository;
    private final com.bwvr.backend.repository.TemplatePlaceholderRepository templatePlaceholderRepository;

    public FileController(
            com.bwvr.backend.repository.ReportValueRepository reportValueRepository,
            com.bwvr.backend.repository.ReportRepository reportRepository,
            com.bwvr.backend.repository.TemplatePlaceholderRepository templatePlaceholderRepository) {
        this.reportValueRepository = reportValueRepository;
        this.reportRepository = reportRepository;
        this.templatePlaceholderRepository = templatePlaceholderRepository;
    }

    @PostMapping(value = "/upload-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload an image for a report placeholder (Saves to BLOB)")
    @org.springframework.transaction.annotation.Transactional
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadImage(
            @RequestPart("file") MultipartFile file,
            @RequestParam("reportId") Long reportId,
            @RequestParam("placeholderKey") String placeholderKey) throws IOException {

        byte[] bytes;
        String contentType = file.getContentType();
        long fileSize = file.getSize();

        // Compress if larger than 1MB and is JPEG/PNG
        if (fileSize > 1048576 && contentType != null && (contentType.startsWith("image/jpeg") || contentType.startsWith("image/png"))) {
            log.info("Compressing image {} of size {} bytes", file.getOriginalFilename(), fileSize);
            bytes = compressImage(file.getInputStream());
            if (bytes == null) {
                // Compression failed or unsupported format, fallback to original
                bytes = file.getBytes();
            }
        } else {
            bytes = file.getBytes();
        }

        String originalName = file.getOriginalFilename();
        if (originalName == null || originalName.isBlank()) {
            originalName = "unknown.jpg";
        }
        final String finalOriginalName = originalName;

        // Try to find existing record
        java.util.Optional<com.bwvr.backend.entity.BwvrReportValue> existingVal
                = reportValueRepository.findByReport_ReportIdAndPlaceholderKey(reportId, placeholderKey);

        com.bwvr.backend.entity.BwvrReportValue val;
        if (existingVal.isPresent()) {
            val = existingVal.get();
        } else {
            // Create new record if it doesn't exist
            com.bwvr.backend.entity.BwvrReport report = reportRepository.findById(reportId)
                    .orElseThrow(() -> new com.bwvr.backend.exception.ResourceNotFoundException("Report", reportId));

            com.bwvr.backend.entity.BwvrTemplatePlaceholder placeholder = templatePlaceholderRepository
                    .findByTemplate_TemplateIdAndPlaceholderKey(report.getTemplate().getTemplateId(), placeholderKey)
                    .orElseThrow(() -> new com.bwvr.backend.exception.ResourceNotFoundException("Placeholder Key: " + placeholderKey));

            val = com.bwvr.backend.entity.BwvrReportValue.builder()
                    .report(report)
                    .placeholder(placeholder)
                    .placeholderKey(placeholderKey)
                    .build();
        }

        // Save to BLOB directly
        val.setImageData(bytes);
        val.setImageOriginalName(finalOriginalName);
        val.setImageFilePath(null); // Clear path to favor BLOB
        reportValueRepository.save(val);

        String imageUrl = "/api/v1/files/image/" + reportId + "?placeholderKey=" + placeholderKey;

        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "originalName", finalOriginalName,
                "imageUrl", imageUrl,
                "filePath", imageUrl
        ), "Image saved successfully in database BLOB"));
    }

    @GetMapping("/image/{reportId}")
    @Operation(summary = "Retrieve/view an uploaded image (from BLOB)")
    public ResponseEntity<byte[]> getImage(
            @PathVariable Long reportId,
            @RequestParam("placeholderKey") String placeholderKey) {

        return reportValueRepository.findByReport_ReportIdAndPlaceholderKey(reportId, placeholderKey)
                .map(val -> {
                    if (val.getImageData() == null) {
                        return ResponseEntity.notFound().<byte[]>build();
                    }
                    String contentType = "image/jpeg";
                    String name = val.getImageOriginalName() != null ? val.getImageOriginalName().toLowerCase() : "";
                    if (name.endsWith(".png")) {
                        contentType = "image/png";
                    } else if (name.endsWith(".gif")) {
                        contentType = "image/gif";
                    } else if (name.endsWith(".webp")) {
                        contentType = "image/webp";
                    }

                    return ResponseEntity.ok()
                            .contentType(MediaType.parseMediaType(contentType))
                            .body(val.getImageData());
                })
                .orElse(ResponseEntity.notFound().build());
    }

    private byte[] compressImage(InputStream inputStream) {
        try {
            BufferedImage img = ImageIO.read(inputStream);
            if (img == null) {
                return null;
            }

            // If image has alpha channel (e.g. PNG), we need to handle it or drop it when writing to JPEG
            BufferedImage newImage = new BufferedImage(img.getWidth(), img.getHeight(), BufferedImage.TYPE_INT_RGB);
            newImage.createGraphics().drawImage(img, 0, 0, java.awt.Color.WHITE, null);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpeg");
            if (!writers.hasNext()) {
                return null;
            }
            ImageWriter writer = writers.next();

            ImageWriteParam param = writer.getDefaultWriteParam();
            if (param.canWriteCompressed()) {
                param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                param.setCompressionQuality(0.7f); // 70% quality
            }

            try (ImageOutputStream ios = ImageIO.createImageOutputStream(baos)) {
                writer.setOutput(ios);
                writer.write(null, new IIOImage(newImage, null, null), param);
            } finally {
                writer.dispose();
            }

            return baos.toByteArray();
        } catch (Exception e) {
            log.warn("Image compression failed", e);
            return null;
        }
    }
}
