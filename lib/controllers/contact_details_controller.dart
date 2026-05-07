import 'package:get/get.dart';

import '../core/utils/app_snackbar.dart';
import '../models/contact.dart';
import 'contacts_controller.dart';
import '../services/contacts_service.dart';
import '../services/phone_dialer_service.dart';

class ContactDetailsController extends GetxController {
  ContactDetailsController(this._contactsController, this._service, this._dialer);

  final ContactsController _contactsController;
  final ContactsService _service;
  final PhoneDialerService _dialer;

  final Rxn<Contact> contact = Rxn<Contact>();
  final RxBool isLoading = false.obs;

  int? _id;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    _id = arg is int ? arg : null;
    _syncFromList();

    ever<List<Contact>>(_contactsController.contacts, (_) => _syncFromList());
    if (_id != null && contact.value == null) {
      _loadFromDb();
    }
  }

  void _syncFromList() {
    final id = _id;
    if (id == null) return;
    final idx = _contactsController.contacts.indexWhere((c) => c.id == id);
    if (idx != -1) contact.value = _contactsController.contacts[idx];
  }

  Future<void> _loadFromDb() async {
    final id = _id;
    if (id == null) return;

    isLoading.value = true;
    try {
      final all = await _service.getAllContacts();
      final found = all.where((c) => c.id == id).toList();
      if (found.isNotEmpty) {
        contact.value = found.first;
      }
    } catch (_) {
      // ignore, UI will show a friendly empty state
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    final c = contact.value;
    if (c == null) return;
    await _contactsController.setFavorite(c, !c.isFavorite);
  }

  Future<void> callContact() async {
    final c = contact.value;
    final phone = c?.phone;
    if (phone == null || phone.trim().isEmpty) {
      AppSnackbar.show('Invalid phone', 'This contact has no phone number.');
      return;
    }

    try {
      final ok = await _dialer.dial(phone);
      if (!ok) {
        AppSnackbar.show('Call failed', 'Could not open the dialer.');
      }
    } catch (_) {
      AppSnackbar.show('Call failed', 'Could not open the dialer.');
    }
  }

  Future<void> delete() async {
    final c = contact.value;
    if (c == null) return;
    await _contactsController.deleteContact(c);
  }

  Future<void> save(Contact updated) async {
    try {
      await _contactsController.updateContact(updated);
      contact.value = updated;
    } catch (_) {
      AppSnackbar.show('Error', 'Failed to save contact');
    }
  }
}
