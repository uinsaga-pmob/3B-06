import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/auth_pages.dart' hide DbHelper;
import 'package:APK_TRAYA/views/profile_bundle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DbHelper dbHelper = DbHelper();

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF7F2F00)),
            title: const Text("Edit Profil"),
            onTap: () async {
              final userData = await dbHelper.getSpecificUserProfile(currentUserEmail);
              
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      currentData: userData ?? const {
                        'name': 'Pengguna TRaya',
                        'username': 'user_traya',
                        'bio': '',
                        'link': ''
                      },
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Color(0xFF7F2F00)),
            title: const Text("Alamat Saya"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LandingPage()),
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorit", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
      ),
      body: const Center(child: Text("Belum ada favorit")),
    );
  }
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
      ),
      body: const Center(child: Text("Riwayat pesanan kosong")),
    );
  }
}

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Alamat Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(),
      ),
      body: const Center(
        child: Text(
          "Belum ada alamat pengiriman yang ditambahkan.",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}