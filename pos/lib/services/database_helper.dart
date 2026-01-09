import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Offline Sales Queue
    await db.execute('''
      CREATE TABLE offline_sales (
        id TEXT PRIMARY KEY,
        saleData TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Sync Queue for general operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        collection TEXT NOT NULL,
        documentId TEXT,
        data TEXT NOT NULL,
        attempts INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Cached Products
    await db.execute('''
      CREATE TABLE cached_products (
        id TEXT PRIMARY KEY,
        productData TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');
  }

  // ===== OFFLINE SALES =====
  
  Future<int> insertOfflineSale(String id, String saleData) async {
    final db = await database;
    return await db.insert('offline_sales', {
      'id': id,
      'saleData': saleData,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSales() async {
    final db = await database;
    return await db.query(
      'offline_sales',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  Future<int> markSaleAsSynced(String id) async {
    final db = await database;
    return await db.update(
      'offline_sales',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPendingSalesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM offline_sales WHERE synced = 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ===== SYNC QUEUE =====

  Future<int> addToSyncQueue(String operation, String collection, String documentId, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'operation': operation,
      'collection': collection,
      'documentId': documentId,
      'data': jsonEncode(data),
      'attempts': 0,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'createdAt ASC');
  }

  Future<int> removeFromSyncQueue(int id) async {
    final db = await database;
    return await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> incrementSyncAttempt(int id) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?',
      [id],
    );
  }

  // ===== PRODUCT CACHE =====

  Future<int> cacheProduct(String id, Map<String, dynamic> productData) async {
    final db = await database;
    return await db.insert(
      'cached_products',
      {
        'id': id,
        'productData': jsonEncode(productData),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCachedProducts() async {
    final db = await database;
    final results = await db.query('cached_products');
    return results.map((row) {
      return jsonDecode(row['productData'] as String) as Map<String, dynamic>;
    }).toList();
  }

  // ===== UTILITIES =====

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('offline_sales');
    await db.delete('sync_queue');
    await db.delete('cached_products');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
