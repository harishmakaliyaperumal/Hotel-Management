class CartItem {
  final String name;
  final String price;
  final String image;
  int quantity;

  CartItem({required this.name, required this.price, required this.image,this.quantity = 1,});

  // Factory constructor to convert from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'],
      price: map['price'],
      image: map['image'],
      quantity: map['quantity'] ?? 1,
    );
  }
}
