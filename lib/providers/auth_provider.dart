import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Login dengan Email/Password
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        _user = UserModel.fromJson(response['user']);
        await ApiService.saveToken(response['token']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', _user!.id);
        await prefs.setString('user_email', _user!.email);
        await prefs.setString('user_name', _user!.fullname);
        await prefs.setString('user_role', _user!.role);
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login gagal';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String email, String password, String fullname) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/register', {
        'email': email,
        'password': password,
        'fullname': fullname,
      });

      if (response['success'] == true) {
        _user = UserModel.fromJson(response['user']);
        await ApiService.saveToken(response['token']);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Registrasi gagal';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cek session
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token != null) {
      try {
        final response = await ApiService.get('/me');
        if (response['id'] != null) {
          _user = UserModel(
            id: response['id'],
            email: response['email'],
            fullname: response['fullname'],
            role: response['role'] ?? 'pasien',
            token: token,
          );
          notifyListeners();
        } else {
          await logout();
        }
      } catch (e) {
        await logout();
      }
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await ApiService.post('/logout', {});
    } catch (e) {
      // ignore
    }
    await ApiService.clearToken();
    _user = null;
    notifyListeners();
  }

  // Tambahkan method ini di dalam class AuthProvider
  Future<void> refreshUser() async {
    try {
      final response = await ApiService.get('/me');
      if (response['id'] != null) {
        _user = UserModel(
          id: response['id'],
          email: response['email'],
          fullname: response['fullname'],
          role: response['role'] ?? 'pasien',
          token: _user?.token,
        );
        
        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _user!.fullname);
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh user error: $e');
    }
  }
}