package com.bwvr.backend.dto.response;

import java.util.List;

public class ParsedTemplateResponse {

    private Long templateId;
    private String bankName;
    private String templateName;
    private String parsedStatus;
    private List<PlaceholderResponse> placeholders;
    private List<ImageSlotResponse> imageSlots;
    private int totalPlaceholders;
    private int textCount;
    private int dateCount;
    private int imageCount;

    public ParsedTemplateResponse() {
    }

    private ParsedTemplateResponse(Builder b) {
        this.templateId = b.templateId;
        this.bankName = b.bankName;
        this.templateName = b.templateName;
        this.parsedStatus = b.parsedStatus;
        this.placeholders = b.placeholders;
        this.imageSlots = b.imageSlots;
        this.totalPlaceholders = b.totalPlaceholders;
        this.textCount = b.textCount;
        this.dateCount = b.dateCount;
        this.imageCount = b.imageCount;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private Long templateId;
        private String bankName;
        private String templateName;
        private String parsedStatus;
        private List<PlaceholderResponse> placeholders;
        private List<ImageSlotResponse> imageSlots;
        private int totalPlaceholders;
        private int textCount;
        private int dateCount;
        private int imageCount;

        public Builder templateId(Long v) {
            this.templateId = v;
            return this;
        }

        public Builder bankName(String v) {
            this.bankName = v;
            return this;
        }

        public Builder templateName(String v) {
            this.templateName = v;
            return this;
        }

        public Builder parsedStatus(String v) {
            this.parsedStatus = v;
            return this;
        }

        public Builder placeholders(List<PlaceholderResponse> v) {
            this.placeholders = v;
            return this;
        }

        public Builder imageSlots(List<ImageSlotResponse> v) {
            this.imageSlots = v;
            return this;
        }

        public Builder totalPlaceholders(int v) {
            this.totalPlaceholders = v;
            return this;
        }

        public Builder textCount(int v) {
            this.textCount = v;
            return this;
        }

        public Builder dateCount(int v) {
            this.dateCount = v;
            return this;
        }

        public Builder imageCount(int v) {
            this.imageCount = v;
            return this;
        }

        public ParsedTemplateResponse build() {
            return new ParsedTemplateResponse(this);
        }
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getTemplateName() {
        return templateName;
    }

    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }

    public String getParsedStatus() {
        return parsedStatus;
    }

    public void setParsedStatus(String parsedStatus) {
        this.parsedStatus = parsedStatus;
    }

    public List<PlaceholderResponse> getPlaceholders() {
        return placeholders;
    }

    public void setPlaceholders(List<PlaceholderResponse> placeholders) {
        this.placeholders = placeholders;
    }

    public List<ImageSlotResponse> getImageSlots() {
        return imageSlots;
    }

    public void setImageSlots(List<ImageSlotResponse> imageSlots) {
        this.imageSlots = imageSlots;
    }

    public int getTotalPlaceholders() {
        return totalPlaceholders;
    }

    public void setTotalPlaceholders(int totalPlaceholders) {
        this.totalPlaceholders = totalPlaceholders;
    }

    public int getTextCount() {
        return textCount;
    }

    public void setTextCount(int textCount) {
        this.textCount = textCount;
    }

    public int getDateCount() {
        return dateCount;
    }

    public void setDateCount(int dateCount) {
        this.dateCount = dateCount;
    }

    public int getImageCount() {
        return imageCount;
    }

    public void setImageCount(int imageCount) {
        this.imageCount = imageCount;
    }

    public static class ImageSlotResponse {

        private Long imageSlotId;
        private String placeholderKey;
        private Long widthEmu;
        private Long heightEmu;
        private Double widthInches;
        private Double heightInches;
        private Integer widthPixels;
        private Integer heightPixels;
        private String pagePosition;

        public ImageSlotResponse() {
        }

        private ImageSlotResponse(Builder b) {
            this.imageSlotId = b.imageSlotId;
            this.placeholderKey = b.placeholderKey;
            this.widthEmu = b.widthEmu;
            this.heightEmu = b.heightEmu;
            this.widthInches = b.widthInches;
            this.heightInches = b.heightInches;
            this.widthPixels = b.widthPixels;
            this.heightPixels = b.heightPixels;
            this.pagePosition = b.pagePosition;
        }

        public static Builder builder() {
            return new Builder();
        }

        public static class Builder {

            private Long imageSlotId;
            private String placeholderKey;
            private Long widthEmu;
            private Long heightEmu;
            private Double widthInches;
            private Double heightInches;
            private Integer widthPixels;
            private Integer heightPixels;
            private String pagePosition;

            public Builder imageSlotId(Long v) {
                this.imageSlotId = v;
                return this;
            }

            public Builder placeholderKey(String v) {
                this.placeholderKey = v;
                return this;
            }

            public Builder widthEmu(Long v) {
                this.widthEmu = v;
                return this;
            }

            public Builder heightEmu(Long v) {
                this.heightEmu = v;
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

            public Builder widthPixels(Integer v) {
                this.widthPixels = v;
                return this;
            }

            public Builder heightPixels(Integer v) {
                this.heightPixels = v;
                return this;
            }

            public Builder pagePosition(String v) {
                this.pagePosition = v;
                return this;
            }

            public ImageSlotResponse build() {
                return new ImageSlotResponse(this);
            }
        }

        public Long getImageSlotId() {
            return imageSlotId;
        }

        public void setImageSlotId(Long imageSlotId) {
            this.imageSlotId = imageSlotId;
        }

        public String getPlaceholderKey() {
            return placeholderKey;
        }

        public void setPlaceholderKey(String placeholderKey) {
            this.placeholderKey = placeholderKey;
        }

        public Long getWidthEmu() {
            return widthEmu;
        }

        public void setWidthEmu(Long widthEmu) {
            this.widthEmu = widthEmu;
        }

        public Long getHeightEmu() {
            return heightEmu;
        }

        public void setHeightEmu(Long heightEmu) {
            this.heightEmu = heightEmu;
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

        public String getPagePosition() {
            return pagePosition;
        }

        public void setPagePosition(String pagePosition) {
            this.pagePosition = pagePosition;
        }
    }
}
