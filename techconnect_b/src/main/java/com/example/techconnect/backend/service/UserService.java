package com.techconnect.backend.service;

import com.techconnect.backend.dto.AuthDTOs.UserProfileResponse;
import com.techconnect.backend.entity.Technician;
import com.techconnect.backend.entity.User;
import com.techconnect.backend.exception.ResourceNotFoundException;
import com.techconnect.backend.repository.TechnicianRepository;
import com.techconnect.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

  private final UserRepository userRepository;
  private final TechnicianRepository technicianRepository;

  public UserProfileResponse getCurrentUser() {
    Authentication authentication =
      SecurityContextHolder.getContext().getAuthentication();
    String email = authentication.getName();

    // 1. Chercher dans users
    User user = userRepository.findByEmail(email).orElse(null);
    if (user != null) {
      return UserProfileResponse.builder()
        .id(user.getId())
        .name(user.getName())
        .email(user.getEmail())
        .role(user.getRole().name())
        .createdAt(user.getCreatedAt())
        .build();
    }

    // 2. Sinon chercher dans technicians
    Technician technician = technicianRepository
      .findByEmail(email)
      .orElseThrow(() ->
        new ResourceNotFoundException("User not found with email: " + email)
      );

    return UserProfileResponse.builder()
      .id(technician.getId())
      .name(technician.getName())
      .email(technician.getEmail())
      .role(technician.getRole().name())
      .createdAt(technician.getCreatedAt())
      .build();
  }

  public UserProfileResponse getUserProfile(Long id) {
    User user = userRepository
      .findById(id)
      .orElseThrow(() ->
        new ResourceNotFoundException("User not found with id: " + id)
      );

    return UserProfileResponse.builder()
      .id(user.getId())
      .name(user.getName())
      .email(user.getEmail())
      .role(user.getRole().name())
      .createdAt(user.getCreatedAt())
      .build();
  }
}
