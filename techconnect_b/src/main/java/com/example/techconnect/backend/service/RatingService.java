package com.techconnect.backend.service;

import com.techconnect.backend.dto.AuthDTOs.RatingRequest;
import com.techconnect.backend.dto.AuthDTOs.RatingResponse;
import com.techconnect.backend.dto.AuthDTOs.RatingUpdateRequest;
import com.techconnect.backend.dto.AuthDTOs.TechnicianRatingStats;
import com.techconnect.backend.entity.Rating;
import com.techconnect.backend.entity.Technician;
import com.techconnect.backend.entity.User;
import com.techconnect.backend.exception.ResourceNotFoundException;
import com.techconnect.backend.exception.UnauthorizedException;
import com.techconnect.backend.repository.RatingRepository;
import com.techconnect.backend.repository.TechnicianRepository;
import com.techconnect.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final TechnicianRepository technicianRepository;
    private final UserRepository userRepository;

    /**
     * Create a new rating for a technician
     */
    @Transactional
    public RatingResponse createRating(Long userId, RatingRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        Technician technician = technicianRepository.findById(request.getTechnicianId())
                .orElseThrow(() -> new ResourceNotFoundException("Technician not found with id: " + request.getTechnicianId()));

        // Check if user has already rated this technician
        if (ratingRepository.existsByUserIdAndTechnicianId(userId, request.getTechnicianId())) {
            throw new IllegalStateException("You have already rated this technician. Please update your existing rating.");
        }

        // Create the rating
        Rating rating = Rating.builder()
                .user(user)
                .technician(technician)
                .score(request.getScore())
                .comment(request.getComment())
                .build();

        Rating savedRating = ratingRepository.save(rating);

        // Update technician's average rating
        updateTechnicianRating(technician);

        return mapToResponse(savedRating);
    }

    /**
     * Update an existing rating
     */
    @Transactional
    public RatingResponse updateRating(Long userId, Long ratingId, RatingUpdateRequest request) {
        Rating rating = ratingRepository.findById(ratingId)
                .orElseThrow(() -> new ResourceNotFoundException("Rating not found with id: " + ratingId));

        // Verify that the rating belongs to the user
        if (!rating.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("You are not authorized to update this rating");
        }

        // Update the rating
        rating.setScore(request.getScore());
        rating.setComment(request.getComment());

        Rating updatedRating = ratingRepository.save(rating);

        // Update technician's average rating
        updateTechnicianRating(rating.getTechnician());

        return mapToResponse(updatedRating);
    }

    /**
     * Delete a rating
     */
    @Transactional
    public void deleteRating(Long userId, Long ratingId) {
        Rating rating = ratingRepository.findById(ratingId)
                .orElseThrow(() -> new ResourceNotFoundException("Rating not found with id: " + ratingId));

        // Verify that the rating belongs to the user
        if (!rating.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("You are not authorized to delete this rating");
        }

        Technician technician = rating.getTechnician();
        ratingRepository.delete(rating);

        // Update technician's average rating
        updateTechnicianRating(technician);
    }

    /**
     * Get a rating by ID
     */
    @Transactional(readOnly = true)
    public RatingResponse getRatingById(Long ratingId) {
        Rating rating = ratingRepository.findById(ratingId)
                .orElseThrow(() -> new ResourceNotFoundException("Rating not found with id: " + ratingId));
        return mapToResponse(rating);
    }

    /**
     * Get user's rating for a specific technician
     */
    @Transactional(readOnly = true)
    public RatingResponse getUserRatingForTechnician(Long userId, Long technicianId) {
        Rating rating = ratingRepository.findByUserIdAndTechnicianId(userId, technicianId)
                .orElseThrow(() -> new ResourceNotFoundException("Rating not found for this user and technician"));
        return mapToResponse(rating);
    }

    /**
     * Check if user has rated a technician
     */
    @Transactional(readOnly = true)
    public boolean hasUserRatedTechnician(Long userId, Long technicianId) {
        return ratingRepository.existsByUserIdAndTechnicianId(userId, technicianId);
    }

    /**
     * Get all ratings for a technician with pagination
     */
    @Transactional(readOnly = true)
    public Page<RatingResponse> getTechnicianRatings(Long technicianId, Pageable pageable) {
        // Verify technician exists
        if (!technicianRepository.existsById(technicianId)) {
            throw new ResourceNotFoundException("Technician not found with id: " + technicianId);
        }

        return ratingRepository.findByTechnicianIdOrderByCreatedAtDesc(technicianId, pageable)
                .map(this::mapToResponse);
    }

    /**
     * Get all ratings given by a user with pagination
     */
    @Transactional(readOnly = true)
    public Page<RatingResponse> getUserRatings(Long userId, Pageable pageable) {
        // Verify user exists
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("User not found with id: " + userId);
        }

        return ratingRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::mapToResponse);
    }

    /**
     * Get rating statistics for a technician
     */
    @Transactional(readOnly = true)
    public TechnicianRatingStats getTechnicianRatingStats(Long technicianId) {
        Technician technician = technicianRepository.findById(technicianId)
                .orElseThrow(() -> new ResourceNotFoundException("Technician not found with id: " + technicianId));

        Double averageRating = ratingRepository.calculateAverageRatingByTechnicianId(technicianId);
        long totalReviews = ratingRepository.countByTechnicianId(technicianId);

        return TechnicianRatingStats.builder()
                .technicianId(technicianId)
                .technicianName(technician.getName())
                .averageRating(averageRating != null ? Math.round(averageRating * 10.0) / 10.0 : 0.0)
                .totalReviews(totalReviews)
                .fiveStarCount(ratingRepository.countByTechnicianIdAndScore(technicianId, 5))
                .fourStarCount(ratingRepository.countByTechnicianIdAndScore(technicianId, 4))
                .threeStarCount(ratingRepository.countByTechnicianIdAndScore(technicianId, 3))
                .twoStarCount(ratingRepository.countByTechnicianIdAndScore(technicianId, 2))
                .oneStarCount(ratingRepository.countByTechnicianIdAndScore(technicianId, 1))
                .build();
    }

    /**
     * Update a technician's average rating and review count
     */
    @Transactional
    protected void updateTechnicianRating(Technician technician) {
        Double averageRating = ratingRepository.calculateAverageRatingByTechnicianId(technician.getId());
        long reviewCount = ratingRepository.countByTechnicianId(technician.getId());

        technician.setRating(averageRating != null ? Math.round(averageRating * 10.0) / 10.0 : 0.0);
        technician.setReviewCount((int) reviewCount);

        technicianRepository.save(technician);
    }

    /**
     * Map Rating entity to RatingResponse DTO
     */
    private RatingResponse mapToResponse(Rating rating) {
        return RatingResponse.builder()
                .id(rating.getId())
                .userId(rating.getUser().getId())
                .userName(rating.getUser().getName())
                .technicianId(rating.getTechnician().getId())
                .technicianName(rating.getTechnician().getName())
                .score(rating.getScore())
                .comment(rating.getComment())
                .createdAt(rating.getCreatedAt())
                .updatedAt(rating.getUpdatedAt())
                .build();
    }
}
