import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../core/utils/loading_controller.dart';
import '../../database/app_database.dart';
import '../../services/contacts_service.dart';
import '../../services/phone_dialer_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppDatabase>(() => AppDatabase.instance, fenix: true);
    Get.put<LoadingController>(LoadingController(), permanent: true);
    Get.lazyPut<ContactsService>(
      () => ContactsService(Get.find<AppDatabase>()),
      fenix: true,
    );
    Get.lazyPut<PhoneDialerService>(() => const PhoneDialerService(), fenix: true);
    Get.put<ContactsController>(
      ContactsController(Get.find<ContactsService>()),
      permanent: true,
    );
    Get.put<AppController>(AppController(Get.find<ContactsService>()), permanent: true);
  }
}
