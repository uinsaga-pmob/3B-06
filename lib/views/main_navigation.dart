import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/shop_dashboard_page.dart';
import 'package:APK_TRAYA/views/shop_bundle.dart';
import 'package:APK_TRAYA/views/chat_bundle.dart';
import 'package:APK_TRAYA/views/profile_bundle.dart';
import 'package:APK_TRAYA/views/upload_product_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Sinkronisasi halaman utama aplikasi TRaya
  final List<Widget> _pages = [
    const ShopDashboardPage(),   // Indeks 0: Beranda Berbasis Database (beranda.png)
    const SearchScreen(),        // Indeks 1: Halaman Cari (Cari.png)
    const UploadProductPage(),   // Indeks 2: Halaman Jual (jual.png)
    const InboxScreen(),         // Indeks 3: Halaman Chat/Kotak Masuk
    const ProfilePage(),         // Indeks 4: Halaman Profil (riska123)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar status scroll halaman tidak hilang saat berpindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // TOMBOL HOME TENGAH MENCUAT (Sesuai dengan mockup beranda.png)
      floatingActionButton: SizedBox(
        width: 68,
        height: 68,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF7F2F00), // Cokelat pekat TRaya
          shape: const CircleBorder(),
          elevation: 4,
          onPressed: () {
            setState(() {
              _currentIndex = 0; // Lompat ke Beranda
            });
          },
          child: const Icon(
            Icons.home_rounded, 
            size: 36, 
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BOTTOM APP BAR (Oranye Peach dengan lingkaran Notch pembatas)
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF69C73), // Oranye peach TRaya asli
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Bagian Kiri FAB
              IconButton(
                icon: Icon(
                  Icons.search_rounded, 
                  color: _currentIndex == 1 ? Colors.black : Colors.white,
                  size: 30,
                ),
                onPressed: () => setState(() => _currentIndex = 1),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded, 
                  color: _currentIndex == 2 ? Colors.black : Colors.white,
                  size: 30,
                ),
                onPressed: () => setState(() => _currentIndex = 2),
              ),
              
              // Pembatas ruang hampa di tengah untuk FAB
              const SizedBox(width: 32),

              // Bagian Kanan FAB
              IconButton(
                icon: Icon(
                  Icons.mail_outline_rounded, 
                  color: _currentIndex == 3 ? Colors.black : Colors.white,
                  size: 30,
                ),
                onPressed: () => setState(() => _currentIndex = 3),
              ),
              IconButton(
                icon: Icon(
                  Icons.person_outline_rounded, 
                  color: _currentIndex == 4 ? Colors.black : Colors.white,
                  size: 30,
                ),
                onPressed: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}