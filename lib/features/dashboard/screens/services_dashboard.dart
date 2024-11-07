// lib/features/dashboard/screens/services_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/services_provider.dart';
import '../widgets/request_card.dart';

class ServicesDashboard extends StatefulWidget {
  final int userId;
  final String userName;

  const ServicesDashboard({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  _ServicesDashboardState createState() => _ServicesDashboardState();
}

class _ServicesDashboardState extends State<ServicesDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    final provider = Provider.of<ServicesProvider>(context, listen: false);
    await provider.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: provider.fetchRequests,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(
                  provider.availableRequests,
                  provider.updateRequestStatus,
                  false,
                ),
                _buildRequestList(
                  provider.filteredCompletedRequests,
                  provider.updateRequestStatus,
                  true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight * 2),
      child: Consumer<ServicesProvider>(
        builder: (context, provider, child) {
          return AppBar(
            title: Text(widget.userName),
            backgroundColor: const Color(0xff013457),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions),
                      const SizedBox(width: 8),
                      Text('Available (${provider.availableRequests.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.task_alt),
                      const SizedBox(width: 8),
                      Text('Completed (${provider.completedRequests.length})'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestList(
      List<Map<String, dynamic>> requests,
      Function(String, String) onStatusUpdate,
      bool isCompleted,
      ) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No requests available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return RequestCard(
          request: requests[index],
          onStatusUpdate: onStatusUpdate,
          isCompleted: isCompleted,
        );
      },
    );
  }
}