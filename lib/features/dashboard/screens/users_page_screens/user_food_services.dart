import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:holtelmanagement/features/dashboard/screens/users_page_screens/food_menu/food_products/food_product_card.dart';

import '../../../../classes/language.dart';
import '../../../../common/helpers/app_bar.dart';
import '../../../services/apiservices.dart';

class UserFoodServices extends StatefulWidget {
  final String selectedRestaurant;

  const UserFoodServices({
    Key? key,
    this.selectedRestaurant = 'Unknown'
  }) : super(key: key);

  @override
  State<UserFoodServices> createState() => _UserFoodServicesState();
}

class _UserFoodServicesState extends State<UserFoodServices> {
  final ApiService _apiService = ApiService();
  late String _restaurantId;

  @override
  void initState() {
    super.initState();
    _restaurantId = widget.selectedRestaurant.toString();
  }





  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = [
      'assets/images/foods/food_services_slide_img-1.png',
      'assets/images/foods/food_services_slide_img-2.png',
      'assets/images/foods/food_services_slide_img-3.png',
    ];

    final List<Map<String, String>> cuisines = [
      {'image': 'assets/images/foods/food_services_slide_img-1.png', 'name': 'Italian cuisine', 'price': '\$15'},
      {'image': 'assets/images/foods/food_services_slide_img-2.png', 'name': 'American Chinese cuisine','price': '\$20'},
      {'image': 'assets/images/foods/food_services_slide_img-3.png', 'name': 'Japanese Cuisine', 'price': '\$12'},
      {'image': 'assets/images/foods/food_services_slide_img-1.png', 'name': 'French cuisine', 'price': '\$18'},
    ];
    final List<Map<String, String>> regualrfood = [
      {'image': 'assets/images/foods/food_services_slide_img-1.png', },
      {'image': 'assets/images/foods/food_services_slide_img-2.png',},
      {'image': 'assets/images/foods/food_services_slide_img-3.png', },
      {'image': 'assets/images/foods/food_services_slide_img-1.png',},
      {'image': 'assets/images/foods/food_services_slide_img-1.png',},
    ];

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {
          // Handle language change
        },
        isLoginPage: false,
        extraActions: [],
        dashboardType: DashboardType.other,
        onLogout: () {
          logOut(context);
        },
        apiService: _apiService,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today Special Foods',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),),
            // Carousel Section
            FlutterCarousel(
              items: imagePaths.map((imagePath) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 100,
                autoPlay: true,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                autoPlayInterval: const Duration(seconds: 3),
              ),
            ),

            const SizedBox(height: 20),  // Spacer

            // Food categiries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Foods Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),  // Spacer

            // Horizontal Scrolling Row of Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: regualrfood.map((regualrfood) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Product(),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SizedBox(
                        width: 150,
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image
                            Image.asset(
                              regualrfood['image']!,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            // Name
                            Text(
                              regualrfood['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            // Price
                            Text(
                              regualrfood['price']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
