import 'package:flutter/material.dart';

enum ThemeType { system, light, dark }

class ThemeModel {
  final ThemeType type;

  const ThemeModel({
    this.type = ThemeType.system,
  });

  ThemeModel copyWith({ThemeType? type}) {
    return ThemeModel(type: type ?? this.type);
  }

  ThemeMode get themeMode {
    switch (type) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.system:
        return ThemeMode.system;
    }
  }

  Map<String, dynamic> toJson() {
    return {'type': type.name};
  }

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      type: ThemeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ThemeType.system,
      ),
    );
  }
}