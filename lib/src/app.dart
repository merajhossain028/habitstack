import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/l10n/app_localizations.dart';

import 'config/constants.dart' show appName;
import 'config/size.dart';
import 'localization/loalization.dart';
import 'modules/entry_point/entry_point.dart';
import 'modules/onboarding/provider/onboarding_provider.dart';
import 'modules/onboarding/view/landing_screen.dart';
import 'modules/settings/provider/fonts_provider.dart';
import 'modules/settings/provider/locale_provider.dart';
import 'modules/settings/provider/performance_overlay_provider.dart';
import 'modules/settings/provider/theme_provider.dart';
import 'shared/internet/view/internet.dart';
import 'shared/ksnackbar/ksnackbar.dart';
import 'utils/extensions/extensions.dart';
import 'utils/logger/logger_helper.dart';
import 'utils/themes/dark/dark.theme.dart';
import 'utils/themes/light/light.theme.dart';

class App extends ConsumerWidget {
  const App({super.key = const Key(appName)});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboardingAsync = ref.watch(
      hasCompletedOnboardingProvider,
    );

    return MaterialApp(
      title: appName,
      theme: _themeData(context, ref),

      home: hasCompletedOnboardingAsync.when(
        data: (hasCompleted) => hasCompleted
            ? const InternetWidget(child: EntryPoint())
            : const LandingScreen(),
        loading: () => const _LoadingScreen(),
        error: (_, __) => const LandingScreen(),
      ),

      onGenerateTitle: onGenerateTitle,
      scaffoldMessengerKey: globalSnackbarKey,
      debugShowCheckedModeBanner: false,
      restorationScopeId: appName.toLowerCase().replaceAll(' ', '_'),
      locale: ref.watch(localeProvider),
      localizationsDelegates: localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      showPerformanceOverlay: ref.watch(performanceOverlayProvider),

      builder: EasyLoading.init(
        builder: (ctx, child) {
          t = AppLocalizations.of(ctx)!;
          topBarSize = ctx.padding.top;
          bottomViewPadding = ctx.padding.bottom;
          log.i('App build. Height: ${ctx.height} px, Width: ${ctx.width} px');
          return MediaQuery(
            data: ctx.mq.copyWith(
              devicePixelRatio: 1.0,
              textScaler: const TextScaler.linear(1.0),
            ),
            child: InternetWidget(child: child ?? const EntryPoint()),
          );
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

ThemeData _themeData(BuildContext context, WidgetRef ref) {
  final themeMode = ref.watch(themeModeProvider);

  // Determine which theme to use
  final t = themeMode == ThemeMode.system
      ? (context.isLightTheme ? lightTheme : darkTheme)
      : themeMode == ThemeMode.dark
      ? darkTheme
      : lightTheme;

  // Set system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    themeMode == ThemeMode.system
        ? (context.isLightTheme ? lightUiConfig : darkUiConfig)
        : themeMode == ThemeMode.dark
        ? darkUiConfig
        : lightUiConfig,
  );

  // Apply custom font if selected
  final fontFamily = ref.watch(fontFamilyProvider);
  if (fontFamily != null) {
    return t.copyWith(
      textTheme: t.textTheme.apply(fontFamily: fontFamily),
      primaryTextTheme: t.primaryTextTheme.apply(fontFamily: fontFamily),
    );
  }

  return t;
}
