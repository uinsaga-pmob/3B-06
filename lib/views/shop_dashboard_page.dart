import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'dart:io';

class ShopDashboardPage extends StatefulWidget {
  const ShopDashboardPage({super.key});

  @override
  State<ShopDashboardPage> createState() => _ShopDashboardPageState();
}

class _ShopDashboardPageState extends State<ShopDashboardPage> {
  final DbHelper dbHelper = DbHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER LENGKUNG TRaya (Sesuai dengan beranda.png)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 25),
              decoration: const BoxDecoration(
                color: Color(0xFFF69C73),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRaya',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFC82E1D), // Warna Merah mockup
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: const Color(0xFFC82E1D),
                          child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SEKSI REKOMENDASI SELLER
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Rekomendasi seller',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Sans'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getAllSellers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada seller terpilih"));
                  }
                  final sellers = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: const AssetImage('assets/seller_avatar.jpg'),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sellers[index]['name'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: List.generate(
                                sellers[index]['rating'] ?? 5,
                                (i) => const Icon(Icons.star, color: Colors.red, size: 12),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // SEKSI HOT ITEMS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hot items',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton<String>(
                      value: 'Semua',
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: ['Semua', 'Pants', 'Hoodie']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),

            // GRID DATA REAL DARI DATABASE
            FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.getAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Belum ada barang aktif")));
                }

                final products = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final String imgPath = item['imagePath'] ?? '';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[100],
                                child: imgPath == 'asset_dummy_jeans'
                                    ? Image.asset('assets/hoodie.jpg', fit: BoxFit.cover) // Fallback ke aset lokal kamu
                                    : (imgPath.isNotEmpty ? Image.file(File(imgPath), fit: BoxFit.cover) : const Icon(Icons.image, size: 50)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Rp ${item['price'].toString().replaceAll('.0', '')}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            item['title'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                          Text(
                            item['size'] ?? 'M',
                            style: const TextStyle(color: Colors.black38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}