import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._();

  static const double tabletBreakpoint = 720;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  static T value<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
  }) {
    return isTablet(context) ? tablet : mobile;
  }
}

