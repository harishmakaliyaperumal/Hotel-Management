import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:intl/intl.dart';

import '../../../../classes/language.dart';
import '../../../../common/helpers/app_bar.dart';
import '../../../../l10n/app_localizations.dart';




class BreakHistory extends StatefulWidget {
  final int userId;


  const BreakHistory({super.key, required this.userId});

  @override
  _BreakHistoryState createState() => _BreakHistoryState();
}

class _BreakHistoryState extends State<BreakHistory> {
  List<BreakRequest> breakData = [];
  bool isLoading = true;
  String? errorMessage;
  final ApiService breakService = ApiService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchBreakHistory();
  }

  String formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    try {
      // Try parsing as DateTime first
      try {
        final DateTime dateTime = DateTime.parse(timeStr);
        return DateFormat('hh:mm a').format(dateTime);
      } catch (_) {
        // If it's just time string (HH:mm:ss)
        final TimeOfDay time = TimeOfDay(
          hour: int.parse(timeStr.split(':')[0]),
          minute: int.parse(timeStr.split(':')[1]),
        );

        // Convert 24-hour format to 12-hour format with AM/PM
        final String period = time.hour >= 12 ? 'PM' : 'AM';
        final int hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
        final String minute = time.minute.toString().padLeft(2, '0');

        return '$hour:$minute $period';
      }
    } catch (e) {
      return '-';
    }
  }

  Future<void> fetchBreakHistory() async {
    try {
      final response = await breakService.getAllBreakRequests();
      setState(() {
        breakData = (response)
            .map((item) => BreakRequest.fromJson(item as Map<String, dynamic>))
            .toList();
        isLoading = false;
      });
        } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final int userId = userId;
    return Scaffold(
      appBar:  buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {
          // Handle language change
        },
        isLoginPage: false,
        extraActions: [], dashboardType: DashboardType.other,
        onLogout: () {
          logOut(context);
        },  apiService: _apiService,

      ),
      body: RefreshIndicator(
        onRefresh: fetchBreakHistory,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : breakData.isEmpty
              ?  Center(
            child: Text(
              AppLocalizations.of(context).translate("br_his_text_break_history"),
              // 'No break history available',
              style: TextStyle(fontSize: 16),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("br_his_text_break_history"),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Text(
              //   'Break History - User ID: ${widget.userId}',
              //   style: const TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns:  [
                      DataColumn(
                        label: Text(AppLocalizations.of(context).translate('br_his_tab_date') ?? 'Date'),
                      ),
                      DataColumn(
                        label: Text(AppLocalizations.of(context).translate('br_his_tab_start_time') ?? 'Start Time'),
                      ),
                      DataColumn(
                        label: Text(AppLocalizations.of(context).translate('br_his_tab_end_time') ?? 'End Time'),
                      ),
                      DataColumn(
                        label: Text(AppLocalizations.of(context).translate('br_his_tab_status') ?? 'Status'),
                      ),
                    ],
                    rows: breakData.map((breakItem) {
                      return DataRow(cells: [
                        DataCell(Text(formatDate(breakItem.breakCreatedOn))),
                        DataCell(Text(formatTime(breakItem.startTime))),
                        DataCell(Text(formatTime(breakItem.endTime))),
                        DataCell(Text(breakItem.status ?? '-')),
                      ]);
                    }).toList(),
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

class BreakRequest {
  final String? breakCreatedOn;
  final String? startTime;
  final String? endTime;
  final String? status;

  BreakRequest({
    this.breakCreatedOn,
    this.startTime,
    this.endTime,
    this.status,
  });

  factory BreakRequest.fromJson(Map<String, dynamic> json) {
    return BreakRequest(
      breakCreatedOn: json['breakCreatedOn']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'breakCreatedOn': breakCreatedOn ?? '',
      'startTime': startTime ?? '',
      'endTime': endTime ?? '',
      'status': status ?? '',
    };
  }
}