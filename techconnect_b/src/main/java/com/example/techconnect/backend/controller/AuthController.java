package com.techconnect.backend.controller;

import com.techconnect.backend.dto.AuthDTOs;
import com.techconnect.backend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Endpoints pour l'authentification")
public class AuthController {

  private final AuthService authService;

  @PostMapping("/register/user")
  @Operation(summary = "Inscrire un utilisateur lambda")
  public ResponseEntity<AuthDTOs.AuthResponse> registerUser(
    @Valid @RequestBody AuthDTOs.RegisterUserRequest request
  ) {
    return ResponseEntity.ok(authService.registerUser(request));
  }

  @PostMapping("/register/technician")
  @Operation(summary = "Inscrire un technicien")
  public ResponseEntity<AuthDTOs.AuthResponse> registerTechnician(
    @Valid @RequestBody AuthDTOs.RegisterTechnicianRequest request
  ) {
    return ResponseEntity.ok(authService.registerTechnician(request));
  }

  @PostMapping("/login")
  @Operation(summary = "Connexion utilisateur/technicien")
  public ResponseEntity<AuthDTOs.AuthResponse> login(
    @Valid @RequestBody AuthDTOs.LoginRequest request
  ) {
    return ResponseEntity.ok(authService.authenticate(request));
  }
}
