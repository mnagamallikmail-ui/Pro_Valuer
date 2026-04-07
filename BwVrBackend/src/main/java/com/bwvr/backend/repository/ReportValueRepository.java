package com.bwvr.backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bwvr.backend.entity.BwvrReportValue;

@Repository
public interface ReportValueRepository extends JpaRepository<BwvrReportValue, Long> {

    List<BwvrReportValue> findByReport_ReportId(Long reportId);

    Optional<BwvrReportValue> findByReport_ReportIdAndPlaceholder_PlaceholderId(Long reportId, Long placeholderId);

    Optional<BwvrReportValue> findByReport_ReportIdAndPlaceholderKey(Long reportId, String placeholderKey);

    void deleteByReport_ReportId(Long reportId);

    long countByReport_ReportId(Long reportId);
}
