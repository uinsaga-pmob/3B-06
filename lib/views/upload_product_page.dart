import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/components.dart';

class UploadProductPage extends StatefulWidget {
  const UploadProductPage({super.key});

  @override
  State<UploadProductPage> createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  
  final SessionManager _session = SessionManager();
  final DbHelper _dbHelper = DbHelper();

  List<File> _selectedImages = [];
  final _picker = ImagePicker();

  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedCondition;
  bool _isLoading = false;

  final Map<String, List<String>> _categoriesData = {
    'Wanita': ['Baju', 'Celana', 'Rok', 'Aksesoris', 'Tas', 'Sepatu'],
    'Pria': ['Kaos', 'Kemeja', 'Celana Panjang', 'Jaket', 'Sepatu', 'Aksesoris'],
    'Anak': ['Pakaian Bayi', 'Pakaian Anak', 'Mainan', 'Sepatu Anak', 'Perlengkapan Sekolah'],
    'Lainnya': ['Buku', 'Elektronik', 'Perabotan', 'Hobi', 'Olahraga'],
  };

  final List<String> _conditions = [
    'Baru dengan Tag',
    'Seperti Baru',
    'Sangat Baik',
    'Baik',
    'Cukup Baik',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 10 foto")),
      );
      return;
    }
    
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      if (_selectedImages.length > 10) {
        _selectedImages = _selectedImages.sublist(0, 10);
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _publishProduct() async {
    if (!_session.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal 1 foto produk")),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kategori produk")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final productData = {
      'ownerEmail': _session.currentUserEmail,
      'ownerName': _session.currentUserData?['name'] ?? 'Pengguna',
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory ?? '',
      'price': double.tryParse(_priceController.text) ?? 0,
      'size': _sizeController.text.trim().isEmpty ? 'Free Size' : _sizeController.text.trim(),
      'condition': _selectedCondition ?? 'Baik',
    };

    final imagePaths = _selectedImages.map((f) => f.path).toList();
    final result = await _dbHelper.addProduct(productData, imagePaths);

    setState(() => _isLoading = false);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil dipublikasikan!")),
      );
      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mempublikasikan produk")),
      );
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _sizeController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedCategory = null;
      _selectedSubCategory = null;
      _selectedCondition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.isLoggedIn) {
      return _buildNotLoggedInUI();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Jual Produk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingOverlay()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildTextField(_titleController, "Judul Produk", Icons.title),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, "Deskripsi", Icons.description, maxLines: 3),
                    const SizedBox(height: 16),
                    _buildTextField(_priceController, "Harga (Rp)", Icons.attach_money, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildCategorySection(),
                    const SizedBox(height: 16),
                    _buildConditionSection(),
                    const SizedBox(height: 16),
                    _buildTextField(_sizeController, "Ukuran (opsional)", Icons.straighten),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetForm,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: orangeTraya),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Reset", style: TextStyle(color: orangeTraya)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _publishProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brownTraya,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Publikasikan", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
        title: const Text("Jual Produk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Login untuk menjual produk",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan login terlebih dahulu untuk mulai berjualan",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              BigButton(
                text: "Login Sekarang",
                backgroundColor: orangeTraya,
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Foto Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_selectedImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (_selectedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "${_selectedImages.length} dari 10 foto",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: const Text("Pilih Kategori"),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _categoriesData.keys.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              _selectedSubCategory = null;
            });
          },
          validator: (v) => v == null ? "Pilih kategori" : null,
        ),
        if (_selectedCategory != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSubCategory,
            hint: const Text("Pilih Sub Kategori"),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _categoriesData[_selectedCategory]!.map((sub) {
              return DropdownMenuItem(value: sub, child: Text(sub));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubCategory = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildConditionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kondisi Barang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCondition,
          hint: const Text("Pilih Kondisi"),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _conditions.map((cond) {
            return DropdownMenuItem(value: cond, child: Text(cond));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCondition = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: orangeTraya),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        if (label == "Harga (Rp)" && double.tryParse(value) == null) {
          return "Masukkan angka yang valid";
        }
        return null;
      },
    );
  }
}