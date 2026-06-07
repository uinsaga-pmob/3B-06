import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/views/profile_bundle.dart';

// --- 1. SETTINGS SCREEN[cite: 34] ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Edit Profil"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Alamat Saya"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LandingPage()),
              (r) => false,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 1b. ADDRESS SCREEN[cite: 34] ---
class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Alamat Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text("Belum ada alamat tersimpan")),
    );
  }
}

// --- 2. WISHLIST SCREEN[cite: 34] ---
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text("Belum ada favorit")),
    );
  }
}

// --- 3. ORDER SCREEN[cite: 34] ---
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pesanan Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text("Riwayat pesanan kosong")),
    );
  }
}

// --- 4. CHECKOUT SCREEN[cite: 34] ---
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text("Halaman Checkout")),
    );
  }
}
