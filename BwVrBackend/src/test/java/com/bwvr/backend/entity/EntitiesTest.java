package com.bwvr.backend.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class EntitiesTest {

    @Test
    void testBwvrAuditLogExhaustive() {
        // Constructor coverage
        BwvrAuditLog logBase = new BwvrAuditLog();

        LocalDateTime now = LocalDateTime.now();
        BwvrAuditLog log = BwvrAuditLog.builder()
                .auditId(1L)
                .entityType("TYPE")
                .entityId(10L)
                .action("ACTION")
                .performedBy("USER")
                .performedAt(now)
                .oldValueJson("OLD")
                .newValueJson("NEW")
                .ipAddress("IP")
                .remarks("REMARKS")
                .build();

        assertThat(log.getAuditId()).isEqualTo(1L);
        log.setAuditId(2L);
        assertThat(log.getAuditId()).isEqualTo(2L);

        // Covering all getters
        assertThat(log.getEntityType()).isEqualTo("TYPE");
        assertThat(log.getEntityId()).isEqualTo(10L);
        assertThat(log.getAction()).isEqualTo("ACTION");
        assertThat(log.getPerformedBy()).isEqualTo("USER");
        assertThat(log.getPerformedAt()).isEqualTo(now);
        assertThat(log.getOldValueJson()).isEqualTo("OLD");
        assertThat(log.getNewValueJson()).isEqualTo("NEW");
        assertThat(log.getIpAddress()).isEqualTo("IP");
        assertThat(log.getRemarks()).isEqualTo("REMARKS");

        // Covering all setters
        log.setEntityType("T");
        log.setEntityId(1L);
        log.setAction("A");
        log.setPerformedBy("P");
        log.setPerformedAt(now);
        log.setOldValueJson("O");
        log.setNewValueJson("N");
        log.setIpAddress("I");
        log.setRemarks("R");
    }

    @Test
    void testBwvrReportExhaustive() {
        BwvrReport reportBase = new BwvrReport();
        LocalDateTime now = LocalDateTime.now();
        BwvrTemplate t = new BwvrTemplate();
        List<BwvrReportValue> vals = new ArrayList<>();
        BwvrReport r = BwvrReport.builder()
                .reportId(1L)
                .referenceNumber("REF")
                .template(t)
                .reportTitle("TITLE")
                .vendorName("V")
                .location("L")
                .bankName("B")
                .reportStatus("S")
                .generatedFilePath("P")
                .generatedAt(now)
                .createdBy("CB")
                .createdAt(now)
                .updatedBy("UB")
                .updatedAt(now)
                .isDeleted("Y")
                .deletedAt(now)
                .deletedBy("DB")
                .reportValues(vals)
                .build();

        assertThat(r.getReportId()).isEqualTo(1L);
        r.setReportId(2L);
        assertThat(r.getReportId()).isEqualTo(2L);

        // Getters
        assertThat(r.getReferenceNumber()).isEqualTo("REF");
        assertThat(r.getTemplate()).isEqualTo(t);
        assertThat(r.getReportTitle()).isEqualTo("TITLE");
        assertThat(r.getVendorName()).isEqualTo("V");
        assertThat(r.getLocation()).isEqualTo("L");
        assertThat(r.getBankName()).isEqualTo("B");
        assertThat(r.getReportStatus()).isEqualTo("S");
        assertThat(r.getGeneratedFilePath()).isEqualTo("P");
        assertThat(r.getGeneratedAt()).isEqualTo(now);
        assertThat(r.getCreatedBy()).isEqualTo("CB");
        assertThat(r.getCreatedAt()).isEqualTo(now);
        assertThat(r.getUpdatedBy()).isEqualTo("UB");
        assertThat(r.getUpdatedAt()).isEqualTo(now);
        assertThat(r.getIsDeleted()).isEqualTo("Y");
        assertThat(r.getDeletedAt()).isEqualTo(now);
        assertThat(r.getDeletedBy()).isEqualTo("DB");
        assertThat(r.getReportValues()).isEqualTo(vals);

        // Setters
        r.setReferenceNumber(null);
        r.setTemplate(null);
        r.setReportTitle(null);
        r.setVendorName(null);
        r.setLocation(null);
        r.setBankName(null);
        r.setReportStatus(null);
        r.setGeneratedFilePath(null);
        r.setGeneratedAt(null);
        r.setCreatedBy(null);
        r.setCreatedAt(null);
        r.setUpdatedBy(null);
        r.setUpdatedAt(null);
        r.setIsDeleted(null);
        r.setDeletedAt(null);
        r.setDeletedBy(null);
        r.setReportValues(null);
    }

    @Test
    void testBwvrReportValueExhaustive() {
        BwvrReportValue valBase = new BwvrReportValue();
        LocalDateTime now = LocalDateTime.now();
        BwvrReport r = new BwvrReport();
        BwvrTemplatePlaceholder ph = new BwvrTemplatePlaceholder();
        byte[] data = new byte[]{1};
        BwvrReportValue v = BwvrReportValue.builder()
                .valueId(1L)
                .report(r)
                .placeholder(ph)
                .placeholderKey("K")
                .textValue("T")
                .imageFilePath("P")
                .imageOriginalName("O")
                .imageData(data)
                .createdAt(now)
                .updatedAt(now)
                .build();

        assertThat(v.getValueId()).isEqualTo(1L);
        v.setValueId(2L);
        assertThat(v.getValueId()).isEqualTo(2L);

        // Getters
        assertThat(v.getReport()).isEqualTo(r);
        assertThat(v.getPlaceholder()).isEqualTo(ph);
        assertThat(v.getPlaceholderKey()).isEqualTo("K");
        assertThat(v.getTextValue()).isEqualTo("T");
        assertThat(v.getImageFilePath()).isEqualTo("P");
        assertThat(v.getImageOriginalName()).isEqualTo("O");
        assertThat(v.getImageData()).isEqualTo(data);
        assertThat(v.getCreatedAt()).isEqualTo(now);
        assertThat(v.getUpdatedAt()).isEqualTo(now);

        // Setters
        v.setReport(null);
        v.setPlaceholder(null);
        v.setPlaceholderKey(null);
        v.setTextValue(null);
        v.setImageFilePath(null);
        v.setImageOriginalName(null);
        v.setImageData(null);
        v.setCreatedAt(null);
        v.setUpdatedAt(null);
    }

    @Test
    void testBwvrTemplateExhaustive() {
        BwvrTemplate templateBase = new BwvrTemplate();
        LocalDateTime now = LocalDateTime.now();
        List<BwvrTemplatePlaceholder> phs = new ArrayList<>();
        List<BwvrTemplateImageSlot> slots = new ArrayList<>();
        BwvrTemplate t = BwvrTemplate.builder()
                .templateId(1L)
                .bankName("B")
                .templateName("N")
                .templateFileName("FN")
                .templateFilePath("FP")
                .templateVersion("V")
                .isActive("Y")
                .parsedStatus("P")
                .createdBy("CB")
                .createdAt(now)
                .updatedBy("UB")
                .updatedAt(now)
                .placeholders(phs)
                .imageSlots(slots)
                .build();

        assertThat(t.getTemplateId()).isEqualTo(1L);
        t.setTemplateId(2L);
        assertThat(t.getTemplateId()).isEqualTo(2L);

        // Getters
        assertThat(t.getBankName()).isEqualTo("B");
        assertThat(t.getTemplateName()).isEqualTo("N");
        assertThat(t.getTemplateFileName()).isEqualTo("FN");
        assertThat(t.getTemplateFilePath()).isEqualTo("FP");
        assertThat(t.getTemplateVersion()).isEqualTo("V");
        assertThat(t.getIsActive()).isEqualTo("Y");
        assertThat(t.getParsedStatus()).isEqualTo("P");
        assertThat(t.getCreatedBy()).isEqualTo("CB");
        assertThat(t.getCreatedAt()).isEqualTo(now);
        assertThat(t.getUpdatedBy()).isEqualTo("UB");
        assertThat(t.getUpdatedAt()).isEqualTo(now);
        assertThat(t.getPlaceholders()).isEqualTo(phs);
        assertThat(t.getImageSlots()).isEqualTo(slots);

        // Setters
        t.setBankName(null);
        t.setTemplateName(null);
        t.setTemplateFileName(null);
        t.setTemplateFilePath(null);
        t.setTemplateVersion(null);
        t.setIsActive(null);
        t.setParsedStatus(null);
        t.setCreatedBy(null);
        t.setCreatedAt(null);
        t.setUpdatedBy(null);
        t.setUpdatedAt(null);
        t.setPlaceholders(null);
        t.setImageSlots(null);
    }

    @Test
    void testBwvrTemplatePlaceholderExhaustive() {
        BwvrTemplatePlaceholder placeholderBase = new BwvrTemplatePlaceholder();
        LocalDateTime now = LocalDateTime.now();
        BwvrTemplate t = new BwvrTemplate();
        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder()
                .placeholderId(1L)
                .template(t)
                .placeholderKey("K")
                .placeholderPrefix("P")
                .displayLabel("L")
                .questionText("Q")
                .fieldType("F")
                .isRequired("N")
                .displayOrder(1)
                .tableContext("C")
                .col1Header("H1")
                .col2Header("H2")
                .isConfirmed("Y")
                .sectionName("S")
                .createdAt(now)
                .build();

        assertThat(ph.getPlaceholderId()).isEqualTo(1L);
        ph.setPlaceholderId(2L);
        assertThat(ph.getPlaceholderId()).isEqualTo(2L);

        // Getters
        assertThat(ph.getTemplate()).isEqualTo(t);
        assertThat(ph.getPlaceholderKey()).isEqualTo("K");
        assertThat(ph.getPlaceholderPrefix()).isEqualTo("P");
        assertThat(ph.getDisplayLabel()).isEqualTo("L");
        assertThat(ph.getQuestionText()).isEqualTo("Q");
        assertThat(ph.getFieldType()).isEqualTo("F");
        assertThat(ph.getIsRequired()).isEqualTo("N");
        assertThat(ph.getDisplayOrder()).isEqualTo(1);
        assertThat(ph.getTableContext()).isEqualTo("C");
        assertThat(ph.getCol1Header()).isEqualTo("H1");
        assertThat(ph.getCol2Header()).isEqualTo("H2");
        assertThat(ph.getIsConfirmed()).isEqualTo("Y");
        assertThat(ph.getSectionName()).isEqualTo("S");
        assertThat(ph.getCreatedAt()).isEqualTo(now);

        // Setters
        ph.setTemplate(null);
        ph.setPlaceholderKey(null);
        ph.setPlaceholderPrefix(null);
        ph.setDisplayLabel(null);
        ph.setQuestionText(null);
        ph.setFieldType(null);
        ph.setIsRequired(null);
        ph.setDisplayOrder(null);
        ph.setTableContext(null);
        ph.setCol1Header(null);
        ph.setCol2Header(null);
        ph.setIsConfirmed(null);
        ph.setSectionName(null);
        ph.setCreatedAt(null);
    }

    @Test
    void testBwvrTemplateImageSlotExhaustive() {
        BwvrTemplateImageSlot slotBase = new BwvrTemplateImageSlot();
        LocalDateTime now = LocalDateTime.now();
        BwvrTemplate t = new BwvrTemplate();
        BwvrTemplateImageSlot s = BwvrTemplateImageSlot.builder()
                .imageSlotId(1L)
                .template(t)
                .placeholderKey("K")
                .originalWidthEmu(100L)
                .originalHeightEmu(200L)
                .widthPixels(10)
                .heightPixels(20)
                .widthInches(1.1)
                .heightInches(2.2)
                .pagePosition("P")
                .createdAt(now)
                .build();

        assertThat(s.getImageSlotId()).isEqualTo(1L);
        s.setImageSlotId(2L);
        assertThat(s.getImageSlotId()).isEqualTo(2L);

        // Getters
        assertThat(s.getTemplate()).isEqualTo(t);
        assertThat(s.getPlaceholderKey()).isEqualTo("K");
        assertThat(s.getOriginalWidthEmu()).isEqualTo(100L);
        assertThat(s.getOriginalHeightEmu()).isEqualTo(200L);
        assertThat(s.getWidthPixels()).isEqualTo(10);
        assertThat(s.getHeightPixels()).isEqualTo(20);
        assertThat(s.getWidthInches()).isEqualTo(1.1);
        assertThat(s.getHeightInches()).isEqualTo(2.2);
        assertThat(s.getPagePosition()).isEqualTo("P");
        assertThat(s.getCreatedAt()).isEqualTo(now);

        // Setters
        s.setTemplate(null);
        s.setPlaceholderKey(null);
        s.setOriginalWidthEmu(null);
        s.setOriginalHeightEmu(null);
        s.setWidthPixels(null);
        s.setHeightPixels(null);
        s.setWidthInches(null);
        s.setHeightInches(null);
        s.setPagePosition(null);
        s.setCreatedAt(null);
    }

    @Test
    void testBwvrReportImageExhaustive() {
        BwvrReportImage i = new BwvrReportImage();
        BwvrReport r = new BwvrReport();
        LocalDateTime now = LocalDateTime.now();
        byte[] data = new byte[]{1};

        i.setImageId(1L);
        i.setReport(r);
        i.setPlaceholderKey("K");
        i.setFileName("F");
        i.setContentType("C");
        i.setImageData(data);
        i.setCreatedAt(now);

        assertThat(i.getImageId()).isEqualTo(1L);
        assertThat(i.getReport()).isEqualTo(r);
        assertThat(i.getPlaceholderKey()).isEqualTo("K");
        assertThat(i.getFileName()).isEqualTo("F");
        assertThat(i.getContentType()).isEqualTo("C");
        assertThat(i.getImageData()).isEqualTo(data);
        assertThat(i.getCreatedAt()).isEqualTo(now);
    }
}
