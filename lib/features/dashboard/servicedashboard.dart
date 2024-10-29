// import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holtelmanagement/features/auth/login.dart';
import 'package:holtelmanagement/features/dashboard/serdash/breakhistory.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
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
class _ServicesDashboardState extends State<ServicesDashboard> with SingleTickerProviderStateMixin {
  bool _jobStatus = false;
  List<Map<String, dynamic>> _generalRequests = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool isfinished = false;
  List<String> statusHistory = [];
  DateTime? _selectedDate;
  late TabController _tabController;
  List<Map<String, dynamic>> _availableRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];
  List<Map<String, dynamic>> _filteredCompletedRequests = [];
  DateTime? _lastNotificationTime;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentStatusIndex = 0; // Index for tracking current status
  final List<String> _statuses = [
    'Accepted',
    'In Progress',
    'Door Checking',
    'Customer Feedback',
    'Completed'
  ];
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Check initial job status and load requests if active
    _checkInitialJobStatus();
    _selectedDate = DateTime.now();
    _initAudio();
    _startAutoRefresh();

    _tabController.addListener(() {
      if (_tabController.index == 1) { // Completed tasks tab
        _filterCompletedTasks();
      }
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _filterCompletedTasks() {
    if (_selectedDate == null) {
      setState(() {
        _filteredCompletedRequests = List.from(_completedRequests);
      });
      return;
    }

    setState(() {
      _filteredCompletedRequests = _completedRequests.where((request) {
        if (request['completedAt'] == null) return false;

        DateTime completedDate = DateTime.parse(request['completedAt']);
        return DateUtils.isSameDay(completedDate, _selectedDate);
      }).toList();
    });
  }

  // Add new method to show date picker
  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff013457),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _filterCompletedTasks();
    }
  }


  void _startAutoRefresh() {
    // Cancel existing timer if any
    _autoRefreshTimer?.cancel();

    // Set up periodic refresh every 30 seconds
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_jobStatus && mounted) {
        _fetchGeneralRequests();
      }
    });
  }

  Future<void> _initAudio() async {
    // Load the default system notification sound
    await _audioPlayer.setAsset('assets/audio/notification1.wav');
    await _audioPlayer.setVolume(0.1);

    await _audioPlayer.setLoopMode(LoopMode.off);
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
        await _apiService.Statusupdate(
          widget.userId,
          currentStatus,
          requestJobHistoryId,
        );

        // Play system sound for status update
        // await _playSystemSound();

        setState(() {
          request['jobStatus'] = currentStatus;
          String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(
              DateTime.now());
          statusHistory.add('$timestamp: $currentStatus');

          if (_currentStatusIndex < _statuses.length - 1) {
            _currentStatusIndex++;
            request['nextJobStatus'] = _statuses[_currentStatusIndex];
          } else {
            request['nextJobStatus'] = 'Completed';
          }
        });

        String nextStatus = _currentStatusIndex < _statuses.length - 1
            ? _statuses[_currentStatusIndex]
            : 'Completed';

        _showOverlayNotification(
            'Status updated: $currentStatus → $nextStatus',
            isNew: false
        );
      } catch (e) {
        print('Failed to update task: ${e.toString()}');
        _showSnackBar(
            'Failed to update status: ${e.toString()}', isError: true);
      }
    }
  }


  Future<void> _playNotificationSound() async {
    if (_lastNotificationTime == null ||
        DateTime.now().difference(_lastNotificationTime!) >
            Duration(seconds: 1)) {
      try {
        // Play system notification sound
        await SystemSound.play(SystemSoundType.alert);

        // Additional bell sound using just_audio
        await _audioPlayer.setClip(
          start: Duration.zero,
          end: Duration(seconds: 3),
        );

        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();

        _lastNotificationTime = DateTime.now();
      } catch (e) {
        print('Error playing notification sound: $e');
      }
    }
  }


  void _showOverlayNotification(String message, {bool isNew = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                isNew ? Icons.notifications_active : Icons.notifications,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isNew ? 'New Request!' : 'Request Update',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isNew ? Colors.blue.shade700 : Colors.green.shade600,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
    } catch (e) {
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

      // Filter available and completed requests
      _availableRequests =
          requests.where((request) => request['jobStatus'] != 'Completed')
              .toList();
      _completedRequests =
          requests.where((request) => request['jobStatus'] == 'Completed')
              .toList();

      _completedRequests = requests.where((request) {
        bool isCompleted = request['jobStatus'] == 'Completed';
        if (isCompleted && request['completedAt'] == null) {
          request['completedAt'] = DateTime.now()
              .toIso8601String(); // Add timestamp for completed tasks
        }
        return isCompleted;
      }).toList();


      _filterCompletedTasks();


      // Check for new requests
      final newRequests = _availableRequests.where((newRequest) =>
      !_generalRequests.any((oldRequest) =>
      oldRequest['requestJobHistoryId'] == newRequest['requestJobHistoryId']))
          .toList();

      if (newRequests.isNotEmpty) {
        await _playNotificationSound();

        // for (var request in newRequests) {
        //   _showOverlayNotification(
        //       '${request['userName']} - ${request['taskName']} (${request['roomName']})',
        //       isNew: true
        //   );
        // }
      }

      setState(() {
        _generalRequests = requests; // Update with all requests
      });

      if (_jobStatus && _availableRequests.isEmpty) {
        _showSnackBar('No tasks available at the moment');
      }
    } catch (e) {
      print('Error fetching requests: $e');
      // _showSnackBar('Error loading requests. Please try again.', isError: true);
      setState(() {
        _generalRequests = [];
        _availableRequests = [];
        _completedRequests = [];
        _filteredCompletedRequests = [];
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green.withOpacity(0.5) : Colors.blue.withOpacity(0.5),
          width: 1,
        ),
      ),
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request['jobStatus'] ?? 'N/A',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.blue,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (isCompleted && request['completedAt'] != null)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Completed: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(request['completedAt']))}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            Divider(height: screenHeight * 0.02),
            _buildInfoRow('Request', request['taskName'] ?? 'N/A', screenWidth),
            _buildInfoRow('Location', request['roomId'] ?? 'N/A', screenWidth),
            _buildInfoRow('Description', request['Description'] ?? 'N/A', screenWidth),
            if (!isCompleted) ...[
              SizedBox(height: screenHeight * 0.015),
              SwipeableButtonView(
                buttonText: "Swipe to Update Status",
                buttonWidget: Icon(
                  Icons.arrow_back_ios_new_sharp,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
                onWaitingProcess: () async {
                  await Future.delayed(Duration(seconds: 1));
                  if (mounted) {
                    setState(() {
                      isfinished = true;
                    });
                    await _updateJobStatus();
                  }
                },
                activeColor: Color(0xff013457),
                isFinished: isfinished,
                onFinish: () {
                  setState(() {
                    isfinished = false;
                  });
                },
              ),
            ],
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
        await Future.delayed(Duration(seconds: 1));

        // Update the status when swipe is completed
        await _updateJobStatus(); // This will handle API and UI updates

        setState(() {
          isfinished = true; // Indicate that the swipe action is finished
        });
      },
      activeColor: Color(0xff013457),
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


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight * 2),
          child: Column(
            children: [
              buildAppBar(
                context,
                widget.userName,
                    () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                extraActions: [
                  IconButton(
                    icon: Icon(
                        Icons.free_breakfast_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              BreakHistory(userId: widget.userId),
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
              Container(
                color: Color(0xff013457),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pending_actions),
                          SizedBox(width: 8),
                          Text('Available (${_availableRequests.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt),
                          SizedBox(width: 8),
                          Text('Completed (${_completedRequests.length})'),
                        ],
                      ),
                    ),
                  ],
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (_jobStatus) {
              await _fetchGeneralRequests();
            }
          },
          child: _jobStatus ? TabBarView(
            controller: _tabController,
            children: [
              // Available Tasks Tab
              _buildTaskList(
                  _availableRequests, screenWidth, screenHeight, false),
              // Completed Tasks Tab
              _buildTaskList(
                  _completedRequests, screenWidth, screenHeight, true),
            ],
          ) : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.toggle_off_outlined,
                  size: screenWidth * 0.12,
                  color: Colors.grey[400],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Toggle status to active to view requests',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, double screenWidth, double screenHeight, bool isCompleted) {
    return Column(
      children: [
        if (isCompleted) _buildFilterHeader(screenWidth, screenHeight),
        Expanded(
          child: _buildTaskListContent(
            isCompleted ? _filteredCompletedRequests : tasks,
            screenWidth,
            screenHeight,
            isCompleted,
          ),
        ),
      ],
    );
  }


  Widget _buildFilterHeader(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDate != null
                ? 'Completed on ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'
                : 'All completed tasks',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
              color: Color(0xff013457),
            ),
          ),
          Row(
            children: [
              if (_selectedDate != null)
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                    _filterCompletedTasks();
                  },
                  tooltip: 'Clear date filter',
                ),
              IconButton(
                icon: Icon(
                  Icons.calendar_month,
                  color: Color(0xff013457),
                ),
                onPressed: _showDatePicker,
                tooltip: 'Select date',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListContent(List<Map<String, dynamic>> tasks, double screenWidth, double screenHeight, bool isCompleted) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.task_alt : Icons.inbox_outlined,
              size: screenWidth * 0.12,
              color: Colors.grey[400],
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              isCompleted
                  ? _selectedDate != null
                  ? 'No completed tasks on ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'
                  : 'No completed tasks'
                  : 'No available requests at the moment',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildRequestCard(tasks[index], screenWidth, screenHeight),
    );
  }

}

