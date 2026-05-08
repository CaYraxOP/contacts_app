import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'routes/bindings/app_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put<ThemeController>(ThemeController(), permanent: true);
  runApp(const ContactsApp());
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() {
      return GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeController.themeMode.value,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 220),
        builder: (context, child) {
          return AnimatedTheme(
            data: Theme.of(context),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialBinding: AppBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      );
    });
  }
}


