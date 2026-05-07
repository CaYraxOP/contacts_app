import 'package:sqflite/sqflite.dart';

import '../models/contact.dart';

class ContactsDao {
  const ContactsDao();

  Future<int> insertContact(Database db, Contact contact) async {
    return db.insert(
      'contacts',
      contact.toMap()..remove('id'),
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

  Future<int> updateContact(Database db, Contact contact) async {
    final id = contact.id;
    if (id == null) {
      throw StateError('Cannot update contact without id');
    }

    return db.update(
      'contacts',
      contact.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> deleteContact(Database db, int id) async {
    return db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> toggleFavorite(Database db, int id, bool isFavorite) async {
    return db.update(
      'contacts',
      <String, Object?>{'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}

