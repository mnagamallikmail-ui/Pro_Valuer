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

    @Query(value = """
        SELECT r.* FROM bwvr.bwvr_report r
        WHERE r.is_deleted = 'N'
        AND (:search IS NULL OR
             LOWER(r.report_title) LIKE LOWER('%' || :search || '%') OR
             LOWER(r.reference_number) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :search || '%'))
        AND (:vendorName IS NULL OR LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :vendorName || '%'))
        AND (:location IS NULL OR LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :location || '%'))
        AND (:bankName IS NULL OR LOWER(COALESCE(r.bank_name,'')) LIKE LOWER('%' || :bankName || '%'))
        AND (:status IS NULL OR r.report_status = :status)
        ORDER BY r.created_at DESC
        """, countQuery = """
        SELECT COUNT(*) FROM bwvr.bwvr_report r
        WHERE r.is_deleted = 'N'
        AND (:search IS NULL OR
             LOWER(r.report_title) LIKE LOWER('%' || :search || '%') OR
             LOWER(r.reference_number) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :search || '%'))
        AND (:vendorName IS NULL OR LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :vendorName || '%'))
        AND (:location IS NULL OR LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :location || '%'))
        AND (:bankName IS NULL OR LOWER(COALESCE(r.bank_name,'')) LIKE LOWER('%' || :bankName || '%'))
        AND (:status IS NULL OR r.report_status = :status)
        """, nativeQuery = true)
    Page<BwvrReport> searchReports(
            @Param("search") String search,
            @Param("vendorName") String vendorName,
            @Param("location") String location,
            @Param("bankName") String bankName,
            @Param("status") String status,
            Pageable pageable
    );

    @Query(value = """
        SELECT r.* FROM bwvr.bwvr_report r
        WHERE r.is_deleted = 'N'
        AND (:createdBy IS NULL OR r.created_by = :createdBy)
        AND (:search IS NULL OR
             LOWER(r.report_title) LIKE LOWER('%' || :search || '%') OR
             LOWER(r.reference_number) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :search || '%'))
        AND (:vendorName IS NULL OR LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :vendorName || '%'))
        AND (:location IS NULL OR LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :location || '%'))
        AND (:bankName IS NULL OR LOWER(COALESCE(r.bank_name,'')) LIKE LOWER('%' || :bankName || '%'))
        AND (:status IS NULL OR r.report_status = :status)
        ORDER BY r.created_at DESC
        """, countQuery = """
        SELECT COUNT(*) FROM bwvr.bwvr_report r
        WHERE r.is_deleted = 'N'
        AND (:createdBy IS NULL OR r.created_by = :createdBy)
        AND (:search IS NULL OR
             LOWER(r.report_title) LIKE LOWER('%' || :search || '%') OR
             LOWER(r.reference_number) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :search || '%'))
        AND (:vendorName IS NULL OR LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :vendorName || '%'))
        AND (:location IS NULL OR LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :location || '%'))
        AND (:bankName IS NULL OR LOWER(COALESCE(r.bank_name,'')) LIKE LOWER('%' || :bankName || '%'))
        AND (:status IS NULL OR r.report_status = :status)
        """, nativeQuery = true)
    Page<BwvrReport> searchReportsFiltered(
            @Param("createdBy") String createdBy,
            @Param("search") String search,
            @Param("vendorName") String vendorName,
            @Param("location") String location,
            @Param("bankName") String bankName,
            @Param("status") String status,
            Pageable pageable
    );

    @Query(value = """
        SELECT r.* FROM bwvr.bwvr_report r
        WHERE r.is_deleted = 'N'
        AND (r.created_by = :createdBy OR r.validator_username = :validatorUsername)
        AND (:search IS NULL OR
             LOWER(r.report_title) LIKE LOWER('%' || :search || '%') OR
             LOWER(r.reference_number) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :search || '%'))
        AND (:vendorName IS NULL OR LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :vendorName || '%'))
        AND (:location IS NULL OR LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :location || '%'))
        AND (:bankName IS NULL OR LOWER(COALESCE(r.bank_name,'')) LIKE LOWER('%' || :bankName || '%'))
        AND (:status IS NULL OR r.report_status = :status)
        ORDER BY r.created_at DESC
        """, countQuery = """
        SELECT COUNT(*) FROM bwvr.bwvr_report r
        WHERE r.is_deleted = 'N'
        AND (r.created_by = :createdBy OR r.validator_username = :validatorUsername)
        AND (:search IS NULL OR
             LOWER(r.report_title) LIKE LOWER('%' || :search || '%') OR
             LOWER(r.reference_number) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :search || '%') OR
             LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :search || '%'))
        AND (:vendorName IS NULL OR LOWER(COALESCE(r.vendor_name,'')) LIKE LOWER('%' || :vendorName || '%'))
        AND (:location IS NULL OR LOWER(COALESCE(r.location,'')) LIKE LOWER('%' || :location || '%'))
        AND (:bankName IS NULL OR LOWER(COALESCE(r.bank_name,'')) LIKE LOWER('%' || :bankName || '%'))
        AND (:status IS NULL OR r.report_status = :status)
        """, nativeQuery = true)
    Page<BwvrReport> searchReportsFilteredByValidatorOrCreator(
            @Param("createdBy") String createdBy,
            @Param("validatorUsername") String validatorUsername,
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
