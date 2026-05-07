package com.bwvr.backend.util;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.assertj.core.api.Assertions.assertThat;

class PlaceholderExtractorTest {

    // ── extractPrefix ────────────────────────────────────────────────────────
    @ParameterizedTest(name = "extractPrefix({0}) = {1}")
    @CsvSource({
        "IMG_COVER_PAGE,        IMG",
        "LOGO_IMAGE,            IMG",
        "DATE_AUDIT_START,      DATE",
        "INSPECTION_DATE,       DATE",
        "NUM_FLOORS,            NUMBER",
        "NUMBER_ROOMS,          NUMBER",
        "SELECT_CATEGORY,       SELECT",
        "VENDOR_NAME,           TEXT",
        "BANK_NAME,             TEXT",})
    void extractPrefix(String key, String expected) {
        assertThat(PlaceholderExtractor.extractPrefix(key.trim())).isEqualTo(expected.trim());
    }

    // ── determineFieldType ───────────────────────────────────────────────────
    @ParameterizedTest(name = "determineFieldType({0}) = {1}")
    @CsvSource({
        "IMG,    IMAGE",
        "DATE,   DATE",
        "NUMBER, NUMBER",
        "SELECT, SELECT",
        "TEXT,   TEXT",
        "OTHER,  TEXT",})
    void determineFieldType(String prefix, String expected) {
        assertThat(PlaceholderExtractor.determineFieldType(prefix.trim())).isEqualTo(expected.trim());
    }

    // ── toDisplayLabel ───────────────────────────────────────────────────────
    @ParameterizedTest(name = "toDisplayLabel({0}) = {1}")
    @CsvSource({
        "VENDOR_NAME,           Vendor Name",
        "IMG_FRONT_ELEVATION,   Front Elevation",
        "DATE_INSPECTION,       Inspection",
        "NUM_FLOORS,            Floors",
        "NUMBER_ROOMS,          Rooms",
        "SELECT_REGION,         Region",
        "BANK_NAME,             Bank Name",})
    void toDisplayLabel(String key, String expected) {
        assertThat(PlaceholderExtractor.toDisplayLabel(key.trim())).isEqualTo(expected.trim());
    }

    @Test
    void getMatcher_findsPlaceholders() {
        var matcher = PlaceholderExtractor.getMatcher("Hello <<VENDOR_NAME>> and <<DATE_START>>");
        assertThat(matcher.find()).isTrue();
        assertThat(matcher.group(1)).isEqualTo("VENDOR_NAME");
        assertThat(matcher.find()).isTrue();
        assertThat(matcher.group(1)).isEqualTo("DATE_START");
    }

    @Test
    void getMatcher_noMatch_whenNoBrackets() {
        var matcher = PlaceholderExtractor.getMatcher("Plain text without placeholders");
        assertThat(matcher.find()).isFalse();
    }
}
