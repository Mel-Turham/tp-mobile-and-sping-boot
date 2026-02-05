import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:techconnect/models/auth_response.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8080/api';

  String? _token;
  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  AuthResponse? get authResponse => _authResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      // Vérifier la validité du token
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      _authResponse = AuthResponse.fromJson(response.data);
      _token = _authResponse!.token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('role', _authResponse!.role);

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      if (e.response != null) {
        _error = e.response?.data['message'] ?? 'Erreur de connexion';
      } else {
        _error = 'Erreur réseau';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.post(
        '/auth/register/user',
        data: {'name': name, 'email': email, 'password': password},
      );

      _authResponse = AuthResponse.fromJson(response.data);
      _token = _authResponse!.token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('role', _authResponse!.role);

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;

      // Gestion spécifique du 409 Conflict
      if (e.response?.statusCode == 409) {
        _error = 'Cet email est déjà utilisé. Veuillez en choisir un autre ou vous connecter.';
      } else if (e.response?.statusCode == 400) {
        _error = 'Données invalides. Vérifiez les champs.';
      } else if (e.response != null) {
        _error = e.response?.data['message'] ?? 'Erreur d\'inscription';
      } else {
        _error = 'Erreur réseau. Vérifiez votre connexion.';
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> registerTechnician({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String domain,
    required String city,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.post(
        '/auth/register/technician',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'domain': domain,
          'city': city,
          if (description != null) 'description': description,
        },
      );

      _authResponse = AuthResponse.fromJson(response.data);
      _token = _authResponse!.token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('role', _authResponse!.role);

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      if (e.response != null) {
        _error = e.response?.data['message'] ?? 'Erreur d\'inscription';
      } else {
        _error = 'Erreur réseau';
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _authResponse = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
