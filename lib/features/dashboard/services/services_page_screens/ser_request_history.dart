import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/dashboard/services/services_page_screens/servicedashboard.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../classes/language.dart';
import '../../../../common/helpers/app_bar.dart';
import '../../../services/apiservices.dart';
import '../services_models/ser_models.dart';

class SerRequestHistory extends StatefulWidget {
  final int userId;
  final String userName;
  final String? roomNo;
  final String? floorId;
  final int hotelId;
  const SerRequestHistory({required this.userId,
  required this.userName,
  this.roomNo,
  this.floorId,
  required this.hotelId,super.key});

  @override
  _SerRequestHistoryState createState() => _SerRequestHistoryState();
}

class _SerRequestHistoryState extends State<SerRequestHistory> {
  List<CompleteRequestJob> completedRequests = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchCompletedRequests();
  }

  Future<void> fetchCompletedRequests() async {
    try {
      final List<Map<String, dynamic>> response = await _apiService.getCompletedRequestsByUserId();
      setState(() {
        completedRequests = response
            .map((data) => CompleteRequestJob.fromMap(data))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        isLoading = false;
      });
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
        extraActions: [], dashboardType: DashboardType.other,
        onLogout: () {
          logOut(context);
        },  apiService: _apiService,onLogoTap: () {
        // Navigate to UserMenu with the required parameters
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => ServicesDashboard(
              userName: widget.userName,
              userId: widget.userId,
              roomNo: widget.roomNo,
              hotelId: widget.hotelId,
            ),
          ),
              (Route<dynamic> route) => false,
        );
      },


      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : completedRequests.isEmpty
          ? const Center(child: Text('No completed requests found.'))
          : ListView.builder(
        itemCount: completedRequests.length,
        itemBuilder: (context, index) {
          final request = completedRequests[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room ID: ${request.roomId}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('User Name: ${request.userName}'),
                  Text('Task Name: ${request.taskName}'),
                  Text('Description: ${request.description}'),
                  Text('Job Status: ${request.jobStatus}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}