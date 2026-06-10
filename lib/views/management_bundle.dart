import 'package:flutter/material.dart';
import 'dart:io';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/views/profile_bundle.dart';
import 'package:APK_TRAYA/views/chat_bundle.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SessionManager _session = SessionManager();
  final DbHelper _dbHelper = DbHelper();
  Map<String, dynamic>? _userData;
  bool _vacationMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    if (_session.isLoggedIn && _session.currentUserEmail != null) {
      final data = await _dbHelper.getUserByEmail(_session.currentUserEmail!);
      final vacationMode = await _dbHelper.getVacationMode(_session.currentUserEmail!);
      setState(() {
        _userData = data;
        _vacationMode = vacationMode == 1;
        _isLoading = false;
      });
    } else {
      setState(() {
        _userData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleVacationMode(bool value) async {
    setState(() => _vacationMode = value);
    await _dbHelper.toggleVacationMode(_session.currentUserEmail!, value ? 1 : 0);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? "Mode libur diaktifkan" : "Mode libur dinonaktifkan"),
          backgroundColor: value ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                if (_session.isLoggedIn && _userData != null) ...[
                  _buildProfileSection(_userData!),
                  const Divider(height: 0),
                ],
                _buildPreferenceSection(),
                const Divider(height: 0),
                _buildAccountSection(),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> userData) {
    String avatarPath = userData['avatar'] ?? '';
    bool hasAvatar = avatarPath.isNotEmpty && File(avatarPath).existsSync();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFFFF0EA),
            child: hasAvatar
                ? ClipOval(
                    child: Image.file(
                      File(avatarPath),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          (userData['name'] ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: brownTraya),
                        );
                      },
                    ),
                  )
                : Text(
                    (userData['name'] ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: brownTraya),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name'] ?? 'Pengguna',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData['email'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: orangeTraya),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(currentData: userData),
                ),
              );
              if (result == true) {
                _loadUserData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Preferensi Toko',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.beach_access, color: brownTraya),
                title: const Text("Mode Libur"),
                subtitle: Text(
                  _vacationMode ? "Toko sedang libur" : "Toko sedang buka",
                  style: TextStyle(color: _vacationMode ? Colors.orange : Colors.green, fontSize: 12),
                ),
                trailing: Switch(
                  value: _vacationMode,
                  activeColor: orangeTraya,
                  onChanged: _toggleVacationMode,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language, color: brownTraya),
                title: const Text("Bahasa"),
                trailing: const Text("Indonesia", style: TextStyle(color: Colors.grey)),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Akun & Lainnya',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: brownTraya),
                title: const Text("Alamat Saya"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: brownTraya),
                title: const Text("Kebijakan Privasi"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _showPrivacyPolicy(),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: brownTraya),
                title: const Text("Syarat & Ketentuan"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _showTermsAndConditions(),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: brownTraya),
                title: const Text("Tentang Aplikasi"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _showAboutApp(),
              ),
              if (_session.isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: _logout,
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kebijakan Privasi"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Privasi Anda adalah prioritas kami.", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("1. Data pribadi Anda hanya digunakan untuk keperluan transaksi."),
              SizedBox(height: 4),
              Text("2. Kami tidak akan membagikan data Anda ke pihak ketiga."),
              SizedBox(height: 4),
              Text("3. Anda dapat menghapus akun kapan saja."),
              SizedBox(height: 4),
              Text("4. Data chat disimpan untuk keperluan komunikasi."),
              SizedBox(height: 4),
              Text("5. Foto produk menjadi milik penjual."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Syarat & Ketentuan"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Dengan menggunakan TRaya, Anda menyetujui:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("1. Deskripsi produk harus sesuai dengan kondisi asli."),
              SizedBox(height: 4),
              Text("2. Dilarang menjual produk ilegal atau palsu."),
              SizedBox(height: 4),
              Text("3. Transaksi dilakukan langsung antara penjual dan pembeli."),
              SizedBox(height: 4),
              Text("4. TRaya tidak bertanggung jawab atas sengketa transaksi."),
              SizedBox(height: 4),
              Text("5. Gunakan fitur chat untuk negosiasi harga."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tentang Aplikasi"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag, color: orangeTraya, size: 40),
                  SizedBox(width: 12),
                  Text("TRaya", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: brownTraya)),
                ],
              ),
              SizedBox(height: 16),
              Text("Versi: 1.0.0"),
              SizedBox(height: 8),
              Text("Latar Belakang:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                "TRaya adalah aplikasi thrift marketplace yang memungkinkan pengguna untuk membeli dan menjual pakaian preloved dengan mudah. "
                "Aplikasi ini dibuat untuk mendukung gaya hidup berkelanjutan dengan memberikan nilai tambah pada pakaian bekas yang masih layak pakai.",
              ),
              SizedBox(height: 12),
              Text("Fitur Utama:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("• Jual beli produk preloved"),
              Text("• Chat antar pengguna"),
              Text("• Sistem favorit dan keranjang"),
              Text("• Mode libur untuk toko"),
              Text("• Riwayat produk yang dilihat"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<Map<String, String>> _addresses = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _loadAddresses() {
    // Load saved addresses from shared preferences or local storage
    // For now, using empty list
    setState(() {
      _addresses.clear();
    });
  }

  void _saveAddresses() {
    // Save addresses to shared preferences or local storage
    // This would be implemented with SharedPreferences
  }

void _addAddress() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Alamat Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Penerima',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lengkap',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Kota',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Kode Pos',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // TOMBOL BATAL - Sudah diperbaiki
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: orangeTraya),
                          foregroundColor: orangeTraya,  // ✅ Teks warna ORANYE
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _nameController.clear();
                          _phoneController.clear();
                          _addressController.clear();
                          _cityController.clear();
                          _postalCodeController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // TOMBOL SIMPAN - Sudah diperbaiki
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeTraya,
                          foregroundColor: Colors.white,  // ✅ Teks warna PUTIH
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _addresses.add({
                                'name': _nameController.text,
                                'phone': _phoneController.text,
                                'address': _addressController.text,
                                'city': _cityController.text,
                                'postalCode': _postalCodeController.text,
                              });
                            });
                            _saveAddresses();
                            _nameController.clear();
                            _phoneController.clear();
                            _addressController.clear();
                            _cityController.clear();
                            _postalCodeController.clear();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Alamat berhasil ditambahkan')),
                            );
                          }
                        },
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  void _editAddress(int index) {
    final addr = _addresses[index];
    _nameController.text = addr['name']!;
    _phoneController.text = addr['phone']!;
    _addressController.text = addr['address']!;
    _cityController.text = addr['city']!;
    _postalCodeController.text = addr['postalCode']!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Alamat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Penerima',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Kota',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Pos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: orangeTraya, foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        _addresses[index] = {
                          'name': _nameController.text,
                          'phone': _phoneController.text,
                          'address': _addressController.text,
                          'city': _cityController.text,
                          'postalCode': _postalCodeController.text,
                        };
                      });
                      _saveAddresses();
                      _nameController.clear();
                      _phoneController.clear();
                      _addressController.clear();
                      _cityController.clear();
                      _postalCodeController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alamat berhasil diperbarui')),
                      );
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Alamat"),
        content: const Text("Apakah Anda yakin ingin menghapus alamat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _addresses.removeAt(index);
              });
              _saveAddresses();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alamat berhasil dihapus')),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Alamat Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: orangeTraya),
            onPressed: _addAddress,
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada alamat",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tambahkan alamat untuk pengiriman",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeTraya,
                      foregroundColor: Colors.white,  // ← TAMBAHKAN INI
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _addAddress,
                    child: const Text(
                      'Tambah Alamat',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final addr = _addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: orangeTraya),
                    title: Text(addr['name']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addr['phone']!),
                        Text(addr['address']!),
                        Text("${addr['city']}, ${addr['postalCode']}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: orangeTraya),
                          onPressed: () => _editAddress(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteAddress(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  final SessionManager _session = SessionManager();
  final DbHelper _dbHelper = DbHelper();
  late TabController _tabController;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      final statuses = ['all', 'pending', 'shipped', 'completed'];
      setState(() {
        _selectedStatus = statuses[_tabController.index];
      });
      _loadOrders();
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!_session.isLoggedIn) {
      setState(() {
        _orders = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final orders = await _dbHelper.getUserOrders(_session.currentUserEmail!, role: 'buyer');
    
    List<Map<String, dynamic>> filteredOrders = orders;
    if (_selectedStatus != 'all') {
      filteredOrders = orders.where((order) => order['status'] == _selectedStatus).toList();
    }
    
    setState(() {
      _orders = filteredOrders;
      _isLoading = false;
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Menunggu Konfirmasi';
      case 'shipped': return 'Dikirim';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'shipped': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Pesanan Saya"),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("Login untuk melihat pesanan", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: brownTraya,
          unselectedLabelColor: Colors.grey,
          indicatorColor: orangeTraya,
          tabs: const [
            Tab(text: "Semua"),
            Tab(text: "Menunggu"),
            Tab(text: "Dikirim"),
            Tab(text: "Selesai"),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada pesanan",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Status: $_selectedStatus",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order['orderNumber'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusText(order['status']),
                                      style: TextStyle(
                                        color: _getStatusColor(order['status']),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // Alternatif - lebih ramah pengguna
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.shopping_bag, color: Colors.grey, size: 24),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Order #${order['orderNumber']?.toString().substring(0, 6) ?? ''}",
                                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['productTitle'],
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Jumlah: ${order['quantity']}"),
                                        Text(
                                          "Total: Rp ${(order['total'] as num).toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: brownTraya,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (order['status'] == 'pending')
                                    OutlinedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Batalkan Pesanan"),
                                            content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("Tidak"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () async {
                                                  await _dbHelper.updateOrderStatus(order['orderNumber'], 'cancelled');
                                                  if (mounted) {
                                                    Navigator.pop(context);
                                                    _loadOrders();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text("Pesanan dibatalkan")),
                                                    );
                                                  }
                                                },
                                                child: const Text("Ya, Batalkan"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                      child: const Text("Batalkan", style: TextStyle(color: Colors.red)),
                                    ),
                                  if (order['status'] == 'shipped')
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _dbHelper.updateOrderStatus(order['orderNumber'], 'completed');
                                        if (mounted) {
                                          _loadOrders();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Pesanan selesai")),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text("Konfirmasi Selesai"),
                                    ),
                                  if (order['status'] == 'completed')
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatRoomScreen(
                                              partnerEmail: order['sellerEmail'],
                                              partnerName: order['sellerEmail'].split('@').first,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("Chat Penjual"),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}