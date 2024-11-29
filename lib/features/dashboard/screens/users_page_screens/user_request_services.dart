import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/auth/screens/login.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:holtelmanagement/common/widgets/custom_button.dart';
import 'package:holtelmanagement/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../classes/language.dart';
import '../../../../common/helpers/app_bar.dart';
import '../../../../l10n/app_localizations.dart';

class UserDashboard extends StatefulWidget {
  final String userName;
  final int userId;
  final Map<String, dynamic> loginResponse;
  final int roomNo;
  final int floorId;
  final String rname;


  const UserDashboard({super.key,
    required this.userName,
    required this.userId,
    required this.loginResponse,
    required this.roomNo,
    required this.floorId,
    required this.rname

  });



  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedTaskId; // Store taskDataId
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _tasks = []; // Task list from API
  bool _isLoading = true; // Loading indicator
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _history = [];
  // Language _selectedLanguage = Language.languageList()[0];
  bool _isHistoryLoading = true;
  // String currentLanguage = Localizations.localeOf(context).languageCode;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadHistory();
  }

  // void _changeLocale(Language language) {
  //   setState(() {
  //     _selectedLanguage = language;
  //     // Add code here if you need to update app's locale based on language selection
  //   });
  // }




  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isHistoryLoading = true;
      });

      final requests = await _apiService.getCustomerRequestsById();

      setState(() {
        _history = requests;
        _isHistoryLoading = false;
      });
    } catch (e) {
      setState(() {
        _isHistoryLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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


  // Fetch tasks from the API via ApiService
  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Directly use the list returned from fetchTasks
      final tasks = await _apiService.fetchTasks();

      setState(() {
        _tasks = tasks; // No need to extract 'data', tasks is already a List
        _isLoading = false;

        // _selectedTaskId = null;

        // Ensure _selectedTaskId is initialized to the first task if tasks exist
        // if (_tasks.isNotEmpty && _selectedTaskId == null) {
        //   _selectedTaskId = _tasks[0]['taskDataId'] as int;
        // }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tasks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Submit request via ApiService
  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        String currentLanguage = Localizations.localeOf(context).languageCode;

        // Prepare descriptions
        String description = _messageController.text;
        String? descriptionNorwegian;

        // Optional: Add specific handling for Norwegian
        if (currentLanguage == 'no') {
          descriptionNorwegian = description;
          description = ''; // Or handle differently based on your requirements
        }

        await _apiService.saveGeneralRequest(
          floorId: widget.floorId,
          taskId: _selectedTaskId!,
          roomDataId: widget.roomNo,
          rname: widget.userName,
          requestType: 'Customer Request',
          description: description,
          requestDataCreatedBy: widget.userId,
          descriptionNorwegian: descriptionNorwegian,
        );

        // Success handling...
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('cur_pg_sub_notify_msg'),
            ),
          ),
        );

        _messageController.clear();
        setState(() {
          _selectedTaskId = null;
        });
      } catch (e) {
        // Error handling...
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final String currentLanguage = Localizations.localeOf(context).languageCode;
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

        },apiService: _apiService,

      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown menu for selecting task
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  // labelText: 'Select Task',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xffB5E198), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xffB5E198), width: 1.5),
                  ),
                  // filled: true,
                  // fillColor: Color(0xFFC4DAD2),
                ),
                style: const TextStyle(color: Colors.black),
                value: _selectedTaskId,
                hint:  Text(AppLocalizations.of(context).translate("cus_pg_form_select"),), // This will show when value is null
                items: _tasks.map((task) {
                  return DropdownMenuItem<int>(
                    value: task['taskDataId'] as int,
                    child: Text(task['taskName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context).translate('please_select');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description input
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('cus_pg_form_field_des') ,
                  // labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.black),
                  // filled: true,
                  // fillColor: Color(0xFFC4DAD2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xffB5E198), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xffB5E198), width: 1.5),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).translate('cus_req_for_notfill_error_msg');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners for the button
                  ),
                  child: CustomButton(
                      text: AppLocalizations.of(context).translate('cus_pg_form_field_butt'),
                      onPressed:_submitRequest),
                ),
              ),

              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.backgroundColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      // History Header
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color:AppColors.backgroundColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(13),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('cus_pg_req_his_htext'),
                              // 'Request History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: _loadHistory,
                            ),
                          ],
                        ),
                      ),
                      // History List
                      Expanded(
                        child: _isHistoryLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _history.isEmpty
                            ? Center(
                          child: Text(
                            AppLocalizations.of(context).translate('cus_pg_req_his_nohis_htext'),
                            // 'No request history available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Task Name Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              item['taskName'] ?? 'N/A', // Displaying taskName from API
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff013457),
                                              ),
                                            ),

                                          ),
                                        ),

                                        // Status Container
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(item['jobStatus'] ?? '').withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            // Translate jobStatus, falling back to 'N/A' if translation or status is missing
                                            AppLocalizations.of(context).translate(item['jobStatus']?.toLowerCase() ?? '') ?? 'N/A',
                                            style: TextStyle(
                                              color: _getStatusColor(item['jobStatus'] ?? ''),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Start Time Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        Text(
                                          AppLocalizations.of(context).translate('cus_pg_req_his_card_date'),
                                          // 'Date: ',  // Label
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          _formatDate(item['starttime']),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                        ),

                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        // Static Text (Label)
                                        Text(
                                          AppLocalizations.of(context).translate('cus_pg_req_his_card_description'),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),

                                        // Dynamic Description Based on Language
                                        Text(
                                          currentLanguage == 'no'
                                              ? (item['descrittionNorweign'] ?? 'No description available')
                                              : (item['description'] ?? 'No description available'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff013457),
                                          ),
                                        )
                                      ],
                                    ),


                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).translate('cus_req_his_card_st_label'),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          _formatTime(item['starttime']),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                        ),

                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).translate('cus_req_his_card_et_label'),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          _formatTime(item['endTime']),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                        ),

                                      ],
                                    ),
                                    const SizedBox(height: 4),



                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.start,
                                    //   children: [
                                    //     Text(
                                    //       _formatTime(item['EndTime']),
                                    //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                    //     ),
                                    //     Text(
                                    //       item['endTime'] ?? 'N/A',
                                    //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                    //     ),
                                    //   ],
                                    // ),


                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
