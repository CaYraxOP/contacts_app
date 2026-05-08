import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/app_snackbar.dart';
import '../core/utils/phone_utils.dart';
import '../models/contact.dart';
import '../services/contacts_service.dart';
import '../widgets/contact_edit_sheet.dart';

enum ContactFilter { all, favorites, hasPhone }

class ContactsController extends GetxController {
  ContactsController(this._service);

  final ContactsService _service;
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxList<Contact> contacts = <Contact>[].obs;
  final RxList<Contact> visibleContacts = <Contact>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<ContactFilter> activeFilter = ContactFilter.all.obs;
  final RxBool isSearching = false.obs;
  final RxInt totalMatches = 0.obs;
  Worker? _searchWorker;
  Worker? _contactsWorker;
  Worker? _filterWorker;

  int _searchToken = 0;

  List<Contact> get favorites => contacts.where((c) => c.isFavorite).toList();

  @override
  void onInit() {
    super.onInit();
    if (!Get.testMode) {
      loadContacts();
    }

    visibleContacts.assignAll(contacts);
    _contactsWorker = ever<List<Contact>>(contacts, (_) => _applySearch());
    _searchWorker = debounce<String>(
      searchQuery,
      (_) => _applySearch(),
      time: const Duration(milliseconds: 250),
    );
    _filterWorker = ever<ContactFilter>(activeFilter, (_) => _applySearch());
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    _contactsWorker?.dispose();
    _filterWorker?.dispose();
    super.onClose();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  void setFilter(ContactFilter filter) {
    activeFilter.value = filter;
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    try {
      final list = await _service.getAllContacts();
      contacts.assignAll(list);
      _applySearch();
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

    final norm = PhoneUtils.normalizeForDuplicate(phone ?? '');
    if (norm.isNotEmpty) {
      final dup = await _service.findByPhone(phone!);
      if (dup != null) {
        final action = await _showDuplicateDialog(dup.name);
        if (action == true) {
          final updated = await ContactEditSheet.show(existing: dup);
          if (updated != null) await updateContact(updated);
        }
        return;
      }
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
      HapticFeedback.selectionClick();
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to add contact');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateContact(Contact updated) async {
    isLoading.value = true;
    try {
      final norm = PhoneUtils.normalizeForDuplicate(updated.phone ?? '');
      if (norm.isNotEmpty) {
        final dup = await _service.findByPhone(updated.phone!);
        if (dup != null && dup.id != updated.id) {
          final action = await _showDuplicateDialog(
            dup.name,
            title: 'Phone already used',
          );
          if (action == true) {
            final updatedDup = await ContactEditSheet.show(existing: dup);
            if (updatedDup != null) await updateContact(updatedDup);
          }
          return;
        }
      }

      await _service.updateContact(updated);
      final index = contacts.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        contacts[index] = updated;
        contacts.refresh();
        _sortInPlace();
        _applyFilter();
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to update contact');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool?> _showDuplicateDialog(
    String existingName, {
    String title = 'Contact already exists',
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(
          'A contact with this phone number already exists: "$existingName".',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Update existing'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteContact(Contact contact) async {
    final id = contact.id;
    if (id == null) return;

    isLoading.value = true;
    try {
      await _service.deleteContact(id);
      contacts.removeWhere((c) => c.id == id);
      _applyFilter();
      HapticFeedback.lightImpact();
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
      HapticFeedback.selectionClick();
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

  Future<void> addDemoContacts({int count = 25}) async {
    isLoading.value = true;
    try {
      await _service.addDemoContacts(count: count);
      await loadContacts();
    } catch (e) {
      AppSnackbar.show('Error', 'Failed to add demo contacts');
    } finally {
      isLoading.value = false;
    }
  }

  void _sortInPlace() {
    final list = contacts.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    contacts.assignAll(list);
  }

  void _applyFilter() {
    visibleContacts.assignAll(_filterContacts(contacts));
  }

  Future<void> _applySearch() async {
    final token = ++_searchToken;
    final q = searchQuery.value.trim();

    isSearching.value = q.isNotEmpty;
    totalMatches.value = 0;

    if (q.isEmpty) {
      final results = _filterContacts(contacts);
      visibleContacts.assignAll(results);
      totalMatches.value = results.length;
      return;
    }

    try {
      // Page 1 only for now; architecture is ready for pagination.
      final results = await _service.getContactsPage(
        limit: 200,
        offset: 0,
        query: q,
      );
      if (token != _searchToken) return;
      final filteredResults = _filterContacts(results);
      visibleContacts.assignAll(filteredResults);
      totalMatches.value = filteredResults.length;
    } catch (_) {
      // Fallback to in-memory filter if DB query fails.
      final lower = q.toLowerCase();
      final results = contacts.where((c) {
        final name = c.name.toLowerCase();
        final phone = (c.phone ?? '').toLowerCase();
        final email = (c.email ?? '').toLowerCase();
        return name.contains(lower) ||
            phone.contains(lower) ||
            email.contains(lower);
      }).toList();
      if (token != _searchToken) return;
      final filteredResults = _filterContacts(results);
      visibleContacts.assignAll(filteredResults);
      totalMatches.value = filteredResults.length;
    }
  }

  List<Contact> _filterContacts(List<Contact> source) {
    switch (activeFilter.value) {
      case ContactFilter.all:
        return source;
      case ContactFilter.favorites:
        return source.where((c) => c.isFavorite).toList();
      case ContactFilter.hasPhone:
        return source.where((c) => (c.phone ?? '').trim().isNotEmpty).toList();
    }
  }
}
