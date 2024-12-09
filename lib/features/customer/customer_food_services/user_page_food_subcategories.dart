import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/customer/customer_food_services/user_food_menu.dart';
// import 'package:holtelmanagement/features/customer/food/user_food_menu.dart';
import '../../../classes/language.dart';
import '../../../common/helpers/app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/categorymodel.dart';

import '../../services/apiservices.dart';


class Subcategories extends StatefulWidget {
  final int floorId;
  final int roomNo;
  final String userName;
  final int userId;
  final int? restaurantMenuCategoriesId;
  final Function(List<Map<String, dynamic>>)? onCartUpdated;


  const Subcategories({
    Key? key,
    required this.restaurantMenuCategoriesId,
    required this.floorId,
    required this.roomNo,
    required this.userName,
    required this.userId,
    this.onCartUpdated,
  }) : super(key: key);

  @override
  _SubcategoriesState createState() => _SubcategoriesState();
}

class _SubcategoriesState extends State<Subcategories> {
  List<SubCategoryModels> _subcategories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> cartItems = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchSubcategories();
  }

  Future<void> _fetchSubcategories() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Fetching subcategories for categoriesId: ${widget.restaurantMenuCategoriesId}');

      final subcategories = await ApiService().fetchAllRestaurantSubCategoryById(widget.restaurantMenuCategoriesId!);

      print('Fetched subcategories count: ${subcategories.length}');

      setState(() {
        _subcategories = subcategories;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Failed to load subcategories: ${e.toString()}';
        _isLoading = false;
      });
      print('Detailed error in _fetchSubcategories: $e');
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

      },apiService: _apiService,
      // backgroundColor: Colors.lightPink, // Light pink color as per preference
    ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
        itemCount: _subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = _subcategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          ),
              child: ListTile(
                leading: _getCategoryIcon(subcategory.restaurantMenuSubCategoryName),
                title: Text(subcategory.restaurantMenuSubCategoryName,
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${AppLocalizations.of(context).translate('cus_pg_subcategories_text_name')}: ${subcategory.restaurantMenuCategoryName}'),
                    if (subcategory.description != null)
                      Text('${AppLocalizations.of(context).translate('cus_pg_subcategories_text_description')}: ${subcategory.description}'),

                  ],
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: subcategory.isActive
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subcategory.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: subcategory.isActive
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
                      builder: (context) => FoodMenu(
                        restaurantMenuSubCategoriesId: subcategory.restaurantMenuSubCategoriesId,floorId: widget.floorId,roomNo: widget.roomNo,userId: widget.userId,userName: widget.userName,
                        onCartUpdated: (updatedCartItems) {
                          setState(() {
                            cartItems = updatedCartItems;
                          });
                        },
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