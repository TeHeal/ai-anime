import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/user.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart'
    show setAuthToken, authToken;
import 'package:anime_ui/pub/services/auth_svc.dart';

class AuthState {
  AuthState({this.user, this.loading = false});
  final User? user;
  final bool loading;
  bool get isLoggedIn => authToken != null && authToken!.isNotEmpty;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  final _authSvc = AuthService();

  Future<void> fetchCurrentUser() async {
    state = AuthState(loading: true);
    try {
      final user = await _authSvc.me();
      state = AuthState(user: user);
    } catch (e, st) {
      debugPrint('AuthNotifier.fetchCurrentUser: $e');
      debugPrint(st.toString());
      state = AuthState();
    }
  }

  Future<void> logout() async {
    setAuthToken(null);
    await ref.read(storageServiceProvider).clearToken();
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
