import 'package:dio/dio.dart';
import 'package:techconnect/models/contact_request.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/models/technician.dart';
import 'package:techconnect/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api'; // Pour émulateur Android
  // static const String baseUrl = 'http://localhost:8080/api'; // Pour iOS

  late Dio _dio;

  ApiService({String? token}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (token != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Gérer l'expiration du token
          }
          return handler.next(error);
        },
      ));
    }
  }

  // Technicians
  Future<List<Technician>> getTechnicians({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/technicians',
        queryParameters: {'page': page, 'size': size},
      );

      final List<dynamic> data = response.data['content'];
      return data.map((json) => Technician.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Technician> getTechnicianById(int id) async {
    try {
      final response = await _dio.get('/technicians/$id');
      return Technician.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Technician>> searchTechnicians({
    String? domain,
    String? city,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;

      final response = await _dio.get(
        '/technicians/search',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['content'];
      return data.map((json) => Technician.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // User Profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Contact
  Future<void> sendContactEmail(ContactRequest request) async {
    try {
      await _dio.post('/contact/send', data: request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== RATINGS ====================

  /// Créer une évaluation pour un technicien
  Future<Rating> createRating(RatingRequest request) async {
    try {
      final response = await _dio.post('/ratings', data: request.toJson());
      return Rating.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtenir une évaluation par son ID
  Future<Rating> getRatingById(int ratingId) async {
    try {
      final response = await _dio.get('/ratings/$ratingId');
      return Rating.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mettre à jour une évaluation existante
  Future<Rating> updateRating(int ratingId, RatingUpdateRequest request) async {
    try {
      final response = await _dio.put('/ratings/$ratingId', data: request.toJson());
      return Rating.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprimer une évaluation
  Future<void> deleteRating(int ratingId) async {
    try {
      await _dio.delete('/ratings/$ratingId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtenir toutes les évaluations d'un technicien avec pagination
  Future<List<Rating>> getTechnicianRatings(int technicianId, {int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/ratings/technician/$technicianId',
        queryParameters: {'page': page, 'size': size},
      );
      final List<dynamic> data = response.data['content'];
      return data.map((json) => Rating.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtenir les statistiques d'évaluation d'un technicien
  Future<RatingStats> getTechnicianRatingStats(int technicianId) async {
    try {
      final response = await _dio.get('/ratings/technician/$technicianId/stats');
      return RatingStats.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtenir toutes les évaluations données par l'utilisateur connecté
  Future<List<Rating>> getMyRatings({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/ratings/user/me',
        queryParameters: {'page': page, 'size': size},
      );
      final List<dynamic> data = response.data['content'];
      return data.map((json) => Rating.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtenir l'évaluation de l'utilisateur connecté pour un technicien spécifique
  Future<Rating?> getMyRatingForTechnician(int technicianId) async {
    try {
      final response = await _dio.get('/ratings/user/me/technician/$technicianId');
      return Rating.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  /// Vérifier si l'utilisateur connecté a déjà évalué un technicien
  Future<bool> hasUserRatedTechnician(int technicianId) async {
    try {
      final response = await _dio.get('/ratings/user/me/technician/$technicianId/exists');
      return response.data['exists'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Erreur serveur: ${error.response?.statusCode}';
    }
    return 'Erreur réseau: ${error.message}';
  }
}
