package com.techconnect.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "contact_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContactRequest {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String userEmail;

  @Column(nullable = false)
  private String technicianEmail;

  @Column(nullable = false, length = 2000)
  private String message;

  @CreationTimestamp
  private LocalDateTime sentAt;

  private boolean read = false;
}
