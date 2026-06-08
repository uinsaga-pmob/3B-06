import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/shop_bundle.dart'; // IMPOR UTAMA: Menyelesaikan konflik navigasi sirkular detail produk
import 'package:APK_TRAYA/views/management_bundle.dart';

const String _defaultAvatar = 'assets/seller_avatar.jpg';
const String currentUserEmail = "zen@traya.com"; // Sinkronisasi Sesi Global

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isHolidayMode = false;
  final DbHelper _dbHelper = DbHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _dbHelper.getSpecificUserProfile(currentUserEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data ?? {
            'name': 'Zen Owner',
            'username': 'zen_owner',
            'bio': 'Thrift Enthusiast',
            'link': 'zen.store',
          };

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildProfileHeader(context, userData),
              _buildSellBanner(context),
              const SizedBox(height: 16),
              _buildMenuBlock(
                title: "Aktivitas Saya",
                items: [
                  _buildMenuItem(Icons.favorite_border_rounded, "Favorit Saya", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserFavoriteListScreen()));
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
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 40, backgroundColor: Color(0xFFEFEFEF), backgroundImage: AssetImage(_defaultAvatar)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData['name'] ?? 'Zen Owner', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7F2F00))),
                Text("@${userData['username'] ?? 'zen_owner'}", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(currentData: userData)));
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF69C73)), borderRadius: BorderRadius.circular(20)),
                    child: const Text("Edit Profil", style: TextStyle(color: Color(0xFFF69C73), fontSize: 12, fontWeight: FontWeight.w600)),
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
      decoration: BoxDecoration(color: const Color(0xFFFFF0EA), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF69C73).withOpacity(0.4))),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_outlined, color: Color(0xFF7F2F00), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Mulai Jual Barang Bekasmu", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF7F2F00))),
                Text("Ubah pakaian lama jadi penghasilan tambahan.", style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF7F2F00), size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gunakan menu navigasi (+) di bagian bawah tengah.")));
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
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(15)),
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
      trailing: Switch.adaptive(value: value, activeColor: const Color(0xFFF69C73), onChanged: onChanged),
    );
  }
}

// --- SCREEN EDIT PROFIL ---
class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;
  const EditProfileScreen({super.key, required this.currentData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _linkController;
  final DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentData['name']);
    _usernameController = TextEditingController(text: widget.currentData['username']);
    _bioController = TextEditingController(text: widget.currentData['bio']);
    _linkController = TextEditingController(text: widget.currentData['link']);
  }

  void _simpanProfil() async {
    Map<String, dynamic> updatedData = {
      'name': _nameController.text,
      'username': _usernameController.text,
      'bio': _bioController.text,
      'link': _linkController.text,
    };

    int result = await _dbHelper.updateUserProfile(updatedData);
    if (result > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil Toko Berhasil Diperbarui!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black, size: 28), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.check, color: Color(0xFF7F2F00), size: 28), onPressed: _simpanProfil)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFEFEF)),
                    child: const CircleAvatar(radius: 45, backgroundImage: AssetImage(_defaultAvatar)),
                  ),
                  const SizedBox(height: 8),
                  const Text("Ubah Foto", style: TextStyle(color: Color(0xFF7F2F00), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildLinearEditField("Name", _nameController),
            _buildLinearEditField("Username", _usernameController),
            _buildLinearEditField("Bio", _bioController),
            _buildLinearEditField("Link", _linkController),
          ],
        ),
      ),
    );
  }

  Widget _buildLinearEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500))),
          Expanded(child: TextField(controller: controller, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), decoration: const InputDecoration(border: InputBorder.none, suffixIcon: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26)))),
        ],
      ),
    );
  }
}

// --- SCREEN LIST FAVORIT PRIVAT USER ---
class UserFavoriteListScreen extends StatelessWidget {
  const UserFavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DbHelper dbHelper = DbHelper();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Favorit Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white, elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getUserFavorites(currentUserEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada iklan thrifting favorit Anda."));
          }
          final favs = snapshot.data!;
          return ListView.builder(
            itemCount: favs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = favs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rp ${item['price'].toString().replaceAll('.0', '')}"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productData: item)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}