import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:holtelmanagement/common/helpers/app_bar.dart';
import 'package:holtelmanagement/features/dashboard/screens/users_page_screens/user_categoriesPage.dart';
import 'package:holtelmanagement/features/dashboard/screens/users_page_screens/user_food_services.dart';
import 'package:holtelmanagement/features/dashboard/screens/users_page_screens/user_request_services.dart';

import '../../../../classes/language.dart';
import '../../../services/apiservices.dart';
import 'demo.dart';

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
      // print('Processed Restaurants: $fetchedRestaurants'); // Debug print
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
                      : const Icon(Icons.restaurant),// Fallback icon if no image URL is provided
                  title: Text(restaurant['name']),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          print('Restaurant ID: ${restaurant['restaurantId']}');
                          return  CategoriesPage();
                        },
                      ),
                    );
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
      const Text(
           'Welcome to User Menu',
            style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                    child: const Text(
                      'FOOD SERVICES',
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
                    child: const Text(
                      'REQUEST SERVICES',
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