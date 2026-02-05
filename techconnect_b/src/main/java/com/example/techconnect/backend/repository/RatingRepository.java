package com.techconnect.backend.repository;

import com.techconnect.backend.entity.Rating;
import com.techconnect.backend.entity.Technician;
import com.techconnect.backend.entity.User;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface RatingRepository extends JpaRepository<Rating, Long> {

    /**
     * Find a rating by user and technician
     */
    Optional<Rating> findByUserAndTechnician(User user, Technician technician);

    /**
     * Find a rating by user ID and technician ID
     */
    Optional<Rating> findByUserIdAndTechnicianId(Long userId, Long technicianId);

    /**
     * Check if a user has already rated a technician
     */
    boolean existsByUserIdAndTechnicianId(Long userId, Long technicianId);

    /**
     * Get all ratings for a specific technician
     */
    List<Rating> findByTechnicianId(Long technicianId);

    /**
     * Get all ratings for a specific technician with pagination
     */
    Page<Rating> findByTechnicianIdOrderByCreatedAtDesc(Long technicianId, Pageable pageable);

    /**
     * Get all ratings given by a specific user
     */
    List<Rating> findByUserId(Long userId);

    /**
     * Get all ratings given by a specific user with pagination
     */
    Page<Rating> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    /**
     * Calculate the average rating for a technician
     */
    @Query("SELECT AVG(r.score) FROM Rating r WHERE r.technician.id = :technicianId")
    Double calculateAverageRatingByTechnicianId(@Param("technicianId") Long technicianId);

    /**
     * Count the number of ratings for a technician
     */
    long countByTechnicianId(Long technicianId);

    /**
     * Delete all ratings for a specific technician
     */
    void deleteByTechnicianId(Long technicianId);

    /**
     * Delete all ratings given by a specific user
     */
    void deleteByUserId(Long userId);

    /**
     * Get ratings by technician ID and score
     */
    List<Rating> findByTechnicianIdAndScore(Long technicianId, Integer score);

    /**
     * Count ratings by technician ID and score (useful for rating distribution)
     */
    long countByTechnicianIdAndScore(Long technicianId, Integer score);
}
