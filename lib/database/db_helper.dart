import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    // Diganti ke v4 agar SQLite menghapus cache lama dan membentuk skema baru yang seimbang
    String path = join(await getDatabasesPath(), 'traya_final_v4.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. TABEL PENGGUNA
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            bio TEXT,
            link TEXT
          )
        ''');

        // 2. TABEL PRODUK PUBLIK
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ownerEmail TEXT NOT NULL,
            ownerName TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT NOT NULL,
            subCategory TEXT NOT NULL,
            price REAL NOT NULL,
            size TEXT DEFAULT 'M'
          )
        ''');

        // 3. TABEL RELASI GAMBAR PRODUK
        await db.execute('''
          CREATE TABLE product_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId INTEGER NOT NULL,
            imagePath TEXT NOT NULL,
            FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
          )
        ''');

        // 4. TABEL DRAF LOKAL PRIVAT
        await db.execute('''
          CREATE TABLE drafts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ownerEmail TEXT NOT NULL,
            ownerName TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            subCategory TEXT,
            price REAL,
            size TEXT DEFAULT 'M'
          )
        ''');

        // 5. TABEL RELASI GAMBAR DRAF
        await db.execute('''
          CREATE TABLE draft_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            draftId INTEGER NOT NULL,
            imagePath TEXT NOT NULL,
            FOREIGN KEY (draftId) REFERENCES drafts (id) ON DELETE CASCADE
          )
        ''');

        // 6. TABEL SELLER REKOMENDASI
        await db.execute('''
          CREATE TABLE sellers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            rating INTEGER DEFAULT 5
          )
        ''');

        // 7. TABEL FAVORIT USER
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userEmail TEXT NOT NULL,
            productId INTEGER NOT NULL,
            FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
          )
        ''');

        // 8. TABEL KERANJANG BELANJA
        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userEmail TEXT NOT NULL,
            productId INTEGER NOT NULL,
            quantity INTEGER DEFAULT 1
          )
        ''');

        // 9. TABEL NOTIFIKASI DINAMIS (BARU)
        await db.execute('''
          CREATE TABLE notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userEmail TEXT NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        // SUNTIK DATA AWAL DEMO
        await db.insert('users', {
          'name': 'Zen Owner', 'username': 'zen_owner', 'email': 'zen@traya.com', 'password': '123', 'bio': 'Thrift Enthusiast', 'link': 'zen.store'
        });
        await db.insert('users', {
          'name': 'Budi Seller', 'username': 'budi_thrift', 'email': 'budi@traya.com', 'password': '123', 'bio': 'Secondhand Branded', 'link': 'budi.store'
        });

        await db.insert('sellers', {'name': 'Jepstore', 'rating': 5});
        await db.insert('sellers', {'name': 'UINAGA Store', 'rating': 5});

        int pId = await db.insert('products', {
          'ownerEmail': 'budi@traya.com',
          'ownerName': 'Jepstore',
          'title': "Carhartt Vintage Hoodie Pink",
          'description': 'Bahan katun sangat tebal dan adem, kondisi mulus 9.5/10 like new.',
          'category': 'Pria',
          'subCategory': 'Jaket',
          'price': 250000.0,
          'size': 'M'
        });

        await db.insert('product_images', {
          'productId': pId,
          'imagePath': 'asset_dummy_jeans'
        });

        // Suntik Notifikasi Sambutan Awal
        await db.insert('notifications', {
          'userEmail': 'zen@traya.com',
          'title': 'Selamat Datang!',
          'message': 'Akun Anda berhasil terdaftar di TRaya Marketplace. Selamat berburu pakaian preloved!',
          'type': 'system',
          'createdAt': DateTime.now().toString().substring(0, 16)
        });
      },
    );
  }

  // --- LOGIKA QUERY USER ---
  Future<Map<String, dynamic>?> getSpecificUserProfile(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<int> updateUserProfile(Map<String, dynamic> data) async {
    Database db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [1]);
  }

  // --- LOGIKA QUERY LISTING PRODUK PUBLIK (MULTI IMAGE) ---
  Future<int> addProduct(Map<String, dynamic> productRow, List<String> images) async {
    Database db = await database;
    return await db.transaction((txn) async {
      int productId = await txn.insert('products', productRow);
      for (String path in images) {
        await txn.insert('product_images', {'productId': productId, 'imagePath': path});
      }
      return productId;
    });
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT p.*, (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p ORDER BY p.id DESC
    ''');
  }

  Future<List<String>> getProductImages(int productId) async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query('product_images', where: 'productId = ?', whereArgs: [productId]);
    return res.map((row) => row['imagePath'].toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getRecommendationProducts(int currentProductId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT p.*, (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p WHERE p.id != ? LIMIT 4
    ''', [currentProductId]);
  }

  // --- LOGIKA QUERY DRAF PRIVAT ---
  Future<int> addDraft(Map<String, dynamic> draftRow, List<String> images) async {
    Database db = await database;
    return await db.transaction((txn) async {
      int draftId = await txn.insert('drafts', draftRow);
      for (String path in images) {
        await txn.insert('draft_images', {'draftId': draftId, 'imagePath': path});
      }
      return draftId;
    });
  }

  Future<List<Map<String, dynamic>>> getAllDrafts(String email) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT d.*, (SELECT imagePath FROM draft_images WHERE draftId = d.id LIMIT 1) as thumbnail 
      FROM drafts d WHERE d.ownerEmail = ? ORDER BY d.id DESC
    ''', [email]);
  }

  Future<int> deleteDraft(int id) async {
    Database db = await database;
    return await db.delete('drafts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllSellers() async {
    Database db = await database;
    return await db.query('sellers');
  }

  // --- TAHAP PENCARIAN SINKRON ---
  Future<List<Map<String, dynamic>>> searchProducts(String keyword) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT p.*, (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p 
      WHERE p.title LIKE ? OR p.description LIKE ? OR p.category LIKE ?
      ORDER BY p.id DESC
    ''', ['%$keyword%', '%$keyword%', '%$keyword%']);
  }

  // --- LOGIKA UTAMA FITUR FAVORIT + TRIGGER NOTIFIKASI ---
  Future<int> toggleFavorite(String email, int productId) async {
    Database db = await database;
    List<Map<String, dynamic>> ada = await db.query('favorites', where: 'userEmail = ? AND productId = ?', whereArgs: [email, productId]);
    
    // Ambil nama barang untuk kelengkapan notifikasi
    List<Map<String, dynamic>> prod = await db.query('products', columns: ['title'], where: 'id = ?', whereArgs: [productId]);
    String pTitle = prod.isNotEmpty ? prod.first['title'] : "Produk";

    if (ada.isNotEmpty) {
      return await db.delete('favorites', where: 'userEmail = ? AND productId = ?', whereArgs: [email, productId]);
    } else {
      int id = await db.insert('favorites', {'userEmail': email, 'productId': productId});
      // TRIGGER: Suntik Notif Sukses Simpan Favorit
      await addNotification(
        email, 
        "Favorit Baru", 
        "Produk '$pTitle' berhasil ditambahkan ke daftar favorit Anda.", 
        "favorite"
      );
      return id;
    }
  }

  Future<bool> isProductFavorite(String email, int productId) async {
    Database db = await database;
    List<Map<String, dynamic>> ada = await db.query('favorites', where: 'userEmail = ? AND productId = ?', whereArgs: [email, productId]);
    return ada.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String email) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT p.*, (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM favorites f 
      JOIN products p ON f.productId = p.id 
      WHERE f.userEmail = ?
    ''', [email]);
  }

  // --- LOGIKA UTAMA FITUR KERANJANG + TRIGGER NOTIFIKASI ---
  Future<int> addToCart(String email, int productId) async {
    Database db = await database;
    List<Map<String, dynamic>> prod = await db.query('products', columns: ['title'], where: 'id = ?', whereArgs: [productId]);
    String pTitle = prod.isNotEmpty ? prod.first['title'] : "Produk";

    List<Map<String, dynamic>> ada = await db.query('cart', where: 'userEmail = ? AND productId = ?', whereArgs: [email, productId]);
    int result;
    if (ada.isNotEmpty) {
      result = await db.rawUpdate('UPDATE cart SET quantity = quantity + 1 WHERE userEmail = ? AND productId = ?', [email, productId]);
    } else {
      result = await db.insert('cart', {'userEmail': email, 'productId': productId, 'quantity': 1});
    }

    // TRIGGER: Suntik Notif Masuk Keranjang Belanja
    await addNotification(
      email, 
      "Keranjang Belanja", 
      "'$pTitle' berhasil masuk ke keranjang belanja. Yuk, segera lakukan checkout!", 
      "cart"
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getUserCart(String email) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT c.id as cartId, c.quantity, p.*, 
      (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM cart c 
      JOIN products p ON c.productId = p.id 
      WHERE c.userEmail = ?
    ''', [email]);
  }

  Future<int> removeFromCart(int cartId) async {
    Database db = await database;
    return await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<void> clearUserCart(String email) async {
    Database db = await database;
    await db.delete('cart', where: 'userEmail = ?', whereArgs: [email]);
  }

  // --- LOGIKA MANAJEMEN NOTIFIKASI (BARU) ---
  Future<int> addNotification(String email, String title, String message, String type) async {
    Database db = await database;
    return await db.insert('notifications', {
      'userEmail': email,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': DateTime.now().toString().substring(11, 16) // Hanya mengambil Jam:Menit (Cth: 13:45)
    });
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String email) async {
    Database db = await database;
    return await db.query('notifications', where: 'userEmail = ?', orderBy: 'id DESC');
  }
}