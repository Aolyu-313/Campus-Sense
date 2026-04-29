package com.example.campussense.exception;

import com.example.campussense.dto.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import javax.servlet.http.HttpServletRequest;
import javax.validation.ConstraintViolationException;
import java.time.LocalDateTime;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ErrorResponse> handleApiException(ApiException exception, HttpServletRequest request) {
        HttpStatus status = exception.getErrorCode().getStatus();
        return ResponseEntity.status(status)
            .body(new ErrorResponse(LocalDateTime.now(), status.value(), exception.getErrorCode().name(), exception.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException exception, HttpServletRequest request) {
        String message = "Request validation failed";
        FieldError first = exception.getBindingResult().getFieldError();
        if (first != null) {
            message = first.getField() + " " + first.getDefaultMessage();
        }
        return buildBadRequest(message, request);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ErrorResponse> handleConstraintViolation(ConstraintViolationException exception, HttpServletRequest request) {
        return buildBadRequest(exception.getMessage(), request);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleUnreadableMessage(HttpMessageNotReadableException exception, HttpServletRequest request) {
        return buildBadRequest("Malformed JSON request body.", request);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception exception, HttpServletRequest request) {
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        ErrorResponse response = new ErrorResponse(LocalDateTime.now(), status.value(), ErrorCode.INTERNAL_ERROR.name(), exception.getMessage(), request.getRequestURI());
        return ResponseEntity.status(status).body(response);
    }

    private ResponseEntity<ErrorResponse> buildBadRequest(String message, HttpServletRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        ErrorResponse response = new ErrorResponse(LocalDateTime.now(), status.value(), ErrorCode.INVALID_REQUEST.name(), message, request.getRequestURI());
        return ResponseEntity.status(status).body(response);
    }
}
