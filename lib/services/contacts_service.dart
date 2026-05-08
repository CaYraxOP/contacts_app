import '../database/app_database.dart';
import '../database/contacts_dao.dart';
import '../core/utils/phone_utils.dart';
import '../models/contact.dart';

class ContactsService {
  ContactsService(this._db, {ContactsDao? dao})
    : _dao = dao ?? const ContactsDao();

  final AppDatabase _db;
  final ContactsDao _dao;

  Future<void> warmUp() async {
    // Opens the database so first real query later feels instant.
    await _db.database;
  }

  Future<void> seedDemoContactsIfEmpty({int count = 25}) async {
    final db = await _db.database;
    final existing = await _dao.getAllContacts(db);
    if (existing.isNotEmpty) return;

    await addDemoContacts(count: count);
  }

  Future<void> addDemoContacts({int count = 25}) async {
    final db = await _db.database;

    final firstNames = <String>[
      'Aarav',
      'Ishita',
      'Rohan',
      'Neha',
      'Kabir',
      'Ananya',
      'Vihaan',
      'Meera',
      'Arjun',
      'Saanvi',
      'Rahul',
      'Priya',
      'Aditya',
      'Kavya',
      'Siddharth',
      'Nisha',
      'Dev',
      'Pooja',
      'Karan',
      'Riya',
    ];
    final lastNames = <String>[
      'Sharma',
      'Patel',
      'Gupta',
      'Singh',
      'Khan',
      'Iyer',
      'Mehta',
      'Nair',
      'Chopra',
      'Joshi',
    ];
    final companies = <String>[
      'Acme Labs',
      'Nimbus Tech',
      'BluePeak',
      'OrbitWorks',
      'PixelNest',
      'Kite Systems',
    ];

    final batch = db.batch();
    final now = DateTime.now();

    for (var i = 0; i < count; i++) {
      final first = firstNames[i % firstNames.length];
      final last = lastNames[(i + now.millisecond) % lastNames.length];
      final name = '$first $last';

      final phoneSeed = (now.millisecondsSinceEpoch ~/ 1000) % 100000;
      final phone =
          '9${(900000000 + phoneSeed + i).toString().padLeft(9, '0')}';

      final email =
          '${first.toLowerCase()}.${last.toLowerCase()}${(phoneSeed + i) % 99}@example.com';
      final company = companies[i % companies.length];

      final contact = Contact(
        name: name,
        phone: phone,
        email: email,
        company: company,
        notes: i % 4 == 0 ? 'Met at a meetup. Follow up next week.' : null,
        imagePath: null,
        isFavorite: i % 6 == 0,
        createdAt: now.subtract(Duration(days: i)),
      );

      batch.insert(
        'contacts',
        (contact.toMap()..remove('id'))
          ..['phone_norm'] = PhoneUtils.normalizeForDuplicate(
            contact.phone ?? '',
          ),
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await _db.database;
    return _dao.getAllContacts(db);
  }

  Future<List<Contact>> getContactsPage({
    required int limit,
    required int offset,
    String? query,
  }) async {
    final db = await _db.database;
    return _dao.getContactsPage(db, limit: limit, offset: offset, query: query);
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

  Future<Contact?> findByPhone(String phoneNumber) async {
    final db = await _db.database;
    return _dao.findByPhone(db, phoneNumber);
  }
}
