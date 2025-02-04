import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/helpers/shared_preferences_helper.dart';
import '../../models/categorymodel.dart';
import '../../utility/token.dart';
import '../customer/customer_other_services/otherservices.dart';
import '../customer/customer_other_services/widgets/models/OtherServiceSlot_models.dart';
import '../customer/customer_other_services/widgets/otherservices_models.dart';
import '../customer/customerhistorymodels/cus_his_models.dart';
import '../dashboard/services/services_models/ser_models.dart';
import '../kitchenMenu/kitchen_models/data.dart';

class ApiService {
  final TokenProvider tokenProvider = TokenProvider();
  final String baseUrl = 'https://www.hotels.annulartech.net';
  bool _isRefreshing = false;

  // final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  // final String baseUrl = 'https://www.hotels.annulartech.net';
  final SharedPreferencesHelper _prefsHelper;
  final TokenProvider _tokenProvider;

  ApiService({
    SharedPreferencesHelper? prefsHelper,
    TokenProvider? tokenProvider,
  })  : _prefsHelper = prefsHelper ?? SharedPreferencesHelper(),
        _tokenProvider = tokenProvider ?? TokenProvider();

  // Login functional
  Future<Map<String, dynamic>> login(
      String userEmailId, String password) async {
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

        // Store login data including JWT in SharedPreferences
        if (data['jwt'] != null) {
          await _prefsHelper.saveLoginData({
            'jwt': data['jwt'],
            'token': data['token'], // This will be used as refresh token
            'expiry': data['expiry'],
            'id': data['id'],
            'username': data['username'],
            'userType': data['userType'],
            'status': data['status'],
            'roomNo': data['roomNo'],
            'floorId': data['floorId'],
            'hotelId': data['hotelId'],
          });

          // Save token expiry separately for refresh checks
          if (data['expiry'] != null) {
            await _prefsHelper.saveTokenExpiry(data['expiry']);
          }
        }

        return data;
      } else {
        return {
          'error': 'Failed to login. invalided credentials',
        };
      }
    } catch (e) {
      // Handle network or other errors
      return {
        'error': 'Failed to login. invalided credentials',
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse('$baseUrl/request/getAllCustomerTaskData'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJwt',
        },
      );

      if (response.statusCode == 401) {
        final newToken = await tokenProvider.refreshToken();
        if (newToken == null) throw Exception('Token refresh failed');

        return fetchTasks();
      }
      print('Response Body: ${response.body}');
      final responseBody = utf8.decode(response.bodyBytes);
      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && decodedResponse['status'] == 1) {
        List<dynamic> data = decodedResponse['data'];
        return data.map((item) => item as Map<String, dynamic>).toList();
      }

      throw Exception(
          'Failed to fetch tasks: ${decodedResponse['message'] ?? response.body}');
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<List<TaskCategoryModel>> fetchTaskCategories(int hotelId) async {
    try {
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];

      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      // Update the URL to include the hotelId query parameter
      final response = await http.get(
        Uri.parse('$baseUrl/task/getAllTaskCategoryDetails?hotelId=$hotelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJwt',
        },
      );

      if (response.statusCode == 401) {
        final newToken = await tokenProvider.refreshToken();
        if (newToken == null) throw Exception('Token refresh failed');

        return fetchTaskCategories(hotelId); // Pass the hotelId again
      }

      final decodedResponse = jsonDecode(response.body);

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
  Future<List<TaskSubcategoryModel>> fetchTaskSubcategories(
      int taskCategoryId) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse(
            '$baseUrl/task/getTaskCategoryListById?taskCategoryId=$taskCategoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJwt',
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
  Future<List<CustomerTaskModel>> fetchCustomerTasks(
      int taskSubCategoryId) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse(
            '$baseUrl/task/getAllTaskNameBySubCategoryById?taskSubCategoryId=$taskSubCategoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJwt',
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
    required int hotelId,
    String? descriptionNorwegian,
    String? descriptionArabian,
  }) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      // Prepare the request body with conditional description fields
      final body = {
        "floorId": floorId,
        "taskId": taskId,
        "roomDataId": roomDataId,
        "rname": rname,
        "requestType": requestType,
        "requestDataCreatedBy": requestDataCreatedBy,
        "taskSubCategoryId": taskSubCategoryId,
        "taskCategoryId": taskCategoryId,
        "hotelId":hotelId,
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
          "Authorization": "Bearer $currentJwt",
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
    required int hotelId,
    String? descriptionNorwegian,
    String? descriptionArabian,
  }) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      // Prepare the request body with conditional description fields
      final body = {
        "floorId": floorId,
        "taskId": taskId,
        "roomDataId": roomDataId,
        "rname": rname,
        "requestType": requestType,
        "requestDataCreatedBy": requestDataCreatedBy,
        "restaurantSubCategoryId": restaurantSubCategoryId,
        "restaurantCategoryId": restaurantCategoryId,
        "restaurantId": restaurantId,
        "restaurantMenu": restaurantMenu,
        "description": description,
        "hotelId":hotelId,
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
          "Authorization": "Bearer $currentJwt",
        },
        body: jsonEncode(body),
      );

      print("Request Body: $body");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Failed to send request');
      } else {
        print('chenkelse');
      }
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
  }

  Future<void> notifyBreaks(int hotelId) async {
    // final String url = '$baseUrl/break/saveBreakDetails';
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.post(
        Uri.parse('$baseUrl/break/saveBreakDetails'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
        },
        body: jsonEncode({
          'hotelId': hotelId,
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
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse('$baseUrl/break/getBreakRequstById'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
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

  Future<Map<String, dynamic>> updateJobStatus(
      bool jobStatus, String userId) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      // final prefs = await SharedPreferences.getInstance();
      // final String? token = prefs.getString('jwt');
      final url = Uri.parse(
          '$baseUrl/hotelapp/updateJobStatus?userId=$userId&jobStatus=$jobStatus');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $currentJwt',
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

  // Future<void> Statusupdate(
  //     int userId,
  //     String jobStatus,
  //     String requestJobHistoryId,
  //     String estimationTime,
  //     {int retries = 3}) async {
  //   try {
  //     // Get current authentication token
  //     final loginData = await _prefsHelper.getLoginData();
  //     var jwt = loginData?['jwt'];
  //
  //     if (jwt == null) {
  //       throw Exception('Authentication token missing');
  //     }
  //
  //     // Check if token needs refresh
  //     if (await tokenProvider.needsRefresh()) {
  //       jwt = await tokenProvider.refreshToken();
  //       if (jwt == null) {
  //         throw Exception('Token refresh failed');
  //       }
  //     }
  //
  //     // Construct the URL with query parameters
  //     final uri = Uri.parse('$baseUrl/hotelapp/updateRequestJobStatus').replace(
  //       queryParameters: {
  //         'userId': userId.toString(),
  //         'jobStatus': jobStatus,
  //         'requestJobHistoryId': requestJobHistoryId,
  //         'estimationTime': estimationTime,
  //       },
  //     );
  //
  //     // Initialize response variable with a default value
  //     http.Response response = http.Response('', 504); // Default to a 504 response
  //
  //     // Make the PUT request with retries
  //     for (int i = 0; i < retries; i++) {
  //       response = await http.put(
  //         uri,
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $jwt',
  //         },
  //         body: jsonEncode({
  //           'userId': userId,
  //           'jobStatus': jobStatus,
  //           'requestJobHistoryId': requestJobHistoryId,
  //           'estimationTime': estimationTime,
  //         }),
  //       );
  //
  //       // Debug logging for each attempt
  //       print('Attempt ${i + 1}: Request URL: ${uri.toString()}');
  //       print('Attempt ${i + 1}: Request Headers: ${response.request?.headers}');
  //       print('Attempt ${i + 1}: Response Status Code: ${response.statusCode}');
  //
  //       // Break the loop if the request is successful
  //       if (response.statusCode == 200) {
  //         break;
  //       } else if (response.statusCode == 504 && i < retries - 1) {
  //         await Future.delayed(Duration(seconds: 2)); // Wait before retrying
  //       }
  //     }
  //
  //     // Handle response after all retries
  //     if (response.statusCode == 200) {
  //       final responseBody = utf8.decode(response.bodyBytes);
  //       final decodedResponse = jsonDecode(responseBody);
  //       final status = decodedResponse['status'];
  //       print('Task updated successfully');
  //       print('Response Status: $status');
  //     } else if (response.statusCode == 504) {
  //       throw Exception('Gateway timeout - server took too long to respond');
  //     } else {
  //       print('Error Response Body: ${response.body}');
  //       throw Exception('Failed to update task: Status ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error in Statusupdate: $e');
  //     throw Exception('Failed to update task status: $e');
  //   }
  // }

  Future<List<CustomerRequest>> getCustomerRequestsById() async {
    try {
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      final prefs = await SharedPreferences.getInstance();

      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getByCustomerRequestById'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
        },
      );

      if (response.statusCode == 401) {
        final newToken = await tokenProvider.refreshToken();
        if (newToken == null) throw Exception('Token refresh failed');
        return getCustomerRequestsById();
      }

      final responseBody = utf8.decode(response.bodyBytes);
      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && decodedResponse['status'] == 1) {
        if (decodedResponse['data']?['customerRequests'] != null) {
          final List<CustomerRequest> requests =
              (decodedResponse['data']['customerRequests'] as List)
                  .map((item) => CustomerRequest.fromMap(item))
                  .toList();

          // Cache the response data
          await prefs.setString('customerRequests',
              jsonEncode(requests.map((request) => request.toMap()).toList()));

          return requests;
        }
      }

      print(
          'Failed to fetch data. Status: ${response.statusCode}, Response: $decodedResponse');
      return [];
    } catch (e) {
      print('Error in getCustomerRequestsById: $e');

      // Attempt to return cached data
      final prefs = await SharedPreferences.getInstance();
      final cachedRequestsString = prefs.getString('customerRequests');

      if (cachedRequestsString != null) {
        try {
          final List<dynamic> cachedRequestsMaps =
              jsonDecode(cachedRequestsString);
          return cachedRequestsMaps
              .map((item) => CustomerRequest.fromMap(item))
              .toList();
        } catch (cacheError) {
          print('Error reading cache: $cacheError');
          return [];
        }
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchRestaurants(int hotelId) async {
    try {
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];
      final response = await http.get(
        Uri.parse('$baseUrl/admin/restaurant/getAllRestaurant?hotelId=$hotelId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
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

  Future<List<CategoryModel>> fetchCategoriesByRestaurantId(
      int restaurantId) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse(
            '$baseUrl/admin/restaurant/getAllRestaurantCategoryById?restaurantId=$restaurantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJwt',
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
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Detailed error fetching categories: $e');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  Future<List<SubCategoryModels>> fetchAllRestaurantSubCategoryById(
      int restaurantMenuCategoriesId) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse(
            '$baseUrl/admin/restaurant/getAllRestaurantSubCategoryById?restaurantSubCategoryId=$restaurantMenuCategoriesId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJwt',
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
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Detailed error fetching categories: $e');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFoodMenu(
      int restaurantMenuSubCategoriesId) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse(
            '$baseUrl/admin/restaurantMenu/getRestaurantMenuSubCategories?restaurantMenuSubCatagoriesId=$restaurantMenuSubCategoriesId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
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
              imageData = mediaFile['fileData'] ??
                  mediaFile['mediaFile']?['fileData'] ??
                  '';
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
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getAllRestaurantOrders'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
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

  Future<String?> updateRequestStatus(
      int restaurantOrderId, String requestOrderStatus) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // final prefs = await SharedPreferences.getInstance();

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.post(
        Uri.parse('$baseUrl/hotelapp/updateRestaurantOrders'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
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

  Future<void> StatusupdateRatting(String? requestDataId,
      String? otherServiceHistoryId, String ratingComment, int rating) async {
    // Get login data from _prefsHelper
    final loginData = await _prefsHelper.getLoginData();
    final jwt = loginData?['jwt'];
    if (jwt == null) {
      throw Exception('Authentication token missing');
    }

    // Check if token needs refresh before making request
    if (await tokenProvider.needsRefresh()) {
      final newJwt = await tokenProvider.refreshToken();
      if (newJwt == null) {
        throw Exception('Token refresh failed');
      }
    }

    // Get fresh JWT after potential refresh
    final currentLoginData = await _prefsHelper.getLoginData();
    final currentJwt = currentLoginData?['jwt'];

    // Log the IDs for debugging
    print('Request Data ID: $requestDataId');
    print('Other Service History ID: $otherServiceHistoryId');

    // Construct the API URL based on which ID is available
    final String apiUrl;
    if (requestDataId != null && requestDataId != "0") {
      apiUrl =
          '$baseUrl/hotelapp/updateRating?rating=$rating&ratingComment=${Uri.encodeComponent(ratingComment)}&requestDataId=$requestDataId';
    } else if (otherServiceHistoryId != null) {
      apiUrl =
          '$baseUrl/hotelapp/updateRating?rating=$rating&ratingComment=${Uri.encodeComponent(ratingComment)}&otherServiceHistoryId=$otherServiceHistoryId';
    } else {
      throw Exception(
          'Both requestDataId and otherServiceHistoryId are null or invalid');
    }

    // Log the API URL for debugging
    print('API URL: $apiUrl');

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $currentJwt",
      },
    );

    // Log the response body for debugging
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 1) {
        print("Task updated successfully");
      } else {
        // Handle API-specific error messages
        final errorMessage = responseData['message'] ?? 'Failed to update task';
        print("Failed to update task: $errorMessage");
        throw Exception(errorMessage);
      }
    } else {
      print("Failed to update task: ${response.body}");
      throw Exception('Failed to update task');
    }
  }

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
      print(data); // Check if the data is being parsed correctly

      final List<dynamic> requests = data['data'] ?? [];
      return requests.map((json) => RequestJob.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load requests: ${response.body}');
    }
  }

  Future<void> submitCustomerFeedback(
      int requestJobHistoryId, // Accept as int
      String ratingComment,
      double rating,
      ) async {
    // Convert requestJobHistoryId to String for the API (if needed)
    String requestJobHistoryIdString = requestJobHistoryId.toString();

    // Get login data from _prefsHelper
    final loginData = await _prefsHelper.getLoginData();
    final jwt = loginData?['jwt'];
    if (jwt == null) {
      throw Exception('Authentication token missing');
    }

    final prefs = await SharedPreferences.getInstance();

    // Check if token needs refresh before making request
    if (await tokenProvider.needsRefresh()) {
      final newJwt = await tokenProvider.refreshToken();
      if (newJwt == null) {
        throw Exception('Token refresh failed');
      }
    }

    // Get fresh JWT after potential refresh
    final currentLoginData = await _prefsHelper.getLoginData();
    final currentJwt = currentLoginData?['jwt'];

    // Validate requestJobHistoryId
    if (requestJobHistoryId <= 0) {
      throw Exception('Request Job History ID must be a positive integer');
    }

    print('Detailed Request ID Check:');
    print('Request ID: $requestJobHistoryIdString');
    print('Request ID Type: ${requestJobHistoryIdString.runtimeType}');

    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/hotelapp/updateServiceRating?rating=$rating&ratingComment=$ratingComment&requestJobHistoryId=$requestJobHistoryIdString',
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print("Task updated successfully");
        print('Response Status Code: ${response.statusCode}');
      } else {
        throw Exception(
          'Failed to update task. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow; // Re-throw to allow the UI to handle the error
    }
  }
  // Future<ServiceResponse> fetchServices(String userType) async {
  //   try {
  //     // Get the token
  //     final token = await _getToken();
  //
  //     if (token == null) {
  //       throw Exception('No authentication token found');
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/otherService/getAllOtherServiceData?userType=$userType'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       return ServiceResponse.fromJson(json.decode(response.body));
  //     } else if (response.statusCode == 401) {
  //       // Handle unauthorized error
  //       final errorResponse = json.decode(response.body);
  //       throw Exception('Authentication error: ${errorResponse['message']}');
  //     } else {
  //       throw Exception('Failed to load services: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error in fetchServices: $e');
  //     rethrow;
  //   }
  // }

  Future<ServiceResponse> fetchServices(int hotelId) async {
    // Get login data from _prefsHelper
    final loginData = await _prefsHelper.getLoginData();
    final jwt = loginData?['jwt'];
    if (jwt == null) {
      throw Exception('Authentication token missing');
    }

    // final prefs = await SharedPreferences.getInstance();

    // Check if token needs refresh before making request
    if (await tokenProvider.needsRefresh()) {
      final newJwt = await tokenProvider.refreshToken();
      if (newJwt == null) {
        throw Exception('Token refresh failed');
      }
    }

    // Get fresh JWT after potential refresh
    final currentLoginData = await _prefsHelper.getLoginData();
    final currentJwt = currentLoginData?['jwt'];

    final response = await http.get(
      Uri.parse('$baseUrl/otherService/getAllOtherServiceData?hotelId=$hotelId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $currentJwt",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ServiceResponse.fromJson(data);
    } else {
      throw Exception('Failed to load services: ${response.body}');
    }
  }

  Future<OtherServiceSlot> fetchServiceSlots(int otherServiceId) async {
    // Get login data from _prefsHelper
    final loginData = await _prefsHelper.getLoginData();
    final jwt = loginData?['jwt'];
    if (jwt == null) {
      throw Exception('Authentication token missing');
    }

    // Check if token needs refresh before making request
    if (await tokenProvider.needsRefresh()) {
      final newJwt = await tokenProvider.refreshToken();
      if (newJwt == null) {
        throw Exception('Token refresh failed');
      }
    }

    // Get fresh JWT after potential refresh
    final currentLoginData = await _prefsHelper.getLoginData();
    final currentJwt = currentLoginData?['jwt'];

    // Make the API call
    final response = await http.get(
      Uri.parse(
          '$baseUrl/otherService/getAllOtherServiceById?OtherServiceId=$otherServiceId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $currentJwt",
      },
    );

    // Handle the response
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return OtherServiceSlot.fromJson(data); // Use the class for parsing
    } else {
      throw Exception('Failed to load services: ${response.body}');
    }
  }

  Future<void> bookotherservices({
    required int otherServiceId,
    required int serviceCreatedBy,
    required String jobStatus,
    required int scheduleId,
    required String time,
    required String date,
    required int floorId,
    required int roomDataId,
    required String rname,
    required int hotelId
  }) async {
    try {
      // Get login data and token
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) throw Exception('Authentication token missing');

      // Refresh token if needed
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) throw Exception('Token refresh failed');
      }

      // Construct the base request body
      final Map<String, dynamic> requestBody = {
        'otherServiceId': otherServiceId,
        'serviceCreatedBy': serviceCreatedBy,
        'jobStatus': jobStatus,
        'roomDataId': roomDataId,
        'floorId': floorId,
        'rname': rname,
        'hotelId':hotelId
      };

      // Add scheduleId only if it's not 0
      if (scheduleId != 0) {
        requestBody['scheduleId'] = scheduleId;
      }

      // Add date and time only if they're not empty
      if (date.isNotEmpty) requestBody['date'] = date;
      if (time.isNotEmpty) requestBody['time'] = time;

      // Make the API call
      final response = await http.post(
        Uri.parse('$baseUrl/otherService/saveOtherServiceByCustomer'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwt",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody;
      } else {
        throw Exception(
          'Failed to submit service request: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to book other services: $e');
    }
  }



  Future<List<Map<String, dynamic>>> getGeneralRequestsById() async {
    try {
      // Get login data and validate JWT
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      final prefs = await SharedPreferences.getInstance();

      // Token refresh handling
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          // If token refresh fails, try using cached data before throwing error
          final cachedData = prefs.getString('generalRequests');
          if (cachedData != null) {
            return List<Map<String, dynamic>>.from(jsonDecode(cachedData)
                .map((item) => Map<String, dynamic>.from(item)));
          }
          throw Exception('Token refresh failed');
        }
      }

      // Get current JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      // Make API request with proper error handling
      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getGeneralRequestById'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      // Decode response with proper error handling
      final String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> decodedResponse;
      try {
        decodedResponse = jsonDecode(responseBody);
      } catch (e) {
        throw Exception('Invalid JSON response: $responseBody');
      }

      // Validate response format
      if (!decodedResponse.containsKey('status')) {
        throw Exception('Response missing status field: $responseBody');
      }

      final status = decodedResponse['status'];

      // Handle different response scenarios
      if (response.statusCode == 200) {
        if (status == 1) {
          if (decodedResponse['data'] is! List) {
            throw Exception(
                'Invalid data format: expected List, got ${decodedResponse['data'].runtimeType}');
          }

          final List jsonResponse = decodedResponse['data'];
          final typedData = jsonResponse
              .map((item) => {
                    'id': item['id']?.toString() ?? '',
                    'userName': item['userName']?.toString() ?? '',
                    'taskName': item['taskName']?.toString() ?? '',
                    'Description': item['Description']?.toString() ?? '',
                    'DescriptionNorweign':
                        item['DescriptionNorweign']?.toString() ?? '',
                    'name': item['name']?.toString() ?? '',
                    'roomName': item['roomName']?.toString() ?? '',
                    'jobStatus': item['jobStatus']?.toString() ?? '',
                    'estimationTime': item['estimationTime']?.toString() ?? '',
                    'roomId': item['roomId']?.toString() ?? '',
                    'nextJobStatus': item['nextJobStatus']?.toString() ?? '',
                    'requestJobHistoryId':
                        item['requestJobHistoryId']?.toString() ?? '',
                    'flag': item['flag']?.toString() ?? '',
                    'feedback_status': item['feedback_status'] ?? false,
                    'completedAt': item['completedAt']?.toString(),
                    'type': item['type']?.toString() ?? '',
                  })
              .toList();

          // Cache successful response
          await prefs.setString('generalRequests', jsonEncode(typedData));
          return typedData;
        } else if (status == 0) {
          // Status 0 might indicate no data or other server-side condition
          // Return empty list instead of throwing error
          return [];
        } else {
          throw Exception('Unexpected status: $status');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGeneralRequestsById: $e');

      // Attempt to return cached data on any error
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString('generalRequests');
        if (cachedData != null) {
          return List<Map<String, dynamic>>.from(jsonDecode(cachedData)
              .map((item) => Map<String, dynamic>.from(item)));
        }
      } catch (cacheError) {
        print('Error retrieving cached data: $cacheError');
      }

      // If no cached data available, rethrow the original error
      throw Exception('Failed to fetch general requests: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCompletedRequestsByUserId() async {
    try {
      // Get login data and validate JWT
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      final prefs = await SharedPreferences.getInstance();

      // Token refresh handling
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          // If token refresh fails, try using cached data before throwing error
          final cachedData = prefs.getString('generalRequests');
          if (cachedData != null) {
            return List<Map<String, dynamic>>.from(jsonDecode(cachedData)
                .map((item) => Map<String, dynamic>.from(item)));
          }
          throw Exception('Token refresh failed');
        }
      }

      // Get current JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      // Make API request with proper error handling
      final response = await http.get(
        Uri.parse('$baseUrl/hotelapp/getAllCompletedRequestByUserId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
        },
      );

      // Decode response with proper error handling
      final String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> decodedResponse;
      try {
        decodedResponse = jsonDecode(responseBody);
      } catch (e) {
        throw Exception('Invalid JSON response: $responseBody');
      }

      // Validate response format
      if (!decodedResponse.containsKey('status')) {
        throw Exception('Response missing status field: $responseBody');
      }

      final status = decodedResponse['status'];

      // Handle different response scenarios
      if (response.statusCode == 200) {
        if (status == 1) {
          if (decodedResponse['data'] is! List) {
            throw Exception(
                'Invalid data format: expected List, got ${decodedResponse['data'].runtimeType}');
          }

          final List jsonResponse = decodedResponse['data'];
          final typedData = jsonResponse
              .map((item) => {
                    'id': item['id']?.toString() ?? '',
                    'userName': item['userName']?.toString() ?? '',
                    'taskName': item['taskName']?.toString() ?? '',
                    'Description': item['Description']?.toString() ?? '',
                    'DescriptionNorweign':
                        item['DescriptionNorweign']?.toString() ?? '',
                    'name': item['name']?.toString() ?? '',
                    'roomName': item['roomName']?.toString() ?? '',
                    'jobStatus': item['jobStatus']?.toString() ?? '',
                    'roomId': item['roomId']?.toString() ?? '',
                    'nextJobStatus': item['nextJobStatus']?.toString() ?? '',
                    'requestJobHistoryId':
                        item['requestJobHistoryId']?.toString() ?? '',
                    'flag': item['flag']?.toString() ?? '',
                    'feedback_status': item['feedback_status'] ?? false,
                    'completedAt': item['completedAt']?.toString(),
                    'type': item['Description']?.toString() ?? '',
                  })
              .toList();

          // Cache successful response
          await prefs.setString('generalRequests', jsonEncode(typedData));
          return typedData;
        } else if (status == 0) {
          // Status 0 might indicate no data or other server-side condition
          // Return empty list instead of throwing error
          return [];
        } else {
          throw Exception('Unexpected status: $status');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGeneralRequestsById: $e');

      // Attempt to return cached data on any error
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString('generalRequests');
        if (cachedData != null) {
          return List<Map<String, dynamic>>.from(jsonDecode(cachedData)
              .map((item) => Map<String, dynamic>.from(item)));
        }
      } catch (cacheError) {
        print('Error retrieving cached data: $cacheError');
      }

      // If no cached data available, rethrow the original error
      throw Exception('Failed to fetch general requests: $e');
    }
  }

  Future<void> Statusupdate(
      int userId,
      String jobStatus,
      String requestJobHistoryId,
      String estimationTime,

      ) async {
    try {
      // Get login data from _prefsHelper
      final loginData = await _prefsHelper.getLoginData();
      final jwt = loginData?['jwt'];
      if (jwt == null) {
        throw Exception('Authentication token missing');
      }

      // Check if token needs refresh before making request
      if (await tokenProvider.needsRefresh()) {
        final newJwt = await tokenProvider.refreshToken();
        if (newJwt == null) {
          throw Exception('Token refresh failed');
        }
      }

      // Get fresh JWT after potential refresh
      final currentLoginData = await _prefsHelper.getLoginData();
      final currentJwt = currentLoginData?['jwt'];

      final response = await http.put(
        Uri.parse(
            '$baseUrl/hotelapp/updateRequestJobStatus?userId=$userId&jobStatus=$jobStatus&requestJobHistoryId=$requestJobHistoryId&estimationTime=$estimationTime'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $currentJwt",
        },
        body: jsonEncode({
          "userId": userId,
          "jobStatus": jobStatus,
          "requestJobHistoryId": requestJobHistoryId,
          "estimationTime": estimationTime,

        }),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      print('Response Body: $responseBody'); // Debug log

      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        final status = decodedResponse['status'];

        print("checkkkkkkk: ${response.statusCode}");
        print("Task updated successfully");
        print('Response Status: $status');

      } else {
        print("Failed to update task: ${response.body}");
        throw Exception('Failed to update task');
      }
    } catch (e) {
      print('Error in getGeneralRequestsById: $e');
      throw Exception('Failed to fetch general requests: ');
    }
  }
}
