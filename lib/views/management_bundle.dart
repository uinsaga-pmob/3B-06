import 'package:flutter/material.dart';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/views/profile_bundle.dart';
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
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_session.isLoggedIn && _session.currentUserEmail != null) {
      final data = await _dbHelper.getUserByEmail(_session.currentUserEmail!);
      setState(() {
        _userData = data;
      });
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
      body: ListView(
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFFFF0EA),
            child: Text(
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
            'Preferensi',
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
                leading: const Icon(Icons.notifications_none, color: brownTraya),
                title: const Text("Notifikasi"),
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: orangeTraya,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: brownTraya),
                title: const Text("Mode Gelap"),
                trailing: Switch(
                  value: _darkMode,
                  activeColor: orangeTraya,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
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
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: brownTraya),
                title: const Text("Syarat & Ketentuan"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: brownTraya),
                title: const Text("Tentang Aplikasi"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TRaya',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.shopping_bag, size: 40, color: orangeTraya),
                    children: const [
                      Text('Aplikasi thrift marketplace untuk pakaian preloved terbaik.'),
                    ],
                  );
                },
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
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
          builder: (context, setState) {
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
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: orangeTraya),
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
                          child: const Text('Simpan'),
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
                    style: ElevatedButton.styleFrom(backgroundColor: orangeTraya),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: orangeTraya),
                    onPressed: _addAddress,
                    child: const Text('Tambah Alamat'),
                  ),
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
                          onPressed: () {
                            setState(() {
                              _addresses.removeAt(index);
                            });
                          },
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

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();
    
    if (!session.isLoggedIn) {
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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pesanan Saya", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          bottom: const TabBar(
            labelColor: brownTraya,
            unselectedLabelColor: Colors.grey,
            indicatorColor: orangeTraya,
            tabs: [
              Tab(text: "Semua"),
              Tab(text: "Menunggu"),
              Tab(text: "Dikirim"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderList(status: 'all'),
            _OrderList(status: 'pending'),
            _OrderList(status: 'shipped'),
            _OrderList(status: 'completed'),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String status;
  const _OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    // Placeholder untuk data pesanan
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 0,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Belum ada pesanan"),
          ),
        );
      },
    );
  }
}