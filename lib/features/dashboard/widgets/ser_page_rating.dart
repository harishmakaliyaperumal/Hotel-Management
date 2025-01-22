import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/apiservices.dart';
import '../services/services_models/ser_models.dart';


class ServicesRating extends StatefulWidget {
  final RequestJob request;
  final int requestJobHistoryId;
  final VoidCallback onRatingSubmitted;


  const ServicesRating({Key? key, required this.requestJobHistoryId, required this.request,required this.onRatingSubmitted,})
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

  void _updateSubmitButton() {
    setState(() {
      _isSubmitEnabled = _rating > 0 || _commentController.text.isNotEmpty;
    });
  }

  void _submitRating() async {
    if (_rating > 0) {
      int requestJobHistoryId = widget.requestJobHistoryId; // Pass as int
      String ratingComment = _commentController.text;

      setState(() {
        _isSubmitting = true;
        _updateSubmitButton();
      });

      try {
        await _apiService.submitCustomerFeedback(
          requestJobHistoryId, // Pass as int
          ratingComment,
          _rating,

        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onRatingSubmitted();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _updateSubmitButton();
          });
        }
      }
    } else {
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
            onChanged: (_) => _updateSubmitButton(),
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