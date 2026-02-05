class Technician {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String domain;
  final String city;
  final String? description;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.domain,
    required this.city,
    this.description,
    this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      domain: json['domain'],
      city: json['city'],
      description: json['description'],
      profileImageUrl: json['profileImageUrl'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'domain': domain,
      'city': city,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}