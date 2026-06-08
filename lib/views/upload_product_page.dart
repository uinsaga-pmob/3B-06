import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:APK_TRAYA/database/db_helper.dart';

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
  
  final String _currentSelectedUserEmail = "zen@traya.com";
  final String _currentSelectedUserName = "Zen Owner";

  List<File> _selectedImages = [];
  final _picker = ImagePicker();
  final DbHelper _dbHelper = DbHelper();

  String? _selectedCategory;
  String? _selectedSubCategory;

  // Struktur Kategori Utama & Sub-Kategori Sesuai Permintaan
  final Map<String, List<String>> _categoriesData = {
    'Wanita': ['Celana', 'Baju', 'Rok', 'Aksesoris'],
    'Pria': ['Kaos', 'Kemeja', 'Celana Panjang', 'Jaket'],
    'Anak': ['Mainan', 'Pakaian Bayi', 'Sepatu Anak'],
    'Hiburan': ['Buku', 'Kaset Game', 'Alat Musik'],
  };

  Future<void> _getMultiImages() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Maksimal unggah adalah 10 foto!")));
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

  void _prosesPublish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap pilih minimal 1 foto barang.")));
      return;
    }
    if (_selectedCategory == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kategori & Sub-kategori wajib dipilih.")));
      return;
    }

    Map<String, dynamic> productData = {
      'ownerEmail': _currentSelectedUserEmail,
      'ownerName': _currentSelectedUserName,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'size': 'M',
    };

    List<String> imgPaths = _selectedImages.map((f) => f.path).toList();
    int id = await _dbHelper.addProduct(productData, imgPaths);

    if (id > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Iklan produk Anda berhasil diterbitkan secara publik!")));
      _resetForm();
    }
  }

  void _prosesSimpanDraft() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Judul diperlukan untuk menyimpan draf.")));
      return;
    }

    Map<String, dynamic> draftData = {
      'ownerEmail': _currentSelectedUserEmail,
      'ownerName': _currentSelectedUserName,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory ?? '',
      'subCategory': _selectedSubCategory ?? '',
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'size': 'M',
    };

    List<String> imgPaths = _selectedImages.map((f) => f.path).toList();
    await _dbHelper.addDraft(draftData, imgPaths);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk disimpan ke dalam draf produk saya.")));
    _resetForm();
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedCategory = null;
      _selectedSubCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Mulai Jualan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Foto Produk (Maksimal 10)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return GestureDetector(
                        onTap: _getMultiImages,
                        child: Container(
                          width: 100, margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                          child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover)),
                        ),
                        Positioned(
                          right: 12, top: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImages.removeAt(index)),
                            child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text("Pilih Kategori Utama"),
                items: _categoriesData.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubCategory = null;
                  });
                },
                validator: (v) => v == null ? "Kategori utama wajib dipilih" : null,
              ),
              const SizedBox(height: 16),
              if (_selectedCategory != null)
                DropdownButtonFormField<String>(
                  value: _selectedSubCategory,
                  hint: const Text("Pilih Sub-Kategori"),
                  items: _categoriesData[_selectedCategory]!.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubCategory = value;
                    });
                  },
                  validator: (v) => v == null ? "Sub-kategori wajib dipilih" : null,
                ),
              
              // KONDISIONAL FORM SESUAI FOTO MOCKUP USER
              if (_selectedCategory == 'Wanita' && _selectedSubCategory == 'Celana') ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.2))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Spesifikasi Ukuran Celana Wanita:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F2F00))),
                      const SizedBox(height: 8),
                      TextFormField(decoration: const InputDecoration(labelText: "Lingkar Pinggang / Waist", hintText: "Cth: Size 28-30 fit")),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul Barang Jualan"), validator: (v) => v!.isEmpty ? "Judul jualan tidak boleh kosong" : null),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Deskripsi Kondisi Barang"), maxLines: 2),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: "Harga Jual (Rp)"), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Harga barang wajib ditentukan" : null),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: Color(0xFF7F2F00))),
                      onPressed: _prosesSimpanDraft,
                      child: const Text("Simpan Ke Draf", style: TextStyle(color: Color(0xFF7F2F00), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7F2F00), minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _prosesPublish,
                      child: const Text("Pasang Iklan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}