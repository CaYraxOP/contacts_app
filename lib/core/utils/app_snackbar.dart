import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  const AppSnackbar._();

  static void show(
    String title,
    String message, {
    SnackPosition position = SnackPosition.BOTTOM,
    Color? backgroundColor,
  }) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        snackPosition: position,
        backgroundColor: backgroundColor ?? Get.theme.colorScheme.surface,
        colorText: Get.theme.colorScheme.onSurface,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

