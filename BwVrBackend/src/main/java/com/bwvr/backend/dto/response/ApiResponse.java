package com.bwvr.backend.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private boolean success;
    private String message;
    private T data;
    private String error;
    private String code;
    private String timestamp;
    private String path;
    private String details;

    public ApiResponse() {
    }

    public ApiResponse(boolean success, String message, T data, String error, String code) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.error = error;
        this.code = code;
    }

    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> r = new ApiResponse<>();
        r.success = true;
        r.data = data;
        return r;
    }

    public static <T> ApiResponse<T> success(T data, String message) {
        ApiResponse<T> r = new ApiResponse<>();
        r.success = true;
        r.data = data;
        r.message = message;
        return r;
    }

    public static <T> ApiResponse<T> error(String error, String code) {
        ApiResponse<T> r = new ApiResponse<>();
        r.success = false;
        r.error = error;
        r.code = code;
        r.timestamp = java.time.Instant.now().toString();
        return r;
    }

    public static <T> ApiResponse<T> error(String error, String code, String path, String details) {
        ApiResponse<T> r = new ApiResponse<>();
        r.success = false;
        r.error = error;
        r.code = code;
        r.timestamp = java.time.Instant.now().toString();
        r.path = path;
        r.details = details;
        return r;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }
}
