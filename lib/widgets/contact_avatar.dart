import 'dart:io';

import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.fallbackText,
    this.photoPath,
    this.radius = 20,
  });

  final String fallbackText;
  final String? photoPath;
  final double radius;

  String get _initials {
    final text = fallbackText.trim();
    if (text.isEmpty) return '?';

    final parts = text.split(RegExp(r'\\s+')).where((p) => p.isNotEmpty).toList();
    final first = parts.first.isEmpty ? '' : parts.first.substring(0, 1);
    final second = (parts.length > 1 && parts[1].isNotEmpty) ? parts[1].substring(0, 1) : '';

    final out = (first + second).toUpperCase();
    return out.isEmpty ? '?' : out;
  }

  @override
  Widget build(BuildContext context) {
    final path = photoPath?.trim();
    final hasImage = path != null && path.isNotEmpty;
    final theme = Theme.of(context);
    final bg = _fallbackBackground(theme, fallbackText);

    return Semantics(
      label: 'Avatar for ${fallbackText.trim().isEmpty ? 'contact' : fallbackText.trim()}',
      image: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: ClipOval(
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: hasImage
                ? Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 180),
                        child: child,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => _Fallback(
                      initials: _initials,
                      radius: radius,
                      backgroundColor: bg,
                    ),
                  )
                : _Fallback(
                    initials: _initials,
                    radius: radius,
                    backgroundColor: bg,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.initials,
    required this.radius,
    required this.backgroundColor,
  });

  final String initials;
  final double radius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final textColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

Color _fallbackBackground(ThemeData theme, String name) {
  final n = name.trim();
  if (n.isEmpty) return theme.colorScheme.surfaceContainerHighest;

  // Deterministic "random" color based on the contact name (stable across rebuilds).
  final hash = n.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
  final hue = (hash % 360).toDouble();

  final isDark = theme.brightness == Brightness.dark;
  final sat = isDark ? 0.45 : 0.55;
  final light = isDark ? 0.35 : 0.82;

  return HSLColor.fromAHSL(1, hue, sat, light).toColor();
}
