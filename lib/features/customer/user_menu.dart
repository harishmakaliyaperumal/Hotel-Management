import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:holtelmanagement/common/helpers/app_bar.dart';
// import 'package:holtelmanagement/features/customer/food/userpage_food_categories.dart';
// import 'package:holtelmanagement/features/customer/services/user_page_requset_services.dart';
import '../../classes/language.dart';
import '../../l10n/app_localizations.dart';
import '../services/apiservices.dart';
import 'customer_food_services/userpage_food_categories.dart';
import 'customer_requset_services/user_page_requset_services.dart';


class UserMenu extends StatefulWidget {
  final String userName;
  final int userId;
  final Map<String, dynamic> loginResponse;
  final int roomNo;
  final int floorId;
  final String rname;


  const UserMenu({super.key,
    required this.userName,
    required this.userId,
    required this.loginResponse,
    required this.roomNo,
    required this.floorId,
    required this.rname});

  @override
  State<UserMenu> createState() => _UserMenuState();

}

class _UserMenuState extends State<UserMenu> {
  final ApiService _apiService = ApiService();
  // Language _selectedLanguage = Language.languageList()[0];
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }
  Future<void> _loadRestaurants() async {
    setState(() => isLoading = true);
    try {
      final fetchedRestaurants = await _apiService.fetchRestaurants();

      // Detailed debug print
      print('Raw Restaurants Data: $fetchedRestaurants');

      // // Check each restaurant's structure
      // fetchedRestaurants.forEach((restaurant) {
      //   print('Restaurant Entry:');
      //   print('Keys: ${restaurant.keys}');
      //   print('restaurantId: ${restaurant['restaurantId']}');
      //   print('name: ${restaurant['name']}');
      // });

      setState(() => restaurants = fetchedRestaurants);

    } catch (e) {
      print('Error fetching restaurants: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildBase64Image(dynamic mediaFiles) {
    if (mediaFiles == null || mediaFiles.isEmpty) {
      print('No media files provided');
      return const Icon(Icons.restaurant);
    }

    try {
      // Get the first media file
      final mediaFile = mediaFiles[0];
      String? fileData = mediaFile['fileData'];

      if (fileData == null || fileData.isEmpty) {
        print('No file data in media files');
        return const Icon(Icons.restaurant);
      }

      // Remove data URL prefix if present
      if (fileData.contains(',')) {
        fileData = fileData.split(',').last;
      }

      // print('Attempting to decode image of length: ${fileData.length}');

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

  void _showRestaurantDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Restaurant'),
          content: isLoading
              ? const Center(child: CircularProgressIndicator())
              : restaurants.isEmpty
              ? const Text('No restaurants available')
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: restaurants.map((restaurant) {
                return ListTile(
                  leading: restaurant['image'] != null
                      ? _buildBase64Image(restaurant['image'])
                      : const Icon(Icons.restaurant),
                  title: Text(restaurant['name']),
                  onTap: () {
                    int? restaurantId;

                    if (restaurant['id'] is int) {
                      restaurantId = restaurant['id'];
                    } else if (restaurant['id'] is String) {
                      restaurantId = int.tryParse(restaurant['id']);
                    }

                    if (restaurantId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid Restaurant Selection'))
                      );
                      return;
                    }
                    // print('Selected Restaurant ID: $restaurantId');
                    // print('Restaurant Data: $restaurant');
                    Navigator.of(context).pop();
                    if (restaurantId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoriesPage(
                            restaurantId: restaurantId!,
                            // Use ! to assert non-nullability
                            userId: widget.userId,
                            floorId: widget.floorId,
                            roomNo: widget.roomNo,userName: widget.userName,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid Restaurant Selection'))
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }


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
        // backgroundColor: Colors.lightPink, // Light pink color as per preference
      ),
      body: Container(
       padding:  EdgeInsets.all(20),
         child: Column(

      mainAxisAlignment: MainAxisAlignment.center,
      children: [
       Center(
         child: Text(
           AppLocalizations.of(context).translate('user_menu_pg_htext'),
              style: TextStyle(

                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                 ),
       ),
       const SizedBox(height: 30),
        Container(
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: _showRestaurantDialog,
                  child: Container(
                    width: 200,
                    height: 100,
                    alignment: Alignment.center,
                    child:  Text(
                      AppLocalizations.of(context).translate('user_menu_card_Htext_FS'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          const SizedBox(height: 20),
          // REQUEST SERVICES card
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDashboard(
                          userName: widget.userName,
                          userId: widget.userId,
                          roomNo: widget.roomNo,
                          floorId: widget.floorId,
                          rname: widget.rname,
                          loginResponse: widget.loginResponse,)
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 100,
                    alignment: Alignment.center,
                    child:  Text(
                      AppLocalizations.of(context).translate('user_menu_card_Htext_RS'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
 }