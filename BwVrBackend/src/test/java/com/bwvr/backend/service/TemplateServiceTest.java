package com.bwvr.backend.service;

import java.io.IOException;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;

import com.bwvr.backend.config.FileStorageConfig;
import com.bwvr.backend.dto.request.ConfirmPlaceholdersRequest;
import com.bwvr.backend.dto.response.ParsedTemplateResponse;
import com.bwvr.backend.dto.response.TemplateResponse;
import com.bwvr.backend.entity.BwvrTemplate;
import com.bwvr.backend.entity.BwvrTemplatePlaceholder;
import com.bwvr.backend.exception.ConflictException;
import com.bwvr.backend.exception.ResourceNotFoundException;
import com.bwvr.backend.repository.ReportRepository;
import com.bwvr.backend.repository.TemplateImageSlotRepository;
import com.bwvr.backend.repository.TemplatePlaceholderRepository;
import com.bwvr.backend.repository.TemplateRepository;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class TemplateServiceTest {

    @Mock
    private TemplateRepository templateRepository;
    @Mock
    private TemplatePlaceholderRepository placeholderRepository;
    @Mock
    private TemplateImageSlotRepository imageSlotRepository;
    @Mock
    private DocxParserService docxParserService;
    @Mock
    private AuditService auditService;
    @Mock
    private FileStorageConfig fileStorageConfig;
    @Mock
    private ReportRepository reportRepository;

    @InjectMocks
    private TemplateService templateService;

    @TempDir
    Path tempDir;

    @BeforeEach
    public void setUp() {
        lenient().when(fileStorageConfig.getTemplateDir()).thenReturn(tempDir.toString());
    }

    @Test
    void uploadTemplate_success() throws IOException {
        String bank = "BankA";
        String name = "Template1";
        String user = "user1";
        MockMultipartFile file = new MockMultipartFile("file", "test.docx", "application/vnd.openxml", "content".getBytes());

        when(templateRepository.findByBankNameAndTemplateName(bank, name)).thenReturn(Optional.empty());
        when(templateRepository.save(any(BwvrTemplate.class))).thenAnswer(invocation -> {
            BwvrTemplate t = invocation.getArgument(0);
            ReflectionTestUtils.setField(t, "templateId", 1L);
            return t;
        });

        ParsedTemplateResponse response = templateService.uploadTemplate(file, bank, name, user);

        assertThat(response.getTemplateId()).isEqualTo(1L);
        verify(docxParserService).parseTemplate(any());
        verify(templateRepository, atLeastOnce()).save(any());
    }

    @Test
    void uploadTemplate_parsingError() throws IOException {
        MockMultipartFile file = new MockMultipartFile("file", "test.docx", "application/vnd.openxml", "content".getBytes());
        BwvrTemplate t = BwvrTemplate.builder().templateId(1L).build();
        when(templateRepository.findByBankNameAndTemplateName(anyString(), anyString())).thenReturn(Optional.empty());
        when(templateRepository.save(any())).thenReturn(t);
        doThrow(new RuntimeException("Parse fail")).when(docxParserService).parseTemplate(any());

        assertThatThrownBy(() -> templateService.uploadTemplate(file, "B", "T", "U"))
                .isInstanceOf(RuntimeException.class);

        verify(templateRepository, atLeastOnce()).save(any());
        assertThat(t.getParsedStatus()).isEqualTo("ERROR");
    }

    @Test
    void uploadTemplate_throwsConflict() {
        MockMultipartFile file = new MockMultipartFile("file", "test.docx", "application/vnd.openxml", "content".getBytes());
        BwvrTemplate existing = BwvrTemplate.builder().isActive("Y").build();
        when(templateRepository.findByBankNameAndTemplateName(anyString(), anyString())).thenReturn(Optional.of(existing));

        assertThatThrownBy(() -> templateService.uploadTemplate(file, "BankA", "T1", "user1"))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void uploadTemplate_throwsIllegalArgument() {
        MockMultipartFile file = new MockMultipartFile("file", "test.pdf", "application/pdf", "content".getBytes());
        assertThatThrownBy(() -> templateService.uploadTemplate(file, "BankA", "T1", "user1"))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void getTemplates_returnsPage() {
        BwvrTemplate t = BwvrTemplate.builder().templateId(1L).bankName("Bank").templateName("Name").isActive("Y").build();
        when(templateRepository.searchTemplates(anyString(), any(PageRequest.class)))
                .thenReturn(new PageImpl<>(Collections.singletonList(t)));

        Page<TemplateResponse> page = templateService.getTemplates("Bank", 0, 10);
        assertThat(page.getContent()).hasSize(1);
    }

    @Test
    void getTemplates_returnsPage_noBank() {
        BwvrTemplate t = BwvrTemplate.builder().templateId(1L).bankName("Bank").templateName("Name").isActive("Y").build();
        when(templateRepository.findByIsActive(eq("Y"), any(PageRequest.class)))
                .thenReturn(new PageImpl<>(Collections.singletonList(t)));

        Page<TemplateResponse> page = templateService.getTemplates(null, 0, 10);
        assertThat(page.getContent()).hasSize(1);
    }

    @Test
    void getTemplate_success() {
        BwvrTemplate t = BwvrTemplate.builder().templateId(1L).bankName("Bank").templateName("Name").isActive("Y").build();
        when(templateRepository.findById(1L)).thenReturn(Optional.of(t));
        when(placeholderRepository.countByTemplate_TemplateId(1L)).thenReturn(5L);

        TemplateResponse resp = templateService.getTemplate(1L);
        assertThat(resp.getTemplateId()).isEqualTo(1L);
    }

    @Test
    void getPlaceholders_success() {
        BwvrTemplate t = BwvrTemplate.builder().templateId(1L).isActive("Y").build();
        when(templateRepository.findById(1L)).thenReturn(Optional.of(t));

        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder()
                .template(t).placeholderKey("K1").placeholderPrefix("TEXT").build();
        when(placeholderRepository.findByTemplate_TemplateIdOrderByDisplayOrder(1L))
                .thenReturn(Collections.singletonList(ph));
        when(imageSlotRepository.findByTemplate_TemplateId(1L)).thenReturn(Collections.emptyList());

        List<com.bwvr.backend.dto.response.PlaceholderResponse> res = templateService.getPlaceholders(1L);
        assertThat(res).hasSize(1);
    }

    @Test
    void confirmPlaceholders_withManyFields() {
        BwvrTemplate t = BwvrTemplate.builder().templateId(1L).isActive("Y").build();
        when(templateRepository.findById(1L)).thenReturn(Optional.of(t));

        BwvrTemplatePlaceholder ph = new BwvrTemplatePlaceholder();
        when(placeholderRepository.findById(10L)).thenReturn(Optional.of(ph));

        ConfirmPlaceholdersRequest req = new ConfirmPlaceholdersRequest();
        ConfirmPlaceholdersRequest.PlaceholderUpdateDto item = new ConfirmPlaceholdersRequest.PlaceholderUpdateDto();
        item.setPlaceholderId(10L);
        item.setQuestionText("Q");
        item.setDisplayLabel("L");
        item.setFieldType("F");
        item.setIsRequired(false);
        req.setPlaceholders(Collections.singletonList(item));

        templateService.confirmPlaceholders(1L, req);

        assertThat(ph.getIsRequired()).isEqualTo("N");
        assertThat(ph.getDisplayLabel()).isEqualTo("L");
    }

    @Test
    void findActiveTemplate_throwsNotFound() {
        when(templateRepository.findById(99L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> templateService.getTemplate(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void deleteTemplate_success() {
        BwvrTemplate t = BwvrTemplate.builder().templateId(1L).isActive("Y").build();
        when(templateRepository.findById(1L)).thenReturn(Optional.of(t));
        when(reportRepository.countByTemplate_TemplateIdAndIsDeleted(1L, "N")).thenReturn(0L);

        templateService.deleteTemplate(1L, "user");

        verify(templateRepository).delete(t);
        verify(auditService).log(eq("TEMPLATE"), eq(1L), eq("DELETE"), eq("user"), any(), any(), any(), anyString());
    }

    @Test
    void getBankNames_success() {
        when(templateRepository.findDistinctBankNames()).thenReturn(Arrays.asList("Bank1", "Bank2"));
        List<String> banks = templateService.getBankNames();
        assertThat(banks).containsExactly("Bank1", "Bank2");
    }
}

