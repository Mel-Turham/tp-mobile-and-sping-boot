class ContactRequest {
  final String technicianEmail;
  final String message;

  ContactRequest({
    required this.technicianEmail,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'technicianEmail': technicianEmail,
      'message': message,
    };
  }
}