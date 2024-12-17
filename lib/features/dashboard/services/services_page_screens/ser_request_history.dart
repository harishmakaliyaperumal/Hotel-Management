import 'package:flutter/material.dart';

import '../../../services/apiservices.dart';
import '../../widgets/ser_page_rating.dart';
import '../services_models/ser_models.dart';

class SerRequestHistory extends StatefulWidget {

  const SerRequestHistory({super.key});

  @override
  State<SerRequestHistory> createState() => _SerRequestHistoryState();
}

class _SerRequestHistoryState extends State<SerRequestHistory> {
  late Future<List<RequestJob>> _serviceRequests;

  @override
  void initState() {
    super.initState();
    _serviceRequests = _fetchRequests(); // Corrected variable name
  }

  Future<List<RequestJob>> _fetchRequests() async {
    final apiService = ApiService();
    return await apiService.getServicesRequestsById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Request History'),
      ),
      body: FutureBuilder<List<RequestJob>>(
        future: _serviceRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No service requests found.'));
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            request.taskName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(request.jobStatus),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              request.jobStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        request.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        request.Description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Text(
                          //   request.taskName,
                          //   style: const TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 12,
                          //     vertical: 6,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: _getStatusColor(request.jobStatus),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //
                          // ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => ServicesRating(request: request, requestJobHistoryId: request.requestJobHistoryId.toString()),
                              );
                            },
                            child: Text(
                              'Feedback',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String jobStatus) {
    switch (jobStatus.trim().toLowerCase()) {  // Trim any unwanted spaces
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

}
