import 'api_svc.dart';

/// 管理员 API 服务 — 用户管理
class AdminService {
  /// 获取所有用户列表
  Future<List<dynamic>> listUsers() async {
    final resp = await dio.get('/admin/users');
    return extractData<List<dynamic>>(resp, defaultValue: []);
  }

  /// 创建新用户
  Future<void> createUser({
    required String username,
    required String password,
    String role = 'member',
  }) async {
    await dio.post(
      '/admin/users',
      data: {'username': username, 'password': password, 'role': role},
    );
  }
}
