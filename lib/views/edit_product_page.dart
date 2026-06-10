import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/components.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> productData;
  
  const EditProductPage({super.key, required this.productData});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  
  final DbHelper _dbHelper = DbHelper();
  
  List<File> _newImages = [];
  List<Map<String, dynamic>> _existingImages = [];
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedCondition;
  bool _isLoading = true;
  bool _isSaving = false;

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
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    setState(() => _isLoading = true);
    
    _titleController.text = widget.productData['title'] ?? '';
    _descriptionController.text = widget.productData['description'] ?? '';
    _priceController.text = (widget.productData['price'] ?? 0).toString();
    _sizeController.text = widget.productData['size'] ?? '';
    _selectedCategory = widget.productData['category'];
    _selectedSubCategory = widget.productData['subCategory'];
    _selectedCondition = widget.productData['condition'];
    
    // Load existing images - PERBAIKAN DI SINI
    final images = await _dbHelper.getProductImages(widget.productData['id']);
    for (var i = 0; i < images.length; i++) {
      _existingImages.add({
        'index': i,           // untuk key
        'path': images[i],    // path gambar (String)
      });
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _newImages.addAll(pickedFiles.map((file) => File(file.path)));
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  // Update product data
  final productData = {
    'title': _titleController.text.trim(),
    'description': _descriptionController.text.trim(),
    'category': _selectedCategory,
    'subCategory': _selectedSubCategory ?? '',
    'price': double.tryParse(_priceController.text) ?? 0,
    'size': _sizeController.text.trim().isEmpty ? 'Free Size' : _sizeController.text.trim(),
    'condition': _selectedCondition ?? 'Baik',
  };
  
  await _dbHelper.updateProduct(widget.productData['id'], productData);
  
  // Add new images
  for (var img in _newImages) {
    await _dbHelper.addProductImage(widget.productData['id'], img.path);
  }
  
  // Hapus gambar yang diremove (opsional, jika ingin hapus dari database)
  // Catatan: Untuk sekarang, gambar lama tetap tersimpan
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil diperbarui!")),
    );
    Navigator.pop(context, true);
  }
  
  setState(() => _isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Produk", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
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
                  onPressed: _saveProduct,
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
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
        
        // Existing Images
        if (_existingImages.isNotEmpty) ...[
          const Text("Gambar Saat Ini:", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_existingImages[index]['path'])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
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
          const SizedBox(height: 12),
        ],
        
        // New Images
        if (_newImages.isNotEmpty) ...[
          const Text("Gambar Baru:", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_newImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(index),
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
          const SizedBox(height: 12),
        ],
        
        // Add Image Button
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
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