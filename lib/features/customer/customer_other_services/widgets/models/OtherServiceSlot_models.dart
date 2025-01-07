class OtherServiceSlot {
  final int status;
  final String message;
  final OtherServiceData data;

  OtherServiceSlot({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OtherServiceSlot.fromJson(Map<String, dynamic> json) {
    return OtherServiceSlot(
      status: json['status'],
      message: json['message'],
      data: OtherServiceData.fromJson(json['data']),
    );
  }
}

class OtherServiceData {
  final int id;
  final String serviceName;
  final int serviceCreatedBy;
  final bool serviceStatus;
  final Map<String, List<Schedule>> schedule;

  OtherServiceData({
    required this.id,
    required this.serviceName,
    required this.serviceCreatedBy,
    required this.serviceStatus,
    required this.schedule,
  });

  factory OtherServiceData.fromJson(Map<String, dynamic> json) {
    final scheduleMap = <String, List<Schedule>>{};
    (json['schedule'] as Map<String, dynamic>).forEach((key, value) {
      scheduleMap[key] = (value as List)
          .map((item) => Schedule.fromJson(item as Map<String, dynamic>))
          .toList();
    });

    return OtherServiceData(
      id: json['id'],
      serviceName: json['serviceName'],
      serviceCreatedBy: json['serviceCreatedBy'],
      serviceStatus: json['serviceStatus'],
      schedule: scheduleMap,
    );
  }
}

class Schedule {
  final int scheduleId;
  final String startTime;
  final String endTime;
  final int servicePersonCount;

  Schedule({
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    required this.servicePersonCount,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['scheduleId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      servicePersonCount: json['servicePersonCount'],
    );
  }
}