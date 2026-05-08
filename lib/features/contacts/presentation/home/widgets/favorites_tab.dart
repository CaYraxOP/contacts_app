import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controllers/contacts_controller.dart';
import '../../../../../controllers/home_controller.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../widgets/empty_state.dart';
import '../../shared/contacts_list_view.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({
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

      return ContactsListView(
        contacts: items,
        onTapContact: (contact) {
          if (isTablet) {
            homeController.selectContact(contact.id);
          } else {
            Get.toNamed(AppRoutes.contactDetails, arguments: contact.id);
          }
        },
        onToggleFavorite: (contact) async =>
            contactsController.setFavorite(contact, false),
        onDelete: (contact) async => contactsController.deleteContact(contact),
      );
    });
  }
}
