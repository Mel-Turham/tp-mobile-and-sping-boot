package com.techconnect.backend.service;

import com.techconnect.backend.dto.AuthDTOs.*;
import com.techconnect.backend.entity.Technician;
import com.techconnect.backend.entity.User;
import com.techconnect.backend.exception.UserAlreadyExistsException;
import com.techconnect.backend.repository.TechnicianRepository;
import com.techconnect.backend.repository.UserRepository;
import com.techconnect.backend.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

  private final UserRepository userRepository;
  private final TechnicianRepository technicianRepository;
  private final PasswordEncoder passwordEncoder;
  private final AuthenticationManager authenticationManager;
  private final JwtTokenProvider tokenProvider;

  @Transactional
  public AuthResponse registerUser(RegisterUserRequest request) {
    if (
      userRepository.existsByEmail(request.getEmail()) ||
      technicianRepository.existsByEmail(request.getEmail())
    ) {
      throw new UserAlreadyExistsException(
        "Email already registered: " + request.getEmail()
      );
    }

    User user = User.builder()
      .name(request.getName())
      .email(request.getEmail())
      .password(passwordEncoder.encode(request.getPassword()))
      .role(User.Role.USER)
      .build();

    User savedUser = userRepository.save(user);

    String token = tokenProvider.generateTokenFromEmail(
      savedUser.getEmail(),
      "ROLE_" + savedUser.getRole().name(),
      savedUser.getId()
    );

    return AuthResponse.builder()
      .token(token)
      .email(savedUser.getEmail())
      .role(savedUser.getRole().name())
      .userId(savedUser.getId())
      .build();
  }

  @Transactional
  public AuthResponse registerTechnician(RegisterTechnicianRequest request) {
    if (
      userRepository.existsByEmail(request.getEmail()) ||
      technicianRepository.existsByEmail(request.getEmail())
    ) {
      throw new UserAlreadyExistsException(
        "Email already registered: " + request.getEmail()
      );
    }

    Technician technician = Technician.builder()
      .name(request.getName())
      .email(request.getEmail())
      .password(passwordEncoder.encode(request.getPassword()))
      .phone(request.getPhone())
      .domain(request.getDomain())
      .city(request.getCity())
      .description(request.getDescription())
      .role(User.Role.TECHNICIAN)
      .rating(0.0)
      .reviewCount(0)
      .build();

    Technician savedTech = technicianRepository.save(technician);

    String token = tokenProvider.generateTokenFromEmail(
      savedTech.getEmail(),
      "ROLE_" + savedTech.getRole().name(),
      savedTech.getId()
    );

    return AuthResponse.builder()
      .token(token)
      .email(savedTech.getEmail())
      .role(savedTech.getRole().name())
      .userId(savedTech.getId())
      .build();
  }

  public AuthResponse authenticate(LoginRequest request) {
    Authentication authentication = authenticationManager.authenticate(
      new UsernamePasswordAuthenticationToken(
        request.getEmail(),
        request.getPassword()
      )
    );

    String token = tokenProvider.generateToken(authentication);

    // Determine if user or technician to get ID
    var principal = authentication.getPrincipal();
    Long userId = null;
    String role = null;

    if (principal instanceof com.techconnect.backend.security.UserDetailsImpl) {
      var userDetails =
        (com.techconnect.backend.security.UserDetailsImpl) principal;
      userId = userDetails.getId();
      role = userDetails
        .getAuthorities()
        .iterator()
        .next()
        .getAuthority()
        .replace("ROLE_", "");
    }

    return AuthResponse.builder()
      .token(token)
      .email(request.getEmail())
      .role(role)
      .userId(userId)
      .build();
  }
}
