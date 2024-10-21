import 'package:flutter/material.dart';
import 'package:holtelmanagement/Common/app_bar.dart';
import 'package:holtelmanagement/features/auth/login.dart';
import 'package:holtelmanagement/features/services/apiservices.dart';

class UserDashboard extends StatefulWidget {
  final String userName;
  final int userId;
  final Map<String, dynamic> loginResponse;

  UserDashboard({
    required this.userName,
    required this.userId,
    required this.loginResponse,
  });

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedTaskId; // Store taskDataId
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _tasks = []; // Task list from API
  bool _isLoading = true; // Loading indicator
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Fetch tasks from the API via ApiService
  // Fetch tasks from the API via ApiService
  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Directly use the list returned from fetchTasks
      final tasks = await _apiService.fetchTasks();

      setState(() {
        _tasks = tasks; // No need to extract 'data', tasks is already a List
        _isLoading = false;

        // _selectedTaskId = null;

        // Ensure _selectedTaskId is initialized to the first task if tasks exist
        // if (_tasks.isNotEmpty && _selectedTaskId == null) {
        //   _selectedTaskId = _tasks[0]['taskDataId'] as int;
        // }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tasks: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // Submit request via ApiService
  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _apiService.saveGeneralRequest(
          floorId: 1,
          taskId: _selectedTaskId!, // Pass the selected taskDataId
          roomDataId: 1,
          rname: 'Cleaning Request', // Example data, change as needed
          requestType: 'Customer Request',
          description: _messageController.text,
          requestDataCreatedBy: widget.userId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted successfully')),
        );
        _messageController.clear();
        setState(() {
          _selectedTaskId = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        widget.userName,
            () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown menu for selecting task
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  // labelText: 'Select Task',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.grey,
                ),
                style: TextStyle(color: Colors.black),
                value: _selectedTaskId,
                hint: Text('Select'), // This will show when value is null
                items: _tasks.map((task) {
                  return DropdownMenuItem<int>(
                    value: task['taskDataId'] as int,
                    child: Text(task['taskName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a task';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Description input
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Submit button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightGreenAccent.withOpacity(0.1),
                        Color(0xFF7bb274),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners for the button
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Make the button itself transparent
                      shadowColor: Colors.transparent, // Remove shadow to see gradient clearly
                    ),
                    onPressed: _submitRequest,
                    child: Text(
                      'Send Request',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
