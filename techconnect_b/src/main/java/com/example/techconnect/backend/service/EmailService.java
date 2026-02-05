package com.techconnect.backend.service;

import com.techconnect.backend.entity.ContactRequest;
import com.techconnect.backend.repository.ContactRequestRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.time.format.DateTimeFormatter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

  private final JavaMailSender mailSender;
  private final ContactRequestRepository contactRequestRepository;

  @Value("${spring.mail.username}")
  private String fromEmail;

  @Async
  public void sendContactEmail(
    String userEmail,
    String technicianEmail,
    String message
  ) {
    try {
      // Save contact request to database
      ContactRequest contactRequest = ContactRequest.builder()
        .userEmail(userEmail)
        .technicianEmail(technicianEmail)
        .message(message)
        .build();
      contactRequestRepository.save(contactRequest);

      // Send email
      MimeMessage mimeMessage = mailSender.createMimeMessage();
      MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "UTF-8");

      helper.setFrom(fromEmail);
      helper.setTo(technicianEmail);
      helper.setReplyTo(userEmail);
      helper.setSubject("Nouvelle demande de contact - TechConnect");

      String htmlContent = buildEmailContent(
        userEmail,
        message,
        contactRequest
          .getSentAt()
          .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
      );
      helper.setText(htmlContent, true);

      mailSender.send(mimeMessage);
      log.info(
        "Contact email sent successfully from {} to {}",
        userEmail,
        technicianEmail
      );
    } catch (MessagingException | MailException e) {
      log.error("Failed to send email", e);
      throw new RuntimeException("Failed to send email: " + e.getMessage());
    }
  }

  private String buildEmailContent(
    String userEmail,
    String message,
    String date
  ) {
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #4F46E5; color: white; padding: 20px; text-align: center; }
            .content { background-color: #f9fafb; padding: 30px; border-radius: 8px; margin-top: 20px; }
            .message-box { background-color: white; padding: 20px; border-left: 4px solid #4F46E5; margin: 20px 0; }
            .footer { text-align: center; color: #6b7280; font-size: 12px; margin-top: 30px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Nouvelle demande de contact</h1>
            </div>
            <div class="content">
                <p><strong>De :</strong> %s</p>
                <p><strong>Date :</strong> %s</p>

                <div class="message-box">
                    <h3>Message :</h3>
                    <p>%s</p>
                </div>

                <p>Vous pouvez répondre directement à cet email pour contacter le client.</p>
            </div>
            <div class="footer">
                <p>Cet email a été envoyé via TechConnect - Plateforme de mise en relation</p>
            </div>
        </div>
    </body>
    </html>
    """.formatted(userEmail, date, message.replace("\n", "<br>"));
  }
}
