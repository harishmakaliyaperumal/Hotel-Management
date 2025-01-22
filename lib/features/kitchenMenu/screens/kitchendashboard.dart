import 'package:flutter/material.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import '../../../classes/language.dart';
import '../../../common/helpers/app_bar.dart';
import '../kitchen_models/data.dart';
import '../../../../l10n/app_localizations.dart';

class KitchenDashboard extends StatefulWidget {
  const KitchenDashboard({super.key});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  final ApiService kitchenService = ApiService();
  late Future<List<KitchenRequest>> kitchenRequests;
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  Map<int, bool> isFinished = {};

  @override
  void initState() {
    super.initState();
    _fetchKitchenRequests();
  }

  void _fetchKitchenRequests() {
    setState(() {
      kitchenRequests = kitchenService.getAllRequestKitchen();
    });
  }

  String _getLocalizedDescription(KitchenRequest request) {
    final currentLanguage = AppLocalizations.of(context).locale.languageCode;

    switch (currentLanguage) {
      case 'no':
      // First check request level, then requestData level
        return request.descriptionNorwegian.isNotEmpty
            ? request.descriptionNorwegian
            : request.requestData.descriptionNorwegian.isNotEmpty
            ? request.requestData.descriptionNorwegian
            : request.requestData.description;
      case 'ar':
      // First check request level, then requestData level
        return request.descriptionArabian.isNotEmpty
            ? request.descriptionArabian
            : request.requestData.descriptionArabian.isNotEmpty
            ? request.requestData.descriptionArabian
            : request.requestData.description;
      default:
        return request.requestData.description;
    }
  }

  String? _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Requested':
        return 'KichenAccepted';
      case 'KichenAccepted':
        return 'KitchenInProgress';
      default:
        return 'Requested' ;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'KitchenInProgress':
        return Colors.green;
      default:
        return const Color(0xFF2A6E75).withOpacity(0.7);
    }
  }

  Future<void> _handleStatusUpdate(KitchenRequest request) async {
    try {
      String? nextStatus = _getNextStatus(request.requestOrderStatus);
      if (nextStatus == null) {
        _showSnackBar('No further status updates available', Colors.grey);
        return;
      }

      String? responseMessage = await kitchenService.updateRequestStatus(
          request.restaurantOrderId,
          nextStatus
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildKitchenRequestCard(KitchenRequest request, int restaurantOrderId) {
    String localizedDescription = _getLocalizedDescription(request);

    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Color(0xFF2A6E75),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(request),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context).translate('kit_tab_card_des')}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    localizedDescription,
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (request.requestOrderStatus != 'KitchenInProgress')
              _buildSwipeableButton(request, restaurantOrderId),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(KitchenRequest request) {
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
            color: _getStatusColor(request.requestOrderStatus),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            request.requestOrderStatus,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeableButton(KitchenRequest request, int restaurantOrderId) {
    bool canUpdateStatus = _getNextStatus(request.requestOrderStatus) != null;

    return Center(
      child: SwipeableButtonView(
        isFinished: isFinished[restaurantOrderId]!,
        onWaitingProcess: canUpdateStatus
            ? () {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              isFinished[restaurantOrderId] = true;
            });
          });
        }
            : () {},
        onFinish: canUpdateStatus
            ? () async {
          setState(() {
            isFinished[restaurantOrderId] = false;
          });
          await _handleStatusUpdate(request);
        }
            : () {},
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

  Widget _buildCustomTab({
    required String text,
    required int index,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A6E75) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF2A6E75),
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2A6E75),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList({required bool isInProgress}) {
    return FutureBuilder<List<KitchenRequest>>(
      future: kitchenRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Kitchen Requests Available'));
        }

        final filteredData = snapshot.data!.where((request) {
          if (isInProgress) {
            return request.requestOrderStatus == 'KitchenInProgress';
          } else {
            return request.requestOrderStatus == 'Requested' ||
                request.requestOrderStatus == 'KichenAccepted';
          }
        }).toList();

        if (filteredData.isEmpty) {
          return Center(
            child: Text(
                isInProgress ? 'No Requests In Progress' : 'No Available Requests'
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final request = filteredData[index];
            final restaurantOrderId = request.restaurantOrderId;
            isFinished.putIfAbsent(restaurantOrderId, () => false);
            return _buildKitchenRequestCard(request, restaurantOrderId);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        onLanguageChange: (Language newLanguage) {
          setState(() {
            _fetchKitchenRequests();
          });
        },
        isLoginPage: false,
        extraActions: [],
        dashboardType: DashboardType.other,
        onLogout: () => logOut(context),
        apiService: _apiService,

      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomTab(
                  text: AppLocalizations.of(context).translate('kit_tab_heading_text_available_req'),
                  index: 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                  isSelected: _selectedIndex == 0,
                ),
                _buildCustomTab(
                  text: AppLocalizations.of(context).translate('kit_tab_heading_text_completed_req'),
                  index: 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                  isSelected: _selectedIndex == 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildRequestsList(isInProgress: false),
                _buildRequestsList(isInProgress: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}