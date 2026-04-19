package com.bwvr.backend.dto.response;

public class DashboardStatsResponse {

    private long totalReports;
    private long reportsThisMonth;
    private long activeTemplates;
    private long distinctBanks;
    private long draftReports;
    private long completedReports;

    public DashboardStatsResponse() {
    }

    private DashboardStatsResponse(Builder b) {
        this.totalReports = b.totalReports;
        this.reportsThisMonth = b.reportsThisMonth;
        this.activeTemplates = b.activeTemplates;
        this.distinctBanks = b.distinctBanks;
        this.draftReports = b.draftReports;
        this.completedReports = b.completedReports;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {

        private long totalReports;
        private long reportsThisMonth;
        private long activeTemplates;
        private long distinctBanks;
        private long draftReports;
        private long completedReports;

        public Builder totalReports(long v) {
            this.totalReports = v;
            return this;
        }

        public Builder reportsThisMonth(long v) {
            this.reportsThisMonth = v;
            return this;
        }

        public Builder activeTemplates(long v) {
            this.activeTemplates = v;
            return this;
        }

        public Builder distinctBanks(long v) {
            this.distinctBanks = v;
            return this;
        }

        public Builder draftReports(long v) {
            this.draftReports = v;
            return this;
        }

        public Builder completedReports(long v) {
            this.completedReports = v;
            return this;
        }

        public DashboardStatsResponse build() {
            return new DashboardStatsResponse(this);
        }
    }

    public long getTotalReports() {
        return totalReports;
    }

    public void setTotalReports(long totalReports) {
        this.totalReports = totalReports;
    }

    public long getReportsThisMonth() {
        return reportsThisMonth;
    }

    public void setReportsThisMonth(long reportsThisMonth) {
        this.reportsThisMonth = reportsThisMonth;
    }

    public long getActiveTemplates() {
        return activeTemplates;
    }

    public void setActiveTemplates(long activeTemplates) {
        this.activeTemplates = activeTemplates;
    }

    public long getDistinctBanks() {
        return distinctBanks;
    }

    public void setDistinctBanks(long distinctBanks) {
        this.distinctBanks = distinctBanks;
    }

    public long getDraftReports() {
        return draftReports;
    }

    public void setDraftReports(long draftReports) {
        this.draftReports = draftReports;
    }

    public long getCompletedReports() {
        return completedReports;
    }

    public void setCompletedReports(long completedReports) {
        this.completedReports = completedReports;
    }
}
