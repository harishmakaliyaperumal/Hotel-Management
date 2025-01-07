// import 'dart:developer';
//
// import 'widgets/models/otherservices_models.dart';  // Import the Service model
//
// class ServiceResponse {
//   final int status;
//   final String message;
//   final List<Service> data;
//
//   ServiceResponse({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   factory ServiceResponse.fromJson(Map<String, dynamic> json) {
//     return ServiceResponse(
//       status: json['status'],
//       message: json['message'],
//       data: (json['data'] as List)
//           .map((item) => Service.fromJson(item as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }