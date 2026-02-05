package com.techconnect.backend.exception;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

@RestControllerAdvice
public class GlobalExceptionHandler {

  @ExceptionHandler(DuplicateRatingException.class)
  public ResponseEntity<ErrorResponse> handleDuplicateRatingException(
    DuplicateRatingException ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.CONFLICT.value(),
      ex.getMessage(),
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.CONFLICT);
  }

  @ExceptionHandler(IllegalStateException.class)
  public ResponseEntity<ErrorResponse> handleIllegalStateException(
    IllegalStateException ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.BAD_REQUEST.value(),
      ex.getMessage(),
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
  }

  @ExceptionHandler(UnauthorizedException.class)
  public ResponseEntity<ErrorResponse> handleUnauthorizedException(
    UnauthorizedException ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.FORBIDDEN.value(),
      ex.getMessage(),
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.FORBIDDEN);
  }

  @ExceptionHandler(ResourceNotFoundException.class)
  public ResponseEntity<ErrorResponse> handleResourceNotFoundException(
    ResourceNotFoundException ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.NOT_FOUND.value(),
      ex.getMessage(),
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
  }

  @ExceptionHandler(UserAlreadyExistsException.class)
  public ResponseEntity<ErrorResponse> handleUserAlreadyExistsException(
    UserAlreadyExistsException ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.CONFLICT.value(),
      ex.getMessage(),
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.CONFLICT);
  }

  @ExceptionHandler(BadCredentialsException.class)
  public ResponseEntity<ErrorResponse> handleBadCredentialsException(
    BadCredentialsException ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.UNAUTHORIZED.value(),
      "Invalid email or password",
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.UNAUTHORIZED);
  }

  @ExceptionHandler(AccessDeniedException.class)
  public ResponseEntity<ErrorResponse> handleAccessDeniedException(
    AccessDeniedException ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.FORBIDDEN.value(),
      "Access denied: insufficient permissions",
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.FORBIDDEN);
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<Map<String, Object>> handleValidationExceptions(
    MethodArgumentNotValidException ex
  ) {
    Map<String, String> errors = new HashMap<>();
    ex
      .getBindingResult()
      .getAllErrors()
      .forEach(error -> {
        String fieldName = ((FieldError) error).getField();
        String errorMessage = error.getDefaultMessage();
        errors.put(fieldName, errorMessage);
      });

    Map<String, Object> response = new HashMap<>();
    response.put("status", HttpStatus.BAD_REQUEST.value());
    response.put("errors", errors);
    response.put("timestamp", LocalDateTime.now());

    return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ErrorResponse> handleGlobalException(
    Exception ex,
    WebRequest request
  ) {
    ErrorResponse error = new ErrorResponse(
      HttpStatus.INTERNAL_SERVER_ERROR.value(),
      "An unexpected error occurred",
      request.getDescription(false),
      LocalDateTime.now()
    );
    return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
  }

  public record ErrorResponse(
    int status,
    String message,
    String path,
    LocalDateTime timestamp
  ) {}
}
