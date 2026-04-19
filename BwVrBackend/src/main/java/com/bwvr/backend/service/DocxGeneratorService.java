package com.bwvr.backend.service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFFooter;
import org.apache.poi.xwpf.usermodel.XWPFHeader;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;
import org.docx4j.TraversalUtil;
import org.docx4j.dml.wordprocessingDrawing.Anchor;
import org.docx4j.dml.wordprocessingDrawing.Inline;
import org.docx4j.finders.ClassFinder;
import org.docx4j.openpackaging.packages.WordprocessingMLPackage;
import org.docx4j.openpackaging.parts.WordprocessingML.BinaryPartAbstractImage;
import org.docx4j.relationships.Relationship;
import org.docx4j.wml.ContentAccessor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.bwvr.backend.entity.BwvrReport;
import com.bwvr.backend.entity.BwvrReportValue;
import com.bwvr.backend.exception.ResourceNotFoundException;
import com.bwvr.backend.exception.TemplateParseException;
import com.bwvr.backend.repository.ReportRepository;
import com.bwvr.backend.repository.ReportValueRepository;

@Service
@SuppressWarnings("null")
public class DocxGeneratorService {

    private static final Logger log = LoggerFactory.getLogger(DocxGeneratorService.class);
    private static final DateTimeFormatter DISPLAY_DATE_FORMAT = DateTimeFormatter.ofPattern("dd-MMM-yyyy", java.util.Locale.ENGLISH);
    private static final DateTimeFormatter ISO_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter ALTERNATE_DATE_FORMAT = DateTimeFormatter.ofPattern("dd-MMM-yyyy", java.util.Locale.ENGLISH);

    private final ReportRepository reportRepository;
    private final ReportValueRepository reportValueRepository;

    @Value("${bwvr.report.output.dir}")
    private String reportOutputDir;

    static {
        // Force the use of the JAXB Reference Implementation to avoid issues with other providers
        System.setProperty("javax.xml.bind.context.factory", "com.sun.xml.bind.v2.ContextFactory");
    }

    public DocxGeneratorService(ReportRepository reportRepository, ReportValueRepository reportValueRepository) {
        this.reportRepository = reportRepository;
        this.reportValueRepository = reportValueRepository;
    }

    public String generateDocument(Long reportId) {
        BwvrReport report = reportRepository.findById(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Report", reportId));

        String templatePath = report.getTemplate().getTemplateFilePath();
        List<BwvrReportValue> values = reportValueRepository.findByReport_ReportId(reportId);

        // 1) Build value maps
        int total = 0;
        int filled = 0;
        List<String> missingTextFields = new ArrayList<>();
        List<String> missingImages = new ArrayList<>();

        Map<String, String> textMap = new HashMap<>();    // placeholder key -> replacement text
        Map<String, BwvrReportValue> imageMap = new HashMap<>(); // placeholder key -> image value

        for (BwvrReportValue v : values) {
            total++;
            String prefix = v.getPlaceholder() != null ? v.getPlaceholder().getPlaceholderPrefix() : "TEXT";
            boolean isImage = "IMG".equalsIgnoreCase(prefix);
            boolean hasVal = (v.getTextValue() != null && !v.getTextValue().isBlank())
                    || (v.getImageFilePath() != null && !v.getImageFilePath().isBlank())
                    || (v.getImageData() != null && v.getImageData().length > 0);
            if (hasVal) {
                filled++;
            } else {
                if (isImage) {
                    missingImages.add(v.getPlaceholder() != null ? v.getPlaceholder().getDisplayLabel() : v.getPlaceholderKey().replace("<", "").replace(">", ""));
                } else {
                    missingTextFields.add(v.getPlaceholder() != null ? v.getPlaceholder().getDisplayLabel() : v.getPlaceholderKey().replace("<", "").replace(">", ""));
                }
            }

            if (isImage) {
                String cleanKey = v.getPlaceholderKey().replaceAll("[<>]", "");
                imageMap.put(cleanKey, v);
                imageMap.put(v.getPlaceholderKey(), v);
                if (v.getPlaceholder() != null) {
                    imageMap.put(v.getPlaceholder().getPlaceholderKey(), v);
                    imageMap.put(v.getPlaceholder().getPlaceholderKey().replaceAll("[<>]", ""), v);
                }
            } else {
                String resolved = resolveTextValue(v);
                textMap.put(v.getPlaceholderKey(), resolved);
                if (v.getPlaceholder() != null) {
                    textMap.put(v.getPlaceholder().getPlaceholderKey(), resolved);
                }
            }
        }

        try {
            // ── Step 1: load template bytes ──────────────────────────────────────────
            byte[] templateBytes;
            if (report.getTemplate().getTemplateContent() != null
                    && report.getTemplate().getTemplateContent().length > 0) {
                templateBytes = report.getTemplate().getTemplateContent();
            } else {
                templateBytes = Files.readAllBytes(Paths.get(templatePath));
            }

            // ── Step 2: text replacement via Apache POI (preserves run formatting) ──
            byte[] afterTextReplacement;
            try (XWPFDocument doc = new XWPFDocument(new ByteArrayInputStream(templateBytes))) {

                // Body paragraphs
                for (XWPFParagraph para : doc.getParagraphs()) {
                    replaceParagraphPlaceholders(para, textMap);
                }
                // Tables
                for (XWPFTable table : doc.getTables()) {
                    for (XWPFTableRow row : table.getRows()) {
                        for (XWPFTableCell cell : row.getTableCells()) {
                            for (XWPFParagraph para : cell.getParagraphs()) {
                                replaceParagraphPlaceholders(para, textMap);
                            }
                        }
                    }
                }
                // Headers
                for (XWPFHeader header : doc.getHeaderList()) {
                    for (XWPFParagraph para : header.getParagraphs()) {
                        replaceParagraphPlaceholders(para, textMap);
                    }
                }
                // Footers
                for (XWPFFooter footer : doc.getFooterList()) {
                    for (XWPFParagraph para : footer.getParagraphs()) {
                        replaceParagraphPlaceholders(para, textMap);
                    }
                }

                // Missing data summary – appended at END (safe; no XML-level insertion)
                if (filled < total) {
                    appendMissingSummary(doc, missingTextFields, missingImages, filled, total);
                }

                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                doc.write(bos);
                afterTextReplacement = bos.toByteArray();
            }

            // ── Step 3: image replacement via docx4j (handles shape Alt-Text placeholders) ─
            byte[] finalBytes;
            if (!imageMap.isEmpty()) {
                WordprocessingMLPackage pkg = WordprocessingMLPackage
                        .load(new ByteArrayInputStream(afterTextReplacement));
                replaceImagesWithDocx4j(pkg, imageMap);
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                pkg.save(bos);
                finalBytes = bos.toByteArray();
            } else {
                finalBytes = afterTextReplacement;
            }

            // ── Step 4: write output file ─────────────────────────────────────────────
            Path outputDir = Paths.get(reportOutputDir, String.valueOf(reportId));
            Files.createDirectories(outputDir);
            Path outputPath = outputDir.resolve("output.docx");
            Files.write(outputPath, finalBytes);

            report.setGeneratedFilePath(outputPath.toAbsolutePath().toString());
            report.setGeneratedAt(LocalDateTime.now());
            report.setReportStatus("COMPLETED");
            reportRepository.save(report);

            log.info("Generated document for report {} at {}", reportId, outputPath);
            return outputPath.toAbsolutePath().toString();

        } catch (java.io.IOException | org.docx4j.openpackaging.exceptions.Docx4JException | RuntimeException e) {
            log.error("Failed generation for report {}", reportId, e);
            throw new TemplateParseException("Failed to generate document: " + (e.getMessage() != null ? e.getMessage() : e.getClass().getName()), e);
        }
    }

    /**
     * Replaces all <<KEY>> placeholders in a paragraph while preserving per-run
     * formatting. Handles the common Word behavior of splitting a single
     * placeholder across multiple runs.
     */
    private void replaceParagraphPlaceholders(XWPFParagraph para, Map<String, String> textMap) {
        List<XWPFRun> runs = para.getRuns();
        if (runs == null || runs.isEmpty()) {
            return;
        }

        // Build the full paragraph text, tracking which characters came from which run
        StringBuilder sb = new StringBuilder();

        // First pass: count total chars
        int totalChars = 0;
        for (XWPFRun r : runs) {
            String t = r.getText(0);
            if (t != null) {
                totalChars += t.length();
            }
        }
        if (totalChars == 0) {
            return;
        }

        for (XWPFRun run : runs) {
            String t = run.getText(0);
            if (t == null) {
                continue;
            }
            sb.append(t);
        }

        String combined = sb.toString();
        if (!combined.contains("<<") || !combined.contains(">>")) {
            return;
        }

        // Perform all replacements on the combined string, tracking offset shifts
        String modified = combined;
        boolean anyReplaced = false;
        for (Map.Entry<String, String> entry : textMap.entrySet()) {
            if (modified.contains(entry.getKey())) {
                modified = modified.replace(entry.getKey(), entry.getValue());
                anyReplaced = true;
            }
        }
        if (!anyReplaced) {
            return;
        }

        // Apply the fully-replaced string back:
        // Strategy: put the full replacement text into the FIRST run, clear all others.
        // This preserves the first run's formatting for the replacement text.
        XWPFRun firstRun = runs.get(0);
        firstRun.setText(modified, 0);
        for (int i = 1; i < runs.size(); i++) {
            if (runs.get(i).getText(0) != null) {
                runs.get(i).setText("", 0);
            }
        }
    }

    /**
     * Safely appends a missing-data summary at the END of the document. Uses
     * only doc.createParagraph() – NO XML-level CTBody manipulation.
     */
    private void appendMissingSummary(XWPFDocument doc, List<String> missingText,
            List<String> missingImages, int filled, int total) {
        List<String> lines = new ArrayList<>();
        lines.add("");
        lines.add("========================================");
        lines.add("MISSING DATA SUMMARY  (Filled: " + filled + "/" + total + ")");
        for (String f : missingText) {
            lines.add("  \u2022 Missing field: " + f);
        }
        for (String img : missingImages) {
            lines.add("  \u2022 Missing image: " + img);
        }
        lines.add("========================================");

        for (String line : lines) {
            XWPFParagraph p = doc.createParagraph();
            XWPFRun r = p.createRun();
            r.setText(line);
        }
    }

    /**
     * Uses docx4j to locate every Drawing (inline or anchored) whose
     * docPr/@descr or docPr/@name matches an IMG_ placeholder, then replaces
     * the graphic content with the uploaded image bytes. Rectangular shape
     * placeholders use Alt Text, which maps to docPr/@descr in the OOXML.
     */
    private void replaceImagesWithDocx4j(WordprocessingMLPackage pkg,
            Map<String, BwvrReportValue> imageMap) {

        List<ContentAccessor> accessors = new ArrayList<>();
        accessors.add(pkg.getMainDocumentPart());

        for (Relationship rel : pkg.getMainDocumentPart().getRelationshipsPart()
                .getRelationships().getRelationship()) {
            Object part = pkg.getMainDocumentPart().getRelationshipsPart().getPart(rel);
            if (part instanceof ContentAccessor ca) {
                accessors.add(ca);
            }
        }

        int imageId1 = 10000;
        int imageId2 = 10001;

        for (ContentAccessor accessor : accessors) {
            ClassFinder drawingFinder = new ClassFinder(org.docx4j.wml.Drawing.class);
            TraversalUtil util = new TraversalUtil(accessor.getContent(), drawingFinder);
            log.trace("TraversalUtil result: {}", util);

            for (Object obj : drawingFinder.results) {
                if (!(obj instanceof org.docx4j.wml.Drawing drawing)) {
                    continue;
                }

                for (Object item : drawing.getAnchorOrInline()) {
                    String altText = null;
                    long cx = 0, cy = 0;

                    switch (item) {
                        case Inline inline -> {
                            if (inline.getDocPr() != null) {
                                altText = inline.getDocPr().getDescr();
                                if (altText == null || altText.isBlank()) {
                                    altText = inline.getDocPr().getName();
                                }
                            }
                            if (inline.getExtent() != null) {
                                cx = inline.getExtent().getCx();
                                cy = inline.getExtent().getCy();
                            }
                        }
                        case Anchor anchor -> {
                            if (anchor.getDocPr() != null) {
                                altText = anchor.getDocPr().getDescr();
                                if (altText == null || altText.isBlank()) {
                                    altText = anchor.getDocPr().getName();
                                }
                            }
                            if (anchor.getExtent() != null) {
                                cx = anchor.getExtent().getCx();
                                cy = anchor.getExtent().getCy();
                            }
                        }
                        default -> {
                        }
                    }

                    if (altText == null || !altText.toUpperCase().contains("IMG_")) {
                        continue;
                    }

                    BwvrReportValue imgVal = findImageValue(altText, imageMap);
                    if (imgVal == null) {
                        continue;
                    }

                    byte[] bytes = getImageBytes(imgVal);
                    if (bytes == null || bytes.length == 0) {
                        continue;
                    }

                    try {
                        BinaryPartAbstractImage imagePart
                                = BinaryPartAbstractImage.createImagePart(pkg, bytes);
                        Inline newInline = imagePart.createImageInline(
                                null, altText, imageId1, imageId2, false);
                        imageId1 += 2;
                        imageId2 += 2;

                        // Extract just the graphic (image blip) from the new inline
                        org.docx4j.dml.Graphic newGraphic = newInline.getGraphic();

                        // Scale the graphic to match the original placeholder dimensions
                        try {
                            if (cx > 0) {
                                newGraphic.getGraphicData().getPic()
                                        .getSpPr().getXfrm().getExt().setCx(cx);
                            }
                            if (cy > 0) {
                                newGraphic.getGraphicData().getPic()
                                        .getSpPr().getXfrm().getExt().setCy(cy);
                            }
                        } catch (NullPointerException | IllegalStateException ignored) {
                        }

                        // CRITICAL: keep the existing anchor/inline wrapper so that
                        // position, text-wrap, and size properties are NOT changed.
                        // Only replace the inner <a:graphic> element.
                        switch (item) {
                            case Inline existingInline -> {
                                existingInline.setGraphic(newGraphic);
                                if (cx > 0 && existingInline.getExtent() != null) {
                                    existingInline.getExtent().setCx(cx);
                                }
                                if (cy > 0 && existingInline.getExtent() != null) {
                                    existingInline.getExtent().setCy(cy);
                                }
                            }
                            case Anchor existingAnchor -> {
                                existingAnchor.setGraphic(newGraphic);
                                if (cx > 0 && existingAnchor.getExtent() != null) {
                                    existingAnchor.getExtent().setCx(cx);
                                }
                                if (cy > 0 && existingAnchor.getExtent() != null) {
                                    existingAnchor.getExtent().setCy(cy);
                                }
                            }
                            default -> {
                            }
                        }
                        log.info("Replaced image placeholder '{}' with uploaded image", altText);
                    } catch (Exception e) {
                        log.warn("Failed to replace image for placeholder '{}': {}", altText,
                                e.getMessage());
                    }
                }
            }
        }
    }

    private byte[] getImageBytes(BwvrReportValue imgVal) {
        if (imgVal.getImageData() != null && imgVal.getImageData().length > 0) {
            return imgVal.getImageData();
        }
        if (imgVal.getImageFilePath() != null) {
            try {
                File f = new File(imgVal.getImageFilePath());
                if (f.exists()) {
                    return Files.readAllBytes(f.toPath());
                }
            } catch (java.io.IOException e) {
                log.warn("Could not read image file: {}", e.getMessage());
            }
        }
        return null;
    }

    private BwvrReportValue findImageValue(String altText, Map<String, BwvrReportValue> imageMap) {
        if (imageMap.containsKey(altText)) {
            return imageMap.get(altText);
        }
        String clean = altText.replaceAll("[<> ]", "");
        if (imageMap.containsKey(clean)) {
            return imageMap.get(clean);
        }
        for (String k : imageMap.keySet()) {
            String kClean = k.replaceAll("[<> ]", "");
            if (k.equalsIgnoreCase(altText) || kClean.equalsIgnoreCase(clean) || altText.contains(kClean)) {
                return imageMap.get(k);
            }
        }
        return null;
    }

    private String resolveTextValue(BwvrReportValue val) {
        String text = val.getTextValue();
        if (text == null || text.isBlank()) {
            String prefix = val.getPlaceholder() != null ? val.getPlaceholder().getPlaceholderPrefix() : "TEXT";
            return "IMG".equalsIgnoreCase(prefix) ? "" : "—";
        }

        // Broad sanitization for XML safety
        text = text.replaceAll("[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\uFFFE\\uFFFF]", "");

        String prefix = val.getPlaceholder() != null ? val.getPlaceholder().getPlaceholderPrefix() : "TEXT";
        if ("DATE".equalsIgnoreCase(prefix)) {
            try {
                return LocalDate.parse(text, ISO_DATE_FORMAT).format(DISPLAY_DATE_FORMAT);
            } catch (Exception e) {
                try {
                    return LocalDate.parse(text, ALTERNATE_DATE_FORMAT).format(DISPLAY_DATE_FORMAT);
                } catch (Exception ignored) {
                }
            }
        }
        return text;
    }
}
