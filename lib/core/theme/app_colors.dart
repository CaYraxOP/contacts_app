import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF1A73E8); // Google-ish blue

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(seedColor: seed);
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
  }
}

