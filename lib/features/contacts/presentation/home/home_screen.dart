import 'package:contacts_app/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/contacts_controller.dart';
import '../../../../controllers/home_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../widgets/contact_edit_sheet.dart';
import '../../../../screens/contact_details/widgets/contact_details_pane.dart';
import 'widgets/contacts_tab.dart';
import 'widgets/favorites_tab.dart';
import 'widgets/home_menu_button.dart';

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
          existing = contactsController.contacts.firstWhere(
            (c) => c.id == editId,
          );
        } catch (_) {
          existing = null;
        }
      }
      final updated = await ContactEditSheet.show(
        context: context,
        existing: existing,
      );
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
        actions: const <Widget>[HomeMenuButton()],
      ),
      body: Obx(() {
        final index = controller.selectedIndex.value;
        final listPane = IndexedStack(
          index: index,
          children: <Widget>[
            HeroMode(
              enabled: index == 0,
              child: ContactsTab(
                homeController: controller,
                contactsController: contactsController,
                isTablet: isTablet,
              ),
            ),
            HeroMode(
              enabled: index == 1,
              child: FavoritesTab(
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
                return ContactDetailsPane(
                  contactId: controller.selectedContactId.value,
                );
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
        if (index != 0) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => openContactSheet(tabIndex: index),
          icon: const Icon(Icons.add),
          label: const Text('Create'),
        );
      }),
    );
  }
}
