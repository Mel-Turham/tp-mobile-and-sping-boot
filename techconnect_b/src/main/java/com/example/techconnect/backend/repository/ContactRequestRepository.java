// ContactRequestRepository.java
package com.techconnect.backend.repository;

import com.techconnect.backend.entity.ContactRequest;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ContactRequestRepository
  extends JpaRepository<ContactRequest, Long>
{
  List<ContactRequest> findByTechnicianEmailOrderBySentAtDesc(
    String technicianEmail
  );
  Page<ContactRequest> findByUserEmailOrderBySentAtDesc(
    String userEmail,
    Pageable pageable
  );
}
