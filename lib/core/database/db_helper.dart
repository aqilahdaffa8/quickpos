import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  // Singleton pattern
  static final DbHelper _instance = DbHelper._internal();
  static DbHelper get instance => _instance;
  DbHelper._internal();

  static Database? _database;

  // Konstanta Nama Tabel
  static const String tableCategories = 'categories';
  static const String tableProducts = 'products';
  static const String tableTransactions = 'transactions';
  static const String tableTransactionItems = 'transaction_items';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quickpos_enterprise.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  // MENGAKTIFKAN FOREIGN KEYS (Sangat krusial untuk integritas data)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // PEMBUATAN SKEMA TABEL
  Future<void> _onCreate(Database db, int version) async {
    // 1. Table Categories
    await db.execute('''
      CREATE TABLE $tableCategories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        icon_name TEXT, -- KOLOM BARU UNTUK NAMA IKON
        created_at TEXT
      )
    ''');

    // 2. Table Products (Relasi ke Categories)
    await db.execute('''
      CREATE TABLE $tableProducts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT,
        image_path TEXT, -- INI KOLOM BARU KITA
        purchase_price REAL,
        selling_price REAL,
        stock INTEGER,
        created_at TEXT,
        FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE RESTRICT
      )
    ''');

    // 3. Table Transactions
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_amount REAL NOT NULL,
        cash_amount REAL NOT NULL,
        change_amount REAL NOT NULL,
        transaction_date TEXT NOT NULL
      )
    ''');

    // 4. Table Transaction Items (Relasi ke Transactions & Products)
    await db.execute('''
      CREATE TABLE $tableTransactionItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES $tableTransactions (id) 
          ON DELETE CASCADE 
          ON UPDATE CASCADE,
        FOREIGN KEY (product_id) REFERENCES $tableProducts (id) 
          ON DELETE RESTRICT 
          ON UPDATE CASCADE
      )
    ''');

    // Opsional: Insert Data Kategori Default agar siap pakai
    await db.insert(tableCategories, {
      'name': 'Umum',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // --- RAW QUERY HELPERS (Untuk digunakan di Repository nanti) ---

  // Helper untuk Batch Transaction (Menyimpan transaksi kasir & item sekaligus)
  Future<void> executeBatchTransaction(Future<void> Function(Transaction txn) action) async {
    final db = await database;
    await db.transaction((txn) async {
      await action(txn);
    });
  }
}