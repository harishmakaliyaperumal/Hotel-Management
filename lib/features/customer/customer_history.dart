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

class _CustomerHistoryState extends State<CustomerHistory> with TickerProviderStateMixin {
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
      setState(() {
        _history = requests.map((request) => request.toMap()).toList(); // Convert to map
      });
    } catch (e) {
      debugPrint('Error in _loadHistory: $e');
      setState(() {
        _history = []; // Handle the error by treating it as "no data"
      });

      if (mounted) {
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
        return task['descriptionNorweign'] ?? task['description'] ?? 'No description available';
      case 'ar':
        return task['descriptionArabian'] ?? task['description'] ?? 'No description available';
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
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task['taskName'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task['jobStatus'] ?? '')
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate(
                        task['jobStatus']?.toLowerCase() ??
                            '') ??
                        'N/A',
                    style: TextStyle(
                      color: _getStatusColor(
                          task['jobStatus'] ?? ''),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),


            // const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: Text(
            //         _getLocalizedDescription(task),
            //         style: const TextStyle(fontSize: 14, color: Colors.black87),
            //         maxLines: 2,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //     Text(
            //       'Link',
            //       style: TextStyle(
            //         color: Colors.blue,
            //         decoration: TextDecoration.underline,
            //       ),
            //     ),
            //   ],
            // ),


            const SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context).translate('cus_req_his_card_st_label')} ${_formatDate(task['starttime'])}',
                ),
                Text(
                  '${AppLocalizations.of(context).translate('cus_req_his_card_et_label')} ${_formatDate(task['endTime'])}',
                ),
              ],

            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getLocalizedDescription(task),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => RatingPopup(task: task,requestDataId: task['requestDataId'],),
                    );
                  },
                  child: Text(
                    'Feedback',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;
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
        },
        apiService: _apiService,
        // backgroundColor: Colors.lightPink, // Light pink color as per preference
      ),
      body: Column(
        children: [
          if (_hasOrderFoodTask())
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryColor,
              tabs: [
                Tab(
                    text: AppLocalizations.of(context).translate('services_tab')),
                Tab(
                    text: AppLocalizations.of(context).translate('food_tab')),
              ],
            ),
          Expanded(
            child: _hasOrderFoodTask()
                ? TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryList(context, currentLanguage),
                _buildOrderFoodList(context,currentLanguage),
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


