import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final String image;
  final double price;
  final int quantity;
  int stock;
  final String whatsapp;
  final DateTime submittedDate;
  final String status;
  bool isFavorite;
  bool isFeatured;
  bool isFlashSale;
  final String sellerPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.image,
    required this.price,
    required this.quantity,
    required this.stock,
    required this.whatsapp,
    required this.submittedDate,
    required this.status,
    this.isFavorite = false,
    this.isFeatured = false,
    this.isFlashSale = false,
    required this.sellerPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  void toggleFavoriteStatus() {
    isFavorite = !isFavorite;
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    String? image,
    double? price,
    int? quantity,
    int? stock,
    String? whatsapp,
    DateTime? submittedDate,
    String? status,
    bool? isFavorite,
    bool? isFeatured,
    bool? isFlashSale,
    String? sellerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      whatsapp: whatsapp ?? this.whatsapp,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'image': image,
      'price': price,
      'quantity': quantity,
      'stock': stock,
      'whatsapp': whatsapp,
      'status': status,
      'isFavorite': isFavorite,
      'isFeatured': isFeatured,
      'isFlashSale': isFlashSale,
      'sellerPhone': sellerPhone,
      'submittedDate': submittedDate.toIso8601String(),
      // createdAt and updatedAt are managed by Firestore
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle dates with flexibility - might be Timestamp or String
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now(); // Default fallback
      }
    }

    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: ((json['price'] ?? 0) as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      image: json['image'] as String? ?? (json['imageUrl'] as String? ?? ''),
      category: json['category'] as String? ?? '',
      stock: (json['stock'] ?? 0) as int,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      submittedDate: parseDateTime(json['submittedDate'] ?? DateTime.now()),
      status: json['status'] as String? ?? 'pending',
      isFavorite: json['isFavorite'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isFlashSale: json['isFlashSale'] as bool? ?? false,
      sellerPhone: json['sellerPhone'] as String? ?? '',
      quantity: (json['quantity'] ?? 1) as int,
      whatsapp: json['whatsapp'] as String? ?? '',
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      stock: map['stock'] ?? 0,
      category: map['category'] ?? '',
      status: map['status'] ?? 'pending',
      sellerPhone: map['sellerPhone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      submittedDate: DateTime.now(),
      image: '',
      quantity: 0,
      whatsapp: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
      'status': status,
      'sellerPhone': sellerPhone,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
