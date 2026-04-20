package com.bwvr.backend.controller;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bwvr.backend.dto.request.CreateReportRequest;
import com.bwvr.backend.dto.request.SaveReportValuesRequest;
import com.bwvr.backend.dto.response.ReportDetailResponse;
import com.bwvr.backend.dto.response.ReportResponse;
import com.bwvr.backend.service.ReportService;
import org.springframework.security.test.context.support.WithMockUser;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;

@WebMvcTest(value = ReportController.class, properties = "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration,org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration")
@AutoConfigureMockMvc(addFilters = false)
@WithMockUser(username = "user1", roles = "USER")
class ReportControllerTest {
    
    @MockBean
    com.bwvr.backend.security.UserDetailsServiceImpl userDetailsService;
    @MockBean
    com.bwvr.backend.security.JwtUtil jwtUtil;
    @MockBean
    com.bwvr.backend.security.JwtAuthFilter jwtAuthFilter;
    @MockBean
    org.springframework.web.cors.CorsConfigurationSource corsConfigurationSource;

    @Autowired
    MockMvc mvc;
    @MockBean
    ReportService reportService;

    @TempDir
    Path tempDir;

    private ObjectMapper mapper;
    private ReportResponse sampleResp;
    private ReportDetailResponse sampleDetail;
    private ReportDetailResponse sampleDetailWithFile;

    @BeforeEach
    void setUp() {
        mapper = new ObjectMapper().registerModule(new JavaTimeModule());

        sampleResp = ReportResponse.builder()
                .reportId(1L).referenceNumber("REF-001")
                .templateId(1L).templateName("T1")
                .reportTitle("Test").vendorName("V").location("L")
                .bankName("B").reportStatus("DRAFT")
                .createdBy("user1")
                .valuesCount(0L).totalPlaceholders(5L)
                .hasGeneratedFile(false).build();

        sampleDetail = ReportDetailResponse.builder()
                .reportId(1L).referenceNumber("REF-001")
                .templateId(1L).templateName("T1").templateFileName("t.docx")
                .reportTitle("Test").vendorName("V").location("L")
                .bankName("B").reportStatus("DRAFT")
                .createdBy("user1").hasGeneratedFile(false).values(List.of()).build();

        sampleDetailWithFile = ReportDetailResponse.builder()
                .reportId(1L).referenceNumber("REF-001")
                .templateId(1L).templateName("T1").templateFileName("t.docx")
                .reportTitle("Test").vendorName("V").location("L")
                .bankName("B").reportStatus("COMPLETED")
                .createdBy("user1").hasGeneratedFile(true).values(List.of()).build();
    }

    @Test
    void createReport_returns200() throws Exception {
        when(reportService.createReport(any())).thenReturn(sampleResp);

        CreateReportRequest req = new CreateReportRequest();
        req.setTemplateId(1L);
        req.setReportTitle("Test");
        req.setVendorName("V");
        req.setLocation("L");
        req.setCreatedBy("user1");

        mvc.perform(post("/api/v1/reports")
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.referenceNumber").value("REF-001"));
    }

    @Test
    void getReports_returns200() throws Exception {
        when(reportService.searchReports(any(), any(), any(), any(), any(), anyInt(), anyInt(), any()))
                .thenReturn(Page.empty());

        mvc.perform(get("/api/v1/reports"))
                .andExpect(status().isOk());
    }

    @Test
    void getReportById_returns200() throws Exception {
        when(reportService.getReportDetail(1L)).thenReturn(sampleDetail);

        mvc.perform(get("/api/v1/reports/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.reportId").value(1));
    }

    @Test
    void getReportByRef_returns200() throws Exception {
        when(reportService.getReportByRefNumber("REF-001")).thenReturn(sampleDetail);

        mvc.perform(get("/api/v1/reports/ref/REF-001"))
                .andExpect(status().isOk());
    }

    @Test
    void saveValues_returns200() throws Exception {
        doNothing().when(reportService).saveReportValues(eq(1L), any());

        SaveReportValuesRequest req = new SaveReportValuesRequest();
        req.setValues(List.of());

        // Controller uses @PostMapping for values
        mvc.perform(post("/api/v1/reports/1/values")
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(req)))
                .andExpect(status().isOk());
    }

    @Test
    void updateReport_returns200() throws Exception {
        when(reportService.updateReport(eq(1L), any())).thenReturn(sampleResp);

        com.bwvr.backend.dto.request.UpdateReportRequest req = new com.bwvr.backend.dto.request.UpdateReportRequest();
        req.setReportTitle("Updated Title");

        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/v1/reports/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Report updated successfully"));
    }

    @Test
    void generateDocument_returns200() throws Exception {
        when(reportService.generateDocument(1L)).thenReturn("/output/r.docx");

        mvc.perform(post("/api/v1/reports/1/generate"))
                .andExpect(status().isOk());
    }

    @Test
    void deleteReport_returns200() throws Exception {
        doNothing().when(reportService).deleteReport(eq(1L), anyString());

        mvc.perform(delete("/api/v1/reports/1")
                .param("deletedBy", "admin"))
                .andExpect(status().isOk());
    }

    @Test
    void downloadReport_returns200_whenFileExists() throws Exception {
        // Create a real temp file for the controller to serve
        Path tmpFile = tempDir.resolve("report.docx");
        Files.write(tmpFile, "fake docx content".getBytes());

        when(reportService.getReportDetail(1L)).thenReturn(sampleDetailWithFile);
        when(reportService.getReportFilePath(1L)).thenReturn(tmpFile.toAbsolutePath().toString());

        mvc.perform(get("/api/v1/reports/1/download"))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Disposition",
                        "attachment; filename=\"report_REF-001.docx\""));
    }

    @Test
    void downloadReport_returns404_whenNoGeneratedFile() throws Exception {
        when(reportService.getReportDetail(1L)).thenReturn(sampleDetail); // hasGeneratedFile=false

        mvc.perform(get("/api/v1/reports/1/download"))
                .andExpect(status().isNotFound());
    }

    @Test
    void downloadReport_returns404_whenFileDoesNotExist() throws Exception {
        when(reportService.getReportDetail(1L)).thenReturn(sampleDetailWithFile);
        when(reportService.getReportFilePath(1L)).thenReturn("/non/existent/path.docx");

        mvc.perform(get("/api/v1/reports/1/download"))
                .andExpect(status().isNotFound());
    }

    @Test
    void getDashboardStats_returns200() throws Exception {
        var stats = com.bwvr.backend.dto.response.DashboardStatsResponse.builder()
                .totalReports(5L).reportsThisMonth(2L)
                .activeTemplates(3L).distinctBanks(2L).build();
        when(reportService.getDashboardStats(any(), anyBoolean())).thenReturn(stats);

        mvc.perform(get("/api/v1/reports/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalReports").value(5));
    }
}

