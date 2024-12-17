import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../services/apiservices.dart';
import '../services/services_models/ser_models.dart';

class ServicesRating extends StatefulWidget {
  final RequestJob request;
  final dynamic requestJobHistoryId;

  const ServicesRating({Key? key, required this.requestJobHistoryId, required this.request})
      : super(key: key);

  @override
  State<ServicesRating> createState() => _ServicesRatingState();
}

class _ServicesRatingState extends State<ServicesRating> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  bool _isSubmitEnabled = false;
  bool _isSubmitting = false;
  final ApiService _apiService = ApiService();

  // Function to update submit button state
  void _updateSubmitButton() {
    setState(() {
      _isSubmitEnabled = _rating > 0 || _commentController.text.isNotEmpty;
    });
  }


  // Function to submit the rating
  void _submitRating() async {
    if (_rating > 0) {
      String requestJobHistoryId = widget.requestJobHistoryId.toString();
      String ratingComment = _commentController.text;


      setState(() {
        _isSubmitting = true;
        _updateSubmitButton(); // Disable submit button
      });

      // print('Submitting rating with details:');
      // print('Request Job History ID: $requestJobHistoryId');
      // print('Rating: $_rating');
      // print('Comment: $ratingComment');
      // print('Attempting to submit rating with requestJobHistoryId: $requestJobHistoryId');
      // // In the widget where you're creating the ServicesRating
      // print('Request Job History ID: ${widget.requestJobHistoryId}');
      // print('Request Job Details: ${widget.request.toString()}');
      try {
        await _apiService.submitCustomerFeedback(
            requestJobHistoryId,
            ratingComment,
            _rating
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );

        // Close the dialog
        Navigator.of(context).pop();
        print('rating');


      } catch (e) {
        print('Feedback submission error: $e'); // Log the specific error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'), // Show more detailed error
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // After submission (success or failure), reset _isSubmitting
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _updateSubmitButton(); // Re-enable submit button if needed
          });
        }
      }
    } else {
      // Show a message if the rating is invalid (e.g., 0 or empty)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a rating.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Rate Your Experience',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
                _updateSubmitButton();
              });
            },
          ),
          SizedBox(height: 20),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add your comments here (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (_) => _updateSubmitButton(), // Update submit button on text change
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitEnabled ? _submitRating : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSubmitEnabled ? Colors.blue : Colors.grey,
          ),
          child: _isSubmitting ? CircularProgressIndicator(color: Colors.white) : Text('Submit'),
        ),
      ],
    );
  }
}
