import 'package:flutter/material.dart';

class DescriptionInput extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xffB5E198), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xffB5E198), width: 1.5),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter a description" : null,
    );
  }
}
