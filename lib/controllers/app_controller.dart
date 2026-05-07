import 'package:get/get.dart';

import '../services/contacts_service.dart';

class AppController extends GetxController {
  AppController(this._contactsService);

  final ContactsService _contactsService;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _contactsService.warmUp();
  }
}

