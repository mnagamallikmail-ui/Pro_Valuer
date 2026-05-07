package com.bwvr.backend.service;

import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;

import javax.xml.namespace.QName;

import org.apache.poi.xwpf.usermodel.IBodyElement;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFFooter;
import org.apache.poi.xwpf.usermodel.XWPFHeader;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;
import org.apache.xmlbeans.XmlCursor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bwvr.backend.entity.BwvrTemplate;
import com.bwvr.backend.entity.BwvrTemplateImageSlot;
import com.bwvr.backend.entity.BwvrTemplatePlaceholder;
import com.bwvr.backend.exception.TemplateParseException;
import com.bwvr.backend.repository.TemplateImageSlotRepository;
import com.bwvr.backend.repository.TemplatePlaceholderRepository;
import com.bwvr.backend.util.PlaceholderExtractor;

/**
 * Parses an uploaded .docx template and extracts: 1. All placeholders matching
 * the <<PREFIX_NAME>> pattern from body paragraphs, table cells, headers, and
 * footers. 2. Image slot dimensions (EMU width/height) from inline drawings
 * using raw XML cursor traversal — fully compatible with poi-ooxml-lite (no
 * generated schema classes required, no deprecated selectPath() API used).
 */
@Service
@SuppressWarnings("null")
public class DocxParserService {

    private static final Logger log = LoggerFactory.getLogger(DocxParserService.class);
    private static final long EMU_PER_INCH = 914400L;
    private static final String WP_DRAWING_NS
            = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing";

    private final TemplatePlaceholderRepository placeholderRepository;
    private final TemplateImageSlotRepository imageSlotRepository;
    private final PlaceholderIntelligenceService intelligenceService;

    public DocxParserService(TemplatePlaceholderRepository placeholderRepository,
            TemplateImageSlotRepository imageSlotRepository,
            PlaceholderIntelligenceService intelligenceService) {
        this.placeholderRepository = placeholderRepository;
        this.imageSlotRepository = imageSlotRepository;
        this.intelligenceService = intelligenceService;
    }

    // ─────────────────────────── public API ─────────────────────────────────
    /**
     * Main entry: parses the template .docx file and persists all placeholders
     * and image dimension slots.
     */
    @Transactional
    public void parseTemplate(BwvrTemplate template) {
        String filePath = template.getTemplateFilePath();
        log.info("Parsing template: {} from {}", template.getTemplateName(), filePath);

        try (XWPFDocument document = new XWPFDocument(
                java.nio.file.Files.newInputStream(Paths.get(filePath)))) {

            // Delete any previously parsed placeholders for this template
            placeholderRepository.deleteByTemplate_TemplateId(template.getTemplateId());

            Map<String, BwvrTemplatePlaceholder> seen = new LinkedHashMap<>();
            int order = 0;

            // 1 ─ Body elements (Paragraphs & Tables in order)
            String currentSection = "General Information";
            int tableIdx = 0;

            for (IBodyElement element : document.getBodyElements()) {
                switch (element) {
                    case XWPFParagraph para -> {
                        String style = para.getStyle();
                        String text = para.getText().trim();
                        if (style != null && (style.toLowerCase().contains("heading") || style.startsWith("1") || style.startsWith("2")) && !text.isEmpty()) {
                            currentSection = text;
                        }
                        order = scanText(text, template, seen, order, currentSection, null, null, null);
                    }
                    case XWPFTable table -> {
                        List<XWPFTableRow> rows = table.getRows();
                        for (int rIdx = 0; rIdx < rows.size(); rIdx++) {
                            List<XWPFTableCell> cells = rows.get(rIdx).getTableCells();
                            String col1 = !cells.isEmpty() ? cells.get(0).getText().trim() : null;
                            String col2 = cells.size() > 1 ? cells.get(1).getText().trim() : null;
                            for (int cIdx = 0; cIdx < cells.size(); cIdx++) {
                                String ctx = String.format("T%d_R%d_C%d", tableIdx, rIdx, cIdx);
                                order = scanText(cells.get(cIdx).getText(), template, seen, order, currentSection, ctx, col1, col2);
                            }
                        }
                        tableIdx++;
                    }
                    default -> {
                        /* skip other body elements */ }
                }
            }

            // 2 ─ Headers
            for (XWPFHeader header : document.getHeaderList()) {
                for (XWPFParagraph para : header.getParagraphs()) {
                    order = scanText(para.getText(), template, seen, order, "Header", null, null, null);
                }
            }

            // 3 ─ Footers
            for (XWPFFooter footer : document.getFooterList()) {
                for (XWPFParagraph para : footer.getParagraphs()) {
                    order = scanText(para.getText(), template, seen, order, "Footer", null, null, null);
                }
            }

            // 5 ─ Image dimensions and replacement
            extractImageDimensionsAndReplace(document, template, seen, order);

            placeholderRepository.saveAll(seen.values());
            log.info("Parsed {} placeholders for template {}", seen.size(), template.getTemplateId());

            // Write modified document to ByteArray
            java.io.ByteArrayOutputStream bos = new java.io.ByteArrayOutputStream();
            document.write(bos);
            template.setTemplateContent(bos.toByteArray());

        } catch (Exception e) {
            throw new TemplateParseException("Failed to parse template: " + e.getMessage(), e);
        }
    }

    // ─────────────────────────── private helpers ─────────────────────────────
    private int scanText(String text, BwvrTemplate template,
            Map<String, BwvrTemplatePlaceholder> seen,
            int order, String sectionName, String tableCtx, String col1, String col2) {
        if (text == null || text.isBlank()) {
            return order;
        }
        Matcher m = PlaceholderExtractor.getMatcher(text);
        while (m.find()) {
            String key = m.group(1);
            if (!seen.containsKey(key)) {
                seen.put(key, buildPlaceholder(template, key, order++, sectionName, tableCtx, col1, col2));
            }
        }
        return order;
    }

    private BwvrTemplatePlaceholder buildPlaceholder(BwvrTemplate template, String key,
            int order, String sectionName, String tableCtx,
            String col1, String col2) {
        String prefix = PlaceholderExtractor.extractPrefix(key);
        String fieldType = PlaceholderExtractor.determineFieldType(prefix);
        String label = PlaceholderExtractor.toDisplayLabel(key);
        String question = intelligenceService.generateQuestion(key);

        return BwvrTemplatePlaceholder.builder()
                .template(template)
                .placeholderKey("<<" + key + ">>")
                .placeholderPrefix(prefix)
                .displayLabel(label)
                .questionText(question)
                .fieldType(fieldType)
                .isRequired("Y")
                .displayOrder(order)
                .sectionName(sectionName)
                .tableContext(tableCtx)
                .col1Header(col1)
                .col2Header(col2)
                .isConfirmed("N")
                .build();
    }

    /**
     * Traverse run XML with XmlCursor looking for wp:extent elements. Reads cx
     * and cy to determine image dimensions in EMU.
     *
     * Compatible with poi-ooxml-lite — avoids CTDrawing/CTInline schema classes
     * and the deprecated XmlObject.selectPath() method.
     */
    private int extractImageDimensionsAndReplace(XWPFDocument document, BwvrTemplate template,
            Map<String, BwvrTemplatePlaceholder> seen, int order) {
        imageSlotRepository.deleteAll(
                imageSlotRepository.findByTemplate_TemplateId(template.getTemplateId()));

        int imgIdx = 0;
        for (XWPFParagraph para : document.getParagraphs()) {
            for (XWPFRun run : para.getRuns()) {
                boolean hasImage = false;
                String altText = null;
                long cx = 0, cy = 0;

                try (XmlCursor cursor = run.getCTR().newCursor()) {
                    int depth = 1;
                    while (cursor.hasNextToken() && depth > 0) {
                        XmlCursor.TokenType type = cursor.toNextToken();
                        if (type == XmlCursor.TokenType.START) {
                            depth++;
                            QName qname = cursor.getName();

                            if ("docPr".equals(qname.getLocalPart()) && WP_DRAWING_NS.equals(qname.getNamespaceURI())) {
                                String descr = cursor.getAttributeText(new QName("descr"));
                                String name = cursor.getAttributeText(new QName("name"));
                                altText = (descr != null && !descr.isBlank()) ? descr : name;
                            }

                            if ("extent".equals(qname.getLocalPart()) && WP_DRAWING_NS.equals(qname.getNamespaceURI())) {
                                String cxStr = cursor.getAttributeText(new QName("cx"));
                                String cyStr = cursor.getAttributeText(new QName("cy"));
                                cx = cxStr != null ? Long.parseLong(cxStr) : 0L;
                                cy = cyStr != null ? Long.parseLong(cyStr) : 0L;

                                if (cx != 0 || cy != 0) {
                                    hasImage = true;
                                }
                            }
                        } else if (type == XmlCursor.TokenType.END) {
                            depth--;
                        }
                    }
                    if (altText != null && altText.toUpperCase().contains("IMG_")) {
                        hasImage = true;
                    }
                } catch (Exception e) {
                    log.warn("Could not extract image from run: {}", e.getMessage());
                }

                if (hasImage) {
                    if (altText == null || altText.isBlank()) {
                        altText = String.format("IMAGE_%02d", imgIdx);
                    }
                    if (!altText.toUpperCase().startsWith("IMG_")) {
                        altText = "IMG_" + altText;
                    }
                    altText = altText.replaceAll("\\s+", "_"); // ensure no spaces in key

                    try {
                        BwvrTemplateImageSlot slot = BwvrTemplateImageSlot.builder()
                                .template(template)
                                .placeholderKey("<<" + altText + ">>")
                                .originalWidthEmu(cx)
                                .originalHeightEmu(cy)
                                .widthInches(cx > 0 ? (double) cx / EMU_PER_INCH : null)
                                .heightInches(cy > 0 ? (double) cy / EMU_PER_INCH : null)
                                .widthPixels(cx > 0 ? (int) (cx / 9144) : null)
                                .heightPixels(cy > 0 ? (int) (cy / 9144) : null)
                                .pagePosition("INLINE")
                                .build();
                        imageSlotRepository.save(slot);
                        imgIdx++;
                    } catch (Exception e) {
                        log.warn("Could not save image slot {}: {}", imgIdx, e.getMessage());
                    }

                    if (!seen.containsKey(altText)) {
                        seen.put(altText, buildPlaceholder(template, altText, order++, "Body", null, null, null));
                    }
                }
            }
        }

        log.debug("Extracted and registered {} image slots for template {}", imgIdx, template.getTemplateId());
        return order;
    }
}
