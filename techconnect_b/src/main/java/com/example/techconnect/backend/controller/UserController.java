package com.techconnect.backend.controller;

import com.techconnect.backend.dto.AuthDTOs;
import com.techconnect.backend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "Gestion des utilisateurs")
@SecurityRequirement(name = "bearerAuth")
public class UserController {

  private final UserService userService;

  @GetMapping("/me")
  @PreAuthorize("hasAnyRole('USER', 'TECHNICIAN', 'ADMIN')")
  @Operation(summary = "Obtenir le profil de l'utilisateur connecté")
  public ResponseEntity<AuthDTOs.UserProfileResponse> getCurrentUser() {
    return ResponseEntity.ok(userService.getCurrentUser());
  }

  @GetMapping("/{id}")
  @PreAuthorize("hasRole('ADMIN')")
  @Operation(
    summary = "Obtenir un profil utilisateur par ID (Admin uniquement)"
  )
  public ResponseEntity<AuthDTOs.UserProfileResponse> getUserById(
    @PathVariable Long id
  ) {
    return ResponseEntity.ok(userService.getUserProfile(id));
  }
}
