import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/shop_bundle.dart';
import 'package:APK_TRAYA/views/management_bundle.dart';

const String _defaultAvatar = 'assets/seller_avatar.jpg';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isHolidayMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildProfileHeader(context),
          _buildSellBanner(context),
          const SizedBox(height: 16),
          _buildMenuBlock(
            title: "Aktivitas Saya",
            items: [
              _buildMenuItem(Icons.favorite_border_rounded, "Favorit Saya", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
              }),
              _buildMenuItem(Icons.shopping_bag_outlined, "Pesanan Saya", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen()));
              }),
              _buildMenuItem(Icons.history_rounded, "Terakhir Dilihat", () {}),
            ],
          ),
          _buildMenuBlock(
            title: "Fitur Toko",
            items: [
              _buildMenuItem(Icons.storefront_outlined, "Dashboard Toko Saya", () {}),
              _buildToggleItem(Icons.beach_access_outlined, "Mode Libur", _isHolidayMode, (val) {
                setState(() {
                  _isHolidayMode = val;
                });
              }),
            ],
          ),
          _buildMenuBlock(
            title: "Pengaturan & Bantuan",
            items: [
              _buildMenuItem(Icons.settings_outlined, "Pengaturan Akun", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
              _buildMenuItem(Icons.help_outline_rounded, "Pusat Bantuan", () {}),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFEFEFEF),
            backgroundImage: AssetImage(_defaultAvatar),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Traya Merchant", // DIUBAH: Dari nama personal menjadi identitas toko netral
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7F2F00)),
                ),
                Text(
                  "@traya_official", // DIUBAH: Username default kelompok
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF69C73)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Edit Profil",
                      style: TextStyle(color: Color(0xFFF69C73), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF69C73).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_outlined, color: Color(0xFF7F2F00), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Mulai Jual Barang Bekasmu",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF7F2F00)),
                ),
                Text(
                  "Ubah pakaian lama jadi penghasilan tambahan.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF7F2F00), size: 18),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBlock({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7F2F00)),
      title: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(IconData icon, String text, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7F2F00)),
      title: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFFF69C73),
        onChanged: onChanged,
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(_defaultAvatar),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF7F2F00),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildEditField("Nama Toko/Merchant", "Traya Merchant"), // DIUBAH
            _buildEditField("Username Toko", "traya_official"), // DIUBAH
            _buildEditField("Bio Aplikasi", "Menjual pakaian preloved kualitas premium kelompok TRaya."), // DIUBAH
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF7F2F00)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF69C73), width: 2),
          ),
        ),
      ),
    );
  }
}