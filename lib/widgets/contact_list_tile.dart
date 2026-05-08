import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../core/theme/app_radii.dart';
import '../core/theme/app_spacing.dart';
import 'contact_avatar.dart';

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onToggleFavorite,
    this.onLongPress,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = contact.phone ?? contact.email ?? '';

    return RepaintBoundary(
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        elevation: 0.4,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: AppRadii.md,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              leading: Hero(
                tag: 'avatar_${contact.id ?? contact.name}',
                child: ContactAvatar(
                  fallbackText: contact.name,
                  photoPath: contact.imagePath,
                  radius: 20,
                ),
              ),
              title: Text(
                contact.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: subtitle.isEmpty
                  ? null
                  : Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: IconButton(
                tooltip: contact.isFavorite ? 'Unfavorite' : 'Favorite',
                onPressed: onToggleFavorite,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    contact.isFavorite ? Icons.star : Icons.star_outline,
                    key: ValueKey<bool>(contact.isFavorite),
                    color: contact.isFavorite
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
