package com.bwvr.backend.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
public class ReportCreationException extends RuntimeException {
    public ReportCreationException(String message) {
        super(message);
    }

    public ReportCreationException(String message, Throwable cause) {
        super(message, cause);
    }
}
