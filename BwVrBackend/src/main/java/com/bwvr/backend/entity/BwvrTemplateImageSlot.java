package com.bwvr.backend.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "BWVR_TEMPLATE_IMAGE_SLOT", schema = "bwvr")
public class BwvrTemplateImageSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "IMAGE_SLOT_ID")
    private Long imageSlotId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "TEMPLATE_ID", nullable = false)
    private BwvrTemplate template;

    @Column(name = "PLACEHOLDER_KEY", nullable = false, length = 300)
    private String placeholderKey;

    @Column(name = "ORIGINAL_WIDTH_EMU")
    private Long originalWidthEmu;

    @Column(name = "ORIGINAL_HEIGHT_EMU")
    private Long originalHeightEmu;

    @Column(name = "WIDTH_PIXELS")
    private Integer widthPixels;

    @Column(name = "HEIGHT_PIXELS")
    private Integer heightPixels;

    @Column(name = "WIDTH_INCHES")
    private Double widthInches;

    @Column(name = "HEIGHT_INCHES")
    private Double heightInches;

    @Column(name = "PAGE_POSITION", length = 100)
    private String pagePosition;

    @CreationTimestamp
    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    public BwvrTemplateImageSlot() {
    }

    private BwvrTemplateImageSlot(Builder b) {
        this.imageSlotId = b.imageSlotId;
        this.template = b.template;
        this.placeholderKey = b.placeholderKey;
        this.originalWidthEmu = b.originalWidthEmu;
        this.originalHeightEmu = b.originalHeightEmu;
        this.widthPixels = b.widthPixels;
        this.heightPixels = b.heightPixels;
        this.widthInches = b.widthInches;
        this.heightInches = b.heightInches;
        this.pagePosition = b.pagePosition;
        this.createdAt = b.createdAt;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long imageSlotId;
        private BwvrTemplate template;
        private String placeholderKey;
        private Long originalWidthEmu;
        private Long originalHeightEmu;
        private Integer widthPixels;
        private Integer heightPixels;
        private Double widthInches;
        private Double heightInches;
        private String pagePosition;
        private LocalDateTime createdAt;

        public Builder imageSlotId(Long v) {
            this.imageSlotId = v;
            return this;
        }

        public Builder template(BwvrTemplate v) {
            this.template = v;
            return this;
        }

        public Builder placeholderKey(String v) {
            this.placeholderKey = v;
            return this;
        }

        public Builder originalWidthEmu(Long v) {
            this.originalWidthEmu = v;
            return this;
        }

        public Builder originalHeightEmu(Long v) {
            this.originalHeightEmu = v;
            return this;
        }

        public Builder widthPixels(Integer v) {
            this.widthPixels = v;
            return this;
        }

        public Builder heightPixels(Integer v) {
            this.heightPixels = v;
            return this;
        }

        public Builder widthInches(Double v) {
            this.widthInches = v;
            return this;
        }

        public Builder heightInches(Double v) {
            this.heightInches = v;
            return this;
        }

        public Builder pagePosition(String v) {
            this.pagePosition = v;
            return this;
        }

        public Builder createdAt(LocalDateTime v) {
            this.createdAt = v;
            return this;
        }

        public BwvrTemplateImageSlot build() {
            return new BwvrTemplateImageSlot(this);
        }
    }

    public Long getImageSlotId() {
        return imageSlotId;
    }

    public void setImageSlotId(Long imageSlotId) {
        this.imageSlotId = imageSlotId;
    }

    public BwvrTemplate getTemplate() {
        return template;
    }

    public void setTemplate(BwvrTemplate template) {
        this.template = template;
    }

    public String getPlaceholderKey() {
        return placeholderKey;
    }

    public void setPlaceholderKey(String placeholderKey) {
        this.placeholderKey = placeholderKey;
    }

    public Long getOriginalWidthEmu() {
        return originalWidthEmu;
    }

    public void setOriginalWidthEmu(Long originalWidthEmu) {
        this.originalWidthEmu = originalWidthEmu;
    }

    public Long getOriginalHeightEmu() {
        return originalHeightEmu;
    }

    public void setOriginalHeightEmu(Long originalHeightEmu) {
        this.originalHeightEmu = originalHeightEmu;
    }

    public Integer getWidthPixels() {
        return widthPixels;
    }

    public void setWidthPixels(Integer widthPixels) {
        this.widthPixels = widthPixels;
    }

    public Integer getHeightPixels() {
        return heightPixels;
    }

    public void setHeightPixels(Integer heightPixels) {
        this.heightPixels = heightPixels;
    }

    public Double getWidthInches() {
        return widthInches;
    }

    public void setWidthInches(Double widthInches) {
        this.widthInches = widthInches;
    }

    public Double getHeightInches() {
        return heightInches;
    }

    public void setHeightInches(Double heightInches) {
        this.heightInches = heightInches;
    }

    public String getPagePosition() {
        return pagePosition;
    }

    public void setPagePosition(String pagePosition) {
        this.pagePosition = pagePosition;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
