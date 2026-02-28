import 'package:shared_preferences/shared_preferences.dart';

const kTokenKey = 'auth_token';
const kCurrentProjectIdKey = 'current_project_id';

class StorageService {
  StorageService(this._prefs);
  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  Future<bool> remove(String key) => _prefs.remove(key);

  String? get token => getString(kTokenKey);
  Future<bool> setToken(String value) => setString(kTokenKey, value);
  Future<bool> clearToken() => remove(kTokenKey);

  String? get currentProjectId => getString(kCurrentProjectIdKey);

  Future<bool> setCurrentProjectId(String id) => setString(kCurrentProjectIdKey, id);
  Future<bool> clearCurrentProjectId() => remove(kCurrentProjectIdKey);
}
