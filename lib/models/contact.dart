class Contact {
  const Contact({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.company,
    this.notes,
    this.imagePath,
    this.isFavorite = false,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? company;
  final String? notes;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? company,
    String? notes,
    String? imagePath,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'notes': notes,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Contact.fromMap(Map<String, Object?> map) {
    return Contact(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      company: map['company'] as String?,
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int?) ?? 0,
      ),
    );
  }
}
