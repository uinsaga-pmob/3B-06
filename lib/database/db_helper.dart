import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  // Mendapatkan koneksi database, membuat jika belum ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Inisialisasi database lokal
  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'traya_final.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Buat Tabel Produk (Listing Aktif)
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ownerName TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            price REAL NOT NULL,
            size TEXT DEFAULT 'M',
            imagePath TEXT
          )
        ''');

        // 2. Buat Tabel Draf
        await db.execute('''
          CREATE TABLE drafts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ownerName TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            price REAL,
            size TEXT DEFAULT 'M',
            imagePath TEXT
          )
        ''');

        // 3. Buat Tabel Seller (Untuk Dummy di Beranda)
        await db.execute('''
          CREATE TABLE sellers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            iconPath TEXT,
            rating INTEGER DEFAULT 5
          )
        ''');

        // Suntikkan Dummy Seller Awal (Mockup beranda.png)
        await db.insert('sellers', {'name': 'Jepstore', 'iconPath': 'seller_1'});
        await db.insert('sellers', {'name': 'Jepstore', 'iconPath': 'seller_2'});
        await db.insert('sellers', {'name': 'Zen Owner', 'iconPath': 'seller_3'});
        await db.insert('sellers', {'name': 'UINAGA Store', 'iconPath': 'seller_4'});

        // Suntikkan Dummy Produk Awal (Mockup beranda.png)
        // Gunakan placeholder 'asset_dummy' untuk gambar tiruan
        for (int i = 0; i < 4; i++) {
          await db.insert('products', {
            'ownerName': 'Jepstore',
            'title': "Levis's 578 baggy jeans hitam",
            'description': 'Kondisi mulus, jarang dipakai.',
            'price': 250000.0,
            'category': 'Pants',
            'size': 'M',
            'imagePath': 'asset_dummy_jeans'
          });
        }
      },
    );
  }

  // --- Fungsi Query Tabel Produk (Listing) ---
  Future<int> addProduct(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('products', row);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    Database db = await database;
    return await db.query('products', orderBy: 'id DESC');
  }

  // --- Fungsi Query Tabel Draf ---
  Future<int> addDraft(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('drafts', row);
  }

  Future<List<Map<String, dynamic>>> getAllDrafts() async {
    Database db = await database;
    return await db.query('drafts', orderBy: 'id DESC');
  }

  Future<int> deleteDraft(int id) async {
    Database db = await database;
    return await db.delete('drafts', where: 'id = ?', whereArgs: [id]);
  }

  // --- Fungsi Query Tabel Seller ---
  Future<List<Map<String, dynamic>>> getAllSellers() async {
    Database db = await database;
    return await db.query('sellers');
  }
}