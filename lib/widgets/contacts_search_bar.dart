import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/contacts_controller.dart';
import '../core/theme/app_radii.dart';
import '../core/theme/app_spacing.dart';

class ContactsSearchBar extends StatefulWidget {
  const ContactsSearchBar({super.key});

  @override
  State<ContactsSearchBar> createState() => _ContactsSearchBarState();
}

class _ContactsSearchBarState extends State<ContactsSearchBar> {
  late final ContactsController contactsController;
  late final TextEditingController textController;
  Worker? _syncWorker;

  @override
  void initState() {
    super.initState();
    contactsController = Get.find<ContactsController>();
    textController = TextEditingController(
      text: contactsController.searchQuery.value,
    );

    textController.addListener(() {
      final next = textController.text;
      if (contactsController.searchQuery.value != next) {
        contactsController.setSearchQuery(next);
      }
      if (mounted) setState(() {});
    });

    _syncWorker = ever<String>(contactsController.searchQuery, (q) {
      if (textController.text == q) return;
      textController.value = TextEditingValue(
        text: q,
        selection: TextSelection.collapsed(offset: q.length),
      );
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _syncWorker?.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = textController.text.trim().isNotEmpty;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: AppRadii.lg,
      child: SearchBar(
        controller: textController,
        hintText: 'Search name, phone, or email',
        leading: const Icon(Icons.search),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        ),
        backgroundColor: WidgetStatePropertyAll<Color>(
          theme.colorScheme.surfaceContainerHighest,
        ),
        elevation: const WidgetStatePropertyAll<double>(0),
        trailing: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: hasText
                ? IconButton(
                    key: const ValueKey('clear'),
                    tooltip: 'Clear',
                    onPressed: () {
                      textController.clear();
                      contactsController.clearSearch();
                    },
                    icon: const Icon(Icons.close),
                  )
                : const SizedBox(key: ValueKey('empty'), width: 0, height: 0),
          ),
        ],
      ),
    );
  }
}
