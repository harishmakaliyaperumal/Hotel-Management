class CategoryModel {
  final int restaurantMenuCategoriesId; // Note the plural 'Categories'
  final String restaurantMenuCategoryName;
  // final String description;
  final bool isActive;



  CategoryModel({
    required this.restaurantMenuCategoriesId,
    required this.restaurantMenuCategoryName,
    // required this.description,
    required this.isActive,



  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      restaurantMenuCategoriesId: json['restaurantMenuCategoriesId'],
      restaurantMenuCategoryName: json['restaurantMenuCategoryName'],
      // description:json['description'],
      isActive: json['isActive']



    );
  }
}

class RestaurantModel {
  final int restaurantId;
  final String restaurantName;
  final String restaurantEmailId;
  final String restaurantMobileNo;
  final String restaurantOpeningTime;
  final String restaurantClosingTime;
  final DateTime restaurantCreatedOn;
  final int restaurantCreatedBy;
  final int? restaurantUpdatedBy;
  final DateTime restaurantUpdatedOn;
  final bool restaurantIsActive;

  RestaurantModel({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantEmailId,
    required this.restaurantMobileNo,
    required this.restaurantOpeningTime,
    required this.restaurantClosingTime,
    required this.restaurantCreatedOn,
    required this.restaurantCreatedBy,
    this.restaurantUpdatedBy,
    required this.restaurantUpdatedOn,
    required this.restaurantIsActive,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      restaurantEmailId: json['restaurantEmailId'],
      restaurantMobileNo: json['restaurantMobileNo'],
      restaurantOpeningTime: json['restaurantOpeningTime'],
      restaurantClosingTime: json['restaurantClosingTime'],
      restaurantCreatedOn: DateTime.parse(json['restaurantCreatedOn']),
      restaurantCreatedBy: json['restaurantCreatedBy'],
      restaurantUpdatedBy: json['restaurantUpdatedBy'],
      restaurantUpdatedOn: DateTime.parse(json['restaurantUpdatedOn']),
      restaurantIsActive: json['restaurantIsActive'],
    );
  }
}

class SubCategoryModels{
    final  int restaurantMenuSubCategoriesId;
    final int restaurantMenuCategoriesId;
    final String restaurantMenuCategoryName;
    final String? description;
    final String restaurantMenuSubCategoryName;
    final bool isActive;


    SubCategoryModels({
      required this.restaurantMenuSubCategoriesId,
      required this.restaurantMenuCategoriesId,
      required this.restaurantMenuCategoryName,
      this.description, // Make this optional
      required this.restaurantMenuSubCategoryName,
      required this.isActive,
  });
    factory SubCategoryModels.fromJson(Map<String, dynamic> json) {
      return  SubCategoryModels(
          restaurantMenuSubCategoriesId:json['restaurantMenuSubCategoriesId'],
          restaurantMenuCategoriesId:json['restaurantMenuCategoriesId'],
          restaurantMenuCategoryName:json['restaurantMenuCategoryName'],
          description:json['description'],
          restaurantMenuSubCategoryName: json['restaurantMenuSubCategoryName'],
          isActive: json['isActive'] ?? false,

      );}
}

class FoodMenuModels{

}


