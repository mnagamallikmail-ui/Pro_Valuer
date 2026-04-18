package com.bwvr.backend.util;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.atomic.AtomicLong;

import org.springframework.stereotype.Component;

@Component
public class ReferenceNumberGenerator {

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyyMMdd");
    // Seeded with nanoTime to avoid collisions across restarts
    private static final AtomicLong counter = new AtomicLong(Math.abs(System.nanoTime() % 1_000_000));

    /**
     * Generates a unique reference number in the format: REF-YYYYMMDD-{6-digit}
     * Example: REF-20240315-001000
     * Uses an in-memory atomic counter seeded with nanoseconds to ensure
     * uniqueness without requiring a database sequence.
     */
    public String generate() {
        long seq = counter.incrementAndGet() % 1_000_000;
        String date = LocalDate.now().format(DATE_FORMAT);
        return String.format("REF-%s-%06d", date, seq);
    }
}
