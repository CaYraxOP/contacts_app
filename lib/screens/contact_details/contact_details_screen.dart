import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/contact_details_controller.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';

import '../../widgets/contact_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/contact_edit_sheet.dart';
import 'widgets/contact_info_widgets.dart';

class ContactDetailsScreen extends GetView<ContactDetailsController> {
  const ContactDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.contact.value == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final contact = controller.contact.value;
      if (contact == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const EmptyState(
            title: 'Contact not found',
            subtitle: 'It may have been deleted.',
          ),
        );
      }

      final theme = Theme.of(context);
      final created = MaterialLocalizations.of(context).formatFullDate(contact.createdAt);

      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 260,
              actions: <Widget>[
                if ((contact.phone ?? '').trim().isNotEmpty)
                  IconButton(
                    tooltip: 'Call',
                    onPressed: controller.callContact,
                    icon: const Icon(Icons.call_outlined),
                  ),
                Obx(() {
                  final fav = controller.contact.value?.isFavorite ?? false;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      key: ValueKey<bool>(fav),
                      tooltip: fav ? 'Unfavorite' : 'Favorite',
                      onPressed: controller.toggleFavorite,
                      icon: Icon(fav ? Icons.star : Icons.star_outline),
                    ),
                  );
                }),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () async {
                    final updated = await ContactEditSheet.show(
                      context: context,
                      existing: contact,
                    );
                    if (updated != null) {
                      await controller.save(updated);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Hero(
                          tag: 'avatar_${contact.id ?? contact.name}',
                          child: ContactAvatar(
                            fallbackText: contact.name,
                            photoPath: contact.imagePath,
                            radius: 52,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          contact.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.isTablet(context) ? 680 : double.infinity,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        if ((contact.phone ?? '').trim().isNotEmpty)
                          FilledButton.tonalIcon(
                            onPressed: controller.callContact,
                            icon: const Icon(Icons.call_outlined, size: 18),
                            label: const Text('Call'),
                          ),
                        Obx(() {
                          final fav = controller.contact.value?.isFavorite ?? false;
                          return FilledButton.tonalIcon(
                            onPressed: controller.toggleFavorite,
                            icon: Icon(
                              fav ? Icons.star : Icons.star_outline,
                              size: 18,
                            ),
                            label: Text(fav ? 'Favorited' : 'Favorite'),
                          );
                        }),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final updated = await ContactEditSheet.show(
                              context: context,
                              existing: contact,
                            );
                            if (updated != null) {
                              await controller.save(updated);
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.isTablet(context) ? 680 : double.infinity,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if ((contact.phone ?? '').trim().isNotEmpty) ...<Widget>[
                          ContactInfoTile(
                            icon: Icons.call_outlined,
                            title: 'Phone',
                            value: contact.phone!,
                            onTap: controller.callContact,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if ((contact.email ?? '').trim().isNotEmpty) ...<Widget>[
                          ContactInfoTile(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: contact.email!,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if ((contact.company ?? '').trim().isNotEmpty) ...<Widget>[
                          ContactInfoTile(
                            icon: Icons.business_outlined,
                            title: 'Company',
                            value: contact.company!,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if ((contact.notes ?? '').trim().isNotEmpty) ...<Widget>[
                          ContactInfoBlock(
                            title: 'Notes',
                            value: contact.notes!,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        Text(
                          'Created',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(created, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.xl),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),
                        Material(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                            title: Text(
                              'Delete',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text('Remove this contact from your phone'),
                            onTap: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete contact?'),
                                  content: Text('Delete "${contact.name}"?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await controller.delete();
                                if (context.mounted) Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Info widgets live in `widgets/contact_info_widgets.dart` so they can be reused
// in tablet split-view panes.
