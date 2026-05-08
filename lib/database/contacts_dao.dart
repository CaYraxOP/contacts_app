import 'package:sqflite/sqflite.dart';

import '../core/utils/phone_utils.dart';
import '../models/contact.dart';

class ContactsDao {
  const ContactsDao();

  Map<String, Object?> _toDbMap(Contact contact) {
    final map = contact.toMap()..remove('id');
    final phone = (map['phone'] as String?) ?? '';
    map['phone_norm'] = PhoneUtils.normalizeForDuplicate(phone);
    return map;
  }

  Future<int> insertContact(Database db, Contact contact) async {
    return db.insert(
      'contacts',
      _toDbMap(contact),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contact>> getAllContacts(Database db) async {
    final rows = await db.query(
      'contacts',
      orderBy: 'name COLLATE NOCASE ASC, created_at DESC',
    );
    return rows.map((e) => Contact.fromMap(e)).toList();
  }

  Future<List<Contact>> getContactsPage(
    Database db, {
    required int limit,
    required int offset,
    String? query,
  }) async {
    final q = (query ?? '').trim();
    if (q.isEmpty) {
      final rows = await db.query(
        'contacts',
        orderBy: 'name COLLATE NOCASE ASC, created_at DESC',
        limit: limit,
        offset: offset,
      );
      return rows.map((e) => Contact.fromMap(e)).toList();
    }

    final like = '%${q.toLowerCase()}%';
    final rows = await db.query(
      'contacts',
      where: 'LOWER(name) LIKE ? OR LOWER(phone) LIKE ? OR LOWER(email) LIKE ?',
      whereArgs: <Object?>[like, like, like],
      orderBy: 'name COLLATE NOCASE ASC, created_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((e) => Contact.fromMap(e)).toList();
  }

  Future<int> updateContact(Database db, Contact contact) async {
    final id = contact.id;
    if (id == null) {
      throw StateError('Cannot update contact without id');
    }

    return db.update(
      'contacts',
      _toDbMap(contact),
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> deleteContact(Database db, int id) async {
    return db.delete('contacts', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<int> toggleFavorite(Database db, int id, bool isFavorite) async {
    return db.update(
      'contacts',
      <String, Object?>{'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<Contact?> findByPhone(Database db, String phoneNumber) async {
    final norm = PhoneUtils.normalizeForDuplicate(phoneNumber);
    if (norm.isEmpty) return null;

    final rows = await db.query(
      'contacts',
      where: 'phone_norm = ?',
      whereArgs: <Object?>[norm],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Contact.fromMap(rows.first);
  }
}
