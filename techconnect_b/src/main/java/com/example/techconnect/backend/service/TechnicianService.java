package com.techconnect.backend.service;

import com.techconnect.backend.dto.AuthDTOs.TechnicianResponse;
import com.techconnect.backend.entity.Technician;
import com.techconnect.backend.exception.ResourceNotFoundException;
import com.techconnect.backend.repository.TechnicianRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TechnicianService {

  private final TechnicianRepository technicianRepository;

  @Transactional(readOnly = true)
  public Page<TechnicianResponse> getAllTechnicians(Pageable pageable) {
    return technicianRepository.findAll(pageable).map(this::mapToResponse);
  }

  @Transactional(readOnly = true)
  public Page<TechnicianResponse> searchTechnicians(
    String domain,
    String city,
    Pageable pageable
  ) {
    if (
      (domain == null || domain.isEmpty()) && (city == null || city.isEmpty())
    ) {
      return getAllTechnicians(pageable);
    }
    return technicianRepository
      .searchTechnicians(domain, city, pageable)
      .map(this::mapToResponse);
  }

  @Transactional(readOnly = true)
  public TechnicianResponse getTechnicianById(Long id) {
    Technician technician = technicianRepository
      .findById(id)
      .orElseThrow(() ->
        new ResourceNotFoundException("Technician not found with id: " + id)
      );
    return mapToResponse(technician);
  }

  private TechnicianResponse mapToResponse(Technician t) {
    return TechnicianResponse.builder()
      .id(t.getId())
      .name(t.getName())
      .email(t.getEmail())
      .phone(t.getPhone())
      .domain(t.getDomain())
      .city(t.getCity())
      .description(t.getDescription())
      .profileImageUrl(t.getProfileImageUrl())
      .rating(t.getRating())
      .reviewCount(t.getReviewCount())
      .createdAt(t.getCreatedAt())
      .build();
  }
}
