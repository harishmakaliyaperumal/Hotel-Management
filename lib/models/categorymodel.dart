class CategoryModel {
  final int restaurantMenuCatagoriesId;
  final String restaurantMenuCategoryName;
  final RestaurantModel restaurant;
  final bool restaurantMenuCatagoriesIsActive;
  final DateTime restaurantMenuCategoryCreatedOn;
  final DateTime restaurantMenuCategoryUpdatedOn;
  final int restaurantMenuCreatedBy;
  final int restaurantMenuCategoryUpdatedBy;

  CategoryModel({
    required this.restaurantMenuCatagoriesId,
    required this.restaurantMenuCategoryName,
    required this.restaurant,
    required this.restaurantMenuCatagoriesIsActive,
    required this.restaurantMenuCategoryCreatedOn,
    required this.restaurantMenuCategoryUpdatedOn,
    required this.restaurantMenuCreatedBy,
    required this.restaurantMenuCategoryUpdatedBy,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      restaurantMenuCatagoriesId: json['restaurantMenuCatagoriesId'],
      restaurantMenuCategoryName: json['restaurantMenuCategoryName'],
      restaurant: RestaurantModel.fromJson(json['restaurant']),
      restaurantMenuCatagoriesIsActive: json['restaurantMenuCatagoriesIsActive'],
      restaurantMenuCategoryCreatedOn: DateTime.parse(json['restaurantMenuCategoryCreatedOn']),
      restaurantMenuCategoryUpdatedOn: DateTime.parse(json['restaurantMenuCategoryUpdatedOn']),
      restaurantMenuCreatedBy: json['restaurantMenuCreatedBy'],
      restaurantMenuCategoryUpdatedBy: json['restaurantMenuCategoryUpdatedBy'],
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