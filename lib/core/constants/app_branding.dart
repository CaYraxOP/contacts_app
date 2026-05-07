import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBranding {
  const AppBranding._();

  static const String appName = 'Contacts';
  static const String tagline = 'Keep people close';

  static const IconData appIcon = Icons.person_outline;

  static Color get seed => AppColors.seed;
}

