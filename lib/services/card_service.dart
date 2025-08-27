import 'package:sqflite/sqflite.dart';
import '../models/card.dart';
import '../models/card_content.dart';
import 'database_service.dart';

class CardService {
  final DatabaseService _databaseService = DatabaseService.instance;

  // 获取指定卡组的所有卡片
  Future<List<Card>> getCardsByDeck(int deckId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  // 获取所有卡片
  Future<List<Card>> getAllCards() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  // 根据ID获取卡片
  Future<Card?> getCardById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Card.fromMap(maps.first);
    }
    return null;
  }

  // 创建卡片
  Future<Card?> createCard(Card card, Map<String, String> contents, List<String> tagNames) async {
    final db = await _databaseService.database;
    
    try {
      late int cardId;
      
      await db.transaction((txn) async {
        // 插入卡片
        cardId = await txn.insert(
          'cards',
          card.toMap()..remove('id'),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // 插入卡片内容
        for (final entry in contents.entries) {
          final content = CardContent(
            cardId: cardId,
            side: entry.key,
            content: entry.value,
            plainText: _stripHtml(entry.value), // 提取纯文本用于搜索
          );
          
          await txn.insert('card_contents', content.toMap()..remove('id'));
        }

        // 处理标签
        await _processCardTags(txn, cardId, tagNames);
      });

      return card.copyWith(id: cardId);
    } catch (e) {
      throw Exception('创建卡片失败: $e');
    }
  }

  // 更新卡片
  Future<bool> updateCard(Card card, Map<String, String> contents, List<String> tagNames) async {
    final db = await _databaseService.database;
    
    try {
      await db.transaction((txn) async {
        // 更新卡片基本信息
        await txn.update(
          'cards',
          card.toMap(),
          where: 'id = ?',
          whereArgs: [card.id],
        );

        // 删除现有内容
        await txn.delete(
          'card_contents',
          where: 'card_id = ?',
          whereArgs: [card.id],
        );

        // 插入新内容
        for (final entry in contents.entries) {
          final content = CardContent(
            cardId: card.id!,
            side: entry.key,
            content: entry.value,
            plainText: _stripHtml(entry.value),
          );
          
          await txn.insert('card_contents', content.toMap()..remove('id'));
        }

        // 处理标签
        await _processCardTags(txn, card.id!, tagNames);
      });

      return true;
    } catch (e) {
      throw Exception('更新卡片失败: $e');
    }
  }

  // 删除卡片
  Future<bool> deleteCard(int cardId) async {
    final db = await _databaseService.database;
    
    try {
      await db.transaction((txn) async {
        // 删除卡片内容
        await txn.delete(
          'card_contents',
          where: 'card_id = ?',
          whereArgs: [cardId],
        );

        // 删除卡片标签关联
        await txn.delete(
          'card_tags',
          where: 'card_id = ?',
          whereArgs: [cardId],
        );

        // 删除卡片
        await txn.delete(
          'cards',
          where: 'id = ?',
          whereArgs: [cardId],
        );
      });

      return true;
    } catch (e) {
      throw Exception('删除卡片失败: $e');
    }
  }

  // 获取卡片内容
  Future<Map<String, String>> getCardContents(int cardId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'card_contents',
      where: 'card_id = ?',
      whereArgs: [cardId],
    );

    final Map<String, String> contents = {};
    for (final map in maps) {
      contents[map['side']] = map['content'];
    }

    return contents;
  }

  // 获取卡片内容对象列表
  Future<List<CardContent>> getCardContentsByCardId(int cardId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'card_contents',
      where: 'card_id = ?',
      whereArgs: [cardId],
    );

    return List.generate(maps.length, (i) {
      return CardContent.fromMap(maps[i]);
    });
  }

  // 获取卡片标签
  Future<List<String>> getCardTags(int cardId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.name FROM tags t
      INNER JOIN card_tags ct ON t.id = ct.tag_id
      WHERE ct.card_id = ?
    ''', [cardId]);

    return maps.map((map) => map['name'] as String).toList();
  }

  // 根据标签获取卡片
  Future<List<Card>> getCardsByTags(List<String> tagNames) async {
    if (tagNames.isEmpty) return [];

    final db = await _databaseService.database;
    final placeholders = tagNames.map((_) => '?').join(',');
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT c.* FROM cards c
      INNER JOIN card_tags ct ON c.id = ct.card_id
      INNER JOIN tags t ON ct.tag_id = t.id
      WHERE t.name IN ($placeholders)
    ''', tagNames);

    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  // 获取需要复习的卡片
  Future<List<Card>> getCardsForReview() async {
    final db = await _databaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'next_review_due <= ? AND review_count > 0',
      whereArgs: [now],
      orderBy: 'next_review_due ASC',
    );

    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  // 获取新卡片
  Future<List<Card>> getNewCards(int limit) async {
    final db = await _databaseService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'review_count = 0',
      orderBy: 'created_at ASC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  // 更新复习结果（间隔重复算法）
  Future<bool> updateReviewResult(int cardId, int difficulty) async {
    final db = await _databaseService.database;
    
    try {
      final card = await getCardById(cardId);
      if (card == null) return false;

      final now = DateTime.now();
      final newReviewCount = card.reviewCount + 1;
      
      // 简化的间隔重复算法
      double newEaseFactor = card.easeFactor;
      int newInterval = card.interval;

      switch (difficulty) {
        case 1: // 很难
          newEaseFactor = (card.easeFactor - 0.2).clamp(1.3, 2.5);
          newInterval = 1;
          break;
        case 2: // 难
          newEaseFactor = (card.easeFactor - 0.15).clamp(1.3, 2.5);
          newInterval = (card.interval * 1.2).round();
          break;
        case 3: // 好
          newInterval = (card.interval * card.easeFactor).round();
          break;
        case 4: // 很好
          newEaseFactor = card.easeFactor + 0.1;
          newInterval = (card.interval * card.easeFactor * 1.3).round();
          break;
        default:
          newInterval = (card.interval * card.easeFactor).round();
      }

      final nextReviewDue = now.add(Duration(days: newInterval)).millisecondsSinceEpoch;

      final updatedCard = card.copyWith(
        lastReviewed: now,
        reviewCount: newReviewCount,
        easeFactor: newEaseFactor,
        interval: newInterval,
        nextReviewDue: nextReviewDue,
        updatedAt: now,
      );

      final count = await db.update(
        'cards',
        updatedCard.toMap(),
        where: 'id = ?',
        whereArgs: [cardId],
      );

      return count > 0;
    } catch (e) {
      throw Exception('更新复习结果失败: $e');
    }
  }

  // 批量更新标签
  Future<bool> batchUpdateTags(List<int> cardIds, List<String> tagNames) async {
    final db = await _databaseService.database;
    
    try {
      await db.transaction((txn) async {
        for (final cardId in cardIds) {
          await _processCardTags(txn, cardId, tagNames);
        }
      });

      return true;
    } catch (e) {
      throw Exception('批量更新标签失败: $e');
    }
  }

  // 批量移动卡片
  Future<bool> batchMoveCards(List<int> cardIds, int newDeckId) async {
    final db = await _databaseService.database;
    
    try {
      final placeholders = cardIds.map((_) => '?').join(',');
      final arguments = [...cardIds, newDeckId, DateTime.now().millisecondsSinceEpoch];
      
      await db.rawUpdate('''
        UPDATE cards 
        SET deck_id = ?, updated_at = ?
        WHERE id IN ($placeholders)
      ''', [newDeckId, DateTime.now().millisecondsSinceEpoch, ...cardIds]);

      return true;
    } catch (e) {
      throw Exception('批量移动卡片失败: $e');
    }
  }

  // 批量删除卡片
  Future<bool> batchDeleteCards(List<int> cardIds) async {
    final db = await _databaseService.database;
    
    try {
      await db.transaction((txn) async {
        final placeholders = cardIds.map((_) => '?').join(',');
        
        // 删除卡片内容
        await txn.rawDelete('''
          DELETE FROM card_contents 
          WHERE card_id IN ($placeholders)
        ''', cardIds);

        // 删除卡片标签关联
        await txn.rawDelete('''
          DELETE FROM card_tags 
          WHERE card_id IN ($placeholders)
        ''', cardIds);

        // 删除卡片
        await txn.rawDelete('''
          DELETE FROM cards 
          WHERE id IN ($placeholders)
        ''', cardIds);
      });

      return true;
    } catch (e) {
      throw Exception('批量删除卡片失败: $e');
    }
  }

  // 搜索卡片
  Future<List<Card>> searchCards(String query, int? deckId) async {
    final db = await _databaseService.database;
    
    String whereClause = '''
      c.id IN (
        SELECT DISTINCT cc.card_id FROM card_contents cc
        WHERE cc.plain_text LIKE ?
      )
    ''';
    
    List<dynamic> whereArgs = ['%$query%'];

    if (deckId != null) {
      whereClause += ' AND c.deck_id = ?';
      whereArgs.add(deckId);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.* FROM cards c
      WHERE $whereClause
      ORDER BY c.updated_at DESC
    ''', whereArgs);

    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  // 获取所有标签
  Future<List<Tag>> getAllTags() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  // 创建标签
  Future<Tag?> createTag(Tag tag) async {
    final db = await _databaseService.database;
    
    try {
      final id = await db.insert(
        'tags',
        tag.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      return tag.copyWith(id: id);
    } catch (e) {
      // 如果标签已存在，返回现有标签
      final existing = await db.query(
        'tags',
        where: 'name = ?',
        whereArgs: [tag.name],
        limit: 1,
      );
      
      if (existing.isNotEmpty) {
        return Tag.fromMap(existing.first);
      }
      
      throw Exception('创建标签失败: $e');
    }
  }

  // 获取卡片统计信息
  Future<Map<String, int>> getCardStats(int deckId) async {
    final db = await _databaseService.database;
    
    try {
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ?',
        [deckId],
      );
      final total = totalResult.first['count'] as int;

      final newResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ? AND review_count = 0',
        [deckId],
      );
      final newCards = newResult.first['count'] as int;

      final learningResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ? AND review_count > 0 AND interval < 21',
        [deckId],
      );
      final learning = learningResult.first['count'] as int;

      final now = DateTime.now().millisecondsSinceEpoch;
      final reviewResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ? AND next_review_due <= ? AND review_count > 0',
        [deckId, now],
      );
      final review = reviewResult.first['count'] as int;

      final masteredResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ? AND interval >= 21',
        [deckId],
      );
      final mastered = masteredResult.first['count'] as int;

      return {
        'total': total,
        'new': newCards,
        'learning': learning,
        'review': review,
        'mastered': mastered,
      };
    } catch (e) {
      throw Exception('获取统计信息失败: $e');
    }
  }

  // 私有方法：处理卡片标签
  Future<void> _processCardTags(Transaction txn, int cardId, List<String> tagNames) async {
    // 删除现有的标签关联
    await txn.delete(
      'card_tags',
      where: 'card_id = ?',
      whereArgs: [cardId],
    );

    // 添加新的标签关联
    for (final tagName in tagNames) {
      if (tagName.trim().isEmpty) continue;

      // 查找或创建标签
      var tagResult = await txn.query(
        'tags',
        where: 'name = ?',
        whereArgs: [tagName.trim()],
        limit: 1,
      );

      int tagId;
      if (tagResult.isEmpty) {
        // 创建新标签
        tagId = await txn.insert('tags', {
          'name': tagName.trim(),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        tagId = tagResult.first['id'] as int;
      }

      // 创建卡片标签关联
      await txn.insert('card_tags', {
        'card_id': cardId,
        'tag_id': tagId,
      });
    }
  }

  // 私有方法：去除HTML标签，提取纯文本
  String _stripHtml(String html) {
    final RegExp htmlTagRegExp = RegExp(r'<[^>]*>');
    return html.replaceAll(htmlTagRegExp, '').trim();
  }
}