import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/card_content.dart';
import '../services/card_service.dart';

class CardController extends ChangeNotifier {
  final CardService _cardService = CardService();
  
  List<Card> _cards = [];
  List<CardContent> _cardContents = [];
  List<Tag> _tags = [];
  bool _isLoading = false;
  String? _error;

  List<Card> get cards => _cards;
  List<CardContent> get cardContents => _cardContents;
  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载指定卡组的所有卡片
  Future<void> loadCardsByDeck(int deckId) async {
    _setLoading(true);
    try {
      _cards = await _cardService.getCardsByDeck(deckId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _cards = [];
    } finally {
      _setLoading(false);
    }
  }

  // 加载所有卡片
  Future<void> loadAllCards() async {
    _setLoading(true);
    try {
      _cards = await _cardService.getAllCards();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _cards = [];
    } finally {
      _setLoading(false);
    }
  }

  // 创建卡片
  Future<bool> createCard(Card card, Map<String, String> contents, List<String> tagNames) async {
    try {
      final createdCard = await _cardService.createCard(card, contents, tagNames);
      if (createdCard != null) {
        _cards.add(createdCard);
        await _loadCardContents(createdCard.id!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 更新卡片
  Future<bool> updateCard(Card card, Map<String, String> contents, List<String> tagNames) async {
    try {
      final success = await _cardService.updateCard(card, contents, tagNames);
      if (success) {
        final index = _cards.indexWhere((c) => c.id == card.id);
        if (index != -1) {
          _cards[index] = card;
          await _loadCardContents(card.id!);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 删除卡片
  Future<bool> deleteCard(int cardId) async {
    try {
      final success = await _cardService.deleteCard(cardId);
      if (success) {
        _cards.removeWhere((card) => card.id == cardId);
        _cardContents.removeWhere((content) => content.cardId == cardId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 根据ID获取卡片
  Card? getCardById(int id) {
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  // 获取卡片内容
  Future<Map<String, String>> getCardContents(int cardId) async {
    try {
      return await _cardService.getCardContents(cardId);
    } catch (e) {
      return {};
    }
  }

  // 获取卡片标签
  Future<List<String>> getCardTags(int cardId) async {
    try {
      return await _cardService.getCardTags(cardId);
    } catch (e) {
      return [];
    }
  }

  // 搜索卡片
  List<Card> searchCards(String query) {
    if (query.isEmpty) return _cards;
    
    final lowerQuery = query.toLowerCase();
    return _cards.where((card) {
      // 这里可以扩展搜索卡片内容
      return true; // 简化实现，后续可以搜索内容
    }).toList();
  }

  // 根据标签筛选卡片
  Future<List<Card>> filterCardsByTags(List<String> tagNames) async {
    try {
      return await _cardService.getCardsByTags(tagNames);
    } catch (e) {
      return [];
    }
  }

  // 获取需要复习的卡片
  Future<List<Card>> getCardsForReview() async {
    try {
      return await _cardService.getCardsForReview();
    } catch (e) {
      return [];
    }
  }

  // 获取新卡片
  Future<List<Card>> getNewCards(int limit) async {
    try {
      return await _cardService.getNewCards(limit);
    } catch (e) {
      return [];
    }
  }

  // 更新复习结果
  Future<bool> updateReviewResult(int cardId, int difficulty) async {
    try {
      final success = await _cardService.updateReviewResult(cardId, difficulty);
      if (success) {
        // 更新本地卡片数据
        final index = _cards.indexWhere((c) => c.id == cardId);
        if (index != -1) {
          final updatedCard = await _cardService.getCardById(cardId);
          if (updatedCard != null) {
            _cards[index] = updatedCard;
            notifyListeners();
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 移动卡片到其他卡组
  Future<bool> moveCard(int cardId, int newDeckId) async {
    try {
      final card = getCardById(cardId);
      if (card == null) return false;

      final updatedCard = card.copyWith(
        deckId: newDeckId,
        updatedAt: DateTime.now(),
      );

      final success = await _cardService.updateCard(updatedCard, {}, []);
      if (success) {
        final index = _cards.indexWhere((c) => c.id == cardId);
        if (index != -1) {
          _cards[index] = updatedCard;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 复制卡片
  Future<bool> duplicateCard(int cardId) async {
    try {
      final originalCard = getCardById(cardId);
      if (originalCard == null) return false;

      final contents = await getCardContents(cardId);
      final tags = await getCardTags(cardId);

      final duplicatedCard = Card(
        deckId: originalCard.deckId,
        templateType: originalCard.templateType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createCard(duplicatedCard, contents, tags);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 批量操作
  Future<bool> batchUpdateTags(List<int> cardIds, List<String> tagNames) async {
    try {
      final success = await _cardService.batchUpdateTags(cardIds, tagNames);
      if (success) {
        // 重新加载卡片数据
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchMoveCards(List<int> cardIds, int newDeckId) async {
    try {
      final success = await _cardService.batchMoveCards(cardIds, newDeckId);
      if (success) {
        // 更新本地数据
        for (final cardId in cardIds) {
          final index = _cards.indexWhere((c) => c.id == cardId);
          if (index != -1) {
            _cards[index] = _cards[index].copyWith(
              deckId: newDeckId,
              updatedAt: DateTime.now(),
            );
          }
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchDeleteCards(List<int> cardIds) async {
    try {
      final success = await _cardService.batchDeleteCards(cardIds);
      if (success) {
        _cards.removeWhere((card) => cardIds.contains(card.id));
        _cardContents.removeWhere((content) => cardIds.contains(content.cardId));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 标签管理
  Future<void> loadAllTags() async {
    try {
      _tags = await _cardService.getAllTags();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createTag(Tag tag) async {
    try {
      final createdTag = await _cardService.createTag(tag);
      if (createdTag != null) {
        _tags.add(createdTag);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 获取卡片统计信息
  Future<Map<String, int>> getCardStats(int deckId) async {
    try {
      return await _cardService.getCardStats(deckId);
    } catch (e) {
      return {
        'total': 0,
        'new': 0,
        'learning': 0,
        'review': 0,
        'mastered': 0,
      };
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadCardContents(int cardId) async {
    try {
      final contents = await _cardService.getCardContentsByCardId(cardId);
      // 移除旧的内容
      _cardContents.removeWhere((content) => content.cardId == cardId);
      // 添加新的内容
      _cardContents.addAll(contents);
    } catch (e) {
      // 忽略错误
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}