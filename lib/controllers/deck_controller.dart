import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../services/deck_service.dart';

class DeckController extends ChangeNotifier {
  final DeckService _deckService = DeckService();
  
  List<Deck> _decks = [];
  bool _isLoading = false;
  String? _error;

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载所有卡组
  Future<void> loadDecks() async {
    _setLoading(true);
    try {
      _decks = await _deckService.getAllDecks();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _decks = [];
    } finally {
      _setLoading(false);
    }
  }

  // 创建卡组
  Future<bool> createDeck(Deck deck) async {
    try {
      final createdDeck = await _deckService.createDeck(deck);
      if (createdDeck != null) {
        _decks.add(createdDeck);
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

  // 更新卡组
  Future<bool> updateDeck(Deck deck) async {
    try {
      final success = await _deckService.updateDeck(deck);
      if (success) {
        final index = _decks.indexWhere((d) => d.id == deck.id);
        if (index != -1) {
          _decks[index] = deck;
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

  // 删除卡组
  Future<bool> deleteDeck(int deckId) async {
    try {
      final success = await _deckService.deleteDeck(deckId);
      if (success) {
        _decks.removeWhere((deck) => deck.id == deckId);
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

  // 根据ID获取卡组
  Deck? getDeckById(int id) {
    try {
      return _decks.firstWhere((deck) => deck.id == id);
    } catch (e) {
      return null;
    }
  }

  // 获取子卡组（文件夹内的卡组）
  List<Deck> getChildDecks(int? parentId) {
    return _decks.where((deck) => deck.parentId == parentId).toList();
  }

  // 获取根级卡组（没有父级的卡组）
  List<Deck> getRootDecks() {
    return getChildDecks(null);
  }

  // 搜索卡组
  List<Deck> searchDecks(String query) {
    if (query.isEmpty) return _decks;
    
    final lowerQuery = query.toLowerCase();
    return _decks.where((deck) {
      return deck.name.toLowerCase().contains(lowerQuery) ||
             (deck.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // 移动卡组到新的父级
  Future<bool> moveDeck(int deckId, int? newParentId) async {
    try {
      final deck = getDeckById(deckId);
      if (deck == null) return false;

      final updatedDeck = deck.copyWith(
        parentId: newParentId,
        updatedAt: DateTime.now(),
      );

      return await updateDeck(updatedDeck);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 复制卡组
  Future<bool> duplicateDeck(int deckId) async {
    try {
      final originalDeck = getDeckById(deckId);
      if (originalDeck == null) return false;

      final duplicatedDeck = Deck(
        name: '${originalDeck.name} (副本)',
        description: originalDeck.description,
        parentId: originalDeck.parentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFolder: originalDeck.isFolder,
      );

      return await createDeck(duplicatedDeck);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 获取卡组统计信息
  Future<Map<String, int>> getDeckStats(int deckId) async {
    try {
      return await _deckService.getDeckStats(deckId);
    } catch (e) {
      return {
        'totalCards': 0,
        'newCards': 0,
        'reviewCards': 0,
        'learnedCards': 0,
      };
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 私有方法：设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}