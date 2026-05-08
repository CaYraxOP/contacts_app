import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controllers/contacts_controller.dart';
import '../../../../../controllers/home_controller.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../widgets/contacts_search_bar.dart';
import '../../../../../widgets/empty_state.dart';
import '../../shared/contacts_list_view.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({
    super.key,
    required this.homeController,
    required this.contactsController,
    required this.isTablet,
  });

  final HomeController homeController;
  final ContactsController contactsController;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: ContactsSearchBar(),
        ),
        _ContactFilterChips(controller: contactsController),
        Obx(() {
          final query = contactsController.searchQuery.value.trim();
          if (query.isEmpty) return const SizedBox(height: 0);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${contactsController.visibleContacts.length} results',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Expanded(
          child: Obx(() {
            if (contactsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = contactsController.visibleContacts;
            final query = contactsController.searchQuery.value.trim();
            final activeFilter = contactsController.activeFilter.value;
            if (items.isEmpty) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: EmptyState(
                  title: _emptyTitle(query, activeFilter),
                  subtitle: _emptySubtitle(query, activeFilter),
                  icon: query.isEmpty
                      ? Icons.person_outline
                      : Icons.search_off_outlined,
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: ContactsListView(
                contacts: items,
                listKey: ValueKey<String>('list_${query}_${items.length}'),
                onTapContact: (contact) {
                  if (isTablet) {
                    homeController.selectContact(contact.id);
                  } else {
                    Get.toNamed(
                      AppRoutes.contactDetails,
                      arguments: contact.id,
                    );
                  }
                },
                onToggleFavorite: (contact) async => contactsController
                    .setFavorite(contact, !contact.isFavorite),
                onDelete: (contact) async =>
                    contactsController.deleteContact(contact),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _emptyTitle(String query, ContactFilter filter) {
    if (query.isNotEmpty) return 'No results';
    return switch (filter) {
      ContactFilter.all => AppStrings.emptyContactsTitle,
      ContactFilter.favorites => 'No favorites yet',
      ContactFilter.hasPhone => 'No contacts with phone',
    };
  }

  String _emptySubtitle(String query, ContactFilter filter) {
    if (query.isNotEmpty) return 'Try a different search term.';
    return switch (filter) {
      ContactFilter.all => AppStrings.emptyContactsSubtitle,
      ContactFilter.favorites => 'Star a contact to find it quickly here.',
      ContactFilter.hasPhone => 'Add phone numbers to contacts to see them here.',
    };
  }
}

class _ContactFilterChips extends StatelessWidget {
  const _ContactFilterChips({required this.controller});

  final ContactsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.activeFilter.value;
      final contacts = controller.contacts;
      final favoritesCount = contacts.where((c) => c.isFavorite).length;
      final phoneCount = contacts
          .where((c) => (c.phone ?? '').trim().isNotEmpty)
          .length;

      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          children: <Widget>[
            _FilterChipOption(
              label: 'All',
              count: contacts.length,
              selected: selected == ContactFilter.all,
              onSelected: () => controller.setFilter(ContactFilter.all),
            ),
            const SizedBox(width: 8),
            _FilterChipOption(
              label: 'Favorites',
              count: favoritesCount,
              selected: selected == ContactFilter.favorites,
              onSelected: () => controller.setFilter(ContactFilter.favorites),
            ),
            const SizedBox(width: 8),
            _FilterChipOption(
              label: 'Has phone',
              count: phoneCount,
              selected: selected == ContactFilter.hasPhone,
              onSelected: () => controller.setFilter(ContactFilter.hasPhone),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterChipOption extends StatelessWidget {
  const _FilterChipOption({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      avatar: selected ? const Icon(Icons.check, size: 16) : null,
    );
  }
}
