import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/chat_bundle.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/views/main_navigation.dart';
import 'package:APK_TRAYA/components.dart';
import 'dart:io';

// ======================== SCREEN 1: DETAIL PRODUK ========================
class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  const ProductDetailScreen({super.key, required this.productData});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DbHelper _dbHelper = DbHelper();
  final SessionManager _session = SessionManager();
  bool _isFav = false;
  int _currentImageIndex = 0;
  List<String> _productImages = [];
  bool _isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _checkFavStatus();
    _loadProductImages();
    _addToRecentlyViewed();
  }

  Future<void> _addToRecentlyViewed() async {
    if (_session.isLoggedIn && _session.currentUserEmail != null) {
      await _dbHelper.addRecentlyViewed(_session.currentUserEmail!, widget.productData['id']);
    }
  }

  Future<void> _loadProductImages() async {
    setState(() => _isLoadingImages = true);
    final images = await _dbHelper.getProductImages(widget.productData['id']);
    setState(() {
      _productImages = images;
      _isLoadingImages = false;
    });
  }

  Future<void> _checkFavStatus() async {
    if (_session.isLoggedIn && _session.currentUserEmail != null) {
      bool fav = await _dbHelper.isProductFavorite(
        _session.currentUserEmail!, 
        widget.productData['id']
      );
      if (mounted) {
        setState(() => _isFav = fav);
      }
    }
  }

  Future<void> _toggleFav() async {
    if (!_session.isLoggedIn) {
      _showLoginRequired();
      return;
    }
    
    await _dbHelper.toggleFavorite(_session.currentUserEmail!, widget.productData['id']);
    _checkFavStatus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFav ? "Dihapus dari Favorit" : "Ditambahkan ke Favorit"),
        backgroundColor: _isFav ? Colors.red : Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Login Diperlukan"),
        content: const Text("Silakan login terlebih dahulu untuk menggunakan fitur ini"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: orangeTraya),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart() async {
    if (!_session.isLoggedIn) {
      _showLoginRequired();
      return;
    }
    
    // Check if seller is on vacation mode
    final vacationMode = await _dbHelper.getVacationMode(widget.productData['ownerEmail']);
    if (vacationMode == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Toko sedang libur, tidak dapat menambahkan ke keranjang"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    await _dbHelper.addToCart(_session.currentUserEmail!, widget.productData['id']);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produk ditambahkan ke keranjang"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _chatWithSeller() {
    if (!_session.isLoggedIn) {
      _showLoginRequired();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          partnerEmail: widget.productData['ownerEmail'],
          partnerName: widget.productData['ownerName'] ?? 'Penjual',
          productId: widget.productData['id'].toString(),
          productTitle: widget.productData['title'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.productData;
    final priceStr = (item['price'] as num).toStringAsFixed(0);
    final bool isMyOwnProduct = _session.isLoggedIn && 
        (_session.currentUserEmail == item['ownerEmail']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Detail Produk",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () => _showShareOptions(),
          ),
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.red,
            ),
            onPressed: _toggleFav,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: brownTraya),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rp $priceStr",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: brownTraya,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildConditionChip(item['condition'] ?? 'Baik'),
                  const Divider(height: 30),
                  _buildSellerInfo(),
                  const Divider(height: 30),
                  _buildDescription(),
                  const SizedBox(height: 30),
                  _buildRecommendations(),
                ],
              ),
            ),
          ],
        ),
      ),
 bottomNavigationBar: Container(
      padding: const EdgeInsets.all(16),
      child: isMyOwnProduct
          ? const Text("Ini adalah produk Anda sendiri")
          : Row(
              children: [
                // 🟢 TOMBOL "Chat Penjual" - SUDAH ADA, TIDAK PERUBAH
                Expanded(
                  child: OutlinedButton(
                    onPressed: _chatWithSeller,  // ← Panggil fungsi ini
                    child: const Text("Chat Penjual"),
                  ),
                ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeTraya,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _addToCart,
                      child: const Text(
                        "Beli Sekarang",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (_isLoadingImages) {
      return Container(
        height: 320,
        width: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_productImages.isEmpty) {
      return Container(
        height: 320,
        width: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.image, size: 80, color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 320,
          width: double.infinity,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              final imagePath = _productImages[index];
              return Container(
                color: const Color(0xFFF5F5F5),
                child: imagePath.startsWith('assets/')
                    ? Image.asset(imagePath, fit: BoxFit.contain)
                    : File(imagePath).existsSync()
                        ? Image.file(File(imagePath), fit: BoxFit.contain)
                        : const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              );
            },
          ),
        ),
        if (_productImages.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _productImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index ? orangeTraya : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConditionChip(String condition) {
    Color chipColor;
    switch (condition) {
      case 'Baru dengan Tag':
        chipColor = Colors.green;
        break;
      case 'Seperti Baru':
        chipColor = Colors.blue;
        break;
      case 'Sangat Baik':
        chipColor = Colors.teal;
        break;
      default:
        chipColor = Colors.orange;
    }
    
    return Chip(
      label: Text(condition),
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildSellerInfo() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _dbHelper.getUserByEmail(widget.productData['ownerEmail']),
      builder: (context, snapshot) {
        final seller = snapshot.data;
        final vacationMode = seller?['storeVacationMode'] ?? 0;
        
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfileScreen(
                  ownerEmail: widget.productData['ownerEmail'],
                  ownerName: widget.productData['ownerName'],
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFFF0EA),
                child: Text(
                  (widget.productData['ownerName'] ?? 'P').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brownTraya),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.productData['ownerName'] ?? 'Penjual TRaya',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (vacationMode == 1)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Libur",
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const Text(
                      "Lihat Toko >",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Deskripsi Produk",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          widget.productData['description'] ?? 'Tidak ada deskripsi.',
          style: const TextStyle(color: Colors.black87, height: 1.4),
        ),
        if (widget.productData['size'] != null && widget.productData['size'].toString().isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.straighten, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Ukuran: ${widget.productData['size']}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
        if (widget.productData['category'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Kategori: ${widget.productData['category']}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ],
    );
  }

Widget _buildRecommendations() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _dbHelper.getRecommendationProducts(widget.productData['id']),
    builder: (context, snapshot) {
      print('Recommendation data: ${snapshot.data}');
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const SizedBox.shrink();
      }
      
      final recs = snapshot.data!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rekomendasi Produk Lainnya",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220, // Tinggi tetap untuk horizontal scroll
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: recs.length,
              itemBuilder: (context, index) {
                final recItem = recs[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildRecommendationCard(recItem),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildRecommendationImage(String imagePath) {
  // Kasus 1: Tidak ada path gambar
  if (imagePath.isEmpty) {
    return const Center(
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }
  
  // Kasus 2: Gambar dari asset
  if (imagePath.startsWith('assets/')) {
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        );
      },
    );
  }
  
  // Kasus 3: Gambar dari file lokal
  final file = File(imagePath);
  if (file.existsSync()) {
    return Image.file(
      file,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        );
      },
    );
  }
  
  // Kasus 4: Path tidak valid
  return const Center(
    child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
  );
}

Widget _buildRecommendationCard(Map<String, dynamic> item) {
  final priceStr = (item['price'] as num).toStringAsFixed(0);
  final thumbnail = item['thumbnail'] ?? '';
  
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productData: item),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BAGIAN GAMBAR - yang diperbaiki
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF5F5F5),
                child: _buildRecommendationImage(thumbnail),
              ),
            ),
          ),
          // BAGIAN INFO PRODUK
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp $priceStr",
                    style: const TextStyle(
                      color: brownTraya,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("Bagikan ke WhatsApp"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: const Text("Bagikan ke Telegram"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.grey),
              title: const Text("Salin Link"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== SCREEN 2: PROFIL PENJUAL ========================
class PublicProfileScreen extends StatefulWidget {
  final String ownerEmail;
  final String ownerName;
  
  const PublicProfileScreen({
    super.key,
    required this.ownerEmail,
    required this.ownerName,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final DbHelper _dbHelper = DbHelper();
  final SessionManager _session = SessionManager();
  Map<String, dynamic>? _sellerData;
  List<Map<String, dynamic>> _sellerProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final seller = await _dbHelper.getUserByEmail(widget.ownerEmail);
    final products = await _dbHelper.getProductsByUser(widget.ownerEmail);
    
    setState(() {
      _sellerData = seller;
      _sellerProducts = products;
      _isLoading = false;
    });
  }

  void _chatWithSeller() {
    if (!_session.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Diperlukan"),
          content: const Text("Silakan login untuk chat dengan penjual"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              child: const Text("Login"),
            ),
          ],
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          partnerEmail: widget.ownerEmail,
          partnerName: widget.ownerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Penjual"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: brownTraya),
            onPressed: _chatWithSeller,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildProfileHeader(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildStatsSection(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductCard(_sellerProducts[index]),
                        childCount: _sellerProducts.length,
                      ),
                    ),
                  ),
                  if (_sellerProducts.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: Column(
                          children: [
                            Icon(Icons.store, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "Belum ada produk",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    if (_sellerData == null) return const SizedBox.shrink();
    
    final vacationMode = _sellerData!['storeVacationMode'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFFFF0EA),
            child: Text(
              (_sellerData!['name'] ?? 'U').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: brownTraya),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _sellerData!['name'] ?? 'Pengguna',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (vacationMode == 1)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Libur",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "@${_sellerData!['username'] ?? 'username'}",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (_sellerData!['bio'] != null && _sellerData!['bio'].toString().isNotEmpty)
            Text(
              _sellerData!['bio'],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_sellerProducts.length.toString(), "Produk"),
          _buildStatItem("0", "Terjual"),
          _buildStatItem("0", "Pengikut"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brownTraya),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final priceStr = (item['price'] as num).toStringAsFixed(0);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productData: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp $priceStr",
                    style: const TextStyle(
                      color: brownTraya,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== SCREEN 3: PENCARIAN ========================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();
  
  String _searchKeyword = "";
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isRecentSearches = true;

  final List<String> _recentSearches = [];
  final List<String> _popularSearches = [
    'Hoodie', 'Jeans', 'Sepatu', 'Tas', 'Jaket', 'Kaos', 'Kemeja', 'Vintage'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final keyword = _searchController.text.trim();
      setState(() {
        _searchKeyword = keyword;
        _isRecentSearches = keyword.isEmpty;
      });
      if (keyword.isNotEmpty) {
        _performSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchKeyword.isEmpty) return;
    
    setState(() => _isLoading = true);
    final results = await _dbHelper.searchProducts(_searchKeyword);
    setState(() {
      _searchResults = results;
      _isLoading = false;
      _isRecentSearches = false;
    });
    
    if (!_recentSearches.contains(_searchKeyword)) {
      _recentSearches.insert(0, _searchKeyword);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    }
  }

void _clearSearch() {
  _searchController.clear();
  setState(() {
    _searchKeyword = "";
    _searchResults = [];
    _isRecentSearches = true;
  });
  // JANGAN panggil Navigator.pop() di sini
}

void _goBack() {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigation()),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _isRecentSearches
                      ? _buildRecentAndPopular()
                      : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSearchBar() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        // Tombol back (panah)
        IconButton(
          icon: const Icon(Icons.arrow_back, color: brownTraya),
          onPressed: _goBack,  // ← panggil _goBack
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: orangeTraya),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: _clearSearch,  // ← panggil _clearSearch (BUKAN pop)
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tombol Batal
        TextButton(
          onPressed: _goBack,  // ← panggil _goBack
          child: const Text("Batal", style: TextStyle(color: brownTraya)),
        ),
      ],
    ),
  );
}

  Widget _buildRecentAndPopular() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pencarian Terbaru",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text("Hapus Semua", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return Chip(
                  label: Text(search),
                  onDeleted: () {
                    setState(() {
                      _recentSearches.remove(search);
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: const Color(0xFFF5F5F5),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            "Pencarian Populer",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch();
                },
                backgroundColor: const Color(0xFFFFF0EA),
                labelStyle: const TextStyle(color: brownTraya),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            "Kategori",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildCategoryIcon(Icons.female, "Wanita"),
              _buildCategoryIcon(Icons.male, "Pria"),
              _buildCategoryIcon(Icons.child_care, "Anak"),
              _buildCategoryIcon(Icons.devices, "Lainnya"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0EA),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: brownTraya, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Produk tidak ditemukan",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Coba kata kunci lain",
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final priceStr = (item['price'] as num).toStringAsFixed(0);
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productData: item),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // KODE BARU
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: buildProductImage(item['thumbnail'] ?? ''),
              ),
            ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp $priceStr",
                        style: const TextStyle(
                          color: brownTraya,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.store, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item['ownerName'] ?? 'Penjual',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ======================== SCREEN 4: KERANJANG ========================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DbHelper _dbHelper = DbHelper();
  final SessionManager _session = SessionManager();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    
    if (_session.isLoggedIn && _session.currentUserEmail != null) {
      final items = await _dbHelper.getUserCart(_session.currentUserEmail!);
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSelection(int cartId, bool isSelected) async {
    await _dbHelper.updateCartSelection(cartId, isSelected ? 1 : 0);
    _loadCart();
  }

  Future<void> _removeItem(int cartId) async {
    await _dbHelper.removeFromCart(cartId);
    _loadCart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk dihapus dari keranjang")),
    );
  }

  void _navigateToProductDetail(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productData: product),
      ),
    );
  }

  void _chatWithSeller(String sellerEmail, String sellerName, String productTitle, int productId) {
    if (!_session.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu")),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          partnerEmail: sellerEmail,
          partnerName: sellerName,
          productId: productId.toString(),
          productTitle: productTitle,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _selectedItems {
    return _cartItems.where((item) => item['isSelected'] == 1).toList();
  }

  double get _totalPrice {
    return _selectedItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  Future<void> _checkout() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih produk yang akan dibeli")),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    bool hasVacationSeller = false;
    String vacationSellerName = "";
    
    for (var item in _selectedItems) {
      final vacationMode = await _dbHelper.getVacationMode(item['ownerEmail']);
      if (vacationMode == 1) {
        hasVacationSeller = true;
        vacationSellerName = item['ownerName'];
        break;
      }
    }

    if (hasVacationSeller) {
      setState(() => _isCheckingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Toko $vacationSellerName sedang libur, tidak dapat checkout"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: _selectedItems,
          total: _totalPrice,
        ),
      ),
    ).then((_) => _loadCart());

    setState(() => _isCheckingOut = false);
  }

  // Fungsi untuk menampilkan gambar di keranjang
  Widget _buildCartImage(String imagePath) {
    if (imagePath.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
    }
    
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
        },
      );
    }
    
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
        },
      );
    }
    
    return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Keranjang Belanja"),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Keranjang belanja kosong",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeTraya,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Belanja Sekarang",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keranjang Belanja",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Keranjang belanja kosong",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Yuk, belanja produk preloved terbaik!",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeTraya,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Belanja Sekarang",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final priceStr = (item['price'] as num).toStringAsFixed(0);
                          final isSelected = item['isSelected'] == 1;
                          final thumbnail = item['thumbnail'] ?? '';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // CHECKBOX
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      _toggleSelection(item['cartId'], value ?? false);
                                    },
                                    activeColor: orangeTraya,
                                  ),
                                  
                                  // GAMBAR PRODUK (bisa diklik)
                                  GestureDetector(
                                    onTap: () => _navigateToProductDetail(item),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _buildCartImage(thumbnail),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 12),
                                  
                                  // INFO PRODUK (bisa diklik)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _navigateToProductDetail(item),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Rp $priceStr",
                                            style: const TextStyle(
                                              color: brownTraya,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Jumlah: ${item['quantity']}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "Penjual: ${item['ownerName']}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // TOMBOL NEGO/CHAT (dan Hapus)
                                  Column(
                                    children: [
                                      // Tombol Nego/Chat (SATU-SATUNYA TOMBOL)
                                      OutlinedButton(
                                        onPressed: () => _chatWithSeller(
                                          item['ownerEmail'],
                                          item['ownerName'],
                                          item['title'],
                                          item['id'],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: brownTraya),
                                          foregroundColor: brownTraya,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          "Nego/Chat",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Tombol Hapus
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                        onPressed: () => _removeItem(item['cartId']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // BAGIAN BAWAH (TOTAL + CHECKOUT) - HANYA 1 TOMBOL CHECKOUT
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Pilih Semua
                              Row(
                                children: [
                                  Checkbox(
                                    value: _selectedItems.length == _cartItems.length && _cartItems.isNotEmpty,
                                    onChanged: (value) {
                                      for (var item in _cartItems) {
                                        _toggleSelection(item['cartId'], value ?? false);
                                      }
                                    },
                                    activeColor: orangeTraya,
                                  ),
                                  const Text("Pilih Semua"),
                                ],
                              ),
                              // Total Harga
                              Row(
                                children: [
                                  const Text(
                                    "Total: ",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Rp ${_totalPrice.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: brownTraya,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // TOMBOL CHECKOUT (HANYA SATU)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: orangeTraya,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isCheckingOut ? null : _checkout,
                              child: _isCheckingOut
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      "Checkout (${_selectedItems.length})",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

// ======================== SCREEN 5: CHECKOUT ========================
class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;
  
  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final DbHelper _dbHelper = DbHelper();
  final SessionManager _session = SessionManager();
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _dbHelper.getUserByEmail(_session.currentUserEmail!);
    if (user != null) {
      _nameController.text = user['name'] ?? '';
    }
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isProcessing = true);
    
    try {
      for (var item in widget.cartItems) {
        await _dbHelper.createOrder(
          productId: item['id'],
          productTitle: item['title'],
          quantity: item['quantity'],
          price: item['price'],
          total: item['price'] * item['quantity'],
          shippingAddress: "${_addressController.text}, ${_cityController.text}, ${_postalCodeController.text}",
          buyerName: _nameController.text,
          buyerEmail: _session.currentUserEmail!,
          buyerPhone: _phoneController.text,
          sellerEmail: item['ownerEmail'],
          thumbnail: item['thumbnail'],
        );
        
        // Remove from cart after order
        await _dbHelper.removeFromCart(item['cartId']);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil dibuat!")),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memproses pesanan: $e")),
        );
      }
    }
    
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ringkasan Pesanan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ringkasan Pesanan",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ...widget.cartItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${item['title']} x${item['quantity']}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                "Rp ${(item['price'] * item['quantity']).toStringAsFixed(0)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Pembayaran",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            "Rp ${widget.total.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: brownTraya,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Form Alamat Pengiriman
                const Text(
                  "Alamat Pengiriman",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Nama Penerima",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v?.isEmpty == true ? "Nama penerima wajib diisi" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: "No. Telepon",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.isEmpty == true ? "No. telepon wajib diisi" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: "Alamat Lengkap",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        maxLines: 3,
                        validator: (v) => v?.isEmpty == true ? "Alamat wajib diisi" : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: "Kota",
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v?.isEmpty == true ? "Kota wajib diisi" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _postalCodeController,
                              decoration: const InputDecoration(
                                labelText: "Kode Pos",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v?.isEmpty == true ? "Kode pos wajib diisi" : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
          
          // Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeTraya,
                  foregroundColor: Colors.white,  // ← TAMBAHKAN INI!
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isProcessing ? null : _processOrder,
                child: _isProcessing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Buat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ),
          ),
        ],
      ),
    );
  }
}