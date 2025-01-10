import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:holtelmanagement/common/helpers/app_bar.dart';
import 'package:holtelmanagement/features/customer/customer_other_services/otherservices.dart';
import '../../classes/language.dart';
import '../../l10n/app_localizations.dart';
import '../services/apiservices.dart';
import 'customer_food_services/userpage_food_categories.dart';
import 'customer_history.dart';
import 'customer_requset_services/user_page_requset_services.dart';

class UserMenu extends StatefulWidget {
  final String userName;
  final int userId;
  final Map<String, dynamic> loginResponse;
  final int roomNo;
  final int floorId;
  final String rname;

  const UserMenu({
    super.key,
    required this.userName,
    required this.userId,
    required this.loginResponse,
    required this.roomNo,
    required this.floorId,
    required this.rname,
  });

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  final ApiService _apiService = ApiService();

  // Single source of truth for state
  List<Map<String, dynamic>> _restaurants = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final fetchedRestaurants = await _apiService.fetchRestaurants();

      if (!mounted) return;

      setState(() {
        _restaurants = fetchedRestaurants;
        _isInitialized = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  Widget _buildBase64Image(dynamic mediaFiles) {
    if (mediaFiles == null || mediaFiles is! List || mediaFiles.isEmpty) {
      return const Icon(Icons.restaurant);
    }

    try {
      final mediaFile = mediaFiles[0];
      String? fileData = mediaFile['fileData'];

      if (fileData == null || fileData.isEmpty) {
        return const Icon(Icons.restaurant);
      }

      fileData = fileData.contains(',') ? fileData.split(',').last : fileData;

      return Image.memory(
        base64Decode(fileData),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } catch (e) {
      debugPrint('Error loading image: $e');
      return const Icon(Icons.broken_image);
    }
  }

  void _showRestaurantDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('user_menu_page_alertdialog_select_restaurant')),
          content: _buildDialogContent(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).translate('user_menu_page_alertdialog_cancel')),
            ),
            if (_error != null)
              TextButton(
                onPressed: _loadRestaurants,
                child: Text(AppLocalizations.of(context).translate('retry')),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDialogContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate('no_restaurants_available'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _restaurants.map((restaurant) {
          return ListTile(
            leading: _buildBase64Image(restaurant['image']),
            title: Text(restaurant['name'] ?? ''),
            onTap: () => _handleRestaurantSelection(restaurant),
          );
        }).toList(),
      ),
    );
  }

  void _handleRestaurantSelection(Map<String, dynamic> restaurant) {
    int? restaurantId;

    if (restaurant['id'] is int) {
      restaurantId = restaurant['id'];
    } else if (restaurant['id'] is String) {
      restaurantId = int.tryParse(restaurant['id']);
    }

    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('invalid_restaurant_selection')
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesPage(
          restaurantId: restaurantId,
          userId: widget.userId,
          floorId: widget.floorId,
          roomNo: widget.roomNo,
          userName: widget.userName,
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0x882F919B),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Color(0xFF2A6E75),
          width: 2.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {},
        isLoginPage: false,
        extraActions: [],
        dashboardType: DashboardType.user,
        onLogout: () => logOut(context),
        apiService: _apiService,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context).translate('user_menu_pg_htext'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Food Services Card
              _buildServiceCard(
                title: AppLocalizations.of(context).translate('user_menu_card_Htext_FS'),
                imagePath: 'assets/images/food_services_image.png',
                onTap: () async {
                  // First load restaurants
                  if (!_isInitialized || _error != null) {
                    await _loadRestaurants();
                  }

                  if (!mounted) return;

                  // Then show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    },
                  );

                  // Add a small delay to show loading indicator
                  await Future.delayed(const Duration(milliseconds: 500));

                  if (context.mounted) {
                    // Remove loading dialog
                    Navigator.of(context).pop();
                    // Show restaurant dialog
                    _showRestaurantDialog();
                  }
                },
              ),
              const SizedBox(height: 20),

              // Request Services Card
              _buildServiceCard(
                title: AppLocalizations.of(context).translate('user_menu_card_Htext_RS'),
                imagePath: 'assets/images/request_services_image.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserDashboard(
                      userName: widget.userName,
                      userId: widget.userId,
                      roomNo: widget.roomNo,
                      floorId: widget.floorId,
                      rname: widget.rname,
                      loginResponse: widget.loginResponse,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Other Services Card
              _buildServiceCard(
                title: AppLocalizations.of(context).translate('user_menu_card_Htext_OS'),
                imagePath: 'assets/images/request_services_image.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDropdownPage(
                      userName: widget.userName,
                      userId: widget.userId,
                      roomNo: widget.roomNo,
                      floorId: widget.floorId,
                      rname: widget.rname,
                      loginResponse: widget.loginResponse,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Order History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)
                        .translate('user_menu_card_text_order_history'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/oderhistory.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerHistory(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A6E75),
                ),
                child: Text(
                  AppLocalizations.of(context).translate('user_menu_page_order_button'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}