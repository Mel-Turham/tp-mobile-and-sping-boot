// Auth DTOs
package com.techconnect.backend.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;
import lombok.*;

public class AuthDTOs {

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class RegisterUserRequest {

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class RegisterTechnicianRequest {

    @NotBlank
    private String name;

    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Size(min = 6)
    private String password;

    @NotBlank
    private String phone;

    @NotBlank
    private String domain;

    @NotBlank
    private String city;

    private String description;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class LoginRequest {

    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class AuthResponse {

    private String token;
    private String type = "Bearer";
    private String email;
    private String role;
    private Long userId;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class TechnicianResponse {

    private Long id;
    private String name;
    private String email;
    private String phone;
    private String domain;
    private String city;
    private String description;
    private String profileImageUrl;
    private Double rating;
    private Integer reviewCount;
    private LocalDateTime createdAt;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class ContactRequestDTO {

    @NotBlank
    @Email
    private String technicianEmail;

    @NotBlank
    @Size(max = 2000)
    private String message;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class UserProfileResponse {

    private Long id;
    private String name;
    private String email;
    private String role;
    private LocalDateTime createdAt;
  }

  // Rating DTOs

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class RatingRequest {

    @NotNull(message = "Technician ID is required")
    private Long technicianId;

    @NotNull(message = "Score is required")
    @Min(value = 1, message = "Score must be at least 1")
    @Max(value = 5, message = "Score must be at most 5")
    private Integer score;

    @Size(max = 1000, message = "Comment must not exceed 1000 characters")
    private String comment;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class RatingUpdateRequest {

    @NotNull(message = "Score is required")
    @Min(value = 1, message = "Score must be at least 1")
    @Max(value = 5, message = "Score must be at most 5")
    private Integer score;

    @Size(max = 1000, message = "Comment must not exceed 1000 characters")
    private String comment;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class RatingResponse {

    private Long id;
    private Long userId;
    private String userName;
    private Long technicianId;
    private String technicianName;
    private Integer score;
    private String comment;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
  }

  @Data
  @Builder
  @NoArgsConstructor
  @AllArgsConstructor
  public static class TechnicianRatingStats {

    private Long technicianId;
    private String technicianName;
    private Double averageRating;
    private Long totalReviews;
    private Long fiveStarCount;
    private Long fourStarCount;
    private Long threeStarCount;
    private Long twoStarCount;
    private Long oneStarCount;
  }
}
