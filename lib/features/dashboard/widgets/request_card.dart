// lib/features/dashboard/widgets/request_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(String, String) onStatusUpdate;
  final bool isCompleted;

  const RequestCard({
    super.key,
    required this.request,
    required this.onStatusUpdate,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green.withOpacity(0.5) : Colors.blue.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (isCompleted && request['completedAt'] != null) _buildCompletedDate(),
            const Divider(height: 16),
            _buildInfoRow('Request', request['taskName'] ?? 'N/A'),
            _buildInfoRow('Location', request['roomId'] ?? 'N/A'),
            _buildInfoRow('Description', request['Description'] ?? 'N/A'),
            if (!isCompleted) _buildStatusUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Name: ${request['userName'] ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        request['jobStatus'] ?? 'N/A',
        style: TextStyle(
          color: isCompleted ? Colors.green : Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCompletedDate() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Completed: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(request['completedAt']))}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateButton() {
    return ElevatedButton(
      onPressed: () => onStatusUpdate(
        request['requestJobHistoryId'].toString(),
        'In Progress',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff013457),
        foregroundColor: Colors.white,
      ),
      child: const Text('Update Status'),
    );
  }
}