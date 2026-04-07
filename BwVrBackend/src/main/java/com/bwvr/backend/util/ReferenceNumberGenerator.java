package com.bwvr.backend.util;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.springframework.stereotype.Component;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Component
public class ReferenceNumberGenerator {

    @PersistenceContext
    private EntityManager entityManager;

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyyMMdd");

    /**
     * Generates a unique reference number in the format: REF-YYYYMMDD-{6-digit
     * zero-padded sequence} Example: REF-20240315-001000
     */
    public String generate() {
        Object nextValObj = entityManager
                .createNativeQuery("SELECT BWVR.SEQ_REPORT_REF_NUM.NEXTVAL FROM DUAL")
                .getSingleResult();
        Long nextVal;
        if (nextValObj instanceof Number n) {
            nextVal = n.longValue();
        } else if (nextValObj != null) {
            nextVal = Long.valueOf(nextValObj.toString());
        } else {
            throw new RuntimeException("Sequence value is null");
        }
        String date = LocalDate.now().format(DATE_FORMAT);
        return String.format("REF-%s-%06d", date, nextVal);
    }
}
