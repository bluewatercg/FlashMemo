// 卡组模型
class Deck {
  final int? id;
  final String name;
  final String? description;
  final int? parentId; // 用于实现文件夹嵌套
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFolder; // 是否为文件夹
  final int sortOrder; // 排序序号

  const Deck({
    this.id,
    required this.name,
    this.description,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.isFolder = false,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_id': parentId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_folder': isFolder ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      parentId: map['parent_id']?.toInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isFolder: map['is_folder'] == 1,
      sortOrder: map['sort_order']?.toInt() ?? 0,
    );
  }

  Deck copyWith({
    int? id,
    String? name,
    String? description,
    int? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFolder,
    int? sortOrder,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFolder: isFolder ?? this.isFolder,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}