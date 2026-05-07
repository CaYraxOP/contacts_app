import 'package:get/get.dart';

import '../screens/favorites/favorites_screen.dart';
import '../screens/contact_details/contact_details_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'app_routes.dart';
import 'bindings/contact_details_binding.dart';
import 'bindings/home_binding.dart';
import 'bindings/splash_binding.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
    ),
    GetPage(
      name: AppRoutes.contactDetails,
      page: () => const ContactDetailsScreen(),
      binding: ContactDetailsBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
