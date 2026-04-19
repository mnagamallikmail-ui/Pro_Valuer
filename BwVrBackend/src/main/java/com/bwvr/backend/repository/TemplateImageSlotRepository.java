package com.bwvr.backend.repository;

import com.bwvr.backend.entity.BwvrTemplateImageSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TemplateImageSlotRepository extends JpaRepository<BwvrTemplateImageSlot, Long> {

    List<BwvrTemplateImageSlot> findByTemplate_TemplateId(Long templateId);

    Optional<BwvrTemplateImageSlot> findByTemplate_TemplateIdAndPlaceholderKey(Long templateId, String placeholderKey);
}
