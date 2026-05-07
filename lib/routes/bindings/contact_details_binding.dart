import 'package:get/get.dart';

import '../../controllers/contact_details_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../services/contacts_service.dart';
import '../../services/phone_dialer_service.dart';

class ContactDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ContactDetailsController>(
      ContactDetailsController(
        Get.find<ContactsController>(),
        Get.find<ContactsService>(),
        Get.find<PhoneDialerService>(),
      ),
    );
  }
}
