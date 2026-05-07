import '../database/app_database.dart';
import '../database/contacts_dao.dart';
import '../models/contact.dart';

class ContactsService {
  ContactsService(this._db, {ContactsDao? dao}) : _dao = dao ?? const ContactsDao();

  final AppDatabase _db;
  final ContactsDao _dao;

  Future<void> warmUp() async {
    // Opens the database so first real query later feels instant.
    await _db.database;
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await _db.database;
    return _dao.getAllContacts(db);
  }

  Future<int> insertContact(Contact contact) async {
    final db = await _db.database;
    return _dao.insertContact(db, contact);
  }

  Future<void> updateContact(Contact contact) async {
    final db = await _db.database;
    await _dao.updateContact(db, contact);
  }

  Future<void> deleteContact(int id) async {
    final db = await _db.database;
    await _dao.deleteContact(db, id);
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await _db.database;
    await _dao.toggleFavorite(db, id, isFavorite);
  }
}
