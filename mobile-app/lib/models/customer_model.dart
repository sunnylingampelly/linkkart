class CustomerModel {
  final int id;
  final int storeId;
  final String name;
  final String phone;
  final String? address;
  final String createdAt;
  
  // Joined fields
  final int totalOrders;
  final double totalSpent;

  CustomerModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.phone,
    this.address,
    required this.createdAt,
    required this.totalOrders,
    required this.totalSpent,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()),
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      address: json['address'],
      createdAt: json['created_at'] ?? '',
      totalOrders: json['total_orders'] != null ? (json['total_orders'] is int ? json['total_orders'] : int.parse(json['total_orders'].toString())) : 0,
      totalSpent: json['total_spent'] != null ? double.parse(json['total_spent'].toString()) : 0.0,
    );
  }
}
