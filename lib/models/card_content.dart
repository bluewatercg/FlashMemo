// 卡片内容模型
class CardContent {
  final int? id;
  final int cardId;
  final String side; // 'front' 或 'back'
  final String content; // HTML格式的富文本内容
  final String? plainText; // 纯文本内容（用于搜索）

  const CardContent({
    this.id,
    required this.cardId,
    required this.side,
    required this.content,
    this.plainText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'side': side,
      'content': content,
      'plain_text': plainText,
    };
  }

  factory CardContent.fromMap(Map<String, dynamic> map) {
    return CardContent(
      id: map['id']?.toInt(),
      cardId: map['card_id']?.toInt() ?? 0,
      side: map['side'] ?? '',
      content: map['content'] ?? '',
      plainText: map['plain_text'],
    );
  }

  CardContent copyWith({
    int? id,
    int? cardId,
    String? side,
    String? content,
    String? plainText,
  }) {
    return CardContent(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      side: side ?? this.side,
      content: content ?? this.content,
      plainText: plainText ?? this.plainText,
    );
  }
}

// 标签模型
class Tag {
  final int? id;
  final String name;
  final String? color; // 标签颜色
  final DateTime createdAt;

  const Tag({
    this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      color: map['color'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Tag copyWith({
    int? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// 卡片标签关联模型
class CardTag {
  final int cardId;
  final int tagId;

  const CardTag({
    required this.cardId,
    required this.tagId,
  });

  Map<String, dynamic> toMap() {
    return {
      'card_id': cardId,
      'tag_id': tagId,
    };
  }

  factory CardTag.fromMap(Map<String, dynamic> map) {
    return CardTag(
      cardId: map['card_id']?.toInt() ?? 0,
      tagId: map['tag_id']?.toInt() ?? 0,
    );
  }
}