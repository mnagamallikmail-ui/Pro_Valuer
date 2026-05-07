package com.bwvr.backend.service;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatNoException;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;

import com.bwvr.backend.dto.request.CreateReportRequest;
import com.bwvr.backend.dto.request.PlaceholderValueDto;
import com.bwvr.backend.dto.request.SaveReportValuesRequest;
import com.bwvr.backend.dto.request.UpdateReportRequest;
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

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class ReportServiceTest {

    @Mock
    ReportRepository reportRepository;
    @Mock
    ReportValueRepository reportValueRepository;
    @Mock
    TemplateRepository templateRepository;
    @Mock
    TemplatePlaceholderRepository placeholderRepository;
    @Mock
    ReferenceNumberGenerator referenceNumberGenerator;
    @Mock
    DocxGeneratorService docxGeneratorService;
    @Mock
    AuditService auditService;

    @InjectMocks
    ReportService reportService;

    private BwvrTemplate template;
    private BwvrReport report;

    @BeforeEach
    public void setUp() {
        template = BwvrTemplate.builder()
                .templateId(1L).bankName("TestBank").templateName("T1")
                .templateFileName("t1.docx").isActive("Y").build();

        report = BwvrReport.builder()
                .reportId(10L).referenceNumber("10001")
                .template(template).reportTitle("Test Report")
                .vendorName("Vendor A").location("City")
                .bankName("TestBank").reportStatus("DRAFT")
                .isDeleted("N").createdBy("user1").build();
    }

    // ── createReport ─────────────────────────────────────────────────────────
    @Test
    void createReport_success() {
        when(templateRepository.findById(1L)).thenReturn(Optional.of(template));
        when(referenceNumberGenerator.generate()).thenReturn("10001");
        when(reportRepository.save(any())).thenReturn(report);
        when(reportValueRepository.countByReport_ReportId(any())).thenReturn(0L);
        when(placeholderRepository.countByTemplate_TemplateId(any())).thenReturn(5L);

        CreateReportRequest req = new CreateReportRequest();
        req.setTemplateId(1L);
        req.setReportTitle("Test Report");
        req.setVendorName("Vendor A");
        req.setLocation("City");
        req.setCreatedBy("user1");

        ReportResponse resp = reportService.createReport(req);
        assertThat(resp.getReferenceNumber()).isEqualTo("10001");
        verify(auditService).log(eq("REPORT"), any(), eq("CREATE"), eq("user1"), any(), any(), any(), any());
    }

    @Test
    void createReport_nullCreatedBy_defaultsToSYSTEM() {
        when(templateRepository.findById(1L)).thenReturn(Optional.of(template));
        when(referenceNumberGenerator.generate()).thenReturn("10002");
        when(reportRepository.save(any())).thenReturn(report);
        when(reportValueRepository.countByReport_ReportId(any())).thenReturn(0L);
        when(placeholderRepository.countByTemplate_TemplateId(any())).thenReturn(0L);

        CreateReportRequest req = new CreateReportRequest();
        req.setTemplateId(1L);
        req.setCreatedBy(null);

        assertThatNoException().isThrownBy(() -> reportService.createReport(req));
    }

    @Test
    void createReport_inactiveTemplate_throws() {
        template.setIsActive("N");
        when(templateRepository.findById(1L)).thenReturn(Optional.of(template));

        CreateReportRequest req = new CreateReportRequest();
        req.setTemplateId(1L);

        assertThatThrownBy(() -> reportService.createReport(req))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void createReport_templateNotFound_throws() {
        when(templateRepository.findById(99L)).thenReturn(Optional.empty());

        CreateReportRequest req = new CreateReportRequest();
        req.setTemplateId(99L);

        assertThatThrownBy(() -> reportService.createReport(req))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // ── getReportDetail ───────────────────────────────────────────────────────
    @Test
    void getReportDetail_success() {
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportId(10L)).thenReturn(List.of());
        when(placeholderRepository.findByTemplate_TemplateIdOrderByDisplayOrder(1L)).thenReturn(List.of());

        ReportDetailResponse resp = reportService.getReportDetail(10L);
        assertThat(resp.getReportId()).isEqualTo(10L);
        assertThat(resp.getReportStatus()).isEqualTo("DRAFT");
    }

    @Test
    void getReportDetail_deletedReport_throws() {
        report.setIsDeleted("Y");
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));

        assertThatThrownBy(() -> reportService.getReportDetail(10L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void getReportDetail_withValues_mapsHasImageData() {
        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder()
                .placeholderId(5L).template(template).placeholderKey("IMG_FRONT")
                .placeholderPrefix("IMG").displayLabel("Front").questionText("Front img?")
                .fieldType("IMAGE").displayOrder(1).build();

        BwvrReportValue val = BwvrReportValue.builder()
                .valueId(1L).report(report).placeholder(ph)
                .placeholderKey("IMG_FRONT")
                .imageData(new byte[]{1, 2, 3}).build();

        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportId(10L)).thenReturn(List.of(val));
        when(placeholderRepository.findByTemplate_TemplateIdOrderByDisplayOrder(1L)).thenReturn(List.of(ph));

        ReportDetailResponse resp = reportService.getReportDetail(10L);
        assertThat(resp.getValues()).hasSize(1);
        assertThat(resp.getValues().get(0).isHasImageData()).isTrue();
    }

    // ── updateReport ──────────────────────────────────────────────────────────
    @Test
    void updateReport_updatesFields() {
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(reportRepository.save(any())).thenReturn(report);
        when(reportValueRepository.countByReport_ReportId(any())).thenReturn(2L);
        when(placeholderRepository.countByTemplate_TemplateId(any())).thenReturn(5L);

        UpdateReportRequest req = new UpdateReportRequest();
        req.setReportTitle("Updated Title");
        req.setVendorName("New Vendor");
        req.setLocation("New City");
        req.setReportStatus("IN_PROGRESS");
        req.setUpdatedBy("admin");

        ReportResponse resp = reportService.updateReport(10L, req);
        assertThat(resp).isNotNull();
        verify(auditService).log(eq("REPORT"), eq(10L), eq("UPDATE"), eq("admin"), any(), any(), any(), any());
    }

    @Test
    void updateReport_nullFields_doesNotOverwrite() {
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(reportRepository.save(any())).thenReturn(report);
        when(reportValueRepository.countByReport_ReportId(any())).thenReturn(0L);
        when(placeholderRepository.countByTemplate_TemplateId(any())).thenReturn(5L);

        UpdateReportRequest req = new UpdateReportRequest();
        // all fields null — nothing should change

        assertThatNoException().isThrownBy(() -> reportService.updateReport(10L, req));
    }

    // ── saveReportValues ──────────────────────────────────────────────────────
    @Test
    void saveReportValues_createsNewValue() {
        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder()
                .placeholderId(5L).template(template).placeholderKey("VENDOR_NAME")
                .placeholderPrefix("TEXT").displayLabel("Vendor").questionText("q?")
                .fieldType("TEXT").displayOrder(1).build();

        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(placeholderRepository.findById(5L)).thenReturn(Optional.of(ph));
        when(reportValueRepository.findByReport_ReportIdAndPlaceholder_PlaceholderId(10L, 5L))
                .thenReturn(Optional.empty());
        when(reportValueRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        PlaceholderValueDto dto = new PlaceholderValueDto();
        dto.setPlaceholderId(5L);
        dto.setPlaceholderKey("VENDOR_NAME");
        dto.setTextValue("Vendor XYZ");

        SaveReportValuesRequest req = new SaveReportValuesRequest();
        req.setValues(List.of(dto));
        req.setUpdatedBy("user1");

        assertThatNoException().isThrownBy(() -> reportService.saveReportValues(10L, req));
        verify(reportValueRepository, atLeastOnce()).save(any());
    }

    @Test
    void saveReportValues_updatesExistingValue() {
        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder()
                .placeholderId(5L).template(template).placeholderKey("VENDOR_NAME")
                .placeholderPrefix("TEXT").displayLabel("Vendor").questionText("q?")
                .fieldType("TEXT").displayOrder(1).build();

        BwvrReportValue existing = BwvrReportValue.builder()
                .valueId(1L).report(report).placeholder(ph)
                .placeholderKey("VENDOR_NAME").textValue("Old Value").build();

        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(placeholderRepository.findById(5L)).thenReturn(Optional.of(ph));
        when(reportValueRepository.findByReport_ReportIdAndPlaceholder_PlaceholderId(10L, 5L))
                .thenReturn(Optional.of(existing));
        when(reportValueRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        PlaceholderValueDto dto = new PlaceholderValueDto();
        dto.setPlaceholderId(5L);
        dto.setPlaceholderKey("VENDOR_NAME");
        dto.setTextValue("New Value");
        dto.setImageFilePath("/some/path.jpg");
        dto.setImageOriginalName("photo.jpg");

        SaveReportValuesRequest req = new SaveReportValuesRequest();
        req.setValues(List.of(dto));

        assertThatNoException().isThrownBy(() -> reportService.saveReportValues(10L, req));
    }

    @Test
    void saveReportValues_draftBecomesInProgress() {
        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder()
                .placeholderId(5L).template(template).placeholderKey("X")
                .placeholderPrefix("TEXT").displayLabel("X").questionText("q?")
                .fieldType("TEXT").displayOrder(1).build();

        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(placeholderRepository.findById(5L)).thenReturn(Optional.of(ph));
        when(reportValueRepository.findByReport_ReportIdAndPlaceholder_PlaceholderId(any(), any()))
                .thenReturn(Optional.empty());
        when(reportValueRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(reportRepository.save(any())).thenReturn(report);

        PlaceholderValueDto dto = new PlaceholderValueDto();
        dto.setPlaceholderId(5L);

        SaveReportValuesRequest req = new SaveReportValuesRequest();
        req.setValues(List.of(dto));

        reportService.saveReportValues(10L, req);
        verify(reportRepository, atLeastOnce()).save(argThat(r -> "IN_PROGRESS".equals(r.getReportStatus())));
    }

    @Test
    void saveReportValues_nonDraftStatus_doesNotChangeStatus() {
        report.setReportStatus("IN_PROGRESS");

        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder()
                .placeholderId(5L).template(template).placeholderKey("X")
                .placeholderPrefix("TEXT").displayLabel("X").questionText("q?")
                .fieldType("TEXT").displayOrder(1).build();

        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(placeholderRepository.findById(5L)).thenReturn(Optional.of(ph));
        when(reportValueRepository.findByReport_ReportIdAndPlaceholder_PlaceholderId(any(), any()))
                .thenReturn(Optional.empty());
        when(reportValueRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        PlaceholderValueDto dto = new PlaceholderValueDto();
        dto.setPlaceholderId(5L);
        SaveReportValuesRequest req = new SaveReportValuesRequest();
        req.setValues(List.of(dto));

        reportService.saveReportValues(10L, req);
        // reportRepository.save should NOT be called for the status update
        verify(reportRepository, never()).save(any());
    }

    // ── generateDocument ──────────────────────────────────────────────────────
    @Test
    void generateDocument_setsPathAndStatus() {
        when(docxGeneratorService.generateDocument(10L)).thenReturn("/output/report.docx");
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(reportRepository.save(any())).thenReturn(report);

        String path = reportService.generateDocument(10L);
        assertThat(path).isEqualTo("/output/report.docx");
        verify(reportRepository).save(argThat(r -> "COMPLETED".equals(r.getReportStatus())));
    }

    // ── deleteReport ──────────────────────────────────────────────────────────
    @Test
    void deleteReport_hardDeletesReport() {
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));

        reportService.deleteReport(10L, "admin");

        verify(reportRepository).delete(report);
        verify(auditService).log(eq("REPORT"), eq(10L), eq("DELETE"), eq("admin"), any(), any(), any(), any());
    }

    // ── getReportFilePath ─────────────────────────────────────────────────────
    @Test
    void getReportFilePath_returnsPath() {
        report.setGeneratedFilePath("/output/report.docx");
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));

        String path = reportService.getReportFilePath(10L);
        assertThat(path).isEqualTo("/output/report.docx");
    }

    // ── searchReports ─────────────────────────────────────────────────────────
    @Test
    void searchReports_returnsPagedResults() {
        when(reportRepository.searchReports(any(), any(), any(), any(), any(), any()))
                .thenReturn(new PageImpl<>(List.of(report)));
        when(reportValueRepository.countByReport_ReportId(any())).thenReturn(2L);
        when(placeholderRepository.countByTemplate_TemplateId(any())).thenReturn(5L);

        Page<ReportResponse> page = reportService.searchReports(
                "test", null, null, null, null, 0, 10, null);
        assertThat(page.getTotalElements()).isEqualTo(1);
    }

    @Test
    void searchReports_blankStrings_treatedAsNull() {
        when(reportRepository.searchReports(isNull(), isNull(), isNull(), isNull(), isNull(), any()))
                .thenReturn(Page.empty());

        Page<ReportResponse> page = reportService.searchReports(
                "  ", "  ", "  ", "  ", "  ", 0, 10, null);
        assertThat(page).isEmpty();
    }

    // ── getDashboardStats ─────────────────────────────────────────────────────
    @Test
    void getDashboardStats_returnsCounts() {
        when(reportRepository.countByIsDeleted("N")).thenReturn(5L);
        when(reportRepository.countByMonthAndYear(anyInt(), anyInt())).thenReturn(2L);
        when(templateRepository.countByIsActive("Y")).thenReturn(3L);
        when(reportRepository.countDistinctBanks()).thenReturn(2L);

        var stats = reportService.getDashboardStats(null, true);
        assertThat(stats.getTotalReports()).isEqualTo(5L);
        assertThat(stats.getReportsThisMonth()).isEqualTo(2L);
        assertThat(stats.getActiveTemplates()).isEqualTo(3L);
        assertThat(stats.getDistinctBanks()).isEqualTo(2L);
    }

    // ── getReportByRefNumber ──────────────────────────────────────────────────
    @Test
    void getReportByRefNumber_found() {
        when(reportRepository.findByReferenceNumberAndIsDeleted("REF-001", "N"))
                .thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportId(any())).thenReturn(List.of());
        when(placeholderRepository.findByTemplate_TemplateIdOrderByDisplayOrder(any())).thenReturn(List.of());

        ReportDetailResponse resp = reportService.getReportByRefNumber("REF-001");
        assertThat(resp.getReferenceNumber()).isEqualTo("10001");
    }

    @Test
    void getReportByRefNumber_notFound_throws() {
        when(reportRepository.findByReferenceNumberAndIsDeleted("MISSING", "N"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> reportService.getReportByRefNumber("MISSING"))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}

