import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/apiservices.dart';

import 'package:badges/badges.dart' as badges;

import 'user_page_food_add_card.dart';

class FoodMenu extends StatefulWidget {
  final int floorId;
  final int roomNo;
  final String userName;
  final int userId;
  final int restaurantMenuSubCategoriesId;
  final Function(List<Map<String, dynamic>>)? onCartUpdated;

  const FoodMenu({
    super.key,
    required this.restaurantMenuSubCategoriesId,
    required this.floorId,
    required this.roomNo,
    required this.userName,
    required this.userId,
    this.onCartUpdated,
  });

  @override
  State<FoodMenu> createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu> {
  List<Map<String, dynamic>> foodMenu = [];
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = false;
  final ApiService _apiService = ApiService();
  // List<Map<String, dynamic>> cartItems = [];


  @override
  void initState() {
    super.initState();
    _loadFoodMenu();
  }

  Future<void> _loadFoodMenu() async {
    try {
      final fetchedFoodMenu = await _apiService.fetchFoodMenu(widget.restaurantMenuSubCategoriesId);

      // Debug prints
      print('Fetched Food Menu: $fetchedFoodMenu');

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          foodMenu = fetchedFoodMenu.map((item) {
            // Extract Base64 image data or set it as null
            final image = item['image'] ?? '';

            return {
              'id': item['id']?.toString() ?? '',
              'menuName': item['name'] ?? 'Unknown Item',
              'quantity':item['quantity']??'N/A',
              'price': item['price'] ?? 'N/A',
              'image': image, // Store image as a string
            };
          }).toList();
        });
      }

    } catch (e) {
      print('Error fetching food menu: $e');

      // Only show SnackBar if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load food menu: $e'))
        );
      }
    }
  }

  @override
  void dispose() {
    // Cancel any ongoing operations or listeners if needed
    super.dispose();
  }

  void _updateCartItems(List<Map<String, dynamic>> updatedCartItems) {
    setState(() {
      cartItems = updatedCartItems;

      // Call onCartUpdated if it's not null
      widget.onCartUpdated?.call(cartItems);
    });
  }
  // bool _isValidBase64(String? base64String) {
  //   if (base64String == null || base64String.isEmpty) return false;
  //   try {
  //     base64Decode(base64String);
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        centerTitle: true,
        actions: [
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Additeampage(
                      cartItems: cartItems,
                      floorId: widget.floorId,
                      roomNo: widget.roomNo,
                      userName: widget.userName,
                      userId: widget.userId,
                      onCartUpdated: (updatedCartItems) {
                        _updateCartItems(updatedCartItems);
                      },
                    ),
                  ),
                );
              },
              child: badges.Badge(
                badgeContent: Text(
                  '${cartItems.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : foodMenu.isEmpty
          ? Center(child: Text('No food items found'))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: foodMenu.length,
          itemBuilder: (context, index) {
            final foodItem = foodMenu[index];

            // Find if this item is already in the cart
            final cartItemIndex = cartItems.indexWhere(
                    (item) => item['menuName'] == foodItem['menuName']
            );

            return ListTile(
              leading: _buildBase64Image(foodItem['image']),
              title: Text('${foodItem['menuName'] ?? 'Unknown Item'}(${foodItem['quantity']}-Pcs)'),
              subtitle: Text('Price: ${foodItem['price'] ?? 'N/A'}'),
              trailing: cartItemIndex != -1
                  ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (cartItems[cartItemIndex]['cardquantity'] > 1) {
                            cartItems[cartItemIndex]['cardquantity']--;
                          } else {
                            cartItems.removeAt(cartItemIndex);
                          }
                          _updateCartItems(cartItems);
                        });
                      },
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                    ),
                    Text('${cartItems[cartItemIndex]['cardquantity']}'),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          cartItems[cartItemIndex]['cardquantity']++;
                          _updateCartItems(cartItems);
                        });

                      },
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                    ),
                  ],
                ),
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    cartItems.add({
                      "menuName": foodItem['menuName'] ?? 'Unknown Item',
                      'quantity': foodItem['quantity'] ?? 'N/A',
                      "price": foodItem['price'] ?? '0.0',
                      "image": foodItem['image'] ?? '',
                      "cardquantity": 1,
                    });
                    _updateCartItems(cartItems);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${foodItem['menuName']} added to cart'),
                    ),
                  );
                },
                child: Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'ADD',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBase64Image(String? fileData) {
    if (fileData == null || fileData.isEmpty) {
      return const Icon(Icons.restaurant); // Fallback icon
    }

    try {
      // Remove data URL prefix if present
      if (fileData.contains(',')) {
        fileData = fileData.split(',').last;
      }

      return Image.memory(
        base64Decode(fileData),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return const Icon(Icons.broken_image);
        },
      );
    } catch (e) {
      print('Invalid image data: $e');
      return const Icon(Icons.broken_image);
    }
  }

}
