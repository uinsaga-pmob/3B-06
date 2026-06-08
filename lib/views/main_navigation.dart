import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/shop_dashboard_page.dart';
import 'package:APK_TRAYA/views/shop_bundle.dart';
import 'package:APK_TRAYA/views/chat_bundle.dart';
import 'package:APK_TRAYA/views/profile_bundle.dart';
import 'package:APK_TRAYA/views/upload_product_page.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';

class MainNavigation extends StatefulWidget {
  final bool isGuest;

  const MainNavigation({super.key, this.isGuest = false});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const ShopDashboardPage(),   
      const SearchScreen(),        
      const UploadProductPage(),   
      const InboxScreen(),         
      const ProfilePage(),         
    ]);
  }

  void _periksaAksesAplikasi(int indexTarget) {
    if (widget.isGuest && (indexTarget == 2 || indexTarget == 3 || indexTarget == 4)) {
      _tampilkanGatewayLoginSheet();
    } else {
      setState(() {
        _currentIndex = indexTarget;
      });
    }
  }

  void _tampilkanGatewayLoginSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 24),
              const Icon(Icons.lock_person_rounded, size: 60, color: Color(0xFF7F2F00)),
              const SizedBox(height: 16),
              const Text(
                "Yuk, Masuk Akun Dulu!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7F2F00)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Untuk dapat bertransaksi, chat penjual, bernegosiasi, atau mengunggah produk, silakan masuk ke akun Anda terlebih dahulu.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF69C73),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text("Masuk Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali Lihat-Lihat", style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 68,
        height: 68,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF7F2F00), 
          shape: const CircleBorder(),
          elevation: 4,
          onPressed: () => _periksaAksesAplikasi(0),
          child: const Icon(Icons.home_rounded, size: 36, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF69C73), 
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        clipBehavior: Clip.none,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPopOutNavItem(index: 1, icon: Icons.search_rounded),
              _buildPopOutNavItem(index: 2, icon: Icons.add_circle_outline_rounded),
              const SizedBox(width: 40), 
              _buildPopOutNavItem(index: 3, icon: Icons.mail_outline_rounded),
              _buildPopOutNavItem(index: 4, icon: Icons.person_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopOutNavItem({required int index, required IconData icon}) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _periksaAksesAplikasi(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isActive ? -12 : 0, 0),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))] : [],
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFF7F2F00) : Colors.white,
        ),
      ),
    );
  }
}