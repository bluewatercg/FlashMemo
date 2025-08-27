import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/deck.dart';
import '../models/card.dart';
import '../models/card_content.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  static Database? _database;
  
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashmemo.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // 创建卡组表
    await db.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        parent_id INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_folder INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (parent_id) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');

    // 创建卡片表
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL,
        template_type TEXT NOT NULL DEFAULT 'basic',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_reviewed INTEGER,
        review_count INTEGER NOT NULL DEFAULT 0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        interval INTEGER NOT NULL DEFAULT 1,
        next_review_due INTEGER,
        FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');

    // 创建卡片内容表
    await db.execute('''
      CREATE TABLE card_contents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL,
        side TEXT NOT NULL,
        content TEXT NOT NULL,
        plain_text TEXT,
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');

    // 创建标签表
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // 创建卡片标签关联表
    await db.execute('''
      CREATE TABLE card_tags (
        card_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (card_id, tag_id),
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // 创建同步表（用于离线同步）
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        data TEXT,
        created_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 创建索引以提升查询性能
    await db.execute('CREATE INDEX idx_cards_deck_id ON cards(deck_id)');
    await db.execute('CREATE INDEX idx_cards_next_review ON cards(next_review_due)');
    await db.execute('CREATE INDEX idx_card_contents_card_id ON card_contents(card_id)');
    await db.execute('CREATE INDEX idx_card_tags_card_id ON card_tags(card_id)');
    await db.execute('CREATE INDEX idx_card_tags_tag_id ON card_tags(tag_id)');
    await db.execute('CREATE INDEX idx_decks_parent_id ON decks(parent_id)');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // 处理数据库升级逻辑
    if (oldVersion < 2) {
      // 添加新的列或表
      // await db.execute('ALTER TABLE cards ADD COLUMN new_column TEXT');
    }
  }

  Future<void> init() async {
    await database;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // 获取数据库统计信息
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    
    final deckCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM decks WHERE is_folder = 0'));
    final cardCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM cards'));
    final tagCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM tags'));
    
    return {
      'decks': deckCount ?? 0,
      'cards': cardCount ?? 0,
      'tags': tagCount ?? 0,
    };
  }

  // 清空数据库（用于重置应用）
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('card_tags');
    await db.delete('card_contents');
    await db.delete('cards');
    await db.delete('tags');
    await db.delete('decks');
    await db.delete('sync_queue');
  }
}