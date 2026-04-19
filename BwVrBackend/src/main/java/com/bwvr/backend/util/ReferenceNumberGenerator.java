package com.bwvr.backend.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import java.util.concurrent.atomic.AtomicLong;
import com.bwvr.backend.repository.ReportRepository;

@Component
public class ReferenceNumberGenerator {

    private final ReportRepository reportRepository;
    private final AtomicLong counter = new AtomicLong(0);
    private volatile boolean initialized = false;

    @Autowired
    public ReferenceNumberGenerator(ReportRepository reportRepository) {
        this.reportRepository = reportRepository;
    }

    /**
     * Generates a unique numeric reference number exactly 5 digits long (e.g. 10000, 10001).
     * It queries the DB on first usage for the highest existing purely numeric 
     * reference number, then uses an in-memory atomic counter.
     */
    public String generate() {
        if (!initialized) {
            synchronized (this) {
                if (!initialized) {
                    Long maxRef = reportRepository.findMaxNumericReferenceNumber();
                    long start = (maxRef != null && maxRef >= 10000) ? maxRef : 9999;
                    counter.set(start);
                    initialized = true;
                }
            }
        }
        long seq = counter.incrementAndGet();
        return String.valueOf(seq);
    }
}
