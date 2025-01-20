import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/customer/customer_other_services/widgets/models/OtherServiceSlot_models.dart';
import 'package:holtelmanagement/features/customer/customer_other_services/widgets/otherservices_models.dart';

import '../../../classes/language.dart';
import '../../../common/helpers/app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/apiservices.dart';
import 'package:intl/intl.dart';

class ServiceDropdownPage extends StatefulWidget {
  final String userName;
  final int userId;
  final Map<String, dynamic> loginResponse;
  final int roomNo;
  final int floorId;
  final String rname;

  const ServiceDropdownPage(
      {super.key,
        required this.userName,
        required this.userId,
        required this.loginResponse,
        required this.roomNo,
        required this.floorId,
        required this.rname});

  @override
  _ServiceDropdownPageState createState() => _ServiceDropdownPageState();
}

class _ServiceDropdownPageState extends State<ServiceDropdownPage> {
  // List to hold the services and schedules
  List<Service> _services = [];
  Service? _selectedService;
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String get formattedDate {
    if (_selectedDate == null) return 'Select date';
    return DateFormat('dd-MM-yyyy').format(_selectedDate!);
  }



  // To hold the schedule data for the selected service
  Map<String, List<Schedule>> _availableSchedules = {}; // Grouped by day
  int? _selectedSchedule; // For the second dropdown (schedule times)

  final ApiService _apiService = ApiService();

  // Method to fetch the services
  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous errors
    });

    try {
      // Call the API to fetch services
      ServiceResponse serviceResponse = await _apiService.fetchServices();

      setState(() {
        _services = serviceResponse.data;
        _selectedService = null; // Set the selected service to null initially
        _availableSchedules = {}; // Clear any previous schedules
        _selectedSchedule = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch services: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to fetch schedule data based on selected service
  Future<void> _fetchSchedule(int serviceId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous errors
      _availableSchedules = {}; // Clear previous schedules
      _selectedSchedule = null; // Reset selected day
    });

    try {
      // Call the API to fetch the schedule based on service ID
      OtherServiceSlot serviceSlot =
      await _apiService.fetchServiceSlots(serviceId);

      // Convert the schedule from the API response into a list of schedules
      setState(() {
        _availableSchedules = _getSchedulesFromResponse(serviceSlot);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch schedule data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  bool isValidDateTime() {
    if (_selectedDate == null || _selectedTime == null) return false;

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    return selectedDateTime.isAfter(now);
  }

// Add this getter back at the top of the class with other getters
  String get formattedTime {
    if (_selectedTime == null) return 'Select time';
    final hours = _selectedTime!.hourOfPeriod.toString().padLeft(2, '0');
    final minutes = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hours:$minutes $period';
  }

// Updated time picker method without selectableTimePredicate
  Future<void> _formattedTime(BuildContext context) async {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();
    final isToday = _selectedDate?.year == now.year &&
        _selectedDate?.month == now.month &&
        _selectedDate?.day == now.day;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: isToday ? TimeOfDay.now() : const TimeOfDay(hour: 9, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
      cancelText: "Cancel",
      confirmText: "Confirm",
      hourLabelText: "Hour",
      minuteLabelText: "Minute",
    );

    if (selectedTime != null) {
      // Validate the selected time
      if (isToday) {
        // Convert both times to minutes since midnight for easy comparison
        final selectedMinutes = selectedTime.hour * 60 + selectedTime.minute;
        final currentMinutes = currentTime.hour * 60 + currentTime.minute;

        if (selectedMinutes < currentMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              // 'Please select a future time'
              content: Text(AppLocalizations.of(context)
                  .translate('user_pg_os_popup_msg_futuretime'),),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        _selectedTime = selectedTime;
      });
    }
  }

// Modified date picker method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      selectableDayPredicate: (DateTime date) {
        // Disable past dates
        return date.isAtSameMomentAs(DateTime.now()) ||
            date.isAfter(DateTime.now());
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Reset time if date changes to today
        if (picked.year == DateTime.now().year &&
            picked.month == DateTime.now().month &&
            picked.day == DateTime.now().day) {
          _selectedTime = null;
        }
      });
    }
  }


  Future<void> _submitRequest() async {
    // Create a map to hold the request data with only the common fields
    final Map<String, dynamic> requestData = {
      'otherServiceId': _selectedService?.id,
      'serviceCreatedBy': widget.userId,
      'jobStatus': "Scheduled",
      'floorId': widget.floorId,
      'roomDataId': widget.roomNo,
      'rname': widget.rname,
    };

    // Add schedule-specific or date/time-specific fields based on the use case
    if (_availableSchedules.isNotEmpty && _selectedSchedule != null) {
      // When using predefined schedules, add scheduleId
      requestData['scheduleId'] = _selectedSchedule;
    } else if (_availableSchedules.isEmpty) {
      // Using manual date/time picker
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            // 'Please select a date'
            content: Text(AppLocalizations.of(context)
                .translate('user_pg_os_validation_msg_date'),),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('user_pg_os_validation_msg_time'),),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Add date and time fields only when using manual selection
      requestData['date'] = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      requestData['time'] = _selectedTime!.format(context);
    }

    try {
      // Send the request with only the relevant fields
      final response = await _apiService.bookotherservices(
        otherServiceId: requestData['otherServiceId'] ?? 0,
        serviceCreatedBy: requestData['serviceCreatedBy'],
        jobStatus: requestData['jobStatus'],
        scheduleId: requestData['scheduleId'] ?? 0,
        // Only passed when scheduleId exists
        time: requestData['time'] ?? "",
        date: requestData['date'] ?? "",
        floorId: requestData['floorId'],
        roomDataId: requestData['roomDataId'],
        rname: requestData['rname'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          // 'Service request submitted successfully!'
          content: Text(AppLocalizations.of(context)
              .translate('user_pg_os_validation_msg_success'),),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Failed to submit service request: $e
          content: Text(AppLocalizations.of(context)
              .translate('user_pg_os_validation_msg_failed'),),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// // Helper to extract schedule ID from selected schedule string
//   int _getScheduleId(String scheduleString) {
//     // Implement logic to map the selected schedule string to its ID
//   }




  // Helper method to extract schedules from the API response
  Map<String, List<Schedule>> _getSchedulesFromResponse(
      OtherServiceSlot serviceSlot) {
    return serviceSlot.data.schedule;
  }

  @override
  void initState() {
    super.initState();
    _fetchServices(); // Fetch services on initial load
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)
                      .translate('user_pg_os_text_select_service'),
                  style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Service>(
                        isExpanded: true,
                        value: _selectedService,
                        // Choose a service
                        hint: Text(AppLocalizations.of(context)
                            .translate('user_pg_os_text_choose_a_service'),),
                        onChanged: (Service? newValue) {
                          setState(() {
                            _selectedService = newValue;
                          });
                          if (newValue != null) {
                            _fetchSchedule(newValue.id);
                          }
                        },
                        items: [
                          DropdownMenuItem<Service>(
                            value: null,
                            // 'Choose a service'
                            child: Text(AppLocalizations.of(context)
                                .translate('user_pg_os_text_choose_a_service'),),
                          ),
                          ..._services.map<DropdownMenuItem<Service>>(
                                  (Service service) {
                                return DropdownMenuItem<Service>(
                                  value: service,
                                  child: Text(service.serviceName),
                                );
                              }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color:
                                Theme.of(context).colorScheme.error),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color:
                                  Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 24),
                if (_selectedService != null) ...[
                  // 'Choose Time Slot',
                  Text(
                    AppLocalizations.of(context)
                        .translate('user_pg_os_text_choose_time_slot'),
                    style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  _availableSchedules.isNotEmpty
                      ? Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedSchedule,
                            // 'Select available time slot'
                            hint: Text(AppLocalizations.of(context)
                                .translate('user_pg_os_text_select_available_time_slot'),),
                            onChanged: (int? newSchedule) {
                              setState(() {
                                _selectedSchedule =
                                    newSchedule; // Store the scheduleId
                              });
                            },
                            items: _generateScheduleDropdownItems(),
                          )),
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          onTap: () async {
                            DateTime? selectedDate =
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                              DateTime(DateTime.now().year + 1),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                _selectedDate = selectedDate;
                              });
                            }
                          },
                          leading: Icon(Icons.calendar_today),
                          title: Text(formattedDate),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16),
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          onTap: () => _formattedTime(context),
                          leading: Icon(Icons.access_time),
                          title: Text(formattedTime),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedDate != null || _selectedTime != null) ...[
                    SizedBox(height: 24),
                    Card(
                      elevation: 0,
                      color:
                      Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 'Selected Date & Time',
                            Text(
                              AppLocalizations.of(context)
                                  .translate('user_pg_os_text_selected_date_time'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (_selectedService != null &&
                          (_selectedDate != null ||
                              _availableSchedules.isNotEmpty) &&
                          (_selectedTime != null ||
                              _availableSchedules.isNotEmpty))
                          ? _submitRequest
                          : null,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // 'Book Now'
                      child: Text(AppLocalizations.of(context)
                          .translate('user_pg_os_text_book_now'),),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _generateScheduleDropdownItems() {
    List<DropdownMenuItem<int>> items = [];

    _availableSchedules.forEach((day, scheduleList) {
      for (var schedule in scheduleList) {
        String displayText =
            '$day (${schedule.startTime} to ${schedule.endTime})';
        items.add(DropdownMenuItem<int>(
          value: schedule.scheduleId, // Use scheduleId as value
          child: Text(displayText),
        ));
      }
    });

    return items;
  }
}
