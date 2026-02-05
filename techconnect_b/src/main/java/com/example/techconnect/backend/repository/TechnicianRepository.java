// TechnicianRepository.java
package com.techconnect.backend.repository;

import com.techconnect.backend.entity.Technician;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface TechnicianRepository extends JpaRepository<Technician, Long> {
  Optional<Technician> findByEmail(String email);
  boolean existsByEmail(String email);

  @Query(
    "SELECT t FROM Technician t WHERE " +
      "(:domain IS NULL OR LOWER(t.domain) LIKE LOWER(CONCAT('%', :domain, '%'))) AND " +
      "(:city IS NULL OR LOWER(t.city) LIKE LOWER(CONCAT('%', :city, '%')))"
  )
  Page<Technician> searchTechnicians(
    @Param("domain") String domain,
    @Param("city") String city,
    Pageable pageable
  );

  Page<Technician> findByDomainIgnoreCase(String domain, Pageable pageable);
  Page<Technician> findByCityIgnoreCase(String city, Pageable pageable);
}
