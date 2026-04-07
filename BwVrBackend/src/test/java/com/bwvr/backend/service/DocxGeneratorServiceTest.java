package com.bwvr.backend.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.docx4j.openpackaging.packages.WordprocessingMLPackage;
import org.docx4j.openpackaging.parts.WordprocessingML.MainDocumentPart;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import static org.mockito.ArgumentMatchers.any;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import com.bwvr.backend.entity.BwvrReport;
import com.bwvr.backend.entity.BwvrReportValue;
import com.bwvr.backend.entity.BwvrTemplate;
import com.bwvr.backend.entity.BwvrTemplatePlaceholder;
import com.bwvr.backend.exception.ResourceNotFoundException;
import com.bwvr.backend.repository.ReportRepository;
import com.bwvr.backend.repository.ReportValueRepository;

@ExtendWith(MockitoExtension.class)
class DocxGeneratorServiceTest {

    @Mock
    private ReportRepository reportRepository;
    @Mock
    private ReportValueRepository reportValueRepository;

    @InjectMocks
    private DocxGeneratorService docxGeneratorService;

    @TempDir
    Path tempDir;

    @BeforeEach
    public void setUp() {
        ReflectionTestUtils.setField(docxGeneratorService, "reportOutputDir", tempDir.toString());
    }

    @Test
    void generateDocument_success() throws Exception {
        Path templatePath = tempDir.resolve("template.docx");
        createTemplateDocx(templatePath, "Hello <<NAME>>");

        BwvrTemplate template = BwvrTemplate.builder().templateFilePath(templatePath.toString()).build();
        BwvrReport report = BwvrReport.builder().reportId(1L).template(template).build();

        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder().placeholderKey("<<NAME>>").placeholderPrefix("TEXT").build();
        BwvrReportValue val = BwvrReportValue.builder().placeholderKey("<<NAME>>").placeholder(ph).textValue("World").build();

        when(reportRepository.findById(1L)).thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportId(1L)).thenReturn(List.of(val));

        String outputPath = docxGeneratorService.generateDocument(1L);

        assertThat(outputPath).contains("output.docx");
        assertThat(new File(outputPath)).exists();
        verify(reportRepository).save(any(BwvrReport.class));
    }

    @Test
    void generateDocument_withMissingDataSummary() throws Exception {
        Path templatePath = tempDir.resolve("template_missing.docx");
        createTemplateDocx(templatePath, "<<FIELD1>> <<IMG_01>>");

        BwvrTemplate template = BwvrTemplate.builder().templateFilePath(templatePath.toString()).build();
        BwvrReport report = BwvrReport.builder().reportId(2L).template(template).build();

        BwvrTemplatePlaceholder ph1 = BwvrTemplatePlaceholder.builder().placeholderKey("<<FIELD1>>").placeholderPrefix("TEXT").displayLabel("Field 1").build();
        BwvrReportValue v1 = BwvrReportValue.builder().placeholderKey("<<FIELD1>>").placeholder(ph1).textValue("").build();

        BwvrTemplatePlaceholder ph2 = BwvrTemplatePlaceholder.builder().placeholderKey("<<IMG_01>>").placeholderPrefix("IMG").displayLabel("Image 1").build();
        BwvrReportValue v2 = BwvrReportValue.builder().placeholderKey("<<IMG_01>>").placeholder(ph2).textValue("").build();

        when(reportRepository.findById(2L)).thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportId(2L)).thenReturn(Arrays.asList(v1, v2));

        String outputPath = docxGeneratorService.generateDocument(2L);
        assertThat(new File(outputPath)).exists();
    }

    @Test
    void generateDocument_withImagesAndHeaders() throws Exception {
        Path templatePath = tempDir.resolve("template_images.docx");
        createTemplateWithHdrFtrAndImg(templatePath);

        BwvrTemplate template = BwvrTemplate.builder().templateFilePath(templatePath.toString()).build();
        BwvrReport report = BwvrReport.builder().reportId(3L).template(template).build();

        byte[] pngData = new byte[]{(byte) 0x89, 0x50, 0x4E, 0x47, 0x00};
        Path legacyFile = tempDir.resolve("legacy.jpg");
        Files.write(legacyFile, new byte[]{(byte) 0xFF, (byte) 0xD8, 0x01});

        BwvrReportValue v1 = BwvrReportValue.builder().placeholderKey("<<IMG_01>>")
                .imageData(pngData).build();
        BwvrReportValue v2 = BwvrReportValue.builder().placeholderKey("<<IMG_02>>")
                .imageFilePath(legacyFile.toString()).build();
        BwvrReportValue v3 = BwvrReportValue.builder().placeholderKey("<<HDR_VAL>>")
                .textValue("HeaderWorld").build();

        when(reportRepository.findById(3L)).thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportId(3L)).thenReturn(Arrays.asList(v1, v2, v3));

        String outputPath = docxGeneratorService.generateDocument(3L);
        assertThat(new File(outputPath)).exists();
    }

    private void createTemplateWithHdrFtrAndImg(Path path) throws Exception {
        WordprocessingMLPackage pkg = WordprocessingMLPackage.createPackage();
        MainDocumentPart mdp = pkg.getMainDocumentPart();
        mdp.addParagraphOfText("Body <<IMG_01>> and <<IMG_02>>");

        org.docx4j.openpackaging.parts.WordprocessingML.HeaderPart hdrPart = new org.docx4j.openpackaging.parts.WordprocessingML.HeaderPart();
        hdrPart.setPackage(pkg);
        hdrPart.setJaxbElement(new org.docx4j.wml.Hdr());
        hdrPart.getJaxbElement().getContent().add(mdp.createParagraphOfText("Header <<HDR_VAL>>"));
        pkg.getMainDocumentPart().addTargetPart(hdrPart);

        // Minimal drawing structure
        org.docx4j.wml.Drawing drawing = new org.docx4j.wml.ObjectFactory().createDrawing();
        org.docx4j.dml.wordprocessingDrawing.Inline inline = new org.docx4j.dml.wordprocessingDrawing.ObjectFactory().createInline();
        org.docx4j.dml.CTNonVisualDrawingProps docPr = new org.docx4j.dml.ObjectFactory().createCTNonVisualDrawingProps();
        docPr.setId(1);
        docPr.setName("IMG_01");
        docPr.setDescr("<<IMG_01>>");
        inline.setDocPr(docPr);
        drawing.getAnchorOrInline().add(inline);
        mdp.getContent().add(mdp.createParagraphOfText(""));
        mdp.addParagraphOfText("").getContent().add(drawing);

        pkg.save(path.toFile());
    }

    @Test
    void generateDocument_throwsNotFound() {
        when(reportRepository.findById(99L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> docxGeneratorService.generateDocument(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void testResolveTextValue_Date() {
        BwvrTemplatePlaceholder ph = BwvrTemplatePlaceholder.builder().placeholderPrefix("DATE").build();
        BwvrReportValue val = BwvrReportValue.builder().placeholder(ph).textValue("2023-10-25").build();
        String resolved = (String) ReflectionTestUtils.invokeMethod(docxGeneratorService, "resolveTextValue", val);
        assertThat(resolved).isEqualTo("25 October 2023");
    }

    private void createTemplateDocx(Path path, String content) throws Exception {
        WordprocessingMLPackage pkg = WordprocessingMLPackage.createPackage();
        pkg.getMainDocumentPart().addParagraphOfText(content);
        pkg.save(path.toFile());
    }
}
