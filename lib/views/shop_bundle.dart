import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/management_bundle.dart';

const Color orangeHeader = Color(0xFFF69C73);

// TAMPILAN CARI REPLIKASI PERSIS DARI MOCKUP Cari.png
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INPUT PENCARIAN ATAS
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari items atau user',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 24),

              // SEKSI RECENT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent >', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              _buildRecentItem("sepatu"),
              _buildRecentItem("cardigan"),
              const SizedBox(height: 24),

              // SEKSI TRENDING
              const Text('Trending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildTrendingBadge("sepatu"),
                  _buildTrendingBadge("tas"),
                  _buildTrendingBadge("hoodie"),
                  _buildTrendingBadge("cardigan"),
                  _buildTrendingBadge("jersey"),
                  _buildTrendingBadge("topi"),
                  _buildTrendingBadge("buku"),
                  _buildTrendingBadge("baggy jeans"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Text(text, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Icon(Icons.close, color: Colors.black54, size: 18),
        ],
      ),
    );
  }

  Widget _buildTrendingBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF7F2F00)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.trending_up, size: 16, color: Colors.black54),
        ],
      ),
    );
  }
}

// Komponen Halaman Lain dalam Bundle yang dipertahankan
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset('assets/banner_bg.png', height: 400, width: double.infinity, fit: BoxFit.cover),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text("Rp 250.000", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
        child: const Text("Beli"),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),
      body: const Center(child: Text("Cart Items")),
    );
  }
}