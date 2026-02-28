import 'package:anime_ui/pub/models/user.dart';
import 'api.dart';

class AuthService {
  Future<({String token, User user})> login(String username, String password) async {
    final resp = await dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    final data = extractData<Map<String, dynamic>>(resp);
    return (
      token: data['token'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<User> me() async {
    final resp = await dio.get('/auth/me');
    return extractDataObject(resp, User.fromJson);
  }
}
