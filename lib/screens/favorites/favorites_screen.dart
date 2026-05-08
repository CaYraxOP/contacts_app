import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../controllers/contacts_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../features/contacts/presentation/shared/contacts_list_view.dart';

class FavoritesScreen extends GetView<ContactsController> {
  const FavoritesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final body = Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = controller.favorites;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: items.isEmpty
            ? const EmptyState(
                title: 'No favorites yet',
                subtitle: 'Mark a contact as favorite to see it here.',
                icon: Icons.star_outline,
              )
            : ContactsListView(
                contacts: items,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                onTapContact: (contact) => Get.toNamed(
                  AppRoutes.contactDetails,
                  arguments: contact.id,
                ),
                onToggleFavorite: (contact) async =>
                    controller.setFavorite(contact, false),
                onDelete: (contact) async => controller.deleteContact(contact),
              ),
      );
    });

    if (!showAppBar) return body;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.favoritesTitle)),
      body: body,
    );
  }
}
