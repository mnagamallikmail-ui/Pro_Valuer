package com.bwvr.backend.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PlaceholderExtractor {

    public static final Pattern PLACEHOLDER_PATTERN = Pattern.compile("<<([^>]*)>>");

    /**
     * Extracts the prefix from a placeholder key. Examples: IMG_COVER_PAGE →
     * IMG DATE_AUDIT_START → DATE VENDOR_NAME → TEXT NUMBER_PAGES → NUMBER
     */
    public static String extractPrefix(String placeholderKey) {
        String upper = placeholderKey.trim().toUpperCase();
        if (upper.contains("_IMAGE")) {
            return "IMG"; // match _image anywhere
        }
        if (upper.startsWith("IMG_")) {
            return "IMG";
        }
        if (upper.startsWith("DATE_") || upper.endsWith("_DATE")) {
            return "DATE";
        }
        if (upper.startsWith("NUM_") || upper.startsWith("NUMBER_")) {
            return "NUMBER";
        }
        if (upper.startsWith("SELECT_")) {
            return "SELECT";
        }
        return "TEXT";
    }

    /**
     * Determines the Flutter UI field type from the prefix.
     */
    public static String determineFieldType(String prefix) {
        return switch (prefix) {
            case "IMG" ->
                "IMAGE";
            case "DATE" ->
                "DATE";
            case "NUMBER" ->
                "NUMBER";
            case "SELECT" ->
                "SELECT";
            default ->
                "TEXT";
        };
    }

    /**
     * Converts snake_case placeholder key to a human-readable label. E.g.
     * VENDOR_NAME → "Vendor Name"
     */
    public static String toDisplayLabel(String placeholderKey) {
        String cleaned = placeholderKey.trim()
                .replaceAll("(?i)^(IMG|DATE|NUM|NUMBER|SELECT)_", "")
                .replaceAll("(?i)_(IMAGE|DATE)$", "")
                .replace("_", " ");

        StringBuilder sb = new StringBuilder();
        for (String word : cleaned.split("\\s+")) {
            if (!word.isEmpty()) {
                sb.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    sb.append(word.substring(1).toLowerCase());
                }
                sb.append(" ");
            }
        }
        return sb.toString().trim();
    }

    public static Matcher getMatcher(String text) {
        return PLACEHOLDER_PATTERN.matcher(text);
    }

    private PlaceholderExtractor() {
    }
}
