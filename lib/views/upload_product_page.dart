import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:APK_TRAYA/database/db_helper.dart';
import 'package:APK_TRAYA/models/product_model.dart';

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

  String _category = 'Pants';
  File? _image;
  final _picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // MENERAPKAN IDENTITAS NETRAL KELOMPOK SAAT UPLOAD PRODUCT
  void _uploadProduk() async {
    if (_formKey.currentState!.validate() && _image != null) {
      Product newProduct = Product(
        ownerName: "TrayaStore", // DIUBAH: Dari "Zen Owner" menjadi nama aplikasi/toko kolektif
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _category,
        size: 'M', 
        imagePath: _image!.path,
      );

      int id = await DbHelper().addProduct(newProduct.toMap());

      if (id > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Barang Berhasil Diposting!")),
        );
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        setState(() {
          _image = null;
        });
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih foto barang terlebih dahulu!")),
      );
    }
  }

  // MENERAPKAN IDENTITAS NETRAL KELOMPOK SAAT SIMPAN DRAF
  void _saveAsDraft() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul minimal harus diisi untuk draf!")),
      );
      return;
    }

    Map<String, dynamic> draftRow = {
      'ownerName': "TrayaStore", // DIUBAH: Menggunakan nama toko kelompok yang netral
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'category': _category,
      'size': 'M',
      'imagePath': _image != null ? _image!.path : '',
    };

    int id = await DbHelper().addDraft(draftRow);
    if (id > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tersimpan ke Draf Kelompok")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jual Barang", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF69C73),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Nama Barang"),
                validator: (v) => v!.isEmpty ? "Nama barang wajib diisi" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Pants', 'Hoodie', 'Shirt']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveAsDraft,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 45)),
                      child: const Text("Save Draft", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _uploadProduk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 45),
                      ),
                      child: const Text("Upload"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}