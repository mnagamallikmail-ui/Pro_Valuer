package com.bwvr.backend.service;

import java.io.IOException;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.bwvr.backend.entity.BwvrReport;
import com.bwvr.backend.entity.BwvrReportImage;
import com.bwvr.backend.repository.ReportImageRepository;
import com.bwvr.backend.repository.ReportRepository;

@Service
public class ReportImageService {

    private final ReportImageRepository reportImageRepository;
    private final ReportRepository reportRepository;
    private final com.bwvr.backend.repository.ReportValueRepository reportValueRepository;

    public ReportImageService(ReportImageRepository reportImageRepository,
            ReportRepository reportRepository,
            com.bwvr.backend.repository.ReportValueRepository reportValueRepository) {
        this.reportImageRepository = reportImageRepository;
        this.reportRepository = reportRepository;
        this.reportValueRepository = reportValueRepository;
    }

    @Transactional
    public com.bwvr.backend.entity.BwvrReportImage saveImage(Long reportId, String placeholderKey, MultipartFile file) throws IOException {
        BwvrReport report = reportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found"));

        byte[] bytes = file.getBytes();

        // 1. Update/Create BLOB in ReportValue (Synchronized storage for Generator)
        reportValueRepository.findByReport_ReportIdAndPlaceholderKey(reportId, placeholderKey)
                .ifPresent(val -> {
                    val.setImageData(bytes);
                    val.setImageOriginalName(file.getOriginalFilename());
                    // Clear filesystem path to signal BLOB usage
                    val.setImageFilePath(null);
                    reportValueRepository.save(val);
                });

        // 2. Update/Create dedicated Image record (Legacy/Metadata storage)
        reportImageRepository.deleteByReportReportIdAndPlaceholderKey(reportId, placeholderKey);

        com.bwvr.backend.entity.BwvrReportImage image = new com.bwvr.backend.entity.BwvrReportImage();
        image.setReport(report);
        image.setPlaceholderKey(placeholderKey);
        image.setFileName(file.getOriginalFilename());
        image.setContentType(file.getContentType());
        image.setImageData(bytes);

        return reportImageRepository.save(image);
    }

    public BwvrReportImage getImage(Long reportId, String placeholderKey) {
        return reportImageRepository.findByReportReportIdAndPlaceholderKey(reportId, placeholderKey)
                .orElseThrow(() -> new RuntimeException("Image not found"));
    }
}
