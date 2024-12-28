class CategoryModel {
  final int restaurantCategoryId; // Note the plural 'Categories'
  final String restaurantMenuCategoryName;
  // final String description;
  final bool isActive;



  CategoryModel({
    required this.restaurantCategoryId,
    required this.restaurantMenuCategoryName,
    // required this.description,
    required this.isActive,



  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
        restaurantCategoryId: json['restaurantMenuCategoriesId'],
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
    final  int restaurantSubCategoryId;
    final int restaurantCategoryId;
    final String restaurantMenuCategoryName;
    final String? description;
    final String restaurantMenuSubCategoryName;
    final bool isActive;


    SubCategoryModels({
      required this.restaurantSubCategoryId,
      required this.restaurantCategoryId,
      required this.restaurantMenuCategoryName,
      this.description, // Make this optional
      required this.restaurantMenuSubCategoryName,
      required this.isActive,
  });
    factory SubCategoryModels.fromJson(Map<String, dynamic> json) {
      return  SubCategoryModels(
        restaurantSubCategoryId:json['restaurantMenuSubCategoriesId'],
          restaurantCategoryId:json['restaurantMenuCategoriesId'],
          restaurantMenuCategoryName:json['restaurantMenuCategoryName'],
          description:json['description'],
          restaurantMenuSubCategoryName: json['restaurantMenuSubCategoryName'],
          isActive: json['isActive'] ?? false,

      );}
}




// Task Category Model
class TaskCategoryModel {
  final int taskCategoryId;
  final String taskCategoryName;
  final bool taskCategoryIsActive;
  final int taskCategorgyCreatedBy;


  TaskCategoryModel({
    required this.taskCategoryId,
    required this.taskCategoryName,
    required this. taskCategorgyCreatedBy,
    required this.taskCategoryIsActive,
  });

  factory TaskCategoryModel.fromJson(Map<String, dynamic> json) {
    return TaskCategoryModel(
      taskCategoryId: json['TaskCategoryId'] as int,
      taskCategoryIsActive: json['TaskCategoryIsActive'] as bool,
      taskCategoryName: json['TaskCategoryName'] as String,
      taskCategorgyCreatedBy: json['taskCategorgyCreatedBy'] as int,
    );
  }
}

// Task Subcategory Model
class TaskSubcategoryModel {
  final int taskSubCategoryId;
  final String taskSubCategoryName;
  final int taskCategoryId;
  final bool taskSubcategoryIsActive;

  TaskSubcategoryModel({
    required this.taskSubCategoryId,
    required this.taskSubCategoryName,
    required this.taskCategoryId,
    required this.taskSubcategoryIsActive,
  });

  factory TaskSubcategoryModel.fromJson(Map<String, dynamic> json) {
    // Print raw JSON for debugging
    print('Subcategory Raw JSON: $json');

    // Handle nested category structure
    int? extractedCategoryId;
    if (json.containsKey('taskCategory') && json['taskCategory'] is Map) {
      extractedCategoryId = json['taskCategory']['taskCategoryId'];
    } else {
      extractedCategoryId = json['taskCategoryId'];
    }

    return TaskSubcategoryModel(
      taskSubCategoryId: _parseIntSafely(json, [
        'taskSubCategoryId',
        'TaskSubcategoryId',
        'id'
      ]),
      taskSubCategoryName: _parseStringSafely(json, [
        'taskSubCategoryName'as String,
        'TaskSubCategoryName'as String,
        'name'
      ]),
      taskCategoryId: extractedCategoryId ?? 0,
      taskSubcategoryIsActive: _parseBoolSafely(json, [
        'taskSubcategoryIsActive',
        'TaskSubcategoryIsActive',
        'isActive'
      ]),
    );
  }

  // Existing helper methods...
  static int _parseIntSafely(Map json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key] is int
            ? json[key]
            : int.tryParse(json[key].toString()) ?? 0;
      }
    }
    return 0;
  }

  static String _parseStringSafely(Map json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key].toString();
      }
    }
    return '';
  }

  static bool _parseBoolSafely(Map json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        if (json[key] is bool) return json[key];
        if (json[key] is int) return json[key] != 0;
        if (json[key] is String) {
          return ['true', '1', 'yes'].contains(json[key].toLowerCase());
        }
      }
    }
    return false;
  }
}


// Customer Task Model
class CustomerTaskModel {
  final String taskName;
  final int taskId;

  CustomerTaskModel({
    required this.taskName,
    required this.taskId
  });

  factory CustomerTaskModel.fromJson(Map<String, dynamic> json) {
    return CustomerTaskModel(
        taskName: (json['taskName'] ?? '').toString(),
        taskId: json['taskId'] is int
            ? json['taskId']
            : int.tryParse(json['taskId']?.toString() ?? '0') ?? 0
    );
  }
}







