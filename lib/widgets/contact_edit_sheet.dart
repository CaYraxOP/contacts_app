import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/contacts_controller.dart';
import '../models/contact.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'contact_avatar.dart';

class ContactEditSheet {
  const ContactEditSheet._();

  static Future<Contact?> show({BuildContext? context, Contact? existing}) {
    final ctx = context ?? Get.context;
    if (ctx == null) return Future<Contact?>.value(null);
    return showModalBottomSheet<Contact?>(
      context: ctx,
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

  late final FocusNode nameFocus;
  late final FocusNode phoneFocus;
  late final FocusNode emailFocus;
  late final FocusNode companyFocus;
  late final FocusNode notesFocus;
  late final FocusNode imageFocus;

  late final ContactsController contactsController;

  String? nameError;
  String? phoneError;
  String? emailError;

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

    nameFocus = FocusNode();
    phoneFocus = FocusNode();
    emailFocus = FocusNode();
    companyFocus = FocusNode();
    notesFocus = FocusNode();
    imageFocus = FocusNode();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    companyCtrl.dispose();
    notesCtrl.dispose();
    imageCtrl.dispose();
    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    companyFocus.dispose();
    notesFocus.dispose();
    imageFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    if (!_validateForm()) {
      return;
    }

    final existing = widget.existing;
    if (existing == null) {
      Navigator.of(context).pop(
        Contact(
          name: name,
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          company: companyCtrl.text.trim().isEmpty
              ? null
              : companyCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          imagePath: imageCtrl.text.trim().isEmpty
              ? null
              : imageCtrl.text.trim(),
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
          company: companyCtrl.text.trim().isEmpty
              ? null
              : companyCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          imagePath: imageCtrl.text.trim().isEmpty
              ? null
              : imageCtrl.text.trim(),
        ),
      );
    }
  }

  bool _validateForm() {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();

    String? nextNameError;
    String? nextPhoneError;
    String? nextEmailError;

    if (name.isEmpty) {
      nextNameError = 'Name is required';
    }

    if (phone.isNotEmpty) {
      final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
      final validChars = RegExp(r'^[0-9+\-()\s]+$').hasMatch(phone);
      if (!validChars || digitsOnly.length < 7) {
        nextPhoneError = 'Enter a valid phone number';
      }
    }

    if (email.isNotEmpty) {
      final isValidEmail = RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      ).hasMatch(email);
      if (!isValidEmail) {
        nextEmailError = 'Enter a valid email address';
      }
    }

    setState(() {
      nameError = nextNameError;
      phoneError = nextPhoneError;
      emailError = nextEmailError;
    });

    if (nextNameError != null) {
      nameFocus.requestFocus();
      return false;
    }
    if (nextPhoneError != null) {
      phoneFocus.requestFocus();
      return false;
    }
    if (nextEmailError != null) {
      emailFocus.requestFocus();
      return false;
    }

    return true;
  }

  void _clearFieldError({
    bool name = false,
    bool phone = false,
    bool email = false,
  }) {
    if (!name && !phone && !email) return;
    final hasNoSelectedError =
        (!name || nameError == null) &&
        (!phone || phoneError == null) &&
        (!email || emailError == null);
    if (hasNoSelectedError) {
      return;
    }
    setState(() {
      if (name) nameError = null;
      if (phone) phoneError = null;
      if (email) emailError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final existing = widget.existing;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: bottom + 16,
      ),
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
              focusNode: nameFocus,
              labelText: 'Name',
              prefixIcon: Icons.person_outline,
              autofocus: existing == null,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              errorText: nameError,
              onChanged: (_) {
                _clearFieldError(name: true);
                setState(() {});
              },
              onSubmitted: (_) => phoneFocus.requestFocus(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: phoneCtrl,
              focusNode: phoneFocus,
              labelText: 'Phone',
              prefixIcon: Icons.call_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              errorText: phoneError,
              onChanged: (_) => _clearFieldError(phone: true),
              onSubmitted: (_) => emailFocus.requestFocus(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: emailCtrl,
              focusNode: emailFocus,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: emailError,
              onChanged: (_) => _clearFieldError(email: true),
              onSubmitted: (_) => companyFocus.requestFocus(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: companyCtrl,
              focusNode: companyFocus,
              labelText: 'Company',
              prefixIcon: Icons.business_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => notesFocus.requestFocus(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: notesCtrl,
              focusNode: notesFocus,
              labelText: 'Notes',
              prefixIcon: Icons.notes_outlined,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: imageCtrl,
              focusNode: imageFocus,
              labelText: 'Image path (optional)',
              prefixIcon: Icons.image_outlined,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
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
