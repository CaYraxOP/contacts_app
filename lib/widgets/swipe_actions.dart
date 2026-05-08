import 'package:flutter/material.dart';

import '../core/theme/app_radii.dart';
import '../core/theme/app_spacing.dart';

class SwipeActions {
  const SwipeActions._();

  static Widget favorite(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: AppRadii.md,
        ),
        child: Icon(Icons.star, color: theme.colorScheme.onTertiaryContainer),
      ),
    );
  }

  static Widget delete(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppRadii.md,
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}
