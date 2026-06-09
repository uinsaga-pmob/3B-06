import 'package:flutter/material.dart';

class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? _currentUserEmail;
  bool _isGuestMode = false;
  Map<String, dynamic>? _currentUserData;

  String? get currentUserEmail => _currentUserEmail;
  bool get isGuestMode => _isGuestMode;
  bool get isLoggedIn => _currentUserEmail != null && !_isGuestMode;
  Map<String, dynamic>? get currentUserData => _currentUserData;

  void setUserSession(String email, Map<String, dynamic> userData, {bool isGuest = false}) {
    _currentUserEmail = email;
    _currentUserData = userData;
    _isGuestMode = isGuest;
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic> userData) {
    _currentUserData = userData;
    notifyListeners();
  }

  void clearSession() {
    _currentUserEmail = null;
    _currentUserData = null;
    _isGuestMode = false;
    notifyListeners();
  }

  void setGuestMode() {
    _isGuestMode = true;
    _currentUserEmail = null;
    _currentUserData = null;
    notifyListeners();
  }
}