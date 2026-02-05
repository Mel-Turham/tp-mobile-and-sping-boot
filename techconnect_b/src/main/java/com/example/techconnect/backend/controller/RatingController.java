package com.techconnect.backend.controller;

import com.techconnect.backend.dto.AuthDTOs.RatingRequest;
import com.techconnect.backend.dto.AuthDTOs.RatingResponse;
import com.techconnect.backend.dto.AuthDTOs.RatingUpdateRequest;
import com.techconnect.backend.dto.AuthDTOs.TechnicianRatingStats;
import com.techconnect.backend.security.UserDetailsImpl;
import com.techconnect.backend.service.RatingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/ratings")
@RequiredArgsConstructor
@Tag(name = "Ratings", description = "Gestion des évaluations des techniciens")
public class RatingController {

    private final RatingService ratingService;

    @PostMapping
    @Operation(summary = "Créer une évaluation pour un technicien")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Évaluation créée avec succès"),
            @ApiResponse(responseCode = "400", description = "Données invalides ou évaluation déjà existante"),
            @ApiResponse(responseCode = "401", description = "Non authentifié"),
            @ApiResponse(responseCode = "404", description = "Technicien non trouvé")
    })
    public ResponseEntity<RatingResponse> createRating(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @Valid @RequestBody RatingRequest request
    ) {
        RatingResponse response = ratingService.createRating(userDetails.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{ratingId}")
    @Operation(summary = "Mettre à jour une évaluation existante")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Évaluation mise à jour avec succès"),
            @ApiResponse(responseCode = "400", description = "Données invalides"),
            @ApiResponse(responseCode = "401", description = "Non authentifié"),
            @ApiResponse(responseCode = "403", description = "Non autorisé à modifier cette évaluation"),
            @ApiResponse(responseCode = "404", description = "Évaluation non trouvée")
    })
    public ResponseEntity<RatingResponse> updateRating(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @PathVariable Long ratingId,
            @Valid @RequestBody RatingUpdateRequest request
    ) {
        RatingResponse response = ratingService.updateRating(userDetails.getId(), ratingId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{ratingId}")
    @Operation(summary = "Supprimer une évaluation")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Évaluation supprimée avec succès"),
            @ApiResponse(responseCode = "401", description = "Non authentifié"),
            @ApiResponse(responseCode = "403", description = "Non autorisé à supprimer cette évaluation"),
            @ApiResponse(responseCode = "404", description = "Évaluation non trouvée")
    })
    public ResponseEntity<Void> deleteRating(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @PathVariable Long ratingId
    ) {
        ratingService.deleteRating(userDetails.getId(), ratingId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{ratingId}")
    @Operation(summary = "Obtenir une évaluation par son ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Évaluation trouvée"),
            @ApiResponse(responseCode = "404", description = "Évaluation non trouvée")
    })
    public ResponseEntity<RatingResponse> getRatingById(
            @PathVariable Long ratingId
    ) {
        RatingResponse response = ratingService.getRatingById(ratingId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/technician/{technicianId}")
    @Operation(summary = "Obtenir toutes les évaluations d'un technicien avec pagination")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Liste des évaluations"),
            @ApiResponse(responseCode = "404", description = "Technicien non trouvé")
    })
    public ResponseEntity<Page<RatingResponse>> getTechnicianRatings(
            @Parameter(description = "ID du technicien") @PathVariable Long technicianId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        Page<RatingResponse> ratings = ratingService.getTechnicianRatings(technicianId, pageable);
        return ResponseEntity.ok(ratings);
    }

    @GetMapping("/technician/{technicianId}/stats")
    @Operation(summary = "Obtenir les statistiques d'évaluation d'un technicien")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Statistiques des évaluations"),
            @ApiResponse(responseCode = "404", description = "Technicien non trouvé")
    })
    public ResponseEntity<TechnicianRatingStats> getTechnicianRatingStats(
            @Parameter(description = "ID du technicien") @PathVariable Long technicianId
    ) {
        TechnicianRatingStats stats = ratingService.getTechnicianRatingStats(technicianId);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/user/me")
    @Operation(summary = "Obtenir toutes les évaluations données par l'utilisateur connecté")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Liste des évaluations de l'utilisateur"),
            @ApiResponse(responseCode = "401", description = "Non authentifié")
    })
    public ResponseEntity<Page<RatingResponse>> getMyRatings(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);
        Page<RatingResponse> ratings = ratingService.getUserRatings(userDetails.getId(), pageable);
        return ResponseEntity.ok(ratings);
    }

    @GetMapping("/user/me/technician/{technicianId}")
    @Operation(summary = "Obtenir l'évaluation de l'utilisateur connecté pour un technicien spécifique")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Évaluation trouvée"),
            @ApiResponse(responseCode = "401", description = "Non authentifié"),
            @ApiResponse(responseCode = "404", description = "Aucune évaluation trouvée")
    })
    public ResponseEntity<RatingResponse> getMyRatingForTechnician(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @Parameter(description = "ID du technicien") @PathVariable Long technicianId
    ) {
        RatingResponse response = ratingService.getUserRatingForTechnician(userDetails.getId(), technicianId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/me/technician/{technicianId}/exists")
    @Operation(summary = "Vérifier si l'utilisateur connecté a déjà évalué un technicien")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Résultat de la vérification"),
            @ApiResponse(responseCode = "401", description = "Non authentifié")
    })
    public ResponseEntity<Map<String, Boolean>> hasUserRatedTechnician(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @Parameter(description = "ID du technicien") @PathVariable Long technicianId
    ) {
        boolean hasRated = ratingService.hasUserRatedTechnician(userDetails.getId(), technicianId);
        return ResponseEntity.ok(Map.of("hasRated", hasRated));
    }
}
