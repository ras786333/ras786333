class Order {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String customerName;
  final String phoneNumber;
  final String address;
  final String note;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.note,
    required this.orderDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'address': address,
      'note': note,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      note: json['note'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
      status: json['status'],
    );
  }
}
