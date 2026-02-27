import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';

import 'src/api/supabase_service.dart';
import 'src/app.dart' show App;
import 'src/config/constants.dart';
import 'src/config/get_platform.dart';
import 'src/utils/logger/logger_helper.dart';
import 'src/utils/themes/themes.dart';

void main() async {
  await _init();
  runApp(const ProviderScope(child: App()));
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set platform type
  pt = PlatformInfo.getCurrentPlatformType();

  // Initialize Supabase
  await _initSupabase();

  // Configure loading UI
  configEasyLoading();

  // Initialize cached image config
  await _initFastCachedImageConfig();

  log.i('App initialized successfully');
}

/// Initialize Supabase
Future<void> _initSupabase() async {
  try {
    await SupabaseService.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    log.i('Supabase initialized');
  } catch (e) {
    log.e('Supabase initialization failed: $e');
    // App can still work offline with local database
  }
}

/// Initialize FastCachedImage
Future<void> _initFastCachedImageConfig() async {
  if (pt.isWeb) {
    await FastCachedImageConfig.init(
      clearCacheAfter: const Duration(days: 30),
    );
  } else {
    final dir = await getApplicationDocumentsDirectory();
    await FastCachedImageConfig.init(
      subDir: dir.path,
      clearCacheAfter: const Duration(days: 30),
    );
  }
}

/// Configure EasyLoading UI
void configEasyLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.transparent
    ..boxShadow = const <BoxShadow>[]
    ..indicatorColor = kPrimaryColor
    ..progressColor = kPrimaryColor
    ..textColor = Colors.white
    ..textStyle = const TextStyle(
      fontSize: 16.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    )
    ..dismissOnTap = false
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = Colors.black.withOpacity(0.8)
    ..indicatorWidget = const SizedBox(
      height: 70.0,
      width: 70.0,
      child: SpinKitThreeBounce(color: kPrimaryColor, size: 30.0),
    )
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle;
}
