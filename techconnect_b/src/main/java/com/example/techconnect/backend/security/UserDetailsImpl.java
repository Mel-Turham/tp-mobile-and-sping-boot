package com.techconnect.backend.security;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.techconnect.backend.entity.Technician;
import com.techconnect.backend.entity.User;
import java.util.Collection;
import java.util.Collections;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

@Data
@AllArgsConstructor
public class UserDetailsImpl implements UserDetails {

  private static final long serialVersionUID = 1L;

  private Long id;
  private String email;
  private String name;

  @JsonIgnore
  private String password;

  private Collection<? extends GrantedAuthority> authorities;

  public static UserDetailsImpl build(User user) {
    return new UserDetailsImpl(
      user.getId(),
      user.getEmail(),
      user.getName(),
      user.getPassword(),
      Collections.singletonList(
        new SimpleGrantedAuthority("ROLE_" + user.getRole().name())
      )
    );
  }

  public static UserDetailsImpl buildFromTechnician(Technician technician) {
    return new UserDetailsImpl(
      technician.getId(),
      technician.getEmail(),
      technician.getName(),
      technician.getPassword(),
      Collections.singletonList(
        new SimpleGrantedAuthority("ROLE_" + technician.getRole().name())
      )
    );
  }

  @Override
  public String getUsername() {
    return email;
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return true;
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return true;
  }
}
