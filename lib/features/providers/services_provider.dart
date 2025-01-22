// lib/features/dashboard/providers/services_provider.dart
import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';

class ServicesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _availableRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];
  List<Map<String, dynamic>> _filteredCompletedRequests = [];
  bool _isLoading = false;
  DateTime? _selectedDate;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get availableRequests => _availableRequests;
  List<Map<String, dynamic>> get completedRequests => _completedRequests;
  List<Map<String, dynamic>> get filteredCompletedRequests => _filteredCompletedRequests;
  bool get isLoading => _isLoading;
  DateTime? get selectedDate => _selectedDate;
  String? get errorMessage => _errorMessage;

  // Initialize
  Future<void> initialize() async {
    await fetchRequests();
  }

  // Fetch Requests
  Future<void> fetchRequests() async {
    try {
      _setLoading(true);
      final requests = await _apiService.getGeneralRequestsById();

      _availableRequests = requests.where((request) => request['jobStatus'] != 'Completed').toList();
      _completedRequests = requests.where((request) {
        bool isCompleted = request['jobStatus'] == 'Completed';
        if (isCompleted && request['completedAt'] == null) {
          request['completedAt'] = DateTime.now().toIso8601String();
        }
        return isCompleted;
      }).toList();

      _filterCompletedTasks();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch requests: $e';
      _availableRequests = [];
      _completedRequests = [];
      _filteredCompletedRequests = [];
    } finally {
      _setLoading(false);
    }
  }

  // Update Request Status
  Future<void> updateRequestStatus(String requestJobHistoryId, String status,String estimationTime) async {
    try {
      _setLoading(true);
      await _apiService.Statusupdate(

        int.parse(requestJobHistoryId),
        status,
        requestJobHistoryId,
          estimationTime
      );
      await fetchRequests();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Filter completed tasks by date
  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _filterCompletedTasks();
    notifyListeners();
  }

  void _filterCompletedTasks() {
    if (_selectedDate == null) {
      _filteredCompletedRequests = List.from(_completedRequests);
    } else {
      _filteredCompletedRequests = _completedRequests.where((request) {
        if (request['completedAt'] == null) return false;
        DateTime completedDate = DateTime.parse(request['completedAt']);
        return DateUtils.isSameDay(completedDate, _selectedDate);
      }).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
