import 'dart:convert';

class Product {
  final int id;
  final int storeId;
  final String name;
  final String productId; // Unique product ID (e.g., LK-001, LK-002)
  final double price;
  final String? description;
  final String? image; // Primary image
  final List<String> images; // Multiple images support
  final int stockQuantity;
  final bool isActive;
  final bool hasSizes;
  final Map<String, int>? sizes; // Map of size to quantity
  final String? sizeChartImage;
  final int clickCount;
  final String formattedPrice;
  final String whatsappUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.productId,
    required this.price,
    this.description,
    this.image,
    this.images = const [],
    required this.stockQuantity,
    required this.isActive,
    this.hasSizes = false,
    this.sizes,
    this.sizeChartImage,
    required this.clickCount,
    required this.formattedPrice,
    required this.whatsappUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse images array if available
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        // If images is a JSON string, parse it
        try {
          var decoded = jsonDecode(json['images']);
          if (decoded is List) {
            imagesList = List<String>.from(decoded);
          }
        } catch (e) {
          imagesList = [];
        }
      }
    }
    
    // Parse sizes map if available
    Map<String, int>? sizesMap;
    if (json['sizes'] != null) {
      if (json['sizes'] is Map) {
        sizesMap = Map<String, int>.from(json['sizes'].map((k, v) => MapEntry(k.toString(), _parseInt(v))));
      } else if (json['sizes'] is String) {
        try {
          var decoded = jsonDecode(json['sizes']);
          if (decoded is Map) {
            sizesMap = Map<String, int>.from(decoded.map((k, v) => MapEntry(k.toString(), _parseInt(v))));
          }
        } catch (e) {
          sizesMap = null;
        }
      }
    }
    
    // If no images array but has single image, add it to images list
    if (imagesList.isEmpty && json['image'] != null) {
      imagesList = [json['image']];
    }

    return Product(
      id: _parseInt(json['id']),
      storeId: _parseInt(json['store_id']),
      name: json['name']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? 'LK-${_parseInt(json['id']).toString().padLeft(4, '0')}',
      price: _parseDouble(json['price']),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      images: imagesList,
      stockQuantity: _parseInt(json['stock_quantity'] ?? 0),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      hasSizes: json['has_sizes'] == 1 || json['has_sizes'] == true,
      sizes: sizesMap,
      sizeChartImage: json['size_chart_image']?.toString(),
      clickCount: _parseInt(json['click_count'] ?? 0),
      formattedPrice: json['formatted_price']?.toString() ?? '₹${_parseDouble(json['price'])}',
      whatsappUrl: json['whatsapp_url']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper method to safely parse int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // Helper method to safely parse double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'product_id': productId,
      'price': price,
      'description': description,
      'image': image,
      'images': images,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
      'has_sizes': hasSizes,
      'sizes': sizes,
      'size_chart_image': sizeChartImage,
      'click_count': clickCount,
      'formatted_price': formattedPrice,
      'whatsapp_url': whatsappUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    int? storeId,
    String? name,
    String? productId,
    double? price,
    String? description,
    String? image,
    List<String>? images,
    int? stockQuantity,
    bool? isActive,
    bool? hasSizes,
    Map<String, int>? sizes,
    String? sizeChartImage,
    int? clickCount,
    String? formattedPrice,
    String? whatsappUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      images: images ?? this.images,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      hasSizes: hasSizes ?? this.hasSizes,
      sizes: sizes ?? this.sizes,
      sizeChartImage: sizeChartImage ?? this.sizeChartImage,
      clickCount: clickCount ?? this.clickCount,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      whatsappUrl: whatsappUrl ?? this.whatsappUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Helper to get primary image
  String? get primaryImage => images.isNotEmpty ? images.first : image;
  
  // Helper to check if product has multiple images
  bool get hasMultipleImages => images.length > 1;
}
