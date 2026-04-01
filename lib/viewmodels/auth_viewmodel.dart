import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/user.dart' as app;

class AuthViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSub;

  bool _isLoading = false;
  String? _errorMessage;
  bool _needsEmailConfirmation = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get needsEmailConfirmation => _needsEmailConfirmation;

  bool get isLoggedIn => _supabase.auth.currentSession != null;

  app.User? get currentUser {
    final u = _supabase.auth.currentUser;
    if (u == null) return null;
    final meta = u.userMetadata ?? {};
    return app.User(
      id: u.id,
      displayName: (meta['display_name'] as String?)?.isNotEmpty == true
          ? meta['display_name'] as String
          : u.email?.split('@').first ?? 'Người dùng',
      email: u.email ?? '',
      bio: meta['bio'] as String?,
    );
  }

  AuthViewModel() {
    // Listen to all subsequent auth state changes (sign in, sign out, token refresh)
    _authSub = _supabase.auth.onAuthStateChange.listen((_) {
      _needsEmailConfirmation = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // ── Login ──────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _needsEmailConfirmation = false;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _mapError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Lỗi kết nối. Vui lòng thử lại.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Register ───────────────────────────────────────────────
  Future<bool> register(
      String displayName, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _needsEmailConfirmation = false;
    notifyListeners();

    try {
      final res = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'display_name': displayName.trim()},
      );

      _isLoading = false;

      // Supabase yêu cầu xác nhận email → session == null
      if (res.session == null && res.user != null) {
        _needsEmailConfirmation = true;
        notifyListeners();
        return false; // Chưa đăng nhập, cần xác nhận email
      }

      notifyListeners();
      return res.session != null;
    } on AuthException catch (e) {
      _errorMessage = _mapError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Lỗi kết nối. Vui lòng thử lại.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── OAuth: Google ──────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    _errorMessage = null;
    _needsEmailConfirmation = false;
    notifyListeners();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? null : 'io.supabase.sounddiary://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // Kết quả được nhận qua onAuthStateChange (deep link callback)
    } on AuthException catch (e) {
      _errorMessage = _mapError(e.message);
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Đăng nhập Google thất bại. Vui lòng thử lại.';
      notifyListeners();
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // ── Update profile ─────────────────────────────────────────
  Future<bool> updateProfile({
    required String displayName,
    String? bio,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': displayName.trim(),
            if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
          },
        ),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _mapError(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Lỗi cập nhật. Vui lòng thử lại.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Error mapping ──────────────────────────────────────────
  String _mapError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password') ||
        msg.contains('wrong password')) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (msg.contains('email already registered') ||
        msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'Email này đã được đăng ký. Vui lòng đăng nhập.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Vui lòng xác nhận email trước khi đăng nhập.';
    }
    if (msg.contains('password') && msg.contains('weak')) {
      return 'Mật khẩu quá yếu. Hãy chọn mật khẩu mạnh hơn.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Lỗi kết nối. Vui lòng kiểm tra mạng.';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
