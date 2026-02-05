package com.techconnect.backend.config;

import com.techconnect.backend.security.JwtAuthenticationFilter;
import java.util.Arrays;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

  private final UserDetailsService userDetailsService;
  private final JwtAuthenticationFilter jwtAuthenticationFilter;

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  public AuthenticationManager authenticationManager(
    AuthenticationConfiguration authConfig
  ) throws Exception {
    return authConfig.getAuthenticationManager();
  }

  @Bean
  public DaoAuthenticationProvider authenticationProvider() {
    DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
    authProvider.setUserDetailsService(userDetailsService);
    authProvider.setPasswordEncoder(passwordEncoder());
    return authProvider;
  }

  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
      .cors(cors -> cors.configurationSource(corsConfigurationSource()))
      .csrf(csrf -> csrf.disable())
      .sessionManagement(session ->
        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
      )
      .authenticationProvider(authenticationProvider())
      .addFilterBefore(
        jwtAuthenticationFilter,
        UsernamePasswordAuthenticationFilter.class
      )
      .authorizeHttpRequests(auth ->
        auth
          .requestMatchers("/api/auth/**")
          .permitAll()
          .requestMatchers(
            "/swagger-ui/**",
            "/swagger-ui.html",
            "/v3/api-docs/**",
            "/v3/api-docs.yaml",
            "/swagger-resources/**",
            "/webjars/**"
          )
          .permitAll()
          .requestMatchers(HttpMethod.GET, "/api/technicians/**")
          .permitAll()
          .requestMatchers(HttpMethod.GET, "/api/ratings/technician/**")
          .permitAll()
          .requestMatchers(HttpMethod.GET, "/api/ratings/{ratingId}")
          .permitAll()
          .requestMatchers("/api/admin/**")
          .hasRole("ADMIN")
          .anyRequest()
          .authenticated()
      );

    return http.build();
  }

  @Bean
  public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();

    // AUTORISER FLUTTER WEB SUR PORT 5000
    configuration.setAllowedOrigins(
      Arrays.asList(
        "http://localhost:5000", // Flutter web
        "http://localhost:8080", // Swagger UI
        "http://127.0.0.1:5000" // Alternative localhost
      )
    );

    configuration.setAllowedMethods(
      Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
    );
    configuration.setAllowedHeaders(
      Arrays.asList(
        "Authorization",
        "Content-Type",
        "Accept",
        "Origin",
        "X-Requested-With"
      )
    );
    configuration.setExposedHeaders(Arrays.asList("Authorization"));
    configuration.setAllowCredentials(true);
    configuration.setMaxAge(3600L); // 1 heure de cache pour les preflight

    UrlBasedCorsConfigurationSource source =
      new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }
}
