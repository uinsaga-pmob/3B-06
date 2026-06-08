import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/chat_bundle.dart';
import 'dart:io';

const String currentUserEmail = "zen@traya.com";

// ======================== SCREEN 1: DETAIL PRODUK LENGKAP ========================
class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  const ProductDetailScreen({super.key, required this.productData});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DbHelper _dbHelper = DbHelper();
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFavStatus();
  }

  void _checkFavStatus() async {
    bool fav = await _dbHelper.isProductFavorite(currentUserEmail, widget.productData['id']);
    setState(() => _isFav = fav);
  }

  void _toggleFav() async {
    await _dbHelper.toggleFavorite(currentUserEmail, widget.productData['id']);
    _checkFavStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFav ? "Dihapus dari Favorit" : "Berhasil Ditambahkan ke Favorit Saya!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.productData;
    final String imgPath = item['thumbnail'] ?? '';
    final String priceStr = item['price'].toString().replaceAll('.0', '');
    final bool isMyOwnProduct = (currentUserEmail == item['ownerEmail']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Detail Produk", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
          IconButton(
            icon: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.red),
            onPressed: _toggleFav,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF7F2F00)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 320, width: double.infinity, color: const Color(0xFFF6F6F6),
              child: imgPath == 'asset_dummy_jeans'
                  ? Image.asset('assets/hoodie.jpg', fit: BoxFit.cover)
                  : (imgPath.isNotEmpty && File(imgPath).existsSync() ? Image.file(File(imgPath), fit: BoxFit.cover) : const Icon(Icons.image, size: 80, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rp $priceStr", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF7F2F00))),
                  const SizedBox(height: 6),
                  Text(item['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(height: 30),

                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(ownerEmail: item['ownerEmail']))),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 22, backgroundColor: Color(0xFFEFEFEF), child: Icon(Icons.storefront, color: Color(0xFF7F2F00))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['ownerName'] ?? 'Penjual TRaya', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const Text("Kunjungi Toko Penjual >", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 30),
                  const Text("Deskripsi Barang:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(item['description'] ?? 'Tidak ada deskripsi.', style: const TextStyle(color: Colors.black54, height: 1.4)),
                  const SizedBox(height: 30),

                  const Text("Rekomendasi Produk Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildRekomendasiSeksi(item['id']),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: isMyOwnProduct
            ? const Text("Ini iklan produk Anda sendiri.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), side: const BorderSide(color: Color(0xFF7F2F00)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen())),
                      child: const Text("Chat / Nego", style: TextStyle(color: Color(0xFF7F2F00), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7F2F00), minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        await _dbHelper.addToCart(currentUserEmail, item['id']);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk berhasil ditambahkan ke keranjang belanja!")));
                      },
                      child: const Text("Beli Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildRekomendasiSeksi(int currentId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbHelper.getRecommendationProducts(currentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Belum ada produk rekomendasi lainnya.", style: TextStyle(color: Colors.grey));
        final recs = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: recs.length,
          itemBuilder: (context, index) {
            final recItem = recs[index];
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productData: recItem))),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Container(color: Colors.grey[100], width: double.infinity, child: const Icon(Icons.inventory_2, color: Colors.grey))),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recItem['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Rp ${recItem['price'].toString().replaceAll('.0', '')}", style: const TextStyle(color: Color(0xFF7F2F00), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ======================== SCREEN 2: PROFIL PENJUAL (READ ONLY) ========================
class PublicProfileScreen extends StatelessWidget {
  final String ownerEmail;
  const PublicProfileScreen({super.key, required this.ownerEmail});

  @override
  Widget build(BuildContext context) {
    final DbHelper dbHelper = DbHelper();
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Penjual"), backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: dbHelper.getSpecificUserProfile(ownerEmail),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 45, backgroundColor: Color(0xFFFFF0EA), child: Icon(Icons.person, size: 50, color: Color(0xFF7F2F00))),
                const SizedBox(height: 16),
                Text(user['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("@${user['username']}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Text(user['bio'] ?? 'No bio text yet.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                const Divider(height: 40),
                const Align(alignment: Alignment.centerLeft, child: Text("Katalog Toko Penjual:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                const Expanded(child: Center(child: Text("Katalog baju preloved aktif penjual otomatis muncul di sini.", style: TextStyle(color: Colors.grey)))),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======================== SCREEN 3: ENGINE PENCARIAN ========================
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchKeyword = _searchController.text.trim());
      if (_searchKeyword.isNotEmpty) _jalankanPencarian();
    });
  }

  void _jalankanPencarian() async {
    setState(() => _isLoading = true);
    final hasil = await _dbHelper.searchProducts(_searchKeyword);
    setState(() {
      _searchResults = hasil;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari items sandang...', hintStyle: const TextStyle(color: Colors.black38),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7F2F00)),
                    suffixIcon: _searchKeyword.isNotEmpty ? IconButton(icon: const Icon(Icons.cancel), onPressed: () => _searchController.clear()) : null,
                    border: InputBorder.none, isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _searchKeyword.isNotEmpty ? _buildHasilPencarian() : _buildDiscoveryMode(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHasilPencarian() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_searchResults.isEmpty) return const Center(child: Text("Barang jualan tidak ditemukan."));
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return ListTile(
          title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Rp ${item['price'].toString().replaceAll('.0', '')}"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productData: item))),
        );
      },
    );
  }

  Widget _buildDiscoveryMode() {
    return ListView(
      children: [
        const Text('Paling Banyak Dicari', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: ['Vintage Hoodie', 'Celana Baggy', 'Kaos Oversize'].map((tag) => ActionChip(label: Text(tag), onPressed: () => _searchController.text = tag)).toList(),
        ),
        const SizedBox(height: 30),
        const Text('Kategori Populer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCatIcon(Icons.woman, "Wanita"), _buildCatIcon(Icons.man, "Pria"), _buildCatIcon(Icons.child_care, "Anak"), _buildCatIcon(Icons.sports_esports, "Hiburan")
          ],
        )
      ],
    );
  }

  Widget _buildCatIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _searchController.text = label,
      child: Column(children: [CircleAvatar(backgroundColor: const Color(0xFFFFF0EA), child: Icon(icon, color: const Color(0xFF7F2F00))), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 12))]),
    );
  }
}

// ======================== SCREEN 4: KERANJANG SAYA ========================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() async {
    final items = await _dbHelper.getUserCart(currentUserEmail);
    setState(() => _cartItems = items);
  }

  @override
  Widget build(BuildContext context) {
    double total = _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang Belanja", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: _cartItems.isEmpty
          ? const Center(child: Text("Keranjang thrifting Anda kosong."))
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Color(0xFF7F2F00)),
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rp ${item['price'].toString().replaceAll('.0', '')} x ${item['quantity']}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                    await _dbHelper.removeFromCart(item['cartId']);
                    _loadCart();
                  }),
                );
              },
            ),
      bottomNavigationBar: _cartItems.isEmpty ? null : Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Tagihan:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), Text("Rp ${total.toString().replaceAll('.0', '')}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7F2F00)))]),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF69C73), minimumSize: const Size(double.infinity, 46)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(cartItems: _cartItems, total: total))),
              child: const Text("Lanjut Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

// ======================== SCREEN 5: CHECKOUT SHOPEE MODE ========================
class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;
  const CheckoutScreen({super.key, required this.cartItems, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengiriman"), backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Alamat Utama Anda", style: TextStyle(fontWeight: FontWeight.bold)),
            const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.location_on, color: Colors.red), title: Text("Zenny Nurul - Kost Mahasiswa TI"), subtitle: Text("Semarang, Jawa Tengah")),
            const Divider(),
            Expanded(child: ListView(children: cartItems.map((e) => ListTile(title: Text(e['title']), trailing: Text("Rp ${e['price'].toString().replaceAll('.0', '')}"))).toList())),
            DropdownButtonFormField<String>(value: 'Reguler', decoration: const InputDecoration(labelText: "Opsi Kurir"), items: ['Reguler', 'Kargo', 'Hemat'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (_) {}),
            DropdownButtonFormField<String>(value: 'Gopay', decoration: const InputDecoration(labelText: "Metode Pembayaran"), items: ['Gopay', 'Transfer Mandiri', 'COD'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (_) {}),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7F2F00), minimumSize: const Size(double.infinity, 50)),
              onPressed: () async {
                await DbHelper().clearUserCart(currentUserEmail);
                if (!context.mounted) return;
                showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Sukses Pesan!"), content: const Text("Pesanan preloved dikirim ke penjual."), actions: [TextButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text("Ok"))]));
              },
              child: Text("Buat Pesanan (Rp ${total.toString().replaceAll('.0', '')})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

class CreateListingScreen extends StatelessWidget {
  const CreateListingScreen({super.key});
  @override
  Widget build(BuildContext context) { return const Scaffold(body: Center(child: Text("+"))); }
}