import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/chat_bundle.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
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
          partnerName: widget.productData['ownerName'] ?? 'Penjual',
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
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: isMyOwnProduct
            ? const Text(
                "Ini adalah produk Anda sendiri",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(color: brownTraya),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _chatWithSeller,
                      child: const Text(
                        "Chat Penjual",
                        style: TextStyle(color: brownTraya, fontWeight: FontWeight.bold),
                      ),
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
                Text(
                  widget.productData['ownerName'] ?? 'Penjual TRaya',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: recs.length,
              itemBuilder: (context, index) {
                final recItem = recs[index];
                return _buildRecommendationCard(recItem);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> item) {
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
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFEFEFEF),
                  child: const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: const Text("Bagikan ke Telegram"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.grey),
              title: const Text("Salin Link"),
              onTap: () {},
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
          Text(
            _sellerData!['name'] ?? 'Pengguna',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
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

  Future<void> _updateQuantity(int cartId, int newQuantity) async {
    if (newQuantity < 1) {
      await _dbHelper.removeFromCart(cartId);
    } else {
      await _dbHelper.updateCartQuantity(cartId, newQuantity);
    }
    _loadCart();
  }

  Future<void> _removeItem(int cartId) async {
    await _dbHelper.removeFromCart(cartId);
    _loadCart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk dihapus dari keranjang")),
    );
  }

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
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
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: orangeTraya),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Belanja Sekarang"),
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
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: orangeTraya),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Belanja Sekarang"),
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
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
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
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                                              onPressed: () => _updateQuantity(item['cartId'], item['quantity'] - 1),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              item['quantity'].toString(),
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, size: 20),
                                              onPressed: () => _updateQuantity(item['cartId'], item['quantity'] + 1),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 20),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                              onPressed: () => _removeItem(item['cartId']),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
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
                      ),
                    ),
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
                              const Text(
                                "Total:",
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
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orangeTraya,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Fitur checkout sedang dalam pengembangan")),
                              );
                            },
                            child: const Text(
                              "Checkout",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;
  
  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ringkasan Pesanan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final priceStr = (item['price'] as num).toStringAsFixed(0);
                  return ListTile(
                    leading: const Icon(Icons.shopping_bag, color: brownTraya),
                    title: Text(item['title'] ?? ''),
                    subtitle: Text("${item['quantity']} x Rp $priceStr"),
                    trailing: Text(
                      "Rp ${(item['price'] * item['quantity']).toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${total.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: brownTraya,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeTraya,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pesanan berhasil dibuat!")),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                "Buat Pesanan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}