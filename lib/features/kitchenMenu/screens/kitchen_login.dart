import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import '../kitchen_models/data.dart';

class KitchenLogin extends StatefulWidget {
  const KitchenLogin({super.key});

  @override
  State<KitchenLogin> createState() => _KitchenLoginState();
}

class _KitchenLoginState extends State<KitchenLogin> {
  final ApiService kitchenService = ApiService();
  late Future<List<KitchenRequest>> kitchenRequests;

  // Map to track the swipe state for each request
  Map<int, bool> isFinished = {};

  @override
  void initState() {
    super.initState();
    _fetchKitchenRequests();
  }

  // Fetch kitchen requests from the API
  void _fetchKitchenRequests() {
    setState(() {
      kitchenRequests = kitchenService.getAllRequestKitchen();
    });
  }

  // Determine the next status based on current status
  String? _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Requested':
        return 'KichenAccepted';
      case 'KichenAccepted':
        return 'KitchenInProgress';
    // case 'KitchenInProgress':
    //   return 'KitchenInProgressCompleted';
      default:
        return null;
    }
  }

  // Get status color based on current status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Requested':
        return Colors.blue;
      case 'KichenAccepted':
        return Colors.orange;
      case 'KitchenInProgress':
        return Colors.green;
      case 'KitchenInProgressCompleted':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  // Handle status update process
  Future<void> _handleStatusUpdate(KitchenRequest request) async {
    try {
      // Get the next status
      String? nextStatus = _getNextStatus(request.requestOrderStatus);

      if (nextStatus == null) {
        _showSnackBar('No further status updates available', Colors.grey);
        return;
      }


      // Create updated request
      KitchenRequest updatedRequest = KitchenRequest(
        restaurantOrderId: request.restaurantOrderId,
        requestOrderStatus: nextStatus,
        requestData: request.requestData,
      );

      // Call API to update status
      String? responseMessage = await kitchenService.updateRequestStatus(
          updatedRequest.restaurantOrderId,
          updatedRequest.requestOrderStatus
      );

      if (responseMessage != null) {
        _showSnackBar('Order moved to $nextStatus', Colors.green);
        _fetchKitchenRequests();
      } else {
        _showSnackBar('Failed to update status', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error updating status: $e', Colors.red);
    }
  }

  // Show a snackbar with a message
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Requests"),
      ),
      body: FutureBuilder<List<KitchenRequest>>(
        future: kitchenRequests,
        builder: (context, snapshot) {
          // Handle different snapshot states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Kitchen Requests Available'));
          }

          // Build the list of kitchen requests
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final request = data[index];
              final restaurantOrderId = request.restaurantOrderId;
              final status = request.requestOrderStatus;

              // Initialize swipe state if not already set
              isFinished.putIfAbsent(restaurantOrderId, () => false);

              return _buildKitchenRequestCard(request, restaurantOrderId);
            },
          );
        },
      ),
    );
  }

  // Build individual kitchen request card
  Widget _buildKitchenRequestCard(KitchenRequest request, int restaurantOrderId) {
    final status = request.requestOrderStatus;

    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xFF2A6E75), // Consistent border color
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with restaurant name and status
            _buildHeaderRow(request),
            const SizedBox(height: 8),

            // Description and order ID
            Text('Description: ${request.requestData.description}, Order ID: ${request.restaurantOrderId}'),
            const SizedBox(height: 10),

            // Swipeable button for status update
            _buildSwipeableButton(request, restaurantOrderId),
          ],
        ),
      ),
    );
  }

  // Build header row with restaurant name and status
  Widget _buildHeaderRow(KitchenRequest request) {
    final status = request.requestOrderStatus;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          request.requestData.rname,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Build swipeable button for status update
  // Widget _buildSwipeableButton(KitchenRequest request, int restaurantOrderId) {
  //   return Center(
  //     child: SwipeableButtonView(
  //       isFinished: isFinished[restaurantOrderId]!,
  //       isDisabled: !canUpdateStatus,
  //       onWaitingProcess: () {
  //         Future.delayed(const Duration(seconds: 1), () {
  //           setState(() {
  //             isFinished[restaurantOrderId] = true;
  //           });
  //         });
  //       },
  //       onFinish: () async {
  //         // Reset button state
  //         setState(() {
  //           isFinished[restaurantOrderId] = false;
  //         });
  //
  //         // Handle status update
  //         await _handleStatusUpdate(request);
  //       },
  //
  //
  //
  //       buttonWidget: const Icon(
  //         Icons.arrow_forward_ios,
  //         color: Colors.grey,
  //       ),
  //       activeColor: Color(0xFF2A6E75),
  //       buttonColor: Colors.white,
  //       disableColor: Colors.grey,
  //       buttonText: 'Swipe to Update Status',
  //     ),
  //   );
  // }

  Widget _buildSwipeableButton(KitchenRequest request, int restaurantOrderId) {
    // Determine if the button should be active
    bool canUpdateStatus = _getNextStatus(request.requestOrderStatus) != null;

    return Center(
      child: SwipeableButtonView(
        isFinished: isFinished[restaurantOrderId]!,
        // Custom logic for disabled-like behavior (as `isDisabled` is not a valid parameter)
        onWaitingProcess: canUpdateStatus
            ? () {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              isFinished[restaurantOrderId] = true;
            });
          });
        }
            : () {}, // Provide a no-op callback when disabled
        onFinish: canUpdateStatus
            ? () async {
          setState(() {
            isFinished[restaurantOrderId] = false;
          });
          await _handleStatusUpdate(request);
        }
            : () {}, // Provide a no-op callback when disabled
        buttonWidget: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
        ),
        activeColor: const Color(0xFF2A6E75),
        buttonColor: Colors.white,
        disableColor: Colors.grey,
        buttonText: canUpdateStatus
            ? 'Swipe to Update Status'
            : 'No Further Updates',
      ),
    );
  }



}