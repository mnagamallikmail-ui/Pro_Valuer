package com.bwvr.backend.dto;

import java.time.LocalDateTime;
import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

import com.bwvr.backend.dto.request.ConfirmPlaceholdersRequest;
import com.bwvr.backend.dto.request.CreateReportRequest;
import com.bwvr.backend.dto.request.PlaceholderValueDto;
import com.bwvr.backend.dto.request.SaveReportValuesRequest;
import com.bwvr.backend.dto.request.UpdateReportRequest;
import com.bwvr.backend.dto.response.ApiResponse;
import com.bwvr.backend.dto.response.DashboardStatsResponse;
import com.bwvr.backend.dto.response.ParsedTemplateResponse;
import com.bwvr.backend.dto.response.PlaceholderResponse;
import com.bwvr.backend.dto.response.ReportDetailResponse;
import com.bwvr.backend.dto.response.ReportResponse;
import com.bwvr.backend.dto.response.TemplateResponse;

class DtoTest {

    @Test
    void testApiResponse() {
        ApiResponse<String> success = ApiResponse.success("D", "M");
        assertThat(success.isSuccess()).isTrue();
        assertThat(success.getData()).isEqualTo("D");
        assertThat(success.getMessage()).isEqualTo("M");

        ApiResponse<Object> error = ApiResponse.error("E", "400");
        assertThat(error.isSuccess()).isFalse();
        assertThat(error.getError()).isEqualTo("E");
        assertThat(error.getCode()).isEqualTo("400");

        ApiResponse<String> s2 = new ApiResponse<>();
        s2.setSuccess(true);
        s2.setData("X");
        s2.setMessage("Y");
        s2.setError("Z");
        s2.setCode("C");
        assertThat(s2.getData()).isEqualTo("X");
    }

    @Test
    void testDashboardStatsResponse() {
        DashboardStatsResponse stats = DashboardStatsResponse.builder()
                .totalReports(1L)
                .reportsThisMonth(2L)
                .activeTemplates(3L)
                .distinctBanks(4L)
                .draftReports(5L)
                .completedReports(6L)
                .build();
        assertThat(stats.getTotalReports()).isEqualTo(1L);

        DashboardStatsResponse s2 = new DashboardStatsResponse();
        s2.setTotalReports(10L);
        s2.setReportsThisMonth(20L);
        s2.setActiveTemplates(30L);
        s2.setDistinctBanks(40L);
        s2.setDraftReports(50L);
        s2.setCompletedReports(60L);
        assertThat(s2.getTotalReports()).isEqualTo(10L);
    }

    @Test
    void testPlaceholderResponse() {
        LocalDateTime now = LocalDateTime.now();
        PlaceholderResponse ph = PlaceholderResponse.builder()
                .placeholderId(1L).templateId(2L).placeholderKey("K").placeholderPrefix("P")
                .displayLabel("L").questionText("Q").fieldType("F").sectionName("S")
                .isRequired("Y").displayOrder(1).tableContext("C").col1Header("H1").col2Header("H2")
                .isConfirmed("Y").createdAt(now)
                .widthInches(1.0).heightInches(2.0).widthEmu(100L).heightEmu(200L).pagePosition("POS")
                .build();

        assertThat(ph.getPlaceholderId()).isEqualTo(1L);

        PlaceholderResponse p2 = new PlaceholderResponse();
        p2.setPlaceholderId(1L);
        p2.setTemplateId(1L);
        p2.setPlaceholderKey("K");
        p2.setPlaceholderPrefix("P");
        p2.setDisplayLabel("L");
        p2.setQuestionText("Q");
        p2.setFieldType("F");
        p2.setSectionName("S");
        p2.setIsRequired("Y");
        p2.setDisplayOrder(1);
        p2.setTableContext("C");
        p2.setCol1Header("C");
        p2.setCol2Header("H");
        p2.setIsConfirmed("Y");
        p2.setCreatedAt(null);
        p2.setWidthInches(0.0);
        p2.setHeightInches(0.0);
        p2.setWidthEmu(0L);
        p2.setHeightEmu(0L);
        p2.setPagePosition(null);
    }

    @Test
    void testReportDetailResponse() {
        ReportDetailResponse.ReportValueResponse val = ReportDetailResponse.ReportValueResponse.builder()
                .valueId(10L).placeholderId(20L).placeholderKey("K").placeholderPrefix("P")
                .displayLabel("L").questionText("Q").fieldType("F").textValue("V")
                .imageFilePath("P").imageOriginalName("O").displayOrder(1)
                .tableContext("T").col1Header("C1").col2Header("C2").hasImageData(true)
                .build();

        ReportDetailResponse detail = ReportDetailResponse.builder()
                .reportId(1L).referenceNumber("R").templateId(2L).templateName("TN").templateFileName("TF")
                .reportTitle("T").vendorName("V").location("L").bankName("B").reportStatus("S")
                .generatedAt(LocalDateTime.now()).createdBy("CB").createdAt(LocalDateTime.now())
                .updatedBy("UB").updatedAt(LocalDateTime.now()).hasGeneratedFile(true)
                .values(Collections.singletonList(val))
                .allPlaceholders(Collections.emptyList()).build();

        assertThat(detail.getReportId()).isEqualTo(1L);

        ReportDetailResponse d2 = new ReportDetailResponse();
        d2.setReportId(1L);
        d2.setReferenceNumber("R");
        d2.setTemplateId(1L);
        d2.setTemplateName("N");
        d2.setTemplateFileName("F");
        d2.setReportTitle("T");
        d2.setVendorName("V");
        d2.setLocation("L");
        d2.setBankName("B");
        d2.setReportStatus("S");
        d2.setGeneratedAt(null);
        d2.setCreatedBy(null);
        d2.setCreatedAt(null);
        d2.setUpdatedBy(null);
        d2.setUpdatedAt(null);
        d2.setHasGeneratedFile(false);
        d2.setValues(null);
        d2.setAllPlaceholders(null);

        ReportDetailResponse.ReportValueResponse v2 = new ReportDetailResponse.ReportValueResponse();
        v2.setValueId(1L);
        v2.setPlaceholderId(1L);
        v2.setPlaceholderKey("K");
        v2.setPlaceholderPrefix("P");
        v2.setDisplayLabel("L");
        v2.setQuestionText("Q");
        v2.setFieldType("F");
        v2.setTextValue("V");
        v2.setImageFilePath("P");
        v2.setImageOriginalName("O");
        v2.setHasImageData(false);
        v2.setDisplayOrder(1);
        v2.setTableContext("T");
        v2.setCol1Header("C");
        v2.setCol2Header("H");
    }

    @Test
    void testTemplateResponse() {
        TemplateResponse t = TemplateResponse.builder()
                .templateId(1L).bankName("B").templateName("N").templateFileName("F")
                .templateVersion("V").parsedStatus("P").isActive("Y").createdBy("C")
                .createdAt(LocalDateTime.now()).updatedAt(LocalDateTime.now())
                .placeholderCount(10L).build();

        assertThat(t.getTemplateId()).isEqualTo(1L);

        TemplateResponse t2 = new TemplateResponse();
        t2.setTemplateId(1L);
        t2.setBankName("B");
        t2.setTemplateName("N");
        t2.setTemplateFileName("F");
        t2.setTemplateVersion("V");
        t2.setParsedStatus("P");
        t2.setIsActive("Y");
        t2.setCreatedBy("C");
        t2.setCreatedAt(null);
        t2.setUpdatedAt(null);
        t2.setPlaceholderCount(0L);
    }

    @Test
    void testReportResponse() {
        ReportResponse r = ReportResponse.builder()
                .reportId(1L).referenceNumber("R").templateId(2L).templateName("TN")
                .reportTitle("T").vendorName("V").location("L").bankName("B")
                .reportStatus("S").generatedAt(LocalDateTime.now()).createdBy("CB")
                .createdAt(LocalDateTime.now()).updatedAt(LocalDateTime.now())
                .valuesCount(10L).totalPlaceholders(20L).hasGeneratedFile(true)
                .build();

        assertThat(r.getReportId()).isEqualTo(1L);

        ReportResponse r2 = new ReportResponse();
        r2.setReportId(1L);
        r2.setReferenceNumber("R");
        r2.setTemplateId(1L);
        r2.setTemplateName("N");
        r2.setReportTitle("T");
        r2.setVendorName("V");
        r2.setLocation("L");
        r2.setBankName("B");
        r2.setReportStatus("S");
        r2.setGeneratedAt(null);
        r2.setCreatedBy(null);
        r2.setCreatedAt(null);
        r2.setUpdatedAt(null);
        r2.setValuesCount(0L);
        r2.setTotalPlaceholders(0L);
        r2.setHasGeneratedFile(false);
    }

    @Test
    void testParsedTemplateResponse() {
        ParsedTemplateResponse.ImageSlotResponse slot = ParsedTemplateResponse.ImageSlotResponse.builder()
                .imageSlotId(1L).placeholderKey("K").widthEmu(100L).heightEmu(200L)
                .widthInches(1.0).heightInches(2.0).widthPixels(10).heightPixels(20)
                .pagePosition("POS").build();

        ParsedTemplateResponse r = ParsedTemplateResponse.builder()
                .templateId(1L).bankName("B").templateName("N").parsedStatus("P")
                .placeholders(Collections.emptyList()).imageSlots(Collections.singletonList(slot))
                .totalPlaceholders(1).textCount(1).dateCount(0).imageCount(1).build();

        assertThat(r.getTemplateId()).isEqualTo(1L);

        ParsedTemplateResponse r2 = new ParsedTemplateResponse();
        r2.setTemplateId(1L);
        r2.setBankName("B");
        r2.setTemplateName("N");
        r2.setParsedStatus("P");
        r2.setPlaceholders(null);
        r2.setImageSlots(null);
        r2.setTotalPlaceholders(0);
        r2.setTextCount(0);
        r2.setDateCount(0);
        r2.setImageCount(0);

        ParsedTemplateResponse.ImageSlotResponse s2 = new ParsedTemplateResponse.ImageSlotResponse();
        s2.setImageSlotId(1L);
        s2.setPlaceholderKey("K");
        s2.setWidthEmu(0L);
        s2.setHeightEmu(0L);
        s2.setWidthInches(0.0);
        s2.setHeightInches(0.0);
        s2.setWidthPixels(0);
        s2.setHeightPixels(0);
        s2.setPagePosition(null);
    }

    @Test
    void testConfirmPlaceholdersRequest_InnerDto() {
        ConfirmPlaceholdersRequest.PlaceholderUpdateDto dto = new ConfirmPlaceholdersRequest.PlaceholderUpdateDto();
        dto.setPlaceholderId(1L);
        dto.setQuestionText("Q");
        dto.setDisplayLabel("L");
        dto.setFieldType("F");
        dto.setIsRequired(true);

        assertThat(dto.getPlaceholderId()).isEqualTo(1L);
    }

    @Test
    void testUpdateReportRequest() {
        UpdateReportRequest r = new UpdateReportRequest();
        r.setReportTitle("T");
        r.setVendorName("V");
        r.setLocation("L");
        assertThat(r.getReportTitle()).isEqualTo("T");
    }

    @Test
    void testPlaceholderValueDto() {
        PlaceholderValueDto d = new PlaceholderValueDto();
        d.setPlaceholderKey("K");
        d.setTextValue("V");
        assertThat(d.getPlaceholderKey()).isEqualTo("K");
    }

    @Test
    void testCreateReportRequest() {
        CreateReportRequest r = new CreateReportRequest();
        r.setTemplateId(1L);
        r.setReportTitle("T");
        r.setVendorName("V");
        r.setLocation("L");
        r.setCreatedBy("C");
        assertThat(r.getTemplateId()).isEqualTo(1L);
    }

    @Test
    void testSaveReportValuesRequest() {
        SaveReportValuesRequest r = new SaveReportValuesRequest();
        r.setValues(Collections.emptyList());
        r.setUpdatedBy("U");
        assertThat(r.getUpdatedBy()).isEqualTo("U");
    }
}
