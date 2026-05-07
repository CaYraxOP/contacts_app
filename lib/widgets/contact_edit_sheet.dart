import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/contacts_controller.dart';
import '../core/utils/app_snackbar.dart';
import '../models/contact.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'contact_avatar.dart';

class ContactEditSheet {
  const ContactEditSheet._();

  static Future<Contact?> show({
    required BuildContext context,
    Contact? existing,
  }) {
    return showModalBottomSheet<Contact?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ContactEditSheetBody(existing: existing),
    );
  }
}

class _ContactEditSheetBody extends StatefulWidget {
  const _ContactEditSheetBody({this.existing});

  final Contact? existing;

  @override
  State<_ContactEditSheetBody> createState() => _ContactEditSheetBodyState();
}

class _ContactEditSheetBodyState extends State<_ContactEditSheetBody> {
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController companyCtrl;
  late final TextEditingController notesCtrl;
  late final TextEditingController imageCtrl;

  late final ContactsController contactsController;

  @override
  void initState() {
    super.initState();
    contactsController = Get.find<ContactsController>();

    final existing = widget.existing;
    nameCtrl = TextEditingController(text: existing?.name ?? '');
    phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    emailCtrl = TextEditingController(text: existing?.email ?? '');
    companyCtrl = TextEditingController(text: existing?.company ?? '');
    notesCtrl = TextEditingController(text: existing?.notes ?? '');
    imageCtrl = TextEditingController(text: existing?.imagePath ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    companyCtrl.dispose();
    notesCtrl.dispose();
    imageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      AppSnackbar.show('Missing name', 'Please enter a name');
      return;
    }

    final existing = widget.existing;
    if (existing == null) {
      Navigator.of(context).pop(
        Contact(
          name: name,
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          company: companyCtrl.text.trim().isEmpty ? null : companyCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          imagePath: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
          isFavorite: false,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      Navigator.of(context).pop(
        existing.copyWith(
          name: name,
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          company: companyCtrl.text.trim().isEmpty ? null : companyCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          imagePath: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final existing = widget.existing;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                ContactAvatar(
                  fallbackText: nameCtrl.text.isEmpty ? '?' : nameCtrl.text,
                  photoPath: imageCtrl.text,
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    existing == null ? 'New contact' : 'Edit contact',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Pick image',
                  onPressed: () async {
                    final path = await contactsController.pickImagePath();
                    if (!mounted || path == null) return;
                    setState(() => imageCtrl.text = path);
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: nameCtrl,
              labelText: 'Name',
              prefixIcon: Icons.person_outline,
              autofocus: existing == null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: phoneCtrl,
              labelText: 'Phone',
              prefixIcon: Icons.call_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: emailCtrl,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: companyCtrl,
              labelText: 'Company',
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: notesCtrl,
              labelText: 'Notes',
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: imageCtrl,
              labelText: 'Image path (optional)',
              prefixIcon: Icons.image_outlined,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: existing == null ? 'Add' : 'Save',
              onPressed: _submit,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

