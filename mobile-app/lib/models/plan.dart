class Plan {
  final int id;
  final String name;
  final String slug;
  final double price;
  final String billingCycle;
  final int productLimit;
  final int orderLimit;
  final List<String> features;
  final bool isActive;
  final int sortOrder;

  Plan({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.billingCycle,
    required this.productLimit,
    required this.orderLimit,
    required this.features,
    required this.isActive,
    required this.sortOrder,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      price: double.parse(json['price'].toString()),
      billingCycle: json['billing_cycle'],
      productLimit: json['product_limit'],
      orderLimit: json['order_limit'],
      features: List<String>.from(json['features']),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      sortOrder: json['sort_order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'billing_cycle': billingCycle,
      'product_limit': productLimit,
      'order_limit': orderLimit,
      'features': features,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  bool get isFree => price == 0;
  
  String get priceDisplay => isFree ? 'Free' : '₹${price.toStringAsFixed(0)}';
  
  String get productLimitDisplay => 
      productLimit == 999999 ? 'Unlimited' : '$productLimit';
  
  String get orderLimitDisplay => 
      orderLimit == 999999 ? 'Unlimited' : '$orderLimit';
}
