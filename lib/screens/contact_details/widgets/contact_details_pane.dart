import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/contact.dart';
import '../../../widgets/contact_avatar.dart';
import '../../../widgets/contact_edit_sheet.dart';
import '../../../widgets/empty_state.dart';
import '../../../services/phone_dialer_service.dart';
import 'contact_info_widgets.dart';

class ContactDetailsPane extends StatelessWidget {
  const ContactDetailsPane({super.key, required this.contactId});

  final int? contactId;

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.find<ContactsController>();
    final dialer = Get.find<PhoneDialerService>();
    final id = contactId;

    if (id == null) {
      return const EmptyState(
        title: 'Select a contact',
        subtitle: 'Pick a contact from the list to see details here.',
      );
    }

    return Obx(() {
      Contact? contact;
      try {
        contact = contactsController.contacts.firstWhere((c) => c.id == id);
      } catch (_) {
        contact = null;
      }

      if (contact == null) {
        return const EmptyState(
          title: 'Contact not found',
          subtitle: 'It may have been deleted.',
        );
      }

      final Contact c = contact;
      final theme = Theme.of(context);

      return Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isTablet(context)
                      ? 720
                      : double.infinity,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Hero(
                          tag: 'avatar_${c.id ?? c.name}',
                          child: ContactAvatar(
                            fallbackText: c.name,
                            photoPath: c.imagePath,
                            radius: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Call',
                          onPressed: (c.phone ?? '').trim().isEmpty
                              ? null
                              : () async {
                                  final ok = await dialer.dial(c.phone!);
                                  if (!ok) {
                                    AppSnackbar.show(
                                      'Call failed',
                                      'Could not open the dialer.',
                                    );
                                  }
                                },
                          icon: const Icon(Icons.call_outlined),
                        ),
                        IconButton(
                          tooltip: c.isFavorite ? 'Unfavorite' : 'Favorite',
                          onPressed: () =>
                              contactsController.setFavorite(c, !c.isFavorite),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: Icon(
                              c.isFavorite ? Icons.star : Icons.star_outline,
                              key: ValueKey<bool>(c.isFavorite),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () async {
                            final updated = await ContactEditSheet.show(
                              context: context,
                              existing: c,
                            );
                            if (updated != null) {
                              await contactsController.updateContact(updated);
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: AppRadii.lg,
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadii.lg,
                          child: _ContactDetailsInfo(contact: c),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ContactDetailsInfo extends StatelessWidget {
  const _ContactDetailsInfo({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        if ((contact.phone ?? '').trim().isNotEmpty)
          ContactInfoTile(
            icon: Icons.call_outlined,
            title: 'Phone',
            value: contact.phone!,
          ),
        if ((contact.email ?? '').trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          ContactInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: contact.email!,
          ),
        ],
        if ((contact.company ?? '').trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          ContactInfoTile(
            icon: Icons.business_outlined,
            title: 'Company',
            value: contact.company!,
          ),
        ],
        if ((contact.notes ?? '').trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          ContactInfoBlock(title: 'Notes', value: contact.notes!),
        ],
      ],
    );
  }
}

