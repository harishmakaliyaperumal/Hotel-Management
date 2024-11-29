import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

// import '../../../../../services/apiservices.dart';
import 'food_card_menu.dart';
import 'carditem.dart';
class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}




class _ProductState extends State<Product> {
  List<String> productName = [
    'Chicken tikka masala',
    'Butter chicken',
    'Dal Makhni',
    'Fish molee',
  ];
  List<String> productPrice = ['29', '33', '44', '76'];
  List<String> productImage = [
    'assets/images/foods/food_services_slide_img-1.png',
    'assets/images/foods/food_services_slide_img-2.png',
    'assets/images/foods/food_services_slide_img-3.png',
    'assets/images/foods/food_services_slide_img-2.png',
  ];

  List<Map<String, dynamic>> cartItems = [];

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
                // Convert List<Map<String, dynamic>> to List<CartItem>
                final cartItemsList = cartItems.map((item) => CartItem.fromMap(item)).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(cartItems: cartItemsList),
                  ),
                );
              },

              child: badges.Badge(
                badgeContent: Text(
                  '${cartItems.length}', // Show the number of items in the cart
                  style: const TextStyle(color: Colors.white),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: productName.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image(
                              height: 100,
                              width: 100,
                              image: AssetImage(productImage[index]),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName[index],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '\$${productPrice[index]}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          cartItems.add({
                                            "name": productName[index],
                                            "price": productPrice[index],
                                            "image": productImage[index],
                                          });
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${productName[index]} added to cart'),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                          BorderRadius.circular(5),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'ADD',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}