class Store {
  final int id;
  final String name;
  final String phone;
  final String? logo;
  final String slug;
  final bool isActive;
  final int viewCount;
  final String storeUrl;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    this.logo,
    required this.slug,
    required this.isActive,
    required this.viewCount,
    required this.storeUrl,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      phone: json['phone'],
      logo: json['logo'],
      slug: json['slug'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      viewCount: int.parse((json['view_count'] ?? 0).toString()),
      storeUrl: json['store_url'] ?? '',
      productCount: int.parse((json['product_count'] ?? 0).toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'logo': logo,
      'slug': slug,
      'is_active': isActive,
      'view_count': viewCount,
      'store_url': storeUrl,
      'product_count': productCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Store copyWith({
    int? id,
    String? name,
    String? phone,
    String? logo,
    String? slug,
    bool? isActive,
    int? viewCount,
    String? storeUrl,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      logo: logo ?? this.logo,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      storeUrl: storeUrl ?? this.storeUrl,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
