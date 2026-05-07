
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/app_snackbar.dart';
import '../models/contact.dart';
import '../services/contacts_service.dart';

class ContactsController extends GetxController {
  ContactsController(this._service);

  final ContactsService _service;
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxList<Contact> contacts = <Contact>[].obs;
  final RxList<Contact> visibleContacts = <Contact>[].obs;
  final RxString searchQuery = ''.obs;
  Worker? _searchWorker;

  List<Contact> get favorites => contacts.where((c) => c.isFavorite).toList();

  @override
  void onInit() {
    super.onInit();
    if (!Get.testMode) {
      loadContacts();
    }

    visibleContacts.assignAll(contacts);
    ever<List<Contact>>(contacts, (_) => _applyFilter());
    _searchWorker = debounce<String>(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 250),
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    try {
      final list = await _service.getAllContacts();
      contacts.assignAll(list);
      _applyFilter();
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to load contacts');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addContact({
    required String name,
    String? phone,
    String? email,
    String? company,
    String? notes,
    String? imagePath,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      AppSnackbar.show('Missing name', 'Please enter a name');
      return;
    }

    isLoading.value = true;
    try {
      final contact = Contact(
        name: cleanName,
        phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
        email: email?.trim().isEmpty == true ? null : email?.trim(),
        company: company?.trim().isEmpty == true ? null : company?.trim(),
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        imagePath: imagePath?.trim().isEmpty == true ? null : imagePath?.trim(),
        isFavorite: false,
        createdAt: DateTime.now(),
      );

      final id = await _service.insertContact(contact);
      contacts.add(contact.copyWith(id: id));
      _sortInPlace();
      _applyFilter();
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to add contact');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateContact(Contact updated) async {
    isLoading.value = true;
    try {
      await _service.updateContact(updated);
      final index = contacts.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        contacts[index] = updated;
        contacts.refresh();
        _sortInPlace();
        _applyFilter();
      }
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to update contact');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteContact(Contact contact) async {
    final id = contact.id;
    if (id == null) return;

    isLoading.value = true;
    try {
      await _service.deleteContact(id);
      contacts.removeWhere((c) => c.id == id);
      _applyFilter();
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to delete contact');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setFavorite(Contact contact, bool isFavorite) async {
    final id = contact.id;
    if (id == null) return;

    final optimistic = contact.copyWith(isFavorite: isFavorite);
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      contacts[index] = optimistic;
      contacts.refresh();
    }

    try {
      await _service.toggleFavorite(id, isFavorite);
    } catch (e) {
      // rollback
      if (index != -1) {
        contacts[index] = contact;
        contacts.refresh();
      }
      AppSnackbar.show('Error', 'Failed to update favorite');
    }
  }

  Future<String?> pickImagePath() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      return file?.path;
    } catch (e) {
      AppSnackbar.show('Error', 'Could not pick image');
      return null;
    }
  }

  void _sortInPlace() {
    final list = contacts.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    contacts.assignAll(list);
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      visibleContacts.assignAll(contacts);
      return;
    }

    visibleContacts.assignAll(
      contacts.where((c) {
        final name = c.name.toLowerCase();
        final phone = (c.phone ?? '').toLowerCase();
        final email = (c.email ?? '').toLowerCase();
        return name.contains(q) || phone.contains(q) || email.contains(q);
      }),
    );
  }
}
