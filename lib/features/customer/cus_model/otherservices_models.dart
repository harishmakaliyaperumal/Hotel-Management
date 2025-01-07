class AllServices {
  final int status;
  final String message;
  final List<ServiceData> data;

  AllServices({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AllServices.fromJson(Map<String, dynamic> json) {
    return AllServices(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => ServiceData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class ServiceData {
  final int id;
  final String serviceName;
  final int serviceCreatedBy;
  final bool serviceStatus;
  final Map<String, dynamic> schedule;

  ServiceData({
    required this.id,
    required this.serviceName,
    required this.serviceCreatedBy,
    required this.serviceStatus,
    required this.schedule,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'],
      serviceName: json['serviceName'],
      serviceCreatedBy: json['serviceCreatedBy'],
      serviceStatus: json['serviceStatus'],
      schedule: json['schedule'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'serviceCreatedBy': serviceCreatedBy,
      'serviceStatus': serviceStatus,
      'schedule': schedule,
    };
  }
}
