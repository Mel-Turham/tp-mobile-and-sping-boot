package com.techconnect.backend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import javax.crypto.SecretKey;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class JwtTokenProvider {

  @Value("${app.jwt.secret}")
  private String jwtSecret;

  @Value("${app.jwt.expiration-ms}")
  private int jwtExpirationMs;

  private SecretKey getSigningKey() {
    return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
  }

  public String generateToken(Authentication authentication) {
    UserDetailsImpl userPrincipal =
      (UserDetailsImpl) authentication.getPrincipal();

    Date expiryDate = new Date(System.currentTimeMillis() + jwtExpirationMs);

    return Jwts.builder()
      .subject(userPrincipal.getEmail())
      .claim(
        "role",
        userPrincipal.getAuthorities().iterator().next().getAuthority()
      )
      .claim("userId", userPrincipal.getId())
      .issuedAt(new Date())
      .expiration(expiryDate)
      .signWith(getSigningKey())
      .compact();
  }

  public String generateTokenFromEmail(String email, String role, Long userId) {
    Date expiryDate = new Date(System.currentTimeMillis() + jwtExpirationMs);

    return Jwts.builder()
      .subject(email)
      .claim("role", role)
      .claim("userId", userId)
      .issuedAt(new Date())
      .expiration(expiryDate)
      .signWith(getSigningKey())
      .compact();
  }

  public String getEmailFromToken(String token) {
    Claims claims = Jwts.parser()
      .verifyWith(getSigningKey())
      .build()
      .parseSignedClaims(token)
      .getPayload();

    return claims.getSubject();
  }

  public boolean validateToken(String authToken) {
    try {
      Jwts.parser()
        .verifyWith(getSigningKey())
        .build()
        .parseSignedClaims(authToken);
      return true;
    } catch (SecurityException | MalformedJwtException e) {
      log.error("Invalid JWT signature: {}", e.getMessage());
    } catch (ExpiredJwtException e) {
      log.error("JWT token is expired: {}", e.getMessage());
    } catch (UnsupportedJwtException e) {
      log.error("JWT token is unsupported: {}", e.getMessage());
    } catch (IllegalArgumentException e) {
      log.error("JWT claims string is empty: {}", e.getMessage());
    }
    return false;
  }
}
