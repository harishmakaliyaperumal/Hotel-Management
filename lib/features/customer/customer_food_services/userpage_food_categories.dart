import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/customer/customer_food_services/user_page_food_subcategories.dart';
// import 'package:holtelmanagement/features/customer/food/user_page_food_subcategories.dart';

import '../../../classes/language.dart';
import '../../../common/helpers/app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/categorymodel.dart';
import '../../services/apiservices.dart';

class CategoriesPage extends StatefulWidget {
  final int floorId;
  final int roomNo;
  final String userName;
  final int userId;
  final int? restaurantId;




  const CategoriesPage({
    Key? key,
    required this.restaurantId,
    required this.floorId,
    required this.roomNo,
    required this.userName,
    required this.userId,


  }) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (widget.restaurantId == null) {
      setState(() {
        _errorMessage = 'Restaurant ID is missing';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Fetching categories for restaurantId: ${widget.restaurantId}');

      final categories = await ApiService()
          .fetchCategoriesByRestaurantId(widget.restaurantId!);

      print('Fetched categories count: ${categories.length}');

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Failed to load categories: ${e.toString()}';
        _isLoading = false;
      });
      print('Detailed error in _fetchCategories: $e');
      print('Stacktrace: $stackTrace');
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
        },
        apiService: _apiService,
        // backgroundColor: Colors.lightPink, // Light pink color as per preference
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: _getCategoryIcon(
                              category.restaurantMenuCategoryName),
                          title: Text(
                            category.restaurantMenuCategoryName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: category.isActive
                                  ? Colors.green.shade100
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: category.isActive
                                    ? Colors.green.shade800
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Subcategories(
                                  restaurantCategoryId: category.restaurantCategoryId,
                                  restaurantId: widget.restaurantId!,
                                  roomNo: widget.roomNo,
                                  userName: widget.userName,
                                  userId: widget.userId,
                                  floorId: widget.floorId,

                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

// Helper method to get category-specific icon
  Icon _getCategoryIcon(String categoryName) {
    // Default food-related icon if no match found
    return Icon(Icons.restaurant_menu, color: Colors.grey.shade600);
  }
}
