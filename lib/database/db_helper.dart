import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'traya_app.db');

    return await openDatabase(
      path,
      version: 4, // ← UBAH DARI 3 MENJADI 4
      onCreate: (db, version) async {
        // TABEL USERS
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          username TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          bio TEXT DEFAULT '',
          link TEXT DEFAULT '',
          avatar TEXT DEFAULT '',
          storeVacationMode INTEGER DEFAULT 0,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

        // TABEL PRODUCTS
        await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ownerEmail TEXT NOT NULL,
          ownerName TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          category TEXT,
          subCategory TEXT,
          price REAL NOT NULL,
          size TEXT DEFAULT 'M',
          condition TEXT DEFAULT 'Good',
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (ownerEmail) REFERENCES users (email) ON DELETE CASCADE
        )
      ''');

        // TABEL PRODUCT IMAGES
        await db.execute('''
        CREATE TABLE product_images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          imagePath TEXT NOT NULL,
          FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
        )
      ''');

        // TABEL FAVORITES
        await db.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userEmail TEXT NOT NULL,
          productId INTEGER NOT NULL,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(userEmail, productId),
          FOREIGN KEY (userEmail) REFERENCES users (email) ON DELETE CASCADE,
          FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
        )
      ''');

        // TABEL CART
        await db.execute('''
        CREATE TABLE cart (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userEmail TEXT NOT NULL,
          productId INTEGER NOT NULL,
          quantity INTEGER DEFAULT 1,
          isSelected INTEGER DEFAULT 1,
          FOREIGN KEY (userEmail) REFERENCES users (email) ON DELETE CASCADE,
          FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
        )
      ''');

        // TABEL NOTIFICATIONS
        await db.execute('''
        CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userEmail TEXT NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT DEFAULT 'system',
          isRead INTEGER DEFAULT 0,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (userEmail) REFERENCES users (email) ON DELETE CASCADE
        )
      ''');

        // TABEL DRAFTS
        await db.execute('''
        CREATE TABLE drafts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ownerEmail TEXT NOT NULL,
          ownerName TEXT NOT NULL,
          title TEXT,
          description TEXT,
          category TEXT,
          subCategory TEXT,
          price REAL,
          size TEXT DEFAULT 'M',
          FOREIGN KEY (ownerEmail) REFERENCES users (email) ON DELETE CASCADE
        )
      ''');

        // TABEL DRAFT IMAGES
        await db.execute('''
        CREATE TABLE draft_images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          draftId INTEGER NOT NULL,
          imagePath TEXT NOT NULL,
          FOREIGN KEY (draftId) REFERENCES drafts (id) ON DELETE CASCADE
        )
      ''');

        // TABEL CHAT MESSAGES
        await db.execute('''
        CREATE TABLE chat_messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fromEmail TEXT NOT NULL,
          toEmail TEXT NOT NULL,
          message TEXT NOT NULL,
          productId TEXT DEFAULT '',
          isRead INTEGER DEFAULT 0,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (fromEmail) REFERENCES users (email) ON DELETE CASCADE,
          FOREIGN KEY (toEmail) REFERENCES users (email) ON DELETE CASCADE
        )
      ''');

        // TABEL ORDERS
        await db.execute('''
        CREATE TABLE orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orderNumber TEXT NOT NULL UNIQUE,
          buyerEmail TEXT NOT NULL,
          sellerEmail TEXT NOT NULL,
          productId INTEGER NOT NULL,
          productTitle TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          total REAL NOT NULL,
          status TEXT DEFAULT 'pending',
          shippingAddress TEXT,
          buyerName TEXT,
          buyerPhone TEXT,
          thumbnail TEXT,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (buyerEmail) REFERENCES users (email) ON DELETE CASCADE,
          FOREIGN KEY (sellerEmail) REFERENCES users (email) ON DELETE CASCADE,
          FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
        )
      ''');

        // TABEL RECENTLY VIEWED
        await db.execute('''
        CREATE TABLE recently_viewed (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userEmail TEXT NOT NULL,
          productId INTEGER NOT NULL,
          viewedAt TEXT DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(userEmail, productId),
          FOREIGN KEY (userEmail) REFERENCES users (email) ON DELETE CASCADE,
          FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN storeVacationMode INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE cart ADD COLUMN isSelected INTEGER DEFAULT 1',
          );
        }

        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS chat_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fromEmail TEXT NOT NULL,
            toEmail TEXT NOT NULL,
            message TEXT NOT NULL,
            productId TEXT DEFAULT '',
            isRead INTEGER DEFAULT 0,
            createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (fromEmail) REFERENCES users (email) ON DELETE CASCADE,
            FOREIGN KEY (toEmail) REFERENCES users (email) ON DELETE CASCADE
          )
        ''');
          await db.execute('''
          CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderNumber TEXT NOT NULL UNIQUE,
            buyerEmail TEXT NOT NULL,
            sellerEmail TEXT NOT NULL,
            productId INTEGER NOT NULL,
            productTitle TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            total REAL NOT NULL,
            status TEXT DEFAULT 'pending',
            shippingAddress TEXT,
            buyerName TEXT,
            buyerPhone TEXT,
            createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (buyerEmail) REFERENCES users (email) ON DELETE CASCADE,
            FOREIGN KEY (sellerEmail) REFERENCES users (email) ON DELETE CASCADE,
            FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
          )
        ''');
          await db.execute('''
          CREATE TABLE IF NOT EXISTS recently_viewed (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userEmail TEXT NOT NULL,
            productId INTEGER NOT NULL,
            viewedAt TEXT DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(userEmail, productId),
            FOREIGN KEY (userEmail) REFERENCES users (email) ON DELETE CASCADE,
            FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
          )
        ''');
        }

        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE orders ADD COLUMN thumbnail TEXT');
            print('Successfully added thumbnail column to orders table');
          } catch (e) {
            print('Column thumbnail already exists or error: $e');
          }
        }
      },
    );
  }
  // ============ AUTHENTICATION METHODS ============

  Future<Map<String, dynamic>?> registerUser(
    Map<String, dynamic> userData,
  ) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> existing = await db.query(
        'users',
        where: 'email = ? OR username = ?',
        whereArgs: [userData['email'], userData['username']],
      );

      if (existing.isNotEmpty) {
        return null;
      }

      await db.insert('users', userData);
      Map<String, dynamic>? newUser = await getUserByEmail(userData['email']);
      return newUser;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginUser(
    String emailOrUsername,
    String password,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: '(email = ? OR username = ?) AND password = ?',
      whereArgs: [emailOrUsername, emailOrUsername, password],
    );

    if (result.isNotEmpty) {
      await addNotification(
        result.first['email'],
        'Login Berhasil',
        'Anda berhasil masuk ke akun TRaya',
        'success',
      );
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserProfile(
    String email,
    Map<String, dynamic> updatedData,
  ) async {
    Database db = await database;
    return await db.update(
      'users',
      updatedData,
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> updateUserAvatar(String email, String avatarPath) async {
    Database db = await database;
    return await db.update(
      'users',
      {'avatar': avatarPath},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> toggleVacationMode(String email, int isVacation) async {
    Database db = await database;
    return await db.update(
      'users',
      {'storeVacationMode': isVacation},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> getVacationMode(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['storeVacationMode'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? (result.first['storeVacationMode'] ?? 0) : 0;
  }

  // ============ PRODUCT METHODS ============

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT p.*, 
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p 
      ORDER BY p.id DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getProductsByUser(String email) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT p.*, 
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p 
      WHERE p.ownerEmail = ?
      ORDER BY p.id DESC
    ''',
      [email],
    );
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT p.*, 
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p 
      WHERE p.id = ?
    ''',
      [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> addProduct(
    Map<String, dynamic> productData,
    List<String> imagePaths,
  ) async {
    Database db = await database;
    return await db.transaction((txn) async {
      int productId = await txn.insert('products', productData);
      for (String path in imagePaths) {
        await txn.insert('product_images', {
          'productId': productId,
          'imagePath': path,
        });
      }
      return productId;
    });
  }

  Future<List<String>> getProductImages(int productId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'product_images',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return result.map((row) => row['imagePath'].toString()).toList();
  }

  Future<List<Map<String, dynamic>>> searchProducts(String keyword) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT p.*, 
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p 
      WHERE p.title LIKE ? OR p.description LIKE ? OR p.category LIKE ?
      ORDER BY p.id DESC
    ''',
      ['%$keyword%', '%$keyword%', '%$keyword%'],
    );
  }

  Future<List<Map<String, dynamic>>> getRecommendationProducts(
    int currentProductId,
  ) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT p.*, 
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM products p 
      WHERE p.id != ? 
      ORDER BY p.id DESC
      LIMIT 4
    ''',
      [currentProductId],
    );
  }

  // ============ FAVORITE METHODS ============

  Future<bool> toggleFavorite(String userEmail, int productId) async {
    Database db = await database;
    List<Map<String, dynamic>> existing = await db.query(
      'favorites',
      where: 'userEmail = ? AND productId = ?',
      whereArgs: [userEmail, productId],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'userEmail = ? AND productId = ?',
        whereArgs: [userEmail, productId],
      );
      return false;
    } else {
      await db.insert('favorites', {
        'userEmail': userEmail,
        'productId': productId,
      });
      return true;
    }
  }

  Future<bool> isProductFavorite(String userEmail, int productId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'favorites',
      where: 'userEmail = ? AND productId = ?',
      whereArgs: [userEmail, productId],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String userEmail) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT p.*, 
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail 
      FROM favorites f 
      JOIN products p ON f.productId = p.id 
      WHERE f.userEmail = ?
      ORDER BY f.createdAt DESC
    ''',
      [userEmail],
    );
  }

  Future<int> getUserFavoriteCount(String userEmail) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM favorites WHERE userEmail = ?',
      [userEmail],
    );
    return result.first['count'] as int;
  }

  // ============ CART METHODS ============

  Future<int> addToCart(
    String userEmail,
    int productId, {
    int quantity = 1,
  }) async {
    Database db = await database;
    List<Map<String, dynamic>> existing = await db.query(
      'cart',
      where: 'userEmail = ? AND productId = ?',
      whereArgs: [userEmail, productId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'cart',
        {'quantity': existing.first['quantity'] + quantity},
        where: 'userEmail = ? AND productId = ?',
        whereArgs: [userEmail, productId],
      );
    } else {
      return await db.insert('cart', {
        'userEmail': userEmail,
        'productId': productId,
        'quantity': quantity,
        'isSelected': 1,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUserCart(String userEmail) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT c.id as cartId, c.quantity, c.isSelected, p.*,
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail
      FROM cart c
      JOIN products p ON c.productId = p.id
      WHERE c.userEmail = ?
    ''',
      [userEmail],
    );
  }

  Future<int> updateCartSelection(int cartId, int isSelected) async {
    Database db = await database;
    return await db.update(
      'cart',
      {'isSelected': isSelected},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeFromCart(int cartId) async {
    Database db = await database;
    return await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<int> updateCartQuantity(int cartId, int newQuantity) async {
    Database db = await database;
    return await db.update(
      'cart',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<void> clearUserCart(String userEmail) async {
    Database db = await database;
    await db.delete('cart', where: 'userEmail = ?', whereArgs: [userEmail]);
  }

  Future<List<Map<String, dynamic>>> getSelectedCartItems(
    String userEmail,
  ) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT c.id as cartId, c.quantity, p.*,
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail
      FROM cart c
      JOIN products p ON c.productId = p.id
      WHERE c.userEmail = ? AND c.isSelected = 1
    ''',
      [userEmail],
    );
  }

  // ============ ORDER METHODS ============

  Future<String> createOrder({
    required String buyerEmail,
    required String sellerEmail,
    required int productId,
    required String productTitle,
    required int quantity,
    required double price,
    required double total,
    required String shippingAddress,
    required String buyerName,
    required String buyerPhone,
    String? thumbnail, // ← TAMBAHKAN PARAMETER INI
  }) async {
    Database db = await database;
    final orderNumber = 'TR${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('orders', {
      'orderNumber': orderNumber,
      'buyerEmail': buyerEmail,
      'sellerEmail': sellerEmail,
      'productId': productId,
      'productTitle': productTitle,
      'quantity': quantity,
      'price': price,
      'total': total,
      'status': 'pending',
      'shippingAddress': shippingAddress,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'thumbnail': thumbnail, // ← TAMBAHKAN BARIS INI
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Add notification to seller
    await addNotification(
      sellerEmail,
      'Pesanan Baru!',
      '$buyerName membeli produk $productTitle',
      'order',
    );

    return orderNumber;
  }

  Future<List<Map<String, dynamic>>> getUserOrders(
    String userEmail, {
    String? role = 'buyer',
  }) async {
    Database db = await database;

    // GANTI dengan query yang JOIN ke product_images
    if (role == 'buyer') {
      return await db.rawQuery(
        '''
        SELECT o.*, 
          (SELECT imagePath FROM product_images WHERE productId = o.productId LIMIT 1) as thumbnail
        FROM orders o
        WHERE o.buyerEmail = ?
        ORDER BY o.createdAt DESC
      ''',
        [userEmail],
      );
    } else {
      return await db.rawQuery(
        '''
        SELECT o.*, 
          (SELECT imagePath FROM product_images WHERE productId = o.productId LIMIT 1) as thumbnail
        FROM orders o
        WHERE o.sellerEmail = ?
        ORDER BY o.createdAt DESC
      ''',
        [userEmail],
      );
    }
  }

  Future<int> updateOrderStatus(String orderNumber, String status) async {
    Database db = await database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'orderNumber = ?',
      whereArgs: [orderNumber],
    );
  }

  // ============ RECENTLY VIEWED METHODS ============

  Future<void> addRecentlyViewed(String userEmail, int productId) async {
    Database db = await database;
    await db.insert('recently_viewed', {
      'userEmail': userEmail,
      'productId': productId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getRecentlyViewed(String userEmail) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT p.*,
        (SELECT imagePath FROM product_images WHERE productId = p.id LIMIT 1) as thumbnail
      FROM recently_viewed rv
      JOIN products p ON rv.productId = p.id
      WHERE rv.userEmail = ?
      ORDER BY rv.viewedAt DESC
      LIMIT 10
    ''',
      [userEmail],
    );
  }

  // ============ NOTIFICATION METHODS ============

  Future<int> addNotification(
    String userEmail,
    String title,
    String message,
    String type,
  ) async {
    Database db = await database;
    return await db.insert('notifications', {
      'userEmail': userEmail,
      'title': title,
      'message': message,
      'type': type,
      'isRead': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(
    String userEmail,
  ) async {
    Database db = await database;
    return await db.query(
      'notifications',
      where: 'userEmail = ?',
      orderBy: 'createdAt DESC',
      whereArgs: [userEmail],
    );
  }

  Future<int> markNotificationAsRead(int notificationId) async {
    Database db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<int> markAllNotificationsAsRead(String userEmail) async {
    Database db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'userEmail = ? AND isRead = 0',
      whereArgs: [userEmail],
    );
  }

  // ============ DRAFT METHODS ============

  Future<int> addDraft(
    Map<String, dynamic> draftData,
    List<String> imagePaths,
  ) async {
    Database db = await database;
    return await db.transaction((txn) async {
      int draftId = await txn.insert('drafts', draftData);
      for (String path in imagePaths) {
        await txn.insert('draft_images', {
          'draftId': draftId,
          'imagePath': path,
        });
      }
      return draftId;
    });
  }

  Future<List<Map<String, dynamic>>> getUserDrafts(String userEmail) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT d.*, 
        (SELECT imagePath FROM draft_images WHERE draftId = d.id LIMIT 1) as thumbnail 
      FROM drafts d 
      WHERE d.ownerEmail = ?
      ORDER BY d.id DESC
    ''',
      [userEmail],
    );
  }

  Future<int> deleteDraft(int draftId) async {
    Database db = await database;
    return await db.delete('drafts', where: 'id = ?', whereArgs: [draftId]);
  }

  // ============ STATISTICS METHODS ============

  Future<int> getUserProductCount(String userEmail) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE ownerEmail = ?',
      [userEmail],
    );
    return result.first['count'] as int;
  }

  Future<int> getUserSoldCount(String userEmail) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM orders WHERE sellerEmail = ? AND status = "completed"',
      [userEmail],
    );
    return result.first['count'] as int;
  }

  Future<int> getUserFollowerCount(String userEmail) async {
    // For now return 0, can be implemented later
    return 0;
  }

  // Hapus produk beserta gambarnya
  Future<int> deleteProduct(int productId) async {
    Database db = await database;
    // Gambar akan otomatis terhapus karena ON DELETE CASCADE
    return await db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }

  // Update produk
  Future<int> updateProduct(
    int productId,
    Map<String, dynamic> productData,
  ) async {
    Database db = await database;
    return await db.update(
      'products',
      productData,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Hapus gambar produk tertentu
  Future<void> deleteProductImage(int imageId) async {
    Database db = await database;
    await db.delete('product_images', where: 'id = ?', whereArgs: [imageId]);
  }

  // Tambah gambar ke produk
  Future<int> addProductImage(int productId, String imagePath) async {
    Database db = await database;
    return await db.insert('product_images', {
      'productId': productId,
      'imagePath': imagePath,
    });
  }
}
