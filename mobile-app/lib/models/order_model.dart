class OrderModel {
  final int id;
  final int storeId;
  final int customerId;
  final int productId;
  final int quantity;
  final double totalPrice;
  final String status;
  final String createdAt;
  
  // Joined fields
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final String productName;
  final String? productImage;

  OrderModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    required this.productName,
    this.productImage,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()),
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      productId: json['product_id'] is int ? json['product_id'] : int.parse(json['product_id'].toString()),
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
      totalPrice: json['total_price'] != null ? double.parse(json['total_price'].toString()) : 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      customerName: json['customer_name'] ?? 'Unknown',
      customerPhone: json['customer_phone'] ?? '',
      customerAddress: json['customer_address'],
      productName: json['product_name'] ?? 'Unknown Product',
      productImage: json['product_image'],
    );
  }
}
