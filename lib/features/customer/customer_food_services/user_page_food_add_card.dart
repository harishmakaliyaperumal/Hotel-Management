import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';

import '../../services/apiservices.dart';

class Additeampage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int floorId;
  final int roomNo;
  final String userName;
  final int userId;
  final int? restaurantId;
  final int? restaurantCategoryId;
  final int? restaurantSubCategoryId;
  final int? restaurantMenuId;
  final Function(List<Map<String, dynamic>>)? onCartUpdated;

  const Additeampage({
    Key? key,
    required this.cartItems,
    required this.floorId,
    required this.roomNo,
    required this.userName,
    required this.userId,
    this.restaurantId,
    this.restaurantCategoryId,
    this.restaurantSubCategoryId,
    this.restaurantMenuId,
    this.onCartUpdated,
  }) : super(key: key);

  @override
  State<Additeampage> createState() => _AdditeampageState();
}

class _AdditeampageState extends State<Additeampage> {

  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  // Access the singleton instance of ApiService
  final ApiService _apiService = ApiService();


  // Function to increment the quantity of an item
  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index]['cardquantity'] += 1;
      widget.onCartUpdated?.call(widget.cartItems);
    });
  }

  // Function to decrement the quantity of an item
  void _decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index]['cardquantity'] > 1) {
        widget.cartItems[index]['cardquantity'] -= 1; // Decrement by 1
      } else {
        // Remove the item if quantity is 1
        widget.cartItems.removeAt(index);
      }
      widget.onCartUpdated?.call(widget.cartItems);
    });
  }

  // Function to generate the description string
  String _generateDescription() {
    return widget.cartItems
        .map((item) => "${item['menuName']}-${item['cardquantity']}")
        .join(', ');
  }

  // Submit food request
  Future<void> _submitRequest() async {
    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.saveGeneralFoodRequest(
        floorId: widget.floorId,
        taskId: 23,
        roomDataId: widget.roomNo,
        rname: widget.userName,
        requestType: "Customer Request",
        description: _generateDescription(),
        requestDataCreatedBy: widget.userId,
        restaurantId: widget.restaurantId ?? 0,
        restaurantCategoryId: widget.restaurantCategoryId ?? 0,
        restaurantSubCategoryId: widget.restaurantSubCategoryId ?? 0,
        restaurantMenu: widget.restaurantMenuId ?? 0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cart items list
          Expanded(
            child: widget.cartItems.isEmpty
                ? const Center(
              child: Text('Your cart is empty'),
            )
                : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Card(
                  child: ListTile(
                    leading: item['image'] != null && item['image'].isNotEmpty
                        ? Image.memory(
                      base64Decode(item['image']), // Decode Base64 image
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.fastfood), // Fallback icon
                    title: Text('${item['menuName'] ?? 'Unknown Item'}(${item['quantity'] ?? 'N/A'}-Pcs)'),
                    subtitle: Text(
                        'Price: \$${item['price'] ?? 'N/A'}, Quantity: ${item['cardquantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _decrementQuantity(index),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('${item['cardquantity']}'),
                        IconButton(
                          onPressed: () => _incrementQuantity(index),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Food Request button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Food Request',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
