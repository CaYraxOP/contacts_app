import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controllers/contacts_controller.dart';
import '../../../../../controllers/theme_controller.dart';

class HomeMenuButton extends StatelessWidget {
  const HomeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      onSelected: (value) {
        final theme = Get.find<ThemeController>();
        if (value == 'theme_system') theme.setSystem();
        if (value == 'theme_light') theme.setLight();
        if (value == 'theme_dark') theme.setDark();
        if (value == 'demo_contacts') {
          Get.find<ContactsController>().addDemoContacts(count: 25);
        }
      },
      itemBuilder: (context) {
        final theme = Get.find<ThemeController>();
        final mode = theme.themeMode.value;
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'demo_contacts',
            child: Text('Add demo contacts'),
          ),
          const PopupMenuDivider(),
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
    );
  }
}
