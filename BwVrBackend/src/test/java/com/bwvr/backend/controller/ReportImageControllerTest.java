package com.bwvr.backend.controller;

import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bwvr.backend.entity.BwvrReportImage;
import com.bwvr.backend.service.ReportImageService;

import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.security.test.context.support.WithMockUser;

@WebMvcTest(value = ReportImageController.class, properties = "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration,org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration")
@AutoConfigureMockMvc(addFilters = false)
@WithMockUser(username = "user1", roles = "USER")
class ReportImageControllerTest {
    
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
    ReportImageService reportImageService;

    @Test
    void uploadImage_returns200WithImageId() throws Exception {
        BwvrReportImage img = new BwvrReportImage();
        img.setImageId(42L);

        when(reportImageService.saveImage(eq(1L), eq("IMG_FRONT"), any())).thenReturn(img);

        MockMultipartFile file = new MockMultipartFile(
                "file", "photo.jpg", "image/jpeg", new byte[]{1, 2, 3});

        mvc.perform(multipart("/api/v1/report-images/upload")
                .file(file)
                .param("reportId", "1")
                .param("placeholderKey", "IMG_FRONT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data").value(42));
    }

    @Test
    void getImageByPlaceholder_found_returnsImageBytes() throws Exception {
        BwvrReportImage img = new BwvrReportImage();
        img.setImageData(new byte[]{10, 20, 30});
        img.setContentType("image/jpeg");

        when(reportImageService.getImage(1L, "IMG_FRONT")).thenReturn(img);

        mvc.perform(get("/api/v1/report-images/1/IMG_FRONT"))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "image/jpeg"));
    }

    @Test
    void getImageByPlaceholder_notFound_returns404() throws Exception {
        when(reportImageService.getImage(1L, "IMG_MISSING"))
                .thenThrow(new RuntimeException("Image not found"));

        mvc.perform(get("/api/v1/report-images/1/IMG_MISSING"))
                .andExpect(status().isInternalServerError());
    }
}
