// lib/features/customer/customer_other_services/models/services_models.dart

import 'models/OtherServiceSlot_models.dart';

class ServiceResponse {
  final int status;
  final String message;
  final List<Service> data;

  ServiceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Service {
  final int id;
  final String serviceName;
  final int serviceCreatedBy;
  final bool serviceStatus;
  final Map<String, List<Schedule>> schedule;

  Service({
    required this.id,
    required this.serviceName,
    required this.serviceCreatedBy,
    required this.serviceStatus,
    required this.schedule,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    Map<String, List<Schedule>> scheduleMap = {};

    if (json['schedule'] is Map) {
      final Map<String, dynamic> scheduleData = json['schedule'];
      scheduleData.forEach((key, value) {
        if (value is List) {
          scheduleMap[key] = value
              .map((item) => Schedule.fromJson(item))
              .toList();
        }
      });
    }

    return Service(
      id: json['id'],
      serviceName: json['serviceName'],
      serviceCreatedBy: json['serviceCreatedBy'],
      serviceStatus: json['serviceStatus'],
      schedule: scheduleMap,
    );
  }
}

// class Schedule {
//   final int scheduleId;
//   final String startTime;
//   final String endTime;
//   final int servicePersonCount;
//
//   Schedule({
//     required this.scheduleId,
//     required this.startTime,
//     required this.endTime,
//     required this.servicePersonCount,
//   });
//
//   factory Schedule.fromJson(Map<String, dynamic> json) {
//     return Schedule(
//       scheduleId: json['scheduleId'],
//       startTime: json['startTime'],
//       endTime: json['endTime'],
//       servicePersonCount: json['servicePersonCount'],
//     );
//   }
// }
