package com.bwvr.backend.controller;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.PageImpl;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bwvr.backend.dto.response.ParsedTemplateResponse;
import com.bwvr.backend.dto.response.TemplateResponse;
import com.bwvr.backend.service.TemplateService;

import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;

@WebMvcTest(value = TemplateController.class, properties = "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration,org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration")
@AutoConfigureMockMvc(addFilters = false)
@WithMockUser(username = "admin", roles = "ADMIN")
@SuppressWarnings("null")
class TemplateControllerTest {
    
    @Autowired
    MockMvc mvc;
    @MockBean
    TemplateService templateService;

    private TemplateResponse sampleTemplate;
    private ParsedTemplateResponse parsedResp;

    @BeforeEach
    public void setUp() {
        sampleTemplate = TemplateResponse.builder()
                .templateId(1L).bankName("B").templateName("T1")
                .templateFileName("t.docx").parsedStatus("PARSED")
                .isActive("Y").placeholderCount(3L).build();

        parsedResp = ParsedTemplateResponse.builder()
                .templateId(1L).bankName("B").templateName("T1")
                .parsedStatus("PARSED").placeholders(List.of())
                .imageSlots(List.of()).totalPlaceholders(0)
                .textCount(0).dateCount(0).imageCount(0).build();
    }

    @Test
    void uploadTemplate_returns200() throws Exception {
        when(templateService.uploadTemplate(any(), anyString(), anyString(), anyString()))
                .thenReturn(parsedResp);

        MockMultipartFile file = new MockMultipartFile(
                "file", "template.docx",
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                "fake docx".getBytes());

        mvc.perform(multipart("/api/v1/templates/upload")
                .file(file)
                .param("bankName", "BankA")
                .param("templateName", "T1")
                .param("uploadedBy", "user1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.templateId").value(1));
    }

    @Test
    void getTemplates_returns200() throws Exception {
        when(templateService.getTemplates(any(), anyInt(), anyInt()))
                .thenReturn(new PageImpl<>(List.of(sampleTemplate)));

        mvc.perform(get("/api/v1/templates"))
                .andExpect(status().isOk());
    }

    @Test
    void getTemplate_returns200() throws Exception {
        when(templateService.getTemplate(1L)).thenReturn(sampleTemplate);

        mvc.perform(get("/api/v1/templates/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.templateName").value("T1"));
    }

    @Test
    void getPlaceholders_returns200() throws Exception {
        when(templateService.getPlaceholders(1L)).thenReturn(List.of());

        mvc.perform(get("/api/v1/templates/1/placeholders"))
                .andExpect(status().isOk());
    }

    @Test
    void confirmPlaceholders_returns200() throws Exception {
        doNothing().when(templateService).confirmPlaceholders(eq(1L), any());

        mvc.perform(post("/api/v1/templates/1/confirm-placeholders")
                .contentType("application/json")
                .content("{\"placeholders\":[],\"confirmedBy\":\"admin\"}"))
                .andExpect(status().isOk());
    }

    @Test
    void deleteTemplate_returns200() throws Exception {
        doNothing().when(templateService).deleteTemplate(eq(1L), anyString());

        mvc.perform(delete("/api/v1/templates/1")
                .param("deletedBy", "admin"))
                .andExpect(status().isOk());
    }

    @Test
    void getBankNames_returns200() throws Exception {
        when(templateService.getBankNames()).thenReturn(List.of("BankA", "BankB"));

        mvc.perform(get("/api/v1/templates/banks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0]").value("BankA"));
    }
}

