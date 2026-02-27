import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

late PlatformType pt;

enum PlatformType {
  web,
  android,
  ios,
  linux,
  macos,
  windows,
  fuchsia;

  bool get isWeb => this == PlatformType.web;
  bool get isAndroid => this == PlatformType.android;
  bool get isIOS => this == PlatformType.ios;
  bool get isLinux => this == PlatformType.linux;
  bool get isMacOS => this == PlatformType.macos;
  bool get isWindows => this == PlatformType.windows;
  bool get isFuchsia => this == PlatformType.fuchsia;

  bool get isMobile => isAndroid || isIOS;
  bool get isDesktop => isLinux || isMacOS || isWindows;
}

class PlatformInfo {
  static PlatformType getCurrentPlatformType() {
    if (kIsWeb) return PlatformType.web;
    
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isIOS) return PlatformType.ios;
    if (Platform.isLinux) return PlatformType.linux;
    if (Platform.isMacOS) return PlatformType.macos;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isFuchsia) return PlatformType.fuchsia;
    
    throw UnsupportedError('Unknown platform');
  }
}
