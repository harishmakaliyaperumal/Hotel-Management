import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/customer/widgets/ratingpopup.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';

import '../../classes/language.dart';
import '../../common/helpers/app_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import 'customerhistorymodels/cus_his_models.dart';

class CustomerHistory extends StatefulWidget {
  const CustomerHistory({super.key});

  @override
  State<CustomerHistory> createState() => _CustomerHistoryState();
}

class _CustomerHistoryState extends State<CustomerHistory>
    with TickerProviderStateMixin {
  bool _isHistoryLoading = true;
  List<Map<String, dynamic>> _history = [];
  final ApiService _apiService = ApiService();
  String _currentLanguage = 'en';
  late Future<List<CustomerRequest>> _customerRequests;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadHistory();

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose the tab controller
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inprogress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isHistoryLoading = true; // Start the loading indicator
    });

    try {
      final requests = await _apiService.getCustomerRequestsById();
      if (mounted) {
        setState(() {
          _history = requests.map((request) => request.toMap()).toList(); // Convert to map
        });
      }
    } catch (e) {
      debugPrint('Error in _loadHistory: $e');
      if (mounted) {
        setState(() {
          _history = []; // Handle the error by treating it as "no data"
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHistoryLoading = false;
        });
      }
    }
  }

  // Updated date formatting method for the CustomerHistory widget
  String _formatDateTime(Map<String, dynamic> task) {
    // For Scheduled status, use date and time fields if available
    if (task['jobStatus'] == 'Scheduled') {
      final date = task['date']?.toString();
      final time = task['time']?.toString();

      if (date != null || time != null) {
        String formattedDate = 'N/A';
        String formattedTime = 'N/A';

        if (date != null && date.isNotEmpty) {
          try {
            final dateTime = DateTime.parse(date);
            formattedDate = '${dateTime.day.toString().padLeft(2, '0')}-'
                '${dateTime.month.toString().padLeft(2, '0')}-'
                '${dateTime.year}';
          } catch (e) {
            formattedDate = 'N/A';
          }
        }

        if (time != null && time.isNotEmpty) {
          try {
            final dateTime = DateTime.parse(time);
            formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:'
                '${dateTime.minute.toString().padLeft(2, '0')}';
          } catch (e) {
            formattedTime = 'N/A';
          }
        }

        return '$formattedDate $formattedTime';
      }
    }

    // For other statuses or if date/time not available, use starttime/endTime
    return task['starttime'] != null
        ? _formatDateTimeFromString(task['starttime'])
        : 'N/A';
  }

  String _formatDateTimeFromString(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}-'
          '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      // return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  bool _hasOrderFoodTask() {
    return _history.any((task) =>
    task['taskName']?.toLowerCase().contains('order food') ?? false);
  }

  // New method to get localized task name

  String _getLocalizedDescription(Map<String, dynamic> task) {
    switch (_currentLanguage) {
      case 'no':
        return task['descriptionNorweign'] ??
            task['description'] ??
            'No description available';
      case 'ar':
        return task['descriptionArabian'] ??
            task['description'] ??
            'No description available';
      default:
        return task['description'] ?? 'No description available';
    }
  }

  Widget _buildHistoryList(BuildContext context, String currentLanguage) {
    final tasks = _hasOrderFoodTask()
        ? _history.where((task) =>
    !task['taskName']?.toLowerCase().contains('order food') ?? false)
        : _history;

    return tasks.isEmpty
        ? Center(
      child: Text(
        AppLocalizations.of(context)
            .translate('cus_pg_req_his_nohis_htext'),
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    )
        : ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(tasks.elementAt(index));
      },
    );
  }

  Widget _buildOrderFoodList(BuildContext context, String currentLanguage) {
    final orderFoodTasks = _history.where((task) =>
    task['taskName']?.toLowerCase().contains('order food') ?? false);

    return orderFoodTasks.isEmpty
        ? Center(
      child: Text(
        AppLocalizations.of(context).translate('no_order_food_tasks'),
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    )
        : ListView.builder(
      itemCount: orderFoodTasks.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(orderFoodTasks.elementAt(index));
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> task) {
    String headingText = task['taskName'] != null && task['taskName'].toString().isNotEmpty
        ? task['taskName']
        : (task['laterServiceName'] ?? 'N/A');

    // Determine if time rows should be shown
    bool showTimeRows = !task.containsKey('laterServiceName');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      headingText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A6E75),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task['jobStatus'] ?? '')
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(task['jobStatus'] ?? '')
                            .withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).translate(
                          task['jobStatus']?.toLowerCase() ?? '') ??
                          'N/A',
                      style: TextStyle(
                        color: _getStatusColor(task['jobStatus'] ?? ''),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (showTimeRows)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildTimeRow(
                        context,
                        'cus_req_his_card_st_label',
                        _formatDate(task['starttime']),
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 8),
                      _buildTimeRow(
                        context,
                        'cus_req_his_card_et_label',
                        _formatDate(task['endTime']),
                        Icons.event_available,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _getLocalizedDescription(task),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => RatingPopup(
                          task: task,
                          requestDataId: task['requestDataId'],
                          otherServiceHistoryId: task['otherServiceHistoryId'],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A6E75).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_outline,
                              size: 16, color: const Color(0xFF2A6E75)),
                          const SizedBox(width: 4),
                          Text(
                            'Feedback',
                            style: TextStyle(
                              color: const Color(0xFF2A6E75),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(
      BuildContext context, String labelKey, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '${AppLocalizations.of(context).translate(labelKey)}: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A6E75),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {},
        isLoginPage: false,
        extraActions: [],
        dashboardType: DashboardType.user,
        onLogout: () => logOut(context),
        apiService: _apiService,
      ),
      body: Column(
        children: [
          if (_hasOrderFoodTask()) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF2A6E75),
                labelColor: const Color(0xFF2A6E75),
                unselectedLabelColor: Colors.grey.shade600,
                tabs: [
                  Tab(
                      text: AppLocalizations.of(context)
                          .translate('services_tab')),
                  Tab(text: AppLocalizations.of(context).translate('food_tab')),
                ],
              ),
            ),
          ],
          Expanded(
            child: _hasOrderFoodTask()
                ? TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryList(context, currentLanguage),
                _buildOrderFoodList(context, currentLanguage),
              ],
            )
                : _buildHistoryList(context, currentLanguage),
          ),
        ],
      ),
    );
  }
}

/// Builds a reusable row widget with a label and value.
Widget _buildInfoRow(BuildContext context, String label, String value,
    {bool isExpanded = false}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      const SizedBox(width: 5),
      isExpanded
          ? Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xff013457),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      )
          : Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xff013457),
        ),
      ),
    ],
  );
}
