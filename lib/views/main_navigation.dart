import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/shop_dashboard_page.dart';
import 'package:APK_TRAYA/views/shop_bundle.dart';
import 'package:APK_TRAYA/views/chat_bundle.dart';
import 'package:APK_TRAYA/views/profile_bundle.dart';
import 'package:APK_TRAYA/views/upload_product_page.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/components.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  final SessionManager _session = SessionManager();

  @override
  void initState() {
    super.initState();
    _pages = [
      const ShopDashboardPage(),
      const SearchScreen(),
      const UploadProductPage(),
      const InboxScreen(),
      const ProfilePage(),
    ];
    _session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    setState(() {});
  }

  void _checkAccess(int index) {
    final requiresAuth = [2, 3];
    final isLoggedIn = _session.isLoggedIn;
    
    if (requiresAuth.contains(index) && !isLoggedIn) {
      _showLoginRequiredDialog();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showLoginRequiredDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.lock_person_rounded, size: 60, color: brownTraya),
              const SizedBox(height: 16),
              const Text(
                "Login Diperlukan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brownTraya),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan login terlebih dahulu untuk mengakses fitur ini",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeTraya,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text(
                  "Login Sekarang",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali", style: TextStyle(color: Colors.grey)),
              ),
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          backgroundColor: brownTraya,
          shape: const CircleBorder(),
          elevation: 4,
          onPressed: () => _checkAccess(2),
          child: const Icon(Icons.add_shopping_cart, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: orangeTraya,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        clipBehavior: Clip.none,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, icon: Icons.home_rounded, label: 'Beranda'),
              _buildNavItem(index: 1, icon: Icons.search_rounded, label: 'Cari'),
              const SizedBox(width: 48),
              _buildNavItem(index: 3, icon: Icons.chat_bubble_outline_rounded, label: 'Pesan'),
              _buildNavItem(index: 4, icon: Icons.person_outline_rounded, label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _checkAccess(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? brownTraya : Colors.white,
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: brownTraya, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}