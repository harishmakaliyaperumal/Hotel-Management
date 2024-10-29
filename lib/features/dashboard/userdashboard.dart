import 'package:flutter/material.dart';
import 'package:holtelmanagement/Common/app_bar.dart';
import 'package:holtelmanagement/features/auth/login.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';

class UserDashboard extends StatefulWidget {
  final String userName;
  final int userId;
  final Map<String, dynamic> loginResponse;
  final int roomNo;
  final int floorId;


  UserDashboard({
    required this.userName,
    required this.userId,
    required this.loginResponse,
    required this.roomNo,
    required this.floorId,

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
  bool _isHistoryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadHistory();
  }

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
        await _apiService.saveGeneralRequest(
          floorId: 1,
          taskId: _selectedTaskId!, // Pass the selected taskDataId
          roomDataId: 1,
          rname: 'Cleaning Request', // Example data, change as needed
          requestType: 'Customer Request',
          description: _messageController.text,
          requestDataCreatedBy: widget.userId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted successfully')),
        );
        _messageController.clear();
        setState(() {
          _selectedTaskId = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request')),
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
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Widget _buildHistoryCard() {
  //   if (_isHistoryLoading) {
  //     return Center(child: CircularProgressIndicator());
  //   }
  //
  //   if (_history.isEmpty) {
  //     return Card(
  //       elevation: 4,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(15),
  //         side: BorderSide(color: Color(0xff013457), width: 1.5),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Center(
  //           child: Text(
  //             'No request history available',
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return Column(
  //     children: [
  //       Container(
  //         padding: EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Color(0xff013457),
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Request History',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             IconButton(
  //               icon: Icon(Icons.refresh, color: Colors.white),
  //               onPressed: _loadHistory,
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //       Expanded(
  //         child: ListView.builder(
  //           itemCount: _history.length,
  //           itemBuilder: (context, index) {
  //             final item = _history[index];
  //             return Card(
  //               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  //               elevation: 4,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(15),
  //                 side: BorderSide(color: Color(0xff013457), width: 1),
  //               ),
  //               child: Padding(
  //                 padding: EdgeInsets.all(16),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Expanded(
  //                           child: Text(
  //                             item['taskName'] ?? 'N/A',
  //                             style: TextStyle(
  //                               fontSize: 18,
  //                               fontWeight: FontWeight.bold,
  //                               color: Color(0xff013457),
  //                             ),
  //                           ),
  //                         ),
  //                         Container(
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 12,
  //                             vertical: 6,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             color: _getStatusColor(item['jobStatus'] ?? '')
  //                                 .withOpacity(0.2),
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                           child: Text(
  //                             item['jobStatus'] ?? 'N/A',
  //                             style: TextStyle(
  //                               color: _getStatusColor(item['jobStatus'] ?? ''),
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 12),
  //                     Row(
  //                       children: [
  //                         Icon(Icons.calendar_today,
  //                             size: 16, color: Colors.grey),
  //                         SizedBox(width: 8),
  //                         Text(
  //                           'Start: ${_formatDate(item['starttime'])}',
  //                           style: TextStyle(color: Colors.grey[700]),
  //                         ),
  //                         SizedBox(width: 16),
  //                         Icon(Icons.access_time, size: 16, color: Colors.grey),
  //                         SizedBox(width: 8),
  //                         Text(
  //                           _formatTime(item['starttime']),
  //                           style: TextStyle(color: Colors.grey[700]),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         Icon(Icons.calendar_today,
  //                             size: 16, color: Colors.grey),
  //                         SizedBox(width: 8),
  //                         Text(
  //                           'End: ${_formatDate(item['endTime'])}',
  //                           style: TextStyle(color: Colors.grey[700]),
  //                         ),
  //                         SizedBox(width: 16),
  //                         Icon(Icons.access_time, size: 16, color: Colors.grey),
  //                         SizedBox(width: 8),
  //                         Text(
  //                           _formatTime(item['endTime']),
  //                           style: TextStyle(color: Colors.grey[700]),
  //                         ),
  //                       ],
  //                     ),
  //                     if (item['description'] != null &&
  //                         item['description'].toString().isNotEmpty) ...[
  //                       SizedBox(height: 12),
  //                       Text(
  //                         item['description'],
  //                         style: TextStyle(
  //                           color: Colors.grey[600],
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                     ],
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        widget.userName,
            () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xff013457), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xff013457), width: 1.5),
                  ),
                  // filled: true,
                  // fillColor: Color(0xFFC4DAD2),
                ),
                style: TextStyle(color: Colors.black),
                value: _selectedTaskId,
                hint: Text('Select'), // This will show when value is null
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
                    return 'Please select a task';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Description input
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.black),
                  // filled: true,
                  // fillColor: Color(0xFFC4DAD2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xff013457), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xff013457), width: 1.5),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Submit button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff013457),
                       borderRadius: BorderRadius.circular(8.0), // Rounded corners for the button
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Make the button itself transparent
                      shadowColor: Colors.transparent, // Remove shadow to see gradient clearly
                    ),
                    onPressed: _submitRequest,
                    child: Text(
                      'Send Request',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xff013457), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      // History Header
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xff013457),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(13),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Request History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.white),
                              onPressed: _loadHistory,
                            ),
                          ],
                        ),
                      ),
                      // History List
                      Expanded(
                        child: _isHistoryLoading
                            ? Center(child: CircularProgressIndicator())
                            : _history.isEmpty
                            ? Center(
                          child: Text(
                            'No request history available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                            : ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return Card(
                              margin: EdgeInsets.all(8),
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
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff013457),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Status Container
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(item['jobStatus'] ?? '').withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item['jobStatus'] ?? 'N/A',
                                            style: TextStyle(
                                              color: _getStatusColor(item['jobStatus'] ?? ''),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),

                                    // Start Time Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date: ',  // Label
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          _formatDate(item['starttime']),
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Start Time: ',  // Label
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          _formatTime(item['starttime']),
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'End Time: ',  // Label
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          _formatTime(item['endTime']),
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff013457)),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 4),



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
