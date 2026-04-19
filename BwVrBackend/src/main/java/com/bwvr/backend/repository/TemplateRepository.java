package com.bwvr.backend.repository;

import com.bwvr.backend.entity.BwvrTemplate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TemplateRepository extends JpaRepository<BwvrTemplate, Long> {

    Page<BwvrTemplate> findByIsActiveAndBankNameContainingIgnoreCase(
        String isActive, String bankName, Pageable pageable);

    Page<BwvrTemplate> findByIsActive(String isActive, Pageable pageable);

    @Query("SELECT DISTINCT t.bankName FROM BwvrTemplate t WHERE t.isActive = 'Y' ORDER BY t.bankName")
    List<String> findDistinctBankNames();

    Optional<BwvrTemplate> findByBankNameAndTemplateName(String bankName, String templateName);

    long countByIsActive(String isActive);

    @Query("SELECT t FROM BwvrTemplate t WHERE t.isActive = 'Y' AND (:bankName IS NULL OR LOWER(t.bankName) LIKE LOWER(CONCAT('%',:bankName,'%')))")
    Page<BwvrTemplate> searchTemplates(@Param("bankName") String bankName, Pageable pageable);
}
