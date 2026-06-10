import 'dart:io';
import 'package:flutter/material.dart';

const Color orangeTraya = Color(0xFFF69C73);
const Color brownTraya = Color(0xFF7F2F00);

class BigButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isLoading;

  const BigButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

class OutlinedBigButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const OutlinedBigButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: orangeTraya, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: orangeTraya,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Fungsi helper untuk menampilkan gambar produk
Widget buildProductImage(String imagePath, {double? width, double? height}) {
  // Jika path kosong
  if (imagePath.isEmpty) {
    return Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]);
  }
  
  // Jika gambar dari asset
  if (imagePath.startsWith('assets/')) {
    return Image.asset(
      imagePath,
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: 40, color: Colors.grey[400]);
      },
    );
  }
  
  // Jika gambar dari file lokal
  final file = File(imagePath);
  if (file.existsSync()) {
    return Image.file(
      file,
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: 40, color: Colors.grey[400]);
      },
    );
  }
  
  // Default jika semua gagal
  return Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]);
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(orangeTraya),
        ),
      ),
    );
  }
}