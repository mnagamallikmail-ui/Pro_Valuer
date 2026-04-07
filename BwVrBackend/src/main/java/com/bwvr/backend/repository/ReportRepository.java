package com.bwvr.backend.repository;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.bwvr.backend.entity.BwvrReport;

@Repository
public interface ReportRepository extends JpaRepository<BwvrReport, Long> {

    Optional<BwvrReport> findByReferenceNumberAndIsDeleted(String referenceNumber, String isDeleted);

    @Query("""
        SELECT r FROM BwvrReport r
        WHERE r.isDeleted = 'N'
        AND (:search IS NULL OR
             LOWER(r.reportTitle) LIKE LOWER(CONCAT('%',:search,'%')) OR
             LOWER(r.referenceNumber) LIKE LOWER(CONCAT('%',:search,'%')) OR
             LOWER(r.vendorName) LIKE LOWER(CONCAT('%',:search,'%')) OR
             LOWER(r.location) LIKE LOWER(CONCAT('%',:search,'%')))
        AND (:vendorName IS NULL OR LOWER(r.vendorName) LIKE LOWER(CONCAT('%',:vendorName,'%')))
        AND (:location IS NULL OR LOWER(r.location) LIKE LOWER(CONCAT('%',:location,'%')))
        AND (:bankName IS NULL OR LOWER(r.bankName) LIKE LOWER(CONCAT('%',:bankName,'%')))
        AND (:status IS NULL OR r.reportStatus = :status)
        ORDER BY r.createdAt DESC
        """)
    Page<BwvrReport> searchReports(
            @Param("search") String search,
            @Param("vendorName") String vendorName,
            @Param("location") String location,
            @Param("bankName") String bankName,
            @Param("status") String status,
            Pageable pageable
    );

    @Query("""
        SELECT r FROM BwvrReport r
        WHERE r.isDeleted = 'N'
        AND (:createdBy IS NULL OR r.createdBy = :createdBy)
        AND (:search IS NULL OR
             LOWER(r.reportTitle) LIKE LOWER(CONCAT('%',:search,'%')) OR
             LOWER(r.referenceNumber) LIKE LOWER(CONCAT('%',:search,'%')) OR
             LOWER(r.vendorName) LIKE LOWER(CONCAT('%',:search,'%')) OR
             LOWER(r.location) LIKE LOWER(CONCAT('%',:search,'%')))
        AND (:vendorName IS NULL OR LOWER(r.vendorName) LIKE LOWER(CONCAT('%',:vendorName,'%')))
        AND (:location IS NULL OR LOWER(r.location) LIKE LOWER(CONCAT('%',:location,'%')))
        AND (:bankName IS NULL OR LOWER(r.bankName) LIKE LOWER(CONCAT('%',:bankName,'%')))
        AND (:status IS NULL OR r.reportStatus = :status)
        ORDER BY r.createdAt DESC
        """)
    Page<BwvrReport> searchReportsFiltered(
            @Param("createdBy") String createdBy,
            @Param("search") String search,
            @Param("vendorName") String vendorName,
            @Param("location") String location,
            @Param("bankName") String bankName,
            @Param("status") String status,
            Pageable pageable
    );

    long countByIsDeleted(String isDeleted);

    long countByCreatedByAndIsDeleted(String createdBy, String isDeleted);

    @Query("SELECT COUNT(r) FROM BwvrReport r WHERE r.isDeleted = 'N' AND EXTRACT(MONTH FROM r.createdAt) = :month AND EXTRACT(YEAR FROM r.createdAt) = :year")
    long countByMonthAndYear(@Param("month") int month, @Param("year") int year);

    @Query("SELECT COUNT(r) FROM BwvrReport r WHERE r.createdBy = :createdBy AND r.isDeleted = 'N' AND EXTRACT(MONTH FROM r.createdAt) = :month AND EXTRACT(YEAR FROM r.createdAt) = :year")
    long countByCreatedByAndMonthAndYear(@Param("createdBy") String createdBy, @Param("month") int month, @Param("year") int year);

    @Query("SELECT COUNT(DISTINCT r.bankName) FROM BwvrReport r WHERE r.isDeleted = 'N'")
    long countDistinctBanks();

    long countByTemplate_TemplateIdAndIsDeleted(Long templateId, String isDeleted);
}
