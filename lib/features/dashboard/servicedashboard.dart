import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/auth/login.dart';
import 'package:holtelmanagement/features/dashboard/serdash/breakhistory.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import '../../Common/app_bar.dart';

class ServicesDashboard extends StatefulWidget {
  final int userId;
  final String userName;
  final String? roomNo;
  final String? floorId;

  ServicesDashboard({
    required this.userId,
    required this.userName,
    this.roomNo,
    this.floorId,
  });

  @override
  _ServicesDashboardState createState() => _ServicesDashboardState();
}
class _ServicesDashboardState extends State<ServicesDashboard> {
  bool _jobStatus = false;
  List<Map<String, dynamic>> _generalRequests = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool isfinished  = false;
  List<String> statusHistory = [];





  int _currentStatusIndex = 0; // Index for tracking current status
  final List<String> _statuses = [
    'Accepted',
    'In Progress',
    'Door Checking',
    'Customer Feedback',
    'Completed'
  ];

  @override
  void initState() {
    super.initState();
    // Check initial job status and load requests if active
    _checkInitialJobStatus();
  }


  Future<bool> _onWillPop() async {
    return false; // Return false to disable back button
  }


  Future<void> _updateJobStatus() async {
    final request = _generalRequests.isNotEmpty ? _generalRequests[0] : null;
    if (request != null) {
      String requestJobHistoryId = request['requestJobHistoryId'].toString();
      String currentStatus = _statuses[_currentStatusIndex];

      try {

        print('Current status: $currentStatus');
        print('Next status (if available): ${_currentStatusIndex < _statuses.length - 1 ? _statuses[_currentStatusIndex] : 'Completed'}');

        // Make the API call
        await _apiService.Statusupdate(
          widget.userId,
          currentStatus,
          requestJobHistoryId,
        );

        // Update local state after successful API call
        setState(() {
          // Update current status in the request
          request['jobStatus'] = currentStatus;

          // Add to status history with timestamp
          String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
          statusHistory.add('$timestamp: $currentStatus');

          // Move to the next status if not already completed
          if (_currentStatusIndex < _statuses.length - 1) {
            _currentStatusIndex++;  // Increment to next status
            request['nextJobStatus'] = _statuses[_currentStatusIndex];
          } else {
            request['nextJobStatus'] = 'Completed';  // Final status
          }
        });

        // Show success message with current and next status
        String nextStatus = _currentStatusIndex < _statuses.length - 1
            ? _statuses[_currentStatusIndex]
            : 'Completed';
        _showSnackBar(
            'Status updated to: $currentStatus\nNext status: $nextStatus'
        );

      } catch (e) {
        print('Failed to update task: ${e.toString()}');
        print('userId: ${widget.userId}, jobStatus: $currentStatus, requestJobHistoryId: $requestJobHistoryId');

        // Revert any local changes if the API call fails
        _showSnackBar('Failed to update status: ${e.toString()}', isError: true);
      }
    } else {
      _showSnackBar('No request available to update status.', isError: true);
    }
  }





  Future<void> _checkInitialJobStatus() async {
    try {
      await _fetchGeneralRequests();
      if (_generalRequests.isNotEmpty) {
        setState(() {
          _jobStatus = true;
        });
      }
    } catch (e) {
      print('Error checking initial status: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleJobStatus(bool newValue) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateJobStatus(newValue, widget.userId.toString());

      setState(() {
        _jobStatus = newValue;
      });

      if (_jobStatus) {
        await _fetchGeneralRequests(); // Fetch only when active
      } else {
        setState(() {
          _generalRequests = []; // Clear when inactive
        });
      }
    }catch (e) {
      // Show an error message if the status update fails
      _showSnackBar('Error updating status: ${e.toString()}', isError: true);
      setState(() {
        _jobStatus = !newValue; // Revert the switch to its original state
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop the loading indicator
      });
    }
  }


  Future<void> _fetchGeneralRequests() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requests = await _apiService.getGeneralRequestsById();
      setState(() {
        _generalRequests = requests;
      });

      if (_jobStatus && _generalRequests.isEmpty) {
        _showSnackBar('No tasks available at the moment');
      }
    } catch (e) {
      print('Error fetching requests: $e');
      _showSnackBar('Error loading requests. Please try again.', isError: true);
      setState(() {
        _generalRequests = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }






  Widget _buildRequestCard(Map<String, dynamic> request, double screenWidth, double screenHeight) {
    bool isCompleted = request['jobStatus'] == 'Completed';

    return Card(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Name: ${request['userName'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            _buildInfoRow('Request', request['taskName'] ?? 'N/A', screenWidth),
            _buildInfoRow('Location', request['roomName'] ?? 'N/A', screenWidth),
            _buildInfoRow('Description', request['Description'] ?? 'N/A', screenWidth),
            _buildInfoRow('requestJobHistoryId', request['requestJobHistoryId'] ?? 'N/A', screenWidth),

            TextButton(
              onPressed: () async {
                await _updateJobStatus();
              },
              child: Text(
                'Current: ${request['jobStatus'] ?? 'N/A'}',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
            SizedBox(height: screenHeight * 0.015),

            SwipeableButtonView(
              buttonText: isCompleted ? "Completed" : "Swipe to Update Status",
              buttonWidget: Container(
                child: Icon(
                  Icons.arrow_back_ios_new_sharp,
                  color: isCompleted ? Colors.grey : Colors.greenAccent,
                  size: screenWidth * 0.05,
                ),
              ),
              onWaitingProcess: () async {
                if (!isCompleted) {
                  await Future.delayed(Duration(seconds: 2));
                  if (mounted) {
                    setState(() {
                      isfinished = true;
                    });
                    await _updateJobStatus();
                  }
                }
              },
              activeColor: isCompleted ? Colors.grey : Colors.blue,
              isFinished: isfinished,
              onFinish: () {
                setState(() {
                  isfinished = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }





  // Swipeable button that updates status
  Widget _buildSwipeButton() {
    return SwipeableButtonView(
      buttonText: "Swipe to Update Status",
      buttonWidget: Container(
        child: Icon(
          Icons.arrow_back_ios_new_sharp,
          color: Colors.greenAccent,
        ),
      ),
      onWaitingProcess: () async {
        // Simulate delay (API call time)
        await Future.delayed(Duration(seconds: 2));

        // Update the status when swipe is completed
        await _updateJobStatus(); // This will handle API and UI updates

        setState(() {
          isfinished = true; // Indicate that the swipe action is finished
        });
      },
      activeColor: Colors.blue,
      isFinished: isfinished,
      onFinish: () {
        // Reset the finished state to allow for the next swipe
        setState(() {
          isfinished = false;
        });
      },
    );
  }





  Widget _buildInfoRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.2,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Widget _buildStatusChip(String text, Color color) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: color.withOpacity(0.3)),
  //     ),
  //     child: Text(
  //       text,
  //       style: TextStyle(
  //         color: color,
  //         fontSize: 13,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   );
  // }
  //
  //
  // Widget _buildEmptyState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           _jobStatus ? Icons.inbox_outlined : Icons.toggle_off_outlined,
  //           size: 48,
  //           color: Colors.grey[400],
  //         ),
  //         SizedBox(height: 16),
  //         Text(
  //           _jobStatus
  //               ? 'No tasks available at the moment'
  //               : 'Toggle status to active to view tasks',
  //           style: TextStyle(
  //             fontSize: 18,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //         if (_jobStatus) ...[
  //           SizedBox(height: 16),
  //           TextButton.icon(
  //             onPressed: _fetchGeneralRequests,
  //             icon: Icon(Icons.refresh),
  //             label: Text('Refresh'),
  //             style: TextButton.styleFrom(
  //               foregroundColor: Colors.blue,
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }



  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: buildAppBar(
          widget.userName,
              () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          extraActions: [
            IconButton(
              icon: Icon(Icons.free_breakfast_rounded, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BreakHistory(userId: widget.userId),
                  ),
                );
              },
            ),
            _isLoading
                ? SizedBox(
              width: 50,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            )
                : Switch(
              value: _jobStatus,
              onChanged: _toggleJobStatus,
              activeColor: Colors.blue,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (_jobStatus) {
              await _fetchGeneralRequests();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Requests: ${_generalRequests.length}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          await _apiService.notifyBreaks(widget.userId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Break notified!")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to notify breaks")),
                          );
                        }
                      },
                      icon: Icon(Icons.notifications_active),
                      label: Text(
                        'Notify Breaks',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Expanded(
                  child: _generalRequests.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _jobStatus
                              ? Icons.inbox_outlined
                              : Icons.toggle_off_outlined,
                          size: screenWidth * 0.12,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          _jobStatus
                              ? 'No requests available at the moment'
                              : 'Toggle status to active to view requests',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: _generalRequests.length,
                    itemBuilder: (context, index) =>
                        _buildRequestCard(_generalRequests[index], screenWidth, screenHeight),
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
