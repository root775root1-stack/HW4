class PropertyModel {
  PropertyModel({
    this.id,
    required this.name,
    this.description,
    this.address,
    this.floors = 1,
    this.notes,
    this.isActive = true,
  });

  final int? id;
  final String name;
  final String? description;
  final String? address;
  final int floors;
  final String? notes;
  final bool isActive;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        'address': address,
        'floors': floors,
        'notes': notes,
        'is_active': isActive ? 1 : 0,
      };

  factory PropertyModel.fromMap(Map<String, Object?> m) => PropertyModel(
        id: m['id'] as int?,
        name: m['name'] as String,
        description: m['description'] as String?,
        address: m['address'] as String?,
        floors: (m['floors'] as int?) ?? 1,
        notes: m['notes'] as String?,
        isActive: (m['is_active'] as int? ?? 1) == 1,
      );
}