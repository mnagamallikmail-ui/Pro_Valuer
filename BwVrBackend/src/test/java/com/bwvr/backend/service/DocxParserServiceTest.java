package com.bwvr.backend.service;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;

import org.apache.poi.util.Units;
import org.apache.poi.wp.usermodel.HeaderFooterType;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFFooter;
import org.apache.poi.xwpf.usermodel.XWPFHeader;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.ArgumentCaptor;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import org.mockito.Captor;
import org.mockito.Mock;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;

import com.bwvr.backend.entity.BwvrTemplate;
import com.bwvr.backend.entity.BwvrTemplateImageSlot;
import com.bwvr.backend.entity.BwvrTemplatePlaceholder;
import com.bwvr.backend.repository.TemplateImageSlotRepository;
import com.bwvr.backend.repository.TemplatePlaceholderRepository;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class DocxParserServiceTest {

    @Mock
    private TemplatePlaceholderRepository placeholderRepository;
    @Mock
    private TemplateImageSlotRepository imageSlotRepository;
    @Mock
    private PlaceholderIntelligenceService intelligenceService;

    private DocxParserService docxParserService;

    @TempDir
    Path tempDir;

    @Captor
    private ArgumentCaptor<Iterable<BwvrTemplatePlaceholder>> captor;

    @BeforeEach
    public void setUp() {
        docxParserService = new DocxParserService(placeholderRepository, imageSlotRepository, intelligenceService);
    }

    @Test
    void parseTemplate_success() throws Exception {
        Path docPath = tempDir.resolve("test.docx");
        createTestDocx(docPath);

        BwvrTemplate template = BwvrTemplate.builder()
                .templateId(1L)
                .templateName("Test Template")
                .templateFilePath(docPath.toString())
                .build();

        when(intelligenceService.generateQuestion(anyString())).thenReturn("Mock Question?");

        docxParserService.parseTemplate(template);

        verify(placeholderRepository).deleteByTemplate_TemplateId(1L);

        verify(placeholderRepository).saveAll(captor.capture());

        Iterable<BwvrTemplatePlaceholder> saved = captor.getValue();
        // Placeholders in doc: <<VENDOR_NAME>>, <<DATE_REPORT>>, <<TABLE_VAL>>, <<HDR_VAL>>, <<FTR_VAL>>, and image placeholder
        assertThat(saved).hasSize(6);

        // Verify image slot extraction
        verify(imageSlotRepository, atLeastOnce()).save(any(BwvrTemplateImageSlot.class));
    }

    @Test
    void parseTemplate_withEmptyDoc() throws Exception {
        Path docPath = tempDir.resolve("empty.docx");
        try (XWPFDocument doc = new XWPFDocument()) {
            try (FileOutputStream out = new FileOutputStream(docPath.toFile())) {
                doc.write(out);
            }
        }

        BwvrTemplate template = BwvrTemplate.builder()
                .templateId(2L)
                .templateFilePath(docPath.toString())
                .build();

        docxParserService.parseTemplate(template);
        verify(placeholderRepository).saveAll(any());
    }

    private void createTestDocx(Path path) throws IOException {
        try (XWPFDocument doc = new XWPFDocument()) {
            // Header
            XWPFHeader hdr = doc.createHeader(HeaderFooterType.DEFAULT);
            hdr.createParagraph().createRun().setText("Header with <<HDR_VAL>>");

            // Body Heading
            XWPFParagraph p1 = doc.createParagraph();
            p1.setStyle("Heading1");
            p1.createRun().setText("Section Alpha");

            // Body Paragraph
            XWPFParagraph p2 = doc.createParagraph();
            p2.createRun().setText("Hello <<VENDOR_NAME>> on <<DATE_REPORT>>");

            // Table
            XWPFTable table = doc.createTable(2, 2);
            table.getRow(0).getCell(0).setText("Col1");
            table.getRow(0).getCell(1).setText("Col2");
            table.getRow(1).getCell(0).setText("Value");
            table.getRow(1).getCell(1).setText("Data <<TABLE_VAL>>");

            // Footer
            XWPFFooter ftr = doc.createFooter(HeaderFooterType.DEFAULT);
            ftr.createParagraph().createRun().setText("Footer <<FTR_VAL>>");

            // Image Slot (using CTR directly as it's hard to add real images in unit tests easily)
            XWPFParagraph pImg = doc.createParagraph();
            XWPFRun rImg = pImg.createRun();
            // This is minimal XML for an image extent which DocxParserService looks for
            try {
                // We use الوحدات (Units) to match DocxParserService expectations
                rImg.addPicture(new java.io.ByteArrayInputStream(new byte[0]), XWPFDocument.PICTURE_TYPE_PNG, "test.png", Units.toEMU(100), Units.toEMU(50));
            } catch (org.apache.poi.openxml4j.exceptions.InvalidFormatException | java.io.IOException e) {
                // ignore
            }

            try (FileOutputStream out = new FileOutputStream(path.toFile())) {
                doc.write(out);
            }
        }
    }
}
