package com.bwvr.backend.dto;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

import com.bwvr.backend.dto.response.ApiResponse;

class ApiResponseTest {

    @Test
    void success_withData_setsCorrectFields() {
        ApiResponse<String> resp = ApiResponse.success("hello");
        assertThat(resp.isSuccess()).isTrue();
        assertThat(resp.getData()).isEqualTo("hello");
        assertThat(resp.getError()).isNull();
        assertThat(resp.getCode()).isNull();
    }

    @Test
    void success_withDataAndMessage() {
        ApiResponse<Integer> resp = ApiResponse.success(42, "Done");
        assertThat(resp.getData()).isEqualTo(42);
        assertThat(resp.getMessage()).isEqualTo("Done");
    }

    @Test
    void error_setsCorrectFields() {
        ApiResponse<Void> resp = ApiResponse.error("Something went wrong", "ERR_001");
        assertThat(resp.isSuccess()).isFalse();
        assertThat(resp.getData()).isNull();
        assertThat(resp.getError()).isEqualTo("Something went wrong");
        assertThat(resp.getCode()).isEqualTo("ERR_001");
    }
    @Test
    void error_withPath_setsCorrectFields() {
        ApiResponse<Void> resp = ApiResponse.error("fail", "CODE", "/path", "details");
        assertThat(resp.getPath()).isEqualTo("/path");
        assertThat(resp.getDetails()).isEqualTo("details");
    }
}

