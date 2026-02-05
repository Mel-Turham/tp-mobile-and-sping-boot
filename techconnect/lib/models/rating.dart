class Rating {
  final int id;
  final int userId;
  final String userName;
  final int technicianId;
  final String technicianName;
  final int score;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.userName,
    required this.technicianId,
    required this.technicianName,
    required this.score,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Utilisateur',
      technicianId: json['technicianId'],
      technicianName: json['technicianName'] ?? 'Technicien',
      score: json['score'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'score': score,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Rating copyWith({
    int? id,
    int? userId,
    String? userName,
    int? technicianId,
    String? technicianName,
    int? score,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      score: score ?? this.score,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RatingStats {
  final int technicianId;
  final String technicianName;
  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;

  RatingStats({
    required this.technicianId,
    required this.technicianName,
    required this.averageRating,
    required this.totalReviews,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      technicianId: json['technicianId'],
      technicianName: json['technicianName'] ?? 'Technicien',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      fiveStarCount: json['fiveStarCount'] ?? 0,
      fourStarCount: json['fourStarCount'] ?? 0,
      threeStarCount: json['threeStarCount'] ?? 0,
      twoStarCount: json['twoStarCount'] ?? 0,
      oneStarCount: json['oneStarCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technicianId': technicianId,
      'technicianName': technicianName,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'fiveStarCount': fiveStarCount,
      'fourStarCount': fourStarCount,
      'threeStarCount': threeStarCount,
      'twoStarCount': twoStarCount,
      'oneStarCount': oneStarCount,
    };
  }

  /// Retourne le pourcentage pour chaque étoile
  double getPercentage(int stars) {
    if (totalReviews == 0) return 0.0;
    switch (stars) {
      case 5:
        return fiveStarCount / totalReviews * 100;
      case 4:
        return fourStarCount / totalReviews * 100;
      case 3:
        return threeStarCount / totalReviews * 100;
      case 2:
        return twoStarCount / totalReviews * 100;
      case 1:
        return oneStarCount / totalReviews * 100;
      default:
        return 0.0;
    }
  }

  /// Retourne le compte pour un nombre d'étoiles donné
  int getCount(int stars) {
    switch (stars) {
      case 5:
        return fiveStarCount;
      case 4:
        return fourStarCount;
      case 3:
        return threeStarCount;
      case 2:
        return twoStarCount;
      case 1:
        return oneStarCount;
      default:
        return 0;
    }
  }
}

class RatingRequest {
  final int technicianId;
  final int score;
  final String? comment;

  RatingRequest({
    required this.technicianId,
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'technicianId': technicianId,
      'score': score,
      'comment': comment,
    };
  }
}

class RatingUpdateRequest {
  final int score;
  final String? comment;

  RatingUpdateRequest({
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'comment': comment,
    };
  }
}
