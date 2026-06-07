class Product {
  final int? id;
  final String ownerName; // Diambil dari profil penjual
  final String title;
  final String description;
  final String category;
  final double price;
  final String size;
  final String imagePath; // Path ke file gambar lokal di HP

  Product({
    this.id,
    required this.ownerName,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.size,
    required this.imagePath,
  });

  // Konversi objek Product ke Map (untuk dimasukkan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerName': ownerName,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'size': size,
      'imagePath': imagePath,
    };
  }

  // Konversi Map database ke objek Product (untuk digunakan di UI)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      ownerName: map['ownerName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num).toDouble(),
      size: map['size'] ?? 'M',
      imagePath: map['image_path'] ?? '',
    );
  }
}