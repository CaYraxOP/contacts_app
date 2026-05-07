import 'package:contacts_app/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/contact_edit_sheet.dart';
import '../../widgets/contacts_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/contact_list_tile.dart';
import '../../controllers/theme_controller.dart';
import '../../core/utils/responsive.dart';
import '../contact_details/widgets/contact_details_pane.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.find<ContactsController>();
    final isTablet = Responsive.isTablet(context);
    Future<void> openContactSheet({int tabIndex = 0, int? editId}) async {
      Contact? existing;
      if (editId != null) {
        try {
          existing = contactsController.contacts.firstWhere((c) => c.id == editId);
        } catch (_) {
          existing = null;
        }
      }
      final updated = await ContactEditSheet.show(context: context, existing: existing);
      if (updated == null) return;

      if (existing == null) {
        await contactsController.addContact(
          name: updated.name,
          phone: updated.phone,
          email: updated.email,
          company: updated.company,
          notes: updated.notes,
          imagePath: updated.imagePath,
        );
      } else {
        await contactsController.updateContact(updated);
      }

      controller.selectedIndex.value = tabIndex;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              final theme = Get.find<ThemeController>();
              if (value == 'theme_system') theme.setSystem();
              if (value == 'theme_light') theme.setLight();
              if (value == 'theme_dark') theme.setDark();
            },
            itemBuilder: (context) {
              final theme = Get.find<ThemeController>();
              final mode = theme.themeMode.value;
              return <PopupMenuEntry<String>>[
                CheckedPopupMenuItem<String>(
                  value: 'theme_system',
                  checked: mode == ThemeMode.system,
                  child: const Text('Theme: System'),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'theme_light',
                  checked: mode == ThemeMode.light,
                  child: const Text('Theme: Light'),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'theme_dark',
                  checked: mode == ThemeMode.dark,
                  child: const Text('Theme: Dark'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        final index = controller.selectedIndex.value;
        final listPane = IndexedStack(
          index: index,
          children: <Widget>[
            HeroMode(
              enabled: index == 0,
              child: _ContactsTab(
                homeController: controller,
                contactsController: contactsController,
                isTablet: isTablet,
              ),
            ),
            HeroMode(
              enabled: index == 1,
              child: _FavoritesTab(
                homeController: controller,
                contactsController: contactsController,
                isTablet: isTablet,
              ),
            ),
          ],
        );

        if (!isTablet) return listPane;

        return Row(
          children: <Widget>[
            Expanded(flex: 5, child: listPane),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 7,
              child: Obx(() {
                return ContactDetailsPane(contactId: controller.selectedContactId.value);
              }),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final index = controller.selectedIndex.value;
        return NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) {
            controller.selectedIndex.value = i;
            if (isTablet) controller.selectContact(null);
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: AppStrings.homeTitle,
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline),
              label: AppStrings.favoritesTitle,
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        final index = controller.selectedIndex.value;
        return AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: index == 0 ? 1 : 0.96,
          child: FloatingActionButton.extended(
            onPressed: index == 0 ? () => openContactSheet(tabIndex: index) : null,
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        );
      }),
    );
  }
}

class _ContactsTab extends StatelessWidget {
  const _ContactsTab({
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
        Obx(() {
          final q = contactsController.searchQuery.value.trim();
          if (q.isEmpty) return const SizedBox(height: 0);
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
            if (items.isEmpty) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: EmptyState(
                  key: ValueKey<String>('empty_$query'),
                  title: query.isEmpty ? AppStrings.emptyContactsTitle : 'No results',
                  subtitle: query.isEmpty
                      ? 'Tap + to add your first contact.'
                      : 'Try a different name, phone, or email.',
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: ListView.separated(
                key: ValueKey<String>('list_${query}_${items.length}'),
                itemCount: items.length,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final contact = items[i];
                  return ContactListTile(
                    key: ValueKey<int?>(contact.id),
                    contact: contact,
                    onTap: () {
                      if (isTablet) {
                        homeController.selectContact(contact.id);
                      } else {
                        Get.toNamed(AppRoutes.contactDetails, arguments: contact.id);
                      }
                    },
                    onToggleFavorite: () =>
                        contactsController.setFavorite(contact, !contact.isFavorite),
                    onLongPress: () async {
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
                        await contactsController.deleteContact(contact);
                      }
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({
    required this.homeController,
    required this.contactsController,
    required this.isTablet,
  });

  final HomeController homeController;
  final ContactsController contactsController;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (contactsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = contactsController.favorites;
      if (items.isEmpty) {
        return const EmptyState(
          title: 'No favorites yet',
          subtitle: 'Mark a contact as favorite to see it here.',
          icon: Icons.star_outline,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final contact = items[i];
          return ContactListTile(
            key: ValueKey<int?>(contact.id),
            contact: contact,
            onTap: () {
              if (isTablet) {
                homeController.selectContact(contact.id);
              } else {
                Get.toNamed(AppRoutes.contactDetails, arguments: contact.id);
              }
            },
            onToggleFavorite: () => contactsController.setFavorite(contact, false),
          );
        },
      );
    });
  }
}
