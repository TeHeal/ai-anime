import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'package:anime_ui/pub/const/font_scale.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart';
import 'package:anime_ui/pub/services/storage_svc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  final savedToken = storageService.token;
  if (savedToken != null && savedToken.isNotEmpty) {
    setAuthToken(savedToken);
  }

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        fontSizeResolver: FontScale.resolve,
        builder: (context, child) => const App(),
      ),
    ),
  );
}
