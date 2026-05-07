class DbSchema {
  const DbSchema._();

  static const String contactsTable = 'contacts';

  // Keep schema definitions centralized so migrations stay manageable.
  static const String createContactsTableSql = '''
CREATE TABLE $contactsTable (
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
''';
}
