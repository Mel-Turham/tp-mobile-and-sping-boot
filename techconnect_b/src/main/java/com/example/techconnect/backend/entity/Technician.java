package com.techconnect.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "technicians")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Technician {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String name;

  @Column(nullable = false, unique = true)
  private String email;

  @Column(nullable = false)
  private String password;

  @Column(nullable = false)
  private String phone;

  @Column(nullable = false)
  private String domain; // Electricity, Plumbing, IT, etc.

  @Column(nullable = false)
  private String city;

  @Column(length = 1000)
  private String description;

  private String profileImageUrl;

  @Column(nullable = false)
  private Double rating = 0.0;

  @Column(nullable = false)
  private Integer reviewCount = 0;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private User.Role role = User.Role.TECHNICIAN;

  @CreationTimestamp
  private LocalDateTime createdAt;
}
