package com.bwvr.backend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bwvr.backend.entity.BwvrReportImage;

@Repository
public interface ReportImageRepository extends JpaRepository<BwvrReportImage, Long> {

    Optional<BwvrReportImage> findByReportReportIdAndPlaceholderKey(Long reportId, String placeholderKey);

    void deleteByReportReportIdAndPlaceholderKey(Long reportId, String placeholderKey);
}
