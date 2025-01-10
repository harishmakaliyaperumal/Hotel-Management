import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/auth/screens/login.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:holtelmanagement/common/widgets/custom_button.dart';
import 'package:holtelmanagement/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../classes/language.dart';
import '../../../common/helpers/app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/categorymodel.dart';

class UserDashboard extends StatefulWidget {
  final String userName;
  final int userId;
  final Map<String, dynamic> loginResponse;
  final int roomNo;
  final int floorId;
  final String rname;

  const UserDashboard(
      {super.key,
      required this.userName,
      required this.userId,
      required this.loginResponse,
      required this.roomNo,
      required this.floorId,
      required this.rname});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedTaskId; // Store taskDataId
  // int? _selectedTaskId1;
  // int? _selectedTaskId2;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _tasks = []; // Task list from API
  List<Map<String, dynamic>> _tasks1 = [];
  bool _isLoading = true; // Loading indicator
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _history = [];

  int? _selectedTaskCategoryId;
  int? _selectedTaskSubcategoryId;
  int? _selectedCustomerTaskId;

  List<TaskCategoryModel> _taskCategories = [];
  List<TaskSubcategoryModel> _taskSubcategories = [];
  List<CustomerTaskModel> _customerTasks = [];

  // List<CustomerTaskModel> Tasks = [];

  // Language _selectedLanguage = Language.languageList()[0];
  bool _isHistoryLoading = true;
  String _currentLanguage = 'en';

  // String currentLanguage = Localizations.localeOf(context).languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLanguage = Localizations.localeOf(context).languageCode;
    _fetchTaskCategories();
  }
  // Fetch Task Categories
  Future<void> _fetchTaskCategories() async {
    try {
      setState(() {
        _isLoading = true; // Add a loading state
        // _error = null; // Clear any previous errors
      });
      final categories = await _apiService.fetchTaskCategories();
      setState(() {
        _taskCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show snackbar, log error, etc.)
      print('Error fetching task categories: $e');
    }
  }
  // Fetch Task Subcategories based on selected Category
  Future<void> _fetchTaskSubcategories(int taskCategoryId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final subcategories = await _apiService.fetchTaskSubcategories(taskCategoryId);

      print('Fetched Subcategories:');
      for (var taskSubCategory in subcategories) {
        print('Subcategory ID: ${taskSubCategory.taskSubCategoryId}, '
            'Name: ${taskSubCategory.taskSubCategoryName}, '
            'Category ID: ${taskSubCategory.taskCategoryId}');
      }

      setState(() {
        _taskSubcategories = subcategories;
        _isLoading = false;

        // Reset dependent dropdowns
        _selectedTaskSubcategoryId = null;
        _customerTasks = [];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _taskSubcategories = [];
      });
      print('Error fetching task subcategories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load subcategories')),
      );
    }
  }

  // Fetch Customer Tasks based on selected Subcategory
  Future<void> _fetchCustomerTasks(int taskSubCategoryId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final tasks = await _apiService.fetchCustomerTasks(taskSubCategoryId);

      setState(() {
        _customerTasks = tasks;
        _selectedCustomerTaskId = null;
        _isLoading = false;
      });

      print('Fetched Customer Tasks: ${_customerTasks.length}');
    } catch (error) {
      print('Error fetching tasks: $error');
      setState(() {
        _isLoading = false;
        _customerTasks = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch customer tasks')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Make sure this is properly initialized
    _taskCategories = []; // Initialize as an empty list
    _taskSubcategories = [];
    _customerTasks = [];
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadHistory();
  //
  //
  //   if (mounted) {
  //     setState(() {
  //       _isHistoryLoading = false;
  //       // _history = requests;
  //     });
  //   }
  // }

  // Future<void> _loadHistory() async {
  //   setState(() {
  //     _isHistoryLoading = true; // Start the loading indicator
  //   });
  //
  //   try {
  //     final requests = await _apiService.getCustomerRequestsById();
  //     setState(() {
  //       _history = requests; // Update the history with fetched data
  //     });
  //   } catch (e) {
  //     // Log the error for debugging (remove this in production)
  //     debugPrint('Error in _loadHistory: $e');
  //     setState(() {
  //       _history = []; // Handle the error by treating it as "no data"
  //     });
  //
  //     // Show the error message to the user
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Failed to load data. Please try again later.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     // Ensure the loading indicator is turned off
  //     if (mounted) {
  //       setState(() {
  //         _isHistoryLoading = false;
  //       });
  //     }
  //   }
  // }

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

  // New method to get localized task name
  String _getLocalizedTaskName(Map<String, dynamic> task) {
    switch (_currentLanguage) {
      case 'no':
        return task['taskNameNorweign'] ?? task['taskName'] ?? 'Select Task';
      case 'ar':
        return task['taskNameArabian'] ?? task['taskName'] ?? 'Select Task';
      default:
        return task['taskName'] ?? 'Select Task';
    }
  }

  // Future<void> _loadTasks() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     // Fetch tasks from API
  //     final List<Map<String, dynamic>> fetchedTasks =
  //         await _apiService.fetchTasks();
  //
  //     // Process tasks with localized names
  //     final processedTasks = fetchedTasks.map((task) {
  //       return {
  //         ...task,
  //         'localizedTaskName': _getLocalizedTaskName(task),
  //         // Ensure taskDataId is converted to an int
  //         'taskDataId': task['taskDataId'] is int
  //             ? task['taskDataId']
  //             : int.tryParse(task['taskDataId'].toString()) ?? 0
  //       };
  //     }).toList();
  //
  //     // Add a default 'Select Task' option
  //     processedTasks.insert(0, {
  //       'taskDataId': null,
  //       'localizedTaskName':
  //           AppLocalizations.of(context).translate('cus_pg_form_select'),
  //       'taskName': 'Select Task'
  //     });
  //
  //     setState(() {
  //       _tasks = processedTasks;
  //       _isLoading = false;
  //       _selectedTaskId = null; // Set to null to show default 'Select' option
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //       _tasks = [
  //         {
  //           'taskDataId': null,
  //           'localizedTaskName':
  //               AppLocalizations.of(context).translate('cus_pg_form_select'),
  //           'taskName': 'Select Task'
  //         }
  //       ];
  //     });
  //
  //     // Show error snackbar
  //     Future.microtask(() {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to load tasks: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     });
  //   }
  // }

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
          taskId: _selectedCustomerTaskId!,
          taskCategoryId: _selectedTaskCategoryId!, // Add this line
          taskSubCategoryId: _selectedTaskSubcategoryId!,
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

        Navigator.of(context).pop();
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

    // Common decoration for Dropdowns and TextFormField
    InputDecoration commonDecoration(String labelText) {
      return InputDecoration(
        labelText: AppLocalizations.of(context).translate(labelText),
        labelStyle: const TextStyle(color: Colors.grey), // Consistent light gray label text
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey, // Light gray border for enabled state
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.grey, // Light gray border for focused state
            width: 1.5,
          ),
        ),
      );
    }

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown menu for selecting task
                DropdownButtonFormField<int>(
                  decoration: commonDecoration('user_page_select_task_category'),
                  value: _selectedTaskCategoryId,
                  items: _taskCategories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.taskCategoryId,
                      child: Text(category.taskCategoryName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTaskCategoryId = value;
                        _selectedTaskSubcategoryId = null;
                        _selectedCustomerTaskId = null;
                        _taskSubcategories = [];
                        _customerTasks = [];
                      });
                      _fetchTaskSubcategories(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppLocalizations.of(context)!.translate(
                          'user_page_valid_message_please_select_category');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Task Subcategory Dropdown
                DropdownButtonFormField<int>(
                  decoration: commonDecoration('user_page_select_task_subcategory'),
                  value: _selectedTaskSubcategoryId,
                  items: _taskSubcategories.map((subcategory) {
                    return DropdownMenuItem<int>(
                      value: subcategory.taskSubCategoryId,
                      child: Text(subcategory.taskSubCategoryName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTaskSubcategoryId = value;
                        _selectedCustomerTaskId = null;
                        _customerTasks = [];
                      });
                      _fetchCustomerTasks(value);
                    }
                  },
                  validator: (value) {
                    if (_selectedTaskCategoryId != null && value == null) {
                      return AppLocalizations.of(context)!.translate(
                          'user_page_valid_message_please_select_subcategory');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Customer Task Dropdown
                DropdownButtonFormField<int>(
                  decoration: commonDecoration('user_page_select_task_customer_task'),
                  value: _selectedCustomerTaskId,
                  items: _customerTasks.isEmpty
                      ? []
                      : _customerTasks.map((task) {
                    return DropdownMenuItem<int>(
                      value: task.taskId,
                      child: Text(task.taskName),
                    );
                  }).toList(),
                  onChanged: _customerTasks.isEmpty
                      ? null
                      : (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTaskId = value;
                        _selectedCustomerTaskId = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (_selectedTaskSubcategoryId != null && value == null) {
                      return AppLocalizations.of(context)!.translate(
                          'user_page_valid_message_please_select_customer_task');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Description input
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black), // Consistent text color
                  decoration: commonDecoration('cus_pg_form_field_des'),
                  // Uncomment if validation is required
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return AppLocalizations.of(context)
                  //         .translate('cus_req_for_notfill_error_msg');
                  //   }
                  //   return null;
                  // },
                ),

                const SizedBox(height: 20),

                // Submit button
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(
                          8.0), // Rounded corners for the button
                    ),
                    child: CustomButton(
                      text: AppLocalizations.of(context)
                          .translate('cus_pg_form_field_butt'),
                      onPressed: _submitRequest,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
