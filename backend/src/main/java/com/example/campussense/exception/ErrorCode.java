package com.example.campussense.exception;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
    INVALID_REQUEST(HttpStatus.BAD_REQUEST),
    INVALID_LOCATION(HttpStatus.BAD_REQUEST),
    PROFILE_NOT_FOUND(HttpStatus.NOT_FOUND),
    REPORT_NOT_FOUND(HttpStatus.NOT_FOUND),
    EXTERNAL_API_FAILED(HttpStatus.BAD_GATEWAY),
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR);

    private final HttpStatus status;

    ErrorCode(HttpStatus status) {
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
