import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/categorymodel.dart';
import '../../utility/token.dart';
import '../customer/customerhistorymodels/cus_his_models.dart';
import '../dashboard/services/services_models/ser_models.dart';
import '../kitchenMenu/kitchen_models/data.dart';


class ApiService {
  final String baseUrl = 'https://www.hotels.annulartech.net';
  // Login functional
  Future<Map<String, dynamic>> login(String userEmailId, String password,) async {
    final String loginUrl = '$baseUrl/user/login';

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "userEmailId": userEmailId,
          "userPassword": password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Successful login, return the response data (e.g., token or user info)

        final tokenProvider = TokenProvider();
        if (data['jwt'] != null) {
          await tokenProvider.saveToken(data['jwt']);
        }

        return data;
      } else {
        // Handle server errors
        return {
          'error': 'Failed to login. Status code: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      // Handle network or other errors
      return {
        'error': 'An error occurred during login',
        'details': e.toString()
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/request/getAllCustomerTaskData'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Use utf8.decode to handle potential encoding issues
        final responseBody = utf8.decode(response.bodyBytes);
        final decodedResponse = jsonDecode(responseBody);

        if (decodedResponse['status'] == 1) {
          List<dynamic> data = decodedResponse['data'];
          // print('Task Data: $data'); // Debugging
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          throw Exception('Failed to fetch tasks: ${decodedResponse['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<List<TaskCategoryModel>> fetchTaskCategories() async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/task/getAllTaskCategoryDetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => TaskCategoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load task categories');
      }
    } catch (e) {
      print('Error in fetchTaskCategories: $e');
      rethrow;
    }
  }

  Future<List<TaskSubcategoryModel>> fetchTaskSubcategories(int taskCategoryId) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/task/getTaskCategoryListById?taskCategoryId=$taskCategoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Subcategories Response Status Code: ${response.statusCode}');
      print('Subcategories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        List<dynamic> jsonList = [];
        if (jsonResponse is Map<String, dynamic>) {
          jsonList = jsonResponse['data'] ?? [];
        } else if (jsonResponse is List) {
          jsonList = jsonResponse;
        }

        return jsonList
            .where((json) => json != null && json is Map<String, dynamic>)
            .map((json) => TaskSubcategoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load task subcategories: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchTaskSubcategories: $e');
      rethrow;
    }
  }




  // Similar modifications for fetchCustomerTasks
  Future<List<CustomerTaskModel>> fetchCustomerTasks(int taskSubCategoryId) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/task/getAllTaskNameBySubCategoryById?taskSubCategoryId=$taskSubCategoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        // Ensure we always work with a list
        List<dynamic> jsonList = [];
        if (jsonResponse is Map<String, dynamic>) {
          jsonList = jsonResponse['data'] ?? jsonResponse['tasks'] ?? [];
        } else if (jsonResponse is List) {
          jsonList = jsonResponse;
        }

        // More robust parsing
        return jsonList
            .where((json) => json != null)
            .map((json) {
          try {
            return CustomerTaskModel.fromJson(json);
          } catch (e) {
            print('Parsing error for task: $json, Error: $e');
            return null;
          }
        })
            .whereType<CustomerTaskModel>()
            .toList();
      } else {
        throw Exception('Failed to load customer tasks: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchCustomerTasks: $e');
      rethrow;
    }
  }



  Future<void> saveGeneralRequest({
    required int floorId,
    required int taskId,
    required int roomDataId,
    required String rname,
    required String requestType,
    required String description,
    required int requestDataCreatedBy,
    required int taskCategoryId,
    required int taskSubCategoryId,
    String? descriptionNorwegian,
    String? descriptionArabian,
  }) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception(

            'Authentication token is missing. Please log in again.');
      }

      // Prepare the request body with conditional description fields
      final body = {
        "floorId": floorId,
        "taskId": taskId,
        "roomDataId": roomDataId,
        "rname": rname,
        "requestType": requestType,
        "requestDataCreatedBy": requestDataCreatedBy,
        "taskSubCategoryId":taskSubCategoryId,
        "taskCategoryId":taskCategoryId
      };
      // Add description based on availability
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      if (descriptionNorwegian != null && descriptionNorwegian.isNotEmpty) {
        body['descriptionNorwegian'] = descriptionNorwegian;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/request/saveGeneralRequest'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("Request Body: $body");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");


      if (response.statusCode != 200) {
        throw Exception('Failed to send request');
      }
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
  }

  Future<void> saveGeneralFoodRequest({
    required int floorId,
    required int taskId,
    required int roomDataId,
    required String rname,
    required String requestType,
    required String description,
    required int requestDataCreatedBy,
    required int restaurantId,
    required int restaurantCategoryId,
    required int restaurantSubCategoryId,
    required int restaurantMenu,
    String? descriptionNorwegian,
    String? descriptionArabian,
  }) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception(

            'Authentication token is missing. Please log in again.');
      }

      // Prepare the request body with conditional description fields
      final body = {
        "floorId": floorId,
        "taskId": taskId,
        "roomDataId": roomDataId,
        "rname": rname,
        "requestType": requestType,
        "requestDataCreatedBy": requestDataCreatedBy,
        "restaurantSubCategoryId":restaurantSubCategoryId,
        "restaurantCategoryId":restaurantCategoryId,
        "restaurantId":restaurantId,
        "restaurantMenu":restaurantMenu,
        "description":description,

      };




      // Add description based on availability
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      if (descriptionNorwegian != null && descriptionNorwegian.isNotEmpty) {
        body['descriptionNorwegian'] = descriptionNorwegian;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/request/saveGeneralRequest'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("Request Body: $body");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");


      if (response.statusCode != 200) {
        throw Exception('Failed to send request');
      }else{
        print('chenkelse');
      }
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
  }



  Future<void> notifyBreaks(int userId) async {
    // final String url = '$baseUrl/break/saveBreakDetails';
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception(
            'Authentication token is missing. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/break/saveBreakDetails'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId,
          'message': 'Break notification from user', // Customize as needed
        }),
      );
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to notify breaks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to notify breaks: $e');
    }
  }

  Future<List<dynamic>> getAllBreakRequests() async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception(
            'Authentication token is missing. Please log in again.');
      }
      // final String getallbreakrequestUrl = '$baseUrl/break/getBreakRequstById';

      final response = await http.get(
        Uri.parse('$baseUrl/break/getBreakRequstById'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 1 && jsonResponse['data'] != null) {
          return jsonResponse['data'] as List<dynamic>;
        }
      }
      return []; // Return empty list if any condition fails
    } catch (e) {
      print('Error fetching break requests: $e');
      return []; // Return empty list on error
    }
  }

  Future<Map<String, dynamic>> updateJobStatus(bool jobStatus, String userId) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception(
            'Authentication token is missing. Please log in again.');
      }

      // final prefs = await SharedPreferences.getInstance();
      // final String? token = prefs.getString('jwt');
      final url = Uri.parse(
          '$baseUrl/hotelapp/updateJobStatus?userId=$userId&jobStatus=$jobStatus');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },

      );
      print('userId:$userId,$jobStatus');
      print('jobStatus:$jobStatus');

      if (response.statusCode == 200) {
        // print('checkdeed${response.body}');
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getGeneralRequestsById() async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception(
            'Authentication token is missing. Please log in again.');
      }
      // Get the JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // Make the GET request
      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getGeneralRequestById'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Check the status code and log the response
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response body
        final decodedResponse = json.decode(response.body);

        // If the response is a Map, convert it to a List
        if (decodedResponse is Map<String, dynamic>) {
          if (decodedResponse.containsKey('data') &&
              decodedResponse['data'] is List) {
            final List<dynamic> jsonResponse = decodedResponse['data'];

            // Convert each item in the list to a Map with proper type handling
            final List<Map<String, dynamic>> typedData =
            jsonResponse.map((item) {
              // print('descrittionNorweign: ${item['descrittionNorweign']}');
              // print(item);

              return {
                'id': item['id']?.toString() ?? '',
                'userName': item['userName']?.toString() ?? '',
                'taskName': item['taskName']?.toString() ?? '',
                'Description': item['Description']?.toString() ?? '',
                'DescriptionNorweign': item['DescriptionNorweign']
                    ?.toString() ?? '',
                'name': item['name']?.toString() ?? '',
                'roomName': item['roomName']?.toString() ?? '',
                'jobStatus': item['jobStatus']?.toString() ?? '',
                'roomId': item['roomId']?.toString() ?? '',
                'nextJobStatus': item['nextJobStatus']?.toString() ?? '',
                'requestJobHistoryId':
                item['requestJobHistoryId']?.toString() ?? '',
                'flag': item['flag']?.toString() ?? '',
              };
            }).toList();
            // Store the response in SharedPreferences
            await prefs.setString('generalRequests', json.encode(typedData));


            // print('Processed ${typedData.length} requests');
            return typedData;
          } else {
            throw Exception('Unexpected response format: No data found.');
          }
        } else {
          throw Exception(
              'Expected a Map but got ${decodedResponse.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGeneralRequestsById: $e');
      throw Exception('Failed to fetch general requests: $e');
    }
  }

  Future<void> Statusupdate(int userId, String jobStatus,
      String requestJobHistoryId) async {
    final tokenProvider = TokenProvider();
    final token = await tokenProvider.getToken();
    // final prefs = await SharedPreferences.getInstance();
    // final String? token = prefs.getString('jwt');

    // final String statusupdateUrl = '$baseUrl/hotelapp/updateRequstJobStatus?userId=$userId&jobStatus=$jobStatus&requestJobHistoryId=$requestJobHistoryId';
    final response = await http.put(
      Uri.parse(
          '$baseUrl/hotelapp/updateRequstJobStatus?userId=$userId&jobStatus=$jobStatus&requestJobHistoryId=$requestJobHistoryId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "userId": userId,
        "jobStatus": jobStatus,
        "requestJobHistoryId": requestJobHistoryId,
      }),
    );


    // print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      print("Task updated successfully");
    } else {
      print("Failed to update task: ${response.body}");
      throw Exception('Failed to update task');
    }
  }

  // Future<List<Map<String,dynamic>>> getCustomerRequestsById() async {
  //   try {
  //     final tokenProvider = TokenProvider();
  //     final token = await tokenProvider.getToken();
  //
  //     if (token == null) {
  //       print('Authentication token is missing. Please log in again.');
  //       return [];
  //     }
  //
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/hotelapp/getByCustomerRequestById'),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Decode response body with UTF-8
  //       final responseBody = utf8.decode(response.bodyBytes);
  //       final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
  //
  //       if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
  //         // Parse data into a typed list of maps
  //         final List<Map<String, dynamic>> typedData =
  //         (jsonResponse['data'] as List).map((item) {
  //           return {
  //             'requestDataId': item['requestDataId']?.toString(),
  //             'rname': item['rname'] ?? 'Unknown',
  //             'taskName': item['taskName'] ?? 'Unknown Task',
  //             'taskNorweign': item['taskNorweign'] ?? 'Unknown Task',
  //             'taskArabian': item['taskArabian'] ?? 'Unknown Task',
  //             'description': item['description'] ?? '',
  //             'descriptionNorweign': item['descriptionNorweign'] ?? '',
  //             'descriptionArabian': item['descriptionArabian'] ?? '',
  //             'starttime': item['starttime'] ?? '',
  //             'endTime': item['endTime'] ?? '',
  //             'jobStatus': item['jobStatus'] ?? '',
  //             'floorName': item['floorName'] ?? 'Unknown Floor',
  //             'requestDataIsActive': item['requestDataIsActive'] ?? false,
  //           };
  //         }).toList();
  //
  //         // Cache the response data
  //         await prefs.setString('customerRequests', jsonEncode(typedData));
  //         return typedData;
  //       } else {
  //         print('Unexpected response structure: $jsonResponse');
  //         return [];
  //       }
  //     } else {
  //       print('Failed to fetch data. HTTP Status: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error in getCustomerRequestsById: $e');
  //
  //     // Attempt to use cached data
  //     final prefs = await SharedPreferences.getInstance();
  //     final cachedRequestsString = prefs.getString('customerRequests');
  //     if (cachedRequestsString != null) {
  //       try {
  //         final List<dynamic> cachedRequests = jsonDecode(cachedRequestsString);
  //         return cachedRequests.cast<Map<String, dynamic>>();
  //       } catch (cacheError) {
  //         print('Error parsing cached requests: $cacheError');
  //       }
  //     }
  //
  //     return [];
  //   }
  // }


  // model with histoiry
  Future<List<CustomerRequest>> getCustomerRequestsById() async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        print('Authentication token is missing. Please log in again.');
        return [];
      }

      final prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getByCustomerRequestById'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['status'] == 1 && jsonResponse.containsKey('data')) {
          // Convert the raw data to a list of CustomerRequest objects
          final List<CustomerRequest> requests = (jsonResponse['data'] as List)
              .map((item) => CustomerRequest.fromMap(item))
              .toList();

          // Cache the response data as a list of maps
          await prefs.setString('customerRequests', jsonEncode(
              requests.map((request) => request.toMap()).toList()
          ));
          return requests;
        } else {
          print('Unexpected response structure: $jsonResponse');
          return [];
        }
      } else {
        print('Failed to fetch data. HTTP Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in getCustomerRequestsById: $e');
      final prefs = await SharedPreferences.getInstance();
      final cachedRequestsString = prefs.getString('customerRequests');

      if (cachedRequestsString != null) {
        final List<dynamic> cachedRequestsMaps = jsonDecode(cachedRequestsString);
        return cachedRequestsMaps
            .map((item) => CustomerRequest.fromMap(item))
            .toList();
      }
      return [];
    }
  }



  Future<List<Map<String, dynamic>>> fetchRestaurants() async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/admin/restaurant/getAllRestaurant'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      // print('Restaurant details: $restaurantId');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        // print('Full API Response: $decodedResponse'); // Debug print

        // Check the structure of the response
        if (decodedResponse['status'] == 1 &&
            decodedResponse['data'] != null &&
            decodedResponse['data']['restaurants'] is List) {

          // Map the restaurants, extracting the nested information
          return (decodedResponse['data']['restaurants'] as List).map((item) {
            // Extract restaurant details from nested structure
            final restaurant = item['restaurant'] ?? {};
            final mediaFiles = item['mediaFiles'] ?? [];

            // print('Restaurant: $restaurant'); // Debug print
            // print('Media Files: $mediaFiles'); // Debug print

            return {
              'id': restaurant['restaurantId']?.toString() ?? '',
              'name': restaurant['restaurantName'] ?? 'Unknown Restaurant',
              // Try different approaches to get the image
              'image': mediaFiles.isNotEmpty ? mediaFiles : null,
            };
          }).toList();
        }
      }

      // Return empty list if no restaurants found
      return [];
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  // Future<List<CategoryModel>> getAllCategories(String restaurantId) async {
  //   try {
  //     final tokenProvider = TokenProvider();
  //     final token = await tokenProvider.getToken();
  //
  //     if (token == null) {
  //       throw Exception(
  //           'Authentication token is missing. Please log in again.');
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/admin/restaurant/getAllRestaurantCategoryById?$restaurantId'),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //       if (jsonResponse['status'] == 1 && jsonResponse['data'] != null) {
  //         final categoriesJson = jsonResponse['data']['categories'] as List;
  //         return categoriesJson
  //             .map((categoryJson) => CategoryModel.fromJson(categoryJson))
  //             .toList();
  //       }
  //     }
  //     return []; // Return empty list if any condition fails
  //   } catch (e) {
  //     print('Error fetching categories: $e');
  //     return []; // Return empty list on error
  //   }
  // }

  Future<List<CategoryModel>> fetchCategoriesByRestaurantId(int restaurantId) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/restaurant/getAllRestaurantCategoryById?restaurantId=$restaurantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);

        print('Parsed JSON list length: ${jsonList.length}');

        return jsonList.map((json) {
          print('Processing JSON: $json');
          return CategoryModel.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load categories. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Detailed error fetching categories: $e');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  }


  Future<List<SubCategoryModels>> fetchAllRestaurantSubCategoryById(int restaurantMenuCategoriesId) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/restaurant/getAllRestaurantSubCategoryById?restaurantSubCategoryId=$restaurantMenuCategoriesId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);

        print('Parsed JSON list length: ${jsonList.length}');

        return jsonList.map((json) {
          print('Processing JSON: $json');
          return SubCategoryModels.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load categories. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Detailed error fetching categories: $e');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  // Future<List<FoodMenuModels>> fetchAllRestaurantFoodmenuById(int restaurantMenuSubCategoriesId) async {
  //   try {
  //     final tokenProvider = TokenProvider();
  //     final token = await tokenProvider.getToken();
  //
  //     if (token == null) {
  //       throw Exception('Authentication token is missing. Please log in again.');
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/admin/restaurant/getAllRestaurantSubCategoryById?restaurantSubCategoryId=$restaurantMenuSubCategoriesId'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     print('Response Status Code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonList = json.decode(response.body);
  //
  //       print('Parsed JSON list length: ${jsonList.length}');
  //
  //       return jsonList.map((json) {
  //         print('Processing JSON: $json');
  //         return FoodMenuModels.fromJson(json);
  //       }).toList();
  //     } else {
  //       throw Exception('Failed to load categories. Status code: ${response.statusCode}, Body: ${response.body}');
  //     }
  //   } catch (e, stackTrace) {
  //     print('Detailed error fetching categories: $e');
  //     print('Stacktrace: $stackTrace');
  //     rethrow;
  //   }
  // }


  Future<List<Map<String, dynamic>>> fetchFoodMenu(int restaurantMenuSubCategoriesId) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/admin/restaurantMenu/getRestaurantMenuSubCategories?restaurantMenuSubCatagoriesId=$restaurantMenuSubCategoriesId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['status'] == 1 &&
            decodedResponse['data'] != null &&
            decodedResponse['data']['menuDetails'] is List) {
          return (decodedResponse['data']['menuDetails'] as List).map((item) {
            // Handle mediaFiles differently
            String imageData = '';
            if (item['mediaFiles'] != null && item['mediaFiles'].isNotEmpty) {
              // Check if 'mediaFile' exists and has 'fileData'
              final mediaFile = item['mediaFiles'][0];
              imageData = mediaFile['fileData'] ?? mediaFile['mediaFile']?['fileData'] ?? '';
            }

            return {
              'restaurantMenuId': item['restaurantMenuId']?.toString() ?? '',
              'name': item['menuName'] ?? 'Unknown Item',
              'price': item['price'] ?? 0.0,
              'quantity': item['quantity'] ?? '',
              'description': item['description'] ?? '',
              'image': imageData,
              'isActive': item['isActive'] ?? false,
            };
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching food menu: $e');
      rethrow;
    }
  }



  Future<List<KitchenRequest>> getAllRequestKitchen() async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      // if (token == null) {
      //   throw Exception('Authentication token is missing. Please log in again.');
      // }

      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getAllRestaurantOrders'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(responseBody);
        // print(jsonResponse); // Debug the response structure

        // Assuming jsonResponse is a List
        if (jsonResponse is List) {
          return jsonResponse
              .map((item) => KitchenRequest.fromJson(item))
              .toList();
        } else {
          print('Unexpected data format: ${jsonResponse.runtimeType}');
        }
      } else {
        print('API error: ${response.statusCode}');
      }

      return []; // Return empty list on failure
    } catch (e) {
      print('Error fetching kitchen requests: $e');
      return [];
    }
  }



  Future<String?> updateRequestStatus(int restaurantOrderId, String requestOrderStatus) async {
    try {
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/hotelapp/updateRestaurantOrders'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "restaurantOrderId": restaurantOrderId,
          "requestOrderStatus": requestOrderStatus,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response
        final jsonResponse = jsonDecode(response.body);

        // Return the data/message from the response
        return jsonResponse['data'] ?? jsonResponse['message'];
      } else {
        print('Failed to update status: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating request status: $e');
      return null;
    }
  }

  Future<void> StatusupdateRatting(String requestDataId, String ratingComment,
      int rating) async {
    final tokenProvider = TokenProvider();
    final token = await tokenProvider.getToken();
    // final prefs = await SharedPreferences.getInstance();
    // final String? token = prefs.getString('jwt');

    // final String statusupdateUrl = '$baseUrl/hotelapp/updateRequstJobStatus?userId=$userId&jobStatus=$jobStatus&requestJobHistoryId=$requestJobHistoryId';
    final response = await http.put(
      Uri.parse(
          '$baseUrl/hotelapp/updateRating?rating=$rating&ratingComment=$ratingComment&requestDataId=$requestDataId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },

    );


    // print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      print("Task updated successfully");
    } else {
      print("Failed to update task: ${response.body}");
      throw Exception('Failed to update task');
    }
  }





  // Future<void> submitCustomerFeedback(int requestJobHistoryId, int rating, String ratingComment) async {
  //   final tokenProvider = TokenProvider();
  //   final token = await tokenProvider.getToken();
  //   // final prefs = await SharedPreferences.getInstance();
  //   // final String? token = prefs.getString('jwt');
  //
  //   // final String statusupdateUrl = '$baseUrl/hotelapp/updateRequstJobStatus?userId=$userId&jobStatus=$jobStatus&requestJobHistoryId=$requestJobHistoryId';
  //   final response = await http.put(
  //     Uri.parse(
  //         '$baseUrl/hotelapp/updateServiceRating?rating=$rating&ratingComment=$ratingComment&requestJobHistoryId=$requestJobHistoryId'),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $token",
  //     },
  //
  //   );
  //
  //
  //   // print('Response Body: ${response.body}');
  //   if (response.statusCode == 200) {
  //     print("Task updated successfully");
  //   } else {
  //     print("Failed to update task: ${response.body}");
  //     throw Exception('Failed to update task');
  //   }
  // }



  Future<List<RequestJob>> getServicesRequestsById() async {

      // Retrieve the authentication token
      final tokenProvider = TokenProvider();
      final token = await tokenProvider.getToken();

      if (token == null) {
        print('Authentication token is missing. Please log in again.');
        return [];
      }

      // Make the API request
      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getGeneralRequestById'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      // print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);  // Check if the data is being parsed correctly

        final List<dynamic> requests = data['data'] ?? [];
        return requests.map((json) => RequestJob.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load requests: ${response.body}');
      }

  }





  Future<void> submitCustomerFeedback(String requestJobHistoryId, String ratingComment, double rating) async {
    final tokenProvider = TokenProvider();
    final token = await tokenProvider.getToken();

    if (requestJobHistoryId.isEmpty) {
      throw Exception('Request Job History ID cannot be empty');
    }

    print('Detailed Request ID Check:');
    print('Request ID: $requestJobHistoryId');
    print('Request ID Type: ${requestJobHistoryId.runtimeType}');
    print('Request ID Trimmed: ${requestJobHistoryId.trim()}');



    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/hotelapp/updateServiceRating?rating=$rating&ratingComment=$ratingComment&requestJobHistoryId=$requestJobHistoryId'
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print("Task updated successfully");
      } else {
        throw Exception('Failed to update task. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow; // Re-throw to allow the UI to handle the error
    }
  }

}





