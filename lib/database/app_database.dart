import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/phone_utils.dart';
import 'db_schema.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbDir = await getDatabasesPath();
    final path = p.join(dbDir, AppConstants.dbName);

    AppLogger.d('Opening database at: $path');

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute(DbSchema.createContactsTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateV1ToV2(db);
        }
        if (oldVersion < 3) {
          await _migrateV2ToV3(db);
        }
      },
    );
  }

  Future<void> _migrateV1ToV2(Database db) async {
    // V1 table columns were: id, display_name, phone_number, email, photo_path.
    // V2 schema: name, phone, email, company, notes, image_path, is_favorite, created_at.
    await db.transaction((txn) async {
      await txn.execute('''
CREATE TABLE contacts_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  company TEXT,
  notes TEXT,
  image_path TEXT,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
)
''');

      final now = DateTime.now().millisecondsSinceEpoch;
      await txn.execute('''
INSERT INTO contacts_new (id, name, phone, email, image_path, is_favorite, created_at)
SELECT id, display_name, phone_number, email, photo_path, 0, $now
FROM ${DbSchema.contactsTable}
''');

      await txn.execute('DROP TABLE ${DbSchema.contactsTable}');
      await txn.execute(
        'ALTER TABLE contacts_new RENAME TO ${DbSchema.contactsTable}',
      );
    });
  }

  Future<void> _migrateV2ToV3(Database db) async {
    // Add phone_norm column for fast duplicate detection.
    await db.execute(
      'ALTER TABLE ${DbSchema.contactsTable} ADD COLUMN ${DbSchema.phoneNormColumn} TEXT',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contacts_phone_norm ON ${DbSchema.contactsTable}(${DbSchema.phoneNormColumn})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contacts_name ON ${DbSchema.contactsTable}(name)',
    );

    final rows = await db.query(
      DbSchema.contactsTable,
      columns: <String>['id', 'phone'],
    );
    for (final row in rows) {
      final id = row['id'] as int?;
      if (id == null) continue;
      final phone = row['phone'] as String? ?? '';
      final norm = PhoneUtils.normalizeForDuplicate(phone);
      await db.update(
        DbSchema.contactsTable,
        <String, Object?>{DbSchema.phoneNormColumn: norm.isEmpty ? null : norm},
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    }
  }

  Future<void> close() async {
    final db = _db;
    _db = null;
    await db?.close();
  }
}
