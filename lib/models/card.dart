// 卡片模型
class Card {
  final int? id;
  final int deckId;
  final String templateType; // 'basic', 'cloze', 'image' 等
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastReviewed; // 最后复习时间
  final int reviewCount; // 复习次数
  final double easeFactor; // 记忆强度因子
  final int interval; // 复习间隔天数
  final int? nextReviewDue; // 下次复习时间戳

  const Card({
    this.id,
    required this.deckId,
    this.templateType = 'basic',
    required this.createdAt,
    required this.updatedAt,
    this.lastReviewed,
    this.reviewCount = 0,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.nextReviewDue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'template_type': templateType,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'last_reviewed': lastReviewed?.millisecondsSinceEpoch,
      'review_count': reviewCount,
      'ease_factor': easeFactor,
      'interval': interval,
      'next_review_due': nextReviewDue,
    };
  }

  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id']?.toInt(),
      deckId: map['deck_id']?.toInt() ?? 0,
      templateType: map['template_type'] ?? 'basic',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      lastReviewed: map['last_reviewed'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_reviewed'])
          : null,
      reviewCount: map['review_count']?.toInt() ?? 0,
      easeFactor: map['ease_factor']?.toDouble() ?? 2.5,
      interval: map['interval']?.toInt() ?? 1,
      nextReviewDue: map['next_review_due']?.toInt(),
    );
  }

  Card copyWith({
    int? id,
    int? deckId,
    String? templateType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastReviewed,
    int? reviewCount,
    double? easeFactor,
    int? interval,
    int? nextReviewDue,
  }) {
    return Card(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      templateType: templateType ?? this.templateType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReviewDue: nextReviewDue ?? this.nextReviewDue,
    );
  }
}