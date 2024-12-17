import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';

class RatingPopup extends StatefulWidget {
  final Map<String, dynamic> task;
  final  String requestDataId;


  const RatingPopup({Key? key, required this.task, required this.requestDataId }) : super(key: key);

  @override
  _RatingPopupState createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitEnabled = false;
  bool _isSubmitting = false;
  final ApiService _apiService = ApiService();




  void _updateSubmitButton() {
    setState(() {
      _isSubmitEnabled = _rating > 0 && !_isSubmitting; // Only enable if not submitting
    });
  }

  void _submitRating() async {
    if (_rating > 0) {
      // Extract the required values
      String requestDataId = widget.task['requestDataId'];  // Assuming task contains requestDataId
      String ratingComment = _commentController.text;
      int rating = _rating.toInt();

      // Print values for debugging
      print('Task: ${widget.task['taskName']}');
      print('Rating: $rating');
      // print('Rating: $_rating');
      print('Comment: $ratingComment');

      setState(() {
        _isSubmitting = true;
        _updateSubmitButton(); // Disable submit button
      });

      try {
        // Call the API to submit the rating
        await _apiService.StatusupdateRatting(
            requestDataId, ratingComment, rating);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );

        // Close the dialog
        Navigator.of(context).pop();
      } catch (e) {
        // Handle any errors in the API call
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      finally {
        // After submission (success or failure), reset _isSubmitting
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _updateSubmitButton(); // Re-enable submit button if needed
          });
        }
      }
      // Close the dialog after submitting
      Navigator.of(context).pop();

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
          Text(
            'How was your experience with ${widget.task['taskName'] ?? 'this service'}?',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
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