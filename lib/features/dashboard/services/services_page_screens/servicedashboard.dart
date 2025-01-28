import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holtelmanagement/features/auth/screens/login.dart';
import 'package:holtelmanagement/features/dashboard/widgets/customtabbar.dart';
import 'package:holtelmanagement/features/dashboard/widgets/ser_page_rating.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:holtelmanagement/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import '../../../../classes/language.dart';
import '../../../../common/helpers/app_bar.dart';
import '../../../../common/helpers/shared_preferences_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/completedtaskcard.dart';
import '../services_models/ser_models.dart';


class ServicesDashboard extends StatefulWidget {
  final int userId;
  final String userName;
  final String? roomNo;
  final String? floorId;
  final int hotelId;


  const ServicesDashboard({super.key,
    required this.userId,
    required this.userName,
    this.roomNo,
    this.floorId,
    required this.hotelId,

  });

  @override
  _ServicesDashboardState createState() => _ServicesDashboardState();
}
class _ServicesDashboardState extends State<ServicesDashboard> with SingleTickerProviderStateMixin {
  // final int userId = widget.userId;
  bool _jobStatus = true;
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
  final Set<String> _ratedRequests = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  Language _selectedLanguage = Language.languageList()[0];
  final SharedPreferencesHelper prefsHelper = SharedPreferencesHelper();
  bool _isRatingDialogOpen = false;
  int _currentStatusIndex = 0; // Index for tracking current status
  final List<String> _statuses = [
    'Accepted',
    'In Progress',
    'Door Checking',
    'Customer Feedback',
    'Completed'
  ];
  Timer? _autoRefreshTimer;
  Map<String, int> selectedTimes = {};
  final List<int> timeOptions = List.generate(12, (index) => (index + 1) * 5);


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
        // _filterCompletedTasks();
      }
    });
  }

  void _changeLocale(Language language) {
    setState(() {
      _selectedLanguage = language;
      // Add code here if you need to update app's locale based on language selection
    });
  }


  void _showRatingDialog(Map<String, dynamic> request) {
    String requestId = request['requestJobHistoryId'].toString();

    // Check if this request has already been rated or if the dialog is already open
    if (_ratedRequests.contains(requestId) || _isRatingDialogOpen) {
      return;
    }

    int requestJobHistoryId = int.tryParse(requestId) ?? 0;
    if (requestJobHistoryId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid request ID.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRatingDialogOpen = true; // Set the dialog as open
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ServicesRating(
          requestJobHistoryId: requestJobHistoryId,
          request: RequestJob.fromJson(request),
          onRatingSubmitted: () {
            // Add request to rated set
            setState(() {
              _ratedRequests.add(requestId);
              _isRatingDialogOpen = false; // Reset the dialog state
            });
          },
        );
      },
    ).then((_) {
      // Ensure the dialog state is reset even if dismissed without submission
      if (mounted) {
        setState(() {
          _isRatingDialogOpen = false;
        });
      }
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    _autoRefreshTimer?.cancel();
    _isRatingDialogOpen = false;
    super.dispose();

  }


  final Set<String> _shownTimeSelectionRequests = Set<String>();

  Future<void> _showTimeSelectionDialog(Map<String, dynamic> request) async {
    final String requestId = request['requestJobHistoryId'].toString();
    bool isLoading = false;

    // Prevent multiple dialogs for same request
    if (_shownTimeSelectionRequests.contains(requestId)) {
      return;
    }

    _shownTimeSelectionRequests.add(requestId);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return WillPopScope(
              onWillPop: () async => false, // Disable back button
              child: AlertDialog(
                title: Text(
                  'Estimation Time',
                  style: const TextStyle(
                    color: Color(0xFF2A6E75),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: timeOptions.map((time) {
                      bool isSelected = selectedTimes[requestId] == time;
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            selectedTimes[requestId] = time;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF2A6E75) : Colors.white,
                            border: Border.all(
                              color: Color(0xFF2A6E75),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${time}m',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Color(0xFF2A6E75),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: isLoading
                    ? []
                    : [
                  TextButton(
                    onPressed: () {
                      _shownTimeSelectionRequests.remove(requestId);
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF2A6E75)),
                    ),
                  ),
                  TextButton(
                    onPressed: selectedTimes[requestId] == null
                        ? null
                        : () async {
                      setDialogState(() {
                        isLoading = true;
                      });

                      try {
                        if (mounted) {
                          setState(() {
                            request['estimationTime'] =
                                selectedTimes[requestId].toString();
                          });

                          await _apiService.Statusupdate(
                            widget.userId,
                            request['jobStatus'] ?? 'Accepted',
                            requestId,
                            selectedTimes[requestId].toString(),
                          );

                          await _fetchGeneralRequests();

                          _showOverlayNotification(
                            'Estimation time updated: ${selectedTimes[requestId]}m',
                            isNew: false,
                          );

                          _shownTimeSelectionRequests.remove(requestId);
                          Navigator.of(dialogContext).pop();
                        }
                      } catch (e) {
                        print('Failed to update estimation time: ${e.toString()}');
                        if (mounted) {
                          _showSnackBar(
                            'Failed to update estimation time: ${e.toString()}',
                            isError: true,
                          );
                        }
                      } finally {
                        setDialogState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: selectedTimes[requestId] == null
                            ? Colors.grey
                            : Color(0xFF2A6E75),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Ensure request is removed from tracked dialogs
      _shownTimeSelectionRequests.remove(requestId);
    }).catchError((_) {
      // Handle any unexpected errors
      _shownTimeSelectionRequests.remove(requestId);
    });
  }

// Add this to your class-level variables


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
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2A6E75),
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
      // _filterCompletedTasks();
    }
  }


  void _startAutoRefresh() {
    // Cancel existing timer if any
    _autoRefreshTimer?.cancel();

    // Set up periodic refresh every 30 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_jobStatus && mounted) {
        _fetchGeneralRequests();
      }
    });
  }

  Future<void> _initAudio() async {
    try {
      // Set volume
      await _audioPlayer.setVolume(0.1);

      // Load the default system notification sound
      await _audioPlayer.setAsset('assets/audio/notification1.wav');

      // Set loop mode
      await _audioPlayer.setLoopMode(LoopMode.off);
    } catch (e) {
      print('Audio initialization error: $e');
    }
  }


  Future<bool> _onWillPop() async {
    return false; // Return false to disable back button
  }

  Map<String, int> _requestStatusIndices = {};

  Future<void> _updateJobStatus(Map<String, dynamic> request) async {
    if (request != null) {
      String requestJobHistoryId = request['requestJobHistoryId'].toString();
      String currentStatus = request['jobStatus'] ?? 'Accepted';

      // Find the index of the current status in the _statuses list
      int currentIndex = _statuses.indexOf(currentStatus);

      // Determine the next status
      String nextStatus = currentIndex < _statuses.length - 1
          ? _statuses[currentIndex + 1]
          : 'Completed';

      String estimationTime = selectedTimes[requestJobHistoryId]?.toString() ??
          request['estimationTime']?.toString() ??
          '0';

      try {
        // Update status on the backend using the next status
        await _apiService.Statusupdate(
          widget.userId,
          nextStatus,
          requestJobHistoryId,
          estimationTime,
        );

        // Immediately fetch fresh data after status update
        await _fetchGeneralRequests();

        _showOverlayNotification(
            'Status updated: $currentStatus → $nextStatus',
            isNew: false
        );

      } catch (e) {
        print('Failed to update task: ${e.toString()}');
        _showSnackBar('Failed to update status: ${e.toString()}', isError: true);
      }
    }
  }


  Future<void> _playNotificationSound(dynamic flag) async {
    if (_lastNotificationTime == null ||
        DateTime.now().difference(_lastNotificationTime!) >
            const Duration(seconds: 1)) {
      try {
        // Debug print to confirm flag value
        print('Notification Flag: $flag');

        // Check flag type and convert to string for comparison
        String flagStr = flag.toString();

        // Play specific sound for flag 1
        if (flagStr == '1') {
          print('Playing specific notification sound');
          await _audioPlayer.setAsset('assets/audio/specification1.mp3');
        }
        // Default sound for null, 0, or any other value
        else {
          print('Playing default notification sound');
          await _audioPlayer.setAsset('assets/audio/notification1.wav');
        }

        // Additional volume and clip settings for clarity
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.setClip(
          start: Duration.zero,
          end: const Duration(seconds: 3),
        );

        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();

        _lastNotificationTime = DateTime.now();
      } catch (e) {
        print('Error playing notification sound: $e');
        // Print more detailed error information
        print('Audio Player Error Details: $e');
      }
    }
  }


  void _showOverlayNotification(String message,
      {bool isNew = false, String? status}) {
    if (!mounted) return;

    // Dismiss any existing Snackbars before showing a new one
    ScaffoldMessenger.of(context).clearSnackBars();

    bool isDoorChecking = status == 'Door Checking';
    String displayMessage = isDoorChecking ? 'Delivered' : message;

    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isNew ? Icons.notifications_active : Icons.notifications,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isNew ? 'New Request!' : 'Request Update',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: isNew ? Colors.blue.shade700 : Colors.green.shade600,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    // Dismiss any existing Snackbars before showing a new one
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : AppColors.backgroundColor,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      _showSnackBar('Error updating status: ${e.toString()}', isError: true);
      setState(() {
        _jobStatus = !newValue; // Revert to original state on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _fetchGeneralRequests() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all requests first
      final requests = await _apiService.getGeneralRequestsById();

      // Process the fetched data
      final availableRequests = requests.where((request) {
        final status = request['jobStatus']?.toString().toLowerCase() ?? '';
        return status != 'completed' && status != 'cancelled';
      }).toList();

      final completedRequests = requests.where((request) {
        final status = request['jobStatus']?.toString().toLowerCase() ?? '';
        return status == 'completed';
      }).toList();

      // Check for new requests and play notification if needed
      final newRequests = availableRequests.where((newRequest) =>
      !_generalRequests.any((oldRequest) =>
      oldRequest['requestJobHistoryId'] == newRequest['requestJobHistoryId']))
          .toList();

      if (newRequests.isNotEmpty) {
        for (var request in newRequests) {
          await _playNotificationSound(request['flag']);
        }
      }

      // Update state
      setState(() {
        _generalRequests = requests;
        _availableRequests = availableRequests;
        _completedRequests = completedRequests;
        // _filteredCompletedRequests = _filterCompletedRequestsByDate(completedRequests);
      });

      if (_jobStatus && availableRequests.isEmpty) {
        _showSnackBar(AppLocalizations.of(context).translate('ser_pg_notify_no_tasks'));
      }
    } catch (e) {
      print('Error fetching requests: $e');
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
    bool isDoorChecking = request['jobStatus'] == 'Door Checking';
    bool isKitchenInProgress = request['jobStatus'] == 'KitchenInProgress';
    bool isAccepted = request['jobStatus'] == 'Accepted';
    bool isCustomerFeedback = request['jobStatus'] == 'Customer Feedback'; // New condition

    if (isAccepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if type is 'user' and time hasn't been selected yet
        if (request['type'] == 'user' &&
            !selectedTimes.containsKey(request['requestJobHistoryId'].toString()) &&
            mounted) {
          _showTimeSelectionDialog(request);
        }
      });
    }

    // Show rating dialog if status is Customer Feedback
    if (isCustomerFeedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRatingDialog(request);
      });
    }

    String currentLanguage = Localizations.localeOf(context).languageCode;
    String description = currentLanguage == 'no'
        ? request['DescriptionNorweign'] ?? 'No description available'
        : request['Description'] ?? 'No description available';

    return Card(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green.withOpacity(0.5) : Color(0xFF2A6E75).withOpacity(0.5),
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
                    '${AppLocalizations.of(context).translate('ser_pg_history_text_name')}: ${request['name'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedTimes.containsKey(request['requestJobHistoryId'].toString())) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${selectedTimes[request['requestJobHistoryId'].toString()]}m',
                          style: TextStyle(
                            color: Color(0xFF2A6E75),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isDoorChecking
                            ? 'Delivered'
                            : isKitchenInProgress
                            ? 'Kitchen in Progress'
                            : AppLocalizations.of(context).translate(
                            request['jobStatus']?.toLowerCase()?.replaceAll(' ', '_') ?? 'unknown_status'
                        ),
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Color(0xFF2A6E75),
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isCompleted && request['completedAt'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${AppLocalizations.of(context).translate('ser_pg_history_text_completed')}: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(request['completedAt']))}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            Divider(height: screenHeight * 0.02),
            _buildInfoRow(
                AppLocalizations.of(context).translate('ser_pg_com_his_text_request'),
                request['taskName'] ?? 'N/A',
                screenWidth,
                request
            ),
            _buildInfoRow(
                AppLocalizations.of(context).translate('ser_pg_history_card_text_location'),
                request['roomName'] ?? 'N/A',
                screenWidth,
                request
            ),
            _buildInfoRow(
                AppLocalizations.of(context).translate('ser_pg_history_card_text_description'),
                description,
                screenWidth,
                request
            ),
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
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    setState(() {
                      isfinished = true;
                    });

                    // Determine if time selection is required
                    bool needsTimeSelection = request['type'] == 'user' &&
                        request['jobStatus'] == 'Accepted' &&
                        !selectedTimes.containsKey(request['requestJobHistoryId'].toString());

                    if (needsTimeSelection) {
                      // For 'user' type on 'Accepted' status without time selection
                      await _showTimeSelectionDialog(request);
                    } else {
                      // Normal status update flow
                      if (isKitchenInProgress) {
                        await _updateJobStatus(request);
                        await _updateJobStatus(request);
                      } else {
                        await _updateJobStatus(request);
                      }
                    }
                  }
                },
                activeColor: const Color(0xff2A6E75),
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





  Widget _buildInfoRow(String label, String value, double screenWidth,
      Map<String, dynamic> request) {
    final bool isDescription = label == AppLocalizations.of(context).translate(
        'ser_pg_history_card_text_description');

    if (!mounted) return const SizedBox.shrink();

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
            child: isDescription
                ? _buildDescriptionWithLink(value, screenWidth, request)
                : Text(
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


  Widget _buildDescriptionWithLink(String description, double screenWidth, Map<String, dynamic> request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black87,
            ),
          ),
        ),
      ],
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

    Widget _buildInactiveContent() {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: screenHeight - kToolbarHeight * 2,
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
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 2),
          child: Column(
            children: [
              buildAppBar(
                context: context,
                onLanguageChange: (Language newLanguage) {
                  // Handle language change
                },
                isLoginPage: false,
                extraActions: [],
                dashboardType: DashboardType.services,
                onLogout: () {
                  logOut(context);
                },
                apiService: _apiService,

              ),
              CustomTabBar(
                tabController: _tabController,
                availableRequestsCount: _availableRequests.length,
                completedRequestsCount: _completedRequests.length,
                onTabChanged: (index) {
                  _tabController.animateTo(index);
                },
              ),
            ],
          ),
        ),

        // RefreshIndicator function
        body: RefreshIndicator(

          onRefresh: () async {
            if (_jobStatus) {
              await _fetchGeneralRequests();
            }
          },
          child: _jobStatus
              ? TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe
            children: [
              // Available Tasks Tab
              _buildTaskList(
                _availableRequests,
                screenWidth,
                screenHeight,
                false,
              ),
              // Completed Tasks Tab
              _buildTaskList(
                _completedRequests,
                screenWidth,
                screenHeight,
                true,
              ),
            ],
          )
              : Center(child: _buildInactiveContent()),
        ),
      ),
    );
  }


  // Completd and filteredCompletedRequests
  Widget _buildTaskList(List<Map<String, dynamic>> tasks, double screenWidth,
      double screenHeight, bool isCompleted) {
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

  // completed date picker function
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDate != null
                ? 'Completed on ${DateFormat('MMM dd, yyyy').format(
                _selectedDate!)}'
                : 'All completed tasks',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2A6E75),
            ),
          ),
          Row(
            children: [
              if (_selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                    // _filterCompletedTasks();
                  },
                  tooltip: 'Clear date filter',
                ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF2A6E75),
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


  // breack function
  Widget _buildTaskListContent(List<Map<String, dynamic>> tasks, double screenWidth, double screenHeight, bool isCompleted) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isCompleted)
              TextButton.icon(
                onPressed: () async {
                  try {
                    await _apiService.notifyBreaks(widget.hotelId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Break notified!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to notify breaks")),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active),
                label: Text(
                  AppLocalizations.of(context).translate('ser_pg_link_notify_breaks'),
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black26,
                ),
              ),
            SizedBox(height: screenHeight * 0.02),
            Icon(
              isCompleted ? Icons.task_alt : Icons.inbox_outlined,
              size: screenWidth * 0.12,
              color: Colors.grey[400],
            ),
            SizedBox(height: screenHeight * 0.04),
            Text(
              isCompleted
                  ? AppLocalizations.of(context).translate('ser_pg_notify_no_completed_tasks')
                  : AppLocalizations.of(context).translate('ser_pg_notify_no_available_requests'),
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.black26,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!isCompleted) {
      // Available Tasks Section (Old Model)
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: TextButton.icon(
              onPressed: () async {
                try {
                  await _apiService.notifyBreaks(widget.hotelId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).translate('ser_pg_notify_break_notified'))),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).translate('ser_pg_notify_failed_to_notify_breaks'))),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active),
              label: Text(
                AppLocalizations.of(context).translate('ser_pg_link_notify_breaks'),
                style: TextStyle(fontSize: screenWidth * 0.02),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black26,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: tasks.length,
              itemBuilder: (context, index) => _buildRequestCard(tasks[index], screenWidth, screenHeight),
            ),
          ),
        ],
      );
    } else {
      // Completed Tasks Section (Fetch All Data Directly from API)
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _apiService.getCompletedRequestsByUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: screenWidth * 0.12,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    AppLocalizations.of(context).translate('ser_pg_notify_no_completed_tasks'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.black26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final completedTasks = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: completedTasks.length,
              itemBuilder: (context, index) => CompletedTaskCard(
                task: completedTasks[index],
              ),
            );
          }
        },
      );
    }
  }
}