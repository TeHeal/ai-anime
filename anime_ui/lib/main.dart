import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'package:anime_ui/pub/services/api_svc.dart';
import 'package:anime_ui/pub/services/storage_svc.dart';

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

  runApp(
    ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const App(),
    ),
  );
}
