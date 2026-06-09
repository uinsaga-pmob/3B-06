import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/shop_bundle.dart';
import 'package:APK_TRAYA/views/management_bundle.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DbHelper _dbHelper = DbHelper();
  final SessionManager _session = SessionManager();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  int _productCount = 0;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    if (_session.isLoggedIn && _session.currentUserEmail != null) {
      final data = await _dbHelper.getUserByEmail(_session.currentUserEmail!);
      final productCount = await _dbHelper.getUserProductCount(_session.currentUserEmail!);
      final favoriteCount = await _dbHelper.getUserFavoriteCount(_session.currentUserEmail!);
      
      setState(() {
        _userData = data;
        _productCount = productCount;
        _favoriteCount = favoriteCount;
        _isLoading = false;
      });
    } else {
      setState(() {
        _userData = null;
        _isLoading = false;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _session.clearSession();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LandingPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isGuestMode) {
      return _buildGuestModeUI();
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return _buildNotLoggedInUI();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildProfileHeader(),
            _buildStatsSection(),
            const SizedBox(height: 16),
            _buildMenuBlock(
              title: "Aktivitas Saya",
              items: [
                _buildMenuItem(Icons.favorite_border_rounded, "Favorit Saya", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserFavoriteListScreen()),
                  );
                }),
                _buildMenuItem(Icons.shopping_bag_outlined, "Pesanan Saya", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderScreen()),
                  );
                }),
                _buildMenuItem(Icons.history_rounded, "Terakhir Dilihat", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fitur sedang dalam pengembangan")),
                  );
                }),
              ],
            ),
            _buildMenuBlock(
              title: "Pengaturan",
              items: [
                _buildMenuItem(Icons.settings_outlined, "Pengaturan Akun", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }),
                _buildMenuItem(Icons.help_outline_rounded, "Pusat Bantuan", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fitur sedang dalam pengembangan")),
                  );
                }),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestModeUI() {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Mode Tamu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk atau daftar untuk mengakses semua fitur',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              BigButton(
                text: 'Masuk Akun',
                backgroundColor: orangeTraya,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedBigButton(
                text: 'Daftar Akun Baru',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedInUI() {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Masuk',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk atau daftar untuk melanjutkan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              BigButton(
                text: 'Masuk Akun',
                backgroundColor: orangeTraya,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedBigButton(
                text: 'Daftar Akun Baru',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    if (_userData == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFFFF0EA),
            child: Text(
              (_userData!['name'] ?? 'U').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: brownTraya),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData!['name'] ?? 'Pengguna',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brownTraya),
                ),
                Text(
                  "@${_userData!['username'] ?? 'username'}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (_userData!['bio'] != null && _userData!['bio'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _userData!['bio'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(currentData: _userData!),
                      ),
                    );
                    if (result == true) {
                      _loadUserData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: orangeTraya),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Edit Profil",
                      style: TextStyle(color: orangeTraya, fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_productCount.toString(), "Produk"),
          _buildStatItem(_favoriteCount.toString(), "Favorit"),
          _buildStatItem("0", "Terjual"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brownTraya),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
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
      leading: Icon(icon, color: brownTraya),
      title: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      onTap: onTap,
    );
  }
}

// EDIT PROFILE SCREEN
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
  final SessionManager _session = SessionManager();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentData['name'] ?? '');
    _usernameController = TextEditingController(text: widget.currentData['username'] ?? '');
    _bioController = TextEditingController(text: widget.currentData['bio'] ?? '');
    _linkController = TextEditingController(text: widget.currentData['link'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isSaving = true);

    if (_session.currentUserEmail == null) {
      setState(() => _isSaving = false);
      return;
    }

    Map<String, dynamic> updatedData = {
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim().toLowerCase(),
      'bio': _bioController.text.trim(),
      'link': _linkController.text.trim(),
    };

    int result = await _dbHelper.updateUserProfile(_session.currentUserEmail!, updatedData);
    
    if (result > 0) {
      final updatedUser = await _dbHelper.getUserByEmail(_session.currentUserEmail!);
      if (updatedUser != null) {
        _session.updateUserData(updatedUser);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui profil")),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check, color: brownTraya, size: 28),
                  onPressed: _saveProfile,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFFFF0EA),
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: brownTraya),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ubah Foto",
                    style: TextStyle(color: brownTraya, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildEditField("Nama Lengkap", _nameController),
            _buildEditField("Username", _usernameController),
            _buildEditField("Bio", _bioController, maxLines: 3),
            _buildEditField("Link", _linkController),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: orangeTraya),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// USER FAVORITE LIST SCREEN
class UserFavoriteListScreen extends StatelessWidget {
  const UserFavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();
    final DbHelper dbHelper = DbHelper();
    
    if (!session.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Favorit Saya"),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("Login untuk melihat favorit", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Favorit Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getUserFavorites(session.currentUserEmail!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada favorit", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          final favs = snapshot.data!;
          return ListView.builder(
            itemCount: favs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = favs[index];
              final priceStr = (item['price'] as num).toStringAsFixed(0);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rp $priceStr"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productData: item),
                      ),
                    );
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