package com.bwvr.backend.service;

import com.bwvr.backend.util.PlaceholderExtractor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * Maps placeholder keys to intelligent, human-readable questions.
 * Uses a dictionary-first approach with a smart fallback for unknown keys.
 */
@Service
public class PlaceholderIntelligenceService {

    private static final Map<String, String> QUESTION_MAP = new HashMap<>();

    static {
        // Text fields
        QUESTION_MAP.put("VENDOR_NAME",        "What is the name of the vendor?");
        QUESTION_MAP.put("VENDOR_ADDRESS",      "What is the vendor's full address?");
        QUESTION_MAP.put("VENDOR_CONTACT",      "What is the vendor's contact number?");
        QUESTION_MAP.put("VENDOR_EMAIL",        "What is the vendor's email address?");
        QUESTION_MAP.put("BANK_NAME",           "What is the name of the bank?");
        QUESTION_MAP.put("BANK_ADDRESS",        "What is the bank's address?");
        QUESTION_MAP.put("BANK_BRANCH",         "What is the bank branch name?");
        QUESTION_MAP.put("REPORT_TITLE",        "What is the title of this report?");
        QUESTION_MAP.put("REPORT_PERIOD",       "What period does this report cover?");
        QUESTION_MAP.put("REPORT_NUMBER",       "What is the report number?");
        QUESTION_MAP.put("LOCATION",            "What is the location or branch?");
        QUESTION_MAP.put("CITY",                "What is the city name?");
        QUESTION_MAP.put("STATE",               "What is the state or province?");
        QUESTION_MAP.put("COUNTRY",             "What is the country?");
        QUESTION_MAP.put("AUDITOR_NAME",        "What is the name of the auditor?");
        QUESTION_MAP.put("AUDITOR_DESIGNATION", "What is the auditor's designation?");
        QUESTION_MAP.put("AUDITOR_FIRM",        "What is the name of the audit firm?");
        QUESTION_MAP.put("REVIEWER_NAME",       "What is the reviewer's name?");
        QUESTION_MAP.put("APPROVER_NAME",       "What is the approver's name?");
        QUESTION_MAP.put("SIGNATORY_NAME",      "What is the signatory's name?");
        QUESTION_MAP.put("DESIGNATION",         "What is the designation?");
        QUESTION_MAP.put("DEPARTMENT",          "What is the department name?");
        QUESTION_MAP.put("ACCOUNT_NUMBER",      "What is the account number?");
        QUESTION_MAP.put("IFSC_CODE",           "What is the IFSC code?");
        QUESTION_MAP.put("PAN_NUMBER",          "What is the PAN number?");
        QUESTION_MAP.put("GST_NUMBER",          "What is the GST registration number?");
        QUESTION_MAP.put("CIN_NUMBER",          "What is the CIN (Company Identification Number)?");
        QUESTION_MAP.put("TOTAL_AMOUNT",        "What is the total amount?");
        QUESTION_MAP.put("CURRENCY",            "What is the currency?");
        QUESTION_MAP.put("REMARKS",             "Please enter any remarks or observations.");
        QUESTION_MAP.put("FINDINGS",            "What are the key findings?");
        QUESTION_MAP.put("RECOMMENDATIONS",     "What are the recommendations?");
        QUESTION_MAP.put("OBSERVATIONS",        "What are the observations?");
        QUESTION_MAP.put("SCOPE",               "What is the scope of this report?");
        QUESTION_MAP.put("OBJECTIVE",           "What is the objective of this report?");
        QUESTION_MAP.put("METHODOLOGY",         "What methodology was used?");

        // Date fields
        QUESTION_MAP.put("DATE_REPORT_GEN",      "What is the report generation date?");
        QUESTION_MAP.put("DATE_AUDIT_START",     "What is the audit start date?");
        QUESTION_MAP.put("DATE_AUDIT_END",       "What is the audit end date?");
        QUESTION_MAP.put("DATE_SUBMISSION",      "What is the submission date?");
        QUESTION_MAP.put("DATE_REVIEW",          "What is the review date?");
        QUESTION_MAP.put("DATE_APPROVAL",        "What is the approval date?");
        QUESTION_MAP.put("DATE_ENGAGEMENT",      "What is the engagement date?");
        QUESTION_MAP.put("DATE_FROM",            "What is the start date?");
        QUESTION_MAP.put("DATE_TO",              "What is the end date?");
        QUESTION_MAP.put("DATE_OF_VISIT",        "What is the date of visit?");
        QUESTION_MAP.put("DATE_OF_BIRTH",        "What is the date of birth?");
        QUESTION_MAP.put("DATE_INCORPORATION",   "What is the date of incorporation?");

        // Image fields
        QUESTION_MAP.put("IMG_COVER_PAGE",       "Upload the cover page image");
        QUESTION_MAP.put("IMG_LOGO",             "Upload the bank/organization logo image");
        QUESTION_MAP.put("IMG_BANK_LOGO",        "Upload the bank logo image");
        QUESTION_MAP.put("IMG_VENDOR_LOGO",      "Upload the vendor logo image");
        QUESTION_MAP.put("IMG_SIGNATURE",        "Upload the authorized signature image");
        QUESTION_MAP.put("IMG_STAMP",            "Upload the official stamp image");
        QUESTION_MAP.put("IMG_PHOTO",            "Upload the photo");
        QUESTION_MAP.put("IMG_WATERMARK",        "Upload the watermark image");
        QUESTION_MAP.put("IMG_HEADER_BANNER",    "Upload the header banner image");
        QUESTION_MAP.put("IMG_FOOTER_LOGO",      "Upload the footer logo image");
    }

    /**
     * Returns the intelligent question for a placeholder key.
     * First checks the dictionary, then generates a question from the key itself.
     */
    public String generateQuestion(String placeholderKey) {
        // Direct dictionary lookup
        if (QUESTION_MAP.containsKey(placeholderKey)) {
            return QUESTION_MAP.get(placeholderKey);
        }

        // Prefix-specific fallback generation
        String prefix = PlaceholderExtractor.extractPrefix(placeholderKey);
        String label = PlaceholderExtractor.toDisplayLabel(placeholderKey);

        return switch (prefix) {
            case "IMG"  -> "Upload the " + label.toLowerCase() + " image";
            case "DATE" -> "What is the " + label.toLowerCase() + "?";
            default     -> "What is the " + label.toLowerCase() + "?";
        };
    }
}
