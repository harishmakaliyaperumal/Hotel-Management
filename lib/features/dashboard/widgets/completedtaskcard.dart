import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const CompletedTaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.green.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name
            Text(
              task['taskName'] ?? 'No Task Name',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Room Name
            Text(
              'Room: ${task['roomName'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Description
            Text(
              task['Description'] ?? 'No Description',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Completed At
            if (task['completedAt'] != null)
              Text(
                'Completed: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(task['completedAt']))}',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),

            // Feedback Status
            if (task['feedback_status'] == true)
              Text(
                'Feedback Submitted',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}