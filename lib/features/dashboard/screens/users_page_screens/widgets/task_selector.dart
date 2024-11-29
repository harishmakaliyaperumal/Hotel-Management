import 'package:flutter/material.dart';

class TaskSelector extends StatelessWidget {
  final int? selectedTaskId;
  final List<Map<String, dynamic>> tasks;
  final Function(int?) onChanged;

  const TaskSelector({
    Key? key,
    required this.selectedTaskId,
    required this.tasks,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xffB5E198), width: 1.5),
        ),
      ),
      value: selectedTaskId,
      hint: Text("Select Task"), // Replace with localization if needed
      items: tasks.map((task) {
        return DropdownMenuItem<int>(
          value: task['taskDataId'] as int,
          child: Text(task['taskName']),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Please select a task" : null,
    );
  }
}
