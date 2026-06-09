import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/shop_bundle.dart';
import 'package:APK_TRAYA/components.dart';
import 'dart:io';

class ShopDashboardPage extends StatefulWidget {
  const ShopDashboardPage({super.key});

  @override
  State<ShopDashboardPage> createState() => _ShopDashboardPageState();
}

class _ShopDashboardPageState extends State<ShopDashboardPage> {
  final DbHelper dbHelper = DbHelper();
  String _searchKeyword = "";
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await dbHelper.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _searchProducts() async {
    if (_searchKeyword.isEmpty) {
      await _loadProducts();
      return;
    }
    
    setState(() => _isLoading = true);
    final results = await dbHelper.searchProducts(_searchKeyword);
    setState(() {
      _products = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            SliverToBoxAdapter(
              child: _buildCategoriesSection(),
            ),
            SliverToBoxAdapter(
              child: _buildProductHeader(),
            ),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: orangeTraya,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'TRaya',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [orangeTraya, brownTraya],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchKeyword = value.trim();
            });
            _searchProducts();
          },
          decoration: InputDecoration(
            hintText: 'Cari pakaian, merk, atau gaya...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: orangeTraya),
            suffixIcon: _searchKeyword.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _searchKeyword = "";
                      });
                      _loadProducts();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.female, 'label': 'Wanita', 'color': const Color(0xFFFFE0E0)},
      {'icon': Icons.male, 'label': 'Pria', 'color': const Color(0xFFE0F0FF)},
      {'icon': Icons.child_care, 'label': 'Anak', 'color': const Color(0xFFE0FFE0)},
      {'icon': Icons.devices, 'label': 'Lainnya', 'color': const Color(0xFFFFF0E0)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((cat) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _searchKeyword = cat['label'];
              });
              _searchProducts();
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cat['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat['icon'], color: brownTraya, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Produk Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Lihat Semua >',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_products.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Produk tidak ditemukan",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                "Coba kata kunci lain",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: orangeTraya),
                onPressed: () {
                  setState(() {
                    _searchKeyword = "";
                  });
                  _loadProducts();
                },
                child: const Text("Reset Pencarian"),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProductCard(_products[index]),
          childCount: _products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
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
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
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
                  child: _buildProductImage(thumbnail),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rp $priceStr",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: brownTraya,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
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
  }

  Widget _buildProductImage(String path) {
    if (path.isEmpty) {
      return const Icon(Icons.inventory_2, size: 40, color: Colors.grey);
    }
    
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else if (File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover);
    } else {
      return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
    }
  }
}