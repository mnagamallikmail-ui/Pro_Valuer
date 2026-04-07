package com.bwvr.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.bwvr.backend.entity.BwvrTemplatePlaceholder;

@Repository
public interface TemplatePlaceholderRepository extends JpaRepository<BwvrTemplatePlaceholder, Long> {

    List<BwvrTemplatePlaceholder> findByTemplate_TemplateIdOrderByDisplayOrder(Long templateId);

    @Query("SELECT p FROM BwvrTemplatePlaceholder p WHERE p.template.templateId = :templateId AND p.isConfirmed = 'Y' ORDER BY p.displayOrder")
    List<BwvrTemplatePlaceholder> findConfirmedByTemplateId(@Param("templateId") Long templateId);

    void deleteByTemplate_TemplateId(Long templateId);

    java.util.Optional<BwvrTemplatePlaceholder> findByTemplate_TemplateIdAndPlaceholderKey(Long templateId, String placeholderKey);

    long countByTemplate_TemplateId(Long templateId);
}
