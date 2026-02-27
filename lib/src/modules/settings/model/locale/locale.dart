import 'package:flutter/material.dart';

class LocaleModel {
  final Locale locale;

  const LocaleModel({
    this.locale = const Locale('en'),
  });

  LocaleModel copyWith({Locale? locale}) {
    return LocaleModel(locale: locale ?? this.locale);
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode,
    };
  }

  factory LocaleModel.fromJson(Map<String, dynamic> json) {
    return LocaleModel(
      locale: Locale(
        json['languageCode'] as String,
        json['countryCode'] as String?,
      ),
    );
  }
}