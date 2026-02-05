package com.techconnect.backend.security;

import com.techconnect.backend.entity.Technician;
import com.techconnect.backend.entity.User;
import com.techconnect.backend.repository.TechnicianRepository;
import com.techconnect.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

  private final UserRepository userRepository;
  private final TechnicianRepository technicianRepository;

  @Override
  @Transactional
  public UserDetails loadUserByUsername(String email)
    throws UsernameNotFoundException {
    // Chercher d'abord dans les users
    User user = userRepository.findByEmail(email).orElse(null);
    if (user != null) {
      return UserDetailsImpl.build(user);
    }

    // Sinon chercher dans les technicians
    Technician technician = technicianRepository
      .findByEmail(email)
      .orElseThrow(() ->
        new UsernameNotFoundException("User not found with email: " + email)
      );

    // Retourner UserDetailsImpl pour les techniciens aussi
    return UserDetailsImpl.buildFromTechnician(technician);
  }
}
