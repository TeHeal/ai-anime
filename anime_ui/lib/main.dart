import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'package:anime_ui/pub/services/api.dart';
import 'package:anime_ui/pub/services/storage.dart';

late final StorageService storageService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  final prefs = await SharedPreferences.getInstance();
  storageService = StorageService(prefs);

  final savedToken = storageService.token;
  if (savedToken != null && savedToken.isNotEmpty) {
    setAuthToken(savedToken);
  }

  runApp(const App());
}
