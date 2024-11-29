import 'package:flutter/material.dart';

import 'carditem.dart';


class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Function to increment the quantity of an item
  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index].quantity++;
    });
  }

  // Function to decrement the quantity of an item
  void _decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index].quantity--;
      } else {
        // Remove the item if quantity is 0
        widget.cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
        child: Text('Your cart is empty'),
      )
          : ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return Card(
            child: ListTile(
              leading: Image.asset(item.image, height: 50, width: 50),
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: \$${item.price}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _decrementQuantity(index),
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                      ),
                      Text('Quantity: ${item.quantity}'),
                      IconButton(
                        onPressed: () => _incrementQuantity(index),
                        icon: const Icon(Icons.add_circle),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
