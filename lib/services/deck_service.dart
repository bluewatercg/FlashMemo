import 'package:sqflite/sqflite.dart';
import '../models/deck.dart';
import 'database_service.dart';

class DeckService {
  final DatabaseService _databaseService = DatabaseService.instance;

  // 获取所有卡组
  Future<List<Deck>> getAllDecks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'decks',
      orderBy: 'sort_order ASC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Deck.fromMap(maps[i]);
    });
  }

  // 根据ID获取卡组
  Future<Deck?> getDeckById(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Deck.fromMap(maps.first);
    }
    return null;
  }

  // 根据父级ID获取子卡组
  Future<List<Deck>> getChildDecks(int? parentId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'decks',
      where: parentId == null ? 'parent_id IS NULL' : 'parent_id = ?',
      whereArgs: parentId == null ? null : [parentId],
      orderBy: 'sort_order ASC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Deck.fromMap(maps[i]);
    });
  }

  // 创建卡组
  Future<Deck?> createDeck(Deck deck) async {
    final db = await _databaseService.database;
    try {
      final id = await db.insert(
        'decks',
        deck.toMap()..remove('id'), // 移除id，让数据库自动生成
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      return deck.copyWith(id: id);
    } catch (e) {
      throw Exception('创建卡组失败: $e');
    }
  }

  // 更新卡组
  Future<bool> updateDeck(Deck deck) async {
    final db = await _databaseService.database;
    try {
      final count = await db.update(
        'decks',
        deck.toMap(),
        where: 'id = ?',
        whereArgs: [deck.id],
      );
      
      return count > 0;
    } catch (e) {
      throw Exception('更新卡组失败: $e');
    }
  }

  // 删除卡组
  Future<bool> deleteDeck(int id) async {
    final db = await _databaseService.database;
    try {
      // 开始事务
      await db.transaction((txn) async {
        // 首先删除卡组下的所有卡片内容
        await txn.rawDelete('''
          DELETE FROM card_contents 
          WHERE card_id IN (
            SELECT id FROM cards WHERE deck_id = ?
          )
        ''', [id]);

        // 删除卡片标签关联
        await txn.rawDelete('''
          DELETE FROM card_tags 
          WHERE card_id IN (
            SELECT id FROM cards WHERE deck_id = ?
          )
        ''', [id]);

        // 删除卡片
        await txn.delete(
          'cards',
          where: 'deck_id = ?',
          whereArgs: [id],
        );

        // 递归删除子卡组
        await _deleteChildDecks(txn, id);

        // 最后删除卡组本身
        await txn.delete(
          'decks',
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      return true;
    } catch (e) {
      throw Exception('删除卡组失败: $e');
    }
  }

  // 递归删除子卡组的私有方法
  Future<void> _deleteChildDecks(Transaction txn, int parentId) async {
    final childDecks = await txn.query(
      'decks',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );

    for (final child in childDecks) {
      final childId = child['id'] as int;
      
      // 递归删除子卡组的子卡组
      await _deleteChildDecks(txn, childId);

      // 删除该子卡组下的所有卡片内容
      await txn.rawDelete('''
        DELETE FROM card_contents 
        WHERE card_id IN (
          SELECT id FROM cards WHERE deck_id = ?
        )
      ''', [childId]);

      // 删除卡片标签关联
      await txn.rawDelete('''
        DELETE FROM card_tags 
        WHERE card_id IN (
          SELECT id FROM cards WHERE deck_id = ?
        )
      ''', [childId]);

      // 删除卡片
      await txn.delete(
        'cards',
        where: 'deck_id = ?',
        whereArgs: [childId],
      );

      // 删除子卡组
      await txn.delete(
        'decks',
        where: 'id = ?',
        whereArgs: [childId],
      );
    }
  }

  // 搜索卡组
  Future<List<Deck>> searchDecks(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'decks',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Deck.fromMap(maps[i]);
    });
  }

  // 移动卡组到新的父级
  Future<bool> moveDeck(int deckId, int? newParentId) async {
    final db = await _databaseService.database;
    try {
      // 检查是否会创建循环引用
      if (newParentId != null && await _wouldCreateCycle(deckId, newParentId)) {
        throw Exception('无法移动：会创建循环引用');
      }

      final count = await db.update(
        'decks',
        {
          'parent_id': newParentId,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [deckId],
      );

      return count > 0;
    } catch (e) {
      throw Exception('移动卡组失败: $e');
    }
  }

  // 检查是否会创建循环引用的私有方法
  Future<bool> _wouldCreateCycle(int deckId, int targetParentId) async {
    final db = await _databaseService.database;
    int? currentId = targetParentId;

    while (currentId != null) {
      if (currentId == deckId) {
        return true; // 发现循环
      }

      final result = await db.query(
        'decks',
        columns: ['parent_id'],
        where: 'id = ?',
        whereArgs: [currentId],
        limit: 1,
      );

      if (result.isEmpty) {
        break;
      }

      currentId = result.first['parent_id'] as int?;
    }

    return false;
  }

  // 更新卡组排序
  Future<bool> updateDeckOrder(List<int> deckIds) async {
    final db = await _databaseService.database;
    try {
      await db.transaction((txn) async {
        for (int i = 0; i < deckIds.length; i++) {
          await txn.update(
            'decks',
            {
              'sort_order': i,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'id = ?',
            whereArgs: [deckIds[i]],
          );
        }
      });

      return true;
    } catch (e) {
      throw Exception('更新排序失败: $e');
    }
  }

  // 获取卡组统计信息
  Future<Map<String, int>> getDeckStats(int deckId) async {
    final db = await _databaseService.database;
    
    try {
      // 总卡片数
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ?',
        [deckId],
      );
      final totalCards = totalResult.first['count'] as int;

      // 新卡片数（从未学习过的）
      final newResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ? AND review_count = 0',
        [deckId],
      );
      final newCards = newResult.first['count'] as int;

      // 需要复习的卡片数
      final now = DateTime.now().millisecondsSinceEpoch;
      final reviewResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ? AND next_review_due <= ? AND review_count > 0',
        [deckId, now],
      );
      final reviewCards = reviewResult.first['count'] as int;

      // 已学会的卡片数（复习间隔大于30天）
      final learnedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cards WHERE deck_id = ? AND interval >= 30',
        [deckId],
      );
      final learnedCards = learnedResult.first['count'] as int;

      return {
        'totalCards': totalCards,
        'newCards': newCards,
        'reviewCards': reviewCards,
        'learnedCards': learnedCards,
      };
    } catch (e) {
      throw Exception('获取统计信息失败: $e');
    }
  }

  // 导出卡组数据
  Future<Map<String, dynamic>> exportDeck(int deckId) async {
    final db = await _databaseService.database;
    
    try {
      // 获取卡组信息
      final deck = await getDeckById(deckId);
      if (deck == null) {
        throw Exception('卡组不存在');
      }

      // 获取卡组下的所有卡片
      final cards = await db.query(
        'cards',
        where: 'deck_id = ?',
        whereArgs: [deckId],
      );

      // 获取所有卡片内容
      final cardContents = await db.rawQuery('''
        SELECT cc.* FROM card_contents cc
        INNER JOIN cards c ON cc.card_id = c.id
        WHERE c.deck_id = ?
      ''', [deckId]);

      // 获取所有卡片标签
      final cardTags = await db.rawQuery('''
        SELECT ct.card_id, t.name as tag_name FROM card_tags ct
        INNER JOIN tags t ON ct.tag_id = t.id
        INNER JOIN cards c ON ct.card_id = c.id
        WHERE c.deck_id = ?
      ''', [deckId]);

      return {
        'deck': deck.toMap(),
        'cards': cards,
        'cardContents': cardContents,
        'cardTags': cardTags,
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      throw Exception('导出卡组失败: $e');
    }
  }

  // 导入卡组数据
  Future<bool> importDeck(Map<String, dynamic> data) async {
    final db = await _databaseService.database;
    
    try {
      await db.transaction((txn) async {
        // 创建卡组
        final deckData = data['deck'] as Map<String, dynamic>;
        deckData.remove('id'); // 移除原ID，让数据库生成新ID
        deckData['created_at'] = DateTime.now().millisecondsSinceEpoch;
        deckData['updated_at'] = DateTime.now().millisecondsSinceEpoch;
        
        final newDeckId = await txn.insert('decks', deckData);

        // 导入卡片
        final cards = data['cards'] as List<dynamic>;
        final cardContents = data['cardContents'] as List<dynamic>;
        final cardTags = data['cardTags'] as List<dynamic>;

        final Map<int, int> cardIdMapping = {}; // 原ID到新ID的映射

        for (final cardData in cards) {
          final originalCardId = cardData['id'];
          cardData.remove('id');
          cardData['deck_id'] = newDeckId;
          cardData['created_at'] = DateTime.now().millisecondsSinceEpoch;
          cardData['updated_at'] = DateTime.now().millisecondsSinceEpoch;
          
          final newCardId = await txn.insert('cards', cardData);
          cardIdMapping[originalCardId] = newCardId;
        }

        // 导入卡片内容
        for (final contentData in cardContents) {
          final originalCardId = contentData['card_id'];
          contentData.remove('id');
          contentData['card_id'] = cardIdMapping[originalCardId];
          
          await txn.insert('card_contents', contentData);
        }

        // 导入标签和卡片标签关联
        final Map<String, int> tagNameToId = {};
        
        for (final tagData in cardTags) {
          final tagName = tagData['tag_name'];
          final originalCardId = tagData['card_id'];
          final newCardId = cardIdMapping[originalCardId];

          // 获取或创建标签
          int tagId;
          if (tagNameToId.containsKey(tagName)) {
            tagId = tagNameToId[tagName]!;
          } else {
            final existingTag = await txn.query(
              'tags',
              where: 'name = ?',
              whereArgs: [tagName],
              limit: 1,
            );

            if (existingTag.isNotEmpty) {
              tagId = existingTag.first['id'] as int;
            } else {
              tagId = await txn.insert('tags', {
                'name': tagName,
                'created_at': DateTime.now().millisecondsSinceEpoch,
              });
            }
            tagNameToId[tagName] = tagId;
          }

          // 创建卡片标签关联
          await txn.insert('card_tags', {
            'card_id': newCardId,
            'tag_id': tagId,
          });
        }
      });

      return true;
    } catch (e) {
      throw Exception('导入卡组失败: $e');
    }
  }
}