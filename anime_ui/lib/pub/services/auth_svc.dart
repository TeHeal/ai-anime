import 'package:anime_ui/pub/models/user.dart';
import 'api_svc.dart';

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

  /// 用户注册 → 返回 token + user，可直接登录
  Future<({String token, User user})> register({
    required String username,
    required String password,
    String displayName = '',
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
    };
    if (displayName.isNotEmpty) body['displayName'] = displayName;
    final resp = await dio.post('/auth/register', data: body);
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

  /// 修改当前用户密码
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await dio.put(
      '/auth/password',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }
}
