import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  void setSystem() => themeMode.value = ThemeMode.system;
  void setLight() => themeMode.value = ThemeMode.light;
  void setDark() => themeMode.value = ThemeMode.dark;

  void toggleLightDark() {
    final current = themeMode.value;
    if (current == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
  }
}

