import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
        body: jsonEncode(
            {
              "userEmailId": userEmailId,
              "userPassword": password,
            }

        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Successful login, return the response data (e.g., token or user info)
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/request/getAllCustomerTaskData'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['status'] == 1) {
          List<dynamic> data = responseBody['data'];

          // Ensure each item is a Map<String, dynamic>
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          throw Exception('Failed to fetch tasks: ${responseBody['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
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
  }) async {
    try {
      // Get JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      final response = await http.post(
        Uri.parse('$baseUrl/request/saveGeneralRequest'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "floorId": floorId,
          "taskId": taskId,
          "roomDataId": roomDataId,
          "rname": rname,
          "requestType": requestType,
          "description": description,
          "requestDataCreatedBy": requestDataCreatedBy,
        }),
      );

      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to send request');
      }
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
  }

  Future<void> notifyBreaks(int userId) async {
    final String url = '$baseUrl/break/saveBreakDetails';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');


      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",},


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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final String getallbreakrequestUrl = '$baseUrl/break/getBreakRequstById';

      final response = await http.get(
        Uri.parse(getallbreakrequestUrl),
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
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or empty');
      }

      final url = Uri.parse('$baseUrl/hotelapp/updateJobStatus?userId=$userId&jobStatus=$jobStatus');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

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
      // Get the JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt');

      // print('Token from SharedPreferences: $token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or empty');
      }

      // Define the API endpoint URL
      final String url = '$baseUrl/hotelapp/getGeneralRequestById';
      // print('Calling API: $url');

      // Make the GET request
      final response = await http.get(
        Uri.parse(url),
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
          if (decodedResponse.containsKey('data') && decodedResponse['data'] is List) {
            final List<dynamic> jsonResponse = decodedResponse['data'];

            // Convert each item in the list to a Map with proper type handling
            final List<Map<String, dynamic>> typedData = jsonResponse.map((item) {
              return {
                'id': item['id']?.toString() ?? '',
                'userName': item['userName']?.toString() ?? '',
                'taskName': item['taskName']?.toString() ?? '',
                'Description':item['Description']?.toString() ?? '',
                'name': item['name']?.toString() ?? '',
                'roomName': item['roomName']?.toString() ?? '',
                'jobStatus': item['jobStatus']?.toString() ?? '',
                'roomId': item['roomId']?.toString() ?? '',
                'nextJobStatus': item['nextJobStatus']?.toString() ?? '',
                'requestJobHistoryId': item['requestJobHistoryId']?.toString() ?? '',
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
          throw Exception('Expected a Map but got ${decodedResponse.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error in getGeneralRequestsById: $e');
      throw Exception('Failed to fetch general requests: $e');
    }
  }





  Future<void> Statusupdate(int userId, String jobStatus, String requestJobHistoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt');

    final String statusupdateUrl = '$baseUrl/hotelapp/updateRequstJobStatus?userId=$userId&jobStatus=$jobStatus&requestJobHistoryId=$requestJobHistoryId';

    final response = await http.put(
      Uri.parse(statusupdateUrl),
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

    print('$userId');
    print(jobStatus);
    print(requestJobHistoryId);
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      print("Task updated successfully");
    } else {
      print("Failed to update task: ${response.body}");
      throw Exception('Failed to update task');
    }
  }

  Future<List<Map<String, dynamic>>> getCustomerRequestsById() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt');

      // print('Token from SharedPreferences: $token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or empty');
      }

      final String url = '$baseUrl/hotelapp/getByCustomerRequestById';
      // print('Calling API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response body, focusing on the "data" field
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        // Convert each item in the data list to a Map
        final List<Map<String, dynamic>> typedData = data.map((item) {
          return {
            'requestDataId': item['requestDataId'].toString(),
            'rname': item['rname'] ?? 'Unknown',
            'taskName': item['taskName'] ?? 'Unknown Task',
            'description': item['description'] ?? '',
            'starttime': item['starttime'] ?? '',
            'endTime': item['endTime'] ?? '',
            'jobStatus': item['jobStatus'] ?? '',
            'floorName': item['floorName'] ?? 'Unknown Floor',
            // Add other fields if needed
          };
        }).toList();

        // Store the processed data in SharedPreferences
        await prefs.setString('generalRequests', json.encode(typedData));

        print('Processed ${typedData.length} requests');
        return typedData;
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserRequestsById: $e');
      throw Exception('Failed to fetch general requests: $e');
    }
  }










}


