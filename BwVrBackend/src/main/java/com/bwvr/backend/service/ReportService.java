package com.bwvr.backend.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bwvr.backend.dto.request.CreateReportRequest;
import com.bwvr.backend.dto.request.SaveReportValuesRequest;
import com.bwvr.backend.dto.request.UpdateReportRequest;
import com.bwvr.backend.dto.response.DashboardStatsResponse;
import com.bwvr.backend.dto.response.ReportDetailResponse;
import com.bwvr.backend.dto.response.ReportResponse;
import com.bwvr.backend.entity.BwvrReport;
import com.bwvr.backend.entity.BwvrReportValue;
import com.bwvr.backend.entity.BwvrTemplate;
import com.bwvr.backend.entity.BwvrTemplatePlaceholder;
import com.bwvr.backend.exception.ResourceNotFoundException;
import com.bwvr.backend.repository.ReportRepository;
import com.bwvr.backend.repository.ReportValueRepository;
import com.bwvr.backend.repository.TemplatePlaceholderRepository;
import com.bwvr.backend.repository.TemplateRepository;
import com.bwvr.backend.util.ReferenceNumberGenerator;

@Service
@SuppressWarnings("null")
public class ReportService {

    private static final Logger log = LoggerFactory.getLogger(ReportService.class);

    private final ReportRepository reportRepository;
    private final ReportValueRepository reportValueRepository;
    private final TemplateRepository templateRepository;
    private final TemplatePlaceholderRepository placeholderRepository;
    private final ReferenceNumberGenerator referenceNumberGenerator;
    private final DocxGeneratorService docxGeneratorService;
    private final AuditService auditService;

    public ReportService(ReportRepository reportRepository,
            ReportValueRepository reportValueRepository,
            TemplateRepository templateRepository,
            TemplatePlaceholderRepository placeholderRepository,
            ReferenceNumberGenerator referenceNumberGenerator,
            DocxGeneratorService docxGeneratorService,
            AuditService auditService) {
        this.reportRepository = reportRepository;
        this.reportValueRepository = reportValueRepository;
        this.templateRepository = templateRepository;
        this.placeholderRepository = placeholderRepository;
        this.referenceNumberGenerator = referenceNumberGenerator;
        this.docxGeneratorService = docxGeneratorService;
        this.auditService = auditService;
    }

    @Transactional
    public ReportResponse createReport(CreateReportRequest request) {
        BwvrTemplate template = templateRepository.findById(request.getTemplateId())
                .filter(t -> "Y".equals(t.getIsActive()))
                .orElseThrow(() -> new ResourceNotFoundException("Template", request.getTemplateId()));

        String refNum = referenceNumberGenerator.generate();

        BwvrReport report = BwvrReport.builder()
                .referenceNumber(refNum)
                .template(template)
                .reportTitle(request.getReportTitle())
                .vendorName(request.getVendorName())
                .location(request.getLocation())
                .bankName(template.getBankName())
                .reportStatus("DRAFT")
                .createdBy(request.getCreatedBy() != null ? request.getCreatedBy() : "SYSTEM")
                .build();

        report = reportRepository.save(report);

        auditService.log("REPORT", report.getReportId(), "CREATE",
                request.getCreatedBy(), null, null, null,
                "Report created: " + refNum);

        log.info("Created report {} with reference {}", report.getReportId(), refNum);
        return toReportResponse(report);
    }

    @Transactional(readOnly = true)
    public Page<ReportResponse> searchReports(String search, String vendorName, String location,
            String bankName, String status, int page, int size, String createdByFilter) {
        PageRequest pageable = PageRequest.of(page, size); // ORDER BY is inside the native SQL query
        if (createdByFilter != null) {
            // User can only see their own reports
            return reportRepository.searchReportsFiltered(
                    createdByFilter,
                    nullIfBlank(search), nullIfBlank(vendorName),
                    nullIfBlank(location), nullIfBlank(bankName),
                    nullIfBlank(status), pageable)
                    .map(this::toReportResponse);
        }
        return reportRepository.searchReports(
                nullIfBlank(search), nullIfBlank(vendorName),
                nullIfBlank(location), nullIfBlank(bankName),
                nullIfBlank(status), pageable)
                .map(this::toReportResponse);
    }

    @Transactional(readOnly = true)
    public ReportDetailResponse getReportDetail(Long reportId) {
        BwvrReport report = findActiveReport(reportId);
        return buildDetailResponse(report);
    }

    @Transactional(readOnly = true)
    public ReportDetailResponse getReportByRefNumber(String referenceNumber) {
        BwvrReport report = reportRepository
                .findByReferenceNumberAndIsDeleted(referenceNumber, "N")
                .orElseThrow(() -> new ResourceNotFoundException(
                "Report not found with reference: " + referenceNumber));
        return buildDetailResponse(report);
    }

    @Transactional
    public ReportResponse updateReport(Long reportId, UpdateReportRequest req) {
        BwvrReport report = findActiveReport(reportId);
        String oldStatus = report.getReportStatus();

        if (req.getReportTitle() != null) {
            report.setReportTitle(req.getReportTitle());
        }
        if (req.getVendorName() != null) {
            report.setVendorName(req.getVendorName());
        }
        if (req.getLocation() != null) {
            report.setLocation(req.getLocation());
        }
        if (req.getReportStatus() != null) {
            report.setReportStatus(req.getReportStatus());
        }
        if (req.getUpdatedBy() != null) {
            report.setUpdatedBy(req.getUpdatedBy());
        }

        report = reportRepository.save(report);

        auditService.log("REPORT", reportId, "UPDATE", req.getUpdatedBy(),
                "{\"status\":\"" + oldStatus + "\"}",
                "{\"status\":\"" + report.getReportStatus() + "\"}",
                null, "Report updated");

        return toReportResponse(report);
    }

    @Transactional
    public void saveReportValues(Long reportId, SaveReportValuesRequest request) {
        BwvrReport report = findActiveReport(reportId);

        for (var dto : request.getValues()) {
            BwvrTemplatePlaceholder placeholder = placeholderRepository.findById(dto.getPlaceholderId())
                    .orElseThrow(() -> new ResourceNotFoundException("Placeholder", dto.getPlaceholderId()));

            Optional<BwvrReportValue> existing = reportValueRepository
                    .findByReport_ReportIdAndPlaceholder_PlaceholderId(reportId, dto.getPlaceholderId());

            BwvrReportValue value = existing.orElseGet(() -> BwvrReportValue.builder()
                    .report(report)
                    .placeholder(placeholder)
                    .placeholderKey(dto.getPlaceholderKey() != null ? dto.getPlaceholderKey() : placeholder.getPlaceholderKey())
                    .build());

            value.setTextValue(dto.getTextValue());
            if (dto.getImageFilePath() != null) {
                value.setImageFilePath(dto.getImageFilePath());
            }
            if (dto.getImageOriginalName() != null) {
                value.setImageOriginalName(dto.getImageOriginalName());
            }

            reportValueRepository.save(value);
        }

        // Update report status if it's still DRAFT
        if ("DRAFT".equals(report.getReportStatus())) {
            report.setReportStatus("IN_PROGRESS");
            reportRepository.save(report);
        }

        auditService.log("REPORT", reportId, "UPDATE", request.getUpdatedBy(),
                null, null, null, "Values saved");
    }

    @Transactional
    public String generateDocument(Long reportId) {
        String outputPath = docxGeneratorService.generateDocument(reportId);

        BwvrReport report = findActiveReport(reportId);
        report.setGeneratedFilePath(outputPath);
        report.setGeneratedAt(LocalDateTime.now());
        report.setReportStatus("COMPLETED");
        reportRepository.save(report);

        auditService.log("REPORT", reportId, "GENERATE", "SYSTEM",
                null, null, null, "Document generated: " + outputPath);
        return outputPath;
    }

    @Transactional
    public void deleteReport(Long reportId, String deletedBy) {
        BwvrReport report = findActiveReport(reportId);
        try {
            reportRepository.delete(report);
            auditService.log("REPORT", reportId, "DELETE", deletedBy,
                    null, null, null, "Hard deleted");
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            throw new com.bwvr.backend.exception.ConflictException("Cannot delete report due to constraints.");
        }
    }

    @Transactional(readOnly = true)
    public String getReportFilePath(Long reportId) {
        BwvrReport report = findActiveReport(reportId);
        return report.getGeneratedFilePath();
    }

    @Transactional(readOnly = true)
    public DashboardStatsResponse getDashboardStats(String username, boolean isAdmin) {
        long now = LocalDate.now().getMonthValue();
        int year = LocalDate.now().getYear();
        if (isAdmin || username == null) {
            return DashboardStatsResponse.builder()
                    .totalReports(reportRepository.countByIsDeleted("N"))
                    .reportsThisMonth(reportRepository.countByMonthAndYear((int) now, year))
                    .activeTemplates(templateRepository.countByIsActive("Y"))
                    .distinctBanks(reportRepository.countDistinctBanks())
                    .build();
        } else {
            return DashboardStatsResponse.builder()
                    .totalReports(reportRepository.countByCreatedByAndIsDeleted(username, "N"))
                    .reportsThisMonth(reportRepository.countByCreatedByAndMonthAndYear(username, (int) now, year))
                    .activeTemplates(templateRepository.countByIsActive("Y"))
                    .distinctBanks(reportRepository.countDistinctBanks())
                    .build();
        }
    }

    // ──────────────────────────── Private Helpers ────────────────────────────
    private BwvrReport findActiveReport(Long reportId) {
        return reportRepository.findById(reportId)
                .filter(r -> "N".equals(r.getIsDeleted()))
                .orElseThrow(() -> new ResourceNotFoundException("Report", reportId));
    }

    private ReportDetailResponse buildDetailResponse(BwvrReport report) {
        List<BwvrReportValue> values = reportValueRepository.findByReport_ReportId(report.getReportId());
        List<BwvrTemplatePlaceholder> allPlaceholders
                = placeholderRepository.findByTemplate_TemplateIdOrderByDisplayOrder(report.getTemplate().getTemplateId());

        Map<Long, BwvrReportValue> valueByPlaceholderId = values.stream()
                .collect(Collectors.toMap(v -> v.getPlaceholder().getPlaceholderId(), v -> v));

        List<ReportDetailResponse.ReportValueResponse> valueResponses = allPlaceholders.stream()
                .map(ph -> {
                    BwvrReportValue val = valueByPlaceholderId.get(ph.getPlaceholderId());
                    return ReportDetailResponse.ReportValueResponse.builder()
                            .valueId(val != null ? val.getValueId() : null)
                            .placeholderId(ph.getPlaceholderId())
                            .placeholderKey(ph.getPlaceholderKey())
                            .placeholderPrefix(ph.getPlaceholderPrefix())
                            .displayLabel(ph.getDisplayLabel())
                            .questionText(ph.getQuestionText())
                            .fieldType(ph.getFieldType())
                            .textValue(val != null ? val.getTextValue() : null)
                            .imageFilePath(val != null ? val.getImageFilePath() : null)
                            .imageOriginalName(val != null ? val.getImageOriginalName() : null)
                            .hasImageData(val != null && val.getImageData() != null)
                            .displayOrder(ph.getDisplayOrder())
                            .tableContext(ph.getTableContext())
                            .col1Header(ph.getCol1Header())
                            .col2Header(ph.getCol2Header())
                            .build();
                })
                .collect(Collectors.toList());

        return ReportDetailResponse.builder()
                .reportId(report.getReportId())
                .referenceNumber(report.getReferenceNumber())
                .templateId(report.getTemplate().getTemplateId())
                .templateName(report.getTemplate().getTemplateName())
                .templateFileName(report.getTemplate().getTemplateFileName())
                .reportTitle(report.getReportTitle())
                .vendorName(report.getVendorName())
                .location(report.getLocation())
                .bankName(report.getBankName())
                .reportStatus(report.getReportStatus())
                .generatedAt(report.getGeneratedAt())
                .createdBy(report.getCreatedBy())
                .createdAt(report.getCreatedAt())
                .updatedBy(report.getUpdatedBy())
                .updatedAt(report.getUpdatedAt())
                .hasGeneratedFile(report.getGeneratedFilePath() != null)
                .values(valueResponses)
                .build();
    }

    private ReportResponse toReportResponse(BwvrReport r) {
        long valuesCount = reportValueRepository.countByReport_ReportId(r.getReportId());
        long totalPlaceholders = placeholderRepository.countByTemplate_TemplateId(r.getTemplate().getTemplateId());
        return ReportResponse.builder()
                .reportId(r.getReportId())
                .referenceNumber(r.getReferenceNumber())
                .templateId(r.getTemplate().getTemplateId())
                .templateName(r.getTemplate().getTemplateName())
                .reportTitle(r.getReportTitle())
                .vendorName(r.getVendorName())
                .location(r.getLocation())
                .bankName(r.getBankName())
                .reportStatus(r.getReportStatus())
                .generatedAt(r.getGeneratedAt())
                .createdBy(r.getCreatedBy())
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .valuesCount(valuesCount)
                .totalPlaceholders(totalPlaceholders)
                .hasGeneratedFile(r.getGeneratedFilePath() != null)
                .build();
    }

    private String nullIfBlank(String s) {
        return (s == null || s.isBlank()) ? null : s;
    }
}
