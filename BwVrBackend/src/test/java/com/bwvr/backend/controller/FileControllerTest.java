package com.bwvr.backend.controller;

import java.util.Optional;

import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bwvr.backend.entity.BwvrReportValue;
import com.bwvr.backend.repository.ReportValueRepository;

import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.security.test.context.support.WithMockUser;

@WebMvcTest(value = FileController.class, properties = "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration,org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration")
@AutoConfigureMockMvc(addFilters = false)
@WithMockUser(username = "user1", roles = "USER")
@SuppressWarnings({"unused", "null"})
class FileControllerTest {
    
    @MockBean
    com.bwvr.backend.security.UserDetailsServiceImpl userDetailsService;
    @MockBean
    com.bwvr.backend.security.JwtUtil jwtUtil;
    @MockBean
    com.bwvr.backend.security.JwtAuthFilter jwtAuthFilter;
    @MockBean
    org.springframework.web.cors.CorsConfigurationSource corsConfigurationSource;

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ReportValueRepository reportValueRepository;

    @MockBean
    private com.bwvr.backend.repository.ReportRepository reportRepository;

    @MockBean
    private com.bwvr.backend.repository.TemplatePlaceholderRepository templatePlaceholderRepository;

    @Test
    void uploadImage_success() throws Exception {
        MockMultipartFile file = new MockMultipartFile("file", "test.jpg", "image/jpeg", "imageContent".getBytes());
        BwvrReportValue mockVal = new BwvrReportValue();

        Mockito.when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(eq(1L), eq("PK")))
                .thenReturn(Optional.of(mockVal));

        mockMvc.perform(multipart("/api/v1/files/upload-image")
                .file(file)
                .param("reportId", "1")
                .param("placeholderKey", "PK"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.originalName").value("test.jpg"));

        Mockito.verify(reportValueRepository).save(any(BwvrReportValue.class));
    }

    @Test
    void uploadImage_withBlankFileName() throws Exception {
        MockMultipartFile file = new MockMultipartFile("file", "", "image/jpeg", "imageContent".getBytes());
        BwvrReportValue mockVal = new BwvrReportValue();

        Mockito.when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(eq(1L), eq("PK")))
                .thenReturn(Optional.of(mockVal));

        mockMvc.perform(multipart("/api/v1/files/upload-image")
                .file(file)
                .param("reportId", "1")
                .param("placeholderKey", "PK"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.originalName").value("unknown.jpg"));
    }

    @Test
    void getImage_success() throws Exception {
        BwvrReportValue mockVal = new BwvrReportValue();
        mockVal.setImageData("imageContent".getBytes());
        mockVal.setImageOriginalName("test.png");

        Mockito.when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(eq(1L), eq("PK")))
                .thenReturn(Optional.of(mockVal));

        mockMvc.perform(get("/api/v1/files/image/1")
                .param("placeholderKey", "PK"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.IMAGE_PNG))
                .andExpect(content().bytes("imageContent".getBytes()));
    }

    @Test
    void getImage_variousContentTypes() throws Exception {
        // GIF
        BwvrReportValue gifVal = new BwvrReportValue();
        gifVal.setImageData(new byte[]{1});
        gifVal.setImageOriginalName("test.gif");
        Mockito.when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(eq(2L), eq("PK1")))
                .thenReturn(Optional.of(gifVal));
        mockMvc.perform(get("/api/v1/files/image/2").param("placeholderKey", "PK1"))
                .andExpect(content().contentType(MediaType.IMAGE_GIF));

        // WEBP
        BwvrReportValue webpVal = new BwvrReportValue();
        webpVal.setImageData(new byte[]{1});
        webpVal.setImageOriginalName("test.webp");
        Mockito.when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(eq(3L), eq("PK2")))
                .thenReturn(Optional.of(webpVal));
        mockMvc.perform(get("/api/v1/files/image/3").param("placeholderKey", "PK2"))
                .andExpect(content().contentType(MediaType.parseMediaType("image/webp")));
    }

    @Test
    void getImage_notFound_whenNoData() throws Exception {
        BwvrReportValue mockVal = new BwvrReportValue();
        mockVal.setImageData(null);

        Mockito.when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(eq(1L), eq("PK")))
                .thenReturn(Optional.of(mockVal));

        mockMvc.perform(get("/api/v1/files/image/1")
                .param("placeholderKey", "PK"))
                .andExpect(status().isNotFound());
    }

    @Test
    void getImage_notFound_whenNoRecord() throws Exception {
        Mockito.when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(eq(1L), eq("PK")))
                .thenReturn(Optional.empty());

        mockMvc.perform(get("/api/v1/files/image/1")
                .param("placeholderKey", "PK"))
                .andExpect(status().isNotFound());
    }
}

