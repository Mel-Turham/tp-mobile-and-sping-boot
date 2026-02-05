package com.techconnect.backend.controller;

import com.techconnect.backend.dto.AuthDTOs;
import com.techconnect.backend.service.TechnicianService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/technicians")
@RequiredArgsConstructor
@Tag(name = "Technicians", description = "Gestion des techniciens")
public class TechnicianController {

  private final TechnicianService technicianService;

  @GetMapping
  @Operation(summary = "Lister tous les techniciens avec pagination")
  public ResponseEntity<Page<AuthDTOs.TechnicianResponse>> getAllTechnicians(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size,
    @RequestParam(defaultValue = "createdAt") String sortBy,
    @RequestParam(defaultValue = "desc") String direction
  ) {
    Sort.Direction dir = direction.equalsIgnoreCase("desc")
      ? Sort.Direction.DESC
      : Sort.Direction.ASC;
    Pageable pageable = PageRequest.of(page, size, Sort.by(dir, sortBy));

    return ResponseEntity.ok(technicianService.getAllTechnicians(pageable));
  }

  @GetMapping("/search")
  @Operation(summary = "Rechercher des techniciens par domaine et ville")
  public ResponseEntity<Page<AuthDTOs.TechnicianResponse>> searchTechnicians(
    @Parameter(
      description = "Domaine (Electricity, Plumbing, IT...)"
    ) @RequestParam(required = false) String domain,
    @Parameter(description = "Ville") @RequestParam(
      required = false
    ) String city,
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size
  ) {
    Pageable pageable = PageRequest.of(page, size);
    return ResponseEntity.ok(
      technicianService.searchTechnicians(domain, city, pageable)
    );
  }

  @GetMapping("/{id}")
  @Operation(summary = "Obtenir les détails d'un technicien")
  public ResponseEntity<AuthDTOs.TechnicianResponse> getTechnicianById(
    @PathVariable Long id
  ) {
    return ResponseEntity.ok(technicianService.getTechnicianById(id));
  }
}
