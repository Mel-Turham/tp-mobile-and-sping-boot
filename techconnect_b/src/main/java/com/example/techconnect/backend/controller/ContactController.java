package com.techconnect.backend.controller;

import com.techconnect.backend.dto.AuthDTOs;
import com.techconnect.backend.service.EmailService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/contact")
@RequiredArgsConstructor
@Tag(name = "Contact", description = "Envoi d'emails de contact")
@SecurityRequirement(name = "bearerAuth")
public class ContactController {

  private final EmailService emailService;

  @PostMapping("/send")
  @PreAuthorize("hasRole('USER')")
  @Operation(summary = "Envoyer un email de contact à un technicien")
  public ResponseEntity<Map<String, String>> sendContactEmail(
    @Valid @RequestBody AuthDTOs.ContactRequestDTO request,
    Authentication authentication
  ) {
    String userEmail = authentication.getName();
    emailService.sendContactEmail(
      userEmail,
      request.getTechnicianEmail(),
      request.getMessage()
    );

    Map<String, String> response = new HashMap<>();
    response.put("message", "Email sent successfully");
    response.put("technicianEmail", request.getTechnicianEmail());

    return ResponseEntity.ok(response);
  }
}
