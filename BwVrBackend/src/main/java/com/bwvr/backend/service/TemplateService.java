package com.bwvr.backend.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.bwvr.backend.config.FileStorageConfig;
import com.bwvr.backend.dto.request.ConfirmPlaceholdersRequest;
import com.bwvr.backend.dto.response.ParsedTemplateResponse;
import com.bwvr.backend.dto.response.PlaceholderResponse;
import com.bwvr.backend.dto.response.TemplateResponse;
import com.bwvr.backend.entity.BwvrTemplate;
import com.bwvr.backend.entity.BwvrTemplateImageSlot;
import com.bwvr.backend.entity.BwvrTemplatePlaceholder;
import com.bwvr.backend.exception.ResourceNotFoundException;
import com.bwvr.backend.repository.ReportRepository;
import com.bwvr.backend.repository.TemplateImageSlotRepository;
import com.bwvr.backend.repository.TemplatePlaceholderRepository;
import com.bwvr.backend.repository.TemplateRepository;

@Service
@SuppressWarnings("null")
public class TemplateService {

    private final TemplateRepository templateRepository;
    private final TemplatePlaceholderRepository placeholderRepository;
    private final TemplateImageSlotRepository imageSlotRepository;
    private final DocxParserService docxParserService;
    private final AuditService auditService;
    private final FileStorageConfig fileStorageConfig;
    private final ReportRepository reportRepository;

    public TemplateService(TemplateRepository templateRepository,
            TemplatePlaceholderRepository placeholderRepository,
            TemplateImageSlotRepository imageSlotRepository,
            DocxParserService docxParserService,
            AuditService auditService,
            FileStorageConfig fileStorageConfig,
            ReportRepository reportRepository) {
        this.templateRepository = templateRepository;
        this.placeholderRepository = placeholderRepository;
        this.imageSlotRepository = imageSlotRepository;
        this.docxParserService = docxParserService;
        this.auditService = auditService;
        this.fileStorageConfig = fileStorageConfig;
        this.reportRepository = reportRepository;
    }

    @Transactional
    public ParsedTemplateResponse uploadTemplate(MultipartFile file, String bankName,
            String templateName, String uploadedBy) throws IOException {

        // Check for existing template with same name and bank (active or inactive)
        templateRepository.findByBankNameAndTemplateName(bankName, templateName)
                .ifPresent(t -> {
                    throw new com.bwvr.backend.exception.ConflictException(
                            "A template named '" + templateName + "' already exists for bank '" + bankName + "'. Please use a unique name.");
                });

        String originalFilename = Objects.requireNonNullElse(file.getOriginalFilename(), "");
        if (!originalFilename.toLowerCase().endsWith(".docx")) {
            throw new IllegalArgumentException("Only .docx files are allowed");
        }

        // Save file to disk
        String uniqueName = UUID.randomUUID() + "_" + originalFilename;
        Path templateDir = Paths.get(fileStorageConfig.getTemplateDir());
        Files.createDirectories(templateDir);
        Path filePath = templateDir.resolve(uniqueName);
        file.transferTo(filePath.toFile());

        // Persist template record
        BwvrTemplate template = BwvrTemplate.builder()
                .bankName(bankName)
                .templateName(templateName)
                .templateFileName(originalFilename)
                .templateFilePath(filePath.toAbsolutePath().toString())
                .parsedStatus("PENDING")
                .isActive("Y")
                .createdBy(uploadedBy != null ? uploadedBy : "SYSTEM")
                .build();
        template = templateRepository.save(template);

        // Parse the document
        try {
            docxParserService.parseTemplate(template);
            template.setParsedStatus("PARSED");
            template = templateRepository.save(template);
        } catch (Exception e) {
            template.setParsedStatus("ERROR");
            templateRepository.save(template);
            throw e;
        }

        auditService.log("TEMPLATE", template.getTemplateId(), "CREATE",
                uploadedBy, null, null, null, "Template uploaded and parsed");

        return buildParsedResponse(template);
    }

    @Transactional(readOnly = true)
    public Page<TemplateResponse> getTemplates(String bankName, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<BwvrTemplate> templates = (bankName != null && !bankName.isBlank())
                ? templateRepository.searchTemplates(bankName, pageable)
                : templateRepository.findByIsActive("Y", pageable);
        return templates.map(this::toTemplateResponse);
    }

    @Transactional(readOnly = true)
    public TemplateResponse getTemplate(Long templateId) {
        BwvrTemplate template = findActiveTemplate(templateId);
        return toTemplateResponse(template);
    }

    @Transactional(readOnly = true)
    public List<PlaceholderResponse> getPlaceholders(Long templateId) {
        findActiveTemplate(templateId);
        List<BwvrTemplatePlaceholder> placeholders
                = placeholderRepository.findByTemplate_TemplateIdOrderByDisplayOrder(templateId);
        Map<String, BwvrTemplateImageSlot> slotMap
                = imageSlotRepository.findByTemplate_TemplateId(templateId)
                        .stream()
                        .collect(Collectors.toMap(BwvrTemplateImageSlot::getPlaceholderKey, s -> s, (s1, s2) -> s1));

        return placeholders.stream()
                .map(p -> toPlaceholderResponse(p, slotMap.get(p.getPlaceholderKey())))
                .collect(Collectors.toList());
    }

    @Transactional
    public void confirmPlaceholders(Long templateId, ConfirmPlaceholdersRequest request) {
        BwvrTemplate template = findActiveTemplate(templateId);

        if (request.getPlaceholders() != null) {
            for (ConfirmPlaceholdersRequest.PlaceholderUpdateDto dto : request.getPlaceholders()) {
                placeholderRepository.findById(dto.getPlaceholderId()).ifPresent(ph -> {
                    if (dto.getQuestionText() != null) {
                        ph.setQuestionText(dto.getQuestionText());
                    }
                    if (dto.getDisplayLabel() != null) {
                        ph.setDisplayLabel(dto.getDisplayLabel());
                    }
                    if (dto.getFieldType() != null) {
                        ph.setFieldType(dto.getFieldType());
                    }
                    if (dto.getIsRequired() != null) {
                        ph.setIsRequired(dto.getIsRequired() ? "Y" : "N");
                    }
                    ph.setIsConfirmed("Y");
                    placeholderRepository.save(ph);
                });
            }
        }

        template.setParsedStatus("CONFIRMED");
        templateRepository.save(template);

        auditService.log("TEMPLATE", templateId, "CONFIRM",
                request.getConfirmedBy(), null, null, null, "Placeholders confirmed");
    }

    @Transactional
    public void deleteTemplate(Long templateId, String deletedBy) {
        BwvrTemplate template = findActiveTemplate(templateId);

        long activeReports = reportRepository.countByTemplate_TemplateIdAndIsDeleted(templateId, "N");
        if (activeReports > 0) {
            throw new com.bwvr.backend.exception.ConflictException(
                    "Cannot delete template '" + template.getTemplateName() + "' because it is used by " + activeReports + " active report(s). Please delete those reports first.");
        }

        try {
            templateRepository.delete(template);
            auditService.log("TEMPLATE", templateId, "DELETE", deletedBy, null, null, null, "Hard deleted");
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            throw new com.bwvr.backend.exception.ConflictException("Cannot delete template because it is still referenced by reports in the database.");
        }
    }

    @Transactional(readOnly = true)
    public List<String> getBankNames() {
        return templateRepository.findDistinctBankNames();
    }

    // ──────────────────────────── Private Helpers ────────────────────────────
    private BwvrTemplate findActiveTemplate(Long templateId) {
        return templateRepository.findById(templateId)
                .filter(t -> "Y".equals(t.getIsActive()))
                .orElseThrow(() -> new ResourceNotFoundException("Template", templateId));
    }

    private ParsedTemplateResponse buildParsedResponse(BwvrTemplate template) {
        List<BwvrTemplatePlaceholder> placeholders
                = placeholderRepository.findByTemplate_TemplateIdOrderByDisplayOrder(template.getTemplateId());
        List<BwvrTemplateImageSlot> imageSlots
                = imageSlotRepository.findByTemplate_TemplateId(template.getTemplateId());

        Map<String, BwvrTemplateImageSlot> slotMap = imageSlots.stream()
                .collect(Collectors.toMap(BwvrTemplateImageSlot::getPlaceholderKey, s -> s, (s1, s2) -> s1));

        List<ParsedTemplateResponse.ImageSlotResponse> slotResponses = imageSlots.stream()
                .map(s -> ParsedTemplateResponse.ImageSlotResponse.builder()
                .imageSlotId(s.getImageSlotId())
                .placeholderKey(s.getPlaceholderKey())
                .widthEmu(s.getOriginalWidthEmu())
                .heightEmu(s.getOriginalHeightEmu())
                .widthInches(s.getWidthInches())
                .heightInches(s.getHeightInches())
                .widthPixels(s.getWidthPixels())
                .heightPixels(s.getHeightPixels())
                .pagePosition(s.getPagePosition())
                .build())
                .collect(Collectors.toList());

        long textCount = placeholders.stream().filter(p -> "TEXT".equals(p.getPlaceholderPrefix())).count();
        long dateCount = placeholders.stream().filter(p -> "DATE".equals(p.getPlaceholderPrefix())).count();
        long imageCount = placeholders.stream().filter(p -> "IMG".equals(p.getPlaceholderPrefix())).count();

        return ParsedTemplateResponse.builder()
                .templateId(template.getTemplateId())
                .bankName(template.getBankName())
                .templateName(template.getTemplateName())
                .parsedStatus(template.getParsedStatus())
                .placeholders(placeholders.stream()
                        .map(p -> toPlaceholderResponse(p, slotMap.get(p.getPlaceholderKey())))
                        .collect(Collectors.toList()))
                .imageSlots(slotResponses)
                .totalPlaceholders(placeholders.size())
                .textCount((int) textCount)
                .dateCount((int) dateCount)
                .imageCount((int) imageCount)
                .build();
    }

    private TemplateResponse toTemplateResponse(BwvrTemplate t) {
        long placeholderCount = placeholderRepository.countByTemplate_TemplateId(t.getTemplateId());
        return TemplateResponse.builder()
                .templateId(t.getTemplateId())
                .bankName(t.getBankName())
                .templateName(t.getTemplateName())
                .templateFileName(t.getTemplateFileName())
                .templateVersion(t.getTemplateVersion())
                .parsedStatus(t.getParsedStatus())
                .isActive(t.getIsActive())
                .createdBy(t.getCreatedBy())
                .createdAt(t.getCreatedAt())
                .updatedAt(t.getUpdatedAt())
                .placeholderCount(placeholderCount)
                .build();
    }

    private PlaceholderResponse toPlaceholderResponse(BwvrTemplatePlaceholder p, BwvrTemplateImageSlot slot) {
        PlaceholderResponse.Builder builder = PlaceholderResponse.builder()
                .placeholderId(p.getPlaceholderId())
                .templateId(p.getTemplate().getTemplateId())
                .placeholderKey(p.getPlaceholderKey())
                .placeholderPrefix(p.getPlaceholderPrefix())
                .displayLabel(p.getDisplayLabel())
                .questionText(p.getQuestionText())
                .fieldType(p.getFieldType())
                .sectionName(p.getSectionName())
                .isRequired(p.getIsRequired())
                .displayOrder(p.getDisplayOrder())
                .tableContext(p.getTableContext())
                .col1Header(p.getCol1Header())
                .col2Header(p.getCol2Header())
                .isConfirmed(p.getIsConfirmed())
                .createdAt(p.getCreatedAt());

        if (slot != null) {
            builder.widthInches(slot.getWidthInches())
                    .heightInches(slot.getHeightInches())
                    .widthEmu(slot.getOriginalWidthEmu())
                    .heightEmu(slot.getOriginalHeightEmu())
                    .pagePosition(slot.getPagePosition());
        }

        return builder.build();
    }
}
