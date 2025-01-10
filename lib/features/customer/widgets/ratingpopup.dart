import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';

class RatingPopup extends StatefulWidget {
  final Map<String, dynamic> task;
  final  String requestDataId;
  final String? otherServiceHistoryId;



  const RatingPopup({Key? key, required this.task, required this.requestDataId,this.otherServiceHistoryId, }) : assert(requestDataId != null || otherServiceHistoryId != null),
        super(key: key);

  @override
  _RatingPopupState createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitEnabled = false;
  bool _isSubmitting = false;
  final ApiService _apiService = ApiService();


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }



  void _updateSubmitButton() {
    setState(() {
      _isSubmitEnabled = _rating > 0 && !_isSubmitting;
    });
  }

  Future<void> _submitRating() async {
    if (_rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _updateSubmitButton();
    });

    try {
      // Print all data before making the API call
      print('Submitting Rating Data:');
      print('Task Name: ${widget.task['taskName']}');
      print('Rating: $_rating');
      print('Comments: ${_commentController.text}');

      // Make the API call
      await _apiService.StatusupdateRatting(
        widget.requestDataId, // Pass requestDataId
        widget.otherServiceHistoryId, // Pass otherServiceHistoryId
        _commentController.text,
        _rating.toInt(),
      );

      // Print success message
      print('Rating submitted successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Print error message
      print('Failed to submit rating: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _updateSubmitButton();
        });
      }
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
          child: _isSubmitting
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text('Submit'),
        ),
      ],
    );
  }

}