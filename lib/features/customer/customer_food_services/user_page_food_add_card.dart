import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';

import '../../../classes/language.dart';
import '../../../common/helpers/app_bar.dart';
import '../../services/apiservices.dart';
import '../user_menu.dart';

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
  final int hotelId;
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
    required this.hotelId,
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
      // Show an AlertDialog instead of SnackBar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Your cart is empty'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final response = await _apiService.saveGeneralFoodRequest(
        floorId: widget.floorId,
        taskId: 237,
        roomDataId: widget.roomNo,
        rname: widget.userName,
        requestType: "Customer Request",
        description: _generateDescription(),
        requestDataCreatedBy: widget.userId,
        hotelId: widget.hotelId,
        restaurantId: widget.restaurantId ?? 0,
        restaurantCategoryId: widget.restaurantCategoryId ?? 0,
        restaurantSubCategoryId: widget.restaurantSubCategoryId ?? 0,
        restaurantMenu: widget.restaurantMenuId ?? 0,
      );

      // Show success AlertDialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Request submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Navigate to UserMenu after closing the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserMenu(
                      userName: widget.userName,
                      userId: widget.userId,
                      loginResponse: {}, // Pass the required loginResponse
                      roomNo: widget.roomNo,
                      floorId: widget.floorId,
                      hotelId: widget.hotelId,
                      rname: widget.userName,
                    ),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error AlertDialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {
          // Handle language change
        },
        isLoginPage: false,
        extraActions: [],
        dashboardType: DashboardType.user,
        onLogout: () {

          logOut(context);

        },apiService: _apiService,
        onLogoTap: () {
          // Navigate to UserMenu with the required parameters
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => UserMenu(
                userName: widget.userName,
                userId: widget.userId,
                floorId: widget.floorId,
                roomNo: widget.roomNo,
                rname: widget.userName,
                loginResponse: {},
                hotelId: widget.hotelId,
              ),
            ),
                (Route<dynamic> route) => false,
          );
        },
        // backgroundColor: Colors.lightPink, // Light pink color as per preference
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
               backgroundColor: const Color(0xFF2A6E75),
                padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Request Food',
                style: TextStyle(fontSize: 16.0,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
