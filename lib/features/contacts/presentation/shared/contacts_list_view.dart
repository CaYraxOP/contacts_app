import 'package:contacts_app/models/contact.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/contact_list_tile.dart';
import '../../../../widgets/contact_section_header.dart';
import '../../../../widgets/swipe_actions.dart';
import 'confirm_delete_contact_dialog.dart';

class ContactsListView extends StatefulWidget {
  const ContactsListView({
    super.key,
    required this.contacts,
    required this.onTapContact,
    required this.onToggleFavorite,
    required this.onDelete,
    this.listKey,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 16),
  });

  final List<Contact> contacts;
  final EdgeInsets padding;
  final Key? listKey;
  final void Function(Contact contact) onTapContact;
  final Future<void> Function(Contact contact) onToggleFavorite;
  final Future<void> Function(Contact contact) onDelete;

  @override
  State<ContactsListView> createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView> {
  static const double _tileHeight = 82;
  static const double _headerHeight = 38;

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries(widget.contacts);

    return ListView.builder(
      key: widget.listKey ?? ValueKey<int>(widget.contacts.length),
      itemCount: entries.length,
      padding: widget.padding,
      cacheExtent: 900,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.letter != null) {
          return SizedBox(
            height: _headerHeight,
            child: ContactSectionHeader(title: entry.letter!),
          );
        }

        final contact = entry.contact!;
        return SizedBox(
          height: _tileHeight,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: index == entries.length - 1 ? 0 : 10,
            ),
            child: Dismissible(
              key: ValueKey<String>('c_${contact.id ?? contact.name}'),
              background: SwipeActions.favorite(context),
              secondaryBackground: SwipeActions.delete(context),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  await widget.onToggleFavorite(contact);
                  return false;
                }
                if (direction == DismissDirection.endToStart) {
                  return ConfirmDeleteContactDialog.show(
                    context,
                    contact: contact,
                  );
                }
                return false;
              },
              onDismissed: (_) => widget.onDelete(contact),
              child: ContactListTile(
                contact: contact,
                onTap: () => widget.onTapContact(contact),
                onToggleFavorite: () => widget.onToggleFavorite(contact),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_ContactListEntry> _buildEntries(List<Contact> contacts) {
    final entries = <_ContactListEntry>[];
    String? currentLetter;

    for (final contact in contacts) {
      final nextLetter = _sectionLetter(contact.name);
      if (nextLetter != currentLetter) {
        entries.add(_ContactListEntry.header(nextLetter));
        currentLetter = nextLetter;
      }
      entries.add(_ContactListEntry.contact(contact));
    }

    return entries;
  }

  String _sectionLetter(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    final first = trimmed.substring(0, 1).toUpperCase();
    final code = first.codeUnitAt(0);
    return code >= 65 && code <= 90 ? first : '#';
  }
}

class _ContactListEntry {
  const _ContactListEntry._({this.contact, this.letter});

  factory _ContactListEntry.contact(Contact contact) {
    return _ContactListEntry._(contact: contact);
  }

  factory _ContactListEntry.header(String letter) {
    return _ContactListEntry._(letter: letter);
  }

  final Contact? contact;
  final String? letter;
}
