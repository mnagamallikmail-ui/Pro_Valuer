package com.bwvr.backend.exception;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import com.bwvr.backend.dto.response.ApiResponse;

@SuppressWarnings("null")
class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void handleConflict_returns409() {
        ResponseEntity<ApiResponse<Void>> resp
                = handler.handleConflict(new ConflictException("duplicate name"));
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(resp.getBody()).isNotNull();
        assertThat(resp.getBody().getError()).contains("duplicate name");
    }

    @Test
    void handleNotFound_returns404() {
        ResponseEntity<ApiResponse<Void>> resp
                = handler.handleNotFound(new ResourceNotFoundException("Report", 1L));
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(resp.getBody()).isNotNull();
        assertThat(resp.getBody().getCode()).isEqualTo("RESOURCE_NOT_FOUND");
    }

    @Test
    void handleTemplateParseError_returns422() {
        ResponseEntity<ApiResponse<Void>> resp
                = handler.handleTemplateParseError(new TemplateParseException("bad docx", null));
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.UNPROCESSABLE_ENTITY);
        assertThat(resp.getBody()).isNotNull();
        assertThat(resp.getBody().getCode()).isEqualTo("TEMPLATE_PARSE_ERROR");
    }

    @Test
    void handleValidation_returns400_withFieldErrors() {
        MethodArgumentNotValidException ex = mock(MethodArgumentNotValidException.class);
        BindingResult br = mock(BindingResult.class);
        when(ex.getBindingResult()).thenReturn(br);
        when(br.getFieldErrors()).thenReturn(
                List.of(new FieldError("obj", "reportTitle", "must not be blank")));

        ResponseEntity<ApiResponse<Void>> resp = handler.handleValidation(ex);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(resp.getBody()).isNotNull();
        assertThat(resp.getBody().getError()).contains("reportTitle");
        assertThat(resp.getBody().getCode()).isEqualTo("VALIDATION_ERROR");
    }

    @Test
    void handleFileSizeExceeded_returns413() {
        ResponseEntity<ApiResponse<Void>> resp
                = handler.handleFileSizeExceeded(new MaxUploadSizeExceededException(1024));
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.PAYLOAD_TOO_LARGE);
        assertThat(resp.getBody()).isNotNull();
        assertThat(resp.getBody().getCode()).isEqualTo("FILE_TOO_LARGE");
    }

    @Test
    void handleIllegalArg_returns400() {
        ResponseEntity<ApiResponse<Void>> resp
                = handler.handleIllegalArg(new IllegalArgumentException("Only .docx allowed"));
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(resp.getBody()).isNotNull();
        assertThat(resp.getBody().getError()).contains("Only .docx");
    }

    @Test
    void handleNoResource_returns404_noBody() throws Exception {
        ResponseEntity<Void> resp
                = handler.handleNoResource(new NoResourceFoundException(HttpMethod.GET, "/favicon.ico"));
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(resp.getBody()).isNull();
    }

    @Test
    void handleGeneral_returns500() {
        ResponseEntity<ApiResponse<Void>> resp
                = handler.handleGeneral(new RuntimeException("boom"));
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(resp.getBody()).isNotNull();
        assertThat(resp.getBody().getCode()).isEqualTo("INTERNAL_ERROR");
    }
}
